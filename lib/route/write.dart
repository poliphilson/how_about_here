import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:here/commons/animation/right_to_left.dart';
import 'package:here/commons/function/get_access_token.dart';
import 'package:here/commons/function/get_address_from_location.dart';
import 'package:here/commons/function/get_area.dart';
import 'package:here/commons/function/get_locality.dart';
import 'package:here/commons/function/get_my_location.dart';
import 'package:here/commons/function/request_api.dart';
import 'package:here/commons/provider/control_here_location.dart';
import 'package:here/commons/provider/control_here_marker.dart';
import 'package:here/commons/provider/progress_indicator_status.dart';
import 'package:here/commons/widget/custom_progress_indicator.dart';
import 'package:here/commons/widget/new_route_base.dart';
import 'package:here/constant.dart';
import 'package:here/models.dart';
import 'package:here/route/check_point.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class Write extends StatefulWidget {
  const Write({super.key});

  @override
  State<Write> createState() => _WriteState();
}

class _WriteState extends State<Write> {
  final _storage = const FlutterSecureStorage();
  final TextEditingController _contentsTextEditController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  List<XFile?> images = [];
  XFile? video;
  bool private = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getMyCurrentAddress();
    });
    super.initState();
  }

  _getMyCurrentAddress() async {
    final Position position = await getMyLocation();
    final Placemark placemark = await getAddressFromLocation(position.latitude, position.longitude);
    // Name > Subthoroughfare > Street > Sublocality > Locality > Administrative area > Country
    if (!mounted) return;
    Provider.of<ControlHereLocation>(context, listen: false).setLatitude(position.latitude);
    Provider.of<ControlHereLocation>(context, listen: false).setLongitude(position.longitude);
    Provider.of<ControlHereLocation>(context, listen: false).setArea(getArea(placemark));
    Provider.of<ControlHereLocation>(context, listen: false).setLocality(getLocality(placemark));
    
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return NewRouteBase(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: height / 20,
              child: Consumer<ProgressIndicatorStatus>(
                builder: (context, progressIndicator, child) {
                  return Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(left: 10),
                        child: IconButton(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          icon: const Icon(
                            Icons.cancel_rounded,
                            color: Colors.red,
                          ),
                          onPressed: progressIndicator.status
                              ? null
                              : () {
                                  Navigator.pop(context);
                                },
                        ),
                      ),
                      Expanded(
                        child: Container(),
                      ),
                      Container(
                        padding: const EdgeInsets.only(right: 10),
                        child: progressIndicator.status
                            ? Container(
                                padding: const EdgeInsets.only(right: 8),
                                child: const CustomProgressIndicator(),
                              )
                            : IconButton(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                icon: const Icon(
                                  Icons.send,
                                  color: Colors.blue,
                                ),
                                onPressed: () async {
                                  progressIndicator.on();

                                  AccessToken aToken = await getAccessToken(_storage);

                                  if (!mounted) return;
                                  final SendHereForm sendHereForm = SendHereForm();
                                  sendHereForm.contents = _contentsTextEditController.text;
                                  sendHereForm.isPrivated = private;
                                  sendHereForm.x = Provider.of<ControlHereLocation>(context, listen: false).latitude;
                                  sendHereForm.y = Provider.of<ControlHereLocation>(context, listen: false).longitude;
                                  sendHereForm.images = images;

                                  HereJsonForm hereJsonForm =  await sendHere(sendHereForm, aToken.accessToken);
                                  if (hereJsonForm.hereCode == statusOK) {
                                    Here here = Here.fromJson(hereJsonForm.data);

                                    if (!mounted) return;
                                    Provider.of<ControlHereMarker>(context, listen: false).add(here, BitmapDescriptor.hueRed);
                                    progressIndicator.off();
                                    Navigator.pop(context);
                                  } else {
                                    print('Fail to send here');
                                    progressIndicator.off();
                                  }
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(
              height: height / 20,
              child: Container(
                padding: const EdgeInsets.only(left: 26),
                child: const FittedBox(
                  child: Text(
                    'Here',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: height / 20,
              child: Container(
                padding: const EdgeInsets.only(left: 26, right: 26),
                child: FittedBox(
                  child: Text(
                    Provider.of<ControlHereLocation>(context, listen: true).locality,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: height / 20,
              child: Container(
                padding: const EdgeInsets.only(left: 26, right: 26),
                child: FittedBox(
                  child: Text(
                    Provider.of<ControlHereLocation>(context, listen: true).area,
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.location_on_outlined, color: Colors.blue,),
                    onPressed: () {
                      Navigator.push(context, rightToLeft(const CheckPoint(main: false,)));
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.my_location_outlined, color: Colors.blue,),
                    onPressed: () async {
                      await _getMyCurrentAddress();
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
              height: height / 20,
              child: Container(
                padding: const EdgeInsets.only(left: 26, right: 26),
                child: const FittedBox(
                  child: Text(
                    'Now',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(left: 26, right: 26),
              child: TextField(
                controller: _contentsTextEditController,
                cursorColor: Colors.black,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'What are you doing here?',
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent)),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent)),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: private
                        ? const Icon(
                            Icons.lock,
                          )
                        : const Icon(
                            Icons.lock_open,
                            color: Colors.grey,
                          ),
                    onPressed: () {
                      setState(() {
                        private = !private;
                      });
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
              height: height / 20,
              child: Container(
                padding: const EdgeInsets.only(left: 26, right: 26),
                child: const FittedBox(
                  child: Text(
                    'Photos?',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: height / 5,
              child: images.isEmpty
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            images = await _picker.pickMultiImage();
                            setState(() {
                              images.isEmpty;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(15),
                              backgroundColor: Colors.black),
                          child: const Icon(Icons.add_photo_alternate_outlined),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            final XFile? image = await _picker.pickImage(
                                source: ImageSource.camera);
                            if (image != null) {
                              images.add(image);
                            }
                            setState(() {
                              images.isEmpty;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(15),
                              backgroundColor: Colors.black),
                          child: const Icon(Icons.add_a_photo_outlined),
                        ),
                      ],
                    )
                  : Container(
                      padding: const EdgeInsets.only(left: 26, right: 26),
                      child: Center(
                        child: ListView.separated(
                          shrinkWrap: true,
                          separatorBuilder: (context, index) => const SizedBox(
                            width: 10,
                          ),
                          scrollDirection: Axis.horizontal,
                          itemCount: images.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              alignment: Alignment.topRight,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.file(
                                    File(images[index]!.path),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      images.removeAt(index);
                                    });
                                  },
                                )
                              ],
                            );
                          },
                        ),
                      ),
                    ),
            ),
            SizedBox(
              height: height / 20,
              child: Container(
                padding: const EdgeInsets.only(left: 26, right: 26),
                child: const FittedBox(
                  child: Text(
                    'Videos?',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: height / 5,
              child: const Center(
                child: Text('Support soon:)'),
              ), /*Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      video = await _picker.pickVideo(source: ImageSource.gallery);
                    },
                    style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(15),
                        backgroundColor: Colors.black),
                    child: const Icon(Icons.camera_roll_outlined),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      video = await _picker.pickVideo(source: ImageSource.camera);
                    },
                    style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(15),
                        backgroundColor: Colors.black),
                    child: const Icon(Icons.camera),
                  ),
                ],
              ),*/
            ),
          ],
        ),
      ),
    );
  }
}
