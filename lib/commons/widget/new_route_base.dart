import 'package:flutter/material.dart';

class NewRouteBase extends StatelessWidget {
  const NewRouteBase({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        margin: const EdgeInsets.fromLTRB(20, 50, 20, 50),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade500,
              spreadRadius: 5,
              blurRadius: 15,
              offset: const Offset(10, 10)
            )
          ]
        ),
      ),
    );
  }
}