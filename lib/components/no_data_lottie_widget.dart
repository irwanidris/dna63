import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../utils/app_constants.dart';

class NoDataLottieWidget extends StatelessWidget {
  const NoDataLottieWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(no_data, height: 130);
  }
}

class EmptyPostLottieWidget extends StatelessWidget {
  const EmptyPostLottieWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(add_post, height: 100,repeat: true);
  }
}

class AllCaughtUpLottieWidget extends StatelessWidget {
  const AllCaughtUpLottieWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(all_caught_up, height: 150);
  }
}

class EmptySearchWidget extends StatelessWidget {
  const EmptySearchWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset(ic_empty_search, height: 100);
  }
}