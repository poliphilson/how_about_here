import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:here/models.dart';

Future<ProfileImage> getMyProfileImage(FlutterSecureStorage storage) async {
  String? profileImage = await storage.read(key: 'profile_image');
  profileImage ??= "user_default.png";

  ProfileImage user = ProfileImage.fromJson({"profile_image": profileImage});

  return user;
}