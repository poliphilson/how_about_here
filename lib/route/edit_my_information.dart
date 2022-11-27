import 'package:flutter/material.dart';
import 'package:here/commons/widget/new_route_base.dart';

class EditMyInfomation extends StatefulWidget {
  const EditMyInfomation({super.key});

  @override
  State<EditMyInfomation> createState() => _EditMyInfomationState();
}

class _EditMyInfomationState extends State<EditMyInfomation> {
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
        ],
      ),
    );
  }
}