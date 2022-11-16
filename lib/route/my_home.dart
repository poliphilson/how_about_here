import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:here/commons/animation/top_to_bottom.dart';
import 'package:here/commons/provider/control_marker.dart';
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
      body: GoogleMap(
        markers: Set.from(Provider.of<ControlMarker>(context, listen: true).markers),
        myLocationButtonEnabled: false,
        initialCameraPosition: const CameraPosition(
          target: LatLng(37.501396, 126.912186),
          zoom: 15,
        ),
      ),
    );
  }

  void _goToLogin(BuildContext context) {
    Navigator.push(context, topToBottom(const Login(main: false)));
  }
}

/*example lat lng
37.5012, 126.914
37.501396, 126.912186
*/
