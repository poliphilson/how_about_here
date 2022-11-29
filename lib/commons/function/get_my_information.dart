import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:here/models.dart';

Future<User> getMyInformation(FlutterSecureStorage storage) async {
  String? email = await storage.read(key: 'email');
  email ??= "???";

  String? profileImage = await storage.read(key: 'profile_image');
  profileImage ??= "user_default.png";

  String? bio = await storage.read(key: 'bio');
  bio ??= "";

  User user = User.fromJson({"email": email, "profile_image": profileImage, "bio": bio});

  return user;
}