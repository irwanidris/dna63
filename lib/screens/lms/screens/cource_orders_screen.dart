import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/main.dart';
import 'package:socialv/network/lms_rest_apis.dart';
import 'package:socialv/screens/lms/screens/lms_order_screen.dart';
import 'package:socialv/store/profile_menu_store.dart';
import 'package:socialv/utils/app_constants.dart';

import '../../../components/loading_widget.dart';
import '../../../components/no_data_lottie_widget.dart';
import '../../../models/lms/course_orders.dart';
import '../../../models/lms/lms_order_model.dart';
import '../components/course_orders_card_component.dart';

class CourseOrdersScreen extends StatefulWidget {
  const CourseOrdersScreen({Key? key}) : super(key: key);

  @override
  State<CourseOrdersScreen> createState() => _CourseOrdersScreenState();
}

class _CourseOrdersScreenState extends State<CourseOrdersScreen> {
  late LmsOrderModel orderDetail;
  List<CourseOrders> courseOrdersList = [];
  ProfileMenuStore commonVars = ProfileMenuStore();

  ScrollController scrollController = ScrollController();
  int mPage = 1;

  bool mIsLastPage = false;
  bool loaderPosition = false;

  @override
  void initState() {
    super.initState();
    init();
    afterBuildCreated(
      () {
        scrollController.addListener(
          () {
            if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
              if (!mIsLastPage) {
                mPage++;
                init();
              }
            }
          },
        );
      },
    );
  }

  void init() async {
    getCourseOrders();
  }

  Future<List<CourseOrders>> getCourseOrders() async {
    appStore.setLoading(true);
    commonVars.isError = false;
    if (mPage == 1) courseOrdersList.clear();
    await courseOrders(page: mPage).then((value) {
      courseOrdersList.addAll(value);
      mIsLastPage = value.length != PER_PAGE;
      appStore.setLoading(false);
    }).catchError((e) {
      toast(e.toString(), print: true);
      commonVars.isError = true;
      appStore.setLoading(false);
    });
    return courseOrdersList;
  }

  Future<void> orderDetails({required int id}) async {
    appStore.setLoading(true);
    commonVars.isError = false;
    await getOrderDetails(id: id).then((value) {
      orderDetail = value;
      appStore.setLoading(false);
      LmsOrderScreen(orderDetail: orderDetail).launch(context).then((value) {
        loaderPosition = value ?? false;
      });
    }).catchError((e) {
      commonVars.isError = true;
      toast(e.toString(), print: true);
      appStore.setLoading(false);
    });
  }

  @override
  void dispose() {
    if (appStore.isLoading) appStore.setLoading(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          language.courseOrders,
          style: boldTextStyle(size: 20),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.iconColor),
          onPressed: () {
            finish(context);
          },
        ),
      ),
      body: Stack(
        children: [
          ///Error widget
          Observer(builder: (_) {
            return SizedBox(
              height: context.height() * 0.8,
              child: NoDataWidget(
                imageWidget: NoDataLottieWidget(),
                title: language.somethingWentWrong,
                onRetry: () {
                  init();
                },
                retryText: '   ${language.clickToRefresh}   ',
              ).center(),
            ).visible(!appStore.isLoading && commonVars.isError);
          }),

          ///No data widget
          Observer(builder: (_) {
            return SizedBox(
              height: context.height() * 0.8,
              child: NoDataWidget(
                imageWidget: NoDataLottieWidget(),
                title: language.noDataFound,
                onRetry: () {
                  init();
                },
                retryText: '   ${language.clickToRefresh}   ',
              ).center(),
            ).visible(!appStore.isLoading && !commonVars.isError && courseOrdersList.isEmpty);
          }),

          ///Loading Widget
          Observer(builder: (_) {
            return LoadingWidget().visible(appStore.isLoading).center();
          }),
          Observer(builder: (_) {
            return AnimatedListView(
              controller: scrollController,
              padding: EdgeInsets.only(bottom: mIsLastPage ? 16 : 60, left: 16, right: 16, top: 16),
              itemCount: courseOrdersList.length,
              shrinkWrap: true,
              slideConfiguration: SlideConfiguration(delay: 80.milliseconds, verticalOffset: 300),
              itemBuilder: (p0, index) {
                CourseOrders data = courseOrdersList[index];
                return CourseOrderCardComponent(
                  data: data,
                  onTap: (id) {
                    loaderPosition = true;
                    orderDetails(id: id);
                  },
                );
              },
            ).visible(!appStore.isLoading && !commonVars.isError);
          }),
        ],
      ),
    );
  }
}
