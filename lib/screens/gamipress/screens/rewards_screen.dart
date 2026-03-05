import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/base_scaffold_widget.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/network/gamipress_repository.dart';
import 'package:socialv/screens/gamipress/components/badge_component.dart';
import 'package:socialv/screens/gamipress/components/level_component.dart';
import 'package:socialv/screens/gamipress/components/points_component.dart';
import 'package:socialv/store/profile_menu_store.dart';

class RewardsScreen extends StatefulWidget {
  final int userID;

  RewardsScreen({required this.userID});

  @override
  State<RewardsScreen> createState() => _ScreenState();
}

class _ScreenState extends State<RewardsScreen> {
  ProfileMenuStore rewardsScreenVars = ProfileMenuStore();

  @override
  void initState() {
    super.initState();
    rewardsScreenVars.rewardTabs.addAll(["${language.points}", "${language.badges}", "${language.levels}"]);
    getDetails();
  }

  Future<void> getDetails() async {
    appStore.setLoading(true);

    await rewards(userID: widget.userID).then((value) {
      rewardsScreenVars.rewardData = value;
      appStore.setLoading(false);
    }).catchError((e) {
      appStore.setLoading(false);
      log("Error: ${e.toString()}");
      rewardsScreenVars.isError = true;
    });
  }

  @override
  void dispose() {
    appStore.setLoading(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: language.rewards,
      child: Stack(
        children: [
          ///Error widget
          Observer(builder: (_) {
            return NoDataWidget(
              imageWidget: NoDataLottieWidget(),
              title: language.somethingWentWrong,
              onRetry: () {
                rewardsScreenVars.isError = false;
                getDetails();
              },
              retryText: '   ${language.clickToRefresh}   ',
            ).center().visible((rewardsScreenVars.isError && !appStore.isLoading));
          }),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ///Horizontal list reward types
                Observer(builder: (context) {
                  return HorizontalList(
                    itemCount: rewardsScreenVars.rewardTabs.length,
                    padding: EdgeInsets.all(16),
                    itemBuilder: (ctx, index) {
                      return Observer(builder: (context) {
                        return InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {
                            rewardsScreenVars.selectedRewardIndex = index;
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                            margin: EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(color: rewardsScreenVars.selectedRewardIndex == index ? context.primaryColor : context.cardColor, borderRadius: radius()),
                            child: Text(rewardsScreenVars.rewardTabs[index], style: boldTextStyle(color: rewardsScreenVars.selectedRewardIndex == index ? Colors.white : context.primaryColor)),
                          ),
                        );
                      });
                    },
                  ).visible(rewardsScreenVars.rewardTabs.length >= 0);
                }),
                Observer(builder: (context) {
                  return PointsComponent(pointsList: rewardsScreenVars.rewardData!.points.validate()).visible(rewardsScreenVars.selectedRewardIndex == 0 && rewardsScreenVars.rewardData != null && !appStore.isLoading && !rewardsScreenVars.isError);
                }),
                Observer(builder: (context) {
                  return BadgeComponent(
                    achievementCount: rewardsScreenVars.rewardData!.achievementCount == null ? 0 : rewardsScreenVars.rewardData!.achievementCount!,
                    badgeList: rewardsScreenVars.rewardData!.achievement.validate(),
                    userId: widget.userID,
                  ).visible(rewardsScreenVars.selectedRewardIndex == 1 && rewardsScreenVars.rewardData != null && !appStore.isLoading && !rewardsScreenVars.isError);
                }),
                Observer(builder: (context) {
                  return LevelComponent(rank: rewardsScreenVars.rewardData!.rank).center().visible(rewardsScreenVars.selectedRewardIndex == 2 && rewardsScreenVars.rewardData != null && !appStore.isLoading && !rewardsScreenVars.isError);
                }),
              ],
            ),
          )
        ],
      ),
    );
  }
}
