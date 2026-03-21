import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/members/friend_request_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/membership/screens/membership_plans_screen.dart';
import 'package:socialv/screens/profile/screens/member_profile_screen.dart';
import 'package:socialv/store/fragment_store/home_fragment_store.dart';
import 'package:socialv/utils/cached_network_image.dart';

import '../../../utils/app_constants.dart';

class MemberSuggestionListComponent extends StatefulWidget {
  const MemberSuggestionListComponent({Key? key}) : super(key: key);

  @override
  State<MemberSuggestionListComponent> createState() => _MemberSuggestionListComponentState();
}

class _MemberSuggestionListComponentState extends State<MemberSuggestionListComponent> {
  HomeFragStore memberSuggestionListComponentVars = HomeFragStore();
  int mPage = 1;
  bool mIsLastPage = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init({bool showLoader = true, int page = 1}) async {
    appStore.setLoading(showLoader);
    await getSuggestedUserList(
      page: page,
      suggestedUserList: memberSuggestionListComponentVars.suggestedMemberList,
      lastPageCallback: (p0) {
        mIsLastPage = p0;
      },
    ).then((value) {
      memberSuggestionListComponentVars.isError = false;
      appStore.setLoading(false);
    }).catchError((e) {
      memberSuggestionListComponentVars.isError = true;
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedScrollView(
          children: [
            /// error widget
            Observer(builder: (context) {
              return memberSuggestionListComponentVars.isError && !appStore.isLoading
                  ? SizedBox(
                      height: context.height() * 0.88,
                      child: NoDataWidget(
                        imageWidget: NoDataLottieWidget(),
                        title: memberSuggestionListComponentVars.isError ? language.somethingWentWrong : language.noDataFound,
                        onRetry: () {
                          init();
                        },
                        retryText: '   ${language.clickToRefresh}   ',
                      ).center(),
                    )
                  : Offstage();
            }),

            /// empty list
            Observer(builder: (context) {
              return memberSuggestionListComponentVars.suggestedMemberList.isEmpty && !memberSuggestionListComponentVars.isError && !appStore.isLoading
                  ? SizedBox(
                      height: context.height() * 0.88,
                      child: NoDataWidget(
                        imageWidget: NoDataLottieWidget(),
                        title: memberSuggestionListComponentVars.isError ? language.somethingWentWrong : language.noDataFound,
                        onRetry: () {
                          init();
                        },
                        retryText: '   ${language.clickToRefresh}   ',
                      ).center(),
                    )
                  : Offstage();
            }),

            /// list widget
            Observer(builder: (context) {
              return memberSuggestionListComponentVars.suggestedMemberList.isNotEmpty && !memberSuggestionListComponentVars.isError
                  ? AnimatedListView(
                      shrinkWrap: true,
                      disposeScrollController: false,
                      physics: NeverScrollableScrollPhysics(),
                      slideConfiguration: SlideConfiguration(delay: 120.milliseconds),
                      padding: EdgeInsets.only(left: 16, right: 16, bottom: 50),
                      itemCount: memberSuggestionListComponentVars.suggestedMemberList.length,
                      itemBuilder: (context, index) {
                        FriendRequestModel member = memberSuggestionListComponentVars.suggestedMemberList[index];
                        return Observer(builder: (context) {
                          return GestureDetector(
                            onTap: () {
                              MemberProfileScreen(memberId: member.userId.validate()).launch(context);
                            },
                            child: Row(
                              children: [
                                cachedImage(
                                  member.userImage.validate(),
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
                                          member.userName.validate(),
                                          style: boldTextStyle(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ).flexible(flex: 1),
                                        if (member.isUserVerified.validate()) Image.asset(ic_tick_filled, width: 18, height: 18, color: blueTickColor).paddingSymmetric(horizontal: 4),
                                      ],
                                    ),
                                    6.height,
                                    Text(
                                      member.userMentionName.validate(),
                                      style: secondaryTextStyle(),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ],
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                ).expand(),
                                Row(
                                  children: [
                                    InkWell(
                                      child: cachedImage(member.isRequested.validate() ? ic_tick_square : ic_plus, height: 26, width: 26, color: context.primaryColor, fit: BoxFit.cover),
                                      onTap: () async {
                                        ifNotTester(() async {
                                          if (member.isRequested.validate()) {
                                            member.isRequested = !member.isRequested.validate();
                                            await removeExistingFriendConnection(friendId: member.userId.validate().toString(), passRequest: true).then((value) {
                                            }).catchError((e) {
                                              member.isRequested = !member.isRequested.validate();
                                            });
                                          } else {
                                            if (pmpStore.sendFriendRequest) {
                                              member.isRequested = !member.isRequested.validate();
                                              Map request = {"initiator_id": userStore.loginUserId, "friend_id": member.userId.validate()};
                                              await requestNewFriend(request).then((value) async {
                                                memberSuggestionListComponentVars.suggestedMemberList.removeAt(index);
                                                toast(language.requestSuccessfullySent);
                                              }).catchError((e) {
                                                member.isRequested = !member.isRequested.validate();
                                              });
                                            } else {
                                              MembershipPlansScreen().launch(context);
                                            }
                                          }
                                        });
                                      },
                                      splashColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                    ),
                                    4.width,
                                    InkWell(
                                      child: cachedImage(ic_close_square, height: 28, width: 28, color: Colors.red, fit: BoxFit.cover),
                                      onTap: () {
                                        ifNotTester(() async {
                                          memberSuggestionListComponentVars.suggestedMemberList.removeAt(index);
                                          await removeSuggestedUser(userId: member.userId.validate()).then((value) {
                                            toast(language.removeSuggestions);
                                          }).catchError(onError);
                                        });
                                      },
                                      splashColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                    ),
                                  ],
                                )
                              ],
                            ).paddingSymmetric(vertical: 8),
                          );
                        });
                      },
                      onNextPage: () {
                        if (!mIsLastPage) {
                          mPage++;
                          init(page: mPage);
                        }
                      },
                    )
                  : Offstage();
            }),
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
