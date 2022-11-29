import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:here/commons/animation/top_to_bottom.dart';
import 'package:here/commons/function/get_access_token.dart';
import 'package:here/commons/function/request_api.dart';
import 'package:here/commons/widget/custom_progress_indicator.dart';
import 'package:here/commons/widget/new_route_base.dart';
import 'package:here/constant.dart';
import 'package:here/models.dart';
import 'package:here/route/login.dart';
import 'package:image_picker/image_picker.dart';

class EditMyInfomation extends StatefulWidget {
  const EditMyInfomation({super.key});

  @override
  State<EditMyInfomation> createState() => _EditMyInfomationState();
}

class _EditMyInfomationState extends State<EditMyInfomation> {
  final _storage = const FlutterSecureStorage();
  final ImagePicker _picker = ImagePicker();

  XFile? image;
  bool edit = false;
  bool imageEdit = false;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return FutureBuilder<HereJsonForm>(
      future: getMyInformation(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CustomProgressIndicator(),
          );
        } else {
          if (snapshot.data!.hereCode != statusOK) {
            print("fail");
            return Container();
          } else {
            User user = User.fromJson(snapshot.data!.data);
            return NewRouteBase(
              child: Column(
                children: [
                  SizedBox(
                    height: height / 20,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.only(left: 10),
                          child: IconButton(
                            icon: const Icon(
                              Icons.cancel_rounded,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        Expanded(
                          child: Container(),
                        ),
                        Container(
                          padding: const EdgeInsets.only(right: 10),
                          child: TextButton(
                            onPressed: edit
                                ? () async {
                                    AccessToken aToken =
                                        await getAccessToken(_storage);
                                    EditMyInfomationForm editMyInfomationForm =
                                        EditMyInfomationForm();
                                    editMyInfomationForm.image = image;
                                    HereJsonForm hereJsonForm =
                                        await editMyInformation(
                                            editMyInfomationForm,
                                            aToken.accessToken);
                                    EditUser editUser =
                                        EditUser.fromJson(hereJsonForm.data);
                                    await _storage.write(
                                        key: 'profile_image',
                                        value: editUser.profileImage);
                                    if (!mounted) return;
                                    Navigator.pop(context);
                                  }
                                : null,
                            child: Text(
                              "Save",
                              style: TextStyle(
                                  color: edit ? Colors.blue : Colors.grey),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 8),
                    height: height / 3,
                    child: FutureBuilder<AccessToken>(
                      future: getAccessToken(_storage),
                      builder: (context, snapshotA) {
                        if (snapshotA.hasData == false) {
                          return const CustomProgressIndicator();
                        } else {
                          if (snapshotA.data!.accessToken == '') {
                            SchedulerBinding.instance
                                .addPostFrameCallback((timeStamp) {
                              Navigator.push(context,
                                  topToBottom(const Login(main: false)));
                            });
                            return Container();
                          } else {
                            String aToken = snapshotA.data!.accessToken;
                            return FittedBox(
                              child: GestureDetector(
                                child: imageEdit
                                    ? CircleAvatar(
                                        backgroundColor: Colors.grey.shade200,
                                        backgroundImage:
                                            AssetImage(image!.path),
                                      )
                                    : CircleAvatar(
                                        backgroundColor: Colors.grey.shade200,
                                        backgroundImage:
                                            CachedNetworkImageProvider(
                                          'http://localhost:8080/image/${user.profileImage}',
                                          headers: {"Cookie": aToken},
                                        ),
                                      ),
                                onTap: () async {
                                  image = await _picker.pickImage(
                                      source: ImageSource.gallery);
                                  if (image != null) {
                                    setState(() {
                                      edit = true;
                                      imageEdit = true;
                                    });
                                  }
                                },
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    height: height / 20,
                  ),
                  SizedBox(
                    height: height / 20,
                    child: Container(
                      padding: const EdgeInsets.only(left: 72, right: 72),
                      child: FittedBox(
                        child: Text(user.name),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: height / 20,
                    child: Container(
                      padding: const EdgeInsets.only(left: 72, right: 72),
                      child: FittedBox(
                        child: Text(user.email),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: height / 20,
                    child: Container(
                      padding: const EdgeInsets.only(left: 72, right: 72),
                      child: FittedBox(
                        child: Text(user.createdAt),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(left: 72, right: 72),
                      child: Center(child: Text(user.bio)),
                    ),
                  ),
                ],
              ),
            );
          }
        }
      },
    );
  }

  Future<HereJsonForm> getMyInformation() async {
    AccessToken aToken = await getAccessToken(_storage);
    RequsetApiForm requestApiForm = RequsetApiForm();
    requestApiForm.method = 'GET';
    requestApiForm.headers = {'Cookie': aToken.accessToken};
    requestApiForm.url = 'http://localhost:8080/user';
    HereJsonForm hereJsonForm = await requestApi(requestApiForm);
    return hereJsonForm;
  }
}
