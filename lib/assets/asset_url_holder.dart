import 'package:logbloc/apis/back.dart';

class AssetUrlHolder {
  Map<String, dynamic> data = {};
  init() async {
    data = await backApi.getAllAssets();
  }
}

final assetHolder = AssetUrlHolder();
