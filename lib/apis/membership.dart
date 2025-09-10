import 'dart:async';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:logbloc/apis/back.dart';
import 'package:logbloc/main.dart';
import 'package:uuid/uuid.dart';

class MembershipApi {
  String? productId;
  String? productPrice;

  String currentPlan = '';
  String deviceId = '';
  bool welcomed = false;

  Future<String> getDeviceId() async {
    const FlutterSecureStorage storage = FlutterSecureStorage();
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

    String? storedId = await storage.read(key: 'device_id');
    if (storedId != null && storedId.isNotEmpty) {
      return storedId;
    }

    String? deviceId;
    if (Platform.isAndroid) {
      final AndroidDeviceInfo androidInfo =
          await deviceInfoPlugin.androidInfo;
      deviceId = androidInfo.id;
    } else if (Platform.isIOS) {
      final IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
      final String? iosId = iosInfo.identifierForVendor;
      if (iosId != null &&
          iosId.isNotEmpty &&
          iosId != '00000000-0000-0000-0000-000000000000') {
        deviceId = iosId;
      }
    }

    if (deviceId == null ||
        deviceId.isEmpty ||
        deviceId == '00000000-0000-0000-0000-000000000000') {
      deviceId = const Uuid().v4();
    }

    await storage.write(key: 'device_id', value: deviceId);

    return deviceId;
  }

  Future<void> init() async {
    welcomed = (await sharedPrefs.getBool('welcomed')) ?? false;

    final diSpSrc = await sharedPrefs.getString('deviceId');
    if (diSpSrc == null) {
      deviceId = await getDeviceId();
      sharedPrefs.setString('deviceId', deviceId);
    } else {
      deviceId = diSpSrc;
    }

    final spSrc = await sharedPrefs.getString('plan');
    if (spSrc != null) {
      currentPlan = spSrc;
    } else {
      if (await InternetConnection().hasInternetAccess) {
        currentPlan = await backApi.checkPlan(deviceId);
      } else {
        currentPlan = 'free';
      }

      await sharedPrefs.setString('plan', currentPlan);
    }

    if (currentPlan == 'free') {
      await getProduct();
    }
    // if app is owned there is no need of getting product details
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

  Future getProduct() async {
    try {
      productId = await backApi.getAsset('product-id');
      final details = await InAppPurchase.instance.queryProductDetails({
        productId!,
      });
      productPrice = details.productDetails.first.price;
    } catch (e) {
      Exception('get product error: $e');
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
        await InAppPurchase.instance.queryProductDetails({productId!});

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
