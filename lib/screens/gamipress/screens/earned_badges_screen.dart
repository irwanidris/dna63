import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/base_scaffold_widget.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/gamipress/rewards_model.dart';
import 'package:socialv/network/gamipress_repository.dart';
import 'package:socialv/store/profile_menu_store.dart';
import 'package:socialv/utils/app_constants.dart';
import 'package:socialv/utils/cached_network_image.dart';

class EarnedBadgesScreen extends StatefulWidget {
  final int userID;

  const EarnedBadgesScreen({required this.userID});

  @override
  State<EarnedBadgesScreen> createState() => _EarnedBadgesScreenState();
}

class _EarnedBadgesScreenState extends State<EarnedBadgesScreen> {
  ProfileMenuStore earnedBadgesScreenVars = ProfileMenuStore();
  int mPage = 1;
  bool mIsLastPage = false;

  @override
  void initState() {
    getList();
    super.initState();
  }

  Future<void> getList() async {
    appStore.setLoading(true);

    await userAchievements(userID: widget.userID, page: mPage).then((value) {
      if (mPage == 1) earnedBadgesScreenVars.listOfBadge.clear();

      mIsLastPage = value.validate().length != PER_PAGE;
      earnedBadgesScreenVars.listOfBadge.addAll(value.validate());

      earnedBadgesScreenVars.isError = false;
      appStore.setLoading(false);
    }).catchError((e) {
      earnedBadgesScreenVars.isError = true;
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  Future<void> onRefresh() async {
    earnedBadgesScreenVars.isError = false;
    mPage = 1;
    getList();
  }

  @override
  void dispose() {
    appStore.setLoading(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: language.earnedBadges,
      child: RefreshIndicator(
        onRefresh: () async {
          onRefresh();
        },
        color: context.primaryColor,
        child: AnimatedScrollView(
          children: [
            /// error widget
            Observer(builder: (context) {
              return earnedBadgesScreenVars.isError && !appStore.isLoading
                  ? SizedBox(
                      height: context.height() * 0.88,
                      child: NoDataWidget(
                        imageWidget: NoDataLottieWidget(),
                        title: language.somethingWentWrong,
                        onRetry: () {
                          onRefresh();
                        },
                        retryText: '   ${language.clickToRefresh}   ',
                      ).center(),
                    )
                  : Offstage();
            }),

            /// empty widget
            Observer(builder: (context) {
              return earnedBadgesScreenVars.listOfBadge.isEmpty && !earnedBadgesScreenVars.isError && !appStore.isLoading
                  ? SizedBox(
                      height: context.height() * 0.88,
                      child: NoDataWidget(
                        imageWidget: NoDataLottieWidget(),
                        title: language.noDataFound,
                        onRetry: () {
                          onRefresh();
                        },
                        retryText: '   ${language.clickToRefresh}   ',
                      ).center(),
                    )
                  : Offstage();
            }),

            /// list widget
            Observer(builder: (context) {
              return earnedBadgesScreenVars.listOfBadge.isNotEmpty && !earnedBadgesScreenVars.isError
                  ? AnimatedListView(
                      shrinkWrap: true,
                      slideConfiguration: SlideConfiguration(delay: 80.milliseconds, verticalOffset: 300),
                      physics: AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.only(left: 16, right: 16, bottom: 50),
                      itemCount: earnedBadgesScreenVars.listOfBadge.length,
                      itemBuilder: (context, index) {
                        Rank badge = earnedBadgesScreenVars.listOfBadge[index];

                        return ListTile(
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                          title: Text(badge.name.validate(), style: secondaryTextStyle(size: 16)),
                          leading: cachedImage(badge.image.validate(), height: 50, width: 50, fit: BoxFit.cover),
                        );
                      },
                      onNextPage: () {
                        if (!mIsLastPage) {
                          mPage++;
                          getList();
                        }
                      },
                    )
                  : Offstage();
            }),
          ],
        ),
      ),
    );
  }
}
