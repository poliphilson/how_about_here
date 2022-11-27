import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:here/models.dart';

Future<User> getMyInformation(FlutterSecureStorage storage) async {
  String? email = await storage.read(key: 'email');
  if (email == null) {
    email = "???";
  }
  else {
    email = email;
  }

  String? profileImage = await storage.read(key: 'profile_image');
  if (profileImage == null) {
    profileImage = "user_default.png";
  }
  else {
    profileImage = profileImage; 
  }

  User user = User.fromJson({"email": email, "profile_image": profileImage});

  return user;
}