import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:here/constant.dart';
import 'package:here/models.dart';

Future<RefreshToken> getRefreshToken(FlutterSecureStorage storage) async {
  RefreshToken rToken = RefreshToken();
  String? temp = await storage.read(key: refreshToken);
  if (temp == null) {
    rToken.refreshToken = "";
  } else {
    rToken.refreshToken = temp;
  }
  return rToken;
}
