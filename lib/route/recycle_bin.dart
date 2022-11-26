import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:here/commons/function/get_access_token.dart';
import 'package:here/commons/function/request_api.dart';
import 'package:here/commons/widget/new_route_base.dart';
import 'package:here/constant.dart';
import 'package:here/models.dart';
import 'package:intl/intl.dart';

class RecycleBin extends StatefulWidget {
  const RecycleBin({super.key});

  @override
  State<RecycleBin> createState() => _RecycleBinState();
}

class _RecycleBinState extends State<RecycleBin> with TickerProviderStateMixin{
  final _storage = const FlutterSecureStorage();
  final ScrollController _pointScrollController = ScrollController();
  final int limit = 15;

  late TabController _tabController;

  List<Point> pointList = [];
  int pointOffset = 0;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) { 
      _getInitDeleted();
    });
    _pointScrollController.addListener(_pointScrollListener);
    super.initState();
  }

  @override
  void dispose() {
    _pointScrollController.dispose();
    _tabController.dispose();
    super.dispose();
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
    List<Point> firstPoints = []; 
    firstPoints = await _getDeletedPoints();
    setState(() {
      pointList.addAll(firstPoints);
    });
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
                Container(color: Colors.amber,),
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

  Future<List<Point>> _getDeletedPoints() async {
    List<Point> pointList = [];
    AccessToken aToken = await getAccessToken(_storage);
    RequsetApiForm requsetApiForm = RequsetApiForm();
    requsetApiForm.method = 'GET';
    requsetApiForm.headers = {"Cookie": aToken.accessToken};
    requsetApiForm.url =
        'http://localhost:8080/trash/point?limit=$limit&offset=$pointOffset';
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
