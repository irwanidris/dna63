import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/main.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/forums/components/forum_detail_component.dart';
import 'package:socialv/screens/forums/screens/create_topic_screen.dart';
import 'package:socialv/screens/groups/screens/group_detail_screen.dart';
import 'package:socialv/screens/membership/screens/membership_plans_screen.dart';
import 'package:socialv/store/profile_menu_store.dart';
import 'package:socialv/utils/app_constants.dart';
import 'package:socialv/utils/extentions/str_extentions.dart';
import '../../../components/loading_widget.dart';
import '../../../components/no_data_lottie_widget.dart';
import '../../profile/components/profile_header_component.dart';

class ForumDetailScreen extends StatefulWidget {
  final int forumId;
  final String type;
  final String forumTitle;
  final bool isFromSubscription;

  const ForumDetailScreen({required this.forumId, required this.type, this.isFromSubscription = false, this.forumTitle = ''});

  @override
  State<ForumDetailScreen> createState() => _ForumDetailScreenState();
}

class _ForumDetailScreenState extends State<ForumDetailScreen> {
  ProfileMenuStore forumDetailScreenVars = ProfileMenuStore();
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    getForumDetails();
    super.initState();
  }

  Future<void> init() async {
    getForumDetails();
  }

  Future<void> getForumDetails({bool showLoader = true}) async {
    appStore.setLoading(showLoader);
    await getForumDetail(
      forumId: widget.forumId.validate(),
      page: 1,
      topicPerPage: PER_PAGE,
      forumsPerPage: PER_PAGE,
    ).then((value) async {
      forumDetailScreenVars.forumData = value;
      forumDetailScreenVars.isSubscribed = value.isSubscribed.validate();
      forumDetailScreenVars.isError = false;
      appStore.setLoading(false);
    }).catchError((e) {
      forumDetailScreenVars.isError = true;
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
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
      child: Scaffold(
        appBar: AppBar(
          title: Observer(
            builder: (context) {
              return Text(forumDetailScreenVars.forumData != null ? forumDetailScreenVars.forumData!.title.validate() : '', style: boldTextStyle(size: 20));
            }
          ),
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: context.iconColor),
            onPressed: () {
              finish(context);
            },
          ),
          actions: [
            Observer(builder: (context) {
              return forumDetailScreenVars.forumData != null && (forumDetailScreenVars.forumData!.groupDetails == null || forumDetailScreenVars.forumData!.groupDetails!.isGroupMember.validate())
                  ? PopupMenuButton(
                position: PopupMenuPosition.under,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(commonRadius)),
                onSelected: (val) async {
                  if (val == 1) {
                    CreateTopicScreen(
                      forumName: forumDetailScreenVars.forumData != null ? forumDetailScreenVars.forumData!.title.validate() : widget.forumTitle,
                      forumId: forumDetailScreenVars.forumData != null ? forumDetailScreenVars.forumData!.id.validate() : widget.forumId,
                    ).launch(context).then((value) {
                      if (value ?? false) {
                        init();
                      }
                    });
                  }
                },
                icon: Icon(Icons.more_vert),
                itemBuilder: (context) => <PopupMenuEntry>[
                  PopupMenuItem(
                    value: 1,
                    child: Text(language.createTopic),
                    textStyle: primaryTextStyle(),
                  ),
                ],
              )
                  : Offstage();
            }),
          ],
        ),
        body: Stack(
          children: [
            AnimatedScrollView(children: [
              /// error widget
              Observer(builder: (context) {
                return forumDetailScreenVars.isError && !appStore.isLoading
                    ? SizedBox(
                  height: context.height() * 0.88,
                  child: NoDataWidget(
                    imageWidget: NoDataLottieWidget(),
                    title: forumDetailScreenVars.isError.toString(),
                    retryText: '   ${language.clickToRefresh}   ',
                    onRetry: () {
                      init();
                    },
                  ).center(),
                )
                    : Offstage();
              }),

              /// list data widget
              Observer(builder: (context) {
                return forumDetailScreenVars.forumData != null
                    ? AnimatedScrollView(
                  controller: scrollController,
                  onSwipeRefresh: () {
                    return init();
                  },
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ProfileHeaderComponent(
                      avatarUrl: forumDetailScreenVars.forumData!.image.validate(),
                      cover:
                      forumDetailScreenVars.forumData!.groupDetails != null && forumDetailScreenVars.forumData!.groupDetails!.coverImage.validate().isNotEmpty ? forumDetailScreenVars.forumData!.groupDetails!.coverImage.validate() : null,
                    ),
                    16.height,
                    Text(forumDetailScreenVars.forumData!.title.validate(), style: boldTextStyle(size: 20)).paddingSymmetric(horizontal: 16).onTap(() {
                      if (forumDetailScreenVars.forumData!.groupDetails != null && forumDetailScreenVars.forumData!.groupDetails!.groupId != 0) {
                        if (pmpStore.viewSingleGroup) {
                          GroupDetailScreen(groupId: forumDetailScreenVars.forumData!.groupDetails!.groupId.validate()).launch(context).then((value) {
                            if (value ?? false) {
                              init();
                            }
                          });
                        } else {
                          MembershipPlansScreen().launch(context);
                        }
                      }
                    }, splashColor: Colors.transparent, highlightColor: Colors.transparent).center(),
                    8.height,
                    ReadMoreText(
                      forumDetailScreenVars.forumData!.description.validateAndFilter(),
                      trimLength: 120,
                      style: secondaryTextStyle(),
                      textAlign: TextAlign.justify,
                    ).paddingSymmetric(horizontal: 16).center(),
                    16.height,
                    Observer(builder: (context) {
                      return AppButton(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        elevation: 0,
                        color: forumDetailScreenVars.isSubscribed ? appOrangeColor : appGreenColor,
                        child: Text(forumDetailScreenVars.isSubscribed ? language.unsubscribe : language.subscribe, style: boldTextStyle(color: Colors.white)),
                        onTap: () {
                          ifNotTester(() {
                            forumDetailScreenVars.isSubscribed = !forumDetailScreenVars.isSubscribed;
                            if (forumDetailScreenVars.isSubscribed) {
                              toast(language.subscribedSuccessfully);
                            } else {
                              toast(language.unsubscribedSuccessfully);
                            }
                            subscribeForum(forumId: widget.forumId.validate()).then((value) {
                              //  if (widget.isFromSubscription) isUpdate = true;
                            }).catchError((e) {
                              log(e.toString());
                            });
                          });
                        },
                      ).paddingSymmetric(horizontal: 16);
                    }),
                    Container(
                      margin: EdgeInsets.all(16),
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: context.primaryColor.withAlpha(30),
                        border: Border(left: BorderSide(color: context.primaryColor, width: 2)),
                      ),
                      child: Text(forumDetailScreenVars.forumData!.lastUpdate.validate(), style: secondaryTextStyle()),
                    ),
                    if ((forumDetailScreenVars.forumData!.groupDetails != null && forumDetailScreenVars.forumData!.groupDetails!.isGroupMember.validate()) || forumDetailScreenVars.forumData!.isPrivate == 0)
                      Observer(
                        builder: (context) {
                          return ForumDetailComponent(
                            scrollCont: scrollController,
                            type: widget.type,
                            callback: () {
                              init();
                            },
                            forumId: forumDetailScreenVars.forumData!.id.validate(),
                            showOptions: forumDetailScreenVars.forumData!.forumList.validate().isNotEmpty && forumDetailScreenVars.forumData!.topicList.validate().isNotEmpty,
                            selectedIndex: forumDetailScreenVars.forumData!.forumList.validate().isNotEmpty ? 1 : 0,
                            forumList: forumDetailScreenVars.forumData!.forumList.validate(),
                            topicList: forumDetailScreenVars.forumData!.topicList.validate(),
                          );
                        }
                      )
                    else if (forumDetailScreenVars.forumData!.groupDetails != null && !forumDetailScreenVars.forumData!.groupDetails!.isGroupMember.validate())
                      appButton(
                        context: context,
                        shapeBorder: RoundedRectangleBorder(borderRadius: radius(4)),
                        text: language.viewGroup,
                        textStyle: boldTextStyle(color: Colors.white),
                        onTap: () {
                          if (forumDetailScreenVars.forumData!.groupDetails != null && forumDetailScreenVars.forumData!.groupDetails!.groupId != 0) {
                            if (pmpStore.viewSingleGroup) {
                              GroupDetailScreen(groupId: forumDetailScreenVars.forumData!.groupDetails!.groupId.validate()).launch(context).then((value) {
                                if (value ?? false) {
                                  init();
                                }
                              });
                            } else {
                              MembershipPlansScreen().launch(context);
                            }
                          } else {
                            toast(language.canNotViewThisGroup);
                          }
                        },
                        width: context.width() - 64,
                      ).paddingSymmetric(vertical: 20).center()
                    else
                      Observer(
                        builder: (context) {
                          return ForumDetailComponent(
                            scrollCont: scrollController,
                            type: widget.type,
                            callback: () {
                              init();
                            },
                            forumId: widget.forumId,
                            showOptions: forumDetailScreenVars.forumData!.forumList.validate().isNotEmpty && forumDetailScreenVars.forumData!.topicList.validate().isNotEmpty,
                            selectedIndex: forumDetailScreenVars.forumData!.forumList.validate().isNotEmpty ? 1 : 0,
                            forumList: forumDetailScreenVars.forumData!.forumList.validate(),
                            topicList: forumDetailScreenVars.forumData!.topicList.validate(),
                          );
                        }
                      ),
                  ],
                )
                    : Offstage();
              }),
            ]),
            Observer(builder: (context) {
              return LoadingWidget(isBlurBackground: true).center().visible(appStore.isLoading);
            }),
            Observer(
              builder: (context) => Positioned(
                child: ThreeBounceLoadingWidget().visible(appStore.isLoadingDots),
                bottom: 24,
                left: 0,
                right: 0,
              ),
            )
          ],
        ),
      ),
    );
  }
}
