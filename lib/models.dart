import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';

class HereJsonForm {
  late int hereCode;
  late int httpCode;
  late dynamic data;
  late String? message;
  late Map<String, String>? headers;
}

class RequsetApiForm {
  late String method;
  Map<String, String>? headers;
  late String url;
  String? query;
  Map<String, dynamic>? body;
}

class SendHereForm {
  late String contents;
  late bool isPrivated;
  late Placemark address;
  late double x;
  late double y;
  late List<XFile?> images = [];
}

class EditMyInfomationForm {
  XFile? image;
  String? bio;
}

class AccessToken {
  late String accessToken;
}

class RefreshToken {
  late String refreshToken;
}

class Here {
  late int hid;               
	late String createdAt;   
	late String contents;             
	late Map<String, dynamic> location;   
	late bool image;                
	late bool video;               
	late bool isPrivated;         

  Here.fromJson(Map json) {
    hid = json['hid'];
    createdAt = json['created_at']; 
    contents = json['contents'];
    location = json['location'];
    image = json['image'];
    video = json['video'];
    isPrivated = json['is_privated'];
  }
}

class User {
  late String email;
  late String profileImage;
  late String bio;
  late String name;
  late String createdAt;

  User.fromJson(Map json) {
    email = json['email'];
    profileImage = json['profile_image'];
    bio = json['bio'];
    createdAt = json['created_at'];
    name = json['name'];
  }
}

class ProfileImage {
  late String profileImage;

  ProfileImage.fromJson(Map json) {
    profileImage = json['profile_image'];
  }
}

class EditUser {
  late String profileImage;
  late String bio;

  EditUser.fromJson(Map json) {
    profileImage = json['profile_image'];
    bio = json['bio'];
  }
}

class Point {
  late int pid;
  late String createdAt;
  late String description;
  late Map<String, dynamic> location;

  Point.fromJson(Map json) {
    pid = json['pid'];
    createdAt = json['created_at']; 
    description = json['description'];
    location = json['location'];
  }
}