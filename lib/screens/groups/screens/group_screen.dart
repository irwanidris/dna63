import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/groups/group_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/groups/components/group_card_component.dart';
import 'package:socialv/screens/groups/components/initial_no_group_component.dart';
import 'package:socialv/screens/groups/screens/create_group_screen.dart';
import 'package:socialv/screens/groups/screens/group_detail_screen.dart';
import 'package:socialv/screens/membership/screens/membership_plans_screen.dart';

import '../../../components/loading_widget.dart';
import '../../../components/no_data_lottie_widget.dart';
import '../../../utils/app_constants.dart';

class GroupScreen extends StatefulWidget {
  final int? userId;
  final String type;

  const GroupScreen({this.userId, this.type = GroupRequestType.all});

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  int mPage = 1;
  bool mIsLastPage = false;
  bool isChange = false;

  @override
  void initState() {
    getGroups();
    super.initState();
  }

  Future<void> getGroups() async {
    appStore.setLoading(true);
    await getUserGroupList(
      userId: widget.userId,
      groupType: widget.type,
      page: mPage,
      groupList: groupStore.groupList,
      lastPageCallback: (p0) {
        mIsLastPage = p0;
      },
    ).then((value) {
      groupStore.isError = false;
      appStore.setLoading(false);
    }).catchError((e) {
      groupStore.isError = true;
      groupStore.errorMSG = e.toString();
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  Future<void> onRefresh() async {
    groupStore.isError = false;
    mPage = 1;
    getGroups();
  }

  @override
  void dispose() {
    if (appStore.isLoading) appStore.setLoading(false);
    groupStore.isError = false;
    groupStore.errorMSG = "";
    groupStore.groupList.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        finish(context, isChange);
        appStore.setLoading(false);
      },
      child: RefreshIndicator(
        onRefresh: () async {
          onRefresh();
        },
        color: appColorPrimary,
        child: Scaffold(
          appBar: AppBar(
            title: Text(language.groups, style: boldTextStyle(size: 20)),
            elevation: 0,
            centerTitle: true,
            actions: [
              if (widget.userId == null)
                IconButton(
                  onPressed: () {
                    if (pmpStore.canCreateGroup) {
                      CreateGroupScreen().launch(context).then((value) {
                        if (value) {
                          isChange = value;
                          mPage = 1;
                          getGroups();
                        }
                      });
                    } else {
                      MembershipPlansScreen().launch(context);
                    }
                  },
                  icon: Image.asset(
                    ic_plus,
                    color: appColorPrimary,
                    height: 22,
                    width: 22,
                    fit: BoxFit.cover,
                  ),
                ),
            ],
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: context.iconColor),
              onPressed: () {
                finish(context, isChange);
              },
            ),
          ),
          body: SafeArea(
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                AnimatedScrollView(children: [
                  ///  Error Widget
                  Observer(builder: (context) {
                    return SizedBox(
                      height: context.height() * 0.8,
                      child: NoDataWidget(
                        imageWidget: NoDataLottieWidget(),
                        title: language.somethingWentWrong,
                        onRetry: () {
                          onRefresh();
                        },
                        retryText: '   ${language.clickToRefresh}   ',
                      ),
                    ).center().visible(groupStore.isError && !appStore.isLoading);
                  }),

                  ///current user & no data found
                  Observer(builder: (context) {
                    return widget.userId.toString() == userStore.loginUserId.validate()
                        ? SizedBox(height: context.height(), child: InitialNoGroupComponent(callback: onRefresh)).center().visible(groupStore.groupList.isEmpty && !appStore.isLoading)
                        : SizedBox(
                            height: context.height() * 0.8,
                            child: NoDataWidget(
                              imageWidget: NoDataLottieWidget(),
                              title: language.noGroupsAddedYet,
                              onRetry: () {
                                onRefresh();
                              },
                              retryText: '   ${language.clickToRefresh}   ',
                            ),
                          ).visible(groupStore.groupList.isEmpty && !appStore.isLoading && !groupStore.isError);
                  }),

                  ///group list is not empty
                  Observer(builder: (context) {
                    return AnimatedListView(
                      slideConfiguration: SlideConfiguration(
                        delay: 80.milliseconds,
                        verticalOffset: 300,
                      ),
                      padding: EdgeInsets.only(left: 16, right: 16, bottom: 50),
                      itemCount: groupStore.groupList.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        GroupModel data = groupStore.groupList[index];
                        return GroupCardComponent(
                          data: data,
                          callback: () {
                            isChange = true;
                            mPage = 1;
                            getGroups();
                          },
                        ).paddingSymmetric(vertical: 8).onTap(() {
                          if (pmpStore.viewSingleGroup) {
                            GroupDetailScreen(
                              groupId: data.id.validate(),
                              groupAvatarImage: data.groupAvatarImage,
                              groupCoverImage: data.groupCoverImage,
                            ).launch(context).then((value) {
                              if (value ?? false) {
                                isChange = value;
                                mPage = 1;
                                getGroups();
                              }
                            });
                          } else {
                            MembershipPlansScreen().launch(context);
                          }
                        }, splashColor: Colors.transparent, highlightColor: Colors.transparent);
                      },
                      onNextPage: () {
                        if (!mIsLastPage) {
                          mPage++;
                          getGroups();
                        }
                      },
                    ).visible(!groupStore.isError);
                  }),
                ]),

                ///Loading widget
                Observer(
                  builder: (_) {
                    if (appStore.isLoading) {
                      return Positioned(
                        bottom: mPage != 1 ? 10 : null,
                        child: LoadingWidget(isBlurBackground: mPage == 1 ? true : false).center(),
                      );
                    } else {
                      return Offstage();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
