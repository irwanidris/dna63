import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/notifications/notification_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/notification/components/notification_widget.dart';
import 'package:socialv/store/fragment_store/notification_fragment_store.dart';
import 'package:socialv/utils/cached_network_image.dart';

import '../../utils/app_constants.dart';

class NotificationFragment extends StatefulWidget {
  final ScrollController controller;

  const NotificationFragment({required this.controller});

  @override
  State<NotificationFragment> createState() => _NotificationFragmentState();
}

class _NotificationFragmentState extends State<NotificationFragment> {
  NotificationFragStore notificationFragStore = NotificationFragStore();
  Future<List<NotificationModel>>? future;

  int mPage = 1;
  bool mIsLastPage = false;

  @override
  void initState() {
    init();
    super.initState();

    widget.controller.addListener(() {
      /// pagination
      if (appStore.currentDashboardIndex == 3) {
        if (widget.controller.position.pixels == widget.controller.position.maxScrollExtent) {
          if (!mIsLastPage) {
            onNextPage();
          }
        }
      }
    });

    LiveStream().on(RefreshNotifications, (p0) {
      mPage = 1;
      mIsLastPage = false;
      init();
    });
  }

  Future<void> init({bool showLoader = true, int page = 1}) async {
    appStore.setLoading(showLoader);
    future = await notificationsList(
      page: page,
      notificationList: notificationFragStore.notificationList,
      lastPageCallback: (p0) {
        mIsLastPage = p0;
      },
    ).then((value) {
      notificationFragStore.isError = false;
      appStore.setLoading(false);
      appStore.setNotificationCount(notificationFragStore.notificationList.length);
    }).catchError((e) {
      notificationFragStore.isError = true;
      notificationFragStore.errorMSG = e.toString();
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  Future<void> onNextPage() async {
    mPage++;
    init(page: mPage);
  }

  @override
  void dispose() {
    LiveStream().dispose(RefreshNotifications);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Column(
          children: [
            /// Error Widget
            Observer(builder: (context) {
              return Align(
                alignment: Alignment.center,
                child: SizedBox(
                  height: context.height() * 0.8,
                  width: context.width() - 32,
                  child: NoDataWidget(
                    imageWidget: NoDataLottieWidget(),
                    title: jsonEncode(notificationFragStore.errorMSG),
                    onRetry: () {
                      LiveStream().emit(RefreshNotifications);
                    },
                    retryText: '   ${language.clickToRefresh}   ',
                  ),
                ).center().visible(notificationFragStore.isError),
              );
            }),

            /// No Data Widget
            Observer(builder: (context) {
              return SizedBox(
                height: context.height() * 0.8,
                child: NoDataWidget(
                  imageWidget: NoDataLottieWidget(),
                  title: language.noNotificationsFound,
                  onRetry: () {
                    LiveStream().emit(RefreshNotifications);
                  },
                  retryText: '   ${language.clickToRefresh}   ',
                ).center(),
              ).visible(notificationFragStore.notificationList.isEmpty && !appStore.isLoading && !notificationFragStore.isError);
            }),

            /// list Widget
            Observer(builder: (context) {
              return AnimatedListView(
                itemCount: notificationFragStore.notificationList.validate().length,
                shrinkWrap: true,
                padding: EdgeInsets.only(bottom: 100, top: 48),
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (BuildContext, index) {
                  return Observer(builder: (context) {
                    return Container(
                      color: notificationFragStore.notificationList[index].isNew == 1 ? context.cardColor : context.scaffoldBackgroundColor,
                      child: NotificationWidget(
                        notificationModel: notificationFragStore.notificationList[index],
                        notificationTapCallback: () {
                          clearNotification().then((value) {
                            if (appStore.notificationCount > 0) {
                              appStore.setNotificationCount(appStore.notificationCount - 1);
                            }
                          });
                        },
                        callback: () {
                          init(showLoader: true);
                        },
                      ),
                    );
                  });
                },
              ).visible(!notificationFragStore.isError && notificationFragStore.notificationList.isNotEmpty);
            }),
          ],
        ),

        /// text button Widget
        Observer(builder: (context) {
          return Positioned(
            top: 16,
            right: 16,
            child: TextIcon(
              prefix: cachedImage(ic_delete, color: Colors.red, width: 20, height: 20, fit: BoxFit.cover),
              text: language.clearAll,
              textStyle: primaryTextStyle(color: Colors.red),
              onTap: () async {
                showConfirmDialogCustom(
                  context,
                  primaryColor: appColorPrimary,

                  title: language.areYouSureToClearNotification,
                  onAccept: (s) async {
                    appStore.setLoading(true);
                    await clearNotification().then((value) {
                      appStore.setNotificationCount(0);
                      init(showLoader: true);
                    }).catchError((error) {
                      toast(error.toString());
                      appStore.setLoading(false);
                    });
                  },
                );
              },
            ),
          ).visible(notificationFragStore.notificationList.isNotEmpty);
        }),

        /// loader Widget
        Observer(builder: (context) {
          return Positioned(
            bottom: mPage != 1 ? 10 : null,
            child: LoadingWidget(isBlurBackground: false).paddingTop(mPage == 1 ? context.height() * 0.4 : 0),
          ).visible(appStore.isLoading);
        })
      ],
    );
  }
}
