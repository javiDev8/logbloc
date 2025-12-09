import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:logbloc/main.dart';
import 'package:logbloc/pools/theme_mode_pool.dart';
import 'package:logbloc/utils/feedback.dart';

class MembershipApi {
  static const String productId = '13';

  String currentPlan = '';
  bool welcomed = false;

  Future<void> init() async {
    welcomed = await sharedPrefs.getBool('welcomed') ?? false;
    currentPlan = await sharedPrefs.getString('plan') ?? 'free';
  }

  Future<bool> theresInternet() async {
    if (!(await InternetConnection().hasInternetAccess)) {
      feedback(
        'You are offline, connect to internet',
        type: FeedbackType.error,
      );
      return false;
    }
    return true;
  }

  grantUnlimited() async {
    currentPlan = 'base';
    await sharedPrefs.setString('plan', 'base');
    themeModePool.emit();
  }

  Future<void> upgrade() async {
    try {
      if (currentPlan == 'base') {
        throw Exception('already on base plan!');
      }
      await purchase();
      await grantUnlimited();
      feedback('Successfully purchased', type: FeedbackType.success);
    } catch (e) {
      throw Exception('upgrade error: $e');
    }
  }

  Future<bool> ultimateRestorePurchase() async {
    final Completer<bool> completer = Completer<bool>();
    StreamSubscription<List<PurchaseDetails>>? subscription;

    subscription = InAppPurchase.instance.purchaseStream.listen(
      (List<PurchaseDetails> purchaseDetailsList) async {
        for (final PurchaseDetails purchaseDetails
            in purchaseDetailsList) {
          if (purchaseDetails.status == PurchaseStatus.restored &&
              purchaseDetails.productID == productId) {
            await InAppPurchase.instance.completePurchase(purchaseDetails);

            if (!completer.isCompleted) {
              completer.complete(true);
              await subscription?.cancel();
            }
            return;
          }
        }

        completer.complete(false);
      },
      onError: (Object error) {
        if (!completer.isCompleted) {
          completer.completeError(error);
        }
        subscription?.cancel();
      },
      onDone: () {
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      },
    );

    await InAppPurchase.instance.restorePurchases();

    try {
      return await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          subscription?.cancel();
          throw Exception('Restore purchase timed out');
        },
      );
    } finally {
      await subscription.cancel();
    }
  }

  restorePurchase() async {
    try {
      if (!await ultimateRestorePurchase()) {
        return feedback(
          'You have not purchased it',
          type: FeedbackType.error,
        );
      }
      await grantUnlimited();
      feedback(
        'purchase successfully restored',
        type: FeedbackType.success,
      );
    } catch (e) {
      feedback(
        'purchase restore has failed! try again',
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
        await InAppPurchase.instance.queryProductDetails({productId});

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
