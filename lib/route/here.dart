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
import 'package:here/commons/widget/custom_progress_indicator.dart';
import 'package:here/commons/widget/new_route_base.dart';
import 'package:here/main.dart';
import 'package:here/models.dart';
import 'package:here/route/login.dart';

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
  late final SpecificHere detailHere;

  String locality = 'Hmm...';
  String area = ' ';
  bool private = false;
  bool haveImages = false;
  List<String> images = [];

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
    Placemark placemark = Placemark(
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
      private = detailHere.here.isPrivated;
      haveImages = detailHere.here.image;
      images.addAll(dynamicToListString(detailHere.images));
    });
  }

  List<String> dynamicToListString(dynamic value) {
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
              navigatorKey.currentState
                  ?.push(topToBottom(const Login(main: false)));
            });
            return Container();
          } else {
            return NewRouteBase(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: height / 20,
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
                                navigatorKey.currentState?.pop();
                              },
                            ),
                          ),
                          Expanded(
                            child: Container(),
                          ),
                        ],
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
                          child: Text(locality),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: height / 20,
                      child: Container(
                        padding: const EdgeInsets.only(left: 26, right: 26),
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
                          IconButton(
                            icon: const Icon(
                              Icons.location_on_outlined,
                              color: Colors.blue,
                            ),
                            onPressed: () {},
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
                        readOnly: true,
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
                            onPressed: null,
                          ),
                        ],
                      ),
                    ),
                    haveImages
                        ? SizedBox(
                            height: height / 20,
                            child: Container(
                              padding:
                                  const EdgeInsets.only(left: 26, right: 26),
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
                      separatorBuilder: (context, index) => const SizedBox(
                        height: 10,
                      ),
                      shrinkWrap: true,
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        return SizedBox(
                          height: height / 5,
                          child: Container(
                            padding: const EdgeInsets.only(left: 26, right: 26),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: CachedNetworkImageProvider(
                                      'http://localhost:8080/image/${images[index]}',
                                      headers: {
                                        "Cookie": snapshot.data!.accessToken
                                      },
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }
        }
      },
    );
  }

  Future<SpecificHere> _getDetailHere() async {
    AccessToken aToken = await getAccessToken(_storage);
    RequsetApiForm requestApiForm = RequsetApiForm();
    requestApiForm.method = 'GET';
    requestApiForm.headers = {'Cookie': aToken.accessToken};
    requestApiForm.url = 'http://localhost:8080/here/${widget.here.hid}';
    HereJsonForm hereJsonForm = await requestApi(requestApiForm);
    SpecificHere specificHere = SpecificHere.fromJson(hereJsonForm.data);
    return specificHere;
  }
}
