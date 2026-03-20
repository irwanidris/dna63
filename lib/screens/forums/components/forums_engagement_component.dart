import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/forums/topic_model.dart';
import 'package:socialv/screens/forums/components/topic_card_component.dart';
import 'package:socialv/screens/forums/screens/topic_detail_screen.dart';
import 'package:socialv/store/profile_menu_store.dart';
import 'package:socialv/utils/app_constants.dart';

import '../../../network/rest_apis.dart';

class ForumsEngagementComponent extends StatefulWidget {
  @override
  State<ForumsEngagementComponent> createState() => _ForumsEngagementComponentState();
}

class _ForumsEngagementComponentState extends State<ForumsEngagementComponent> {
  ProfileMenuStore forumsEngagementComponentVars = ProfileMenuStore();
  int mPage = 1;
  bool mIsLastPage = false;

  @override
  void initState() {
    super.initState();
    getList();
  }

  Future<void> getList() async {
    forumsEngagementComponentVars.setLoading(true);
    forumsEngagementComponentVars.topicsEngagementList.clear();

    await getTopicList(
      type: TopicType.engagement,
      page: mPage,
      topicList: forumsEngagementComponentVars.topicsEngagementList,
      lastPageCallback: (p0) {
        mIsLastPage = p0;
      },
    ).then((value) {
      forumsEngagementComponentVars.setLoading(false);
    }).catchError((e) {
      forumsEngagementComponentVars.isError = true;
      toast(e.toString());
      forumsEngagementComponentVars.setLoading(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        height: context.height() * 0.8,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            ///Topics Engagement List
            Observer(builder: (_) {
              return AnimatedListView(
                padding: EdgeInsets.only(left: 16, right: 16, bottom: 50, top: 16),
                itemBuilder: (context, index) {
                  TopicModel topic = forumsEngagementComponentVars.topicsEngagementList[index];
                  return InkWell(
                    onTap: () {
                      TopicDetailScreen(topicId: topic.id.validate()).launch(context);
                    },
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    child: TopicCardComponent(topic: topic, isFavTab: false),
                  );
                },
                itemCount: forumsEngagementComponentVars.topicsEngagementList.length,
                shrinkWrap: true,
                onNextPage: () {
                  if (!mIsLastPage) {
                    mPage++;

                    getList();
                  }
                },
              );
            }),
            Observer(builder: (_) {
              return forumsEngagementComponentVars.isLoading
                  ? Positioned(
                      bottom: mPage != 1 ? 10 : null,
                      child: LoadingWidget(isBlurBackground: false).center(),
                    )
                  : NoDataWidget(
                      imageWidget: NoDataLottieWidget(),
                      title: forumsEngagementComponentVars.isError ? language.somethingWentWrong : language.noDataFound,
                      onRetry: () {
                        mPage = 1;
                        getList();
                      },
                      retryText: '   ${language.clickToRefresh}   ',
                    ).center().visible(forumsEngagementComponentVars.topicsEngagementList.isEmpty);
            })
          ],
        ),
      ),
    );
  }
}
