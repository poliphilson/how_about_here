import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:here/models.dart';

Future<SignIn> getMyProfileImage(FlutterSecureStorage storage) async {
  String? profileImage = await storage.read(key: 'profile_image');
  profileImage ??= "user_default.png";

  SignIn user = SignIn.fromJson({"profile_image": profileImage});

  return user;
}