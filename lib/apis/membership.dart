import 'dart:async';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:logize/apis/back.dart';
import 'package:logize/main.dart';
import 'package:logize/utils/feedback.dart';

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
    }
  }

  Future<void> upgrade() async {
    try {
      if (currentPlan == 'base') {
        throw Exception('already on base plan!');
      }

      await purchase();
      currentPlan = 'base';
      sharedPrefs.setString('plan', 'base');
      await backApi.upgradePlan(deviceId);
    } catch (e) {
      return feedback('error on upgrade!', type: FeedbackType.error);
    }
  }

  Future<void> purchase() async {
    const String productId = '01';
    final completer = Completer<void>();
    late StreamSubscription<List<PurchaseDetails>> subscription;

    subscription = InAppPurchase.instance.purchaseStream.listen((
      purchaseDetailsList,
    ) {
      for (final purchaseDetails in purchaseDetailsList) {
        if (purchaseDetails.status == PurchaseStatus.purchased) {
          InAppPurchase.instance.completePurchase(purchaseDetails);
          completer.complete();
        } else if (purchaseDetails.status == PurchaseStatus.error) {
          completer.completeError(purchaseDetails.error!);
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
      completer.completeError('Product details not found');
    }

    await completer.future.timeout(Duration(seconds: 30));
    subscription.cancel();
  }
}

final membershipApi = MembershipApi();
