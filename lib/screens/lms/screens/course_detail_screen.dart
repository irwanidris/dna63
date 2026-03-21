import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/base_scaffold_widget.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/common_models.dart';
import 'package:socialv/network/lms_rest_apis.dart';
import 'package:socialv/screens/lms/components/course_card_component.dart';
import 'package:socialv/screens/lms/components/course_includes_tab_component.dart';
import 'package:socialv/screens/lms/components/curriculam_tab_component.dart';
import 'package:socialv/screens/lms/components/faq_tab_component.dart';
import 'package:socialv/screens/lms/components/instructor_tab_component.dart';
import 'package:socialv/screens/lms/components/overview_tab_component.dart';
import 'package:socialv/screens/lms/components/review_tab_component.dart';
import 'package:socialv/screens/lms/components/start_course_widget.dart';
import 'package:socialv/screens/lms/screens/buy_course_screen.dart';
import 'package:socialv/screens/lms/screens/course_sections_screen.dart';
import 'package:socialv/store/profile_menu_store.dart';
import 'package:socialv/utils/app_constants.dart';

class CourseDetailScreen extends StatefulWidget {
  final int courseId;

  CourseDetailScreen({required this.courseId});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  ProfileMenuStore courseDetailScreenVars = ProfileMenuStore();
  List<DrawerModel> tabsList = getCourseTabs();

  @override
  void initState() {
    courseDetailScreenVars.selectedCourseDetailTabIndex = 0;
    getCourseDetail();
    super.initState();
  }

  Future<void> getCourseDetail({bool isCourseStarted = false}) async {
    appStore.setLoading(true);

    await getCourseById(courseId: widget.courseId).then((value) {
      courseDetailScreenVars.course = value;
      appStore.setLoading(false);
    }).catchError((e) {
      courseDetailScreenVars.isError = true;
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  Widget getTabWidget() {
    if (courseDetailScreenVars.selectedCourseDetailTabIndex == 1) {
      return OverviewTabComponent(overviewContent: courseDetailScreenVars.course!.content,isPurchased: courseDetailScreenVars.course!.price_rendered != 'Free',
  isFreeCourse: courseDetailScreenVars.course!.price_rendered == 'Free');
    } else if (courseDetailScreenVars.selectedCourseDetailTabIndex == 2) {
      return CurriculumTabComponent(
        sections: courseDetailScreenVars.course!.sections,
        isEnrolled: courseDetailScreenVars.course!.course_data!.status == CourseStatus.enrolled,
        isFree: courseDetailScreenVars.course!.price_rendered == 'Free',
        callback: () {
          onRefresh();
        },
      );
    } else if (courseDetailScreenVars.selectedCourseDetailTabIndex == 3) {
      return InstructorTabComponent(instructor: courseDetailScreenVars.course!.instructor);
    } else if (courseDetailScreenVars.selectedCourseDetailTabIndex == 4) {
      return FaqTabComponent(
        faqs: courseDetailScreenVars.course!.meta_data!.lp_faqs.validate(),
      );
    } else if (courseDetailScreenVars.selectedCourseDetailTabIndex == 5) {
      return ReviewTabComponent(courseId: widget.courseId);
    } else {
      return CourseIncludesTabComponent(
        metaData: courseDetailScreenVars.course!.meta_data!,
        courseData: courseDetailScreenVars.course!.course_data!,
        requirements: courseDetailScreenVars.course!.meta_data!.lp_requirements.validate(),
        features: courseDetailScreenVars.course!.meta_data!.lp_key_features.validate(),
        audiences: courseDetailScreenVars.course!.meta_data!.lp_target_audiences.validate(),
      );
    }
  }

  Future<void> onRefresh() async {
    courseDetailScreenVars.isError = false;
    getCourseDetail();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        onRefresh();
      },
      child: AppScaffold(
        onBack: () {
          if (appStore.isLoading) appStore.setLoading(false);
          finish(context);
        },
        appBarTitle: language.courseDetail,
        child: AnimatedScrollView(
          children: [
            Observer(builder: (_) {
              return SizedBox(
                height: context.height() * 0.8,
                child: NoDataWidget(
                  imageWidget: NoDataLottieWidget(),
                  title: courseDetailScreenVars.isError ? language.somethingWentWrong : language.noDataFound,
                  onRetry: () {
                    onRefresh();
                  },
                  retryText: '   ${language.clickToRefresh}   ',
                ),
              ).visible(!appStore.isLoading && courseDetailScreenVars.isError);
            }),
            Observer(builder: (_) {
              return courseDetailScreenVars.course != null && !appStore.isLoading && !courseDetailScreenVars.isError
                  ? SingleChildScrollView(
                      child: Column(
                        children: [
                          CourseCardComponent(course: courseDetailScreenVars.course!).paddingSymmetric(
                            horizontal: 16,
                          ),
                         if (courseDetailScreenVars.course!.course_data!.status == CourseStatus.enrolled)
                           Builder(
                             builder: (context) {
                               final completed = courseDetailScreenVars.course!.course_data!.result?.completed_items.validate() ?? 0;
                               final total = courseDetailScreenVars.course!.course_data!.result?.count_items.validate() ?? 0;
                               final percent = (total > 0) ? (completed / total * 100) : 0.0;
                               final progress = (total > 0) ? (completed / total) : 0.0;

                               return Row(
                                 children: [
                                   Text(
                                     '${language.courseResults}: ${percent.toStringAsFixed(0)}%',
                                     style: boldTextStyle(),
                                   ).paddingSymmetric(horizontal: 16),
                                   SizedBox(
                                     width: context.width() / 3,
                                     height: 14,
                                     child: LinearProgressIndicator(
                                       color: context.primaryColor,
                                       backgroundColor: appStore.isDarkMode ? bodyDark.withValues(alpha: 0.4) : bodyWhite.withValues(alpha: 0.4),
                                       value: progress,
                                       minHeight: 14,
                                     ).cornerRadiusWithClipRRect(defaultRadius),
                                   ),
                                 ],
                               );
                             },
                           ),
                          if (courseDetailScreenVars.course!.course_data!.status == CourseStatus.enrolled)
                            appButton(
                              width: context.width() / 2 - 20,
                              context: context,
                              text: language.lblContinue,
                              onTap: () {
                                CourseSectionsScreen(
                                  sections: courseDetailScreenVars.course!.sections,
                                  isEnrolled: courseDetailScreenVars.course!.course_data!.status == CourseStatus.enrolled,
                                  isFree: courseDetailScreenVars.course!.price_rendered == 'Free',
                                  callback: () {
                                    getCourseDetail(isCourseStarted: true);
                                  },
                                ).launch(context);
                              },
                            ).paddingSymmetric(vertical: 16)
                          else if (courseDetailScreenVars.course!.course_data!.status.validate().isEmpty && courseDetailScreenVars.course!.price_rendered == 'Free')
                            appButton(
                              width: context.width() / 2 - 20,
                              context: context,
                              text: language.startNow,
                              onTap: () {
                                ifNotTester(() {
                                  appStore.setLoading(true);
                                  enrollCourse(courseId: widget.courseId).then((value) async {
                                    log(value);
                                    showDialog(
                                        context: context,
                                        builder: (_) {
                                          return Dialog(
                                            backgroundColor: context.cardColor,
                                            shape: RoundedRectangleBorder(borderRadius: radius()),
                                            child: StartCourseWidget(callback: () {
                                              CourseSectionsScreen(
                                                sections: courseDetailScreenVars.course!.sections,
                                                isEnrolled: courseDetailScreenVars.course!.course_data!.status == CourseStatus.enrolled,
                                                isFree: courseDetailScreenVars.course!.price_rendered == 'Free',
                                                callback: () {
                                                  getCourseDetail();
                                                },
                                              ).launch(context);
                                            }),
                                          );
                                        });
                                    appStore.setLoading(false);
                                    courseDetailScreenVars.course!.course_data!.status = CourseStatus.enrolled;
                                    onRefresh();

                                  }).catchError((e) {
                                    appStore.setLoading(false);
                                    toast(e.toString());
                                  });
                                });
                              },
                            ).paddingSymmetric(vertical: 16)
                          else if (courseDetailScreenVars.course!.can_retake.validate())
                            appButton(
                              width: context.width() / 2 - 20,
                              context: context,
                              text: '${language.retake} (${courseDetailScreenVars.course!.ratake_count.validate() - courseDetailScreenVars.course!.rataken.validate()})',
                              onTap: () {
                                ifNotTester(() {
                                  appStore.setLoading(true);
                                  retakeCourse(courseId: widget.courseId).then((value) {
                                    courseDetailScreenVars.course!.course_data!.status = CourseStatus.enrolled;
                                    onRefresh();
                                    toast(value.message);
                                  }).catchError((e) {
                                    appStore.setLoading(false);

                                    toast(e.toString());
                                  });
                                });
                              },
                            ).paddingSymmetric(vertical: 16)
                          else if (courseDetailScreenVars.course!.course_data!.status.validate().isEmpty && courseDetailScreenVars.course!.price_rendered != 'Free')
                            if (courseDetailScreenVars.course!.in_cart.validate())
                              Container(
                                width: context.width(),
                                margin: EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: appGreenColor.withAlpha(20),
                                  border: Border(left: BorderSide(color: appGreenColor, width: 2)),
                                ),
                                padding: EdgeInsets.all(14),
                                child: Text('${language.yourOrderIsWaitingFor} ${courseDetailScreenVars.course!.order_status.validate()}', style: primaryTextStyle(color: appGreenColor)),
                              )
                            else
                              appButton(
                                width: context.width() / 2 - 20,
                                context: context,
                                text: language.buyNow,
                                onTap: () {
                                  BuyCourseScreen(
                                    courseImage: courseDetailScreenVars.course!.image.validate(),
                                    courseName: courseDetailScreenVars.course!.name.validate(),
                                    coursePriseRendered: courseDetailScreenVars.course!.price_rendered.validate(),
                                    coursePrise: courseDetailScreenVars.course!.price.validate(),
                                    courseId: courseDetailScreenVars.course!.id.validate(),
                                    callback: () {
                                      onRefresh();
                                    },
                                  ).launch(context);
                                },
                              ).paddingSymmetric(vertical: 16)
                          else if (courseDetailScreenVars.course!.course_data!.status.validate() == CourseStatus.finished &&
                              (courseDetailScreenVars.course!.course_data!.graduation == CourseStatus.passed ||
                               courseDetailScreenVars.course!.course_data!.graduation == CourseStatus.failed))
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: courseDetailScreenVars.course!.course_data!.graduation == CourseStatus.passed 
                                  ? blueTickColor.withAlpha(20)
                                  : appOrangeColor.withAlpha(20),
                                border: Border(
                                  left: BorderSide(
                                    color: courseDetailScreenVars.course!.course_data!.graduation == CourseStatus.passed 
                                      ? blueTickColor 
                                      : appOrangeColor,
                                    width: 2
                                  )
                                ),
                              ),
                              child: Text(
                                courseDetailScreenVars.course!.course_data!.graduation == CourseStatus.passed
                                  ? language.youHaveFinishedThisCourse
                                  : language.youHaveCompletedButNotPassed,
                                style: primaryTextStyle(
                                  color: courseDetailScreenVars.course!.course_data!.graduation == CourseStatus.passed 
                                    ? blueTickColor 
                                    : appOrangeColor
                                ),
                              ),
                            )
                          else
                            Offstage(),
                          if (courseDetailScreenVars.course!.can_finish.validate())
                            appButton(
                              width: context.width() / 2 - 20,
                              context: context,
                              text: language.finishCourse,
                              onTap: () {
                                ifNotTester(() {
                                  showConfirmDialogCustom(
                                    context,
                                    onAccept: (c) {
                                      ifNotTester(() {
                                        appStore.setLoading(true);
                                        finishCourse(courseId: courseDetailScreenVars.course!.id.validate()).then((value) {
                                          appStore.setLoading(false);
                                          onRefresh();
                                        }).catchError((e) {
                                          appStore.setLoading(false);
                                          toast(e.toString(), print: true);
                                        });
                                      });
                                    },
                                    dialogType: DialogType.CONFIRMATION,
                                    title: language.finishCourseConfirmation,
                                    positiveText: language.finish,
                                  );
                                });
                              },
                            ),
                          16.height,
                          HorizontalList(
                            itemCount: tabsList.length,
                            itemBuilder: (ctx, index) {
                              DrawerModel tab = tabsList[index];
                              return GestureDetector(
                                onTap: () {
                                  courseDetailScreenVars.selectedCourseDetailTabIndex = index;
                                },
                                child: Observer(builder: (context) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: courseDetailScreenVars.selectedCourseDetailTabIndex == index ? context.primaryColor : context.scaffoldBackgroundColor,
                                      borderRadius: radius(commonRadius),
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                                    child: Text(
                                      tab.title.validate(),
                                      style: boldTextStyle(
                                        color: courseDetailScreenVars.selectedCourseDetailTabIndex == index
                                            ? Colors.white
                                            : appStore.isDarkMode
                                                ? bodyDark
                                                : bodyWhite,
                                        size: 14,
                                      ),
                                    ),
                                  );
                                }),
                              );
                            },
                          ),
                          getTabWidget(),
                        ],
                      ),
                    )
                  : Offstage();
            })
          ],
        ),
      ),
    );
  }
}
