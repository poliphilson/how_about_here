import 'package:here/models.dart';
import 'package:http/http.dart' as http;
import 'package:here/json_key.dart';
import 'dart:convert';

Future<HereJsonForm> requestApi(RequsetApiForm requestForm) async {
  late final http.Response responseOfRequest;

  switch (requestForm.method.toLowerCase()) {
    case 'get':
      responseOfRequest = await http.get(
        Uri.parse(requestForm.url),
        headers: requestForm.headers,
      );
      break;

    case 'post':
      responseOfRequest = await http.post(Uri.parse(requestForm.url),
          headers: requestForm.headers, body: json.encode(requestForm.body));

      break;

    case 'patch':
      break;

    case 'delete':
      responseOfRequest = await http.delete(Uri.parse(requestForm.url),
          headers: requestForm.headers);
      break;
  }

  final HereJsonForm responseForm =
      _bindJson(responseOfRequest.body, responseOfRequest.headers);

  return responseForm;
}

Future<HereJsonForm> sendHere(SendHereForm sendHereForm, String aToken) async {
  late final http.StreamedResponse responseOfRequest;

  Uri uri = Uri.parse('http://localhost:8080/here');
  http.MultipartRequest request = http.MultipartRequest('POST', uri);
  Map<String, String> headers = {"Cookie": aToken};

  request.headers.addAll(headers);
  request.fields['contents'] = sendHereForm.contents;
  request.fields['is_privated'] = sendHereForm.isPrivated.toString();
  request.fields['x'] = sendHereForm.x.toString();
  request.fields['y'] = sendHereForm.y.toString();
  for (int i = 0; i < sendHereForm.images.length; i++) {
    request.files.add(await http.MultipartFile.fromPath(
        'image[]', sendHereForm.images[i]!.path));
  }

  responseOfRequest = await request.send();

  final String responseToString =
      await responseOfRequest.stream.bytesToString();
  final HereJsonForm responseForm =
      _bindJson(responseToString, responseOfRequest.headers);

  return responseForm;
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
