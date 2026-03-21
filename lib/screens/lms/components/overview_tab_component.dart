import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/utils/html_widget.dart';

import '../../../main.dart';

class OverviewTabComponent extends StatelessWidget {
  final String? overviewContent;
  final bool isPurchased;
  final bool isFreeCourse;

  OverviewTabComponent(
      {Key? key,
      this.overviewContent,
      this.isPurchased = false,
      this.isFreeCourse = false});

  @override
  Widget build(BuildContext context) {
    if (overviewContent.validate().isEmpty) {
      return NoDataWidget(
        imageWidget: NoDataLottieWidget(),
        title: language.noDataFound,
      ).center();
    }

    if (isFreeCourse) {
      return HtmlWidget(postContent: overviewContent.validate()).paddingAll(16);
    }
    else{
     return Center(
        child: Text(
          language.pleasePurchaseCourse,
          style: primaryTextStyle(color: Colors.redAccent, size: 16),
          textAlign: TextAlign.center,
        ).paddingAll(16),
      );
    }
  }
}
