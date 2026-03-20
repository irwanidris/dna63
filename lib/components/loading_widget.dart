import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:nb_utils/nb_utils.dart';

import '../utils/app_constants.dart';

class LoadingWidget extends StatelessWidget {
  final bool isBlurBackground;

  const LoadingWidget({this.isBlurBackground = true});

  @override
  Widget build(BuildContext context) {
    return isBlurBackground
        ? SizedBox(
            height: 60,
            width: 60,
            child: Image.asset(
              'assets/images/Comp 3_1.gif',
              height: 60,
              width: 60,
              fit: BoxFit.cover,
              alignment: Alignment.center,
            )).center()
        : Image.asset('assets/images/Comp 3_1.gif', height: 60, width: 60, fit: BoxFit.cover);
  }
}

class ThreeBounceLoadingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SpinKitThreeBounce(
      size: 30,
      itemBuilder: (BuildContext context, int index) {
        return DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: appColorPrimary,
          ),
        );
      },
    );
  }
}
