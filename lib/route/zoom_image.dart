import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:here/commons/animation/top_to_bottom.dart';
import 'package:here/commons/function/get_access_token.dart';
import 'package:here/commons/widget/custom_progress_indicator.dart';
import 'package:here/constant.dart';
import 'package:here/models.dart';
import 'package:here/route/login.dart';

class ZoomImage extends StatelessWidget {
  const ZoomImage({required this.imageUrl, super.key});

  final _storage = const FlutterSecureStorage();
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: SizedBox(
          height: double.infinity,
          child: InteractiveViewer(
            child: FutureBuilder<AccessToken>(
              future: getAccessToken(_storage),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CustomProgressIndicator(),
                  );
                } else {
                  if (snapshot.data!.accessToken == "") {
                    SchedulerBinding.instance.addPostFrameCallback((_) {
                      Navigator.push(
                          context, topToBottom(const Login(main: false)));
                    });
                    return Container();
                  } else {
                    return InteractiveViewer(
                      child: Image(
                        image: CachedNetworkImageProvider(
                          '$server/image/$imageUrl',
                          headers: {"Cookie": snapshot.data!.accessToken},
                        ),
                      ),
                    );
                  }
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
