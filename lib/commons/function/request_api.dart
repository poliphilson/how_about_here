import 'package:geocoding/geocoding.dart';
import 'package:here/constant.dart';
import 'package:here/models.dart';
import 'package:http/http.dart' as http;
import 'package:here/json_key.dart';
import 'dart:convert';

Future<HereJsonForm> requestApi(RequsetApiForm requestApiForm) async {
  late final http.Response responseOfRequest;

  switch (requestApiForm.method.toLowerCase()) {
    case 'get':
      responseOfRequest = await http.get(Uri.parse(requestApiForm.url),
          headers: requestApiForm.headers);
      break;

    case 'post':
      responseOfRequest = await http.post(Uri.parse(requestApiForm.url),
          headers: requestApiForm.headers, body: json.encode(requestApiForm.body));
      break;

    case 'patch':
      responseOfRequest = await http.patch(Uri.parse(requestApiForm.url),
          headers: requestApiForm.headers, body: json.encode(requestApiForm.body));
      break;

    case 'delete':
      responseOfRequest = await http.delete(Uri.parse(requestApiForm.url),
          headers: requestApiForm.headers);
      break;
  }

  final HereJsonForm responseForm = _bindJson(responseOfRequest.body, responseOfRequest.headers);

  return responseForm;
}

Future<HereJsonForm> sendHere(SendHereForm sendHereForm, String aToken) async {
  late final http.StreamedResponse responseOfRequest;

  Uri uri = Uri.parse('$server/here');
  http.MultipartRequest request = http.MultipartRequest('POST', uri);
  Map<String, String> headers = {"Cookie": aToken};

  request.headers.addAll(headers);
  request.fields['contents'] = sendHereForm.contents;
  request.fields['is_privated'] = sendHereForm.isPrivated.toString();
  request.fields['x'] = sendHereForm.x.toString();
  request.fields['y'] = sendHereForm.y.toString();
  request.fields['address'] = json.encode(_placemarkToMap(sendHereForm.address));
  for (int i = 0; i < sendHereForm.images.length; i++) {
    request.files.add(await http.MultipartFile.fromPath(
        'image[]', sendHereForm.images[i]!.path));
  }

  responseOfRequest = await request.send();

  final String responseToString = await responseOfRequest.stream.bytesToString();
  final HereJsonForm responseForm = _bindJson(responseToString, responseOfRequest.headers);

  return responseForm;
}

Future<HereJsonForm> editMyInformation(EditMyInfomationForm editMyInfomationForm, String aToken) async {
  late final http.StreamedResponse responseOfRequest;

  Uri uri = Uri.parse('$server/user');
  http.MultipartRequest request = http.MultipartRequest('PATCH', uri);
  Map<String, String> headers = {"Cookie": aToken};
  request.headers.addAll(headers);

  if (editMyInfomationForm.bio != null) {
    if (editMyInfomationForm.bio == '') {
      editMyInfomationForm.bio = ' ';
    }
    request.fields['bio'] = editMyInfomationForm.bio!;
  }

  if (editMyInfomationForm.image != null) {
    request.files.add(await http.MultipartFile.fromPath('image', editMyInfomationForm.image!.path));
  } 

  if (editMyInfomationForm.name != null) {
    request.fields['name'] = editMyInfomationForm.name!;
  } 

  responseOfRequest = await request.send();

  final String responseToString = await responseOfRequest.stream.bytesToString();
  final HereJsonForm responseForm = _bindJson(responseToString, responseOfRequest.headers);

  return responseForm;
}

Future<HereJsonForm> editHere(EditHereForm editHere, int hid, String aToken) async {
  late final http.StreamedResponse responseOfRequest;

  Uri uri = Uri.parse('$server/here/$hid');
  http.MultipartRequest request = http.MultipartRequest('PATCH', uri);
  Map<String, String> headers = {"Cookie": aToken};
  request.headers.addAll(headers);

  request.fields['contents'] = editHere.contents;
  request.fields['is_privated'] = editHere.isPrivated.toString();
  for (int i = 0; i < editHere.images.length; i++) {
    request.files.add(http.MultipartFile.fromString('images[]', editHere.images[i]));
  }
  
  for (int i = 0; i < editHere.newImages.length; i++) {
    request.files.add(await http.MultipartFile.fromPath(
        'new_image[]', editHere.newImages[i]!.path));
  }

  responseOfRequest = await request.send();

  final String responseToString = await responseOfRequest.stream.bytesToString();
  final HereJsonForm responseForm = _bindJson(responseToString, responseOfRequest.headers);

  return responseForm;
}

Map<String, String> _placemarkToMap(Placemark placemark) {
  Map<String, String> address = {
    "name": placemark.name ?? '',
    "street": placemark.street ?? '',  
    "country": placemark.country ?? '',
    "admin_area": placemark.administrativeArea ?? '',
    "sub_area": placemark.subAdministrativeArea ?? '',
    "locality": placemark.locality ?? '',
    "sub_locality": placemark.subLocality ?? '',
    "thoroughfare": placemark.thoroughfare ?? '',
    "sub_thoroughfare": placemark.subThoroughfare ?? '',
  };
  return address;
}

HereJsonForm _bindJson(String jsonFormBody, Map<String, String> headers) {
  dynamic jsonForm = jsonDecode(jsonFormBody);
  HereJsonForm responseForm = HereJsonForm();
  responseForm.httpCode = jsonForm[httpCode];
  responseForm.hereCode = jsonForm[hereCode];
  responseForm.data = jsonForm[hereData];
  responseForm.message = jsonForm[hereMessage];
  responseForm.headers = headers;

  return responseForm;
}
