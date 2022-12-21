import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geocoding/geocoding.dart';
import 'package:here/commons/animation/top_to_bottom.dart';
import 'package:here/commons/function/get_access_token.dart';
import 'package:here/commons/function/get_area.dart';
import 'package:here/commons/function/get_locality.dart';
import 'package:here/commons/function/request_api.dart';
import 'package:here/commons/provider/control_here_marker.dart';
import 'package:here/commons/widget/custom_progress_indicator.dart';
import 'package:here/commons/widget/new_route_base.dart';
import 'package:here/constant.dart';
import 'package:here/models.dart';
import 'package:here/route/login.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class DetailHere extends StatefulWidget {
  const DetailHere({required this.here, super.key});

  final Here here;

  @override
  State<DetailHere> createState() => _DetailHereState();
}

class _DetailHereState extends State<DetailHere> {
  final _storage = const FlutterSecureStorage();
  final TextEditingController _contentsTextEditController =
      TextEditingController();
  final ImagePicker _picker = ImagePicker();
  late final SpecificHere detailHere;
  late final Placemark placemark;

  String locality = 'Hmm...';
  String area = ' ';
  String date = ' ';
  bool private = false;
  bool haveImages = false;
  List<String> images = [];
  List<XFile?> newImages = [];
  bool edit = false;

  @override
  void initState() {
    _contentsTextEditController.text = "Hmm...";
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initHere();
    });
    super.initState();
  }

  void _initHere() async {
    detailHere = await _getDetailHere();
    if (detailHere.hereCode != statusOK) {
      if (!mounted) return;
      Navigator.pop(context);
      Navigator.push(context, topToBottom(const Login(main: false)));
    } else {
      placemark = Placemark(
        name: detailHere.address.name,
        street: detailHere.address.street,
        country: detailHere.address.country,
        administrativeArea: detailHere.address.adminArea,
        subAdministrativeArea: detailHere.address.subArea,
        locality: detailHere.address.locality,
        subLocality: detailHere.address.subLocality,
        thoroughfare: detailHere.address.thoroughfare,
        subThoroughfare: detailHere.address.subThoroughfare,
      );

      setState(() {
        locality = getLocality(placemark);
        area = getArea(placemark);
        _contentsTextEditController.text = detailHere.here.contents;
        date = dateToPrettyDate(detailHere.here.createdAt);
        private = detailHere.here.isPrivated;
        haveImages = detailHere.here.image;
        images.addAll(dynamicToListString(detailHere.images));
      });
    }
  }

  String dateToPrettyDate(String time) {
    final String parseDate = time.split('T')[1].split('+')[0];
    final String prettyDate = '${parseDate.split(':')[0]}:${parseDate.split(':')[1]}';
    return prettyDate;
  }

  List<String> dynamicToListString(dynamic value) {
    value ??= [];
    return List<String>.from(value as List).toList();
  }

  @override
  void dispose() {
    _contentsTextEditController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return FutureBuilder<AccessToken>(
      future: getAccessToken(_storage),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CustomProgressIndicator(),
          );
        } else {
          if (snapshot.data!.accessToken == "") {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              Navigator.push(context, topToBottom(const Login(main: false)));
            });
            return Container();
          } else {
            return NewRouteBase(
              child: Column(
                children: [
                  SizedBox(
                    height: height / 15,
                    child: Row(
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
                          child: Row(
                            children: [
                              edit
                                  ? TextButton(
                                      child: const Text(
                                        'Cancel',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _contentsTextEditController.text = detailHere.here.contents;
                                          private = detailHere.here.isPrivated;
                                          images = dynamicToListString(detailHere.images);
                                          newImages.clear();
                                          edit = false;
                                        });
                                      },
                                    )
                                  : TextButton(
                                      child: const Text('Edit'),
                                      onPressed: () {
                                        setState(() {
                                          edit = true;
                                        });
                                      },
                                    ),
                              edit
                                  ? TextButton(
                                      child: const Text('Save'),
                                      onPressed: () async {
                                        EditHereForm editHereForm = EditHereForm();
                                        editHereForm.contents = _contentsTextEditController.text;
                                        editHereForm.isPrivated = private;
                                        editHereForm.images = images;
                                        editHereForm.newImages = newImages;
                                        HereJsonForm hereJsonForm = await editHere(editHereForm, detailHere.here.hid, snapshot.data!.accessToken);
                                        if (hereJsonForm.hereCode != statusOK) {
                                          print('fail');
                                        } else {
                                          setState(() {
                                          edit = false;
                                        });
                                        }
                                      },
                                    )
                                  : TextButton(
                                      child: const Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                      onPressed: () async {
                                        RequsetApiForm requsetApiForm =
                                            RequsetApiForm();
                                        requsetApiForm.method = 'DELETE';
                                        requsetApiForm.headers = {
                                          'Cookie': snapshot.data!.accessToken
                                        };
                                        requsetApiForm.url =
                                            '$server/here/${detailHere.here.hid}';
                                        HereJsonForm hereJsonForm =
                                            await requestApi(requsetApiForm);
                                        if (hereJsonForm.hereCode == statusOK) {
                                          if (!mounted) return;
                                          Provider.of<ControlHereMarker>(
                                                  context,
                                                  listen: false)
                                              .delete(detailHere.here.hid);
                                          Navigator.pop(context);
                                        } else {
                                          print('fail');
                                        }
                                      },
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                              padding:
                                  const EdgeInsets.only(left: 26, right: 26),
                              child: FittedBox(
                                child: Text(locality),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: height / 20,
                            child: Container(
                              padding:
                                  const EdgeInsets.only(left: 26, right: 26),
                              child: FittedBox(
                                child: Text(area),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  child: const Text(
                                    'More',
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                  onPressed: () {
                                    locationDialog(context, placemark);
                                  },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: height / 20,
                            child: Container(
                              padding:
                                  const EdgeInsets.only(left: 26, right: 26),
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
                              readOnly: !edit,
                              controller: _contentsTextEditController,
                              cursorColor: Colors.black,
                              maxLines: null,
                              decoration: const InputDecoration(
                                hintText: 'What are you doing here?',
                                enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.transparent)),
                                focusedBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.transparent)),
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
                                  onPressed: edit ? () {
                                    setState(() {
                                      private = !private;
                                    });
                                  } : null,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(left: 26, right: 26),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(date, style: const TextStyle(fontWeight: FontWeight.bold),),
                              ],
                            ),
                          ),
                          images.isNotEmpty || edit || newImages.isNotEmpty
                              ? SizedBox(
                                  height: height / 20,
                                  child: Container(
                                    padding: const EdgeInsets.only(
                                        left: 26, right: 26),
                                    child: const FittedBox(
                                      child: Text(
                                        'Photos',
                                        style: TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : Container(),
                          ListView.separated(
                            physics: const NeverScrollableScrollPhysics(),
                            separatorBuilder: (context, index) =>
                                const SizedBox(
                              height: 10,
                            ),
                            shrinkWrap: true,
                            itemCount: images.length,
                            itemBuilder: (context, index) {
                              return Container(
                                padding:
                                    const EdgeInsets.only(left: 26, right: 26),
                                child: Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Image(
                                        image: CachedNetworkImageProvider(
                                          '$server/image/${images[index]}',
                                          headers: {
                                            "Cookie": snapshot.data!.accessToken
                                          },
                                        ),
                                      ),
                                    ),
                                    edit
                                        ? IconButton(
                                            icon: const Icon(
                                              Icons.close,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                images.removeAt(index);
                                              });
                                            },
                                          )
                                        : Container()
                                  ],
                                ),
                              );
                            },
                          ),
                          Container(
                            padding: const EdgeInsets.only(left: 26, right: 26),
                            child: Padding(
                              padding: images.isEmpty || newImages.isEmpty
                              ? EdgeInsets.zero
                              : const EdgeInsets.only(top: 10),
                              child: Center(
                                child: ListView.separated(
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(
                                    height: 10,
                                  ),
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: newImages.length,
                                  itemBuilder: (context, index) {
                                    return Stack(
                                      alignment: Alignment.topRight,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(15),
                                          child: Image.file(
                                            File(newImages[index]!.path),
                                          ),
                                        ),
                                        edit
                                            ? IconButton(
                                                icon: const Icon(
                                                  Icons.close,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    newImages.removeAt(index);
                                                  });
                                                },
                                              )
                                            : Container(),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          edit
                              ? SizedBox(
                                  height: height / 5,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () async {
                                          List<XFile?> newImagesList =
                                              await _picker.pickMultiImage();
                                          if (newImagesList.isNotEmpty) {
                                            setState(() {
                                              newImages.addAll(newImagesList);
                                            });
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                            shape: const CircleBorder(),
                                            padding: const EdgeInsets.all(15),
                                            backgroundColor: Colors.black),
                                        child: const Icon(
                                            Icons.add_photo_alternate_outlined),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(),
                          const SizedBox(
                            height: 8,
                          ),
                        ],
                      ),
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

  void locationDialog(BuildContext context, Placemark placemark) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Center(
                child: Text('Location'),
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: width,
                        minHeight: height / 15,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Theme(
                            data: Theme.of(context)
                                .copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              iconColor: Colors.black,
                              textColor: Colors.black,
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: const [
                                  Icon(Icons.public_rounded),
                                  Text('Country')
                                ],
                              ),
                              children: [
                                ListTile(
                                  title: Center(
                                    child: placemark.country!.isEmpty
                                        ? const Text('???')
                                        : Text(placemark.country!),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Theme(
                            data: Theme.of(context)
                                .copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              iconColor: Colors.black,
                              textColor: Colors.black,
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: const [
                                  Icon(Icons.emoji_transportation_rounded),
                                  Text('Area')
                                ],
                              ),
                              children: [
                                ListTile(
                                  title: Center(
                                    child: Column(
                                      children: [
                                        placemark.administrativeArea!.isEmpty
                                            ? const Text('???')
                                            : Text(
                                                placemark.administrativeArea!),
                                        placemark.subAdministrativeArea!.isEmpty
                                            ? Container()
                                            : Text(
                                                '${placemark.subAdministrativeArea!}(Sub)'),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Theme(
                            data: Theme.of(context)
                                .copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              iconColor: Colors.black,
                              textColor: Colors.black,
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: const [
                                  Icon(Icons.holiday_village_rounded),
                                  Text('Locality')
                                ],
                              ),
                              children: [
                                ListTile(
                                  title: Center(
                                    child: Column(
                                      children: [
                                        placemark.locality!.isEmpty
                                            ? const Text('???')
                                            : Text(placemark.locality!),
                                        placemark.subLocality!.isEmpty
                                            ? Container()
                                            : Text(
                                                '${placemark.subLocality!}(Sub)'),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Theme(
                            data: Theme.of(context)
                                .copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              iconColor: Colors.black,
                              textColor: Colors.black,
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: const [
                                  Icon(Icons.directions_rounded),
                                  Text('Street')
                                ],
                              ),
                              children: [
                                ListTile(
                                  title: Center(
                                    child: placemark.street!.isEmpty
                                        ? const Text('???')
                                        : Text(placemark.street!),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Theme(
                            data: Theme.of(context)
                                .copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              iconColor: Colors.black,
                              textColor: Colors.black,
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: const [
                                  Icon(Icons.route_rounded),
                                  Text('Thoroughfare')
                                ],
                              ),
                              children: [
                                ListTile(
                                  title: Center(
                                    child: Column(
                                      children: [
                                        placemark.thoroughfare!.isEmpty
                                            ? const Text('???')
                                            : Text(placemark.thoroughfare!),
                                        placemark.subAdministrativeArea!.isEmpty
                                            ? Container()
                                            : Text(
                                                '${placemark.subThoroughfare!}(Sub)'),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<SpecificHere> _getDetailHere() async {
    AccessToken aToken = await getAccessToken(_storage);
    RequsetApiForm requestApiForm = RequsetApiForm();
    requestApiForm.method = 'GET';
    requestApiForm.headers = {'Cookie': aToken.accessToken};
    requestApiForm.url = '$server/here/${widget.here.hid}';
    HereJsonForm hereJsonForm = await requestApi(requestApiForm);
    SpecificHere specificHere = SpecificHere.fromJson(hereJsonForm);
    return specificHere;
  }
}
