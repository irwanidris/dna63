import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/blockReport/components/block_member_dialog.dart';
import 'package:socialv/screens/blockReport/components/show_report_dialog.dart';
import 'package:socialv/screens/gamipress/screens/rewards_screen.dart';
// TEMP DISABLED: import 'package:socialv/screens/groups/screens/group_screen.dart';
import 'package:socialv/screens/membership/screens/membership_plans_screen.dart';
import 'package:socialv/screens/post/components/post_component.dart';
import 'package:socialv/screens/profile/components/profile_header_component.dart';
import 'package:socialv/screens/profile/components/request_follow_widget.dart';
import 'package:socialv/screens/profile/screens/member_friends_screen.dart';
import 'package:socialv/screens/profile/screens/personal_info_screen.dart';
import 'package:socialv/screens/settings/screens/settings_screen.dart';
import 'package:socialv/screens/stories/component/story_highlights_component.dart';
import 'package:socialv/store/fragment_store/profile_fragment_store.dart';

import '../../../utils/app_constants.dart';
import '../../gallery/screens/gallery_screen.dart';

class MemberProfileScreen extends StatefulWidget {
  final int memberId;

  MemberProfileScreen({required this.memberId});

  @override
  State<MemberProfileScreen> createState() => _MemberProfileScreenState();
}

class _MemberProfileScreenState extends State<MemberProfileScreen> {
  ScrollController _scrollController = ScrollController();
  ProfileFragStore memberProfileScreenVars = ProfileFragStore();
  int mPage = 1;
  bool isCallback = false;
  bool mIsLastPage = false;
  bool hasInfo = false;

  @override
  void initState() {
    init(showLoader: true);
    setStatusBarColor(Colors.transparent);
    super.initState();
  }

  void init({bool showLoader = false}) async {
    appStore.setLoading(showLoader);
    await getMemberDetail(userId: widget.memberId).then((value) async {
      memberProfileScreenVars.member = value;
      memberProfileScreenVars.hasInfo = memberProfileScreenVars.member!.profileInfo.validate().any((element) => element.fields.validate().any((el) => el.value.validate().isNotEmpty));
      hasInfo = memberProfileScreenVars.member!.profileInfo.validate().any((element) => element.fields.validate().any((el) => el.value.validate().isNotEmpty));

      memberProfileScreenVars.showDetails = widget.memberId.toInt() == userStore.loginUserId.toInt();

      if (!memberProfileScreenVars.showDetails) {
        if (memberProfileScreenVars.member!.accountType.validate() == AccountType.private) {
          memberProfileScreenVars.showDetails = !(memberProfileScreenVars.member!.blockedByMe.validate() || memberProfileScreenVars.member!.blockedBy.validate());
          if (memberProfileScreenVars.showDetails) {
            memberProfileScreenVars.showDetails = (memberProfileScreenVars.member!.friendshipStatus.validate() == Friendship.isFriend || memberProfileScreenVars.member!.friendshipStatus.validate() == Friendship.currentUser);
          }
        } else {
          memberProfileScreenVars.showDetails = !(memberProfileScreenVars.member!.blockedByMe.validate() || memberProfileScreenVars.member!.blockedBy.validate());
        }
      }

      memberProfileScreenVars.memberPostList.addAll(memberProfileScreenVars.member!.postList.validate());
      mIsLastPage = memberProfileScreenVars.member!.postList.validate().length != PER_PAGE;
      memberProfileScreenVars.isError = false;
      appStore.setLoading(false);
    }).catchError((e) {
      memberProfileScreenVars.isError = true;
      memberProfileScreenVars.errorMSG = e.toString();
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  Future<void> getPostList({bool showLoader = true, int page = 1}) async {
    if (mIsLastPage) return;
    appStore.setLoading(showLoader);
    await getPost(
      type: memberProfileScreenVars.isFavorites ? PostRequestType.favorites : PostRequestType.timeline,
      page: page,
      postList: memberProfileScreenVars.memberPostList,
      userId: widget.memberId,
      lastPageCallback: (p0) {
        mIsLastPage = p0;
      },
    ).then((value) {
      if (value.length < PER_PAGE) mIsLastPage = true;
      appStore.setLoading(false);
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  Future<void> onRefresh() async {
    mPage = 1;
    memberProfileScreenVars.memberPostList.clear();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          appStore.setLoading(false);
          finish(context, isCallback);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(language.profile, style: boldTextStyle(size: 20)),
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: context.iconColor),
            onPressed: () {
              finish(context);
            },
          ),
          actions: [
            Observer(
              builder: (context) => !appStore.isLoading && memberProfileScreenVars.showDetails && widget.memberId.toString() != userStore.loginUserId && memberProfileScreenVars.member != null
                  ? Theme(
                      data: Theme.of(context).copyWith(),
                      child: PopupMenuButton(
                        enabled: !appStore.isLoading,
                        position: PopupMenuPosition.under,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(commonRadius)),
                        onSelected: (val) async {
                          if (val == 1 && widget.memberId.toString() != userStore.loginUserId) {
                            PersonalInfoScreen(profileInfo: memberProfileScreenVars.member!.profileInfo.validate(), hasUserInfo: memberProfileScreenVars.hasInfo).launch(context);
                          } else if (val == 2) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return BlockMemberDialog(
                                  mentionName: memberProfileScreenVars.member!.mentionName.validate(),
                                  id: memberProfileScreenVars.member!.id.validate().toInt(),
                                  callback: () {
                                    init(showLoader: true);
                                  },
                                );
                              },
                            ).then((value) {});
                          } else {
                            await showModalBottomSheet(
                              context: context,
                              elevation: 0,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) {
                                return FractionallySizedBox(
                                  heightFactor: 0.80,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 45,
                                        height: 5,
                                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colors.white),
                                      ),
                                      8.height,
                                      Container(
                                        decoration: BoxDecoration(
                                          color: context.cardColor,
                                          borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                                        ),
                                        child: ShowReportDialog(isPostReport: false, userId: widget.memberId),
                                      ).expand(),
                                    ],
                                  ),
                                );
                              },
                            );
                          }
                        },
                        icon: Icon(Icons.more_horiz),
                        itemBuilder: (context) => <PopupMenuEntry>[
                          PopupMenuItem(
                            value: 1,
                            child: Row(
                              children: [
                                Icon(Icons.info_outline_rounded, color: context.iconColor, size: 20),
                                8.width,
                                Text(language.about, style: primaryTextStyle()),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 2,
                            child: Row(
                              children: [
                                Icon(Icons.block, color: context.iconColor, size: 20),
                                8.width,
                                Text(language.block, style: primaryTextStyle()),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 3,
                            child: Row(
                              children: [
                                Icon(Icons.report_gmailerrorred, color: context.iconColor, size: 20),
                                8.width,
                                Text(language.report, style: primaryTextStyle()),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  : Offstage(),
            ),
            IconButton(
              onPressed: () {
                SettingsScreen().launch(context).then((value) {
                  if (value ?? false) init(showLoader: true);
                });
              },
              icon: Image.asset(
                ic_setting,
                height: 20,
                width: 20,
                fit: BoxFit.cover,
                color: context.primaryColor,
              ),
            ).visible(widget.memberId.toString() == userStore.loginUserId),
          ],
        ),
        body: SafeArea(
          child: Stack(
            children: [
              AnimatedScrollView(
                listAnimationType: ListAnimationType.None,
                padding: EdgeInsets.only(bottom: mIsLastPage ? context.height() / 2 : 50),
                controller: _scrollController,
                physics: AlwaysScrollableScrollPhysics(),
                onSwipeRefresh: onRefresh,
                onNextPage: () {
                  print("mIsLastPage$mIsLastPage");
                  if (!mIsLastPage) {
                    mPage++;
                    getPostList(showLoader: true, page: mPage);
                  }
                },
                children: [
                  AnimatedScrollView(children: [
                    // error Widget
                    Observer(builder: (context) {
                      return SizedBox(
                        height: context.height() * 0.4,
                        child: NoDataWidget(
                          imageWidget: NoDataLottieWidget(),
                          title: jsonEncode(memberProfileScreenVars.errorMSG),
                          onRetry: () {
                            LiveStream().emit(OnAddPost);
                          },
                          retryText: '   ${language.clickToRefresh}   ',
                        ).center(),
                      ).visible(memberProfileScreenVars.isError && !appStore.isLoading);
                    }),

                    /// list Widget

                    Observer(builder: (context) {
                      return memberProfileScreenVars.member != null && !memberProfileScreenVars.isError
                          ? Column(
                              children: [
                                ProfileHeaderComponent(
                                  avatarUrl: memberProfileScreenVars.member!.blockedBy.validate() ? AppImages.defaultAvatarUrl : memberProfileScreenVars.member!.memberAvatarImage.validate(),
                                  cover: memberProfileScreenVars.member!.blockedBy.validate() ? null : memberProfileScreenVars.member!.memberCoverImage.validate(),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          memberProfileScreenVars.member!.blockedBy.validate() ? language.userNotFound : memberProfileScreenVars.member!.name.validate(),
                                          style: boldTextStyle(size: 20),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ).flexible(flex: 1),
                                        if (memberProfileScreenVars.member!.isUserVerified.validate() && !memberProfileScreenVars.member!.blockedBy.validate())
                                          Image.asset(ic_tick_filled, width: 18, height: 18, color: blueTickColor).paddingSymmetric(horizontal: 4),
                                      ],
                                    ),
                                   // 4.height,
                              /*      TextIcon(
                                      edgeInsets: EdgeInsets.zero,
                                      spacing: 0,
                                      onTap: () {
                                        PersonalInfoScreen(profileInfo: memberProfileScreenVars.member!.profileInfo.validate(), hasUserInfo: hasInfo).launch(context);
                                      },
                                      text: memberProfileScreenVars.member!.mentionName.validate(),
                                      textStyle: secondaryTextStyle(),
                                      suffix: SizedBox(
                                        height: 26,
                                        width: 26,
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          onPressed: () {
                                            PersonalInfoScreen(profileInfo: memberProfileScreenVars.member!.profileInfo.validate(), hasUserInfo: hasInfo).launch(context);
                                          },
                                          icon: Icon(Icons.info_outline_rounded),
                                          iconSize: 18,
                                          splashRadius: 1,
                                        ),
                                      ),
                                    ),*/
                                  ],
                                ).paddingSymmetric(vertical: 8),

                                /// Request Friend
                                Observer(builder: (context) {
                                  return !appStore.isLoading && !memberProfileScreenVars.member!.blockedBy.validate() && widget.memberId.toString() != userStore.loginUserId
                                      ? RequestFollowWidget(
                                          userMentionName: memberProfileScreenVars.member!.mentionName.validate(),
                                          userName: memberProfileScreenVars.member!.name.validate(),
                                          memberId: memberProfileScreenVars.member!.id.validate().toInt(),
                                          friendshipStatus: memberProfileScreenVars.member!.friendshipStatus.validate(),
                                          callback: () {
                                            isCallback = true;
                                            init();
                                          },
                                          isBlockedByMe: memberProfileScreenVars.member!.blockedByMe.validate(),
                                        ).paddingSymmetric(vertical: 6)
                                      : Offstage();
                                }),
                                Observer(builder: (context) {
                                  return Row(
                                    children: [
                                      if (appStore.displayPostCount == 1)
                                        Column(
                                          children: [
                                            Text(memberProfileScreenVars.member!.postCount.validate().toString(), style: boldTextStyle(size: 18)),
                                            4.height,
                                            Text(language.posts, style: secondaryTextStyle(size: 12)),
                                          ],
                                        ).onTap(
                                          () {
                                            _scrollController.animateTo(context.height() * 0.35, duration: const Duration(milliseconds: 500), curve: Curves.linear);
                                          },
                                          splashColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                        ).expand(),
                                      Column(
                                        children: [
                                          Text(memberProfileScreenVars.member!.friendsCount.validate().toString(), style: boldTextStyle(size: 18)),
                                          4.height,
                                          Text(language.friends, style: secondaryTextStyle(size: 12)),
                                        ],
                                      ).onTap(() {
                                        if (memberProfileScreenVars.showDetails && memberProfileScreenVars.member!.accountType != "private") {
                                          if (pmpStore.memberDirectory) {
                                            log(memberProfileScreenVars.member!.id.toInt());
                                            MemberFriendsScreen(memberId: memberProfileScreenVars.member!.id.toInt()).launch(context);
                                          } else {
                                            MembershipPlansScreen().launch(context);
                                          }
                                        }
                                      }, splashColor: Colors.transparent, highlightColor: Colors.transparent).expand(),
                                      Column(
                                        children: [
                                          Text(memberProfileScreenVars.member!.groupsCount.validate().toString(), style: boldTextStyle(size: 18)),
                                          4.height,
                                          Text(language.groups, style: secondaryTextStyle(size: 12)),
                                        ],
                                      ).onTap(() {
                                        if (memberProfileScreenVars.showDetails && memberProfileScreenVars.member!.accountType != "private") {
                                          if (pmpStore.viewGroups) {
                                            GroupScreen(userId: memberProfileScreenVars.member!.id.validate().toInt(), type: GroupRequestType.userGroup).launch(context);
                                          } else {
                                            MembershipPlansScreen().launch(context);
                                          }
                                        }
                                      }, splashColor: Colors.transparent, highlightColor: Colors.transparent).expand(),
                                    ],
                                  ).paddingSymmetric(vertical: 16);
                                }),
                                8.height,

                                if (memberProfileScreenVars.showDetails && appStore.showStoryHighlight)
                                  StoryHighlightsComponent(
                                    showAddOption: memberProfileScreenVars.member!.id.validate() == userStore.loginUserId,
                                    avatarImage: memberProfileScreenVars.member!.memberAvatarImage.validate(),
                                    highlightsList: memberProfileScreenVars.member!.highlightStory.validate(),
                                    callback: () {
                                      onRefresh();
                                    },
                                  ),

                                Observer(builder: (context) {
                                  return memberProfileScreenVars.showDetails && memberProfileScreenVars.member!.accountType == "private"
                                      ? userStore.loginUserId == memberProfileScreenVars.member!.id
                                          ? Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                              children: [
                                                TextIcon(
                                                  onTap: () {
                                                    GalleryScreen(userId: memberProfileScreenVars.member!.id.toInt(), canEdit: true).launch(context);
                                                  },
                                                  text: language.viewGallery,
                                                  textStyle: primaryTextStyle(color: appColorPrimary),
                                                  prefix: Image.asset(ic_image, width: 18, height: 18, color: appColorPrimary),
                                                ),
                                                if (appStore.showGamiPress && appStore.isGamiPressEnable)
                                                  TextIcon(
                                                    onTap: () {
                                                      RewardsScreen(userID: memberProfileScreenVars.member!.id.toInt()).launch(context);
                                                    },
                                                    text: language.viewRewards,
                                                    textStyle: primaryTextStyle(color: appColorPrimary),
                                                    prefix: Image.asset(ic_badge, width: 18, height: 18, color: appColorPrimary),
                                                  ),
                                              ],
                                            ).paddingTop(16)
                                          : Offstage()
                                      : Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            TextIcon(
                                              onTap: () {
                                                GalleryScreen(userId: memberProfileScreenVars.member!.id.toInt(), canEdit: false).launch(context);
                                              },
                                              text: language.viewGallery,
                                              textStyle: primaryTextStyle(color: appColorPrimary),
                                              prefix: Image.asset(ic_image, width: 18, height: 18, color: appColorPrimary),
                                            ),
                                            if (appStore.showGamiPress)
                                              TextIcon(
                                                onTap: () {
                                                  RewardsScreen(userID: memberProfileScreenVars.member!.id.toInt()).launch(context);
                                                },
                                                text: language.viewRewards,
                                                textStyle: primaryTextStyle(color: appColorPrimary),
                                                prefix: Image.asset(ic_badge, width: 18, height: 18, color: appColorPrimary),
                                              ),
                                          ],
                                        ).paddingTop(16);
                                }),
                                if (memberProfileScreenVars.showDetails) ...[
                                  Observer(builder: (context) {
                                    return memberProfileScreenVars.memberPostList.isEmpty
                                        ? SizedBox(
                                            height: context.height() * 0.4,
                                            child: NoDataWidget(
                                              imageWidget: NoDataLottieWidget(),
                                              title: language.noDataFound,
                                              onRetry: () {
                                                getPostList();
                                              },
                                              retryText: '   ${language.clickToRefresh}   ',
                                            ),
                                          ).center()
                                        : Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(language.posts, style: boldTextStyle(color: appColorPrimary)).paddingSymmetric(horizontal: 16),
                                                  TextIcon(
                                                    onTap: () {
                                                      memberProfileScreenVars.isFavorites = !memberProfileScreenVars.isFavorites;
                                                      mPage = 1;
                                                      getPostList();
                                                    },
                                                    prefix: Image.asset(memberProfileScreenVars.isFavorites ? ic_star_filled : ic_star, width: 18, height: 18, color: appColorPrimary),
                                                    text: language.favorites,
                                                    textStyle: secondaryTextStyle(color: memberProfileScreenVars.isFavorites ? context.primaryColor : null),
                                                  ).paddingSymmetric(horizontal: 8),
                                                ],
                                              ).visible(memberProfileScreenVars.member!.postCount.validate() != 0).paddingSymmetric(vertical: 8),
                                              AnimatedListView(
                                                itemCount: memberProfileScreenVars.memberPostList.length,
                                                slideConfiguration: SlideConfiguration(delay: 80.milliseconds, verticalOffset: 300),
                                                itemBuilder: (context, index) {
                                                  return PostComponent(
                                                    fromProfile: true,
                                                    post: memberProfileScreenVars.memberPostList[index],
                                                    callback: () {
                                                      onRefresh();
                                                    },
                                                    commentCallback: () {
                                                      mPage = 1;
                                                      getPostList();
                                                    },
                                                    fromFavourites: widget.memberId.toString() == userStore.loginUserId && memberProfileScreenVars.isFavorites,
                                                  ).paddingSymmetric(horizontal: 8);
                                                },
                                                shrinkWrap: true,
                                                physics: NeverScrollableScrollPhysics(),
                                              ),
                                            ],
                                          ).paddingSymmetric(vertical: 16);
                                  }).visible(memberProfileScreenVars.member!.accountType != "private")
                                ],
                                16.height,

                                Observer(builder: (context) {
                                  return memberProfileScreenVars.member!.accountType == "private"
                                      ? Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(border: Border.all(), shape: BoxShape.circle),
                                              padding: EdgeInsets.all(8),
                                              child: Image.asset(ic_lock, height: 24, width: 24, color: context.iconColor),
                                            ),
                                            14.height,
                                            Text(language.thisAccountIsPrivate, style: boldTextStyle()),
                                            5.height,
                                            Text(
                                              language.followThisAccountText,
                                              style: secondaryTextStyle(),
                                              textAlign: TextAlign.center,
                                            ).paddingSymmetric(horizontal: 16),
                                          ],
                                        )
                                      : Offstage();
                                }),
                              ],
                            )
                          : Offstage();
                    }),

                    /// Empty widget
                    Observer(
                        warnWhenNoObservables: false,
                        builder: (context) {
                          return memberProfileScreenVars.member == null && !memberProfileScreenVars.isError
                              ? NoDataWidget(
                                  imageWidget: NoDataLottieWidget(),
                                  title: language.noDataFound,
                                  retryText: '   ${language.clickToRefresh}   ',
                                ).center().visible(!appStore.isLoading)
                              : Offstage();
                        }),
                  ]),
                ],
              ),

              ///More data loading widget
              Observer(
                builder: (context) => Positioned(
                  child: ThreeBounceLoadingWidget().paddingTop(16),
                  bottom: 16,
                  left: 0,
                  right: 0,
                ).visible(appStore.isLoading && mPage > 1),
              ),

              ///Initial Loading widget
              Observer(builder: (context) {
                return LoadingWidget().center().visible(appStore.isLoading && mPage == 1);
              }),
            ],
          ),
        ),
      ),
    );
  }
}
