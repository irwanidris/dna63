import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/forums/forum_model.dart';
import 'package:socialv/models/forums/topic_model.dart';
import 'package:socialv/screens/forums/components/forums_card_component.dart';
import 'package:socialv/screens/forums/components/topic_card_component.dart';
import 'package:socialv/screens/forums/screens/forum_detail_screen.dart';
import 'package:socialv/screens/forums/screens/topic_detail_screen.dart';
import 'package:socialv/store/profile_menu_store.dart';
import 'package:socialv/utils/constants.dart';

import '../../../network/rest_apis.dart';

// ignore: must_be_immutable
class ForumDetailComponent extends StatefulWidget {
  ScrollController scrollCont;
  final String type;
  final int forumId;
  final VoidCallback? callback;

  final bool showOptions;

  final int selectedIndex;

  List<TopicModel> topicList;
  List<ForumModel> forumList;

  ForumDetailComponent({
    required this.type,
    required this.scrollCont,
    this.callback,
    required this.forumId,
    this.showOptions = false,
    this.selectedIndex = 0,
    required this.topicList,
    required this.forumList,
  });

  @override
  State<ForumDetailComponent> createState() => _ForumDetailComponentState();
}

class _ForumDetailComponentState extends State<ForumDetailComponent> with SingleTickerProviderStateMixin {
  ProfileMenuStore forumDetailComponentVars = ProfileMenuStore();
  int mForumPage = 1;
  int mTopicPage = 1;
  bool showOptions = true;
  bool mIsTopicLastPage = false;
  bool mIsSubForumLastPage = false;

  @override
  void initState() {
    super.initState();
    widget.scrollCont.addListener(() {
      if (widget.scrollCont.position.pixels == widget.scrollCont.position.maxScrollExtent) {
        onNextPage();
      }
    });
    init();

    LiveStream().on("test_topic", (p0) {
      init();
    });
  }

  Future<void> init() async {
    showOptions = widget.showOptions;
    forumDetailComponentVars.selectedIndex = widget.selectedIndex;
    forumDetailComponentVars.topicList.addAll(widget.topicList);
    forumDetailComponentVars.forumListData.addAll(widget.forumList);
    widget.topicList.forEach(
      (element) {},
    );
  }

  Future<void> onNextPage() async {
    if (forumDetailComponentVars.selectedIndex == 0) {
      if (!mIsTopicLastPage) {
        mTopicPage++;
        await getForumTopicList(type: widget.type, page: mTopicPage);
      }
    }
    if (forumDetailComponentVars.selectedIndex == 1) {
      if (!mIsSubForumLastPage) {
        mForumPage++;
        await getForumList(page: mForumPage);
      }
    }
  }

  Future<void> getForumTopicList({int page = 1, bool showLoader = true, String type = ''}) async {
    appStore.setLoadingDots(showLoader);
    await getTopicList(
      topicList: forumDetailComponentVars.topicList,
      page: page,
      type: widget.type,
      forumId: widget.forumId.validate(),
      lastPageCallback: (p0) {
        mIsTopicLastPage = p0;
      },
    ).then((value) {
      appStore.setLoadingDots(false);
      return value;
    }).catchError((e) {
      appStore.setLoadingDots(false);
      toast(e.toString(), print: true);
      throw e;
    });
  }

  Future<void> getForumList({bool showLoader = true, int page = 1}) async {
    appStore.setLoadingDots(showLoader);
    await getSubForumList(
      forumId: widget.forumId.validate(),
      page: page,
      forumList: forumDetailComponentVars.forumListData,
      lastPageCallback: (p0) {
        mIsSubForumLastPage = p0;
      },
    ).then((value) async {
      appStore.setLoadingDots(false);
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Observer(builder: (context) {
          return Row(
            mainAxisAlignment: showOptions ? MainAxisAlignment.spaceEvenly : MainAxisAlignment.start,
            children: [
              Text(
                language.topics,
                style: forumDetailComponentVars.selectedIndex == 0 ? boldTextStyle(color: context.primaryColor, size: 18) : primaryTextStyle(color: context.iconColor),
              ).paddingSymmetric(horizontal: 16).onTap(() {
                forumDetailComponentVars.selectedIndex = 0;
              }, splashColor: Colors.transparent, highlightColor: Colors.transparent),
              Text(
                language.forums,
                style: forumDetailComponentVars.selectedIndex == 1 ? boldTextStyle(color: context.primaryColor, size: 18) : primaryTextStyle(color: context.iconColor),
              ).paddingSymmetric(horizontal: 16).visible(showOptions).onTap(() {
                forumDetailComponentVars.selectedIndex = 1;
              }, splashColor: Colors.transparent, highlightColor: Colors.transparent),
            ],
          );
        }),
        Divider().visible(showOptions),
        Observer(
          builder: (context) {
            return forumDetailComponentVars.selectedIndex == 0
                ? Observer(
                    builder: (context) {
                      return widget.topicList.isEmpty && !appStore.isLoading
                          ? NoDataWidget(
                              imageWidget: NoDataLottieWidget(),
                              title: language.noTopicsFound,
                            )
                          : ListView.builder(
                              padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: mIsTopicLastPage ? 80 : 16),
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: widget.topicList.validate().length,
                              itemBuilder: (ctx, index) {
                                return InkWell(
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () {
                                    TopicDetailScreen(topicId: widget.topicList.validate()[index].id.validate()).launch(context).then((value) {
                                      if (value ?? false) {
                                        widget.callback?.call();
                                      }
                                    });
                                  },
                                  child: TopicCardComponent(
                                    topic: widget.topicList.validate()[index],
                                    isFavTab: false,
                                    showForums: false,
                                    callback: () {
                                      init();
                                    },
                                  ),
                                );
                              },
                            );
                    },
                  )
                : Observer(
                    builder: (context) {
                      return forumDetailComponentVars.forumListData.isEmpty
                          ? NoDataWidget(
                              imageWidget: NoDataLottieWidget(),
                              title: language.noForumsFound,
                            )
                          : ListView.builder(
                              padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: mIsSubForumLastPage ? 80 : 16),
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: forumDetailComponentVars.forumListData.validate().length,
                              itemBuilder: (ctx, index) {
                                return InkWell(
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () {
                                    ForumDetailScreen(
                                      type: TopicType.forums,
                                      forumId: forumDetailComponentVars.forumListData[index].id.validate(),
                                      forumTitle: forumDetailComponentVars.forumListData[index].title.validate(),
                                    ).launch(context).then((value) {
                                      widget.callback?.call();
                                    });
                                  },
                                  child: ForumsCardComponent(
                                    title: forumDetailComponentVars.forumListData.validate()[index].title,
                                    topicCount: forumDetailComponentVars.forumListData.validate()[index].topicCount,
                                    postCount: forumDetailComponentVars.forumListData.validate()[index].postCount,
                                    freshness: forumDetailComponentVars.forumListData.validate()[index].freshness,
                                    description: forumDetailComponentVars.forumListData.validate()[index].description,
                                  ),
                                );
                              },
                            );
                    },
                  );
          },
        )
      ],
    );
  }
}
