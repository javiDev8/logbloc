import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:logbloc/main.dart';
import 'package:logbloc/pools/theme_mode_pool.dart';
import 'package:logbloc/utils/feedback.dart';
import 'package:logbloc/utils/noticable_print.dart';

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

  Future<void> ultimateRestorePurchase() async {
    final Completer<void> completer = Completer<void>();
    StreamSubscription<List<PurchaseDetails>>? subscription;

    subscription = InAppPurchase.instance.purchaseStream.listen(
      (List<PurchaseDetails> purchaseDetailsList) async {
        for (final PurchaseDetails purchaseDetails
            in purchaseDetailsList) {
          if (purchaseDetails.status == PurchaseStatus.restored &&
              purchaseDetails.productID == '13') {
            await InAppPurchase.instance.completePurchase(purchaseDetails);
            completer.complete();
            break;
          }
        }
      },
      onError: (Object error) {
        subscription?.cancel();
        completer.completeError(error);
      },
      onDone: () {
        subscription?.cancel();
      },
    );

    await InAppPurchase.instance.restorePurchases();

    try {
      await completer.future.timeout(const Duration(seconds: 10));
    } on TimeoutException {
      subscription.cancel();
      throw Exception("not-purchased");
    } finally {
      subscription.cancel();
    }
  }

  restorePurchase() async {
    try {
      await ultimateRestorePurchase();
      await sharedPrefs.setString('plan', 'base');
      membershipApi.currentPlan = 'base';
      feedback(
        'purchase successfully restored',
        type: FeedbackType.success,
      );
      themeModePool.emit();
    } catch (e) {
      nPrint('exception: ${e.toString()}');
      if (e.toString() == 'Exception: not-purchased') {
        feedback(
          'You haven\'t purchased it!',
          type: FeedbackType.error,
        );
      } else {
        feedback(
          'purchase restore has failed! try again',
          type: FeedbackType.error,
        );
      }
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
        await InAppPurchase.instance.queryProductDetails({'13'});

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
