import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/models/reactions/reactions_count_model.dart';

import '../../../main.dart';
import '../../../utils/cached_network_image.dart';
import '../../../utils/constants.dart';
import '../screens/reaction_screen.dart';

class ThreeReactionComponent extends StatefulWidget {
  final int postReactionCount;
  final List<Reactions> postReactionList;
  final int id;
  final bool isComments;

  /// id = comment Id if comment reaction or postId
  const ThreeReactionComponent({required this.postReactionCount, required this.postReactionList, required this.id, required this.isComments});

  @override
  State<ThreeReactionComponent> createState() => _ThreeReactionComponentState();
}

class _ThreeReactionComponentState extends State<ThreeReactionComponent> {
  @override
  Widget build(BuildContext context) {
    return (widget.postReactionList.isNotEmpty)
        ? Row(
            children: [
              Stack(
                children: widget.postReactionList.take(3).map(
                  (reaction) {
                    return Container(
                      width: 20,
                      height: 20,
                      margin: EdgeInsets.only(left: 10 * widget.postReactionList.indexOf(reaction).toDouble()),
                      decoration: BoxDecoration(border: Border.all(color: context.scaffoldBackgroundColor, width: 2), shape: BoxShape.circle),
                      child: cachedImage(reaction.icon.validate(), fit: BoxFit.cover).cornerRadiusWithClipRRect(100),
                    );
                  },
                ).toList(),
              ),
              Marquee(
                child: RichText(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    text: language.reactedBy,
                    style: secondaryTextStyle(size: 10, fontFamily: fontFamily),
                    children: <TextSpan>[
                      TextSpan(
                        text: widget.postReactionList.any((element) => element.user!.id == userStore.loginUserId.toInt()) ? ' ${language.you} ' : ' ${widget.postReactionList.first.user!.displayName}',
                        style: boldTextStyle(size: 10, fontFamily: fontFamily),
                      ),
                      if (widget.postReactionCount > 1) TextSpan(text: ' ${language.and} ', style: secondaryTextStyle(size: 10, fontFamily: fontFamily)),
                      if (widget.postReactionCount > 1) TextSpan(text: '${widget.postReactionCount - 1} ${language.others}', style: boldTextStyle(size: 10, fontFamily: fontFamily)),
                    ],
                  ),
                ).paddingAll(4).onTap(() {
                  ReactionScreen(
                    postId: widget.id.validate(),
                    isCommentScreen: widget.isComments,
                  ).launch(context);
                }, highlightColor: Colors.transparent, splashColor: Colors.transparent),
              ).expand(),
            ],
          )
        : Offstage();
  }
}
