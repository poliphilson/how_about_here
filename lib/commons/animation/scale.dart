import 'package:flutter/widgets.dart';

Route scale(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) {
      return page;
    },
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = 0.0;
      var end = 1.0;
      return ScaleTransition(
        scale: Tween<double>(
          begin: begin,
          end: end,
        ).animate(
          CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn),
        ),
        child: child,
      );
    },
  );
}
