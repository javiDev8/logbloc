import 'package:logbloc/apis/back.dart';

class AssetUrlHolder {
  Map<String, dynamic> urls = {};
  init() async {
    urls = await backApi.getAllAssets();
  }
}

final assetHolder = AssetUrlHolder();
