import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/blockReport/components/show_report_dialog.dart';
import 'package:socialv/screens/groups/components/join_group_widget.dart';
import 'package:socialv/screens/groups/screens/edit_group_screen.dart';
import 'package:socialv/screens/groups/screens/group_member_request_screen.dart';
import 'package:socialv/screens/groups/screens/group_member_screen.dart';
import 'package:socialv/screens/groups/screens/invite_user_screen.dart';
import 'package:socialv/screens/post/components/post_component.dart';
import 'package:socialv/screens/post/screens/add_post_screen.dart';
import 'package:socialv/screens/profile/components/profile_header_component.dart';
import 'package:socialv/store/group_store.dart';
import 'package:socialv/utils/cached_network_image.dart';

import '../../../utils/app_constants.dart';
import '../../gallery/screens/gallery_screen.dart';

class GroupDetailScreen extends StatefulWidget {
  final int? groupId;
  final String? groupAvatarImage;
  final String? groupCoverImage;

  GroupDetailScreen({this.groupId, this.groupAvatarImage, this.groupCoverImage});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  GroupStore groupDetailScreenVars = GroupStore();
  int mPage = 1;
  bool mIsLastPage = false;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    init();
    if (groupStore.postList.isNotEmpty) {
      _scrollController.addListener(() {
        if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
          if (!mIsLastPage) {
            onNextPage();
          }
        }
      });
    }
  }

  Future<void> init() async {
    groupDetail();
  }

  Future<void> groupDetail({bool showLoader = true}) async {
    appStore.setLoading(true);
    await getGroupDetail(groupId: widget.groupId.validate()).then((value) async {
      groupDetailScreenVars.postList.clear();
      groupDetailScreenVars.group = value;
      groupDetailScreenVars.postList.addAll(value.postList.validate());
      groupDetailScreenVars.isError = false;
      appStore.setLoading(false);
    }).catchError((e) {
      groupDetailScreenVars.isError = true;
      groupDetailScreenVars.errorMSG = e;
      appStore.setLoading(false);

      toast(e.toString(), print: true);
    });
  }

  Future<void> getPostList({bool showLoader = true, int page = 1}) async {
    appStore.setLoadingDots(showLoader);
    await getPost(
        type: PostRequestType.group,
        page: page,
        groupId: widget.groupId,
        userId: userStore.loginUserId.toInt(),
        postList: groupDetailScreenVars.postList,
        lastPageCallback: (p0) {
          mIsLastPage = p0;
        }).then(
      (value) {
        appStore.setLoadingDots(false);
      },
    ).catchError((e) {
      appStore.setLoadingDots(false);
      groupDetailScreenVars.errorMSG = e;
      toast(e.toString(), print: true);
    });
  }

  Future<void> onRefresh() async {
    init();
  }

  Future<void> onNextPage() async {
    mPage++;

    getPostList(showLoader: true, page: mPage);
  }

  @override
  void dispose() {
    appStore.setLoading(false);
    appStore.setLoadingDots(false);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          appStore.setLoading(false);
          finish(context);
        }
      },
      child: RefreshIndicator(
        onRefresh: () async {
          onRefresh();
        },
        color: context.primaryColor,
        child: Observer(builder: (context) {
          return Scaffold(
              appBar: AppBar(
                title: Text(parseHtmlString(groupDetailScreenVars.group.name.validate()), style: boldTextStyle(size: 20)),
                elevation: 0,
                centerTitle: true,
                actions: [
                  if (groupDetailScreenVars.group.isGroupAdmin.validate())
                    IconButton(
                      onPressed: () {
                        EditGroupScreen(groupId: widget.groupId.validate()).launch(context);
                      },
                      icon: Image.asset(
                        ic_edit,
                        height: 18,
                        width: 18,
                        fit: BoxFit.cover,
                        color: context.primaryColor,
                      ),
                    )
                  else
                    Theme(
                      data: Theme.of(context).copyWith(),
                      child: PopupMenuButton(
                        position: PopupMenuPosition.under,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(commonRadius)),
                        onSelected: (val) async {
                          if (val == 1) {
                            showConfirmDialogCustom(
                              context,
                              onAccept: (c) async {
                                ifNotTester(() async {
                                  appStore.setLoading(true);
                                  await leaveGroup(groupId: widget.groupId.validate().toInt()).then((value) {
                                    init();
                                  }).catchError((e) {
                                    appStore.setLoading(false);
                                    toast(e.toString());
                                  });
                                });
                              },
                              dialogType: DialogType.CONFIRMATION,
                              title: language.leaveGroupConfirmation,
                              positiveText: language.remove,
                            );
                          } else {
                            await showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              elevation: 0,
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
                                        child: ShowReportDialog(
                                          isPostReport: false,
                                          isGroupReport: true,
                                          groupId: widget.groupId.validate(),
                                        ),
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
                            child: Text(language.leaveGroup),
                            textStyle: primaryTextStyle(),
                          ),
                          PopupMenuItem(
                            value: 2,
                            child: Text(language.report),
                            textStyle: primaryTextStyle(),
                          ),
                        ],
                      ),
                    ).visible(groupDetailScreenVars.group.isGroupMember.validate()),
                ],
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: context.iconColor),
                  onPressed: () {
                    finish(context);
                  },
                ),
              ),
              body: SafeArea(
                child: Stack(
                  children: [
                    AnimatedScrollView(children: [
                      ///Error Widget
                      Observer(builder: (context) {
                        return groupDetailScreenVars.isError && !appStore.isLoading
                            ? SizedBox(
                                height: context.height() * 0.8,
                                child: NoDataWidget(
                                  imageWidget: NoDataLottieWidget(),
                                  title: language.somethingWentWrong,
                                  onRetry: () {
                                    onRefresh();
                                  },
                                  retryText: '   ${language.clickToRefresh}   ',
                                ),
                              ).center()
                            : Offstage();
                      }),

                      ///Group detail
                      Observer(builder: (_) {
                        return !appStore.isLoading && !groupDetailScreenVars.isError
                            ? AnimatedScrollView(
                                children: [
                                  Column(
                                    children: [
                                      ProfileHeaderComponent(
                                        avatarUrl: groupDetailScreenVars.group.groupAvatarImage.validate(),
                                        cover: groupDetailScreenVars.group.groupCoverImage.validate(),
                                      ),
                                      16.height,
                                      RichText(
                                        text: TextSpan(
                                          text: '${parseHtmlString(groupDetailScreenVars.group.name.validate())}',
                                          style: boldTextStyle(size: 20, fontFamily: fontFamily),
                                          children: <TextSpan>[
                                            TextSpan(
                                              text: ' ${groupDetailScreenVars.group.isGroupAdmin.validate() ? '(${language.organizer})' : groupDetailScreenVars.group.isGroupMember.validate() ? '(${language.member})' : ''}',
                                              style: boldTextStyle(color: appStore.isDarkMode ? bodyDark : bodyWhite, size: 14, fontFamily: fontFamily),
                                            ),
                                          ],
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ).paddingSymmetric(horizontal: 8),
                                      8.height,
                                      Text(
                                        parseHtmlString(groupDetailScreenVars.group.description.validate()),
                                        style: secondaryTextStyle(),
                                        textAlign: TextAlign.center,
                                      ).paddingSymmetric(horizontal: 16),
                                      16.height,
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            ic_globe_antarctic,
                                            height: 16,
                                            width: 16,
                                            fit: BoxFit.cover,
                                            color: context.iconColor,
                                          ),
                                          4.width,
                                          Text('${groupDetailScreenVars.group.groupType.validate().capitalizeFirstLetter()} ${language.group}', style: secondaryTextStyle()),
                                          Text(
                                            '•',
                                            style: primaryTextStyle(color: appStore.isDarkMode ? bodyDark : bodyWhite),
                                          ).paddingSymmetric(horizontal: 8),
                                          Image.asset(
                                            ic_calendar,
                                            height: 16,
                                            width: 16,
                                            fit: BoxFit.cover,
                                            color: context.iconColor,
                                          ),
                                          4.width,
                                          Text('${groupDetailScreenVars.group.dateCreated == null ? "" : getFormattedDate(groupDetailScreenVars.group.dateCreated.validate())}', style: secondaryTextStyle()),
                                        ],
                                      ).paddingSymmetric(horizontal: 16),
                                      16.height,
                                      Container(
                                        padding: EdgeInsets.all(8),
                                        width: context.width(),
                                        decoration: BoxDecoration(color: context.cardColor, borderRadius: radius(defaultAppButtonRadius)),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                TextButton(
                                                  onPressed: () {
                                                    if (groupDetailScreenVars.group.isGroupAdmin.validate() && groupDetailScreenVars.group.groupType == AccountType.private) {
                                                      GroupMemberRequestScreen(
                                                        creatorId: groupDetailScreenVars.group.groupCreatedById.validate(),
                                                        groupId: widget.groupId.validate(),
                                                        isAdmin: groupDetailScreenVars.group.isGroupAdmin.validate(),
                                                      ).launch(context).then((value) {
                                                        if (value) {
                                                          groupDetail();
                                                        }
                                                      });
                                                    } else if (groupDetailScreenVars.group.groupType == AccountType.public || groupDetailScreenVars.group.isGroupMember.validate()) {
                                                      GroupMemberScreen(
                                                        creatorId: groupDetailScreenVars.group.groupCreatedById.validate(),
                                                        groupId: widget.groupId.validate(),
                                                        isAdmin: groupDetailScreenVars.group.isGroupAdmin.validate(),
                                                      ).launch(context).then((value) {
                                                        if (value ?? false) {
                                                          groupDetail();
                                                        }
                                                      });
                                                    } else {
                                                      toast(language.cShowGroupMembers);
                                                    }
                                                  },
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      if (groupDetailScreenVars.group.memberList.validate().isNotEmpty)
                                                        Stack(
                                                          children: groupDetailScreenVars.group.memberList.validate().take(3).map((e) {
                                                            return Container(
                                                              width: 32,
                                                              height: 32,
                                                              margin: EdgeInsets.only(left: 18 * groupDetailScreenVars.group.memberList.validate().indexOf(e).toDouble()),
                                                              child: cachedImage(
                                                                groupDetailScreenVars.group.memberList.validate()[groupDetailScreenVars.group.memberList.validate().indexOf(e)].userAvatar.validate(),
                                                                fit: BoxFit.cover,
                                                              ).cornerRadiusWithClipRRect(100),
                                                            );
                                                          }).toList(),
                                                        ),
                                                      6.width,
                                                      Text(
                                                        '${groupDetailScreenVars.group.memberCount.validate().toInt()} ${language.members}',
                                                        style: boldTextStyle(color: context.primaryColor),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                if (groupDetailScreenVars.group.canInvite.validate())
                                                  Theme(
                                                    data: Theme.of(context).copyWith(
                                                      highlightColor: Colors.transparent,
                                                      splashColor: Colors.transparent,
                                                    ),
                                                    child: IconButton(
                                                      onPressed: () {
                                                        InviteUserScreen(groupId: widget.groupId.validate()).launch(context);
                                                      },
                                                      icon: Image.asset(
                                                        ic_add_user,
                                                        color: context.primaryColor,
                                                        height: 20,
                                                        width: 20,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                              mainAxisAlignment: groupDetailScreenVars.group.isGroupMember.validate() ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
                                            ),
                                            if (!groupDetailScreenVars.group.isGroupMember.validate() && groupDetailScreenVars.group.isBanned == 0)
                                              JoinGroupWidget(
                                                hasInvite: groupDetailScreenVars.group.hasInvite.validate(),
                                                isRequestSent: groupDetailScreenVars.group.isRequestSent.validate(),
                                                groupId: widget.groupId.validate(),
                                                isGroupMember: groupDetailScreenVars.group.isGroupMember.validate(),
                                                isPublicGroup: groupDetailScreenVars.group.groupType.validate() == AccountType.public ? true : false,
                                                callback: () {
                                                  init();
                                                },
                                              ),
                                          ],
                                        ),
                                      ).paddingSymmetric(horizontal: 16),
                                      16.height,
                                      if (groupDetailScreenVars.group.isGalleryEnabled == 1)
                                        if (groupDetailScreenVars.group.groupType == AccountType.public || groupDetailScreenVars.group.isGroupMember.validate())
                                          TextIcon(
                                            onTap: () {
                                              GalleryScreen(groupId: groupDetailScreenVars.group.id, canEdit: groupDetailScreenVars.group.isGroupMember.validate()).launch(context);
                                            },
                                            text: language.viewGallery,
                                            textStyle: primaryTextStyle(color: appColorPrimary),
                                            prefix: Image.asset(ic_image, width: 18, height: 18, color: appColorPrimary),
                                          ),
                                      8.height,
                                      if (!appStore.isLoading)
                                        groupDetailScreenVars.group.groupType == AccountType.public || groupDetailScreenVars.group.isGroupMember.validate()
                                            ? Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  if (groupDetailScreenVars.postList.isNotEmpty)
                                                    Text(
                                                      (appStore.displayPostCount) ? '${language.post} (${groupDetailScreenVars.group.postCount})' : language.post,
                                                      style: boldTextStyle(color: context.primaryColor),
                                                    ).paddingSymmetric(horizontal: 16),
                                                  AnimatedScrollView(children: [
                                                    Observer(builder: (_) {
                                                      return NoDataWidget(
                                                        imageWidget: NoDataLottieWidget(),
                                                        title: groupDetailScreenVars.errorMSG,
                                                        onRetry: () {
                                                          onRefresh();
                                                        },
                                                        retryText: '   ${language.clickToRefresh}   ',
                                                      ).center().visible(groupDetailScreenVars.isError && !appStore.isLoading);
                                                    }),
                                                    Observer(builder: (_) {
                                                      return NoDataWidget(
                                                        imageWidget: NoDataLottieWidget(),
                                                        title: language.noPostsFound,
                                                        onRetry: () {
                                                          onRefresh();
                                                        },
                                                        retryText: '   ${language.clickToRefresh}   ',
                                                      ).center().visible(groupDetailScreenVars.postList.isEmpty && !appStore.isLoadingDots && !appStore.isLoading);
                                                    }),

                                                    /// list widget
                                                    Observer(builder: (_) {
                                                      return AnimatedListView(
                                                        controller: _scrollController,
                                                        padding: EdgeInsets.all(8),
                                                        itemCount: groupDetailScreenVars.postList.length,
                                                        slideConfiguration: SlideConfiguration(
                                                          delay: 80.milliseconds,
                                                          verticalOffset: 300,
                                                        ),
                                                        itemBuilder: (context, index) {
                                                          return PostComponent(
                                                            post: groupDetailScreenVars.postList[index],
                                                            callback: () {
                                                              mPage = 1;
                                                              init();
                                                            },
                                                            commentCallback: () {
                                                              mPage = 1;
                                                              init();
                                                            },
                                                            fromGroup: true,
                                                            groupId: widget.groupId,
                                                          );
                                                        },
                                                        shrinkWrap: true,
                                                        physics: NeverScrollableScrollPhysics(),
                                                      );
                                                    })
                                                  ]),
                                                ],
                                              )
                                            : Offstage(),
                                      70.height,
                                    ],
                                  )
                                ],
                              )
                            : Offstage();
                      })
                    ]),

                    ///Loading Widget
                    Observer(builder: (_) {
                      return LoadingWidget().center().visible(appStore.isLoading);
                    }),
                    if (mPage != 1 && appStore.isLoadingDots)
                      Positioned(
                        bottom: 32,
                        right: 0,
                        left: 0,
                        child: ThreeBounceLoadingWidget(),
                      )
                  ],
                ),
              ),
              floatingActionButton: (groupDetailScreenVars.group.isGroupAdmin.validate() || groupDetailScreenVars.group.isGroupMember.validate())
                  ? FloatingActionButton(
                      backgroundColor: appColorPrimary,
                      onPressed: () {
                        AddPostScreen(
                          component: Component.groups,
                          groupId: widget.groupId,
                          groupName: groupDetailScreenVars.group.name.validate(),
                        ).launch(context).then((value) {
                          if (value ?? false) {
                            init();
                          }
                        });
                      },
                      child: Icon(Icons.add, color: Colors.white),
                    )
                  : Offstage());
        }),
      ),
    );
  }
}
