import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/story/story_views_model.dart';
import 'package:socialv/models/story/user_story_model.dart';
import 'package:socialv/models/story/user_story_reaction_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/profile/screens/member_profile_screen.dart';
import 'package:socialv/store/fragment_store/home_fragment_store.dart';
import 'package:socialv/utils/app_constants.dart';
import 'package:socialv/utils/cached_network_image.dart';

class StoryViewsScreen extends StatefulWidget {
  final int? storyId;
  final int viewCount;
  final ScrollController? controller;
  final List<Item>? list;
  final int? storyIndex;
  final Function(bool)? onStoryDeleted;

  StoryViewsScreen({
    required this.storyId,
    required this.viewCount,
    this.controller,
    this.list,
    this.storyIndex,
    this.onStoryDeleted,
  });

  @override
  State<StoryViewsScreen> createState() => _StoryViewsScreenState();
}

class _StoryViewsScreenState extends State<StoryViewsScreen> {
  final HomeFragStore storyViewsScreenVars = HomeFragStore();
  late ReactionDisposer storyPageReactionDisposer;
  late ReactionDisposer pageErrorReactionDisposer;

  @override
  void initState() {
    super.initState();
    setupStoryPageReactions();
    _initializeData();
  }

  ///Page reactions for story views
  void setupStoryPageReactions() {
    storyPageReactionDisposer = reaction(
      (_) => storyViewsScreenVars.currentPage,
      (page) {
        if (page > 1 && !storyViewsScreenVars.isLastPage) {
          getViews();
        }
      },
    );
    pageErrorReactionDisposer = reaction(
      (_) => storyViewsScreenVars.hasError,
      (hasError) {
        if (hasError) {
          toast(language.somethingWentWrong, print: true);
        }
      },
    );
  }

  ///Initialize data
  Future<void> _initializeData() async {
    await getViews();
    await fetchUserReactions();
  }

  ///Fetch user reactions
  Future<void> fetchUserReactions() async {
    try {
      final reactions = await getStoryReactions(storyId: widget.storyId.validate());
      storyViewsScreenVars.userStoryReactionList.clear();
      storyViewsScreenVars.userStoryReactionList.addAll(reactions);
    } catch (e) {
      log('Error fetching user reactions: $e');
    }
  }

  ///Get story views
  Future<void> getViews() async {
    storyViewsScreenVars.setStoryViewsLoading = true;
    await getStoryViews(storyId: widget.storyId.validate()).then((value) {
      if (storyViewsScreenVars.isLastPage == 1) storyViewsScreenVars.storyMemberList.clear();
      storyViewsScreenVars.isLastPage = value.length != 20;
      storyViewsScreenVars.storyMemberList.addAll(value);
      storyViewsScreenVars.isError = false;
      storyViewsScreenVars.setStoryViewsLoading = false;
    }).catchError((e) {
      storyViewsScreenVars.isError = true;
      storyViewsScreenVars.setStoryViewsLoading = false;
      toast(e.toString(), print: true);
    });
  }

// region Story delete
  Future<void> _handleDeleteStory() async {
    showConfirmDialogCustom(
      context,
      onAccept: (c) {
        ifNotTester(() {
          appStore.setLoading(true);

          deleteStory(
            storyId: widget.storyId.validate(),
            status: StoryHighlightOptions.delete,
            type: StoryHighlightOptions.story,
          ).then((value) {
            toast(value.message);

            runInAction(() {
              bool isRemoved = false;
              homeFragStore.currentUserStory.value.items?.removeWhere((element) {
                if (element.id == widget.storyId) {
                  isRemoved = true;
                  return true;
                }
                return false;
              });
              widget.onStoryDeleted?.call(isRemoved);
              if (isRemoved) {
                finish(context);
                _handleStoryNavigation();
              }
            });
            appStore.setLoading(false);
          }).catchError((e) {
            appStore.setLoading(false);
            toast(e.toString());
          });
        });
      },
      dialogType: DialogType.DELETE,
      title: language.deleteStoryConfirmation,
      positiveText: language.delete,
    );
  }

  void _handleStoryNavigation() {
    if (widget.storyIndex != null) {
      runInAction(() {
        final items = homeFragStore.currentUserStory.value.items;
        if (items.validate().isNotEmpty) {
          if (widget.storyIndex! < (items.validate().length - 1)) {
            homeFragStore.setCurrentStoryIndex(widget.storyIndex! + 1);
          } else if (widget.storyIndex! > 0) {
            homeFragStore.setCurrentStoryIndex(widget.storyIndex! - 1);
          } else {
            finish(context);
          }
        }
      });
    }
  }

  void _handleLoadMore() {
    if (!storyViewsScreenVars.isLastPage) {
      runInAction(() {
        storyViewsScreenVars.setCurrentPage(storyViewsScreenVars.currentPage + 1);
      });
    }
  }

//endregion

  @override
  void dispose() {
    storyPageReactionDisposer();
    pageErrorReactionDisposer();
    storyViewsScreenVars.setStoryViewsLoading = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Observer(builder: (context) {
          return storyViewsScreenVars.isError && !storyViewsScreenVars.setStoryViewsLoading
              ? NoDataWidget(
                  imageWidget: NoDataLottieWidget(),
                  title: storyViewsScreenVars.isError ? language.somethingWentWrong : language.noDataFound,
                ).center()
              : Offstage();
        }),
        Observer(builder: (context) {
          return storyViewsScreenVars.storyMemberList.isEmpty && !storyViewsScreenVars.isError && !storyViewsScreenVars.setStoryViewsLoading
              ? SizedBox(
                  height: context.height() * 0.5,
                  child: NoDataWidget(
                    imageWidget: NoDataLottieWidget(),
                    title: language.noDataFound,
                  ).center(),
                )
              : Offstage();
        }),
        Observer(builder: (context) {
          return storyViewsScreenVars.storyMemberList.isNotEmpty && !storyViewsScreenVars.isError
              ? SingleChildScrollView(
                  controller: widget.controller,
                  child: AnimatedListView(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    slideConfiguration: SlideConfiguration(
                      delay: 120.milliseconds,
                    ),
                    padding: EdgeInsets.only(left: 16, right: 16, bottom: 50, top: 60),
                    itemCount: storyViewsScreenVars.storyMemberList.length,
                    itemBuilder: (context, index) {
                      StoryViewsModel member = storyViewsScreenVars.storyMemberList[index];
                      UserStoryReactionList? memberReaction;
                      try {
                        memberReaction = storyViewsScreenVars.userStoryReactionList.firstWhere((r) => r.userId == member.userId.toString());
                      } catch (e) {
                        memberReaction = null;
                      }
                      final bool hasValidReaction = memberReaction != null && memberReaction.reactionImage != null && memberReaction.reactionImage!.url.validate().isNotEmpty;
                      return GestureDetector(
                        onTap: () {
                          MemberProfileScreen(memberId: storyViewsScreenVars.storyMemberList[index].userId.validate()).launch(context);
                        },
                        child: Row(
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                cachedImage(
                                  member.userAvatar.validate(),
                                  height: 56,
                                  width: 56,
                                  fit: BoxFit.cover,
                                ).cornerRadiusWithClipRRect(100),
                                if (hasValidReaction)
                                  Positioned(
                                    bottom: -5.5,
                                    right: -5.5,
                                    child: Container(
                                      height: 24,
                                      width: 24,
                                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                                      padding: EdgeInsets.all(2),
                                      child: cachedImage(memberReaction.reactionImage!.url.validate(), fit: BoxFit.contain),
                                    ),
                                  ),
                              ],
                            ),
                            20.width,
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      member.userName.validate(),
                                      style: boldTextStyle(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ).flexible(flex: 1),
                                    if (member.isUserVerified.validate()) Image.asset(ic_tick_filled, width: 18, height: 18, color: blueTickColor).paddingSymmetric(horizontal: 4),
                                  ],
                                ),
                                6.height,
                                Text(member.mentionName.validate(), style: secondaryTextStyle(), maxLines: 1, overflow: TextOverflow.ellipsis),
                              ],
                              crossAxisAlignment: CrossAxisAlignment.start,
                            ).expand(),
                            Text(convertToAgo(member.seenTime.validate().toString()), style: secondaryTextStyle()),
                          ],
                        ).paddingSymmetric(vertical: 8),
                      ).visible(member.userId.toString() != userStore.loginUserId);
                    },
                    onNextPage: _handleLoadMore,
                  ),
                )
              : Offstage();
        }),
        Container(
          width: context.width(),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            color: context.primaryColor,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${language.viewedBy} ${widget.viewCount}', style: primaryTextStyle(color: Colors.white)),
              Icon(Icons.delete_outline, color: Colors.white).onTap(() {
                _handleDeleteStory();
              }),
            ],
          ),
        ),
        Observer(builder: (_) {
          return Positioned(
            bottom: storyViewsScreenVars.isLastPage != 1 ? 10 : null,
            child: LoadingWidget(isBlurBackground: storyViewsScreenVars.isLastPage == 1 ? true : false),
          ).visible(storyViewsScreenVars.setStoryViewsLoading);
        }),
      ],
    );
  }
}