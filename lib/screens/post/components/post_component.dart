import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:share_plus/share_plus.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/posts/get_post_likes_model.dart';
import 'package:socialv/models/posts/post_model.dart';
import 'package:socialv/models/reactions/reactions_count_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/blockReport/components/show_report_dialog.dart';
import 'package:socialv/screens/blog/screens/blog_detail_screen.dart';
import 'package:socialv/screens/groups/screens/group_detail_screen.dart';
import 'package:socialv/screens/membership/screens/membership_plans_screen.dart';
import 'package:socialv/screens/post/components/hidden_post_component.dart';
import 'package:socialv/screens/post/components/like_button_widget.dart';
import 'package:socialv/screens/post/components/popup_menu_button_component.dart';
import 'package:socialv/screens/post/components/post_likes_component.dart';
import 'package:socialv/screens/post/components/post_media_component.dart';
import 'package:socialv/screens/post/components/post_reaction_component.dart';
import 'package:socialv/screens/post/components/quick_view_post_widget.dart';
import 'package:socialv/screens/post/components/reaction_button_widget.dart';
import 'package:socialv/screens/post/screens/comment_screen.dart';
import 'package:socialv/screens/post/screens/single_post_screen.dart';
import 'package:socialv/screens/profile/screens/member_profile_screen.dart';
import 'package:socialv/store/fragment_store/home_fragment_store.dart';
import 'package:socialv/utils/cached_network_image.dart';
import 'package:socialv/utils/overlay_handler.dart';
import 'package:socialv/utils/app_constants.dart';

import 'post_content_component.dart';

// ignore: must_be_immutable
class PostComponent extends StatefulWidget {
  final PostModel post;
  final VoidCallback? callback;
  final VoidCallback? commentCallback;
  int? count;
  final bool fromGroup;
  final bool fromProfile;
  final bool fromFavourites;
  final int? groupId;
  final bool showHidePostOption;
  final bool childPost;
  final Color? color;

  PostComponent({
    required this.post,
    this.callback,
    this.count,
    this.fromGroup = false,
    this.groupId,
    this.showHidePostOption = false,
    this.childPost = false,
    this.color,
    this.fromProfile = false,
    this.commentCallback,
    this.fromFavourites = false,
    super.key,
  });

  @override
  State<PostComponent> createState() => _PostComponentState();
}

class _PostComponentState extends State<PostComponent> {
  OverlayHandler _overlayHandler = OverlayHandler();
  HomeFragStore postComponentVars = HomeFragStore();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    postComponentVars.isPostHidden = false;
    postComponentVars.postLikeList.clear();
    postComponentVars.postLikeList.addAll(widget.post.usersWhoLiked.validate());
    postComponentVars.postLikeCount = widget.post.likeCount.validate();
    postComponentVars.isLiked = widget.post.isLiked.validate() == 1;
    postComponentVars.postReactionList.clear();
    postComponentVars.postReactionList.addAll(widget.post.reactions.validate());
    postComponentVars.isReacted = widget.post.curUserReaction != null;
    postComponentVars.notify = postComponentVars.isReacted.validate();
    postComponentVars.postReactionCount = widget.post.reactionCount.validate();
  }

  Future<void> postReaction({bool addReaction = false, int? reactionID, bool fromQuickView = false}) async {
    ifNotTester(() async {
      if (addReaction) {
        if (postComponentVars.postReactionList.length < 3 && postComponentVars.isReacted.validate()) {
          if (postComponentVars.postReactionList.any((element) => element.user!.id.validate().toString() == userStore.loginUserId)) {
            int index = postComponentVars.postReactionList.indexWhere((element) => element.user!.id.validate().toString() == userStore.loginUserId);
            postComponentVars.postReactionList[index].id = reactionID.validate().toString();
            postComponentVars.postReactionList[index].icon = appStore.reactions.firstWhere((element) => element.id == reactionID.validate().toString().validate()).imageUrl.validate();
            postComponentVars.postReactionList[index].reaction = appStore.reactions.firstWhere((element) => element.id == reactionID.validate().toString().validate()).name.validate();
          } else {
            postComponentVars.postReactionList.add(
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
            postComponentVars.postReactionCount++;
          }
        }
        widget.post.curUserReaction = Reactions(
          id: reactionID.validate().toString(),
          icon: appStore.reactions.firstWhere((element) => element.id == reactionID.validate().toString().validate()).imageUrl.validate(),
          reaction: appStore.reactions.firstWhere((element) => element.id == reactionID.validate().toString().validate()).name.validate(),
          user: ReactedUser(
            id: userStore.loginUserId.validate().toInt(),
            displayName: userStore.loginFullName,
          ),
        );
        postComponentVars.notify = true;
        await addPostReaction(id: widget.post.activityId.validate(), reactionId: reactionID.validate(), isComments: false).then((value) {
          if (fromQuickView) widget.callback!.call();
        }).catchError((e) {
          log('Error: ${e.toString()}');
        });
      } else {
        widget.post.curUserReaction = null;
        if (postComponentVars.postReactionList.any((element) => element.user!.id.validate().toString() == userStore.loginUserId)) {
          postComponentVars.postReactionList.removeWhere((element) => element.user!.id.validate().toString() == userStore.loginUserId);
          postComponentVars.postReactionCount--;
        }

        postComponentVars.notify = false;
        await deletePostReaction(id: widget.post.activityId.validate(), isComments: false).then((value) {
          if (fromQuickView) widget.callback!.call();
        }).catchError((e) {
          log('Error: ${e.toString()}');
        });
      }
    });
  }

  Future<void> postLike() async {
    ifNotTester(() async {
      postComponentVars.isLiked = !postComponentVars.isLiked;

      if (postComponentVars.isLiked) {
        if (postComponentVars.postLikeList.length < 3 && postComponentVars.isLiked) {
          postComponentVars.postLikeList.add(GetPostLikesModel(
            userId: userStore.loginUserId,
            userAvatar: userStore.loginAvatarUrl,
            userName: userStore.loginFullName,
          ));
        }
        postComponentVars.postLikeCount++;
        await likePost(postId: widget.post.activityId.validate()).then((value) {
          //
        }).catchError((e) {
          log('Error: ${e.toString()}');
        });
      } else {
        if (postComponentVars.postLikeList.length <= 3) {
          postComponentVars.postLikeList.removeWhere((element) => element.userId == userStore.loginUserId);
        }
        postComponentVars.postLikeCount--;
        await likePost(postId: widget.post.activityId.validate()).then((value) {
          //
        }).catchError((e) {
          log('Error: ${e.toString()}');
        });
      }
    });
  }

  Future<void> onHidePost() async {
    ifNotTester(() async {
      postComponentVars.isPostHidden = !postComponentVars.isPostHidden;

      if (postComponentVars.isPostHidden) {
        toast(language.thisPostIsNowHidden);
      } else {
        toast(language.postUnhiddenToast);
      }

      await hidePost(id: widget.post.activityId.validate()).then((value) {
        //
      }).catchError((e) {
        log("Error:" + e.toString());
      });
    });
  }

  Future<void> onReportPost() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 45,
              height: 5,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colors.white),
            ),
            8.height,
            Container(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
              ),
              child: ShowReportDialog(
                isPostReport: true,
                postId: widget.post.activityId.validate(),
                userId: widget.post.userId.validate(),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> onDeletePost() async {
    showConfirmDialogCustom(
      context,
      onAccept: (c) {
        ifNotTester(() {
          appStore.setLoading(true);
          deletePost(postId: widget.post.activityId.validate()).then((value) {
            appStore.setLoading(false);
            toast(language.postDeleted);
            widget.callback?.call();
          }).catchError((e) {
            appStore.setLoading(false);
            toast(e.toString());
          });
        });
      },
      dialogType: DialogType.DELETE,
      title: language.deletePostConfirmation,
      positiveText: language.delete,
    );
  }

  Future<void> onUnfriend() async {
    showConfirmDialogCustom(
      context,
      onAccept: (c) async {
        ifNotTester(() async {
          appStore.setLoading(true);
          await removeExistingFriendConnection(friendId: widget.post.userId.toString(), passRequest: true).then((value) {
            appStore.setLoading(false);
            widget.callback?.call();
          }).catchError((e) {
            appStore.setLoading(false);
            log(e.toString());
          });
        });
      },
      dialogType: DialogType.CONFIRMATION,
      title: language.unfriendConfirmation,
      positiveText: language.remove,
    );
  }

  Future<void> onViewBlogPost() async {
    if (widget.post.blogId != null) {
      appStore.setLoading(true);
      await wpPostById(postId: widget.post.blogId.validate()).then((value) {
        appStore.setLoading(false);
        if (value.is_restricted.validate()) {
          MembershipPlansScreen().launch(context);
        } else {
          BlogDetailScreen(blogId: widget.post.blogId.validate(), data: value).launch(context);
        }
      }).catchError((e) {
        toast(language.canNotViewPost);
        appStore.setLoading(false);
      });
    } else {
      toast(language.canNotViewPost);
    }
  }

  Future<void> onFavorites() async {
    ifNotTester(() {
      if (widget.post.isFavorites == 0) {
        widget.post.isFavorites = 1;
        setState(() {});
        toast(language.postAddedToFavorite);
      } else {
        widget.post.isFavorites = 0;
        setState(() {});
        toast(language.postRemovedFromFavorite);
      }
      Map<String, dynamic> request = {"is_favorite": widget.post.isFavorites};

      favoriteActivity(request: request, activityId: widget.post.activityId.validate().toInt()).then((value) {
        if (widget.post.isFavorites == 0 && widget.fromFavourites) widget.commentCallback?.call();
      }).catchError((e) {
        log('Error: ${e.toString()}');
      });
    });
  }

  Future<void> onPinned() async {
    ifNotTester(() async {
      Map<String, dynamic> request = {
        "pin_activity": widget.post.isPinned == 1 ? 0 : 1,
      };

      if (widget.fromGroup) request.putIfAbsent('group_id', () => widget.groupId);
      if (widget.fromFavourites)
        request.putIfAbsent('screen', () => "favorites");
      else if (widget.fromGroup)
        request.putIfAbsent('screen', () => "groups");
      else if (widget.fromProfile)
        request.putIfAbsent('screen', () => "timeline");
      else
        request.putIfAbsent('screen', () => "newsfeed");
      pinActivity(activityId: widget.post.activityId.validate(), request: request).catchError((e) {
        log('Error: ${e.toString()}');
        return null;
      });
      if (widget.post.isPinned == 0) {
        widget.post.isPinned = 1;
        widget.post.canUnpinPost = 1;
        toast(language.pinned);
      } else {
        widget.post.isPinned = 0;
        widget.post.canUnpinPost = 0;
        toast(language.unpinned);
      }
    });
  }

  @override
  void dispose() {
    _overlayHandler.removeOverlay(context);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.count == 0) {
      init();
      widget.count = widget.count.validate() + 1;
    }

    return Observer(builder: (context) {
      return !postComponentVars.isPostHidden
          ? GestureDetector(
              onTap: () {
                if (widget.post.type.validate() == PostActivityType.newBlogPost) {
                  onViewBlogPost();
                } else {
                  SinglePostScreen(postId: widget.post.activityId.validate()).launch(context).then((value) {
                    if (value ?? false) widget.callback?.call();
                  });
                }
              },
              onPanEnd: (s) {
                if (!widget.childPost.validate()) _overlayHandler.removeOverlay(context);
              },
              onLongPress: () {
                if (!widget.childPost.validate())
                  _overlayHandler.insertOverlay(
                    context,
                    OverlayEntry(
                      builder: (context) {
                        return QuickViewPostWidget(
                          postModel: widget.post,
                          isPostLiked: postComponentVars.isLiked,
                          onPostLike: () async {
                            postLike();
                            widget.callback!.call();
                          },
                          onPostReacted: (id) {
                            postComponentVars.isReacted = true;
                            postReaction(reactionID: id, addReaction: true);
                          },
                          onReactionRemoved: () {
                            postComponentVars.isReacted = false;
                            postReaction(reactionID: widget.post.curUserReaction!.id.toInt(), addReaction: false);
                          },
                          pageIndex: postComponentVars.index,
                          isPostReacted: postComponentVars.isReacted!,
                        );
                      },
                    ),
                  );
              },
              onLongPressEnd: (details) {
                if (!widget.childPost.validate()) _overlayHandler.removeOverlay(context);
              },
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(borderRadius: radius(commonRadius), color: widget.color ?? context.cardColor),
                child: Observer(builder: (context) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          cachedImage(
                            widget.post.userImage.validate(),
                            height: 40,
                            width: 40,
                            fit: BoxFit.cover,
                          ).cornerRadiusWithClipRRect(20).onTap(() {
                            MemberProfileScreen(memberId: widget.post.userId.validate()).launch(context);
                          }),
                          8.width,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        widget.post.userId.validate().toString() == userStore.loginUserId.toString() ? language.you.capitalizeFirstLetter() : widget.post.userName.validate(),
                                        style: boldTextStyle(),
                                      ),
                                      if (widget.post.isUserVerified.validate() == 1)
                                        Icon(
                                          Icons.verified,
                                          color: Colors.blue.shade700,
                                          size: 16,
                                        ).paddingSymmetric(horizontal: 4),
                                    ],
                                  ).expand(),
                                  if (widget.post.isPinned.validate() == 1) Image.asset(ic_pin, height: 18, width: 18, color: context.primaryColor).paddingSymmetric(horizontal: 4),
                                  if (widget.post.isFavorites.validate() == 1) Image.asset(ic_star_filled, height: 18, width: 18, color: context.primaryColor).paddingSymmetric(horizontal: 4),
                                ],
                              ),
                              Text(
                                convertToAgo(widget.post.dateRecorded.validate()),
                                style: secondaryTextStyle(size: 12),
                              ),
                            ],
                          ).expand(),
                          if (!widget.childPost.validate())
                            PopUpMenuButtonComponent(
                              post: widget.post,
                              onReportPost: () => onReportPost(),
                              onFavorites: () => onFavorites(),
                              onDeletePost: () => onDeletePost(),
                              onPinned: () => onPinned(),
                              onHidePost: () => onHidePost(),
                              callback: () => widget.callback!.call(),
                              groupId: widget.groupId,
                              showHidePostOption: widget.showHidePostOption,
                            ),
                        ],
                      ).paddingOnly(left: 16, right: 16, top: 16, bottom: 8),
                      if (!widget.fromGroup)
                        if (widget.post.postIn == Component.groups && widget.post.groupName.validate().isNotEmpty)
                          InkWell(
                            onTap: () {
                              if (widget.post.groupId != 0) {
                                if (pmpStore.viewSingleGroup) {
                                  GroupDetailScreen(groupId: widget.post.groupId.validate()).launch(context);
                                } else {
                                  MembershipPlansScreen().launch(context);
                                }
                              }
                            },
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                      text: widget.post.userId.toString() == userStore.loginUserId.toString() ? language.you : widget.post.userName.validate(),
                                      style: boldTextStyle(fontFamily: fontFamily, size: 14)),
                                  TextSpan(text: ' ${language.postedAnUpdateInTheGroup} ', style: primaryTextStyle(fontFamily: fontFamily, size: 14)),
                                  TextSpan(text: '${widget.post.groupName.validate()} ', style: boldTextStyle(fontFamily: fontFamily, size: 14)),
                                ],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.start,
                            ).paddingSymmetric(horizontal: 8),
                          ),
                      Divider(),
                      if (widget.post.content != null && widget.post.content!.replaceAll(RegExp(r'<[^>]*>|&nbsp;'), '').trim().isNotEmpty)
                        Column(
                          children: [
                            PostContentComponent(
                              postContent: widget.post.content,
                              hasMentions: widget.post.hasMentions == 1,
                              postType: widget.post.type,
                              blogId: widget.post.blogId,
                              contentObject: widget.post.contentObject,
                            ).paddingSymmetric(horizontal: 8),
                            8.height,
                          ],
                        ),
                      PostMediaComponent(
                        mediaTitle: widget.post.userId.validate() == userStore.loginUserId ? language.you : widget.post.userName.validate(),
                        mediaType: widget.post.mediaType.validate(),
                        mediaList: widget.post.medias.validate(),
                        onPageChange: (i) {
                          postComponentVars.index = i;
                        },
                      ),
                      if (widget.post.type == PostActivityType.activityShare && widget.post.childPost != null)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: PostComponent(post: widget.post.childPost!, childPost: true, color: context.scaffoldBackgroundColor),
                        ),
                      if (widget.childPost.validate())
                        TextButton(
                          onPressed: () {
                            SinglePostScreen(postId: widget.post.activityId.validate()).launch(context).then((value) {
                              if (value ?? false) widget.callback?.call();
                            });
                          },
                          child: Text(language.viewPost, style: primaryTextStyle(color: context.primaryColor)),
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (!widget.childPost.validate())
                            if (appStore.isReactionEnable)
                              ThreeReactionComponent(
                                isComments: false,
                                id: widget.post.activityId.validate(),
                                postReactionCount: postComponentVars.postReactionCount,
                                postReactionList: postComponentVars.postReactionList,
                              ).paddingOnly(left: 8).expand()
                            else
                              PostLikesComponent(
                                postLikeList: postComponentVars.postLikeList,
                                postId: widget.post.activityId.validate(),
                                postLikeCount: postComponentVars.postLikeCount,
                              ),
                          if (appStore.displayPostCommentsCount)
                            widget.post.commentCount.validate() > 0
                                ? Text(
                                    '${widget.post.commentCount} ${widget.post.commentCount.validate() > 1 ? language.comments : language.comment}',
                                    style: secondaryTextStyle(size: 12),
                                  ).paddingOnly(right: 8, left: 8).onTap(() {
                                    CommentScreen(
                                      postId: widget.post.activityId.validate(),
                                      callback: () {
                                        widget.commentCallback?.call();
                                      },
                                    ).launch(context);
                                  })
                                : Offstage(),
                        ],
                      ).paddingOnly(top: 8),
                      if (!widget.childPost.validate())
                        Observer(
                          builder: (context) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (appStore.isReactionEnable)
                                  if (appStore.reactions.validate().isNotEmpty)
                                    ReactionButton(
                                      isReacted: postComponentVars.notify,
                                      isComments: false,
                                      currentUserReaction: widget.post.curUserReaction,
                                      onReacted: (id) {
                                        postComponentVars.isReacted = true;
                                        postReaction(addReaction: true, reactionID: id);
                                      },
                                      onReactionRemoved: () {
                                        postComponentVars.isReacted = false;
                                        postReaction(addReaction: false);
                                      },
                                    )
                                  else
                                    Offstage()
                                else
                                  LikeButtonWidget(
                                      onPostLike: () {
                                        postLike();
                                      },
                                      isPostLiked: postComponentVars.isLiked),
                                TextButton(
                                  onPressed: () {
                                    if (!appStore.isLoading) {
                                      CommentScreen(
                                          postId: widget.post.activityId.validate(),
                                          callback: () {
                                            widget.commentCallback?.call();
                                          }).launch(context);
                                    }
                                  },
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        ic_chat,
                                        height: 22,
                                        width: 22,
                                        fit: BoxFit.cover,
                                        color: context.iconColor,
                                      ).paddingOnly(right: 4, bottom: 8, top: 8, left: 6),
                                      Text(language.comment, style: secondaryTextStyle(size: 14))
                                    ],
                                  ),
                                ).paddingSymmetric(horizontal: 8),
                                TextButton(
                                    onPressed: () {
                                      if (!appStore.isLoading) {
                                        String saveUrl = "$DOMAIN_URL/activity/p/${widget.post.activityId}";
                                        SharePlus.instance.share(ShareParams(uri: Uri.parse(saveUrl.trim())));
                                      }
                                    },
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          ic_share,
                                          height: 20,
                                          width: 20,
                                          fit: BoxFit.cover,
                                          color: context.iconColor,
                                        ).paddingAll(4),
                                        Text(language.share, style: secondaryTextStyle(size: 14))
                                      ],
                                    ))
                              ],
                            ).paddingSymmetric(horizontal: 8);
                          },
                        ),
                    ],
                  );
                }),
              ),
            )
          : HiddenPostComponent(
              isFriend: widget.post.isFriend.validate() == 1,
              userName: widget.post.userName.validate(),
              onReportPost: () => onReportPost(),
              onUndo: () => onHidePost(),
              onUnfriend: () => onUnfriend(),
            );
    });
  }
}
