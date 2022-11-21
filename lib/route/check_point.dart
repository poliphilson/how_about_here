import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:here/commons/widget/new_route_base.dart';

class CheckPoint extends StatefulWidget {
  const CheckPoint({super.key});

  @override
  State<CheckPoint> createState() => _CheckPointState();
}

class _CheckPointState extends State<CheckPoint> {
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
          SizedBox(
            height: height / 3,
            child: const GoogleMap(
              myLocationButtonEnabled: false,
              initialCameraPosition: CameraPosition(
                target: LatLng(37.501396, 126.912186),
                zoom: 15,
              ),
            ),
          ),
          SingleChildScrollView(),
        ],
      ),
    );
  }
}
