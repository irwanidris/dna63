import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/groups/group_request_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/groups/screens/create_group_screen.dart';
import 'package:socialv/screens/profile/screens/member_profile_screen.dart';
import 'package:socialv/utils/cached_network_image.dart';

import '../../../models/groups/search_invite_members_model.dart';
import '../../../utils/app_constants.dart';

class InviteUserComponent extends StatefulWidget {
  final int? groupId;
  final VoidCallback? onInviteSuccess;

  InviteUserComponent({this.groupId, this.onInviteSuccess});

  @override
  State<InviteUserComponent> createState() => _InviteUserComponentState();
}

class _InviteUserComponentState extends State<InviteUserComponent> {
  int mPage = 1;
  bool mIsLastPage = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    getInvites();
    super.initState();
  }

  Future<void> getInvites() async {
    appStore.setLoading(true);

    await getGroupInviteList(page: mPage, groupId: widget.groupId ?? groupId).then((value) {
      if (mPage == 1) groupStore.invites.clear();

      mIsLastPage = value.length != PER_PAGE;
      groupStore.invites.addAll(value);

      updateInvitedCount();

      appStore.setLoading(false);
    }).catchError((e) {
      groupStore.isError = true;
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  void updateInvitedCount() {
    groupStore.updateInvitedMembersCount(groupStore.invites.where((element) => element.isInvited.validate()).length);
  }

  Future<void> getInviteMembers(String? search) async {
    appStore.isLoading = true;

    try {
      List<InviteData> searchInviteMembers = await getSearchResults(
        groupId: widget.groupId.validate(),
        searchParam: search.validate(),
      );
      searchInviteMembers.map((value) {}).toList();
      groupStore.invites.clear();
      groupStore.invites = ObservableList.of(
        convertInviteDataToGroupInviteModel(searchInviteMembers),
      );

      updateInvitedCount();
    } catch (e) {
      print('Error caught in getInviteMembers: $e');
    } finally {
      appStore.isLoading = false;
    }
  }

  Future<void> onRefresh() async {
    groupStore.isError = false;
    mPage = 1;

    getInvites();
  }

  @override
  void dispose() {
    groupStore.isError = false;
    groupStore.invites.clear();
    groupStore.resetInvitedMembersCount();
    appStore.setLoading(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        onRefresh();
      },
      color: context.primaryColor,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          ///No data widget
          Observer(builder: (_) {
            return NoDataWidget(
              imageWidget: NoDataLottieWidget(),
              title: language.noDataFound,
              onRetry: () {
                onRefresh();
              },
              retryText: '   ${language.clickToRefresh}   ',
            ).center().visible(!appStore.isLoading && !groupStore.isError && groupStore.invites.isEmpty);
          }),

          ///Error widget
          Observer(builder: (_) {
            return NoDataWidget(
              imageWidget: NoDataLottieWidget(),
              title: language.somethingWentWrong,
              onRetry: () {
                onRefresh();
              },
              retryText: '   ${language.clickToRefresh}   ',
            ).center().visible(!appStore.isLoading && groupStore.isError);
          }),

          ///List widget
          Observer(builder: (_) {
            return Column(
              children: [
                Container(
                  margin: EdgeInsets.only(left: 16, right: 8),
                  decoration: BoxDecoration(color: context.cardColor, borderRadius: radius(commonRadius)),
                  child: Observer(builder: (context) {
                    return AppTextField(
                      controller: searchController,
                      onChanged: (val) {
                        getInviteMembers(val);
                      },
                      textFieldType: TextFieldType.USERNAME,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: language.searchHere,
                        hintStyle: secondaryTextStyle(),
                        prefixIcon: Image.asset(
                          ic_search,
                          height: 16,
                          width: 16,
                          fit: BoxFit.cover,
                          color: appStore.isDarkMode ? bodyDark : bodyWhite,
                        ).paddingAll(16),
                      ),
                      suffix: IconButton(
                          icon: Icon(Icons.cancel, color: appStore.isDarkMode ? bodyDark : bodyWhite, size: 18),
                          onPressed: () {
                            hideKeyboard(context);
                            mPage = 1;
                            searchController.clear();
                            groupStore.invites.clear();
                            getInvites();
                          }),
                    );
                  }),
                ),
                16.height,
                AnimatedListView(
                  shrinkWrap: true,
                  physics: AlwaysScrollableScrollPhysics(),
                  slideConfiguration: SlideConfiguration(
                    delay: 80.milliseconds,
                    verticalOffset: 300,
                  ),
                  padding: EdgeInsets.only(left: 16, right: 16, bottom: 50),
                  itemCount: groupStore.invites.length,
                  itemBuilder: (context, index) {
                    GroupInviteModel member = groupStore.invites[index];

                if (member.userId.validate().toString() != userStore.loginUserId) {
                  return Row(
                    children: [
                      cachedImage(
                        member.userImage.validate(),
                        width: 55,
                        height: 55,
                        fit: BoxFit.cover,
                      ).cornerRadiusWithClipRRect(100),
                      8.width,
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(text: '${member.userName.validate()}  ', style: primaryTextStyle(fontFamily: fontFamily)),
                            if (member.isUserVerified.validate()) WidgetSpan(child: Image.asset(ic_tick_filled, height: 18, width: 18, color: blueTickColor, fit: BoxFit.cover)),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                      ).expand(),
                      Observer(
                        builder: (context) => member.isInvited.validate()
                          ? TextButton(
                              onPressed: () async {
                                if (!appStore.isLoading)
                                  ifNotTester(() async {
                                    mPage = 1;

                                    appStore.setLoading(true);

                                    await invite(
                                      groupId: widget.groupId ?? groupId,
                                      userId: member.userId.validate(),
                                      isInviting: 0,
                                    ).then((value) async {
                                      mPage = 1;

                                      getInvites();
                                    }).catchError((e) {
                                      appStore.setLoading(false);

                                      toast(e.toString());
                                    });
                                  });
                              },
                              child:     Icon(Icons.check_circle_outline_sharp, color: context.primaryColor, size: 18),
                            )
                          : IconButton(
                              onPressed: () async {
                                if (!appStore.isLoading)
                                  ifNotTester(() async {
                                    mPage = 1;
                                    member.isInvited = true;

                                    await invite(groupId: widget.groupId ?? groupId, userId: member.userId.validate(), isInviting: 1).then((value) async {
                                      mPage = 1;
                                      appStore.setLoading(false);
                                      getInvites();
                                      widget.onInviteSuccess?.call();
                                    }).catchError((e) {
                                      appStore.setLoading(false);
                                      member.isInvited = false;
                                      toast(e.toString(), print: true);
                                    });
                                  });
                              },
                              icon: Icon(Icons.person_add_alt,size: 20,color: context.primaryColor,),
                            )
                      )
                    ],
                  ).onTap(() async {
                    MemberProfileScreen(memberId: member.userId.validate()).launch(context);
                  }, splashColor: Colors.transparent, highlightColor: Colors.transparent).paddingSymmetric(vertical: 8);
                } else {
                  return Offstage();
                }
              },
              onNextPage: () {
                if (!mIsLastPage) {
                  mPage++;

                      getInvites();
                    }
                  },
                ).visible(!groupStore.isError && groupStore.invites.isNotEmpty).expand(),
              ],
            );
          }),

          ///Loading Widget
          Positioned(
            bottom: mPage != 1 ? 8 : null,
            child: Observer(builder: (_) => LoadingWidget(isBlurBackground: mPage == 1 ? true : false).visible(appStore.isLoading)),
          ),
        ],
      ),
    );
  }
}
