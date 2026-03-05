import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/common_models/post_mdeia_model.dart';
import 'package:socialv/models/posts/comment_model.dart';
import 'package:socialv/screens/profile/screens/member_profile_screen.dart';
import 'package:socialv/store/fragment_store/home_fragment_store.dart';
import 'package:socialv/utils/cached_network_image.dart';
import 'package:socialv/utils/extentions/str_extentions.dart';

import '../../../models/reactions/reactions_count_model.dart';
import '../../../network/rest_apis.dart';
import '../../../utils/app_constants.dart';
import '../../../utils/html_widget.dart';

class CommentComponent extends StatefulWidget {
  final CommentModel comment;
  final bool isParent;
  final bool fromReplyScreen;
  final int postId;
  final int? parentId;
  final int? activityId;
  final VoidCallback? onReply;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? callback;

  CommentComponent({
    required this.isParent,
    required this.postId,
    this.onReply,
    this.onDelete,
    this.fromReplyScreen = false,
    this.callback,
    this.onEdit,
    required this.comment,
    this.parentId,
    this.activityId,
    super.key,
  });

  @override
  State<CommentComponent> createState() => _CommentComponentState();
}

class _CommentComponentState extends State<CommentComponent> {
  HomeFragStore commentComponentVars = HomeFragStore();
  bool isChange = false;
  bool isTyping = false;
  bool isSaving = false;

  TextEditingController editController = TextEditingController();
  FocusNode editFocusNode = FocusNode();

  @override
  void initState() {
    commentComponentVars.pageController = PageController(initialPage: 0);
    editController.addListener(() {
      setState(() {
        isTyping = editController.text.trim().isNotEmpty;
      });
    });
    init();
    super.initState();
  }

  Future<void> init() async {
    commentComponentVars.commentReactionList.addAll(widget.comment.reactions.validate());
    commentComponentVars.commentReactionCount = widget.comment.reactionCount.validate();
    commentComponentVars.isReactedOnComment = widget.comment.curUserReaction != null;
  }

  Future<void> postReaction({bool addReaction = false, int? reactionID}) async {
    ifNotTester(() async {
      if (addReaction) {
        if (commentComponentVars.commentReactionList.length < 3 && commentComponentVars.isReactedOnComment.validate()) {
          if (commentComponentVars.commentReactionList.any((element) => element.user!.id.validate().toString() == userStore.loginUserId)) {
            int index = commentComponentVars.commentReactionList.indexWhere((element) => element.user!.id.validate().toString() == userStore.loginUserId);
            commentComponentVars.commentReactionList[index].id = reactionID.validate().toString();
            commentComponentVars.commentReactionList[index].icon = appStore.reactions.firstWhere((element) => element.id == reactionID.validate().toString().validate()).imageUrl.validate();
            commentComponentVars.commentReactionList[index].reaction = appStore.reactions.firstWhere((element) => element.id == reactionID.validate().toString().validate()).name.validate();
          } else {
            commentComponentVars.commentReactionList.add(
              Reactions(
                id: reactionID.validate().toString(),
                icon: appStore.reactions.firstWhere((element) => element.id == reactionID.validate().toString().validate()).imageUrl.validate(),
                reaction: appStore.reactions.firstWhere((element) => element.id == reactionID.validate().toString().validate()).name.validate(),
                user: ReactedUser(
                  id: userStore.loginUserId.validate().toInt(),
                  displayName: userStore.loginFullName,
                ),
              ),
            );
            commentComponentVars.commentReactionCount++;
          }
        }

        await addPostReaction(id: widget.comment.id.toInt().validate(), reactionId: reactionID.validate(), isComments: true).then((value) {
          //
        }).catchError((e) {
          log('Error: ${e.toString()}');
        });
      } else {
        commentComponentVars.commentReactionList.removeWhere((element) => element.user!.id.validate().toString() == userStore.loginUserId);

        commentComponentVars.commentReactionCount--;
        await deletePostReaction(id: widget.comment.id.toInt().validate(), isComments: true).then((value) {
          //
        }).catchError((e) {
          log('Error: ${e.toString()}');
        });
      }
    });
  }

  void startEditing() {
    if (!mounted) return;
    setState(() {
      commentComponentVars.isEditing = true;
      editController.text = parseHtmlString(widget.comment.content.validate());
    });
    // Focus the text field after a short delay to ensure the widget is built
    Future.delayed(Duration(milliseconds: 100), () {
      editFocusNode.requestFocus();
    });
  }
  void saveEdit() async {
    if (editController.text.trim().isEmpty) {
      toast(language.writeComment);
      return;
    }

    setState(() => isSaving = true);

    ifNotTester(() async {
      Map<String, dynamic> request = {
        "content": editController.text.trim(),
        "comment_id": widget.comment.id.validate(),
      };

      if (widget.parentId != null) {
        request["parent_comment_id"] = widget.parentId;
      }

      await savePostComment(
        postId: widget.activityId ?? widget.postId,
        request: request,
      ).then((value) {
        commentComponentVars.isEditing = false;
        hideKeyboard(context);
        widget.onEdit?.call();
        toast(language.commentUpdatedSuccessfully);
      }).catchError((e) {
        toast(e.toString(), print: true);
      }).whenComplete(() {
        setState(() => isSaving = false);
      });
    });
  }


  void cancelEditing() {
    setState(() {
      commentComponentVars.isEditing = true;
      editController.clear();
    });
    editFocusNode.unfocus();
  }


  @override
  void dispose() {
    commentComponentVars.pageController.dispose();
    editFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              cachedImage(
                widget.comment.userImage.validate(),
                height: widget.isParent ? 36 : 25,
                width: widget.isParent ? 36 : 25,
                fit: BoxFit.cover,
              ).cornerRadiusWithClipRRect(100),
              8.width,
              Flexible(
                child: Container(
                  padding: EdgeInsets.only(left: 10, right: 20, top: 4, bottom: 4),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: context.scaffoldBackgroundColor),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(text: widget.comment.userId.validate() == userStore.loginUserId ? language.you : '${widget.comment.userName.validate()} ', style: boldTextStyle(size: 14, fontFamily: fontFamily)),
                            if (widget.comment.isUserVerified.validate()) WidgetSpan(child: Image.asset(ic_tick_filled, height: widget.isParent ? 18 : 12, width: widget.isParent ? 18 : 12, color: blueTickColor, fit: BoxFit.cover)),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                      ),
                      4.height,
                      commentComponentVars.isEditing
                          ? SizedBox(
                              height: 60,
                              child: TextFormField(
                                controller: editController,
                                focusNode: editFocusNode,
                                autofocus: true,
                                minLines: 1,
                                maxLines: 5,
                                textCapitalization: TextCapitalization.sentences,
                                decoration: InputDecoration(
                                  suffixIcon: isSaving
                                      ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: Padding(
                                      padding: EdgeInsets.all(10),
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  )
                                      : IconButton(
                                    onPressed: () {
                                      saveEdit();
                                    },
                                    icon: Icon(Icons.send),
                                  ),

                                  hintText: language.writeAComment,
                                  hintStyle: secondaryTextStyle(size: 14),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: context.dividerColor),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: context.primaryColor),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  filled: true,
                                  fillColor: context.cardColor,
                                ),
                                onTapOutside: (value) {
                                  editFocusNode.unfocus();
                                  // Cancel editing if the user taps outside the text field
                                  cancelEditing();
                                },
                              ),
                            )
                          : (widget.comment.hasMentions == 1 || widget.comment.content.validate().contains('href') || widget.comment.content.validate().contains('</br>'))
                              ? HtmlWidget(postContent: widget.comment.content.validateAndFilter())
                              : Text(parseHtmlString(widget.comment.content.validateAndFilter()), style: primaryTextStyle(size: 14)),
                    ],
                  ),
                ),
              ),
            ],
          ).onTap(() {
            if (!commentComponentVars.isEditing) {
              MemberProfileScreen(memberId: widget.comment.userId.validate().toInt()).launch(context);
            }
          }, splashColor: Colors.transparent, highlightColor: Colors.transparent),
          if (widget.comment.medias.validate().isNotEmpty)
            SizedBox(
              height: 200,
              width: context.width(),
              child: Observer(builder: (context) {
                return PageView.builder(
                  controller: commentComponentVars.pageController,
                  itemCount: widget.comment.medias.validate().length,
                  itemBuilder: (ctx, index) {
                    PostMediaModel media = widget.comment.medias.validate()[index];
                    return cachedImage(media.url, radius: defaultAppButtonRadius);
                  },
                );
              }),
            ),
          if (!commentComponentVars.isEditing)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (widget.comment.id != null)
                      TextButton(
                        onPressed: () {
                          if (!appStore.isLoading) {
                            isChange = true;
                            widget.onReply?.call();
                          }
                        },
                        child: Text(language.reply),
                      ).paddingLeft(40),
                    Text(convertToAgo(widget.comment.dateRecorded.validate()), style: secondaryTextStyle(size: 12)),
                    if (widget.comment.userId == userStore.loginUserId && widget.comment.id != null)
                      IconButton(
                        onPressed: () {
                          if (!appStore.isLoading) {
                            isChange = true;
                            widget.onDelete?.call();
                          }
                        },
                        icon: cachedImage(ic_delete, color: Colors.red, width: 16, height: 16),
                      ),
                    if (widget.comment.userId == userStore.loginUserId && widget.comment.id != null)
                      IconButton(
                        onPressed: () {
                          if (!appStore.isLoading) {
                            startEditing();
                          }
                        },
                        icon: cachedImage(ic_edit, color: context.primaryColor, width: 16, height: 16),
                      ),
                  ],
                ),
              ],
            ),
        ],
      );
    });
  }
}
