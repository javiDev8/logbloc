import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:logbloc/main.dart';
import 'package:logbloc/pools/theme_mode_pool.dart';
import 'package:logbloc/utils/feedback.dart';

class MembershipApi {
  //String? productId;
  String? productPrice;

  String currentPlan = '';
  bool welcomed = false;

  Future<void> init() async {
    welcomed = await sharedPrefs.getBool('welcomed') ?? false;
    currentPlan = await sharedPrefs.getString('plan') ?? 'free';
  }

  Future<void> upgrade() async {
    try {
      if (currentPlan == 'base') {
        throw Exception('already on base plan!');
      }

      await purchase();
      currentPlan = 'base';
      await sharedPrefs.setString('plan', 'base');
    } catch (e) {
      throw Exception('upgrade error: $e');
    }
  }

  restorePurchase() async {
    try {
      await InAppPurchase.instance.restorePurchases();
      await sharedPrefs.setString('plan', 'base');
      membershipApi.currentPlan = 'base';
      feedback(
        'purchase successfully restored',
        type: FeedbackType.success,
      );
      themeModePool.emit();
    } catch (e) {
      feedback(
        'There is no purchase to restore!',
        type: FeedbackType.error,
      );
    }
  }

  Future<void> purchase() async {
    final completer = Completer<void>();
    late StreamSubscription<List<PurchaseDetails>> subscription;

    subscription = InAppPurchase.instance.purchaseStream.listen((
      purchaseDetailsList,
    ) {
      for (final purchaseDetails in purchaseDetailsList) {
        if (purchaseDetails.status == PurchaseStatus.pending) {
        } else if (purchaseDetails.status == PurchaseStatus.purchased) {
          InAppPurchase.instance.completePurchase(purchaseDetails);
          if (!completer.isCompleted) {
            completer.complete();
          }
        } else if (purchaseDetails.status == PurchaseStatus.error) {
          if (!completer.isCompleted) {
            completer.completeError(purchaseDetails.error!);
          }
        } else if (purchaseDetails.status == PurchaseStatus.canceled) {
          if (!completer.isCompleted) {
            completer.completeError('Purchase was canceled');
          }
        }
      }
    });

    final ProductDetailsResponse productDetailsResponse =
        await InAppPurchase.instance.queryProductDetails({'12'});

    if (productDetailsResponse.productDetails.isNotEmpty) {
      final ProductDetails productDetails =
          productDetailsResponse.productDetails.first;
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: productDetails,
      );
      InAppPurchase.instance.buyNonConsumable(
        purchaseParam: purchaseParam,
      );
    } else {
      if (!completer.isCompleted) {
        completer.completeError('Product details not found');
      }
    }
    try {
      await completer.future.timeout(const Duration(seconds: 30));
    } catch (e) {
      throw Exception('PURCHASE ERROR: $e');
    } finally {
      subscription.cancel();
    }
  }
}

final membershipApi = MembershipApi();
