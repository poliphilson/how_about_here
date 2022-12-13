import 'package:flutter/material.dart';
import 'package:here/commons/function/get_access_token.dart';
import 'package:here/commons/function/request_api.dart';
import 'package:here/constant.dart';
import 'package:here/models.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _emailTextEditController = TextEditingController();
  final _nameTextEditController = TextEditingController();
  final _passwordTextEditController = TextEditingController();
  final _passwordConfirmTextEditController = TextEditingController();

  bool passworkOk = false; 

  @override
  void initState() {
    _passwordConfirmTextEditController.addListener(() { 
      if (_passwordTextEditController.text == _passwordConfirmTextEditController.text) {
        setState(() {
          passworkOk = true;
        });
      } else {
        setState(() {
          passworkOk = false;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _emailTextEditController.dispose();
    _nameTextEditController.dispose();
    _passwordTextEditController.dispose();
    _passwordConfirmTextEditController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        foregroundColor: Colors.black,
        title: const Text('Create an account'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: height / 7.4,
            ),
            Container(
              margin: EdgeInsets.only(left: width / 10, right: width / 10),
              height: height / 2,
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
                                'Sign Up',
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
                      padding:
                          EdgeInsets.only(left: width / 10, right: width / 10),
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
                      padding:
                          EdgeInsets.only(left: width / 10, right: width / 10),
                      child: TextField(
                        controller: _nameTextEditController,
                        cursorColor: Colors.black,
                        decoration: const InputDecoration(
                          hintText: 'Name',
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
                      padding:
                          EdgeInsets.only(left: width / 10, right: width / 10),
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
                    child: Container(
                      padding:
                          EdgeInsets.only(left: width / 10, right: width / 10),
                      child: TextField(
                        controller: _passwordConfirmTextEditController,
                        obscureText: true,
                        cursorColor: Colors.black,
                        decoration: const InputDecoration(
                          hintText: 'Password Confirm',
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
                              child: 
                              passworkOk
                              ? TextButton(
                                child: const Text('OK'),
                                onPressed: () async {
                                  RequsetApiForm requsetApiForm = RequsetApiForm();
                                  requsetApiForm.method = 'POST';
                                  requsetApiForm.body = {
                                    'email': _emailTextEditController.text,
                                    'name': _nameTextEditController.text,
                                    'password': _passwordTextEditController.text,
                                  };
                                  requsetApiForm.url = '$server/signup';

                                  HereJsonForm hereJsonForm = await requestApi(requsetApiForm);
                                  if (hereJsonForm.hereCode != statusOK) {
                                    print('fail');
                                  } else {
                                    if (!mounted) return;
                                    Navigator.pop(context);
                                  }
                                },
                              )
                              : const TextButton(
                                onPressed: null,
                                child: Text('OK', style: TextStyle(color: Colors.red),),
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
          ],
        ),
      ),
    );
  }
}
