import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/youtube_player_component.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/common_models/post_mdeia_model.dart';
import 'package:socialv/screens/post/components/audio_component.dart';
import 'package:socialv/screens/post/components/video_post_component.dart';
import 'package:socialv/screens/post/screens/audio_post_screen.dart';
import 'package:socialv/screens/post/screens/image_screen.dart';
import 'package:socialv/screens/post/screens/pdf_screen.dart';
import 'package:socialv/screens/post/screens/video_post_screen.dart';
import 'package:socialv/store/fragment_store/home_fragment_store.dart';
import 'package:socialv/utils/app_constants.dart';
import 'package:socialv/utils/cached_network_image.dart';

class PostMediaComponent extends StatefulWidget {
  final String? mediaType;
  final List<PostMediaModel>? mediaList;
  final bool isFromPostDetail;
  final bool isFromQuickViewDetail;
  final String mediaTitle;
  final Function(int)? onPageChange;
  final int initialPageIndex;

  PostMediaComponent({
    this.isFromQuickViewDetail = false,
    required this.mediaTitle,
    this.mediaType,
    this.mediaList,
    this.isFromPostDetail = false,
    this.onPageChange,
    this.initialPageIndex = 0,
    super.key,
  });

  @override
  State<PostMediaComponent> createState() => _PostMediaComponentState();
}

class _PostMediaComponentState extends State<PostMediaComponent> {
  late PageController pageController;
  HomeFragStore postMediaComponentVars = HomeFragStore();
  final int maxImageLimit = 20;
  int currentPage = 0;

  @override
  void initState() {
    pageController = PageController(initialPage: widget.initialPageIndex);
    postMediaComponentVars.selectedIndex = widget.initialPageIndex;
    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mediaList.validate().isNotEmpty) {
      int itemCount = widget.mediaList.validate().length;
      if (widget.mediaType == MediaTypes.photo && itemCount > maxImageLimit) {
        itemCount = maxImageLimit;
      }

      return Column(
        children: [
          SizedBox(
            height: widget.mediaType == MediaTypes.photo
                ? 300
                : widget.mediaType == MediaTypes.video
                    ? 250
                    : 200,
            width: context.width(),
            child: PageView.builder(
              controller: pageController,
              itemCount: itemCount,
              itemBuilder: (context, index) {
                if (widget.mediaType == MediaTypes.photo) {
                  return Stack(
                    children: [
                      cachedImage(
                        widget.mediaList.validate()[index].url,
                        height: 300,
                        width: context.width() - 32,
                        fit: BoxFit.cover,
                      ).cornerRadiusWithClipRRect(defaultAppButtonRadius).paddingSymmetric(horizontal: 8).onTap(() {
                        ImageScreen(
                          imageURl: widget.mediaList.validate()[index].url.validate(),
                          isMultipleImages: true,
                          selectedImageIndex: index,
                          multipleImageList: widget.mediaList.validate().map((e) => e.url.validate()).toList(),
                        ).launch(context);
                      }, splashColor: Colors.transparent, highlightColor: Colors.transparent),
                      if (index == maxImageLimit - 1 && widget.mediaList.validate().length > maxImageLimit)
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "+${widget.mediaList.validate().length - maxImageLimit} ${language.more}",
                              style: TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ).onTap(() {
                            ImageScreen(
                              isMultipleImages: true,
                              selectedImageIndex: index,
                              multipleImageList: widget.mediaList.validate().map((e) => e.url.validate()).toList(),
                            ).launch(context);
                          }),
                        ),
                    ],
                  );
                } else if (widget.mediaType == MediaTypes.audio) {
                  return widget.isFromPostDetail
                      ? AudioPostComponent(audioURl: widget.mediaList.validate()[index].url.validate())
                      : Container(
                          margin: EdgeInsets.symmetric(horizontal: 8),
                          padding: EdgeInsets.symmetric(vertical: 40),
                          decoration: BoxDecoration(borderRadius: radius(defaultAppButtonRadius)),
                          child: cachedImage(ic_voice, color: appStore.isDarkMode ? bodyDark : bodyWhite),
                        ).onTap(() {
                          AudioPostScreen(widget.mediaList.validate()[index].url.validate()).launch(context);
                        }, splashColor: Colors.transparent, highlightColor: Colors.transparent);
                } else if (widget.mediaType == MediaTypes.doc) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    padding: EdgeInsets.symmetric(vertical: 40),
                    decoration: BoxDecoration(borderRadius: radius(defaultAppButtonRadius)),
                    child: cachedImage(
                      ic_document,
                      color: appStore.isDarkMode ? bodyDark : bodyWhite,
                    ),
                  ).onTap(() {
                    if (widget.mediaList.validate()[index].url.validate().isPdf) {
                      PDFScreen(docURl: widget.mediaList.validate()[index].url.validate()).launch(context);
                    } else {
                      openWebPage(context, url: '$openDocUrlPrefix${widget.mediaList.validate()[index].url.validate()}');
                    }
                  }, splashColor: Colors.transparent, highlightColor: Colors.transparent);
                } else if (widget.mediaType == MediaTypes.video) {
                  if (widget.mediaList.validate()[index].source.validate() == 'youtube') {
                    return YoutubePlayerComponent(id: widget.mediaList.validate()[index].url.validate().toYouTubeId()).paddingSymmetric(horizontal: 8);
                  } else {
                    return widget.isFromPostDetail
                        ? VideoPostComponent(
                            videoURl: widget.mediaList.validate()[index].url.validate(),
                          ).cornerRadiusWithClipRRect(10).paddingSymmetric(horizontal: 8)
                        : VideoPostComponent(videoURl: widget.mediaList.validate()[index].url.validate())
                            .onTap(() {
                              VideoPostScreen(widget.mediaList.validate()[index].url.validate()).launch(context);
                            }, splashColor: Colors.transparent, highlightColor: Colors.transparent)
                            .cornerRadiusWithClipRRect(10)
                            .paddingSymmetric(horizontal: 8);
                  }
                } else if (widget.mediaType == MediaTypes.gif) {
                  return cachedImage(
                    widget.mediaList.validate()[index].url,
                    width: context.width() - 32,
                    fit: BoxFit.cover,
                  ).cornerRadiusWithClipRRect(defaultAppButtonRadius).paddingSymmetric(horizontal: 8);
                } else {
                  return Offstage();
                }
              },
              onPageChanged: (i) {
                setState(() {
                  currentPage = i;
                });
                widget.onPageChange?.call(i);
                postMediaComponentVars.selectedIndex = pageController.page!.round();
              },
            ),
          ),
          16.height,
          if (itemCount > 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(itemCount, (index) {
                return AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  width: currentPage == index ? 10 : 6,
                  height: currentPage == index ? 10 : 6,
                  decoration: BoxDecoration(

                    color: appStore.isDarkMode? currentPage == index ? Colors.white : Colors.white.withOpacity(0.5):currentPage == index ? Colors.black : Colors.black.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                );
              }),
            )
        ],
      );
    } else {
      return Offstage();
    }
  }
}
