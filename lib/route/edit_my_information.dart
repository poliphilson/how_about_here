import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:here/commons/animation/top_to_bottom.dart';
import 'package:here/commons/function/get_access_token.dart';
import 'package:here/commons/function/get_my_profile_image.dart';
import 'package:here/commons/function/request_api.dart';
import 'package:here/commons/widget/custom_progress_indicator.dart';
import 'package:here/commons/widget/new_route_base.dart';
import 'package:here/main.dart';
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
  final _nameTextEditingController = TextEditingController();
  final _bioTextEditingController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  XFile? image;

  String name = "";
  String email = "";
  String createdAt = "";
  String bio = "";

  bool imageEdit = false;
  bool nameEdit = false;
  bool bioEdit = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      initProfile();
    });
    super.initState();
  }

  void initProfile() async {
    HereJsonForm hereJsonForm = await _getMyInformation();
    User user = User.fromJson(hereJsonForm.data);
    setState(() {
      name = user.name;
      email = user.email;
      createdAt = user.createdAt;
      bio = user.bio;
    });
  }

  @override
  void dispose() {
    _nameTextEditingController.dispose();
    _bioTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return FutureBuilder<ProfileImage>(
      future: getMyProfileImage(_storage),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CustomProgressIndicator(),
          );
        } else {
          return FutureBuilder<AccessToken>(
            future: getAccessToken(_storage),
            builder: (context, snapshotA) {
              if (!snapshotA.hasData) {
                return const Center(
                  child: CustomProgressIndicator(),
                );
              } else {
                if (snapshotA.data!.accessToken == "") {
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    navigatorKey.currentState?.push(topToBottom(const Login(main: false)));
                  });
                  return Container();
                } else {
                  String aToken = snapshotA.data!.accessToken;
                  return NewRouteBase(
                    image: imageEdit
                        ? DecorationImage(
                            colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(0.3),
                                BlendMode.dstATop),
                            image: AssetImage(image!.path),
                            fit: BoxFit.cover,
                          )
                        : DecorationImage(
                            colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(0.3),
                                BlendMode.dstATop),
                            image: CachedNetworkImageProvider(
                              'http://localhost:8080/image/${snapshot.data!.profileImage}',
                              headers: {"Cookie": aToken},
                            ),
                            fit: BoxFit.cover,
                          ),
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
                                    navigatorKey.currentState?.pop();
                                  },
                                ),
                              ),
                              Expanded(
                                child: Container(),
                              ),
                              Container(
                                padding: const EdgeInsets.only(right: 10),
                                child: TextButton(
                                  onPressed: (imageEdit || nameEdit || bioEdit)
                                      ? () async {
                                          AccessToken aToken =
                                              await getAccessToken(_storage);
                                          EditMyInfomationForm
                                              editMyInfomationForm =
                                              EditMyInfomationForm();

                                          if (image != null) {
                                            editMyInfomationForm.image = image;
                                          }

                                          if (_nameTextEditingController.text !=
                                              name) {
                                            editMyInfomationForm.name =
                                                _nameTextEditingController.text;
                                          }

                                          if (_bioTextEditingController.text !=
                                              bio) {
                                            editMyInfomationForm.bio =
                                                _bioTextEditingController.text;
                                          }

                                          HereJsonForm hereJsonForm =
                                              await editMyInformation(
                                                  editMyInfomationForm,
                                                  aToken.accessToken);
                                          EditUser editUser = EditUser.fromJson(
                                              hereJsonForm.data);

                                          await _storage.write(
                                              key: 'profile_image',
                                              value: editUser.profileImage);

                                          name = editUser.name;
                                          bio = editUser.bio;

                                          setState(() {
                                            nameEdit = false;
                                            bioEdit = false;
                                          });
                                        }
                                      : null,
                                  child: Text(
                                    "Save",
                                    style: TextStyle(
                                        color:
                                            (imageEdit || nameEdit || bioEdit) 
                                            ? Colors.blue 
                                            : Colors.grey),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(top: 8),
                          height: height / 3,
                          child: FittedBox(
                            child: GestureDetector(
                              child: imageEdit
                                  ? CircleAvatar(
                                      backgroundColor: Colors.grey.shade200,
                                      backgroundImage: AssetImage(image!.path),
                                    )
                                  : CircleAvatar(
                                      backgroundColor: Colors.grey.shade200,
                                      backgroundImage:
                                          CachedNetworkImageProvider(
                                        'http://localhost:8080/image/${snapshot.data!.profileImage}',
                                        headers: {"Cookie": aToken},
                                      ),
                                    ),
                              onTap: () async {
                                image = await _picker.pickImage(
                                    source: ImageSource.gallery);
                                if (image != null) {
                                  setState(() {
                                    imageEdit = true;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          height: height / 20,
                        ),
                        nameEdit
                            ? TextField(
                                controller: _nameTextEditingController,
                                autofocus: true,
                                textAlign: TextAlign.center,
                                cursorColor: Colors.black,
                                maxLines: 1,
                                style: const TextStyle(
                                    fontSize: 35, fontWeight: FontWeight.w200),
                                decoration: const InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.all(0),
                                    border: InputBorder.none),
                              )
                            : SizedBox(
                                height: height / 20,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  child: Container(
                                    padding: const EdgeInsets.only(
                                        left: 26, right: 26),
                                    child: Text(
                                      name,
                                      style: const TextStyle(
                                          fontSize: 35,
                                          fontWeight: FontWeight.w200),
                                    ),
                                  ),
                                  onTap: () {
                                    _nameTextEditingController.text = name;

                                    setState(() {
                                      nameEdit = true;
                                    });
                                  },
                                ),
                              ),
                        SizedBox(
                          height: height / 20,
                        ),
                        Container(
                          padding: const EdgeInsets.only(left: 26, right: 26),
                          child: Text(
                            email,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w200),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(left: 26, right: 26),
                          child: Text(
                            "From $createdAt",
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w200),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            child: Container(
                              padding:
                                  const EdgeInsets.only(left: 26, right: 26),
                              child: Center(
                                child: bioEdit
                                    ? TextField(
                                        autofocus: true,
                                        textAlign: TextAlign.center,
                                        controller: _bioTextEditingController,
                                        cursorColor: Colors.black,
                                        maxLines: null,
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w200),
                                        decoration: const InputDecoration(
                                            isDense: true,
                                            contentPadding: EdgeInsets.all(0),
                                            border: InputBorder.none),
                                      )
                                    : Text(
                                        bio,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w200),
                                      ),
                              ),
                            ),
                            onTap: () {
                              _bioTextEditingController.text = bio;

                              setState(() {
                                bioEdit = true;
                              });
                            },
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
      },
    );
  }

  Future<HereJsonForm> _getMyInformation() async {
    AccessToken aToken = await getAccessToken(_storage);
    RequsetApiForm requestApiForm = RequsetApiForm();
    requestApiForm.method = 'GET';
    requestApiForm.headers = {'Cookie': aToken.accessToken};
    requestApiForm.url = 'http://localhost:8080/user';
    HereJsonForm hereJsonForm = await requestApi(requestApiForm);
    return hereJsonForm;
  }
}
