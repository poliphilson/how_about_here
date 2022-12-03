import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:here/commons/function/get_access_token.dart';
import 'package:here/commons/function/request_api.dart';
import 'package:here/commons/provider/control_here_marker.dart';
import 'package:here/commons/widget/new_route_base.dart';
import 'package:here/constant.dart';
import 'package:here/models.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class RecycleBin extends StatefulWidget {
  const RecycleBin({required this.date, super.key});

  final DateTime date;

  @override
  State<RecycleBin> createState() => _RecycleBinState();
}

class _RecycleBinState extends State<RecycleBin> with TickerProviderStateMixin{
  final _storage = const FlutterSecureStorage();
  final ScrollController _pointScrollController = ScrollController();
  final ScrollController _hereScrollController = ScrollController();
  final int limit = 15;

  late TabController _tabController;

  List<Point> pointList = [];
  List<Here> hereList = [];
  int pointOffset = 0;
  int hereOffset = 0;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) { 
      _getInitDeleted();
    });
    _hereScrollController.addListener(_hereScrollListener);
    _pointScrollController.addListener(_pointScrollListener);
    super.initState();
  }

  @override
  void dispose() {
    _hereScrollController.dispose();
    _pointScrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  _hereScrollListener() async {
    if (_hereScrollController.offset >=
            _hereScrollController.position.maxScrollExtent &&
        !_hereScrollController.position.outOfRange) {
      List<Here> getHeres = await _getDeletedHeres();
      setState(() {
        hereList.addAll(getHeres);
      });
    }
  }

  _pointScrollListener() async {
    if (_pointScrollController.offset >=
            _pointScrollController.position.maxScrollExtent &&
        !_pointScrollController.position.outOfRange) {
      List<Point> getPoints = await _getDeletedPoints();
      setState(() {
        pointList.addAll(getPoints);
      });
    }
  }

  _getInitDeleted() async {
    await _getDeletedHeres().then((value) {
      setState(() {
          hereList.addAll(value);
      });
    });
    await _getDeletedPoints().then((value) {
      setState(() {
          pointList.addAll(value);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

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
                    icon: const Icon(
                      Icons.cancel_rounded,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            labelColor: Colors.black,
            indicatorColor: Colors.black,
            tabs: const [
              Tab(
                text: 'Here',
              ),
              Tab(
                text: 'Check point',
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                ListView.builder(
                  controller: _hereScrollController,
                  itemCount: hereList.length,
                  itemBuilder: (context, index) {
                    final String parseDate = hereList[index].createdAt.split('.').first;
                    final DateTime date = DateTime.parse(parseDate);
                    final DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm');
                    final String prettyDate = dateFormat.format(date);

                    return ListTile(
                      title: Text(hereList[index].contents, maxLines: 1,),
                      subtitle: Text(prettyDate),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () async {
                              AccessToken aToken = await getAccessToken(_storage);
                              RequsetApiForm requestApiForm = RequsetApiForm();
                              requestApiForm.method = 'PATCH';
                              requestApiForm.headers = {'Cookie': aToken.accessToken};
                              requestApiForm.url = 'http://localhost:8080/trash/here/${hereList[index].hid}';
                              HereJsonForm hereJsonForm = await requestApi(requestApiForm);
                              if (hereJsonForm.hereCode != statusOK) {
                                print('fail');
                              } else {
                                final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
                                final String date = dateFormat.format(widget.date);

                                if (date == prettyDate.split(' ').first) {
                                  if (!mounted) return;
                                  Provider.of<ControlHereMarker>(context, listen: false).add(hereList[index], BitmapDescriptor.hueRed);
                                }

                                setState(() {
                                  hereList.removeAt(index);
                                });
                              }
                            },
                            icon: const Icon(Icons.refresh_rounded, color: Colors.blue,),
                          ),
                          IconButton(
                            onPressed: () async {
                              AccessToken aToken = await getAccessToken(_storage);
                              RequsetApiForm requestApiForm = RequsetApiForm();
                              requestApiForm.method = 'DELETE';
                              requestApiForm.headers = {'Cookie': aToken.accessToken};
                              requestApiForm.url = 'http://localhost:8080/trash/here/${hereList[index].hid}';
                              HereJsonForm hereJsonForm = await requestApi(requestApiForm);
                              if (hereJsonForm.hereCode != statusOK) {
                                print('fail');
                              } else {
                                setState(() {
                                  hereList.removeAt(index);
                                });
                              }
                            },
                            icon: const Icon(Icons.delete_forever_rounded, color: Colors.red,),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                ListView.builder(
                  controller: _pointScrollController,
                  itemCount: pointList.length,
                  itemBuilder: (context, index) {
                    final String parseDate = pointList[index].createdAt.split('.').first;
                    final DateTime date = DateTime.parse(parseDate);
                    final DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm');
                    final String prettyDate = dateFormat.format(date);

                    return ListTile(
                      title: Text(pointList[index].description, maxLines: 1,),
                      subtitle: Text(prettyDate),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () async {
                              AccessToken aToken = await getAccessToken(_storage);
                              RequsetApiForm requestApiForm = RequsetApiForm();
                              requestApiForm.method = 'PATCH';
                              requestApiForm.headers = {'Cookie': aToken.accessToken};
                              requestApiForm.url = 'http://localhost:8080/trash/point/${pointList[index].pid}';
                              HereJsonForm hereJsonForm = await requestApi(requestApiForm);
                              if (hereJsonForm.hereCode != statusOK) {
                                print('fail');
                              } else {
                                setState(() {
                                  pointList.removeAt(index);
                                });
                              }
                            },
                            icon: const Icon(Icons.refresh_rounded, color: Colors.blue,),
                          ),
                          IconButton(
                            onPressed: () async {
                              AccessToken aToken = await getAccessToken(_storage);
                              RequsetApiForm requestApiForm = RequsetApiForm();
                              requestApiForm.method = 'DELETE';
                              requestApiForm.headers = {'Cookie': aToken.accessToken};
                              requestApiForm.url = 'http://localhost:8080/trash/point/${pointList[index].pid}';
                              HereJsonForm hereJsonForm = await requestApi(requestApiForm);
                              if (hereJsonForm.hereCode != statusOK) {
                                print('fail');
                              } else {
                                setState(() {
                                  pointList.removeAt(index);
                                });
                              }
                            },
                            icon: const Icon(Icons.delete_forever_rounded, color: Colors.red,),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Here>> _getDeletedHeres() async {
    List<Here> hereList = [];
    AccessToken aToken = await getAccessToken(_storage);
    RequsetApiForm requsetApiForm = RequsetApiForm();
    requsetApiForm.method = 'GET';
    requsetApiForm.headers = {"Cookie": aToken.accessToken};
    requsetApiForm.url =
        'http://localhost:8080/trash/here?limit=$limit&offset=$hereOffset';
    HereJsonForm hereJsonForm = await requestApi(requsetApiForm);
    hereJsonForm.data ??= [];
    List<Map<String, dynamic>> heres = (hereJsonForm.data as List)
        .map((item) => item as Map<String, dynamic>)
        .toList();
    hereOffset = hereOffset + heres.length;
    for (int i = 0; i < heres.length; i++) {
      Here here = Here.fromJson(heres[i]);
      hereList.add(here);
    }
    return hereList;
  }

  Future<List<Point>> _getDeletedPoints() async {
    List<Point> pointList = [];
    AccessToken aToken = await getAccessToken(_storage);
    RequsetApiForm requsetApiForm = RequsetApiForm();
    requsetApiForm.method = 'GET';
    requsetApiForm.headers = {"Cookie": aToken.accessToken};
    requsetApiForm.url = 'http://localhost:8080/trash/point?limit=$limit&offset=$pointOffset';
    HereJsonForm hereJsonForm = await requestApi(requsetApiForm);
    hereJsonForm.data ??= [];
    List<Map<String, dynamic>> points = (hereJsonForm.data as List)
        .map((item) => item as Map<String, dynamic>)
        .toList();
    pointOffset = pointOffset + points.length;
    for (int i = 0; i < points.length; i++) {
      Point point = Point.fromJson(points[i]);
      pointList.add(point);
    }
    return pointList;
  }
}
