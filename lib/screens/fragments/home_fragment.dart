import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/home/components/ad_component.dart';
import 'package:socialv/screens/home/components/suggested_user_component.dart';
import 'package:socialv/screens/post/components/post_component.dart';
import 'package:socialv/screens/stories/component/home_story_component.dart';

import '../../utils/app_constants.dart';
import '../home/components/initial_home_component.dart';

class HomeFragment extends StatefulWidget {
  final ScrollController controller;

  const HomeFragment({super.key, required this.controller});

  @override
  State<HomeFragment> createState() => _HomeFragmentState();
}

class _HomeFragmentState extends State<HomeFragment> with SingleTickerProviderStateMixin {
  bool mIsLastPage = false;
  String errorText = "";

  @override
  void initState() {
    init();
    super.initState();
    setStatusBarColorBasedOnTheme();
    widget.controller.addListener(() {
      /// pagination
      if (appStore.currentDashboardIndex == 0) {
        if (widget.controller.position.pixels == widget.controller.position.maxScrollExtent) {
          if (!mIsLastPage) {
            onNextPage();
          }
        }
      }
    });

    LiveStream().on(OnAddPost, (p0) {
      homeFragStore.mHomePage = 1;
      mIsLastPage = false;
      init();
    });
  }

  Future<void> init({bool showLoader = true, int page = 1}) async {
    if (!appStore.isLoggedIn) return;
    appStore.setLoading(showLoader);
    getPost(
      page: page,
      type: PostRequestType.newsFeed,
      postList: homeFragStore.postList,
      userId: userStore.loginUserId.toInt(),
      lastPageCallback: (p0) async {
        mIsLastPage = p0;
      },
    ).then((value) {
      homeFragStore.isError = false;
      appStore.setLoading(false);
      return value;
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
      homeFragStore.isError = true;
      errorText = e.toString();
      throw e;
    });
  }

  Future<void> onNextPage() async {
    homeFragStore.mHomePage++;
    init(page: homeFragStore.mHomePage);
  }

  @override
  void dispose() {
    LiveStream().dispose(OnAddPost);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            HomeStoryComponent(
              callback: () {
                LiveStream().emit(GetUserStories);
              },
            ),
            Column(
              children: [
                // initial empty home Component
                Observer(builder: (context) {
                  return SizedBox(
                    height: context.height() * 0.5,
                    child: InitialHomeComponent().center(),
                  ).visible(homeFragStore.postList.isEmpty && !appStore.isLoading && !homeFragStore.isError);
                }),

                // error Widget
                Observer(builder: (context) {
                  return SizedBox(
                    height: context.height() * 0.5,
                    width: context.width() - 32,
                    child: NoDataWidget(
                      imageWidget: NoDataLottieWidget(),
                      title: errorText,
                      onRetry: () {
                        LiveStream().emit(OnAddPost);
                      },
                      retryText: '   ${language.clickToRefresh}   ',
                    ),
                  ).center().visible(homeFragStore.isError && !appStore.isLoading);
                }),

                // Post list component
                Observer(builder: (context) {
                  return ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: homeFragStore.postList.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          Observer(builder: (context) {
                            return PostComponent(
                              key: ValueKey(index),
                              post: homeFragStore.postList[index],
                              count: 0,
                              callback: () {
                                init(showLoader: false);
                              },
                              commentCallback: () {
                                init(showLoader: false);
                              },
                              showHidePostOption: true,
                            ).paddingSymmetric(horizontal: 8);
                          }),
                          if ((index + 1) % 5 == 0) AdComponent().visible(appStore.showAds),
                          if ((index + 1) == 3)
                            if (pmpStore.pmpEnable)
                              if (pmpStore.memberDirectory) SuggestedUserComponent() else Offstage()
                            else
                              SuggestedUserComponent(),
                        ],
                      );
                    },
                  );
                }),
                if (mIsLastPage) SizedBox(height: 120),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
