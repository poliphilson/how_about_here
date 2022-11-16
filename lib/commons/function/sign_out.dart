import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:here/commons/function/get_refresh_token.dart';
import 'package:here/commons/function/request_api.dart';
import 'package:here/constant.dart';
import 'package:here/models.dart';

Future<void> signOut(FlutterSecureStorage storage) async {
  RequsetApiForm requsetApiForm = RequsetApiForm();
  RefreshToken rToken = await getRefreshToken(storage);

  requsetApiForm.method = 'POST';
  requsetApiForm.headers = {"Cookie": rToken.refreshToken};
  requsetApiForm.url = 'http://localhost:8080/signout';

  await storage.delete(key: accessToken);
  await storage.delete(key: refreshToken);
  await requestApi(requsetApiForm);
}
