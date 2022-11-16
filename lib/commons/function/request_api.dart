
import 'package:here/models.dart';
import 'package:http/http.dart' as http;
import 'package:here/json_key.dart';
import 'dart:convert';

Future<HereJsonForm> requestApi(RequsetApiForm requestForm) async {
    late http.Response responseOfRequest;

    switch (requestForm.method.toLowerCase()) {
      case 'get':
      responseOfRequest = await http.get(
        Uri.parse(requestForm.url),
        headers: requestForm.headers,
      );
      break;

      case 'post':
      responseOfRequest = await http.post(
        Uri.parse(requestForm.url),
        headers: requestForm.headers, 
        body: json.encode(requestForm.body)
      );
      break;

      case 'patch':
      break;
      case 'delete':
      break;
    }

    dynamic jsonForm = jsonDecode(responseOfRequest.body);
    HereJsonForm responseForm = HereJsonForm();
    responseForm.httpCode = jsonForm[httpCode];
    responseForm.hereCode = jsonForm[hereCode];
    responseForm.data = jsonForm[hereData];
    responseForm.message = jsonForm[hereMessage];
    responseForm.headers = responseOfRequest.headers;
    
    return responseForm;
  }