import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:here/commons/animation/scale.dart';
import 'package:here/commons/animation/top_to_bottom.dart';
import 'package:here/commons/function/get_access_token.dart';
import 'package:here/commons/provider/control_check_point.dart';
import 'package:here/commons/provider/control_here_location.dart';
import 'package:here/commons/provider/control_here_marker.dart';
import 'package:here/commons/widget/custom_progress_indicator.dart';
import 'package:here/route/my_home.dart';
import 'package:provider/provider.dart';
import 'package:here/constant.dart';
import 'package:here/models.dart';
import 'package:here/commons/function/request_api.dart';
import 'package:here/route/login.dart';
import 'package:here/commons/provider/progress_indicator_status.dart';
import 'package:intl/intl.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProgressIndicatorStatus()),
        ChangeNotifierProvider(create: (_) => ControlHereMarker()),
        ChangeNotifierProvider(create: (_) => ControlCheckPoint()),
        ChangeNotifierProvider(create: (_) => ControlHereLocation()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Here',
        home: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage('assets/background.jpg'),
            ),
          ),
          child: const Main(),
        ),
      ),
    ),
  );
}

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  final _storage = const FlutterSecureStorage();
  final RequsetApiForm requestApiForm = RequsetApiForm();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FutureBuilder<AccessToken>(
        future: getAccessToken(_storage),
        builder: (context, snapshot) {
          if (snapshot.hasData == false) {
            return const Center(
              child: CustomProgressIndicator(),
            );
          } else {
            if (snapshot.data!.accessToken == "") {
              SchedulerBinding.instance.addPostFrameCallback((_) {
                Navigator.push(context, topToBottom(const Login(main: true)));
              });
              return Container();
            } else {
              final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
              final String today = dateFormat.format(DateTime.now());
              requestApiForm.method = 'GET';
              requestApiForm.headers = {"Cookie": snapshot.data!.accessToken};
              requestApiForm.url = 'http://localhost:8080/here?date=$today';
              return FutureBuilder<HereJsonForm>(
                future: requestApi(requestApiForm),
                builder: (_, snapshot) {
                  if (snapshot.hasData == false) {
                    return const Center(
                      child: CustomProgressIndicator(),
                    );
                  } else {
                    if (snapshot.data!.hereCode != statusOK) {
                      SchedulerBinding.instance.addPostFrameCallback((_) {
                        Navigator.push(context, topToBottom(const Login(main: true)));
                      });
                      return Container();
                    } else {
                      snapshot.data!.data ??= [];
                      List<Map<String, dynamic>> heres;
                      heres = (snapshot.data!.data as List)
                            .map((item) => item as Map<String, dynamic>)
                            .toList();
                      SchedulerBinding.instance.addPostFrameCallback((_) {
                        Navigator.pushReplacement(context, scale(MyHome(heres: heres), true));
                      });
                      return Container();
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
}
