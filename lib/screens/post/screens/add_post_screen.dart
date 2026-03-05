import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/file_picker_dialog_component.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/common_models.dart';
import 'package:socialv/models/members/member_response.dart';
import 'package:socialv/models/posts/media_model.dart';
import 'package:socialv/models/posts/post_in_list_model.dart';
import 'package:socialv/models/posts/post_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/post/components/add_post_media_component.dart';
import 'package:socialv/screens/post/components/edit_post_media_component.dart';
import 'package:socialv/screens/post/components/show_selected_media_component.dart';
import 'package:socialv/screens/post/screens/post_in_groups_screen.dart';
import 'package:socialv/store/fragment_store/home_fragment_store.dart';
import 'package:video_player/video_player.dart';

import '../../../utils/app_constants.dart';
import '../../../utils/cached_network_image.dart';

// ignore: must_be_immutable
enum FileType { image, video, audio, document, unknown }

class AddPostScreen extends StatefulWidget {
  final String? component;
  final String? groupName;
  final int? groupId;
  final PostModel? post;
  final VoidCallback? callback;
  final bool showMediaOptions;
  final String? parentPostId;

  AddPostScreen({this.component, this.post, this.callback, this.showMediaOptions = true, this.parentPostId, this.groupName, this.groupId});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  HomeFragStore addPostVars = HomeFragStore();
  GlobalKey<FlutterMentionsState> postContentTextKey = GlobalKey<FlutterMentionsState>();

  final int maxImageLimit = 20;
  int mPage = 1;
  bool mIsLastPage = false;

  String oldValue = '';
  int mediaLength = 0;

  @override
  void initState() {
    super.initState();

    getMentionsMembers();
    afterBuildCreated(() async {
      setStatusBarColor(context.cardColor);
      if (widget.showMediaOptions.validate()) {
        await getMediaList();
      }
      await postIn();
      init();
    });
  }

  Future<void> init() async {
    if (widget.post != null) {
      if (addPostVars.mediaTypeList.isNotEmpty && (widget.post!.mediaType != null && widget.post!.mediaType.validate().isNotEmpty)) {
        addPostVars.selectedMedia = addPostVars.mediaTypeList.firstWhere((element) => element.type == widget.post!.mediaType);
        addPostVars.enableSelectMedia = false;
      } else {
        addPostVars.enableSelectMedia = true;
      }

      if (widget.post!.medias.validate().isNotEmpty) {
        addPostVars.postMedia.addAll(widget.post!.medias.validate());
      }

      if (postContentTextKey.currentState != null) postContentTextKey.currentState!.controller!.text = parseHtmlString(widget.post!.content.validate().replaceAll('</br>', '\n'));
      addPostVars.postContent = postContentTextKey.currentState!.controller!.text;
      oldValue = addPostVars.postContent;
      mediaLength = addPostVars.postMedia.length;
    }
  }

  Future<void> getMediaList() async {
    addPostVars.mediaTypeList.add(MediaModel(title: "Text", type: MediaTypes.text, isActive: true));
    addPostVars.mediaTypeList
        .addAll(widget.component != null ? appStore.allowedMedia.firstWhere((element) => element.component == widget.component.validate()).allowedTypes : appStore.allowedMedia.first.allowedTypes);
    addPostVars.selectedMedia = addPostVars.mediaTypeList.first;
  }

  Future<void> postIn() async {
    addPostVars.postInList.add(PostInListModel(id: 0, title: language.myProfile));
    addPostVars.postInList.add(PostInListModel(title: language.selectGroups));

    if (widget.groupId != null && widget.parentPostId == null) {
      addPostVars.postInList.insert(addPostVars.postInList.length - 1, PostInListModel(id: widget.groupId, title: widget.groupName));
      addPostVars.dropdownValue = addPostVars.postInList.firstWhere((element) => element.id == widget.groupId.validate());
    } else {
      addPostVars.dropdownValue = addPostVars.postInList.first;
    }
  }

  FileType detectFileType(String url) {
    final extension = url.split('.').last.toLowerCase();

    if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension)) {
      return FileType.image;
    } else if (['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(extension)) {
      return FileType.video;
    } else if (['mp3', 'wav', 'ogg', 'm4a'].contains(extension)) {
      return FileType.audio;
    } else if (['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt'].contains(extension)) {
      return FileType.document;
    } else {
      return FileType.unknown;
    }
  }

  Future<bool> isValidUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.isAbsolute) return false;

    try {
      final response = await http.head(uri).timeout(Duration(seconds: 10));

      // If HEAD fails (e.g., YouTube), fallback to GET
      if (response.statusCode >= 200 && response.statusCode < 400) {
        return true;
      } else {
        final getResponse = await http.get(uri).timeout(Duration(seconds: 10));
        return getResponse.statusCode >= 200 && getResponse.statusCode < 400;
      }
    } catch (e) {
      return false;
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

  Future<void> checkAndAddMedia(File element, List<PostMedia> mediaList, String unsupportedMessage) async {
    try {
      String fileExtension = element.path.split(".").last.toLowerCase();
      if (['jpeg', 'jpg', 'png', 'webp', 'gif', 'heic'].contains(fileExtension)) {
        bool isValid = await isValidImage(element);
        if (!isValid) {
          toast(language.multipleSelectedImageIsCorrupt);
          return;
        }
      }
      else if (['mp4', 'avi', 'mov', 'mkv', 'flv', 'wmv'].contains(fileExtension)) {
        final controller = VideoPlayerController.file(element);
        await controller.initialize();
        bool isValid = controller.value.duration > Duration.zero;
        await controller.dispose();
        if (!isValid) {
          toast(unsupportedMessage);
          return;
        }
      }
            mediaList.add(PostMedia(file: element));
    } catch (e) {
      toast(unsupportedMessage);
      // Failed to load → corrupted or unsupported
    }
  }

  Future<void> onSelectMedia() async {
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
        appStore.setLoading(true);
        await getImageSource(isCamera: true, isVideo: addPostVars.selectedMedia!.type == MediaTypes.video).then((value) async {
          // Check current media count before adding
          int currentMediaCount = addPostVars.mediaList.where((media) => !media.isLink).length;
          if (currentMediaCount >= maxImageLimit) {
            toast(language.maximumImageLimit);
            appStore.setLoading(false);
            return;
          }

          if (addPostVars.selectedMedia!.type == MediaTypes.photo) {
            bool isValid = await isValidImage(value!);
            if (isValid) {
              addPostVars.mediaList.add(PostMedia(file: value));
            } else {
              toast(language.selectedImageIsCorrupt);
            }
          } else {
            addPostVars.mediaList.add(PostMedia(file: value));
          }
          appStore.setLoading(false);
        }).catchError((e) {
          log('Error: ${e.toString()}');
          appStore.setLoading(false);
        });
      } else {
        appStore.setLoading(true);
        getMultipleFiles(mediaType: addPostVars.selectedMedia!, postingInComponent: widget.component.validate()).then((value) async {
          // Check current image count before adding multiple files
          int currentImageCount = addPostVars.mediaList.where((media) => !media.isLink).length;
          int remainingSlots = maxImageLimit - currentImageCount;

          if (remainingSlots <= 0) {
            toast(language.maximumImageLimit);
            appStore.setLoading(false);
            return;
          }

          // Limit the number of files to add based on remaining slots
          List<File> filesToAdd = value.take(remainingSlots).toList();
          if (value.length > remainingSlots) {
            toast(language.maximumImageLimit);
          }

          for (File element in filesToAdd) {
            String fileExtension = element.path.split(".").last.toLowerCase();

            // Define supported extensions based on media type
            List<String> supportedExtensions;
            String unsupportedMessage;
            if (addPostVars.selectedMedia!.type == MediaTypes.photo) {
              supportedExtensions = ['jpeg', 'jpg', 'png', 'webp', 'gif', 'heic'];
              unsupportedMessage = 'File not supported. Only JPEG, JPG, PNG, WEBP, GIF, and HEIC files are allowed.';

              bool isValid = await isValidImage(element);
              if (!isValid) {
                toast(language.multipleSelectedImageIsCorrupt);
                continue;
              }
            } else if (addPostVars.selectedMedia!.type == MediaTypes.video) {
              supportedExtensions = ['mp4', 'avi', 'mov', 'mkv', 'flv', 'wmv', 'mpeg'];
              unsupportedMessage = 'File not supported. Only MP4, AVI, MOV, MKV, FLV, WMV, and MPEG files are allowed.';
            } else if (addPostVars.selectedMedia!.type == MediaTypes.audio) {
              supportedExtensions = ['mp3', 'midi', 'm4a', 'wav', 'aac'];

              unsupportedMessage = 'File not supported. Only MP3, MIDI, M4A, WAV, and AAC files are allowed.';
            } else if (addPostVars.selectedMedia!.type == MediaTypes.doc) {
              supportedExtensions = ['pdf', 'doc', 'docx', 'txt', 'xls', 'xlsx', 'ppt', 'pptx', 'odt', 'ods', 'odp', 'gz', 'zip', 'rar'];
              unsupportedMessage = 'File not supported. Only PDF, DOC, DOCX, TXT, XLS, XLSX, PPT, PPTX, ODT, ODS, ODP, GZ, ZIP, and RAR files are allowed.';
            } else {
              supportedExtensions = [];
              unsupportedMessage = 'Unsupported media type.';
            }
            log("supported extensions $supportedExtensions");
            // Check if the file extension is supported or not.
            if (supportedExtensions.contains(fileExtension)) {
              ///Before adding the file, check if it's corrupt or not audio or video file
              addPostVars.mediaList.add(PostMedia(file: element));
            } else {
              toast(unsupportedMessage);
            }
          }
        }).catchError((e) {
          log('Error: ${e.toString()}');
          toast(e.toString());
        }).whenComplete(() {
          appStore.setLoading(false);
        });
        log('MediaList: ${addPostVars.mediaList.length}');
      }
    }
  }

  Future<List<MemberResponse>> getMentionsMembers({String mentionText = ''}) async {
    await getAllMembers(
      searchText: mentionText,
      memberList: addPostVars.mentionsMemberList,
      lastPageCallback: (p0) {
        mIsLastPage = p0;
      },
      page: mPage,
    ).then((value) {
      addPostVars.mentionsMemberList.forEach((element) {
        addPostVars.userNameForMention.add({"full_name": element.name, "display": element.userLogin, "photo": element.avatarUrls!.full});
      });
    }).catchError((e) {
      String errorMessage = language.somethingWentWrong;

      if (e.toString().contains('Unsupported file') || e.toString().contains('corrupt')) {
        errorMessage = language.pleaseSelectAnotherFile;
      } else if (e.toString().contains('timeout')) {
        errorMessage = "networkTimeout";
      }

      toast(errorMessage, print: true);
      appStore.setLoading(false);
    });
    return addPostVars.mentionsMemberList;
  }

  @override
  void dispose() {
    if (appStore.isLoading) appStore.setLoading(false);
    setStatusBarColorBasedOnTheme();
    super.dispose();
  }

  bool get isEdited {
    if (widget.post == null) return false;

    final oldContent = oldValue.trim();
    final newContent = addPostVars.postContent.trim();

    final contentChanged = oldContent != newContent;

    final oldMediaCount = mediaLength;
    final newMediaCount = addPostVars.postMedia.length;
    var postMediaChanged = oldMediaCount != newMediaCount;

    // ✅ Also check new mediaList additions
    final newMediaAdded = addPostVars.mediaList.isNotEmpty;
    // i want to display file name
    for (var element in addPostVars.mediaList) {
      log("list of media -------${element.file}");
      if(element.file.toString().contains("File: ")) {
        log("true");
        postMediaChanged = true;
        return true;
      }
    }


    return contentChanged || postMediaChanged || newMediaAdded;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.cardColor,
      appBar: AppBar(
        backgroundColor: context.cardColor,
        title: Text(widget.post != null ? language.editPost : language.newPost, style: boldTextStyle(size: 20)),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.iconColor),
          onPressed: () {
            finish(context);
          },
        ),
        actions: [
          Observer(builder: (context) {
            final canPost = widget.post == null ? (addPostVars.mediaList.isNotEmpty || addPostVars.postContent.isNotEmpty) : isEdited;

            return AppButton(
              shapeBorder: RoundedRectangleBorder(borderRadius: radius(4)),
              text: widget.post != null ? language.save : language.post,
              color: canPost
                  ? context.primaryColor
                  : appStore.isDarkMode
                      ? context.cardColor
                      : Colors.grey.shade300,
              textStyle: primaryTextStyle(
                size: 12,
                color: canPost
                    ? Colors.white
                    : appStore.isDarkMode
                        ? context.cardColor
                        : context.scaffoldBackgroundColor
              ),
              onTap: canPost
                  ? () async {
                      hideKeyboard(context);
                      if (!appStore.isLoading) {
                        ifNotTester(() async {
                          if(addPostVars.postContent .isNotEmpty || addPostVars.mediaList.isNotEmpty) {
                            appStore.setLoading(true);
                            await uploadPost(
                              id: widget.post != null ? widget.post!.activityId : null,
                              postMedia: addPostVars.mediaList,
                              content: postContentTextKey.currentState!.controller!.text.replaceAll("\n", "</br>").replaceAll(' ', ' '),
                              mediaType: addPostVars.selectedMedia != null ? addPostVars.selectedMedia!.type : null,
                              isMedia: addPostVars.selectedMedia == null ? false : true,
                              postIn: addPostVars.dropdownValue.id.toString(),
                              gif: addPostVars.gif != null ? addPostVars.gif!.images!.original!.url.validate() : null,
                              parentPostId: widget.parentPostId,
                              type: widget.parentPostId != null ? PostActivityType.activityShare : null,
                              mediaId: addPostVars.gif != null ? addPostVars.gif!.id.validate() : "",
                            ).then((value) async {
                              appStore.setLoading(false);
                              LiveStream().emit(OnAddPost);
                              if (widget.parentPostId
                                  .validate()
                                  .isEmpty) {
                                LiveStream().emit(OnAddPostProfile);
                              }
                              widget.callback?.call();
                              finish(context, true);
                            }).catchError((e) {
                              toast(language.pleaseSelectAnotherFile, print: true);
                              appStore.setLoading(false);
                            });
                          }
                          else
                            {
                              toast("please add some content");
                            }
                        });

                      }
                    }
                  : null,
              // 🔒 disabled if not edited
              enabled: canPost,
              width: 60,
              padding: EdgeInsets.all(0),
              elevation: 0,
            ).paddingSymmetric(horizontal: 16, vertical: 12);
          })
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.showMediaOptions.validate())
                  Container(
                    width: context.width(),
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(borderRadius: radius(), color: context.scaffoldBackgroundColor),
                    child: Observer(builder: (context) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: addPostVars.mediaTypeList.map((e) {
                          if (e.isActive.validate()) {
                            return Container(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: addPostVars.selectedMedia == e ? context.primaryColor : Colors.transparent,
                                borderRadius: radius(defaultRadius),
                              ),
                              child: Text(
                                e.title.validate(),
                                style: boldTextStyle(size: 12, color: addPostVars.selectedMedia == e ? white : Colors.grey.shade500),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ).onTap(() {
                              if (addPostVars.enableSelectMedia && e.isActive.validate()) {
                                addPostVars.mediaList.clear();
                                addPostVars.selectedMedia = e;

                                if (e.type == MediaTypes.gif) {
                                  selectGif(context: context).then((value) {
                                    if (value != null) {
                                      addPostVars.gif = value;
                                      log('Gif Url: ${addPostVars.gif!.images!.original!.url.validate()}');
                                    }
                                  });
                                }
                              } else {
                                toast(language.youCanNotSelect);
                              }
                            }, splashColor: Colors.transparent, highlightColor: Colors.transparent).expand();
                          } else {
                            return Offstage();
                          }
                        }).toList(),
                      );
                    }),
                  ),
                Theme(
                  data: ThemeData(
                    textSelectionTheme: TextSelectionThemeData(
                      selectionHandleColor: Colors.transparent,
                    ),
                  ),
                  child: FlutterMentions(
                    key: postContentTextKey,
                    suggestionPosition: SuggestionPosition.Top,
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: (value) {
                      addPostVars.setPostContent(value);
                    },
                    maxLines: 10,
                    decoration: inputDecorationFilled(
                      context,
                      fillColor: context.scaffoldBackgroundColor,
                      label: language.whatsOnYourMind,
                    ),
                    style: primaryTextStyle(),
                    suggestionListDecoration: BoxDecoration(color: context.cardColor, border: Border.all(color: context.dividerColor)),
                    mentions: [
                      Mention(
                        trigger: "@",
                        matchAll: true,
                        data: addPostVars.userNameForMention,
                        suggestionBuilder: (data) {
                          return Container(
                            constraints: BoxConstraints(maxHeight: 200),
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(color: context.scaffoldBackgroundColor, borderRadius: radius(commonRadius)),
                            child: Row(
                              children: [
                                Text('@' + data["display"], style: boldTextStyle(size: 14, color: context.primaryColor), maxLines: 1, overflow: TextOverflow.ellipsis).expand(),
                                TextIcon(
                                  text: data["full_name"],
                                  textStyle: secondaryTextStyle(),
                                  suffix: cachedImage(data["photo"], height: 20, width: 20, fit: BoxFit.cover).cornerRadiusWithClipRRect(4),
                                  maxLine: 1,
                                  expandedText: true,
                                ).expand(),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ).paddingSymmetric(horizontal: 16, vertical: 8),
                ),
                Observer(builder: (context) {
                  return addPostVars.selectedMedia != null && addPostVars.selectedMedia!.type != MediaTypes.gif && addPostVars.selectedMedia!.type != MediaTypes.text
                      ? AddPostMediaComponent(
                          enableSelectMedia: addPostVars.enableSelectMedia,
                          selectedMedia: addPostVars.selectedMedia!,
                          onSelectMedia: () {
                            onSelectMedia();
                          },
                          mediaListAdd: () async {
                            appStore.setLoading(true);
                            getMultipleFiles(mediaType: addPostVars.selectedMedia!, postingInComponent: widget.component.validate()).then((value) async {
                              // Check current image count before adding multiple files
                              int currentImageCount = addPostVars.mediaList.where((media) => !media.isLink).length;
                              int remainingSlots = maxImageLimit - currentImageCount;
                              if (remainingSlots <= 0) {
                                toast(language.maximumImageLimit);
                                appStore.setLoading(false);
                                return;
                              }

                              // Limit the number of files to add based on remaining slots
                              List<File> filesToAdd = value.take(remainingSlots).toList();
                              if (value.length > remainingSlots) {
                                toast(language.maximumImageLimit);
                              }

                              for (File element in filesToAdd) {
                                await checkAndAddMedia(element, addPostVars.mediaList, "This file is corrupted. Please select another file.");
                              }
                              appStore.setLoading(false);
                            }).catchError((e) {
                              appStore.setLoading(false);
                              log('Error: ${e.toString()}');
                            });

                            log('MediaList: ${addPostVars.mediaList.length}');
                          },
                          clearMediaList: () {
                            addPostVars.mediaList.clear();
                            addPostVars.selectedMedia = null;
                          },
                          linkListAdd: (link) async {
                            if (link.isNotEmpty) {
                              appStore.setLoading(true);

                              bool isValidImage = await isValidUrl(link);

                              appStore.setLoading(false);
log("is valid image-----|${isValidImage}");
                              if (isValidImage) {
                                addPostVars.mediaList.add(PostMedia(isLink: true, link: link));
                              } else {
                                toast("The link provided is invalid or broken. Please check and try again.");
                              }
                            } else {
                              toast(language.enterValidUrl);
                            }
                            FocusScope.of(context).unfocus();
                          },
                        ).paddingAll(16)
                      : Offstage();
                }),
                Observer(builder: (context) {
                  return addPostVars.mediaList.isNotEmpty
                      ? Column(
                          children: [
                            widget.post != null ? Text(language.newlyAdded) : Offstage(),
                            ShowSelectedMediaComponent(
                              mediaList: addPostVars.mediaList,
                              mediaType: addPostVars.selectedMedia!,
                              videoController: List.generate(
                                addPostVars.mediaList.length,
                                (index) {
                                  PostMedia media = addPostVars.mediaList[index];
                                  if (media.isLink)
                                    return VideoPlayerController.networkUrl(Uri.parse(addPostVars.mediaList[index].link.validate()));
                                  else
                                    return VideoPlayerController.file(addPostVars.mediaList[index].file!);
                                },
                              ),
                            ),
                          ],
                        )
                      : Offstage();
                }),
                Observer(builder: (context) {
                  return addPostVars.postMedia.isNotEmpty
                      ? Column(
                          children: [
                            EditPostMediaComponent(
                              mediaList: addPostVars.postMedia,
                              mediaType: addPostVars.selectedMedia!,
                              callback: () {
                                addPostVars.enableSelectMedia = true;
                              },
                            ),
                          ],
                        )
                      : Offstage();
                }),
                Observer(builder: (context) {
                  return addPostVars.gif != null
                      ? Stack(
                          children: [
                            Loader(),
                            Image.network(
                              addPostVars.gif!.images!.original!.url.validate(),
                              headers: {'accept': 'image/*'},
                              width: context.width() - 32,
                              fit: BoxFit.fitWidth,
                            ).cornerRadiusWithClipRRect(defaultAppButtonRadius),
                            Positioned(
                              right: 0,
                              child: IconButton(
                                onPressed: () {
                                  addPostVars.gif = null;
                                },
                                icon: Icon(Icons.cancel_outlined, color: context.primaryColor),
                              ),
                            ),
                          ],
                        ).paddingSymmetric(horizontal: 16)
                      : Offstage();
                }),
                16.height,
                widget.post != null
                    ? Offstage()
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(language.postIn, style: boldTextStyle()).paddingSymmetric(horizontal: 16),
                          Observer(builder: (context) {
                            return addPostVars.dropdownValue.id != null
                                ? Container(
                                    height: 40,
                                    decoration: BoxDecoration(color: context.scaffoldBackgroundColor, borderRadius: radius(commonRadius)),
                                    margin: EdgeInsets.symmetric(horizontal: 16),
                                    child: DropdownButtonHideUnderline(
                                      child: ButtonTheme(
                                        alignedDropdown: true,
                                        child: DropdownButton<PostInListModel>(
                                          borderRadius: BorderRadius.circular(commonRadius),
                                          value: addPostVars.dropdownValue,
                                          icon: Icon(Icons.arrow_drop_down, color: appStore.isDarkMode ? bodyDark : bodyWhite),
                                          elevation: 8,
                                          isExpanded: true,
                                          style: primaryTextStyle(),
                                          underline: Container(height: 2, color: appColorPrimary),
                                          alignment: Alignment.bottomCenter,
                                          onChanged: (PostInListModel? newValue) {
                                            if (newValue!.id == null) {
                                              PostInGroupsScreen().launch(context).then((value) {
                                                if (value != null) {
                                                  addPostVars.dropdownValue = value;
                                                  addPostVars.postInList.insert(addPostVars.postInList.length - 1, value);
                                                }
                                              });
                                            } else {
                                              addPostVars.dropdownValue = newValue;
                                            }
                                          },
                                          items: addPostVars.postInList.map<DropdownMenuItem<PostInListModel>>((e) {
                                            return DropdownMenuItem<PostInListModel>(
                                              value: e,
                                              child: Text('${e.title.validate()}', overflow: TextOverflow.ellipsis, maxLines: 1),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  ).expand()
                                : Offstage();
                          }),
                        ],
                      ),
                50.height,
              ],
            ),
          ),
          Observer(builder: (_) => LoadingWidget().visible(appStore.isLoading))
        ],
      ),
    );
  }
}
