import 'package:flutter/material.dart';

class NewRouteBase extends StatelessWidget {
  const NewRouteBase({this.image, required this.child, super.key});

  final Widget child;
  final DecorationImage? image;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Center(
        child: SingleChildScrollView(
          child: SafeArea(
            child: Container(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              height: height - 100,
              width: width - 40,
              decoration: BoxDecoration(
                image: image,
                color: Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade500,
                    spreadRadius: 5,
                    blurRadius: 15,
                    offset: const Offset(10, 10),
                  )
                ],
              ),
              child: child
            ),
          ),
        ),
      ),
    );
  }
}
