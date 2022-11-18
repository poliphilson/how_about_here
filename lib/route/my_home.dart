import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:here/commons/animation/top_to_bottom.dart';
import 'package:here/commons/function/get_access_token.dart';
import 'package:here/commons/function/get_refresh_token.dart';
import 'package:here/commons/function/request_api.dart';
import 'package:here/commons/function/sign_out.dart';
import 'package:here/commons/provider/control_marker.dart';
import 'package:here/commons/widget/custom_progress_indicator.dart';
import 'package:here/constant.dart';
import 'package:here/models.dart';
import 'package:here/route/login.dart';
import 'package:provider/provider.dart';

class MyHome extends StatefulWidget {
  const MyHome({required this.heres, super.key});

  final List<Map<String, dynamic>> heres;

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    Here here;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (int i = 0; i < widget.heres.length; i++) {
        here = Here.fromJson(widget.heres[i]);
        Provider.of<ControlMarker>(context, listen: false).add(here);
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            markers: Set.from(
                Provider.of<ControlMarker>(context, listen: true).markers),
            myLocationButtonEnabled: false,
            initialCameraPosition: const CameraPosition(
              target: LatLng(37.501396, 126.912186),
              zoom: 15,
            ),
          ),
          Positioned(
            top: 50,
            left: 20,
            child: _userFloatingActionButton(),
          ),
          Positioned(
            bottom: 50,
            right: 20,
            child: _menuFloatingActionButton(),
          ),
        ],
      ),
    );
  }

  SpeedDial _userFloatingActionButton() {
    return SpeedDial(
      foregroundColor: Colors.black,
      backgroundColor: Colors.white,
      direction: SpeedDialDirection.down,
      spacing: 5,
      overlayOpacity: 0,
      switchLabelPosition: true,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.edit_note_outlined),
          label: 'Edit',
        ),
        SpeedDialChild(
          child: const Icon(Icons.recycling_outlined),
          label: 'Recycle bin',
        ),
        SpeedDialChild(
          child: const Icon(Icons.logout_outlined),
          label: 'Sign out',
          onTap: () async {
            final RequsetApiForm requestApiForm = RequsetApiForm();
            RefreshToken rToken = await getRefreshToken(_storage);
            requestApiForm.method = 'POST';
            requestApiForm.headers = {'Cookie': rToken.refreshToken};
            requestApiForm.url = 'http://localhost:8080/signout';
            await requestApi(requestApiForm);
            await signOut(_storage);
            if (!mounted) return;
            Navigator.push(context, topToBottom(const Login(main: false)));
          },
        ),
      ],
      child: FutureBuilder<AccessToken>(
        future: getAccessToken(_storage),
        builder: (context, snapshot) {
          if (snapshot.hasData == false) {
            return const CustomProgressIndicator();
          } else {
            if (snapshot.data!.accessToken == '') {
              SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                Navigator.push(context, topToBottom(const Login(main: false)));
              });
              return Container();
            } else {
              String aToken = snapshot.data!.accessToken;
              final RequsetApiForm requestApiForm = RequsetApiForm();
              requestApiForm.method = 'GET';
              requestApiForm.headers = {"Cookie": aToken};
              requestApiForm.url = 'http://localhost:8080/user';
              return FutureBuilder<HereJsonForm>(
                future: requestApi(requestApiForm),
                builder: (context, snapshot) {
                  if (snapshot.hasData == false) {
                    return const CustomProgressIndicator();
                  } else {
                    if (snapshot.data!.hereCode != statusOK) {
                      SchedulerBinding.instance.addPostFrameCallback((_) {
                        Navigator.push(context, topToBottom(const Login(main: false)));
                      });
                      return Container();
                    } else {
                      User user = User.fromJson(snapshot.data!.data);
                      return CircleAvatar(
                        backgroundColor: Colors.grey.shade200,
                        radius: 24,
                        backgroundImage: CachedNetworkImageProvider(
                          'http://localhost:8080/image/${user.profileImage}',
                          headers: {"Cookie": aToken},
                        ),
                      );
                    }
                  }
                },
              );
            }
          }
        },
      ),
    );
  }

  SpeedDial _menuFloatingActionButton() {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      foregroundColor: Colors.black,
      backgroundColor: Colors.white,
      spacing: 5,
      overlayOpacity: 0,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.my_location_outlined),
          label: 'My location',
          onTap: () {
            
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.calendar_month_outlined),
          label: 'Calendar',
        ),
        SpeedDialChild(
          child: const Icon(Icons.add_location_alt_outlined),
          label: 'Add check point',
        ),
        SpeedDialChild(
          child: const Icon(Icons.edit_location_outlined),
          label: 'Write',
        ),
      ],
    );
  }
}

/*example lat lng
37.5012, 126.914
37.501396, 126.912186
*/
