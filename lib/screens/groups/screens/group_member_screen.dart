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

import '../../../utils/app_constants.dart';

class GroupMemberScreen extends StatefulWidget {
  final int groupId;
  final bool isAdmin;
  final int creatorId;

  GroupMemberScreen(
      {required this.groupId, required this.isAdmin, required this.creatorId});

  @override
  State<GroupMemberScreen> createState() => _GroupMemberScreenState();
}

class _GroupMemberScreenState extends State<GroupMemberScreen> {
  GroupStore groupMemberScreenVars = GroupStore();
  late Future<List<MemberModel>> future;
  int mPage = 1;
  bool mIsLastPage = false;
  bool isCallback = false;
  bool isRefreshing = false;
  ScrollController? _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();
    getMemberList();
    super.initState();
  }

  Future<void> getMemberList() async {
    print(
        'DEBUG: GroupMemberScreen getMemberList() called - page: $mPage, isCallback: $isCallback');

    if (!mounted) return;
    if (isCallback || mPage == 1) {
      groupMemberScreenVars.memberList.clear();
    }

    appStore.setLoading(true);

    await getGroupMembersList(groupId: widget.groupId, page: mPage)
        .then((value) {
      if (!mounted) return;
      
      if (mPage == 1) {
        groupMemberScreenVars.memberList.clear();
      }

      mIsLastPage = value.length != 20;
      groupMemberScreenVars.memberList.addAll(value);
      appStore.setLoading(false);
    }).catchError((e) {
      if (!mounted) return;
      
      groupMemberScreenVars.isError = true;
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  Future<void> onRefresh() async {
    
    if (!mounted) return;
    
    setState(() {
      isRefreshing = true;
    });

    groupMemberScreenVars.isError = false;
    mPage = 1;
    isCallback = true; 
    await getMemberList();
    isCallback = false; 

    if (mounted) {
      setState(() {
        isRefreshing = false;
      });
    }
  }

  void refreshMemberList() {
    mPage = 1;
    isCallback = true;
    getMemberList();
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    appStore.setLoading(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(language.groupMembers, style: boldTextStyle(size: 20)),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.iconColor),
          onPressed: () {
            finish(context, isCallback);
          },
        ),
        actions: [],
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await onRefresh();
              },
              color: appColorPrimary,
              backgroundColor: context.cardColor,
              strokeWidth: 3.0,
              displacement: 40.0,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          Column(
                            children: [
                              Observer(builder: (context) {
                                return groupMemberScreenVars.isError &&
                                        !appStore.isLoading
                                    ? SizedBox(
                                        height: constraints.maxHeight * 0.8,
                                        child: NoDataWidget(
                                          imageWidget: NoDataLottieWidget(),
                                          title: groupMemberScreenVars.isError
                                              ? language.somethingWentWrong
                                              : language.noDataFound,
                                          onRetry: () {
                                            onRefresh();
                                          },
                                          retryText:
                                              '   ${language.clickToRefresh}   ',
                                        ).center(),
                                      )
                                    : Offstage();
                              }),

                              // Empty widget
                              Observer(builder: (context) {
                                return groupMemberScreenVars
                                            .memberList.isEmpty &&
                                        !groupMemberScreenVars.isError &&
                                        !appStore.isLoading
                                    ? SizedBox(
                                        height: constraints.maxHeight * 0.8,
                                        child: NoDataWidget(
                                          imageWidget: NoDataLottieWidget(),
                                          title: groupMemberScreenVars.isError
                                              ? language.somethingWentWrong
                                              : language.noDataFound,
                                          onRetry: () {
                                            onRefresh();
                                          },
                                          retryText:
                                              '   ${language.clickToRefresh}   ',
                                        ).center(),
                                      )
                                    : Offstage();
                              }),

                              // List widget
                              Observer(builder: (context) {
                                return groupMemberScreenVars
                                            .memberList.isNotEmpty &&
                                        !groupMemberScreenVars.isError
                                    ? AnimatedListView(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        slideConfiguration: SlideConfiguration(
                                          delay: 120.milliseconds,
                                        ),
                                        padding: EdgeInsets.only(
                                            left: 16, right: 16, bottom: 50),
                                        itemCount: groupMemberScreenVars
                                            .memberList.length,
                                        itemBuilder: (context, index) {
                                          MemberModel member =
                                              groupMemberScreenVars
                                                  .memberList[index];
                                          return MembersComponent(
                                            creatorId: widget.creatorId,
                                            member: member,
                                            groupId: widget.groupId,
                                            callback: () {
                                              isCallback = true;
                                              getMemberList();
                                            },
                                            isAdmin: widget.isAdmin,
                                          ).paddingSymmetric(vertical: 8);
                                        },
                                        onNextPage: () {
                                          if (!mIsLastPage) {
                                            mPage++;
                                            getMemberList();
                                          }
                                        },
                                      )
                                    : Offstage();
                              }),
                            ],
                          ),

                          // Loading indicator
                          Observer(builder: (_) {
                            return Positioned(
                              bottom: mPage != 1 ? 10 : null,
                              child: LoadingWidget(
                                      isBlurBackground:
                                          mPage == 1 ? true : false)
                                  .center(),
                            ).visible(appStore.isLoading && !isRefreshing);
                          }),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
