import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/base_scaffold_widget.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/lms/course_list_model.dart';
import 'package:socialv/network/lms_rest_apis.dart';
import 'package:socialv/screens/lms/components/course_card_component.dart';
import 'package:socialv/screens/lms/components/empty_mycourse_component.dart';
import 'package:socialv/store/profile_menu_store.dart';

import '../../../models/lms/course_category.dart';
import '../../../utils/app_constants.dart';

// ignore: must_be_immutable
class CourseListScreen extends StatefulWidget {
  bool myCourses;
  int? categoryId;

  CourseListScreen({this.myCourses = false, this.categoryId});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  ProfileMenuStore courseListScreenVars = ProfileMenuStore();
  String status = '';
  int selectedValue = 1;
  bool isFirstLoad = true;
  int mPage = 1;
  bool mIsLastPage = false;

  bool isEmpty = false;

  @override
  void initState() {
    typesOfCourses();
    getCourses();
    super.initState();
  }

  Future<void> typesOfCourses() async {
    courseListScreenVars.setLoading(true);
    courseListScreenVars.isError = false;
    courseListScreenVars.coursesType.clear();
    await getCourseCategory().then((value) {
      courseListScreenVars.coursesType.addAll(value);
      courseListScreenVars.coursesType.insert(0, CourseCategory(name: language.all));
      courseListScreenVars.setLoading(false);
    }).catchError((e) {
      courseListScreenVars.isError = true;
      toast(e.toString());
      courseListScreenVars.setLoading(false);
    });
  }

  

  Future<void> getCourses() async {
    courseListScreenVars.setLoading(true);
    if (mPage == 1) courseListScreenVars.courseList.clear();
  
    try {
      List<CourseListModel> value;
  
      if (widget.myCourses) {
        value = await getCourseList(page: mPage, myCourse: true, status: status);
      } else {
        value = await getCourseList(page: mPage, categoryId: widget.categoryId);
        
      }
  
      mIsLastPage = value.length != PER_PAGE;
      courseListScreenVars.courseList.addAll(value);
    } catch (e) {
      courseListScreenVars.isError = true;
      if (!isFirstLoad) {
        toast(e.toString(), print: true);
        print("Error loading courses: ${e.toString()}");
      }
    } finally {
      courseListScreenVars.setLoading(false);
      isFirstLoad = false;
    }
  }


  Future<void> onRefresh() async {
    courseListScreenVars.isError = false;
    mPage = 1;
    getCourses();
  }

  @override
  void dispose() {
    if (courseListScreenVars.isLoading) courseListScreenVars.setLoading(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: widget.myCourses ? language.myCourses : language.courses,
      actions: [
        if (widget.myCourses)
          Theme(
            data: Theme.of(context).copyWith(),
            child: Observer(builder: (context) {
              return PopupMenuButton(
                enabled: !courseListScreenVars.isLoading,
                position: PopupMenuPosition.under,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(commonRadius)),
                onSelected: (value) async {
                  if (value == 1) {
                    status = '';
                  } else if (value == 2) {
                    status = CourseStatus.inProgress;
                  } else if (value == 3) {
                    status = CourseStatus.passed;
                  } else {
                    status = CourseStatus.failed;
                  }
                  if (selectedValue != value) {
                    onRefresh();
                  } else {
                    //
                  }

                  selectedValue = value.toString().toInt();
                },
                icon: Icon(Icons.more_vert, color: context.iconColor),
                itemBuilder: (context) => <PopupMenuEntry>[
                  PopupMenuItem(
                    value: 1,
                    child: Text(language.all, style: primaryTextStyle()),
                  ),
                  PopupMenuItem(
                    value: 2,
                    child: Text(language.inProgress, style: primaryTextStyle()),
                  ),
                  PopupMenuItem(
                    value: 3,
                    child: Text(language.passed, style: primaryTextStyle()),
                  ),
                  PopupMenuItem(
                    value: 4,
                    child: Text(language.failed, style: primaryTextStyle()),
                  ),
                ],
              );
            }),
          )
        else
          TextButton(
            onPressed: () {
              CourseListScreen(myCourses: true).launch(context);
            },
            child: Text(language.myCourses, style: primaryTextStyle(color: context.primaryColor)),
          ),
      ],
      child: RefreshIndicator(
        onRefresh: () async {
          onRefresh();
        },
        color: appColorPrimary,
        child: AnimatedScrollView(
          children: [
            ///Error widget
            Observer(builder: (_) {
              return NoDataWidget(
                imageWidget: NoDataLottieWidget(),
                title: language.somethingWentWrong,
                onRetry: () {
                  onRefresh();
                },
                retryText: '   ${language.clickToRefresh}   ',
              ).center().visible(courseListScreenVars.isError && !courseListScreenVars.isLoading);
            }),

            ///No Data Widget when my course list is empty

            Observer(builder: (_) {
              return courseListScreenVars.courseList.isEmpty && !courseListScreenVars.isLoading && widget.myCourses
                  ? SizedBox(
                height: context.height() * 0.8,
                child: EmptyMyCourseComponent(status: status,).center(),
              )
                  : Offstage();
            }),

            ///Loading Widget
            Observer(builder: (_)
            {
              return LoadingWidget().visible(courseListScreenVars.isLoading && courseListScreenVars.courseList.isEmpty);
            }),

            AnimatedScrollView(
              children: [
                ///Horizontal Course type
                Observer(builder: (_) {
                  return widget.myCourses
                      ? Offstage()
                      : HorizontalList(
                          itemCount: courseListScreenVars.coursesType.length,
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                          itemBuilder: (context, index) {
                            CourseCategory item = courseListScreenVars.coursesType[index];
                            return Observer(builder: (context) {
                              return Container(
                                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: courseListScreenVars.selectedCourseCategory == index ? context.primaryColor : context.cardColor,
                                  borderRadius: BorderRadius.all(radiusCircular()),
                                ),
                                child: Text(
                                  parseHtmlString(item.name.validate().capitalizeFirstLetter()),
                                  style: boldTextStyle(size: 14, color: courseListScreenVars.selectedCourseCategory == index ? context.cardColor : context.primaryColor),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ).onTap(
                                () {
                                  mPage = 1;
                                  courseListScreenVars.selectedCourseCategory = index;
                                  widget.myCourses = false;
                                  widget.categoryId = item.id;
                                  getCourses();
                                },
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                splashColor: Colors.transparent,
                              );
                            });
                          },
                        ).visible(courseListScreenVars.coursesType.isNotEmpty && !courseListScreenVars.isLoading && !courseListScreenVars.isError);
                }),

                ///List of Courses
                Observer(builder: (_) {
                  return AnimatedListView(
                    slideConfiguration: SlideConfiguration(
                      delay: 80.milliseconds,
                      verticalOffset: 300,
                    ),
                    padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    itemCount: courseListScreenVars.courseList.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      CourseListModel data = courseListScreenVars.courseList[index];
                      return CourseCardComponent(course: data).paddingSymmetric(vertical: 8);
                    },
                    onNextPage: () {
                      if (!mIsLastPage) {
                        mPage++;
                        getCourses();
                      }
                    },
                  ).visible(courseListScreenVars.courseList.isNotEmpty && !courseListScreenVars.isLoading);
                }),

                ///Empty course list widget
                Observer(builder: (_) {
                  return courseListScreenVars.courseList.isEmpty && !courseListScreenVars.isLoading && courseListScreenVars.coursesType.isEmpty
                      ? SizedBox(
                          height: context.height() * 0.8,
                          child: NoDataWidget(
                            imageWidget: NoDataLottieWidget(),
                            title: language.noCoursesFound,
                            onRetry: () {
                              onRefresh();
                            },
                            retryText: '   ${language.clickToRefresh}   ',
                          ).center(),
                        )
                      : Offstage();
                }),
              ],
            )
          ],
        ),
      ),
    );
  }
}
