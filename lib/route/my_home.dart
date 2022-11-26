import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:here/commons/animation/scale.dart';
import 'package:here/commons/animation/top_to_bottom.dart';
import 'package:here/commons/function/get_access_token.dart';
import 'package:here/commons/function/get_my_location.dart';
import 'package:here/commons/function/get_refresh_token.dart';
import 'package:here/commons/function/request_api.dart';
import 'package:here/commons/function/sign_out.dart';
import 'package:here/commons/provider/control_here_location.dart';
import 'package:here/commons/provider/control_here_marker.dart';
import 'package:here/commons/widget/custom_progress_indicator.dart';
import 'package:here/constant.dart';
import 'package:here/models.dart';
import 'package:here/route/check_point.dart';
import 'package:here/route/login.dart';
import 'package:here/route/write.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MyHome extends StatefulWidget {
  const MyHome({required this.heres, super.key});

  final List<Map<String, dynamic>> heres;

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  final _storage = const FlutterSecureStorage();
  final Completer<GoogleMapController> _googleMapController = Completer();
  final TextEditingController _descriptionTextEditController = TextEditingController();

  DateTime datePickerDate = DateTime.now();

  @override
  void initState() {
    Here here;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (int i = 0; i < widget.heres.length; i++) {
        here = Here.fromJson(widget.heres[i]);
        Provider.of<ControlHereMarker>(context, listen: false).add(here, BitmapDescriptor.hueRed);
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _descriptionTextEditController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            markers: Set.from(
                Provider.of<ControlHereMarker>(context, listen: true).markers),
            myLocationButtonEnabled: false,
            initialCameraPosition: const CameraPosition(
              target: LatLng(37.501396, 126.912186),
              zoom: 15,
            ),
            onMapCreated: (controller) {
              _googleMapController.complete(controller);
            },
          ),
          Positioned(
            top: 60,
            left: 30,
            child: _userFloatingActionButton(),
          ),
          Positioned(
            bottom: 60,
            right: 30,
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
          child: const Icon(Icons.location_on_outlined),
          label: 'Check point',
          onTap: () {
            Navigator.push(context, scale(const CheckPoint(main: true,), false));
          },
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
                        Navigator.push(
                            context, topToBottom(const Login(main: false)));
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
          onTap: () async {
            final GoogleMapController controller = await _googleMapController.future;
            final Position position = await getMyLocation();

            controller.animateCamera(CameraUpdate.newLatLng(
                LatLng(position.latitude, position.longitude)));
                
            if (!mounted) return;
            Provider.of<ControlHereMarker>(context, listen: false).myLocation(position.latitude, position.longitude, BitmapDescriptor.hueViolet);
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.calendar_month_outlined),
          label: 'Calendar',
          onTap: () async {
            final DateTime? selectedDate = await showDatePicker(
              context: context,
              initialDate: datePickerDate,
              firstDate: DateTime(2022),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    textSelectionTheme: const TextSelectionThemeData(
                      cursorColor: Colors.black,
                    ),
                    colorScheme: const ColorScheme.light(
                      primary: Colors.black,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (selectedDate == null) {
              return;
            } else {
              datePickerDate = selectedDate;
              
              final RequsetApiForm getHeresApiForm = RequsetApiForm();
              final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
              final String date = dateFormat.format(selectedDate);
              final AccessToken aToken = await getAccessToken(_storage);

              getHeresApiForm.method = 'GET';
              getHeresApiForm.url = 'http://localhost:8080/here?date=$date';
              getHeresApiForm.headers = {"Cookie": aToken.accessToken};

              HereJsonForm getHeresJsonForm = await requestApi(getHeresApiForm);
              getHeresJsonForm.data ??= [];
              List<Map<String, dynamic>> heres = (getHeresJsonForm.data as List)
                  .map((item) => item as Map<String, dynamic>)
                  .toList();

              if (!mounted) return;
              Provider.of<ControlHereMarker>(context, listen: false).clear();

              for (int i = 0; i < heres.length; i++) {
                Here here = Here.fromJson(heres[i]);
                Provider.of<ControlHereMarker>(context, listen: false).add(here, BitmapDescriptor.hueRed);
              }
            }
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.add_location_alt_outlined),
          label: 'Add check point',
          onTap: () async {   
            final GoogleMapController controller =
                await _googleMapController.future;
            final Position position = await getMyLocation();

            controller.animateCamera(CameraUpdate.newLatLng(
                LatLng(position.latitude, position.longitude)));

            if (!mounted) return;
            checkPointDialog(context, position.latitude, position.longitude);
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.edit_location_outlined),
          label: 'Write',
          onTap: () {
            Navigator.push(context, scale(const Write(), false)).then((_) {
              Provider.of<ControlHereLocation>(context, listen: false).setLocality('Hmm...');
              Provider.of<ControlHereLocation>(context, listen: false).setArea(' ');
            });
          },
        ),
      ],
    );
  }

  void checkPointDialog(BuildContext context, double latitude, double longitude) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Center(
                child: Text('Description'),
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [ConstrainedBox(
                            constraints: BoxConstraints(
                                minWidth: width, minHeight: height / 15),
                            child: TextField(
                              controller: _descriptionTextEditController,
                              maxLines: null,
                              cursorColor: Colors.black,
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.all(0),
                                hintText: 'What do you want to write down?',
                                enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.transparent)),
                                focusedBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.transparent)),
                              ),
                            ),
                          )
                  ],
                ),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              actions: [
                TextButton(
                  onPressed: () async {
                    AccessToken aToken = await getAccessToken(_storage);
                    RequsetApiForm requestApiForm = RequsetApiForm();
                    requestApiForm.method = 'POST';
                    requestApiForm.headers = {
                      'Cookie': aToken.accessToken,
                      "Content-Type": "application/json"
                    };
                    requestApiForm.url = 'http://localhost:8080/point';
                    requestApiForm.body = {
                      'x': latitude,
                      'y': longitude,
                      'description': _descriptionTextEditController.text
                    };
                    HereJsonForm hereJsonForm = await requestApi(requestApiForm);
                    if (hereJsonForm.hereCode != statusOK) {
                      print('fail');
                    } else {
                      if (!mounted) return;
                      Navigator.pop(context);
                      Provider.of<ControlHereMarker>(context, listen: false).myLocation(latitude, longitude, BitmapDescriptor.hueCyan);
                    }
                  },
                  child: const Text('Save'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel', style: TextStyle(color: Colors.red))
                ),
              ],
            );
          },
        );
      },
    ).then((value) {
      _descriptionTextEditController.text = '';
    });
  }
}

/*example lat lng
37.5012,  
37.501396, 126.912186
37.500484, 126.91186
*/
