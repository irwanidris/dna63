import 'dart:io';
import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/screens/stories/screen/story_page.dart';
import 'package:socialv/utils/app_constants.dart';
import 'package:video_player/video_player.dart' as vc;
import 'package:visibility_detector/visibility_detector.dart';

class CreateVideoStory extends StatefulWidget {
  final File videoFile;
  final bool isShowControllers;

  CreateVideoStory({required this.videoFile, this.isShowControllers = true});

  @override
  State<CreateVideoStory> createState() => _CreateVideoStoryState();
}

class _CreateVideoStoryState extends State<CreateVideoStory> {
  late CachedVideoPlayerController videoPlayerController;
  late CustomVideoPlayerController _customVideoPlayerController;
  GlobalKey storyVisibilityKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    videoPlayerController = CachedVideoPlayerController.file(widget.videoFile)..initialize().then((value) => setState(() {}));
    videoPlayerController.play();

    _customVideoPlayerController = CustomVideoPlayerController(
      context: context,
      videoPlayerController: videoPlayerController,
      customVideoPlayerSettings: CustomVideoPlayerSettings(
        enterFullscreenButton: Image.asset(ic_full_screen, color: Colors.white, width: 16, height: 16).paddingAll(4),
        exitFullscreenButton: Image.asset(ic_exit_full_screen, color: Colors.white, width: 16, height: 16).paddingAll(4),
        playButton: Image.asset(ic_play_button, color: Colors.white, width: 16, height: 16).paddingAll(4),
        pauseButton: Image.asset(ic_pause, color: Colors.white, width: 16, height: 16).paddingAll(4),
        playbackSpeedButtonAvailable: false,
        settingsButtonAvailable: false,
        playOnlyOnce: false,
      ),
    );
  }

  @override
  void dispose() {
    _customVideoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width(),
      height: context.height(),
      decoration: BoxDecoration(color: Colors.black),
      padding: EdgeInsets.only(bottom: 180),
      child: CustomVideoPlayer(
        customVideoPlayerController: _customVideoPlayerController,
      ),
    );
  }
}

class CreateVideoThumbnail extends StatefulWidget {
  final File? videoFile;

  const CreateVideoThumbnail({this.videoFile});

  @override
  State<CreateVideoThumbnail> createState() => _CreateVideoThumbnailState();
}

class _CreateVideoThumbnailState extends State<CreateVideoThumbnail> {
  late vc.VideoPlayerController controller;

  @override
  void initState() {
    init();
    super.initState();
  }

  void init() async {
    controller = vc.VideoPlayerController.file(widget.videoFile!)..initialize().then((value) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    if (controller.value.isInitialized) {
      return vc.VideoPlayer(controller).cornerRadiusWithClipRRect(defaultAppButtonRadius);
    } else {
      return Container(
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: radius(defaultAppButtonRadius),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Image.asset(ic_video, height: 20, width: 20, fit: BoxFit.contain),
      );
    }
  }
}

class ShowVideoThumbnail extends StatefulWidget {
  final String? videoUrl;

  const ShowVideoThumbnail({this.videoUrl});

  @override
  State<ShowVideoThumbnail> createState() => ShowVideoThumbnailState();
}

class ShowVideoThumbnailState extends State<ShowVideoThumbnail> {
  String videoUrl = '';

  late vc.VideoPlayerController controller;

  @override
  void initState() {
    videoUrl = widget.videoUrl.validate();
    super.initState();
    init();
  }

  Future<void> init() async {
    controller = vc.VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl.validate()))..initialize().then((value) => setState(() {}));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.videoUrl != videoUrl) {
      init();
      videoUrl = widget.videoUrl.validate();
    }
    return controller.value.isInitialized ? vc.VideoPlayer(controller).cornerRadiusWithClipRRect(24) : Image.asset(ic_video, height: 18, width: 18, fit: BoxFit.cover).paddingAll(8);
  }
}

class StoryVideoPostComponent extends StatefulWidget {
  final String videoURl;
  final bool isShowControllers;
  final VoidCallback? onVideoInitialized;
  final VoidCallback? onVideoLoading;

  StoryVideoPostComponent({
    super.key,
    required this.videoURl,
    this.isShowControllers = true,
    this.onVideoInitialized,
    this.onVideoLoading,
  });

  @override
  State<StoryVideoPostComponent> createState() => _StoryVideoPostComponentState();
}

class _StoryVideoPostComponentState extends State<StoryVideoPostComponent> {
  late vc.VideoPlayerController videoPlayerController;
  bool isVideoVisible = true;
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    try {
      if (widget.onVideoLoading != null) widget.onVideoLoading!();
      videoPlayerController = vc.VideoPlayerController.networkUrl(
        Uri.parse(widget.videoURl),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: false,
          allowBackgroundPlayback: false,
        ),
      );
      globalVideoPlayerController = videoPlayerController;
      await videoPlayerController.initialize();
      await videoPlayerController.setLooping(true);
      if (mounted) {
        setState(() => isInitialized = true);
        videoPlayerController.play();
        if (widget.onVideoInitialized != null) widget.onVideoInitialized!();
      }
    } catch (e) {
      log('Video Init Error: $e');
    }
  }

  @override
  void dispose() {
    videoPlayerController.pause();
    videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return VisibilityDetector(
      key: UniqueKey(),
      onVisibilityChanged: (visibilityInfo) async {
        isVideoVisible = visibilityInfo.visibleFraction > 0.5;

        if (widget.videoURl != videoPlayerController.dataSource) {
          await videoPlayerController.pause();
          await init();
        } else {
          if (!isVideoVisible) {
            await videoPlayerController.pause();
          } else if (!videoPlayerController.value.isPlaying) {
            await videoPlayerController.play();
          }
        }
      },
      child: SizedBox(
        width: context.width(),
        height: context.height() * 0.8,
        child: AspectRatio(
          aspectRatio: videoPlayerController.value.aspectRatio,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              vc.VideoPlayer(videoPlayerController),
              vc.VideoProgressIndicator(
                videoPlayerController,
                allowScrubbing: true,
                padding: EdgeInsets.only(bottom: 16),
              ),
            ],
          ),
        ),
      ).center(),
    );
  }
}
