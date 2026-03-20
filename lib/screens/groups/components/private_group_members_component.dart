import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/members/member_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/groups/components/members_component.dart';
import 'package:socialv/store/group_store.dart';
import 'package:socialv/utils/app_constants.dart';

class PrivateGroupMembersComponent extends StatefulWidget {
  final int groupId;
  final bool isAdmin;
  final int creatorId;
  final VoidCallback? callback;

  const PrivateGroupMembersComponent({required this.groupId, required this.isAdmin, required this.creatorId, this.callback});

  @override
  State<PrivateGroupMembersComponent> createState() => _PrivateGroupMembersComponentState();
}

class _PrivateGroupMembersComponentState extends State<PrivateGroupMembersComponent> with AutomaticKeepAliveClientMixin {
  GroupStore privateGroupMembersComponentVars = GroupStore();
  int mPage = 1;
  bool mIsLastPage = false;

  @override
  void initState() {
    getList();

    LiveStream().on(OnGroupRequestAccept, (p0) {
      privateGroupMembersComponentVars.groupMemberList.clear();
      getList();
    });
    super.initState();
  }

  Future<void> getList() async {
    appStore.setLoading(true);

    await getGroupMembersList(groupId: widget.groupId, page: mPage).then((value) {
      if (mPage == 1) privateGroupMembersComponentVars.groupMemberList.clear();
      mIsLastPage = value.length != 20;
      privateGroupMembersComponentVars.groupMemberList.addAll(value);
      privateGroupMembersComponentVars.isError = false;
      appStore.setLoading(false);
    }).catchError((e) {
      privateGroupMembersComponentVars.isError = true;
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  Future<void> onRefresh() async {
    privateGroupMembersComponentVars.isError = false;
    privateGroupMembersComponentVars.groupMemberList.clear();
    getList();
  }

  @override
  void dispose() {
    LiveStream().dispose(OnGroupRequestAccept);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      padding: EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: radiusOnly(topLeft: defaultRadius, topRight: defaultRadius),
      ),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          AnimatedScrollView(children: [
            /// error widget
            Observer(builder: (context) {
              return privateGroupMembersComponentVars.isError && !appStore.isLoading
                  ? SizedBox(
                      height: context.height() * 0.88,
                      child: NoDataWidget(
                        imageWidget: NoDataLottieWidget(),
                        title: privateGroupMembersComponentVars.isError ? language.somethingWentWrong : language.noDataFound,
                        onRetry: () {
                          onRefresh();
                        },
                        retryText: '   ${language.clickToRefresh}   ',
                      ).center(),
                    )
                  : Offstage();
            }),

            /// empty  widget

            Observer(builder: (context) {
              return privateGroupMembersComponentVars.groupMemberList.isEmpty && !privateGroupMembersComponentVars.isError && !appStore.isLoading
                  ? SizedBox(
                      height: context.height() * 0.88,
                      child: NoDataWidget(
                        imageWidget: NoDataLottieWidget(),
                        title: privateGroupMembersComponentVars.isError ? language.somethingWentWrong : language.noDataFound,
                        onRetry: () {
                          onRefresh();
                        },
                        retryText: '   ${language.clickToRefresh}   ',
                      ).center(),
                    )
                  : Offstage();
            }),

            /// list widget
            Observer(
              builder: (context) {
                return privateGroupMembersComponentVars.groupMemberList.isNotEmpty && !privateGroupMembersComponentVars.isError? AnimatedListView(
                  shrinkWrap: true,
                  physics: AlwaysScrollableScrollPhysics(),
                  slideConfiguration: SlideConfiguration(
                    delay: 80.milliseconds,
                    verticalOffset: 300,
                  ),
                  padding: EdgeInsets.only(left: 16, right: 16, bottom: 50),
                  itemCount: privateGroupMembersComponentVars.groupMemberList.validate().length,
                  itemBuilder: (context, index) {
                    MemberModel member = privateGroupMembersComponentVars.groupMemberList.validate()[index];
                    return MembersComponent(
                      creatorId: widget.creatorId,
                      groupId: widget.groupId,
                      member: member,
                      isAdmin: widget.isAdmin,
                      callback: () {
                        mPage = 1;
                        getList();
                        widget.callback?.call();
                      },
                    ).paddingSymmetric(vertical: 8);
                  },
                  onNextPage: () {
                    if (!mIsLastPage) {
                      mPage++;
                      getList();
                    }
                  },
                ): Offstage();
              }
            ),
          ]),
          Observer(builder: (_) {
            if (appStore.isLoading) {
              return Positioned(
                bottom: mPage != 1 ? 10 : null,
                child: LoadingWidget(isBlurBackground: mPage == 1 ? true : false),
              );
            } else {
              return Offstage();
            }
          }),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
