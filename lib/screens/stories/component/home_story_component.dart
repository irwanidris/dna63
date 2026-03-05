import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:lottie/lottie.dart';
import 'package:mobx/mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/file_picker_dialog_component.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/story/user_story_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/stories/screen/user_story_page.dart';
import 'package:socialv/screens/stories/screen/create_story_screen.dart';
import 'package:socialv/screens/stories/screen/story_page.dart';
import 'package:socialv/store/fragment_store/home_fragment_store.dart';
import 'package:socialv/utils/cached_network_image.dart';

import '../../../../utils/app_constants.dart';

class HomeStoryComponent extends StatefulWidget {
  final VoidCallback? callback;

  HomeStoryComponent({this.callback});

  @override
  State<HomeStoryComponent> createState() => _HomeStoryComponentState();
}

class _HomeStoryComponentState extends State<HomeStoryComponent> with TickerProviderStateMixin {
  HomeFragStore homeStoryComponentVars = HomeFragStore();

  @override
  void initState() {
    super.initState();
    getStories();
    initCurrentUserStory();

    LiveStream().on(GetUserStories, (p0) {
      getStories();
      getUserStory();
    });
  }

  /// Get Friends stories
  Future<void> getStories() async {
    if (!appStore.isLoggedIn) return;
    appStore.setStoryLoader(true);
    try {
      homeStoryComponentVars.homeStoryList.clear();
      var value = await getUserStories();

      for (var element in value) {
        element.animationController = AnimationController(
          vsync: this,
          duration: Duration(milliseconds: 2500),
          lowerBound: 0.0,
          upperBound: 1.0,
        );
      }

      homeStoryComponentVars.homeStoryList.addAll(value);
    } catch (e) {
      if (mounted) {
        appStore.setStoryLoader(false);
        if (e.toString() != "Stories Not found.") {
          toast(e.toString(), print: true);
        }
      }
    } finally {
      appStore.setStoryLoader(false);
    }
  }

//region User Story Functions
  /// Border Color changing logic
  Color getBorderColor(BuildContext context) {
    final hasStories = homeStoryComponentVars.currentUserStory.value.items.validate().isNotEmpty;
    final hasUnseenStories = hasStories && homeStoryComponentVars.currentUserStory.value.items.validate().any((story) => !story.seen.validate());

    if (!hasStories) return Colors.transparent;
    if (hasUnseenStories) return appColorPrimary;
    return Colors.grey.withValues(alpha: 0.7);
  }

  /// Get current user story and handle view logic
  Future<void> getCurrentUserStory() async {
    if (!appStore.isLoggedIn) return;

    try {
      appStore.setLoading(true);
      final response = await getUserStory();

      if (response?.items.validate().isEmpty ?? true) return;

      final bool hasUnseenStories = response!.items.validate().any((story) => !story.seen.validate());

      updateCurrentUserStory(response, hasUnseenStories: hasUnseenStories);

      await UserStoryPage(initialIndex: 0, initialStoryIndex: 0).launch(context);

      if (!hasUnseenStories) return;

      final updatedResponse = await getUserStory();
      if (updatedResponse?.items.validate().isNotEmpty ?? false) {
        updateCurrentUserStory(updatedResponse!, seen: true);
      }
    } catch (e) {
      if (e.toString() != "Stories Not found.") {
        toast(e.toString(), print: true);
      }
    } finally {
      appStore.setLoading(false);
    }
  }

  /// Update current user story state
  void updateCurrentUserStory(UserStoryData response, {bool? seen, bool? hasUnseenStories}) {
    runInAction(() {
      response.showBorder = response.items.validate().isNotEmpty;
      response.seen = seen ?? !hasUnseenStories!;

      if (seen == true) {
        response.items?.forEach((story) => story.seen = true);
      }

      homeStoryComponentVars.currentUserStory.value = response;
      userStore.setLoginAvatarUrl(homeStoryComponentVars.currentUserStory.value.avatarUrl.validate());
      homeFragStore.currentUserStory = Observable(response);
    });
  }

  /// Initialize current user story
  Future<void> initCurrentUserStory() async {
    if (!appStore.isLoggedIn) return;

    try {
      final response = await getUserStory();
      if (response?.items.validate().isEmpty ?? true) return;

      final bool hasUnseenStories = response!.items.validate().any((story) => !story.seen.validate());
      updateCurrentUserStory(response, hasUnseenStories: hasUnseenStories);
    } catch (e) {
      if (e.toString() != "Stories Not found.") {
        toast(e.toString(), print: true);
      }
    }
  }

  //endregion

//region File Selection Functions
  /// Handle file selection for story creation
  Future<void> handleFileSelection(FileTypes file) async {
    try {
      switch (file) {
        case FileTypes.CAMERA:
          await handleCameraImage();
          break;
        case FileTypes.CAMERA_VIDEO:
          await handleCameraVideo();
          break;
        default:
          await handleGalleryMedia();
      }
    } catch (e) {
      appStore.setLoading(false);
      toast(file == FileTypes.CAMERA_VIDEO ? language.videoNotUploaded : language.imageNotSelected, print: true);
    }
  }

  Future<void> handleCameraImage() async {
    final image = await getImageSource(isCamera: true);
    appStore.setLoading(false);

    final result = await CreateStoryScreen(cameraImage: image).launch(context);

    if (result ?? false) {
      final freshResponse = await getUserStory();
      if (freshResponse?.items.validate().isNotEmpty ?? false) {
        updateCurrentUserStory(freshResponse!, seen: false);
      }
    } else {
      toast(language.imageNotSelected);
    }
  }

  Future<void> handleCameraVideo() async {
    final video = await getImageSource(isCamera: true, isVideo: true);
    appStore.setLoading(false);

    final result = await CreateStoryScreen(cameraImage: video, isCameraVideo: true).launch(context);

    if (result ?? false) {
      runInAction(() {
        UserStoryData currentStory = homeStoryComponentVars.currentUserStory.value;
        currentStory.showBorder = true;
        currentStory.seen = false;
        homeStoryComponentVars.currentUserStory.value = currentStory;
      });
      await initCurrentUserStory();
    } else {
      toast(language.videoNotUploaded);
    }
  }

  Future<void> handleGalleryMedia() async {
    final mediaList = await getMultipleImages(allowedTypeList: appStore.storyAllowedMediaType);
    appStore.setLoading(false);

    if (mediaList.isEmpty) return;

    final result = await CreateStoryScreen(mediaList: mediaList).launch(context);

    if (result ?? false) {
      runInAction(() {
        UserStoryData currentStory = homeStoryComponentVars.currentUserStory.value;
        currentStory.showBorder = true;
        currentStory.seen = false;
        homeStoryComponentVars.currentUserStory.value = currentStory;
      });
      await initCurrentUserStory();
    }
  }

//endregion

  @override
  void dispose() {
    LiveStream().dispose(GetUserStories);
    homeStoryComponentVars.homeStoryList.forEach((e) => e.animationController!.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CurrentUserStory(context),
                  Observer(builder: (context) {
                    return homeStoryComponentVars.homeStoryList.isNotEmpty && !appStore.showStoryLoader
                        ? HorizontalList(
                            padding: EdgeInsets.only(left: 0, bottom: 8, right: 8, top: 8),
                            spacing: 8,
                            itemCount: homeStoryComponentVars.homeStoryList.length,
                            itemBuilder: (context, index) {
                              return StoryItem(context, index);
                            },
                          )
                        : Offstage();
                  }),
                ],
              ),
            ),
          ),
          // ThreeBounceLoadingWidget().visible(appStore.showStoryLoader)
        ],
      ),
    );
  }

  /// Build current user story
  Widget CurrentUserStory(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Observer(builder: (context) {
              return Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: context.scaffoldBackgroundColor,
                  shape: BoxShape.circle,
                  border: homeStoryComponentVars.currentUserStory.value.items.validate().isEmpty
                      ? Border.all(color: Colors.transparent)
                      : Border.all(
                          color: getBorderColor(context),
                          width: 2,
                        ),
                ),
                child: cachedImage(
                  userStore.loginAvatarUrl,
                  height: 54,
                  width: 52,
                  fit: BoxFit.cover,
                ).cornerRadiusWithClipRRect(100),
              ).onTap(() {
                getCurrentUserStory();
              });
            }),
            Positioned(
              right: 0,
              left: 0,
              bottom: -10,
              child: Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: appColorPrimary,
                  shape: BoxShape.circle,
                  border: Border.all(color: context.scaffoldBackgroundColor, width: 2),
                ),
                child: Icon(Icons.add, color: Colors.white, size: 16).onTap(
                  () async {
                    FileTypes? file = await showInDialog(
                      context,
                      backgroundColor: context.scaffoldBackgroundColor,
                      contentPadding: EdgeInsets.symmetric(vertical: 16),
                      title: Text(language.chooseAnAction, style: boldTextStyle()),
                      builder: (p0) {
                        return FilePickerDialog(isSelected: true, showCameraVideo: true);
                      },
                    );
                    if (file != null) {
                      await handleFileSelection(file);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        10.height,
        Text(language.yourStory, style: secondaryTextStyle(size: 12, color: appColorPrimary, weight: FontWeight.w500)),
      ],
    ).paddingRight(8);
  }

  /// Build Friends story item
  Widget StoryItem(BuildContext context, int index) {
    final story = homeStoryComponentVars.homeStoryList[index];
    return SizedBox(
      width: 60,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Hero(
                tag: "${story.name}",
                child: Container(
                  decoration: BoxDecoration(
                    color: context.scaffoldBackgroundColor,
                    shape: BoxShape.circle,
                    border: !story.showBorder.validate()
                        ? Border.all(color: context.scaffoldBackgroundColor)
                        : Border.all(
                            color: story.seen.validate() ? Colors.grey.withValues(alpha: 0.7) : appColorPrimary,
                            width: 2,
                          ),
                  ),
                  padding: EdgeInsets.all(2),
                  child: cachedImage(
                    story.avatarUrl,
                    height: 54,
                    width: 54,
                    fit: BoxFit.cover,
                  ).cornerRadiusWithClipRRect(100),
                ),
              ).onTap(
                () {
                  if (!story.seen.validate()) {
                    story.animationController!.forward();
                    story.showBorder = false;
                    story.animationController!.addListener(() {
                      if (story.animationController!.isCompleted) {
                        StoryPage(
                          initialIndex: index,
                          stories: homeStoryComponentVars.homeStoryList,
                          initialStoryIndex: story.items!.indexWhere((element) => !element.seen.validate()),
                        ).launch(context).then((value) async {
                          story.showBorder = true;

                          await 500.milliseconds.delay;
                          homeStoryComponentVars.homeStoryList.clear();
                          getStories();
                        });
                      }
                    });
                  } else {
                    StoryPage(
                      initialIndex: index,
                      stories: homeStoryComponentVars.homeStoryList,
                    ).launch(context);
                  }
                },
              ),
              if (homeStoryComponentVars.homeStoryList.isNotEmpty && !story.showBorder.validate() && !story.seen.validate())
                Lottie.asset(
                  story_loader,
                  height: 60,
                  width: 60,
                  fit: BoxFit.cover,
                  controller: story.animationController!,
                ),
            ],
          ),
          8.height,
          Text(
            story.name.validate().split(" ").first,
            style: secondaryTextStyle(size: 12, color: context.iconColor, weight: FontWeight.w500),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
