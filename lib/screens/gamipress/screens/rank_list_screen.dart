import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/base_scaffold_widget.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/gamipress/common_gamipress_model.dart';
import 'package:socialv/network/gamipress_repository.dart';
import 'package:socialv/utils/app_constants.dart';
import 'package:socialv/utils/cached_network_image.dart';

import '../../../store/profile_menu_store.dart';

class RankScreen extends StatefulWidget {
  const RankScreen({super.key});

  @override
  State<RankScreen> createState() => _RankScreenState();
}

class _RankScreenState extends State<RankScreen> {
  ProfileMenuStore rankStore = ProfileMenuStore();

  int mPage = 1;
  bool mIsLastPage = false;

  @override
  void initState() {
    if (appStore.gamipressRankEndPoints.validate().isNotEmpty) {
      rankStore.setSelectedRankType(appStore.gamipressRankEndPoints.validate()[0]);
      init();
    }

    super.initState();
  }

  Future<void> init() async {
    appStore.setLoading(true);

    rankStore.rankFuture = getGamiPressRewardsList(
      page: mPage,
      slug: rankStore.selectedRank!.slug,
      rankList: rankStore.rankList,
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

  @override
  void dispose() {
    appStore.setLoading(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: language.ranks,
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
          if (appStore.gamipressRankEndPoints.isNotEmpty) ...[
            Observer(
              builder: (context) => HorizontalList(
                padding: EdgeInsets.only(bottom: 16),
                itemCount: appStore.gamipressRankEndPoints.validate().length,
                runSpacing: 8,
                spacing: 8,
                itemBuilder: (context, index) {
                  return Observer(
                    builder: (context) {
                      return InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () {
                          if (rankStore.selectedRankTypeIndex == index) return;
                          rankStore.setSelectedRankTypeIndex(index);
                          rankStore.setSelectedRankType(appStore.gamipressRankEndPoints.validate()[index]);
                          onRefresh();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                          decoration: BoxDecoration(color: rankStore.selectedRankTypeIndex == index ? context.primaryColor : context.cardColor, borderRadius: radius()),
                          child: Text(
                            appStore.gamipressRankEndPoints.validate()[index].pluralName,
                            style: boldTextStyle(color: rankStore.selectedRankTypeIndex == index ? Colors.white : context.primaryColor),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Observer(
              builder: (context) => FutureBuilder(
                future: rankStore.rankFuture,
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
                    if (rankStore.rankList.isEmpty)
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
                        itemCount: rankStore.rankList.length,
                        runSpacing: 16,
                        spacing: 16,
                        itemBuilder: (context, index) {
                          CommonGamiPressModel level = rankStore.rankList[index];
                          return Container(
                            padding: EdgeInsets.all(16),
                            width: context.width(),
                            decoration: BoxDecoration(color: context.cardColor, borderRadius: radius(commonRadius)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                cachedImage(level.image.validate().isNotEmpty ? level.image.validate() : ic_default_ranks, height: 100, fit: BoxFit.cover).center(),
                                16.height,
                                Text(parseHtmlString(level.title!.rendered.validate()), style: primaryTextStyle()).center(),
                                8.height.visible(level.content!.rendered.validate().isNotEmpty),
                                Text(
                                  parseHtmlString(level.content!.rendered.validate()),
                                  style: secondaryTextStyle(),
                                  textAlign: TextAlign.center,
                                ),
                                if (level.requirements.validate().isNotEmpty && level.requirements!.first.title!.isNotEmpty ) ...[
                                  Text('${language.requirements}:(${level.requirements.validate().length})', style: primaryTextStyle()),
                                  8.height,
                                  Column(
                                    children: level.requirements.validate().map((e) {
                                      return UL(
                                        symbolType: SymbolType.Bullet,
                                        children: [
                                          Text(
                                            ' ${parseHtmlString(e.title.validate())}',
                                            style: secondaryTextStyle(decoration: e.hasEarned.validate() ? TextDecoration.overline : TextDecoration.none),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          )
                                        ],
                                      ).visible(e.title != "");
                                    }).toList(),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      );
                  }
                },
              ),
            ),
          ] else
            Observer(
              builder: (context) => SizedBox(
                height: context.height() * 0.65,
                width: context.width(),
                child: NoDataWidget(
                  imageWidget: NoDataLottieWidget(),
                  title: language.noDataFound,
                  onRetry: () {
                    if (appStore.gamipressRankEndPoints.validate().isNotEmpty) {
                      rankStore.setSelectedRankType(appStore.gamipressRankEndPoints.validate()[0]);
                      init();
                    }
                  },
                  retryText: '   ${language.clickToRefresh}   ',
                ).center(),
              ).visible(!appStore.isLoading),
            )
        ],
      ),
    );
  }
}
