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

  User.fromJson(Map json) {
    email = json['email'];
    profileImage = json['profile_image'];
  }
}