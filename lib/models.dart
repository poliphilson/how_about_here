import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

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
  String? name;
}

class AccessToken {
  late String accessToken;
}

class RefreshToken {
  late String refreshToken;
}

class Here {
  late int hid;
  late String createdAt = "";
  late String contents = "";
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

class SpecificHere {
  late int hereCode;
  late int httpCode;
  late Here here;
  late Address address;
  late dynamic images;
  late dynamic videos;

  SpecificHere.fromJson(HereJsonForm hereJsonForm) {
    hereCode = hereJsonForm.hereCode;
    httpCode = hereJsonForm.httpCode;
    here = Here.fromJson(hereJsonForm.data['here']);
    address = Address.fromJson(hereJsonForm.data['address']);
    images = hereJsonForm.data['images'];
    videos = hereJsonForm.data['videos'];
  }
}

class Address {
  late String name = "";
  late String street = "";
  late String country = "";
  late String adminArea = "";
  late String subArea = "";
  late String locality = "Hmm...";
  late String subLocality = "";
  late String thoroughfare = "";
  late String subThoroughfare = "";

  Address.fromJson(Map json) {
    name = json['name'];
    street = json['street'];
    country = json['country'];
    adminArea = json['admin_area'];
    subArea = json['sub_area'];
    locality = json['locality'];
    subLocality = json['sub_locality'];
    thoroughfare = json['thoroughfare'];
    subThoroughfare = json['sub_thoroughfare'];
  }
}

class User {
  late String email;
  late String profileImage;
  late String bio;
  late String name;
  late String createdAt;

  User.fromJson(Map json) {
    final String parseDate = json['created_at'].split('.').first;
    final DateTime date = DateTime.parse(parseDate);
    final DateFormat dateFormat = DateFormat('MMMM dd yyyy');
    final String prettyDate = dateFormat.format(date);
    
    email = json['email'];
    profileImage = json['profile_image'];
    bio = json['bio'];
    createdAt = prettyDate;
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
  late String name;

  EditUser.fromJson(Map json) {
    profileImage = json['profile_image'];
    bio = json['bio'];
    name = json['name'];
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
