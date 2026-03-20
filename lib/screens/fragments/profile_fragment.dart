import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/posts/post_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/gamipress/screens/rewards_screen.dart';
import 'package:socialv/screens/groups/screens/group_screen.dart';
import 'package:socialv/screens/membership/screens/membership_plans_screen.dart';
import 'package:socialv/screens/post/components/post_component.dart';
import 'package:socialv/screens/profile/components/profile_header_component.dart';
import 'package:socialv/screens/profile/screens/profile_friends_screen.dart';

import '../../utils/app_constants.dart';
import '../gallery/screens/gallery_screen.dart';
import '../profile/screens/personal_info_screen.dart';
import '../stories/component/story_highlights_component.dart';

class ProfileFragment extends StatefulWidget {
  final ScrollController? controller;

  const ProfileFragment({this.controller});

  @override
  State<ProfileFragment> createState() => _ProfileFragmentState();
}

class _ProfileFragmentState extends State<ProfileFragment> {
  bool mIsLastPage = false;
  bool hasInfo = false;

  @override
  void initState() {
    init(showLoader: true);
    profileFragStore.isFavorites = false;

    setStatusBarColor(Colors.transparent);

    widget.controller?.addListener(() {
      if (appStore.currentDashboardIndex == 4) {
        if (widget.controller?.position.pixels == widget.controller?.position.maxScrollExtent) {
          if (!mIsLastPage) {
            onNextPage();
          }
        }
      }
    });

    LiveStream().on(OnAddPostProfile, (p0) {
      profileFragStore.mProfilePage = 1;
      mIsLastPage = false;
      init();
    });

    super.initState();
  }

  Future<void> init({bool showLoader = true}) async {
    appStore.setLoading(showLoader);
    await getMemberDetail(userId: userStore.loginUserId.toInt()).then((value) async {
      profileFragStore.memberDetails = value;
      profileFragStore.userPostList.clear();
      hasInfo = profileFragStore.memberDetails!.profileInfo.validate().any(
            (element) => element.fields.validate().any(
                  (el) => el.value.validate().isNotEmpty,
                ),
          );
      profileFragStore.userPostList.addAll(value.postList.validate());
      profileFragStore.isError = false;
      appStore.setLoading(false);
    }).catchError((e) {
      profileFragStore.isError = true;
      profileFragStore.errorMSG = e.toString();
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  Future<void> onNextPage() async {
    profileFragStore.mProfilePage++;
  }

  @override
  void dispose() {
    LiveStream().dispose(OnAddPostProfile);
    profileFragStore.mProfilePage = 1;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () {
        return init(showLoader: true);
      },
      child: AnimatedScrollView(
        children: [
          /// Error Widget
          Observer(builder: (context) {
            return SizedBox(
              height: context.height() * 0.8,
              width: context.width() - 32,
              child: NoDataWidget(
                imageWidget: NoDataLottieWidget(),
                title: jsonEncode(profileFragStore.errorMSG),
                onRetry: () {
                  LiveStream().emit(OnAddPostProfile);
                },
                retryText: '   ${language.clickToRefresh}   ',
              ),
            ).center().visible(profileFragStore.isError && !appStore.isLoading);
          }),

          /// Empty Widget
          Observer(
              warnWhenNoObservables: false,
              builder: (context) {
                return SizedBox(
                  height: context.height() * 0.8,
                  child: NoDataWidget(
                    imageWidget: NoDataLottieWidget(),
                    title: language.noDataFound,
                    onRetry: () {
                      LiveStream().emit(OnAddPostProfile);
                    },
                    retryText: '   ${language.clickToRefresh}   ',
                  ).center(),
                ).visible(profileFragStore.memberDetails == null && !appStore.isLoading && !profileFragStore.isError);
              }),

          /// List Widget
          Observer(
            builder: (context) {
              return profileFragStore.memberDetails != null && !profileFragStore.isError
                  ? AnimatedScrollView(
                      padding: EdgeInsets.only(bottom: 30),
                      children: [
                        Observer(
                          builder: (context) {
                            return Column(
                              children: [
                                ProfileHeaderComponent(avatarUrl: userStore.loginAvatarUrl, cover: profileFragStore.memberDetails!.memberCoverImage.validate()),
                             8.height,
                                /*Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Observer(builder: (context) {
                                      return RichText(
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        text: TextSpan(
                                          text: userStore.loginFullName,
                                          style: boldTextStyle(size: 20),
                                          children: [
                                            if (profileFragStore.memberDetails!.isUserVerified.validate())
                                              WidgetSpan(
                                                child: Image.asset(ic_tick_filled, width: 20, height: 20, color: blueTickColor).paddingSymmetric(horizontal: 4),
                                              ),
                                          ],
                                        ),
                                      );
                                    }),
                                    4.height,
                                    TextIcon(
                                      edgeInsets: EdgeInsets.zero,
                                      spacing: 0,
                                      onTap: () {
                                        PersonalInfoScreen(profileInfo: profileFragStore.memberDetails!.profileInfo.validate(), hasUserInfo: hasInfo).launch(context);
                                      },
                                      text: userStore.loginName,
                                      textStyle: secondaryTextStyle(),
                                      suffix: SizedBox(
                                        height: 26,
                                        width: 26,
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          onPressed: () {
                                            PersonalInfoScreen(profileInfo: profileFragStore.memberDetails!.profileInfo.validate(), hasUserInfo: hasInfo).launch(context);
                                          },
                                          icon: Icon(Icons.info_outline_rounded),
                                          iconSize: 18,
                                          splashRadius: 1,
                                        ),
                                      ),
                                    ),
                                  ],
                                ).paddingAll(16),*/
                                Row(
                                  children: [
                                    if (appStore.displayPostCount)
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(profileFragStore.memberDetails!.postCount.toString(), style: boldTextStyle(size: 18)),
                                          4.height,
                                          Text(language.posts, style: secondaryTextStyle(size: 12)),
                                        ],
                                      ).paddingSymmetric(vertical: 8).onTap(() {
                                        widget.controller?.animateTo(context.height() * 0.35, duration: const Duration(milliseconds: 500), curve: Curves.linear);
                                      }, splashColor: Colors.transparent, highlightColor: Colors.transparent).expand(),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(profileFragStore.memberDetails!.friendsCount.validate().toString(), style: boldTextStyle(size: 18)),
                                        4.height,
                                        Text(language.friends, style: secondaryTextStyle(size: 12)),
                                      ],
                                    ).paddingSymmetric(vertical: 8).onTap(() {
                                      ProfileFriendsScreen().launch(context).then((value) {
                                        if (value ?? false) init();
                                      });
                                    }, splashColor: Colors.transparent, highlightColor: Colors.transparent).expand(),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(profileFragStore.memberDetails!.groupsCount.validate().toString(), style: boldTextStyle(size: 18)),
                                        4.height,
                                        Text(language.groups, style: secondaryTextStyle(size: 12)),
                                      ],
                                    ).paddingSymmetric(vertical: 8).onTap(() {
                                      if (pmpStore.viewGroups) {
                                        GroupScreen(type: GroupRequestType.userGroup).launch(context).then((value) {
                                          if (value ?? false) init();
                                        });
                                      } else {
                                        MembershipPlansScreen().launch(context);
                                      }
                                    }, splashColor: Colors.transparent, highlightColor: Colors.transparent).expand(),
                                  ],
                                ),
                                if (appStore.showStoryHighlight) 16.height,
                                if (appStore.showStoryHighlight)
                                  StoryHighlightsComponent(
                                    avatarImage: profileFragStore.memberDetails!.memberAvatarImage.validate(),
                                    highlightsList: profileFragStore.memberDetails!.highlightStory.validate(),
                                    callback: () {
                                      init();
                                    },
                                  ),
                                if (appStore.showStoryHighlight) 16.height,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    TextIcon(
                                      onTap: () {
                                        GalleryScreen(userId: userStore.loginUserId.toInt(), canEdit: true).launch(context);
                                      },
                                      text: language.viewGallery,
                                      textStyle: primaryTextStyle(color: appColorPrimary),
                                      prefix: Image.asset(ic_image, width: 18, height: 18, color: appColorPrimary),
                                    ),
                                    if (appStore.showGamiPress && appStore.isGamiPressEnable)
                                      TextIcon(
                                        onTap: () {
                                          RewardsScreen(userID: userStore.loginUserId.toInt()).launch(context);
                                        },
                                        text: language.viewRewards,
                                        textStyle: primaryTextStyle(color: appColorPrimary),
                                        prefix: Image.asset(ic_badge, width: 18, height: 18, color: appColorPrimary),
                                      ),
                                  ],
                                ).paddingSymmetric(vertical: 12),
                              ],
                            );
                          },
                        ),
                        if (profileFragStore.memberDetails != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(language.posts, style: boldTextStyle(color: context.primaryColor, size: 20)),
                              Observer(builder: (context) {
                                return TextIcon(
                                  onTap: () {
                                    setValue(SharePreferencesKey.isFavourite, !profileFragStore.isFavorites);
                                    profileFragStore.isFavorites = !profileFragStore.isFavorites;
                                    profileFragStore.mProfilePage = 1;
                                    if (profileFragStore.isFavorites)
                                      getPost(
                                        type: PostRequestType.favorites,
                                        postList: profileFragStore.userPostList,
                                        userId: userStore.loginUserId.toInt(),
                                        lastPageCallback: (p0) async {
                                          mIsLastPage = p0;
                                        },
                                      );
                                    else
                                      init();
                                  },
                                  prefix: Image.asset(profileFragStore.isFavorites ? ic_star_filled : ic_star, width: 18, height: 18, color: appColorPrimary),
                                  text: language.favorites,
                                  textStyle: secondaryTextStyle(color: profileFragStore.isFavorites ? context.primaryColor : null),
                                );
                              }),
                            ],
                          ).paddingSymmetric(horizontal: 8, vertical: 8),
                        if (profileFragStore.memberDetails != null) ...[
                          profileFragStore.userPostList.isEmpty
                              ? NoDataWidget(
                                  imageWidget: NoDataLottieWidget(),
                                  title: language.noDataFound,
                                  retryText: '   ${language.clickToRefresh}   ',
                                ).center().paddingBottom(20)
                              : Stack(
                                  children: [
                                    Observer(builder: (_) {
                                      // Choose posts based on isFavorites
                                      final List<PostModel> posts = profileFragStore.isFavorites ? profileFragStore.userPostList.where((e) => e.isFavorites.getBoolInt()).toList() : profileFragStore.userPostList;

                                      return AnimatedWrap(
                                        spacing: 16,
                                        listAnimationType: ListAnimationType.None,
                                        itemCount: posts.length,
                                        slideConfiguration: SlideConfiguration(
                                          delay: 80.milliseconds,
                                          verticalOffset: 300,
                                        ),
                                        itemBuilder: (context, index) {
                                          return PostComponent(
                                            fromProfile: true,
                                            post: posts[index],
                                            callback: () => init(),
                                            fromFavourites: profileFragStore.isFavorites,
                                          ).paddingSymmetric(horizontal: 8);
                                        },
                                      );
                                    }),
                                    if (appStore.isLoadingDots)
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        left: 0,
                                        child: ThreeBounceLoadingWidget(),
                                      ),
                                  ],
                                ),
                        ]
                      ],
                    )
                  : Offstage();
            },
          )
        ],
      ),
    );
  }
}
