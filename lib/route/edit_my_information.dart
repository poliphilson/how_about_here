import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:here/commons/animation/top_to_bottom.dart';
import 'package:here/commons/function/get_access_token.dart';
import 'package:here/commons/function/get_my_information.dart';
import 'package:here/commons/widget/custom_progress_indicator.dart';
import 'package:here/commons/widget/new_route_base.dart';
import 'package:here/models.dart';
import 'package:here/route/login.dart';

class EditMyInfomation extends StatefulWidget {
  const EditMyInfomation({super.key});

  @override
  State<EditMyInfomation> createState() => _EditMyInfomationState();
}

class _EditMyInfomationState extends State<EditMyInfomation> {
  final _storage = const FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

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
                  child: IconButton(
                    onPressed: () {
                      
                    },
                    icon: const Icon(Icons.save, color: Colors.blue,),
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
              builder: (context, snapshot) {
                if (snapshot.hasData == false) {
                  return const CustomProgressIndicator();
                } else {
                  if (snapshot.data!.accessToken == '') {
                    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                      Navigator.push(
                          context, topToBottom(const Login(main: false)));
                    });
                    return Container();
                  } else {
                    String aToken = snapshot.data!.accessToken;
                    return FutureBuilder<User>(
                      future: getMyInformation(_storage),
                      builder: (context, snapshot) {
                        if (snapshot.hasData == false) {
                          return const CustomProgressIndicator();
                        } else {
                          return FittedBox(
                            child:GestureDetector(
                              child: CircleAvatar(
                                backgroundColor: Colors.grey.shade200,
                                backgroundImage: CachedNetworkImageProvider(
                                  'http://localhost:8080/image/${snapshot.data!.profileImage}',
                                  headers: {"Cookie": aToken},
                                ),
                              ),
                              onTap: () async {
                              },
                            ),
                          );
                        }
                      },
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
            child: FutureBuilder<User>(
              future: getMyInformation(_storage),
              builder: (context, snapshot) {
                if (snapshot.hasData == false) {
                  return const CustomProgressIndicator();
                } else {
                  return Container(
                    padding: const EdgeInsets.only(left: 72, right: 72),
                    child: FittedBox(
                      child: Text(snapshot.data!.email),
                    ),
                  );
                }
              },
            ),
          ),
          const Expanded(
            child: Center(
              child: Text('Support soon:)'),
            ),
          )
        ],
      ),
    );
  }
}
