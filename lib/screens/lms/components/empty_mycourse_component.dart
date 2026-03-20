import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/main.dart';

import '../../../utils/constants.dart';

class EmptyMyCourseComponent extends StatelessWidget {
  final String status;

  const EmptyMyCourseComponent({Key? key, required this.status}) : super(key: key);

  String getMessage() {
    log("status-------------${status}");
    if (status == 'failed') {
      return "Great job! You haven't failed any courses.";
    } else if (status == 'passed') {
      return "No passed courses found. Keep learning and aim for success!";
    } else if (status == 'in-progress') {
      return "No courses are currently in progress. Start learning to see your progress here!";
    } else {
      return "You haven’t enrolled in any courses so far. Explore our course catalog to find training programs tailored for you and start learning today.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/images/book-outline.gif', height: 100, width: 100, fit: BoxFit.cover),
        16.height,
        Text(getMessage(), style: primaryTextStyle(), textAlign: TextAlign.center),
        16.height,
        InkWell(
          onTap: () {
            finish(context);
          },
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(color: context.primaryColor, borderRadius: radius(commonRadius)),
            child: Text(language.viewCourses, style: boldTextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}
