import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/file_picker_dialog_component.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/story/user_story_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/stories/screen/create_story_screen.dart';
import 'package:socialv/screens/stories/screen/user_story_page.dart';
import 'package:socialv/store/fragment_store/home_fragment_store.dart';
import 'package:socialv/utils/cached_network_image.dart';
import 'package:socialv/utils/colors.dart';
import 'package:socialv/utils/common.dart';
import 'package:socialv/utils/constants.dart';

class ProfileHeaderComponent extends StatefulWidget {
  final String avatarUrl;
  final String? cover;

  ProfileHeaderComponent({required this.avatarUrl, this.cover});

  @override
  State<ProfileHeaderComponent> createState() => _ProfileHeaderComponentState();
}

class _ProfileHeaderComponentState extends State<ProfileHeaderComponent> {
  HomeFragStore homeStoryComponentVars = HomeFragStore();

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

  void updateCurrentUserStory(UserStoryData response, {bool? seen, bool? hasUnseenStories}) {
    runInAction(() {
      response.showBorder = response.items
          .validate()
          .isNotEmpty;
      response.seen = seen ?? !hasUnseenStories!;

      if (seen == true) {
        response.items?.forEach((story) => story.seen = true);
      }
    });
  }

  Future<void> handleCameraImage() async {
    final image = await getImageSource(isCamera: true);
    appStore.setLoading(false);

    final result = await CreateStoryScreen(cameraImage: image).launch(context);

    if (result ?? false) {
      final freshResponse = await getUserStory();
      if (freshResponse?.items
          .validate()
          .isNotEmpty ?? false) {
        updateCurrentUserStory(freshResponse!, seen: false);
      }
    } else {
      toast(language.imageNotSelected);
    }
  }

  /// Initialize current user story
  Future<void> initCurrentUserStory() async {
    if (!appStore.isLoggedIn) return;

    try {
      final response = await getUserStory();
      if (response?.items
          .validate()
          .isEmpty ?? true) return;

      final bool hasUnseenStories = response!.items.validate().any((story) => !story.seen.validate());
      updateCurrentUserStory(response, hasUnseenStories: hasUnseenStories);
    } catch (e) {
      if (e.toString() != "Stories Not found.") {
        toast(e.toString(), print: true);
      }
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

  Future<void> getCurrentUserStory() async {
    if (!appStore.isLoggedIn) return;

    try {
      appStore.setLoading(true);
      final response = await getUserStory();

      if (response?.items
          .validate()
          .isEmpty ?? true) return;

      final bool hasUnseenStories = response!.items.validate().any((story) => !story.seen.validate());

      updateCurrentUserStory(response, hasUnseenStories: hasUnseenStories);

      await UserStoryPage(initialIndex: 0, initialStoryIndex: 0).launch(context);

      if (!hasUnseenStories) return;

      final updatedResponse = await getUserStory();
      if (updatedResponse?.items
          .validate()
          .isNotEmpty ?? false) {
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: widget.avatarUrl.isNotEmpty ? context.height() * 0.26 : context.height() * 0.2,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              widget.cover
                  .validate()
                  .isNotEmpty
                  ? cachedImage(
                widget.cover,
                width: context.width(),
                height: context.height() * 0.2,
                fit: BoxFit.cover,
              )
                  : Image.asset(
                AppImages.profileBackgroundImage,
                width: context.width(),
                height: context.height() * 0.2,
                fit: BoxFit.cover,
              ),
              Positioned(
                bottom: 0,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 2), shape: BoxShape.circle),
                      child: cachedImage(widget.avatarUrl, height: 88, width: 88, fit: BoxFit.cover).cornerRadiusWithClipRRect(100),
                    ).onTap(() {
                      getCurrentUserStory();
                    }),
                    Positioned(
                      right: -70,
                      left: 0,
                      bottom: 7,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: appColorPrimary,
                          shape: BoxShape.circle,
                          border: Border.all(color: context.scaffoldBackgroundColor, width: 2),
                        ),
                        child: Icon(Icons.add, color: Colors.white, size: 18).onTap(
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
              ).visible(widget.avatarUrl.isNotEmpty),
            ],
          ),
        ),
      ],
    );
  }
}
