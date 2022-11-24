import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:here/commons/function/get_access_token.dart';
import 'package:here/commons/function/request_api.dart';
import 'package:here/commons/provider/control_check_point.dart';
import 'package:here/commons/widget/new_route_base.dart';
import 'package:here/constant.dart';
import 'package:here/models.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CheckPoint extends StatefulWidget {
  const CheckPoint({required this.main, super.key});

  final bool main;

  @override
  State<CheckPoint> createState() => _CheckPointState();
}

class _CheckPointState extends State<CheckPoint> {
  final _storage = const FlutterSecureStorage();
  final ScrollController _scrollController = ScrollController();
  final Completer<GoogleMapController> _googleMapController = Completer();
  final int limit = 10;

  List<Marker> markers = [];
  int offset = 0;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getInitPoints();
    });
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  _getInitPoints() async {
    List<Point> getPoints = await _getPoints();
    if (!mounted) return;
    Provider.of<ControlCheckPoint>(context, listen: false).add(getPoints);
  }

  _scrollListener() async {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      List<Point> getPoints = await _getPoints();
      if (!mounted) return;
      Provider.of<ControlCheckPoint>(context, listen: false).add(getPoints);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    super.dispose();
  }

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
                      Provider.of<ControlCheckPoint>(context, listen: false).clear();
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 8),
            height: height / 3,
            child: GoogleMap(
              markers: Set.from(markers),
              myLocationButtonEnabled: false,
              initialCameraPosition: const CameraPosition(
                target: LatLng(37.501396, 126.912186),
                zoom: 15,
              ),
              onMapCreated: (controller) {
                _googleMapController.complete(controller);
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: Provider.of<ControlCheckPoint>(context, listen: true)
                  .points
                  .length,
              itemBuilder: (context, index) {
                final String parseDate =
                    Provider.of<ControlCheckPoint>(context, listen: false)
                        .points[index]
                        .createdAt
                        .split('.')
                        .first;
                final DateTime date = DateTime.parse(parseDate);
                final DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm');
                final String prettyDate = dateFormat.format(date);

                return ListTile(
                  title: Text(
                      Provider.of<ControlCheckPoint>(context, listen: false)
                          .points[index]
                          .description),
                  subtitle: Text(prettyDate),
                  trailing: widget.main
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.blue,
                              ),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              onPressed: () async {
                                AccessToken aToken = await getAccessToken(_storage);
                                RequsetApiForm requsetApiForm = RequsetApiForm();
                                requsetApiForm.method = 'DELETE';
                                requsetApiForm.headers = {"Cookie": aToken.accessToken};
                                if (!mounted) return;
                                requsetApiForm.url = 'http://localhost:8080/point/${Provider.of<ControlCheckPoint>(context, listen: false).points[index].pid}';
                                HereJsonForm hereJsonForm = await requestApi(requsetApiForm);
                                if (hereJsonForm.hereCode != statusOK) {
                                  print('fail');
                                } else {
                                  if (!mounted) return;
                                  Provider.of<ControlCheckPoint>(context, listen: false).delete(index);
                                }
                              },
                            ),
                          ],
                        )
                      : IconButton(
                          icon: const Icon(
                            Icons.check_circle_outline_rounded,
                            color: Colors.blue,
                          ),
                          onPressed: () {},
                        ),
                  onTap: () async {
                    final GoogleMapController controller =
                        await _googleMapController.future;

                    if (!mounted) return;
                    controller.animateCamera(
                      CameraUpdate.newLatLng(
                        LatLng(
                          Provider.of<ControlCheckPoint>(context, listen: false)
                              .points[index]
                              .location['x'],
                          Provider.of<ControlCheckPoint>(context, listen: false)
                              .points[index]
                              .location['y'],
                        ),
                      ),
                    );

                    setState(() {
                      markers.clear();
                      markers.add(
                        Marker(
                          markerId: const MarkerId('check_point'),
                          position: LatLng(
                            Provider.of<ControlCheckPoint>(context,
                                    listen: false)
                                .points[index]
                                .location['x'],
                            Provider.of<ControlCheckPoint>(context,
                                    listen: false)
                                .points[index]
                                .location['y'],
                          ),
                        ),
                      );
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Point>> _getPoints() async {
    List<Point> pointList = [];
    AccessToken aToken = await getAccessToken(_storage);
    RequsetApiForm requsetApiForm = RequsetApiForm();
    requsetApiForm.method = 'GET';
    requsetApiForm.headers = {"Cookie": aToken.accessToken};
    requsetApiForm.url =
        'http://localhost:8080/point?limit=$limit&offset=$offset';
    HereJsonForm hereJsonForm = await requestApi(requsetApiForm);
    hereJsonForm.data ??= [];
    List<Map<String, dynamic>> points = (hereJsonForm.data as List)
        .map((item) => item as Map<String, dynamic>)
        .toList();
    offset = offset + points.length;
    for (int i = 0; i < points.length; i++) {
      Point point = Point.fromJson(points[i]);
      pointList.add(point);
    }
    return pointList;
  }
}
