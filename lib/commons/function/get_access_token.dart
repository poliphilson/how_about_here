import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:here/constant.dart';
import 'package:here/models.dart';

Future<AccessToken> getAccessToken(FlutterSecureStorage storage) async {
  AccessToken aToken = AccessToken();
  String? temp = await storage.read(key: accessToken);
  if (temp == null) {
    aToken.accessToken = "";
  }
  else {
    aToken.accessToken = temp;
  }
  return aToken;
}