import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/base_scaffold_widget.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/gamipress/common_gamipress_model.dart';
import 'package:socialv/network/gamipress_repository.dart';
import 'package:socialv/utils/cached_network_image.dart';

import '../../../store/profile_menu_store.dart';
import '../../../utils/app_constants.dart';

class AchievementScreen extends StatefulWidget {
  const AchievementScreen({super.key});

  @override
  State<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen> {
  ProfileMenuStore achievementStore = ProfileMenuStore();

  int mPage = 1;
  bool mIsLastPage = false;

  @override
  void initState() {
    if (appStore.achievementEndPoints.validate().isNotEmpty) {
      achievementStore.setAchievementType(appStore.achievementEndPoints[0]);
      init();
    }

    super.initState();
  }

  Future<void> init() async {
    appStore.setLoading(true);

    achievementStore.achievementFuture = getGamiPressRewardsList(
      page: mPage,
      slug: achievementStore.selectedAchievement!.slug,
      rankList: achievementStore.achievementList,
      lastPageCallback: (p0) {
        mIsLastPage = p0;
      },
    ).then((value) {
      appStore.setLoading(false);
      return value;
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  Future<void> onRefresh() async {
    mPage = 1;
    init();
  }

  Future<void> onNextPage() async {
    if (!mIsLastPage) {
      mPage = mPage++;
      init();
    }
  }

  void showBadgeDetailsDialog(BuildContext context, CommonGamiPressModel data) {
    String getDialogTitle() {
      if (achievementStore.selectedAchievement != null) {
        return '${achievementStore.selectedAchievement!.singularName} Details';
      }
      return 'Details'; // fallback
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return data.hasEarned.validate()
            ? Dialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Container(
                  width: context.width() * 0.85,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(getDialogTitle(), style: boldTextStyle(size: 18, color: Colors.black)).center(),
                          Positioned(right: 0, child: CloseButton()),
                        ],
                      ),
                      24.height,
                      cachedImage(
                        width: 60,
                        height: 60,
                        data.image.validate().isNotEmpty ? data.image.validate() : ic_default_ranks,
                        fit: BoxFit.cover,
                      ).cornerRadiusWithClipRRect(16),
                      16.height,
                      Text(parseHtmlString(data.title!.rendered.validate()), style: boldTextStyle(size: 16, color: Colors.black), textAlign: TextAlign.center),
                      16.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text(language.points, style: secondaryTextStyle(size: 12)),
                              4.height,
                              Text('100', style: boldTextStyle(color: Colors.black, size: 18)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  5,
                                  (index) => Icon(Icons.star, color: Colors.yellow, size: 20),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      16.height,
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(language.congratulatesYouAreAchieve, style: boldTextStyle(size: 14), textAlign: TextAlign.center),
                      ),
                      16.height,
                      AppButton(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        text: language.done.capitalizeFirstLetter(),
                        elevation: 0,
                        width: double.infinity,
                        textStyle: boldTextStyle(color: Colors.white),
                        onTap: () => finish(context),
                        color: context.primaryColor,
                        shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ],
                  ),
                ),
              )

            ///Not Earned Dialog
            : Dialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Container(
                  width: context.width() * 0.85,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(16)),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Center(
                            child: Text(getDialogTitle(),
                                style: boldTextStyle(
                                  size: 18,
                                ))),
                        Positioned(right: 0, child: CloseButton()),
                      ],
                    ),
                    24.height,
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        cachedImage(
                          width: 60,
                          height: 60,
                          data.image.validate().isNotEmpty ? data.image.validate() : ic_default_ranks,
                          fit: BoxFit.cover,
                        ).cornerRadiusWithClipRRect(16),
                        Icon(Icons.lock, color: Color(0xFFFCD7F32).withValues(alpha: 0.5), size: 60),
                      ],
                    ),
                    16.height,
                    Text(parseHtmlString(data.title!.rendered.validate()),
                        style: boldTextStyle(
                          size: 16,
                        ),
                        textAlign: TextAlign.center),
                    16.height,
                    Text(
                      'You haven\'t earned this ${achievementStore.selectedAchievement?.singularName.toLowerCase() ?? 'achievement'} yet!',
                      style: boldTextStyle(size: 14),
                      textAlign: TextAlign.center,
                    ),
                    16.height,
                    AppButton(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      text: language.done.capitalizeFirstLetter(),
                      elevation: 0,
                      width: double.infinity,
                      textStyle: boldTextStyle(color: Colors.white),
                      onTap: () => finish(context),
                      color: context.primaryColor,
                      shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ]),
                ),
              );
      },
    );
  }

  @override
  void dispose() {
    appStore.setLoading(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: language.achievements,
      child: AnimatedScrollView(
        listAnimationType: ListAnimationType.None,
        padding: EdgeInsets.only(bottom: 30, left: 16, right: 16),
        physics: AlwaysScrollableScrollPhysics(),
        refreshIndicatorColor: appColorPrimary,
        onSwipeRefresh: () {
          return onRefresh();
        },
        onNextPage: onNextPage,
        children: [
          if (appStore.achievementEndPoints.isNotEmpty) ...[
            Observer(
              builder: (context) => HorizontalList(
                padding: EdgeInsets.only(bottom: 16),
                runSpacing: 8,
                spacing: 8,
                itemCount: appStore.achievementEndPoints.validate().length,
                itemBuilder: (context, index) {
                  return Observer(
                    builder: (context) => InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () {
                        if (achievementStore.selectedAchievementTypeIndex == index) return;
                        achievementStore.setSelectedAchievementTypeIndex(index);
                        achievementStore.setAchievementType(appStore.achievementEndPoints.validate()[index]);
                        onRefresh();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                        decoration: BoxDecoration(color: achievementStore.selectedAchievementTypeIndex == index ? context.primaryColor : context.cardColor, borderRadius: radius()),
                        child: Text(
                          appStore.achievementEndPoints.validate()[index].pluralName,
                          style: boldTextStyle(color: achievementStore.selectedAchievementTypeIndex == index ? Colors.white : context.primaryColor),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Observer(
              builder: (context) {
                return FutureBuilder(
                  future: achievementStore.achievementFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasError)
                      return NoDataWidget(
                        imageWidget: NoDataLottieWidget(),
                        title: snapshot.error.toString(),
                        onRetry: () {
                          mPage = 1;
                          init();
                        },
                        retryText: '   ${language.clickToRefresh}   ',
                      ).center();
                    else {
                      if (achievementStore.achievementList.isEmpty)
                        return SizedBox(
                          height: context.height() / 2,
                          width: context.width(),
                          child: NoDataWidget(
                            imageWidget: NoDataLottieWidget(),
                            title: language.noDataFound,
                            onRetry: () {
                              mPage = 1;
                              init();
                            },
                            retryText: '   ${language.clickToRefresh}   ',
                          ).center(),
                        ).visible(!appStore.isLoading);
                      else
                        return AnimatedWrap(
                          slideConfiguration: SlideConfiguration(delay: 80.milliseconds, verticalOffset: 300),
                          itemCount: achievementStore.achievementList.length,
                          spacing: 16,
                          runSpacing: 16,
                          itemBuilder: (context, index) {
                            CommonGamiPressModel data = achievementStore.achievementList[index];
                            return GestureDetector(
                              onTap: () {
                                showBadgeDetailsDialog(context, data);
                              },
                              child: Stack(
                                children: [
                                  Container(
                                    width: context.width() / 2 - 32,
                                    height: 145,
                                    padding: EdgeInsets.only(left: 16, right: 16, top: 38, bottom: 16),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: context.primaryColor, width: 1.5),
                                    ),
                                    child: Column(
                                      children: [
                                        cachedImage(
                                          height: 60,
                                          width: 60,
                                          data.image.validate().isNotEmpty ? data.image.validate() : ic_default_ranks,
                                          fit: BoxFit.cover,
                                        ).cornerRadiusWithClipRRect(30),
                                        8.height,
                                        Marquee(child: Text(parseHtmlString(data.title!.rendered.validate()), style: boldTextStyle(color: Colors.black))),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      decoration: boxDecorationDefault(
                                        color: Colors.green,
                                        borderRadius: radius(commonRadius),
                                      ),
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      child: Text(
                                        language.earned,
                                        style: boldTextStyle(color: Colors.white, size: 12),
                                      ),
                                    ),
                                  ).visible(data.hasEarned.validate()),
                                  Positioned(top: 8, right: 8, child: Icon(Icons.lock_outline, color: Color(0xFFFCD7F32), size: 24)).visible(!data.hasEarned.validate()),
                                ],
                              ),
                            );
                          },
                        );
                    }
                  },
                );
              },
            )
          ] else
            Observer(
              builder: (context) {
                return SizedBox(
                  height: context.height() * 0.65,
                  width: context.width(),
                  child: NoDataWidget(
                    imageWidget: NoDataLottieWidget(),
                    title: language.noDataFound,
                    onRetry: () {
                      if (appStore.achievementEndPoints.validate().isNotEmpty) {
                        achievementStore.setAchievementType(appStore.achievementEndPoints[0]);
                        init();
                      }
                    },
                    retryText: '   ${language.clickToRefresh}   ',
                  ).center(),
                ).visible(!appStore.isLoading);
              },
            )
        ],
      ),
    );
  }
}
