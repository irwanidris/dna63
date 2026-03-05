import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/lms/lms_common_models/section.dart';
import 'package:socialv/screens/lms/screens/lesson_screen.dart';
import 'package:socialv/screens/lms/screens/quiz_screen.dart';
import 'package:socialv/utils/app_constants.dart';

class CurriculumTabComponent extends StatefulWidget {
  final List<Section>? sections;
  final bool showCheck;
  final VoidCallback? callback;
  final bool isEnrolled;
  final bool isFree;

  CurriculumTabComponent({
    this.sections, 
    this.showCheck = false, 
    this.callback, 
    required this.isEnrolled,
    this.isFree = false,
  });

  @override
  State<CurriculumTabComponent> createState() => _CurriculumTabComponentState();
}

class _CurriculumTabComponentState extends State<CurriculumTabComponent> {
  bool shouldShowItem(dynamic item) {
    if (widget.isFree) return true;  
    return widget.isEnrolled;  
  }

  bool canAccessItem(dynamic item) {
    if (widget.isFree) return true;  
    return widget.isEnrolled; 
  }

  bool isItemCompleted(dynamic item) {
    return item.status == CourseStatus.completed || 
           item.graduation == CourseStatus.passed || 
           item.graduation == CourseStatus.failed;   
  }

  double calculateCompletionPercentage() {
    int totalItems = 0;
    int completedItems = 0;

    widget.sections?.forEach((section) {
      section.items?.forEach((item) {
        totalItems++;
        if (isItemCompleted(item)) {
          completedItems++;
        }
      });
    });

    return totalItems > 0 ? (completedItems / totalItems) * 100 : 0;
  }

  void updateCourseProgress() {
    if (widget.callback != null) {
      widget.callback!.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isEnrolled && !widget.isFree) {
    return Center(
      child: Text(
              language.pleasePurchaseCourse,
              style: primaryTextStyle(color: Colors.redAccent, size: 16),
              textAlign: TextAlign.center,
            ).paddingAll(16),
        );
      }

    if (widget.sections.validate().isNotEmpty) {
      return ListView.builder(
        padding: EdgeInsets.all(16),
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: widget.sections.validate().length,
        itemBuilder: (ctx, index) {
          Section section = widget.sections.validate()[index];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(section.title.validate(), style: boldTextStyle()),
              16.height,
              Wrap(
                children: section.items.validate().map((e) {
                  int i = section.items.validate().indexOf(e);

                  return InkWell(
                    onTap: () {
                      if (canAccessItem(e)) {
                        if (e.type == CourseType.lp_lesson) {
                          LessonScreen(
                            onLessonComplete: () {
                              e.graduation = CourseStatus.passed;
                              e.status = CourseStatus.completed;
                              setState(() {});
                              updateCourseProgress();
                            },
                            lessonId: e.id.validate(),
                            isEnrolled: widget.isEnrolled,
                            isLocked: e.locked.validate() && !widget.isFree,
                          ).launch(context);
                        } else if (e.type == CourseType.lp_quiz) {
                          QuizScreen(
                            quizId: e.id.validate(),
                            isLocked: e.locked.validate() && !widget.isFree,
                            completeQuiz: (bool val) {
                              if (val) {
                                e.graduation = CourseStatus.passed;
                                e.status = CourseStatus.completed;
                              } else {
                                e.graduation = CourseStatus.failed;
                                e.status = CourseStatus.completed;
                              }
                              setState(() {});
                              updateCourseProgress();
                            },
                          ).launch(context);
                        }
                      } else {
                        toast(language.thisContentIsLocked);
                      }
                    },
                    child: Container(
                      width: context.width(),
                      margin: EdgeInsets.symmetric(vertical: 8),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(color: context.cardColor, borderRadius: radius(commonRadius)),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(color: context.primaryColor.withAlpha(30), shape: BoxShape.circle),
                            child: Text('${i + 1}', style: boldTextStyle(size: 12, color: context.primaryColor)),
                          ),
                          16.width,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (isItemCompleted(e) && widget.showCheck)
                                    Icon(
                                      e.graduation == CourseStatus.passed ? Icons.check_circle : Icons.check_circle_outline,
                                      color: e.graduation == CourseStatus.passed ? Colors.green : Colors.orange,
                                      size: 16
                                    ).paddingRight(8),
                                  Text(
                                    e.title.validate(),
                                    style: primaryTextStyle(),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ).expand(),
                                ],
                              ),
                              if (e.duration.validate().isNotEmpty)
                                Text(
                                  e.duration.validate(),
                                  style: secondaryTextStyle(),
                                ).paddingTop(4),
                            ],
                          ).expand(),
                          if (!widget.isEnrolled && !canAccessItem(e))
                            Icon(
                              Icons.lock,
                              color: appOrangeColor,
                              size: 16,
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              16.height,
            ],
          );
        },
      );
    } else {
      return NoDataWidget(
        imageWidget: NoDataLottieWidget(),
        title: language.noDataFound,
      ).center();
    }
  }
}
