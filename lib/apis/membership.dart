import 'dart:async';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:logbloc/apis/back.dart';
import 'package:logbloc/main.dart';

class MembershipApi {
  String currentPlan = '';
  String deviceId = '';

  Future<String> getDeviceId() async {
    try {
      final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidInfo =
            await deviceInfoPlugin.androidInfo;
        return androidInfo.id;
      } else if (Platform.isIOS) {
        final IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
        final iosId = iosInfo.identifierForVendor;
        if (iosId == null) {
          throw Exception('id failed');
        }
        return iosId;
      } else {
        throw Exception('id failed: unsupported platform');
      }
    } catch (e) {
      throw Exception('error on get device id: $e');
    }
  }

  Future<void> init() async {
    deviceId = await getDeviceId();
    final spSrc = await sharedPrefs.getString('plan');
    if (spSrc != null) {
      currentPlan = spSrc;
      return;
    } else {
      currentPlan = await backApi.checkPlan(deviceId);
      await sharedPrefs.setString('plan', currentPlan);
    }
  }

  Future<void> upgrade() async {
    try {
      if (currentPlan == 'base') {
        throw Exception('already on base plan!');
      }

      await purchase();
      currentPlan = 'base';
      await sharedPrefs.setString('plan', 'base');
      await backApi.upgradePlan(deviceId);
    } catch (e) {
      throw Exception('upgrade error: $e');
    }
  }

  Future<void> purchase() async {
    final String productId = await backApi.getAsset('product-id');
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
