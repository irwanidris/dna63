import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/file_picker_dialog_component.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/story/common_story_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/stories/component/attch_link_dialog.dart';
import 'package:socialv/screens/stories/component/set_story_duration.dart';
import 'package:socialv/screens/stories/component/story_video_component.dart';
import 'package:socialv/store/fragment_store/home_fragment_store.dart';
import 'package:socialv/utils/cached_network_image.dart';
import 'package:socialv/utils/colors.dart';
import 'package:socialv/utils/common.dart';
import 'package:socialv/utils/constants.dart';
import 'package:socialv/utils/images.dart';
import 'package:video_player/video_player.dart';

class CreateStoryScreen extends StatefulWidget {
  final File? cameraImage;
  final List<MediaSourceModel>? mediaList;
  final String? categoryId;
  final String? categoryName;
  final File? categoryImage;
  final bool isHighlight;
  final bool isCameraVideo;

  const CreateStoryScreen({this.cameraImage, this.mediaList, this.categoryId, this.categoryName, this.categoryImage, this.isHighlight = false, this.isCameraVideo = false});

  @override
  State<CreateStoryScreen> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen> {
  HomeFragStore createStoryScreenVars = HomeFragStore();
  TextEditingController storyTextController = TextEditingController();
  TextEditingController storyDurationController = TextEditingController();

  PageController pageController = PageController();

  @override
  void initState() {
    super.initState();
    setStatusBarColor(Colors.transparent);

    if (widget.cameraImage != null && widget.isCameraVideo) {
      createStoryScreenVars.storyMediaList.add(MediaSourceModel(
        mediaFile: widget.cameraImage!,
        extension: widget.cameraImage!.path.validate().split("/").last.split(".").last,
        mediaType: MediaTypes.video,
      ));

      getVideoDuration(widget.cameraImage!).then((duration) {
        if (duration != null) {
          createStoryScreenVars.setStoryContent(
            CreateStoryModel(storyDuration: duration.inSeconds.toString()),
            createStoryScreenVars.storyContentList.length,
          );
        } else {
          createStoryScreenVars.setStoryContent(
            CreateStoryModel(storyDuration: storyDuration),
            createStoryScreenVars.storyContentList.length,
          );
        }
      });
    } else if (widget.cameraImage != null) {
      // Handle image case
      createStoryScreenVars.storyMediaList.add(
        MediaSourceModel(
          mediaFile: widget.cameraImage!,
          extension: widget.cameraImage!.path.validate().split("/").last.split(".").last,
          mediaType: MediaTypes.photo,
        ),
      );
      createStoryScreenVars.setStoryContent(
        CreateStoryModel(storyDuration: storyDuration),
        createStoryScreenVars.storyContentList.length,
      );
    }

    if (widget.mediaList != null) {
      createStoryScreenVars.storyMediaList.addAll(widget.mediaList.validate());

      // Process each media item
      widget.mediaList?.forEach((element) async {
        if (element.mediaType == MediaTypes.video) {
          final duration = await getVideoDuration(element.mediaFile);
          int index = createStoryScreenVars.storyMediaList.indexOf(element);

          if (duration != null) {
            createStoryScreenVars.setStoryContent(
              CreateStoryModel(storyDuration: duration.inSeconds.toString()),
              index,
            );
          } else {
            createStoryScreenVars.setStoryContent(
              CreateStoryModel(storyDuration: storyDuration),
              index,
            );
          }
        } else {
          createStoryScreenVars.setStoryContent(
            CreateStoryModel(storyDuration: storyDuration),
            createStoryScreenVars.storyContentList.length,
          );
        }
      });
    }
  }

  Future<Duration?> getVideoDuration(File videoFile) async {
    VideoPlayerController? controller;
    try {
      controller = VideoPlayerController.file(videoFile);
      await controller.initialize();
      final duration = controller.value.duration;
      return duration;
    } catch (e) {
      log('Error getting video duration: $e');
      return null;
    } finally {
      await controller?.dispose();
    }
  }

  @override
  void dispose() {
    setStatusBarColorBasedOnTheme();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: createStoryScreenVars.doResize,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Observer(builder: (context) {
              if (createStoryScreenVars.storyMediaList.isEmpty || createStoryScreenVars.storyContentList.isEmpty) {
                return SizedBox();
              }
              return PageView.builder(
                controller: pageController,
                itemCount: createStoryScreenVars.storyMediaList.length,
                onPageChanged: (index) {
                  createStoryScreenVars.selectedMediaIndex = index;
                  if (createStoryScreenVars.storyContentList[index].storyText.validate().isNotEmpty) {
                    storyTextController.text = createStoryScreenVars.storyContentList[index].storyText.validate();
                  } else {
                    storyTextController.text = '';
                  }
                  createStoryScreenVars.linkText = createStoryScreenVars.storyContentList[index].storyLink != null ? createStoryScreenVars.storyContentList[index].storyLink.validate() : "";
                },
                itemBuilder: (ctx, index) {
                  if (createStoryScreenVars.storyMediaList[index].mediaType == MediaTypes.video) {
                    return CreateVideoStory(videoFile: createStoryScreenVars.storyMediaList[index].mediaFile);
                  } else {
                    return Image.file(createStoryScreenVars.storyMediaList[index].mediaFile, height: context.height(), width: context.width(), fit: BoxFit.cover);
                  }
                },
              );
            }),
            Positioned(
              top: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: FractionalOffset.topCenter,
                    end: FractionalOffset.bottomCenter,
                    colors: [
                      ...List<Color>.generate(20, (index) => Colors.black.withAlpha(index * 10)).reversed,
                      Colors.transparent,
                      Colors.transparent,
                    ],
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 20),
                width: context.width(),
                child: Observer(builder: (context) {
                  if (createStoryScreenVars.storyContentList.isEmpty || createStoryScreenVars.selectedMediaIndex >= createStoryScreenVars.storyContentList.length) {
                    return const SizedBox();
                  }
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Image.asset(ic_close_square, color: Colors.white, height: 30, width: 30, fit: BoxFit.cover),
                        onPressed: () {
                          if (appStore.isLoading) appStore.setLoading(false);
                          finish(context);
                        },
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Image.asset(ic_hyperlink, color: Colors.white, height: 28, width: 28, fit: BoxFit.cover),
                            onPressed: () {
                              createStoryScreenVars.doResize = false;
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AttachLinkDialog(
                                    linkText: createStoryScreenVars.linkText,
                                    onSubmit: (text) {
                                      createStoryScreenVars.linkText = text;
                                      createStoryScreenVars.storyContentList[createStoryScreenVars.selectedMediaIndex].storyLink = text;
                                      finish(context);
                                    },
                                  );
                                },
                              ).then((value) => createStoryScreenVars.doResize = true);
                            },
                          ),
                          8.width,
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: context.scaffoldBackgroundColor,
                                    shape: RoundedRectangleBorder(borderRadius: radius(defaultRadius)),
                                    title: Text(language.setStoryDuration, style: boldTextStyle()),
                                    content: SetStoryDuration(
                                      onTap: (val) {
                                        createStoryScreenVars.storyContentList[createStoryScreenVars.selectedMediaIndex].storyDuration = val.toString();
                                        finish(context);
                                      },
                                      initialValue: createStoryScreenVars.storyContentList[createStoryScreenVars.selectedMediaIndex].storyDuration.toInt(),
                                    ),
                                  );
                                },
                              );
                            },
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)),
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    '${createStoryScreenVars.storyContentList[createStoryScreenVars.selectedMediaIndex].storyDuration}s',
                                    style: secondaryTextStyle(color: Colors.white, size: 12),
                                  ),
                                ),
                                Positioned(
                                  bottom: -4,
                                  right: -4,
                                  child: Container(
                                    decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                    child: Icon(Icons.access_time_filled, color: context.primaryColor, size: 18),
                                  ),
                                )
                              ],
                            ),
                          ) /*.visible(!isCurrentMediaVideo)*/,
                          8.width,
                        ],
                      )
                    ],
                  ).paddingTop(16);
                }),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: FractionalOffset.topCenter,
                  end: FractionalOffset.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    ...List<Color>.generate(20, (index) => Colors.black.withAlpha(index * 10)),
                  ],
                ),
              ),
              padding: EdgeInsets.fromLTRB(8, 16, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: cardBackgroundBlackDark,
                          border: Border.all(color: context.primaryColor.withValues(alpha: 0.5)),
                          borderRadius: radius(defaultAppButtonRadius),
                        ),
                        height: 86,
                        width: 70,
                        child: Icon(Icons.add, color: Colors.white),
                        margin: EdgeInsets.only(bottom: 8),
                      ).onTap(() async {
                        FileTypes? file = await showInDialog(
                          context,
                          contentPadding: EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: context.scaffoldBackgroundColor,
                          title: Text(language.chooseAnAction, style: boldTextStyle()),
                          builder: (p0) {
                            return FilePickerDialog(isSelected: true);
                          },
                        );

                        if (file != null) {
                          if (file == FileTypes.CAMERA) {
                            await getImageSource(isCamera: true).then((value) {
                              createStoryScreenVars.storyMediaList.add(
                                MediaSourceModel(
                                  mediaFile: value!,
                                  extension: value.path.validate().split("/").last.split(".").last,
                                  mediaType: MediaTypes.photo,
                                ),
                              );
                              createStoryScreenVars.storyContentList.add(CreateStoryModel(storyDuration: storyDuration));
                            }).catchError((e) {
                              appStore.setLoading(false);
                            });
                          } else {
                            await getMultipleImages(allowedTypeList: appStore.storyAllowedMediaType).then((value) {
                              createStoryScreenVars.storyMediaList.addAll(value);
                              value.forEach((element) {
                                createStoryScreenVars.storyContentList.add(CreateStoryModel(storyDuration: storyDuration));
                              });
                            });
                          }
                        }
                      }),
                      8.width,
                      Observer(builder: (context) {
                        return Container(
                          height: 90,
                          width: 70,
                          child: Theme(
                            data: ThemeData(canvasColor: Colors.transparent),
                            child: ReorderableListView(
                              scrollDirection: Axis.horizontal,
                              onReorder: (int oldIndex, int newIndex) {
                                if (oldIndex < newIndex) {
                                  newIndex -= 1;
                                }
                                final MediaSourceModel item = createStoryScreenVars.storyMediaList.removeAt(oldIndex);
                                createStoryScreenVars.storyMediaList.insert(newIndex, item);
                              },
                              children: createStoryScreenVars.storyMediaList.map((e) {
                                int index = createStoryScreenVars.storyMediaList.indexOf(e);
                                if (createStoryScreenVars.storyMediaList[index].mediaType == MediaTypes.video) {
                                  return Stack(
                                    key: Key('$index'),
                                    children: [
                                      Container(
                                        margin: EdgeInsets.symmetric(horizontal: 4),
                                        decoration: BoxDecoration(
                                          border: createStoryScreenVars.selectedMediaIndex == index ? Border.all(color: context.primaryColor) : Border(),
                                          borderRadius: radius(defaultAppButtonRadius),
                                        ),
                                        height: 86,
                                        width: 70,
                                        child: CreateVideoThumbnail(videoFile: createStoryScreenVars.storyMediaList[index].mediaFile),
                                      ),
                                      Container(
                                        child: Image.asset(ic_close, width: 10, height: 10, color: context.primaryColor),
                                        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                        padding: EdgeInsets.all(4),
                                        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      ).onTap(() {
                                        createStoryScreenVars.storyMediaList.removeAt(index);
                                      }),
                                    ],
                                  );
                                } else {
                                  return Stack(
                                    key: Key('$index'),
                                    alignment: Alignment.topRight,
                                    children: [
                                      Column(
                                        children: [
                                          Container(
                                            margin: EdgeInsets.symmetric(horizontal: 4),
                                            decoration: BoxDecoration(
                                              border: createStoryScreenVars.selectedMediaIndex == index ? Border.all(color: context.primaryColor) : Border(),
                                              borderRadius: radius(defaultAppButtonRadius),
                                            ),
                                            child: Image.file(
                                              createStoryScreenVars.storyMediaList[index].mediaFile,
                                              height: 86,
                                              width: 70,
                                              fit: BoxFit.cover,
                                            ).cornerRadiusWithClipRRect(defaultAppButtonRadius),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        child: Image.asset(ic_close, width: 10, height: 10, color: context.primaryColor),
                                        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                        padding: EdgeInsets.all(4),
                                        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      ).onTap(() {
                                        createStoryScreenVars.storyMediaList.removeAt(index);
                                      }),
                                    ],
                                  );
                                }
                              }).toList(),
                            ),
                          ),
                        ).expand();
                      }),
                    ],
                  ),
                  8.height,
                  SizedBox(
                    height: 56,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        AppTextField(
                          autoFocus: false,
                          controller: storyTextController,
                          cursorColor: Colors.white,
                          textStyle: secondaryTextStyle(color: Colors.white),
                          textFieldType: TextFieldType.OTHER,
                          onChanged: (text) {
                            createStoryScreenVars.storyContentList[createStoryScreenVars.selectedMediaIndex].storyText = text;
                          },
                          onFieldSubmitted: (text) {
                            createStoryScreenVars.storyContentList[createStoryScreenVars.selectedMediaIndex].storyText = text;
                          },
                          decoration: InputDecoration(
                            hintText: language.addText,
                            hintStyle: secondaryTextStyle(color: Colors.grey.shade500),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(100),
                              borderSide: BorderSide(width: 1.0, color: Colors.white),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(100),
                              borderSide: BorderSide(width: 1.0, color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(100),
                              borderSide: BorderSide(width: 1.0, color: Colors.white),
                            ),
                          ),
                        ).expand(),
                        8.width,
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(color: context.primaryColor, shape: BoxShape.circle),
                          child: Image.asset(ic_send, height: 28, width: 28, fit: BoxFit.fill, color: Colors.white),
                        ).onTap(() async {
                          if (/*widget.isHighlight &&*/ appStore.storyActions.validate().any((element) => element.action == StoryHighlightOptions.trash)) {
                            showInDialog(
                              context,
                              backgroundColor: context.cardColor,
                              contentPadding: EdgeInsets.zero,
                              builder: (BuildContext context) {
                                return Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(color: context.cardColor, borderRadius: radius()),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextIcon(
                                        text: language.saveStoryToDraft,
                                        textStyle: primaryTextStyle(color: appStore.isDarkMode ? bodyDark : bodyWhite),
                                        expandedText: true,
                                        prefix: cachedImage(ic_edit, height: 18, width: 18, fit: BoxFit.cover, color: appStore.isDarkMode ? bodyDark : bodyWhite),
                                        onTap: () {
                                          createStoryScreenVars.status = StoryHighlightOptions.draft;
                                          finish(context);
                                        },
                                      ),
                                      Divider(),
                                      TextIcon(
                                        text: language.publish,
                                        expandedText: true,
                                        prefix: cachedImage(ic_send, height: 18, width: 18, fit: BoxFit.cover, color: appStore.isDarkMode ? bodyDark : bodyWhite),
                                        textStyle: primaryTextStyle(color: appStore.isDarkMode ? bodyDark : bodyWhite),
                                        onTap: () {
                                          createStoryScreenVars.status = StoryHighlightOptions.publish;
                                          finish(context);
                                        },
                                      ),
                                      Divider(),
                                      TextIcon(
                                        text: language.cancel,
                                        expandedText: true,
                                        textStyle: primaryTextStyle(color: appStore.isDarkMode ? bodyDark : bodyWhite),
                                        prefix: cachedImage(ic_close_square, height: 18, width: 18, fit: BoxFit.cover, color: appStore.isDarkMode ? bodyDark : bodyWhite),
                                        onTap: () {
                                          createStoryScreenVars.status = null;
                                          finish(context);
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ).then((value) {
                              if (createStoryScreenVars.status != null && !appStore.isLoading) {
                                ifNotTester(() async {
                                  appStore.setLoading(true);
                                  uploadStory(
                                    context,
                                    contentList: createStoryScreenVars.storyContentList,
                                    fileList: createStoryScreenVars.storyMediaList,
                                    status: createStoryScreenVars.status,
                                  ).then((value) {}).catchError((e) {
                                    appStore.setLoading(false);
                                    toast(e.toString());
                                  });
                                });
                              }
                            });
                          } else {
                            if (!appStore.isLoading) {
                              ifNotTester(() async {
                                appStore.setLoading(true);
                                uploadStory(
                                  context,
                                  contentList: createStoryScreenVars.storyContentList,
                                  fileList: createStoryScreenVars.storyMediaList,
                                  isHighlight: widget.isHighlight,
                                  highlightId: widget.categoryId,
                                  highlightImage: widget.categoryImage,
                                  highlightName: widget.categoryName,
                                ).catchError((e) {
                                  appStore.setLoading(false);
                                  toast(e.toString());
                                });
                              });
                            }
                          }
                        }),
                      ],
                    ),
                  ),
                  8.height,
                ],
              ),
            ),
            Observer(builder: (_) => LoadingWidget().center().visible(appStore.isLoading))
          ],
        ),
      ),
    );
  }
}
