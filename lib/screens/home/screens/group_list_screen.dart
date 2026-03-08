import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/dashboard_api_response.dart';
import 'package:socialv/models/groups/group_response.dart';
import 'package:socialv/network/rest_apis.dart';
// TEMP DISABLED: import 'package:socialv/screens/groups/screens/group_detail_screen.dart';
import 'package:socialv/screens/membership/screens/membership_plans_screen.dart';
import 'package:socialv/store/fragment_store/home_fragment_store.dart';
import 'package:socialv/utils/cached_network_image.dart';
import 'package:socialv/utils/common.dart';
import 'package:socialv/utils/images.dart';

class GroupListScreen extends StatefulWidget {
  final bool isSuggested;

  GroupListScreen({this.isSuggested = false});

  @override
  State<GroupListScreen> createState() => _GroupListScreenState();
}

class _GroupListScreenState extends State<GroupListScreen> {
  HomeFragStore groupListScreenVars = HomeFragStore();
  final ScrollController _controller = ScrollController();

  int mPage = 1;
  bool mIsLastPage = false;

  @override
  void initState() {
    super.initState();
    groupListScreenVars.isSuggested = widget.isSuggested;
    _fetchData();
  }

  void _fetchData() {
    if (widget.isSuggested) {
      getSuggestedList();
    } else {
      getGroupsList();
    }
  }

  Future<List<GroupResponse>> getGroupsList() async {
    appStore.setLoading(true);
    await getBuddyPressGroupList(
        page: mPage,
        groupList: groupListScreenVars.groupList,
        lastPageCallback: (p0) {
          mIsLastPage = p0;
        }).then((value) {
      groupListScreenVars.isError = false;
      appStore.setLoading(false);
    }).catchError((e) {
      groupListScreenVars.isError = true;
      toast(e.toString(), print: true);
      appStore.setLoading(false);
    });

    return groupListScreenVars.groupList;
  }

  Future<List<SuggestedGroup>> getSuggestedList() async {
    appStore.setLoading(true);

    await getSuggestedGroupList(page: mPage).then((value) {
      mIsLastPage = value.length != 20;
      if (mPage == 1) groupListScreenVars.suggestedGroups.clear();
      groupListScreenVars.suggestedGroups.addAll(value);
      groupListScreenVars.isError = false;
      appStore.setLoading(false);
    }).catchError((e) {
      groupListScreenVars.isError = true;
      appStore.setLoading(false);
      toast(e.toString());
    });
    return groupListScreenVars.suggestedGroups;
  }

  Widget _buildNoDataWidget(String message, VoidCallback onRetry) {
    return SizedBox(
      height: context.height() * 0.88,
      child: NoDataWidget(
        imageWidget: NoDataLottieWidget(),
        title: message,
        onRetry: onRetry,
        retryText: '   ${language.clickToRefresh}   ',
      ).center(),
    );
  }

  Widget _buildGroupList(List groups) {
    return groupListScreenVars.isSuggested
        ? AnimatedListView(
            shrinkWrap: true,
            controller: _controller,
            disposeScrollController: false,
            physics: AlwaysScrollableScrollPhysics(),
            slideConfiguration: SlideConfiguration(delay: 120.milliseconds),
            padding: EdgeInsets.only(left: 16, right: 16, bottom: 50),
            itemCount: groupListScreenVars.suggestedGroups.length,
            itemBuilder: (context, index) {
              SuggestedGroup group = groupListScreenVars.suggestedGroups[index];
              return GestureDetector(
                onTap: () {
                  if (pmpStore.viewSingleGroup) {
                    GroupDetailScreen(groupId: group.id.validate()).launch(context);
                  } else {
                    MembershipPlansScreen().launch(context);
                  }
                },
                child: Row(
                  children: [
                    cachedImage(
                      group.groupAvtarImage.validate(),
                      height: 40,
                      width: 40,
                      fit: BoxFit.cover,
                    ).cornerRadiusWithClipRRect(20),
                    16.width,
                    Text(
                      group.name.validate(),
                      style: boldTextStyle(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ).expand(),
                    InkWell(
                      child: cachedImage(ic_close_square, height: 22, width: 22, color: Colors.red, fit: BoxFit.cover),
                      onTap: () {
                        ifNotTester(() async {
                          groupListScreenVars.suggestedGroups.removeAt(index);
                          await removeSuggestedGroup(groupId: group.id.validate()).then((value) {
                            //
                          }).catchError(onError);
                        });
                      },
                    ),
                  ],
                ).paddingSymmetric(vertical: 8),
              );
            },
            onNextPage: () {
              if (!mIsLastPage) {
                mPage++;
                getSuggestedGroupList();
              }
            },
          )
        : AnimatedListView(
            shrinkWrap: true,
            physics: AlwaysScrollableScrollPhysics(),
            slideConfiguration: SlideConfiguration(
              delay: 120.milliseconds,
            ),
            padding: EdgeInsets.only(left: 16, right: 16, bottom: 50),
            itemCount: groupListScreenVars.groupList.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  if (pmpStore.viewSingleGroup) {
                    GroupDetailScreen(groupId: groupListScreenVars.groupList[index].id.validate()).launch(context);
                  } else {
                    MembershipPlansScreen().launch(context);
                  }
                },
                child: Row(
                  children: [
                    cachedImage(
                      groupListScreenVars.groupList[index].avatarUrls!.full.validate(),
                      height: 56,
                      width: 56,
                      fit: BoxFit.cover,
                    ).cornerRadiusWithClipRRect(100),
                    20.width,
                    Column(
                      children: [
                        Text(groupListScreenVars.groupList[index].name.validate(), style: boldTextStyle()),
                        6.height,
                        Text(
                          groupListScreenVars.groupList[index].description!.raw.validate(),
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
            },
            onNextPage: () {
              if (!mIsLastPage) {
                mPage++;
                getGroupsList();
              }
            },
          );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: context.iconColor),
        title: Text(language.groups, style: boldTextStyle(size: 20)),
        elevation: 0,
        centerTitle: true,
      ),
      body: Observer(
        builder: (context) {
          final isLoading = appStore.isLoading;
          final isError = groupListScreenVars.isError;
          final groupList = widget.isSuggested ? groupListScreenVars.suggestedGroups : groupListScreenVars.groupList;

          return Stack(
            alignment: Alignment.topCenter,
            children: [
              if (isError && !isLoading)
                _buildNoDataWidget(language.somethingWentWrong, _fetchData)
              else if (groupList.isEmpty && !isError && !isLoading)
                _buildNoDataWidget(language.noDataFound, _fetchData)
              else
                _buildGroupList(groupList),
              if (isLoading)
                Positioned(
                  bottom: mPage != 1 ? 10 : null,
                  child: LoadingWidget(isBlurBackground: mPage == 1),
                ),
            ],
          );
        },
      ),
    );
  }
}
