import 'package:flutter/material.dart';
import 'package:here/commons/animation/scale.dart';
import 'package:here/commons/function/get_access_token.dart';
import 'package:here/commons/function/request_api.dart';
import 'package:here/commons/provider/progress_indicator_status.dart';
import 'package:here/commons/widget/custom_progress_indicator.dart';
import 'package:here/constant.dart';
import 'package:here/models.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:here/route/my_home.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  const Login({required this.main, super.key});

  final bool main;

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _storage = const FlutterSecureStorage();
  final _emailTextEditController = TextEditingController();
  final _passwordTextEditController = TextEditingController();

  @override
  void dispose() {
    _emailTextEditController.dispose();
    _passwordTextEditController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          SizedBox.expand(
            child: Container(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: height / 3,
                ),
                Container(
                  margin: EdgeInsets.only(left: width / 10, right: width / 10),
                  height: height / 3,
                  /*decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: const BorderRadius.all(Radius.circular(containerCorner)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: const Offset(3, 3)
                      )
                    ]
                  ),*/
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              fit: FlexFit.tight,
                              child: Container(
                                padding: EdgeInsets.only(
                                    left: width / 10, right: width / 10, top: 15),
                                child: const FittedBox(
                                  alignment: Alignment.centerLeft,
                                  fit: BoxFit.fitHeight,
                                  child: Text(
                                    'Login',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(
                              left: width / 10, right: width / 10),
                          child: TextField(
                            controller: _emailTextEditController,
                            cursorColor: Colors.black,
                            decoration: const InputDecoration(
                              hintText: 'Email',
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black)),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black)),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(
                              left: width / 10, right: width / 10),
                          child: TextField(
                            controller: _passwordTextEditController,
                            obscureText: true,
                            cursorColor: Colors.black,
                            decoration: const InputDecoration(
                              hintText: 'Password',
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black)),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black)),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              fit: FlexFit.tight,
                              child: Container(
                                padding: EdgeInsets.only(
                                    left: width / 10,
                                    right: width / 10,
                                    bottom: 15),
                                child: FittedBox(
                                  alignment: Alignment.centerRight,
                                  fit: BoxFit.fitHeight,
                                  child: Consumer<ProgressIndicatorStatus>(
                                    builder: (context, progressIndicator,
                                            child) =>
                                        progressIndicator.status
                                            ? const CustomProgressIndicator()
                                            : TextButton(
                                                child: const Text('Sign in'),
                                                onPressed: () async {
                                                  progressIndicator.on();
    
                                                  RequsetApiForm signInApiForm = RequsetApiForm();
    
                                                  Map<String, dynamic> body = {
                                                    "email": _emailTextEditController.text,
                                                    "password": _passwordTextEditController.text,
                                                  };
    
                                                  signInApiForm.method = 'POST';
                                                  signInApiForm.headers = {
                                                    "Content-Type": "application/json"
                                                  };
                                                  signInApiForm.url = 'http://localhost:8080/signin';
                                                  signInApiForm.body = body;
    
                                                  HereJsonForm signInJsonForm = await requestApi(signInApiForm);
                                                  if (signInJsonForm.hereCode == statusOK) {
                                                    String cookies = signInJsonForm.headers![setCookie]!;
                                                    List<String> tokens = cookies.split(',');
    
                                                    for (int i = 0; i < tokens.length; i++) {
                                                      if (tokens[i].contains(accessToken) == true) {
                                                        await _storage.write(key: accessToken, value: tokens[i],);
                                                      } else {
                                                        await _storage.write(key: refreshToken,value: tokens[i],);
                                                      }
                                                    }

                                                    SignIn user = SignIn.fromJson(signInJsonForm.data);
                                                    await _storage.write(key: 'profile_image', value: user.profileImage);

                                                    if (widget.main) {
                                                      RequsetApiForm getHeresApiForm = RequsetApiForm();
                                                      final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
                                                      final String today = dateFormat.format(DateTime.now());
                                                      AccessToken aToken = await getAccessToken(_storage);
                                                      getHeresApiForm.method = 'GET';
                                                      getHeresApiForm.url = 'http://localhost:8080/here?date=$today';
                                                      getHeresApiForm.headers = {
                                                        "Cookie": aToken.accessToken
                                                      };
    
                                                      HereJsonForm getHeresJsonForm = await requestApi(getHeresApiForm);
                                                      getHeresJsonForm.data ??= [];
                                                      List<Map<String, dynamic>> heres;
                                                      heres = (getHeresJsonForm.data as List)
                                                              .map((item) => item as Map<String, dynamic>)
                                                              .toList();
                                                      progressIndicator.off();
    
                                                      if (!mounted) return;
                                                      await _goToMyHome(context, heres,);
                                                    } else {
                                                      progressIndicator.off();
    
                                                      if (!mounted) return;
                                                      await _goToMyHome(context,);
                                                    }
                                                  } else {
                                                    print("Failed to sign in");
                                                    progressIndicator.off();
                                                  }
                                                },
                                              ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: height / 3,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(top: 15),
                        child: TextButton(
                          onPressed: () {},
                          style: ButtonStyle(
                            overlayColor:
                                MaterialStateProperty.all(Colors.transparent),
                          ),
                          child: const Text('Create an account'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _goToMyHome(BuildContext context, [List<Map<String, dynamic>>? heres]) async {
    Navigator.pop(context);
    if (widget.main) {
      Navigator.pushReplacement(context, scale(MyHome(heres: heres!), true));
    }
  }
}
