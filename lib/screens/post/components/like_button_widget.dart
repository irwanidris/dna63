import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/main.dart';
import 'package:socialv/store/fragment_store/home_fragment_store.dart';

import '../../../utils/app_constants.dart';

class LikeButtonWidget extends StatefulWidget {
  final VoidCallback onPostLike;
  final bool isPostLiked;
  final Key? key;

  const LikeButtonWidget({this.key, required this.onPostLike, required this.isPostLiked});

  @override
  State<LikeButtonWidget> createState() => _LikeButtonWidgetState();
}

class _LikeButtonWidgetState extends State<LikeButtonWidget> with SingleTickerProviderStateMixin {
  HomeFragStore likeButtonWidgetVars = HomeFragStore();
  AnimationController? _controller;

  @override
  void initState() {
    likeButtonWidgetVars.isPostLiked = widget.isPostLiked;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250),
      lowerBound: 0.0,
      upperBound: 0.1,
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller != null) {
      likeButtonWidgetVars.likeScale = 1 - _controller!.value;
    }
    return Listener(
      key: widget.key,
      onPointerDown: (details) {
        _controller?.forward();
      },
      onPointerUp: (details) {
        _controller?.reverse();
      },
      child: Observer(builder: (context) {
        return Transform.scale(
          scale: likeButtonWidgetVars.likeScale,
          child: GestureDetector(
            onTap: () {
              if (!appStore.isLoading) {
                ifNotTester(() async {
                  likeButtonWidgetVars.isPostLiked = !likeButtonWidgetVars.isPostLiked;
                  await Future.delayed(Duration.zero);
                  widget.onPostLike.call();
                });
              }
            },
            child: Row(
              children: [
                Image.asset(
                  likeButtonWidgetVars.isPostLiked ? ic_heart_filled : ic_heart,
                  height: likeButtonWidgetVars.isPostLiked ? 20 : 22,
                  width: 22,
                  fit: BoxFit.fill,
                  color: likeButtonWidgetVars.isPostLiked ? Colors.red : context.iconColor,
                ),
                Text(language.like, style: secondaryTextStyle(color: textPrimaryColor)).paddingLeft(6)
              ],
            ),
          ),
        );
      }),
    );
  }
}
