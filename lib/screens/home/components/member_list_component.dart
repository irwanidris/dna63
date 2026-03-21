import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/members/member_response.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/profile/screens/member_profile_screen.dart';
import 'package:socialv/store/fragment_store/home_fragment_store.dart';
import 'package:socialv/utils/cached_network_image.dart';

import '../../../utils/app_constants.dart';

class MemberListComponent extends StatefulWidget {
  const MemberListComponent({Key? key}) : super(key: key);

  @override
  State<MemberListComponent> createState() => _MemberListComponentState();
}

class _MemberListComponentState extends State<MemberListComponent> {
  HomeFragStore memberListComponentVars = HomeFragStore();
  ScrollController scrollController = ScrollController();

  int mPage = 1;
  bool mIsLastPage = false;

  @override
  void initState() {
    super.initState();
    getMembersList();
  }

  Future<List<MemberResponse>> getMembersList() async {
    appStore.setLoading(true);

    await getAllMembers(
      page: mPage,
      memberList: memberListComponentVars.memberList,
      lastPageCallback: (p0) {
        mIsLastPage = p0;
      },
    ).then((value) {
      memberListComponentVars.isError = false;
      appStore.setLoading(false);
    }).catchError((e) {
      memberListComponentVars.isError = true;
      appStore.setLoading(false);
      toast(e.toString());
    });
    return memberListComponentVars.memberList;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedScrollView(
          children: [
            /// empty list widget
            Observer(builder: (context) {
              return memberListComponentVars.isError && !appStore.isLoading
                  ? SizedBox(
                      height: context.height() * 0.88,
                      child: NoDataWidget(
                        imageWidget: NoDataLottieWidget(),
                        title: memberListComponentVars.isError ? language.somethingWentWrong : language.noDataFound,
                        onRetry: () {
                          getMembersList();
                        },
                        retryText: '   ${language.clickToRefresh}   ',
                      ).center(),
                    )
                  : Offstage();
            }),

            /// empty widget
            Observer(builder: (context) {
              return memberListComponentVars.memberList.isEmpty && !memberListComponentVars.isError && !appStore.isLoading
                  ? SizedBox(
                      height: context.height() * 0.88,
                      child: NoDataWidget(
                        imageWidget: NoDataLottieWidget(),
                        title: memberListComponentVars.isError ? language.somethingWentWrong : language.noDataFound,
                        onRetry: () {
                          getMembersList();
                        },
                        retryText: '   ${language.clickToRefresh}   ',
                      ).center(),
                    )
                  : Offstage();
            }),

            /// list widget

            Observer(builder: (context) {
              return memberListComponentVars.memberList.isNotEmpty && !memberListComponentVars.isError
                  ? AnimatedListView(
                      shrinkWrap: true,
                      controller: scrollController,
                      physics: NeverScrollableScrollPhysics(),
                      slideConfiguration: SlideConfiguration(delay: 120.milliseconds),
                      padding: EdgeInsets.only(left: 16, right: 16, bottom: 50),
                      itemCount: memberListComponentVars.memberList.length,
                      itemBuilder: (context, index) {
                        MemberResponse member = memberListComponentVars.memberList[index];
                        if (member.id.validate().toString() != userStore.loginUserId)
                          return InkWell(
                            onTap: () {
                              MemberProfileScreen(memberId: member.id.validate()).launch(context);
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                cachedImage(
                                  member.avatarUrls!.full.validate(),
                                  height: 56,
                                  width: 56,
                                  fit: BoxFit.cover,
                                ).cornerRadiusWithClipRRect(100),
                                20.width,
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          member.name.validate(),
                                          style: boldTextStyle(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ).flexible(flex: 1),
                                        if (member.isUserVerified.validate()) Image.asset(ic_tick_filled, width: 18, height: 18, color: blueTickColor).paddingSymmetric(horizontal: 4),
                                      ],
                                    ),
                                    6.height,
                                    Text(
                                      member.mentionName.validate(),
                                      style: secondaryTextStyle(),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ],
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                ).expand(),
                              ],
                            ).paddingSymmetric(vertical: 8),
                          );
                        else
                          return Offstage();
                      },
                      onNextPage: () {
                        log("call the next page ");
                        if (!mIsLastPage) {
                          mPage++;
                          getMembersList();
                        }
                      },
                    )
                  : Offstage();
            })
          ],
        ),
        Positioned(
          bottom: mPage != 1 ? 8 : null,
          width: context.width(),
          child: Observer(builder: (_) => LoadingWidget(isBlurBackground: mPage == 1 ? true : false).visible(appStore.isLoading)),
        ),
      ],
    );
  }
}
