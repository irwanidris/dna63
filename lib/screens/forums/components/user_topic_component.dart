import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/screens/forums/components/topic_card_component.dart';
import 'package:socialv/screens/forums/screens/topic_detail_screen.dart';
import 'package:socialv/store/profile_menu_store.dart';
import 'package:socialv/utils/app_constants.dart';

import '../../../network/rest_apis.dart';

class UserTopicComponent extends StatefulWidget {
  @override
  State<UserTopicComponent> createState() => _UserTopicComponentState();
}

class _UserTopicComponentState extends State<UserTopicComponent> {
  ProfileMenuStore userTopicComponentVars = ProfileMenuStore();
  int mPage = 1;
  bool mIsLastPage = false;

  @override
  void initState() {
    super.initState();
    getList();
  }

  Future<void> getList() async {
    userTopicComponentVars.setLoading(true);
    userTopicComponentVars.isError = false;
    if (mPage == 1) userTopicComponentVars.topicsList.clear();

    await getTopicList(
        type: TopicType.members,
        page: mPage,
        topicList: userTopicComponentVars.topicsList,
        lastPageCallback: (p0) {
          mIsLastPage = p0;
        }).then((value) {
      print(userTopicComponentVars.topicsList.length);
      userTopicComponentVars.setLoading(false);
    }).catchError((e) {
      userTopicComponentVars.isError = true;
      toast(e.toString(), print: true);
      userTopicComponentVars.setLoading(false);
    });
  }

  @override
  void dispose() {
    userTopicComponentVars.setLoading(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        ///Users Topics widget
        Observer(builder: (context) {
          return !userTopicComponentVars.isLoading && !userTopicComponentVars.isError && userTopicComponentVars.topicsList.isNotEmpty
              ? AnimatedListView(
                  padding: EdgeInsets.only(left: 16, right: 16, bottom: 50, top: 16),
                  itemBuilder: (context, index) {
                    final topic = userTopicComponentVars.topicsList[index];
                    return InkWell(
                      onTap: () {
                        TopicDetailScreen(topicId: topic.id.validate()).launch(context);
                      },
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      child: TopicCardComponent(topic: topic, isFavTab: false),
                    );
                  },
                  itemCount: userTopicComponentVars.topicsList.length,
                  shrinkWrap: true,
                  onNextPage: () {
                    if (!mIsLastPage) {
                      mPage++;
                      getList();
                    }
                  },
                )
              : Offstage();
        }),

        ///Loading widget
        Observer(builder: (context) {
          return userTopicComponentVars.isLoading
              ? Positioned(
                  bottom: mPage != 1 ? 10 : null,
                  child: LoadingWidget(isBlurBackground: false).center(),
                )
              : Offstage();
        }),

        ///No Data Widget
        Observer(builder: (context) {
          return userTopicComponentVars.topicsList.isEmpty && !userTopicComponentVars.isLoading && !userTopicComponentVars.isError
              ? NoDataWidget(
                  imageWidget: NoDataLottieWidget(),
                  title: language.noDataFound,
                  onRetry: () {
                    mPage = 1;
                    getList();
                  },
                  retryText: '   ${language.clickToRefresh}   ',
                ).center()
              : Offstage();
        }),

        ///Error Widget
        Observer(builder: (context) {
          return userTopicComponentVars.isError && !userTopicComponentVars.isLoading
              ? NoDataWidget(
                  imageWidget: NoDataLottieWidget(),
                  title: language.somethingWentWrong,
                  onRetry: () {
                    mPage = 1;
                    getList();
                  },
                  retryText: '   ${language.clickToRefresh}   ',
                ).center()
              : Offstage();
        }),
      ],
    );
  }
}
