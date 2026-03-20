import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/store/fragment_store/home_fragment_store.dart';
import 'package:socialv/utils/cached_network_image.dart';

import '../../../components/loading_widget.dart';
import '../../../components/no_data_lottie_widget.dart';
import '../../../main.dart';
import '../../../models/reactions/reactions_count_model.dart';
import '../../../network/rest_apis.dart';
import '../../../utils/constants.dart';
import '../components/reaction_list_component.dart';

class ReactionScreen extends StatefulWidget {
  final int postId;
  final bool isCommentScreen;

  const ReactionScreen({Key? key, required this.postId, required this.isCommentScreen}) : super(key: key);

  @override
  State<ReactionScreen> createState() => _ReactionScreenState();
}

class _ReactionScreenState extends State<ReactionScreen> {
  HomeFragStore reactionScreenVars = HomeFragStore();
  int mPage = 1;
  bool mIsLastPage = false;

  @override
  void initState() {
    super.initState();
    reactionScreenVars.reactionsCount.clear();
    reactionList();
  }

  void reactionList() async {
    if (mPage == 1) reactionScreenVars.reactionsList.clear();
    appStore.setLoading(true);
    await getUsersReaction(
      id: widget.postId,
      isComments: widget.isCommentScreen,
      page: mPage,
    ).then((value) {
      mIsLastPage = value.reactions.validate().length != PER_PAGE;
      reactionScreenVars.reactionsList.addAll(value.reactions.validate());
      if (reactionScreenVars.reactionsCount.isEmpty) reactionScreenVars.reactionsCount.addAll(value.count.validate());
      appStore.setLoading(false);
    }).catchError((e) {
      reactionScreenVars.isError = true;

      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  Future<void> onRefresh() async {
    reactionScreenVars.isError = false;
    mPage = 1;
    reactionList();
  }

  @override
  void dispose() {
    appStore.setLoading(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        onRefresh();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(language.reactions, style: boldTextStyle(size: 20)),
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: context.iconColor),
            onPressed: () {
              finish(context);
            },
          ),
        ),
        body: Stack(
          alignment: Alignment.topCenter,
          children: [
            Observer(builder: (context) {
              return NoDataWidget(
                imageWidget: NoDataLottieWidget(),
                title: reactionScreenVars.isError ? language.somethingWentWrong : language.noDataFound,
                onRetry: () {
                  onRefresh();
                },
                retryText: '   ${language.clickToRefresh}   ',
              ).visible((reactionScreenVars.isError || reactionScreenVars.reactionsList.isEmpty) && !appStore.isLoading).center();
            }),
            Observer(builder: (context) {
              return AnimatedListView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(left: 16, right: 16, bottom: 50, top: 50),
                slideConfiguration: SlideConfiguration(
                  delay: 80.milliseconds,
                  verticalOffset: 300,
                ),
                shrinkWrap: true,
                itemCount: reactionScreenVars.reactionsList.length,
                itemBuilder: (p0, index) {
                  if (reactionScreenVars.reactionsList[index].id == reactionScreenVars.selectedReaction) {
                    return ReactionListComponent(
                      reaction: reactionScreenVars.reactionsList[index],
                      index: index,
                    );
                  } else if (reactionScreenVars.selectedReaction.isEmpty) {
                    return ReactionListComponent(
                      reaction: reactionScreenVars.reactionsList[index],
                      index: index,
                    );
                  } else {
                    return Offstage();
                  }
                },
                onNextPage: () {
                  if (!mIsLastPage) {
                    mPage++;
                    reactionList();
                  }
                },
              ).visible(reactionScreenVars.reactionsList.isNotEmpty);
            }),
            Observer(builder: (context) {
              return Align(
                alignment: Alignment.topLeft,
                child: HorizontalList(
                  itemCount: reactionScreenVars.reactionsCount.length,
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  spacing: 0,
                  runSpacing: 0,
                  itemBuilder: (ctx, index) {
                    Reactions e = reactionScreenVars.reactionsCount[index];
                    if (e.count != 0)
                      return TextIcon(
                        onTap: () {
                          if (reactionScreenVars.selectedReaction != e.id) {
                            if (e.id == "0") {
                              reactionScreenVars.selectedReaction = "";
                            } else {
                              reactionScreenVars.selectedReaction = e.id.validate();
                            }
                            mPage = 1;
                            reactionList();
                          }
                        },
                        text: e.id == "0" ? '${e.title.validate().capitalizeFirstLetter()} (${e.count.validate()})' : e.count.validate().toString(),
                        textStyle: secondaryTextStyle(size: 16),
                        prefix: e.icon.validate().isNotEmpty
                            ? cachedImage(
                                e.icon.validate(),
                                width: 16,
                                height: 16,
                                fit: BoxFit.cover,
                              )
                            : Offstage(),
                      );
                    else
                      return Offstage();
                  },
                ),
              ).visible(reactionScreenVars.reactionsCount.length > 0);
            }),
            Observer(
              builder: (_) {
                if (appStore.isLoading) {
                  return Positioned(
                    bottom: mPage != 1 ? 10 : null,
                    child: LoadingWidget(isBlurBackground: mPage == 1 ? true : false),
                  );
                } else {
                  return Offstage();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
