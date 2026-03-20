import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/models/posts/post_model.dart';
import 'package:socialv/utils/app_constants.dart';

import '../../../main.dart';
import '../screens/add_post_screen.dart';

class PopUpMenuButtonComponent extends StatefulWidget {
  final PostModel post;
  final VoidCallback? onDeletePost;
  final VoidCallback? onReportPost;
  final VoidCallback? onHidePost;
  final VoidCallback? onFavorites;
  final VoidCallback? onPinned;
  final VoidCallback? callback;
  final int? groupId;
  final bool? showHidePostOption;

  const PopUpMenuButtonComponent({Key? key, required this.post, this.onDeletePost, this.onReportPost, this.onHidePost, this.onFavorites, this.onPinned, this.callback, this.groupId, this.showHidePostOption}) : super(key: key);

  @override
  State<PopUpMenuButtonComponent> createState() => _PopUpMenuButtonComponentState();
}

class _PopUpMenuButtonComponentState extends State<PopUpMenuButtonComponent> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
      ),
      child: PopupMenuButton(
        position: PopupMenuPosition.under,
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(commonRadius)),
        onSelected: (val) async {
          if (val == 1) {
            widget.onDeletePost!.call();
          } else if (val == 2) {
            widget.onReportPost!.call();
          } else if (val == 3) {
            AddPostScreen(
              showMediaOptions: widget.post.type == PostActivityType.activityShare ? false : true,
              post: widget.post,
              groupId: widget.post.groupId,
              groupName: widget.post.groupName.validate(),
              component: widget.groupId != null ? Component.groups : Component.members,
              callback: () {
                widget.callback?.call();
              },
            ).launch(context);
          } else if (val == 4) {
            widget.onHidePost!.call();
          } else if (val == 5) {
            widget.onFavorites!.call();
          } else if (val == 6) {
            widget.onPinned!.call();
          } else {
            AddPostScreen(
              showMediaOptions: false,
              parentPostId: widget.post.activityId.validate().toString(),
              groupId: widget.post.groupId,
              groupName: widget.post.groupName.validate(),
              component: widget.groupId != null ? Component.groups : Component.members,
              callback: () {
                widget.callback?.call();
              },
            ).launch(context);
          }
        },
        icon: Icon(Icons.more_vert),
        itemBuilder: (context) => <PopupMenuEntry>[
          PopupMenuItem(
            value: 5,
            child: TextIcon(
                text: widget.post.isFavorites == 1 ? language.unfavorite : language.favourite,
                textStyle: secondaryTextStyle(),
                prefix: Image.asset(widget.post.isFavorites == 1 ? ic_unstar : ic_star, color: appStore.isDarkMode ? bodyDark : bodyWhite, width: 16, height: 16)),
            textStyle: primaryTextStyle(),
          ),
          if (widget.post.isPinned == 0 || widget.post.canUnpinPost.validate().getBoolInt())
            PopupMenuItem(
              value: 6,
              child: TextIcon(
                  text: widget.post.isPinned == 1 ? language.unpin : language.pinToTop,
                  textStyle: secondaryTextStyle(),
                  prefix: Image.asset(widget.post.isPinned == 1 ? ic_unpin : ic_push_pin, color: appStore.isDarkMode ? bodyDark : bodyWhite, width: 16, height: 16)),
              textStyle: primaryTextStyle(),
            ),
          if (widget.post.userId.validate().toString() != userStore.loginUserId && widget.showHidePostOption!)
            PopupMenuItem(
              value: 4,
              child: TextIcon(text: language.hidePost, textStyle: secondaryTextStyle(), prefix: Icon(Icons.visibility_off_outlined, color: appStore.isDarkMode ? bodyDark : bodyWhite, size: 16)),
              textStyle: primaryTextStyle(),
            ),
          if (widget.post.userId.validate().toString() == userStore.loginUserId)
            PopupMenuItem(
              value: 3,
              child: TextIcon(text: language.editPost, textStyle: secondaryTextStyle(), prefix: Image.asset(ic_edit, color: appStore.isDarkMode ? bodyDark : bodyWhite, width: 16, height: 16)),
              textStyle: primaryTextStyle(),
            ),
          if (widget.post.userId.validate().toString() == userStore.loginUserId)
            PopupMenuItem(
              value: 1,
              child: TextIcon(text: language.deletePost, textStyle: secondaryTextStyle(), prefix: Image.asset(ic_delete, color: appStore.isDarkMode ? bodyDark : bodyWhite, width: 16, height: 16)),
              textStyle: primaryTextStyle(),
            ),
          PopupMenuItem(
            value: 7,
            child: TextIcon(text: language.shareOnActivity, textStyle: secondaryTextStyle(), prefix: Image.asset(ic_share, color: appStore.isDarkMode ? bodyDark : bodyWhite, width: 16, height: 16)),
            textStyle: primaryTextStyle(),
          ),
          if (widget.post.userId.validate().toString() != userStore.loginUserId && appStore.pluginStatus.iqonicModerationTools.getBoolInt())
            PopupMenuItem(
              value: 2,
              child: TextIcon(text: language.reportPost, textStyle: secondaryTextStyle(), prefix: Icon(Icons.report_gmailerrorred, color: appStore.isDarkMode ? bodyDark : bodyWhite, size: 16)),
              textStyle: primaryTextStyle(),
            ),
        ],
      ),
    );
  }
}
