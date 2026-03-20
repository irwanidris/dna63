import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/story/story_response_model.dart' hide StoryItem;
import 'package:socialv/models/story/user_story_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/stories/component/story_video_component.dart';
import 'package:socialv/screens/stories/component/story_views_component.dart';
import 'package:socialv/utils/cached_network_image.dart';
import 'package:socialv/utils/colors.dart';
import 'package:socialv/utils/common.dart';
import 'package:socialv/utils/constants.dart';
import 'package:socialv/utils/images.dart';
import 'package:story_time/story_time.dart';
import 'package:story_view/story_view.dart';
import 'package:video_player/video_player.dart';

VideoPlayerController? globalVideoPlayerController;

class UserStoryPage extends StatefulWidget {
  final VoidCallback? callback;
  final int initialIndex;
  final int? initialStoryIndex;
  final List<StoryResponseModel>? viewList;
  final bool fromUserStory;

  UserStoryPage({
    required this.initialIndex,
    this.initialStoryIndex,
    this.viewList,
    this.callback,
    this.fromUserStory = false,
  });

  @override
  UserStoryPageState createState() => UserStoryPageState();
}

class UserStoryPageState extends State<UserStoryPage> {
  late ValueNotifier<IndicatorAnimationCommand> indicatorAnimationController;
  late ReactionDisposer storyIndexViewDisposer;
  final StoryController controller = StoryController();
  bool isDisposed = false;

  @override
  void initState() {
    super.initState();

    indicatorAnimationController = ValueNotifier<IndicatorAnimationCommand>(
      IndicatorAnimationCommand(resume: true),
    );

    homeFragStore.setCurrentUserIndex(widget.initialIndex);
    homeFragStore.setCurrentStoryIndex(widget.initialStoryIndex ?? 0);
    homeFragStore.setMediaLoading(false); // Reset media loading state
    setStatusBarColor(Colors.transparent);

    storyIndexViewDisposer = reaction(
      (_) => homeFragStore.currentUserStory.value.items,
      (items) {
        if (items.validate().isEmpty) {
          Future.microtask(() => safeFinish());
        } else {
          validateStoryIndex();
        }
      },
      fireImmediately: true,
    );
  }

  /// Handle story deletion
  void handleStoryDeletion(Item story) {
    runInAction(() {
      if (homeFragStore.currentUserStory.value.items.validate().isNotEmpty) {
        homeFragStore.currentUserStory.value.items!.removeWhere((element) => element.id == story.id);
        if (homeFragStore.currentUserStory.value.items?.isEmpty ?? true) {
          Future.microtask(() => safeFinish());
        } else {
          validateStoryIndex();
        }
      }
    });
  }

  /// Show views and delete Story bottom sheet
  Future<void> viewsBottomSheet(BuildContext context, Item story) async {
    pauseStory();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.8,
          builder: (context, controller) {
            return Container(
              decoration: BoxDecoration(
                color: context.scaffoldBackgroundColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: StoryViewsScreen(
                storyId: story.id,
                viewCount: story.viewCount.validate(),
                controller: controller,
                storyIndex: homeFragStore.currentStoryIndex,
                onStoryDeleted: (isRemoved) {
                  if (isRemoved) {
                    handleStoryDeletion(story);
                  }
                },
              ),
            );
          },
        );
      },
    ).then((_) => resumeStory());
  }

//region Story Control

  void pauseStory() {
    indicatorAnimationController.value = IndicatorAnimationCommand(pause: true);
    if (globalVideoPlayerController != null) {
      globalVideoPlayerController!.pause();
    }
  }

  void resumeStory() {
    if (!homeFragStore.isMediaLoading) {
      indicatorAnimationController.value = IndicatorAnimationCommand(resume: true);
      if (globalVideoPlayerController != null) {
        globalVideoPlayerController!.play();
      }
    }
  }

  void validateStoryIndex() {
    final items = homeFragStore.currentUserStory.value.items;

    if (items.validate().isNotEmpty) {
      if (homeFragStore.currentStoryIndex >= items.validate().length) {
        homeFragStore.setCurrentStoryIndex(items.validate().length - 1);
      }
    } else {
      homeFragStore.setCurrentStoryIndex(0);
    }
  }

  void safeFinish() {
    if (!isDisposed && mounted) {
      finish(context);
    }
  }

//endregion

  @override
  void dispose() {
    isDisposed = true;
    if (widget.fromUserStory && homeFragStore.storyViewed) widget.callback?.call();
    setStatusBarColorBasedOnTheme();
    indicatorAnimationController.dispose();
    storyIndexViewDisposer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.delta.dy > 10) {
            safeFinish();
          }
        },
        child: Observer(builder: (context) {
          return StoryPageView(
            indicatorPadding: EdgeInsets.only(top: 40),
            onStoryIndexChanged: (int newStoryIndex) async {
              homeFragStore.setCurrentStoryIndex(newStoryIndex);
              if (homeFragStore.currentUserStory.value.items.validate().isNotEmpty) {
                if (homeFragStore.currentUserStory.value.items.validate().length > newStoryIndex) {
                  final currentStory = homeFragStore.currentUserStory.value.items![newStoryIndex];
                  if (currentStory.duration.validate().isNotEmpty) {
                    indicatorAnimationController.value = IndicatorAnimationCommand(
                      duration: Duration(seconds: int.parse(currentStory.duration!)),
                    );
                  }
                }
                if (homeFragStore.currentStoryIndex >= homeFragStore.currentUserStory.value.items.validate().length) {
                  finish(context);
                  return;
                }
              }
            },
            itemBuilder: (context, pageIndex, storyIndex) {
              if (storyIndex >= (homeFragStore.currentUserStory.value.items?.length ?? 0)) {
                finish(context);
                return const SizedBox();
              }
              homeFragStore.setCurrentUserIndex(pageIndex);
              homeFragStore.setCurrentStoryIndex(storyIndex);

              try {
                if (homeFragStore.currentUserStory.value.items.validate().isNotEmpty && storyIndex < homeFragStore.currentUserStory.value.items.validate().length) {
                  final story = homeFragStore.currentUserStory.value.items![storyIndex];

                  if (!story.seen.validate()) {
                    viewStory(storyId: story.id.validate()).then((value) {
                      if (!homeFragStore.storyViewed) homeFragStore.setStoryViewed(true);
                    }).catchError((e) {
                      log('Error viewing story: $e');
                      toast(e.toString());
                    });
                  }
                  return buildStoryView(homeFragStore.currentUserStory.value.name ?? "", story, context);
                }
              } catch (e) {
                log('Error in itemBuilder: $e');
              }
              return Center(child: Text(language.noStoryAvailable));
            },
            indicatorAnimationController: indicatorAnimationController,
            initialPage: widget.initialIndex,
            pageLength: 1,
            storyLength: (int pageIndex) {
              if (homeFragStore.currentUserStory.value.items.validate().isNotEmpty) {
                return homeFragStore.currentUserStory.value.items.validate().length;
              }
              return 0;
            },
            initialStoryIndex: (x) => widget.initialStoryIndex ?? 0,
            onPageLimitReached: () {
              finish(context);
            },
            onStoryUnpaused: () {
              print("Story is unpaused!!");
              resumeStory();
            },
            onStoryPaused: () {
              print("Story is paused!!");
              pauseStory();
            },
            gestureItemBuilder: (context, pageIndex, storyIndex) {
              if (homeFragStore.currentUserStory.value.items.validate().isNotEmpty) {
                final story = homeFragStore.currentUserStory.value.items.validate()[storyIndex];
                return Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 32),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          color: Colors.white,
                          icon: const Icon(Icons.remove_red_eye_outlined),
                          onPressed: () => viewsBottomSheet(context, story),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 30,
                      child: Column(
                        children: [
                          if (story.storyText.validate().isNotEmpty)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              width: context.width(),
                              decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6)),
                              child: Text(
                                story.storyText.validate(),
                                style: boldTextStyle(color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          16.height,
                          if (story.storyLink.validate().isNotEmpty)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: radius(defaultRadius),
                              ),
                              child: Text(language.visitLink, style: boldTextStyle(color: Colors.white)),
                            ).onTap(() {
                              openWebPage(context, url: story.storyLink.validate());
                            }, borderRadius: radius(defaultRadius)),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return Center(child: Text('No story available'));
            },
          );
        }),
      ),
    );
  }

  Widget buildStoryView(String name, Item story, BuildContext context) {
    return Hero(
      tag: name,
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          children: [
            Positioned.fill(child: Container(color: Colors.black)),
            Positioned.fill(
              child: story.mediaType == MediaTypes.photo
                  ? CachedNetworkImage(
                      imageUrl: story.storyMedia.validate(),
                      width: context.width(),
                      height: context.height(),
                      imageBuilder: (context, imageProvider) {
                        indicatorAnimationController.value = IndicatorAnimationCommand(resume: true);
                        return Container(
                          width: context.width(),
                          height: context.height(),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.contain,
                            ),
                          ),
                        );
                      },
                      placeholder: (value, url) {
                        return LoadingWidget().center();
                      },
                      errorWidget: (context, url, error) {
                        return Center(child: Icon(Icons.error));
                      },
                    )
                  : StoryVideoPostComponent(
                      videoURl: story.storyMedia.validate(),
                      onVideoInitialized: () {
                        indicatorAnimationController.value = IndicatorAnimationCommand(resume: true);
                      },
                      onVideoLoading: () {
                        indicatorAnimationController.value = IndicatorAnimationCommand(pause: true);
                      },
                    ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: FractionalOffset.topCenter,
                  end: FractionalOffset.bottomCenter,
                  colors: [
                    ...List<Color>.generate(20, (index) => Colors.grey.shade700.withAlpha(index * 10)).reversed,
                    Colors.transparent,
                  ],
                ),
              ),
              padding: const EdgeInsets.only(top: 46, left: 16, bottom: 20),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  cachedImage(homeFragStore.currentUserStory.value.avatarUrl, fit: BoxFit.cover, height: 48, width: 48).cornerRadiusWithClipRRect(24),
                  16.width,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${homeFragStore.currentUserStory.value.name.validate()} ',
                              style: TextStyle(
                                fontSize: 17,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: fontFamily,
                              ),
                            ),
                            if (homeFragStore.currentUserStory.value.isUserVerified.validate()) WidgetSpan(child: Image.asset(ic_tick_filled, height: 18, width: 18, color: blueTickColor, fit: BoxFit.cover)),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                      ),
                      Text(timeStampToDate(story.time.validate()), style: secondaryTextStyle(color: Colors.white)),
                    ],
                  ).flexible(flex: 1),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
