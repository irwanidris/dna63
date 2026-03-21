import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/forums/components/topic_reply_component.dart';
import 'package:socialv/screens/forums/screens/topic_detail_screen.dart';
import 'package:socialv/screens/profile/screens/member_profile_screen.dart';
import 'package:socialv/store/profile_menu_store.dart';

class ForumRepliesComponent extends StatefulWidget {
  const ForumRepliesComponent({Key? key}) : super(key: key);

  @override
  State<ForumRepliesComponent> createState() => _ForumRepliesComponentState();
}

class _ForumRepliesComponentState extends State<ForumRepliesComponent> {
  int mPage = 1;
  bool mIsLastPage = false;

  ProfileMenuStore forumRepliesComponentVars = ProfileMenuStore();

  @override
  void initState() {
    super.initState();
    getList();
  }

  Future<void> getList() async {
    forumRepliesComponentVars.setLoading(true);
    if (mPage == 1) forumRepliesComponentVars.repliesList.clear();

    await forumRepliesList(
      page: mPage,
      topicRepliesList: forumRepliesComponentVars.repliesList,
      lastPageCallback: (p0) {
        mIsLastPage = p0;
      },
    ).then((value) {
      forumRepliesComponentVars.setLoading(false);
    }).catchError((e) {
      forumRepliesComponentVars.isError = true;
      toast(e.toString());
      forumRepliesComponentVars.setLoading(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Observer(builder: (_) {
          return forumRepliesComponentVars.repliesList.isNotEmpty && !forumRepliesComponentVars.isError
              ? AnimatedListView(
                  slideConfiguration: SlideConfiguration(
                    delay: 80.milliseconds,
                    verticalOffset: 300,
                  ),
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.only(left: 16, right: 16, bottom: 50, top: 16),
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        TopicDetailScreen(topicId: forumRepliesComponentVars.repliesList[index].topicId.validate()).launch(context);
                      },
                      child: TopicReplyComponent(
                        reply: forumRepliesComponentVars.repliesList[index],
                        showReply: false,
                        isParent: true,
                        callback: () {
                          MemberProfileScreen(
                            memberId: forumRepliesComponentVars.repliesList[index].createdById.validate().toInt(),
                          ).launch(context);
                        },
                      ),
                    );
                  },
                  itemCount: forumRepliesComponentVars.repliesList.length,
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

        ///Loading Widget
        Observer(builder: (_) {
          return Positioned(bottom: mPage != 1 ? 10 : null, child: LoadingWidget(isBlurBackground: false).center().visible(forumRepliesComponentVars.isLoading));
        }),

        ///Error Widget
        Observer(builder: (_) {
          return NoDataWidget(
            imageWidget: NoDataLottieWidget(),
            title: language.somethingWentWrong,
            onRetry: () {
              mPage = 1;
              getList();
            },
            retryText: '   ${language.clickToRefresh}   ',
          ).center().visible(!forumRepliesComponentVars.isLoading && forumRepliesComponentVars.isError);
        }),

        ///No Data Widget
        Observer(builder: (_) {
          return NoDataWidget(
            imageWidget: NoDataLottieWidget(),
            title: language.noDataFound,
            onRetry: () {
              mPage = 1;
              getList();
            },
            retryText: '   ${language.clickToRefresh}   ',
          ).center().visible(!forumRepliesComponentVars.isLoading && !forumRepliesComponentVars.isError && forumRepliesComponentVars.repliesList.isEmpty);
        }),
      ],
    );
  }
}
