import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:socialv/store/fragment_store/home_fragment_store.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../utils/app_constants.dart';

class VideoPostComponent extends StatefulWidget {
  final String videoURl;

  VideoPostComponent({required this.videoURl});

  @override
  State<VideoPostComponent> createState() => _VideoPostComponentState();
}

class _VideoPostComponentState extends State<VideoPostComponent> {
  HomeFragStore videoPostComponentVars = HomeFragStore();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    videoPostComponentVars.videoPlayerController = CachedVideoPlayerController.network(widget.videoURl)..initialize().then((value) => setState(() {}));
    videoPostComponentVars.customVideoPlayerController = CustomVideoPlayerController(
      context: context,
      videoPlayerController: videoPostComponentVars.videoPlayerController,
      customVideoPlayerSettings: CustomVideoPlayerSettings(
          enterFullscreenButton: Image.asset(ic_full_screen, color: Colors.white, width: 16, height: 16).paddingAll(4),
          exitFullscreenButton: Image.asset(ic_exit_full_screen, color: Colors.white, width: 16, height: 16).paddingAll(4),
          playButton: Image.asset(ic_play_button, color: Colors.white, width: 16, height: 16).paddingAll(4),
          pauseButton: Image.asset(ic_pause, color: Colors.white, width: 16, height: 16).paddingAll(4),
          playbackSpeedButtonAvailable: false,
          settingsButtonAvailable: false,
          systemUIModeInsideFullscreen: SystemUiMode.edgeToEdge),
    );

    videoPostComponentVars.videoUrl = widget.videoURl;
  }

  @override
  void dispose() {
    videoPostComponentVars.videoPlayerController.pause();
    videoPostComponentVars.customVideoPlayerController.videoPlayerController.pause();
    videoPostComponentVars.customVideoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (videoPostComponentVars.videoUrl != widget.videoURl) {
      init();
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        Image.asset(ic_video, height: 100, width: 100, fit: BoxFit.contain),
        SizedBox(
          width: context.width(),
          height: context.height() * 0.85,
          child: VisibilityDetector(
              key: videoPostComponentVars.visibilityKey,
              onVisibilityChanged: (info) {
                videoPostComponentVars.customVideoPlayerController.videoPlayerController.pause();
              },
              child: CustomVideoPlayer(customVideoPlayerController: videoPostComponentVars.customVideoPlayerController)),
        ).center(),
      ],
    );
  }
}
