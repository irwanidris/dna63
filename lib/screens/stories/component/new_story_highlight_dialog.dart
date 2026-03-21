import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/file_picker_dialog_component.dart';
import 'package:socialv/main.dart';
import 'package:socialv/screens/stories/screen/create_story_screen.dart';
import 'package:socialv/store/profile_menu_store.dart';
import 'package:socialv/utils/app_constants.dart';
import 'package:socialv/utils/cached_network_image.dart';

import '../../../models/story/common_story_model.dart';
import '../../../models/story/highlight_stories_model.dart';

class NewStoryHighlightDialog extends StatefulWidget {
  final List<HighlightStoriesModel> highlightList;
  final VoidCallback? callback;

  NewStoryHighlightDialog({required this.highlightList, this.callback});

  @override
  State<NewStoryHighlightDialog> createState() =>
      _NewStoryHighlightDialogState();
}

class _NewStoryHighlightDialogState extends State<NewStoryHighlightDialog> {
  TextEditingController categoryName = TextEditingController();
  ProfileMenuStore newStoryHighlightDialogVars = ProfileMenuStore();

  @override
  void initState() {
    super.initState();

    if (widget.highlightList.isNotEmpty) {
      newStoryHighlightDialogVars.dialogHighlightList
          .addAll(widget.highlightList);
      newStoryHighlightDialogVars.dialogDropdownValue =
          widget.highlightList.validate().first;
      newStoryHighlightDialogVars.showNewCategory = false;
    } else {
      newStoryHighlightDialogVars.showNewCategory = true;
    }
  }

  Future<bool> isValidImage(File file) async {
    try {
      await decodeImageFromList(await file.readAsBytes());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> onAddStory() async {
    FileTypes? file = await showInDialog(
      context,
      contentPadding: EdgeInsets.symmetric(vertical: 16),
      backgroundColor: context.scaffoldBackgroundColor,
      title: Text(language.chooseAnAction, style: boldTextStyle()),
      builder: (p0) {
        return FilePickerDialog(
          isSelected: true,
          showCameraVideo: true,
        );
      },
    );

    if (file != null) {
      if (file == FileTypes.CAMERA) {
        appStore.setLoading(true);
        await getImageSource(isCamera: true).then((value) async {
          bool isValid = await isValidImage(value!);
          if (!isValid) {
            appStore.setLoading(false);
            toast(language.selectedImageIsCorrupt);
            return;
          }

          appStore.setLoading(false);
          finish(context);
          CreateStoryScreen(
            cameraImage: value,
            categoryId: newStoryHighlightDialogVars.showNewCategory
                ? ''
                : newStoryHighlightDialogVars.dialogDropdownValue.categoryId
                    .validate()
                    .toString(),
            categoryName: newStoryHighlightDialogVars.showNewCategory
                ? categoryName.text.validate()
                : newStoryHighlightDialogVars.dialogDropdownValue.categoryName,
            categoryImage: newStoryHighlightDialogVars.categoryPic,
            isHighlight: true,
          ).launch(context).then((value) {
            LiveStream().emit(OnAddPostProfile);
            widget.callback?.call();
          });
        }).catchError((e) {
          appStore.setLoading(false);
        });
      } else if (file == FileTypes.CAMERA_VIDEO) {
        appStore.setLoading(true);
        await getImageSource(isCamera: true, isVideo: true).then((value) async {
          appStore.setLoading(false);
          finish(context);
          CreateStoryScreen(
            cameraImage: value,
            isCameraVideo: true,
            categoryId: newStoryHighlightDialogVars.showNewCategory
                ? ''
                : newStoryHighlightDialogVars.dialogDropdownValue.categoryId
                    .validate()
                    .toString(),
            categoryName: newStoryHighlightDialogVars.showNewCategory
                ? categoryName.text.validate()
                : newStoryHighlightDialogVars.dialogDropdownValue.categoryName,
            categoryImage: newStoryHighlightDialogVars.categoryPic,
            isHighlight: true,
          ).launch(context).then((value) {
            LiveStream().emit(OnAddPostProfile);
            widget.callback?.call();
          });
        }).catchError((e) {
          appStore.setLoading(false);
        });
      } else {
        log("${appStore.storyAllowedMediaType}");
        appStore.setLoading(true);
        await getMultipleImages(allowedTypeList: appStore.storyAllowedMediaType)
            .then((List<MediaSourceModel> value) async {
          List<MediaSourceModel> validMediaList = [];

          for (MediaSourceModel media in value) {
            // Only validate images, skip validation for other types
            if (['jpeg', 'jpg', 'png', 'webp', 'gif']
                .contains(media.extension.toLowerCase())) {
              bool isValid = await isValidImage(media.mediaFile);
              if (!isValid) {
                toast(language.multipleSelectedImageIsCorrupt);
                continue;
              }
            }
            // Add all files that pass backend validation
            validMediaList.add(media);
          }

          appStore.setLoading(false);

          if (validMediaList.isNotEmpty) {
            finish(context);
            CreateStoryScreen(
              mediaList: validMediaList,
              categoryId: newStoryHighlightDialogVars.showNewCategory
                  ? ''
                  : newStoryHighlightDialogVars.dialogDropdownValue.categoryId
                      .validate()
                      .toString(),
              categoryName: newStoryHighlightDialogVars.showNewCategory
                  ? categoryName.text.validate()
                  : newStoryHighlightDialogVars
                      .dialogDropdownValue.categoryName,
              categoryImage: newStoryHighlightDialogVars.categoryPic,
              isHighlight: true,
            ).launch(context).then((value) {
              LiveStream().emit(OnAddPostProfile);
              widget.callback?.call();
            });
          }
        }).catchError((e) {
          appStore.setLoading(false);
        });
      }
    }
  }

  @override
  void dispose() {
    newStoryHighlightDialogVars.showHighlightStory = false;
    newStoryHighlightDialogVars.showNewCategory = false;
    if (appStore.isLoading) appStore.setLoading(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: radius(defaultAppButtonRadius),
          color: context.cardColor,
        ),
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Observer(builder: (context) {
                return Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: () {
                      newStoryHighlightDialogVars.showNewCategory =
                          !newStoryHighlightDialogVars.showNewCategory;
                    },
                    child: Text(
                        newStoryHighlightDialogVars.showNewCategory
                            ? language.selectHighlight
                            : language.createNew,
                        style: primaryTextStyle(color: context.primaryColor)),
                  ),
                ).visible(
                    newStoryHighlightDialogVars.dialogHighlightList.isNotEmpty);
              }),
              16.height.visible(
                  newStoryHighlightDialogVars.dialogHighlightList.isEmpty),
              Observer(builder: (context) {
                return newStoryHighlightDialogVars.showNewCategory.validate()
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(language.storyHighlightImage,
                              style: boldTextStyle()),
                          16.height,
                          Observer(builder: (context) {
                            return DottedBorderWidget(
                              radius: 60,
                              dotsWidth: 8,
                              color: context.primaryColor,
                              child: newStoryHighlightDialogVars.categoryPic ==
                                      null
                                  ? InkWell(
                                      onTap: () async {
                                        FileTypes? file = await showInDialog(
                                          context,
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 16),
                                          backgroundColor: context.scaffoldBackgroundColor,
                                          title: Text(language.chooseAnAction,
                                              style: boldTextStyle()),
                                          builder: (p0) {
                                            return FilePickerDialog(
                                              isSelected: true,
                                            );
                                          },
                                        );

                                        if (file != null) {
                                          if (file == FileTypes.CAMERA) {
                                            await getImageSource()
                                                .then((value) {
                                              appStore.setLoading(false);
                                              newStoryHighlightDialogVars
                                                  .categoryPic = value;
                                            }).catchError((e) {
                                              appStore.setLoading(false);
                                            });
                                          } else {
                                            await getImageSource(
                                                    isCamera: false)
                                                .then((value) {
                                              appStore.setLoading(false);
                                              newStoryHighlightDialogVars
                                                  .categoryPic = value;
                                            }).catchError((e) {
                                              appStore.setLoading(false);
                                            });
                                          }
                                        }
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: context.cardColor,
                                          shape: BoxShape.circle,
                                        ),
                                        height: 120,
                                        width: 120,
                                        child: Text(
                                          language.selectHighlightImage,
                                          style: secondaryTextStyle(),
                                          textAlign: TextAlign.center,
                                        ).center(),
                                      ),
                                    )
                                  : Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        cachedImage(
                                          newStoryHighlightDialogVars
                                              .categoryPic!.path,
                                          height: 120,
                                          width: 120,
                                          fit: BoxFit.cover,
                                        ).cornerRadiusWithClipRRect(60),
                                        Positioned(
                                          bottom: 8,
                                          child: InkWell(
                                            onTap: () {
                                              newStoryHighlightDialogVars
                                                  .categoryPic = null;
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                  color: Colors.grey
                                                      .withValues(alpha: 0.7),
                                                  shape: BoxShape.circle),
                                              child: cachedImage(ic_close,
                                                  color: context.primaryColor,
                                                  width: 18,
                                                  height: 18,
                                                  fit: BoxFit.cover),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                            ).center();
                          }),
                          8.height,
                          Text(language.recommendedSize,
                                  style: secondaryTextStyle(size: 12))
                              .center(),
                          16.height,
                          AppTextField(
                            controller: categoryName,
                            keyboardType: TextInputType.name,
                            textInputAction: TextInputAction.next,
                            textFieldType: TextFieldType.NAME,
                            textStyle: primaryTextStyle(),
                            maxLines: 1,
                            decoration: inputDecorationFilled(context,
                                label: language.highlightName,
                                fillColor: context.scaffoldBackgroundColor),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(language.selectHighlight, style: boldTextStyle())
                              .paddingSymmetric(vertical: 16),
                          Observer(builder: (context) {
                            final list =
                                newStoryHighlightDialogVars.dialogHighlightList;

                            if (list.length > 1 &&newStoryHighlightDialogVars.dialogDropdownValue.categoryId !=null) {
                              return Container(
                                width: context.width(),
                                decoration: BoxDecoration(
                                  color: context.scaffoldBackgroundColor,
                                  borderRadius: radius(commonRadius),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: ButtonTheme(
                                    alignedDropdown: true,
                                    child:DropdownButton<HighlightStoriesModel>(
                                      borderRadius:
                                          BorderRadius.circular(commonRadius),
                                      value: newStoryHighlightDialogVars
                                          .dialogDropdownValue,
                                      icon: Icon(Icons.arrow_drop_down,
                                          color: appStore.isDarkMode
                                              ? bodyDark
                                              : bodyWhite),
                                      elevation: 8,
                                      style: primaryTextStyle(),
                                      underline: Container(
                                          height: 2, color: appColorPrimary),
                                      alignment: Alignment.bottomCenter,
                                      isExpanded: true,
                                      onChanged:
                                          (HighlightStoriesModel? newValue) {
                                        newStoryHighlightDialogVars
                                            .dialogDropdownValue = newValue!;
                                      },
                                      items: list.map<
                                          DropdownMenuItem<
                                              HighlightStoriesModel>>((e) {
                                        return DropdownMenuItem<
                                            HighlightStoriesModel>(
                                          value: e,
                                          child: Text(
                                            e.categoryName.validate().isNotEmpty
                                                ? e.categoryName.validate()
                                                : language.untitled,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              );
                            } else if (list.length == 1 && newStoryHighlightDialogVars.dialogDropdownValue.categoryId !=null) {
                              final highlight = list.first;
                              return Container(
                                width: context.width(),
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: context.scaffoldBackgroundColor,
                                  borderRadius: radius(commonRadius),
                                  border: Border.all(
                                      color: appColorPrimary, width: 1),
                                ),
                                child: Text(
                                  highlight.categoryName.validate().isNotEmpty
                                      ? highlight.categoryName.validate()
                                      : language.untitled,
                                  style: primaryTextStyle(),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            } else {
                              return Offstage();
                            }
                          }),
                        ],
                      );
              }),
              16.height,
              AppButton(
                width: context.width(),
                onTap: () async {
                  if (newStoryHighlightDialogVars.showNewCategory) {
                    if (categoryName.text.isNotEmpty) {
                      onAddStory();
                    } else {
                      toast(language.pleaseAddHighlightName);
                    }
                  } else {
                    onAddStory();
                  }
                },
                child: Text(language.addHighlightStory,
                    style: primaryTextStyle(color: Colors.white)),
                color: context.primaryColor,
                elevation: 0,
              ),
              16.height,
            ],
          ),
        ),
      ),
    );
  }
}
