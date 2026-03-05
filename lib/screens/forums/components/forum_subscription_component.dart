import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/forums/forum_model.dart';
import 'package:socialv/models/forums/topic_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/forums/components/forums_card_component.dart';
import 'package:socialv/screens/forums/components/topic_card_component.dart';
import 'package:socialv/screens/forums/screens/forum_detail_screen.dart';
import 'package:socialv/screens/forums/screens/forums_screen.dart';
import 'package:socialv/screens/forums/screens/topic_detail_screen.dart';
import 'package:socialv/screens/forums/screens/topics_screen.dart';
import 'package:socialv/store/profile_menu_store.dart';

class ForumSubscriptionComponent extends StatefulWidget {
  const ForumSubscriptionComponent({Key? key}) : super(key: key);

  @override
  State<ForumSubscriptionComponent> createState() => _ForumSubscriptionComponentState();
}

class _ForumSubscriptionComponentState extends State<ForumSubscriptionComponent> {
  ProfileMenuStore forumSubscriptionComponentVars = ProfileMenuStore();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    await getList();
  }

  Future<void> getList() async {
    forumSubscriptionComponentVars.isError = false;
    forumSubscriptionComponentVars.setLoading(true);
    forumSubscriptionComponentVars.forumList.clear();
    forumSubscriptionComponentVars.topicsSubscriptionList.clear();
    await subscribedList(perPage: 3).then((value) {
      print(value.forums!.length);
      forumSubscriptionComponentVars.forumList.addAll(value.forums.validate());
      forumSubscriptionComponentVars.topicsSubscriptionList.addAll(value.topics.validate());
      forumSubscriptionComponentVars.setLoading(false);
    }).catchError((e) {
      toast(e.toString());
      forumSubscriptionComponentVars.isError = true;
      forumSubscriptionComponentVars.setLoading(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              Observer(builder: (context) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(language.forums, style: boldTextStyle()),
                    Text(language.viewAll, style: primaryTextStyle(color: context.primaryColor)).onTap(() {
                      ForumsScreen().launch(context).then((value) {
                        if (value ?? false) {
                          getList();
                        }
                      });
                    }, splashColor: Colors.transparent, highlightColor: Colors.transparent).visible(forumSubscriptionComponentVars.forumList.validate().length > 2),
                  ],
                ).visible(forumSubscriptionComponentVars.forumList.isNotEmpty && !forumSubscriptionComponentVars.isLoading);
              }),
              Observer(builder: (context) {
                return AnimatedListView(
                  listAnimationType: ListAnimationType.FadeIn,
                  itemCount: forumSubscriptionComponentVars.forumList.take(2).length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (ctx, index) {
                    ForumModel forum = forumSubscriptionComponentVars.forumList[index];
                    return InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () {
                        ForumDetailScreen(
                          forumId: forum.id.validate(),
                          type: forum.type.validate(),
                          forumTitle: forum.title.validate(),
                          isFromSubscription: true,
                        ).launch(context).then((value) {
                          if (value ?? false) {
                            getList();
                          }
                        });
                      },
                      child: ForumsCardComponent(
                        title: forum.title,
                        description: forum.description,
                        postCount: forum.postCount,
                        topicCount: forum.topicCount,
                        freshness: forum.freshness,
                      ),
                    );
                  },
                ).visible(forumSubscriptionComponentVars.forumList.isNotEmpty && !forumSubscriptionComponentVars.isLoading);
              }),
              16.height.visible(forumSubscriptionComponentVars.forumList.isNotEmpty),
              Observer(builder: (context) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(language.topics, style: boldTextStyle()),
                    Text(language.viewAll, style: primaryTextStyle(color: context.primaryColor)).onTap(() {
                      TopicsScreen().launch(context).then((value) {
                        if (value ?? false) {
                          getList();
                        }
                      });
                    }, splashColor: Colors.transparent, highlightColor: Colors.transparent).visible(forumSubscriptionComponentVars.topicsSubscriptionList.validate().length > 2),
                  ],
                ).visible(forumSubscriptionComponentVars.topicsSubscriptionList.isNotEmpty && !forumSubscriptionComponentVars.isLoading);
              }),
              Observer(builder: (context) {
                return AnimatedListView(
                  listAnimationType: ListAnimationType.FadeIn,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: forumSubscriptionComponentVars.topicsSubscriptionList.take(2).length,
                  itemBuilder: (ctx, index) {
                    TopicModel topic = forumSubscriptionComponentVars.topicsSubscriptionList[index];
                    return InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () {
                        TopicDetailScreen(topicId: topic.id.validate()).launch(context).then((value) {
                          if (value ?? false) {
                            getList();
                          }
                        });
                      },
                      child: TopicCardComponent(topic: topic, isFavTab: false, showForums: false),
                    );
                  },
                ).visible(forumSubscriptionComponentVars.topicsSubscriptionList.isNotEmpty && !forumSubscriptionComponentVars.isLoading);
              }),
              50.height,
            ],
          ).paddingSymmetric(horizontal: 16),
        ),
        Observer(
          builder: (_) {
            return forumSubscriptionComponentVars.isLoading
                ? LoadingWidget(isBlurBackground: false).center()
                : NoDataWidget(
                    imageWidget: NoDataLottieWidget(),
                    title: language.noDataFound,
                    onRetry: () {
                      getList();
                    },
                    retryText: '   ${language.clickToRefresh}   ',
                  ).center().visible(forumSubscriptionComponentVars.topicsSubscriptionList.isEmpty && forumSubscriptionComponentVars.forumList.isEmpty);
          },
        )
      ],
    );
  }
}
