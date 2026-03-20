import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/file_picker_dialog_component.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/story/common_story_model.dart';
import 'package:socialv/network/messages_repository.dart';
import 'package:socialv/screens/stories/component/story_video_component.dart';
import 'package:socialv/store/message_store.dart';
import 'package:socialv/utils/app_constants.dart';

class MessageMediaScreen extends StatefulWidget {
  final File? cameraImage;
  final List<MediaSourceModel>? mediaList;
  final int? messageId;
  final String? message;
  final int threadId;
  final bool isEdit;

  MessageMediaScreen({this.cameraImage, this.mediaList, this.messageId, this.message, required this.threadId, required this.isEdit});

  @override
  State<MessageMediaScreen> createState() => _MessageMediaScreenState();
}

class _MessageMediaScreenState extends State<MessageMediaScreen> {
  MessageStore messageMediaScreenVars = MessageStore();
  TextEditingController messageController = TextEditingController();
  PageController pageController = PageController();

  @override
  void initState() {
    super.initState();
    setStatusBarColor(Colors.transparent);
    if (widget.cameraImage != null) {
      messageMediaScreenVars.mediaList.add(MediaSourceModel(
        mediaFile: widget.cameraImage!,
        extension: widget.cameraImage!.path.validate().split("/").last.split(".").last,
        mediaType: MediaTypes.photo,
      ));
    }

    if (widget.mediaList != null) {
      messageMediaScreenVars.mediaList.addAll(widget.mediaList.validate());
      messageMediaScreenVars.mediaList.forEach((element) {});
    }

    if (widget.message.validate().isNotEmpty) {
      messageController.text = widget.message.validate();
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
      appBar: AppBar(
        title: Text('', style: boldTextStyle(size: 20)),
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
        alignment: Alignment.bottomCenter,
        children: [
          Observer(builder: (context) {
            return PageView.builder(
              controller: pageController,
              itemCount: messageMediaScreenVars.mediaList.length,
              onPageChanged: (index) {
                messageMediaScreenVars.selectedMediaIndex = index;
              },
              itemBuilder: (ctx, index) {
                if (messageMediaScreenVars.mediaList[index].mediaType == MediaTypes.video) {
                  return CreateVideoStory(videoFile: messageMediaScreenVars.mediaList[index].mediaFile);
                } else {
                  return Image.file(messageMediaScreenVars.mediaList[index].mediaFile, height: context.height(), width: context.width(), fit: BoxFit.cover);
                }
              },
            );
          }),
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
            padding: EdgeInsets.fromLTRB(8, 60, 8, 8),
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
                            messageMediaScreenVars.mediaList.add(MediaSourceModel(
                              mediaFile: value!,
                              extension: value.path.validate().split("/").last.split(".").last,
                              mediaType: MediaTypes.photo,
                            ));
                          }).catchError((e) {
                            appStore.setLoading(false);
                          });
                        } else {
                          await getMultipleImages().then((value) {
                            messageMediaScreenVars.mediaList.addAll(value);
                          });
                        }
                      }
                    }),
                    8.width,
                    Container(
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
                            final MediaSourceModel item = messageMediaScreenVars.mediaList.removeAt(oldIndex);
                            messageMediaScreenVars.mediaList.insert(newIndex, item);
                          },
                          children: messageMediaScreenVars.mediaList.map((e) {
                            int index = messageMediaScreenVars.mediaList.indexOf(e);
                            if (messageMediaScreenVars.mediaList[index].mediaType == MediaTypes.video) {
                              return Stack(
                                key: Key('$index'),
                                children: [
                                  Observer(builder: (context) {
                                    return Container(
                                      margin: EdgeInsets.symmetric(horizontal: 4),
                                      decoration: BoxDecoration(
                                        border: messageMediaScreenVars.selectedMediaIndex == index ? Border.all(color: context.primaryColor) : Border(),
                                        borderRadius: radius(defaultAppButtonRadius),
                                      ),
                                      height: 86,
                                      width: 70,
                                      child: CreateVideoThumbnail(videoFile: messageMediaScreenVars.mediaList[index].mediaFile),
                                    );
                                  }),
                                  Container(
                                    child: Image.asset(ic_close, width: 10, height: 10, color: context.primaryColor),
                                    decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                    padding: EdgeInsets.all(4),
                                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  ).onTap(() {
                                    messageMediaScreenVars.mediaList.removeAt(index);
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
                                      Observer(builder: (context) {
                                        return Container(
                                          margin: EdgeInsets.symmetric(horizontal: 4),
                                          decoration: BoxDecoration(
                                            border: messageMediaScreenVars.selectedMediaIndex == index ? Border.all(color: context.primaryColor) : Border(),
                                            borderRadius: radius(defaultAppButtonRadius),
                                          ),
                                          child: Image.file(
                                            messageMediaScreenVars.mediaList[index].mediaFile,
                                            height: 86,
                                            width: 70,
                                            fit: BoxFit.cover,
                                          ).cornerRadiusWithClipRRect(defaultAppButtonRadius),
                                        );
                                      }),
                                    ],
                                  ),
                                  Container(
                                    child: Image.asset(ic_close, width: 10, height: 10, color: context.primaryColor),
                                    decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                    padding: EdgeInsets.all(4),
                                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  ).onTap(() {
                                    messageMediaScreenVars.mediaList.removeAt(index);
                                  }),
                                ],
                              );
                            }
                          }).toList(),
                        ),
                      ),
                    ).expand(),
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
                        controller: messageController,
                        cursorColor: Colors.white,
                        textStyle: secondaryTextStyle(color: Colors.white),
                        textFieldType: TextFieldType.OTHER,
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
                      InkWell(
                        onTap: () {
                          hideKeyboard(context);
                          ifNotTester(() async {
                            appStore.setLoading(true);

                            if (widget.isEdit) {
                              Future.forEach(messageMediaScreenVars.mediaList, (MediaSourceModel element) {
                                uploadMessageMedia(threadId: widget.threadId.validate(), media: element).then((value) {
                                  //
                                }).catchError(onError);
                              }).whenComplete(() {
                                appStore.setLoading(false);
                                finish(context, true);
                              });
                            } else {
                              List<int> fileIdList = [];
                              await Future.forEach(messageMediaScreenVars.mediaList, (MediaSourceModel element) async {
                                await uploadMessageMedia(threadId: widget.threadId.validate(), media: element).then((value) {
                                  if (value != null) {
                                    fileIdList.add(value);
                                    log("Uploaded file id: ${value}");
                                  } else {
                                    log("===================== File is not Uploaded =====================");
                                  }
                                }).catchError(onError);
                              }).then(
                                (value) {
                                  sendMessage(
                                    threadId: widget.threadId.validate(),
                                    message: messageController.text,
                                    fileIds: fileIdList,
                                    messageId: widget.messageId,
                                  ).then((value) {
                                    appStore.setLoading(false);
                                    finish(context, true);
                                  }).catchError((e) {
                                    appStore.setLoading(false);
                                    log('Error: ${e.toString()}');
                                  });
                                },
                              );
                            }
                          });
                        },
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(color: context.primaryColor, shape: BoxShape.circle),
                          child: Image.asset(ic_send, height: 28, width: 28, fit: BoxFit.fill, color: Colors.white),
                        ),
                      ).visible(!appStore.isLoading)
                    ],
                  ),
                ),
                8.height,
              ],
            ),
          ),
          Observer(builder: (_) => LoadingWidget().visible(appStore.isLoading)),
        ],
      ),
    );
  }
}
