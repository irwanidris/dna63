import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:share_plus/share_plus.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/common_models/post_mdeia_model.dart';
import 'package:socialv/models/posts/comment_model.dart';
import 'package:socialv/models/posts/get_post_likes_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/post/components/comment_component.dart';
import 'package:socialv/screens/post/components/like_button_widget.dart';
import 'package:socialv/screens/post/components/post_component.dart';
import 'package:socialv/screens/post/components/post_media_component.dart';
import 'package:socialv/screens/post/components/reaction_button_widget.dart';
import 'package:socialv/screens/post/screens/comment_screen.dart';
import 'package:socialv/screens/post/screens/post_likes_screen.dart';
import 'package:socialv/screens/profile/screens/member_profile_screen.dart';
import 'package:socialv/store/fragment_store/home_fragment_store.dart';
import 'package:socialv/utils/app_constants.dart';
import 'package:socialv/utils/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../models/reactions/reactions_count_model.dart';
import '../components/post_content_component.dart';
import '../components/post_reaction_component.dart';

class SinglePostScreen extends StatefulWidget {
  final int postId;

  const SinglePostScreen({required this.postId});

  @override
  State<SinglePostScreen> createState() => _SinglePostScreenState();
}

class _SinglePostScreenState extends State<SinglePostScreen> {
  HomeFragStore singlePostScreenVars = HomeFragStore();
  PageController pageController = PageController();
  FocusNode commentFocus = FocusNode();
  TextEditingController commentController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  int mPage = 1;
  bool mIsLastPage = false;
  bool isTyping = false;
  bool isReply = false;

  @override
  void initState() {
    postDetail(showLoader: true);
    singlePostScreenVars.isChange = false;
    getComment(showLoader: true);
    super.initState();
  }

  Future<void> getComment({bool showLoader = true, int page = 1}) async {
    // appStore.setLoading(showLoader);
    getComments(
      id: widget.postId,
      page: page,
      commentList: singlePostScreenVars.commentList,
      lastPageCallback: (p0) {},
    ).then((value) {
      appStore.setLoading(false);
      singlePostScreenVars.isError = false;
      return value;
    }).catchError((e) {
      singlePostScreenVars.isError = true;
      appStore.setLoading(false);
      toast(e.toString(), print: true);
      return e;
    });
  }

  Future<void> postDetail({bool showLoader = false}) async {
    singlePostScreenVars.isError = false;
    appStore.setLoading(showLoader);
    await getSinglePost(postId: widget.postId.validate()).then((value) {
      singlePostScreenVars.singlePost = value;
      singlePostScreenVars.likeCount = value.likeCount.validate();
      singlePostScreenVars.likeList.addAll(value.usersWhoLiked.validate());
      singlePostScreenVars.isLike = value.isLiked.validate() == 1;
      singlePostScreenVars.postReactionList.addAll(value.reactions.validate());
      singlePostScreenVars.isReacted = value.curUserReaction != null;
      singlePostScreenVars.notify = singlePostScreenVars.isReacted.validate();
      singlePostScreenVars.postReactionCount = value.reactionCount.validate();
      appStore.setLoading(false);
    }).catchError((e) {
      singlePostScreenVars.isError = true;
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  Future<void> postReaction({bool addReaction = false, int? reactionID}) async {
    ifNotTester(() async {
      if (addReaction) {
        if (singlePostScreenVars.postReactionList.length < 3 && singlePostScreenVars.isReacted.validate()) {
          if (singlePostScreenVars.postReactionList.any((element) => element.user!.id.validate().toString() == userStore.loginUserId)) {
            int index = singlePostScreenVars.postReactionList.indexWhere((element) => element.user!.id.validate().toString() == userStore.loginUserId);
            singlePostScreenVars.postReactionList[index].id = reactionID.validate().toString();
            singlePostScreenVars.postReactionList[index].icon = appStore.reactions.firstWhere((element) => element.id == reactionID.validate().toString().validate()).imageUrl.validate();
            singlePostScreenVars.postReactionList[index].reaction = appStore.reactions.firstWhere((element) => element.id == reactionID.validate().toString().validate()).name.validate();
          } else {
            singlePostScreenVars.postReactionList.add(
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
            singlePostScreenVars.postReactionCount++;
          }
        }

        await addPostReaction(id: singlePostScreenVars.singlePost!.activityId.validate(), reactionId: reactionID.validate(), isComments: false).then((value) {
          //
        }).catchError((e) {
          log('Error: ${e.toString()}');
        });
      } else {
        singlePostScreenVars.postReactionList.removeWhere((element) => element.user!.id.validate().toString() == userStore.loginUserId);

        singlePostScreenVars.postReactionCount--;
        await deletePostReaction(id: singlePostScreenVars.singlePost!.activityId.validate(), isComments: false).then((value) {
          //
        }).catchError((e) {
          log('Error: ${e.toString()}');
        });
      }
    });
  }

  Future<void> postLike() async {
    ifNotTester(() {
      singlePostScreenVars.isLike = !singlePostScreenVars.isLike;

      likePost(postId: singlePostScreenVars.singlePost!.activityId.validate()).then((value) {
        singlePostScreenVars.isChange = true;
        if (singlePostScreenVars.likeList.length < 3 && singlePostScreenVars.isLike) {
          singlePostScreenVars.likeList.add(GetPostLikesModel(
            userId: userStore.loginUserId,
            userAvatar: userStore.loginAvatarUrl,
            userName: userStore.loginFullName,
          ));
        }
        if (!singlePostScreenVars.isLike) {
          if (singlePostScreenVars.likeList.length <= 3) {
            singlePostScreenVars.likeList.removeWhere((element) => element.userId == userStore.loginUserId);
          }
          singlePostScreenVars.likeCount--;
        }

        if (singlePostScreenVars.isLike) {
          singlePostScreenVars.likeCount++;
        }
      }).catchError((e) {
        if (singlePostScreenVars.likeList.length < 3) {
          singlePostScreenVars.likeList.removeWhere((element) => element.userId == userStore.loginUserId);
        }
        singlePostScreenVars.isLike = false;
        log(e.toString());
      });
    });
  }

  void deleteComment(int commentId) async {
    ifNotTester(() async {
      //  appStore.setLoading(true);
      await deletePostComment(postId: widget.postId, commentId: commentId).then((value) {
        getComment();
        toast(language.commentSucesfullyDeleted);
      }).catchError((e) {
        appStore.setLoading(false);
        toast(e.toString());
      });
    });
  }

  void postComment(String commentContent, {int? parentId}) async {
    ifNotTester(() async {
      var newComment = CommentModel(
        content: commentContent,
        userImage: userStore.loginAvatarUrl,
        dateRecorded: DateFormat(DATE_FORMAT_1).format(DateTime.now()),
        userName: userStore.loginFullName,
        medias: singlePostScreenVars.commentGif != null
            ? [
                PostMediaModel(
                  url: singlePostScreenVars.commentGif!.images!.original!.url.validate(),
                )
              ]
            : [],
        children: ObservableList<CommentModel>(),
      );

      int? scrollToIndex;

      runInAction(() {
        if (parentId == null) {
          singlePostScreenVars.commentList.add(newComment);
          scrollToIndex = singlePostScreenVars.commentList.length - 1;
        } else {
          var parentIndex = singlePostScreenVars.commentList.indexWhere((e) => e.id == parentId);
          if (parentIndex != -1) {
            singlePostScreenVars.commentList[parentIndex].children?.add(newComment);
            scrollToIndex = parentIndex;
          }
        }
      });

      Future.delayed(Duration(milliseconds: 100), () {
        if (_scrollController.hasClients && scrollToIndex != null) {
          const itemHeight = 100.0;
          _scrollController.animateTo(
            itemHeight * scrollToIndex!,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });

      commentController.clear();
      singlePostScreenVars.commentGif = null;

      Map<String, dynamic> request = {
        "content": commentContent,
        "media_type": singlePostScreenVars.commentGif != null ? MediaTypes.gif : "",
        "media_id": singlePostScreenVars.commentGif?.id ?? "",
        "media": singlePostScreenVars.commentGif?.images?.original?.url ?? "",
      };

      if (parentId != null) {
        request["parent_comment_id"] = parentId;
      }

      await savePostComment(postId: widget.postId, request: request).then((value) {
        getComment();
      }).catchError((e) {
        appStore.setLoading(false);
        toast(e.toString());
      });
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!Navigator.canPop(context)) {
          appStore.setLoading(false);
          finish(context, singlePostScreenVars.isChange);
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {});
        }
      },
      child: RefreshIndicator(
        onRefresh: () async {
          postDetail();
        },
        color: context.primaryColor,
        child: Scaffold(
          appBar: AppBar(
            title: Text(language.post, style: boldTextStyle(size: 20)),
            elevation: 0,
            centerTitle: true,
          ),
          body: SizedBox(
            height: context.height(),
            child: Stack(
              // alignment: Alignment.topCenter,
              children: [
                AnimatedScrollView(
                  children: [
                    /// error widget
                    Observer(builder: (context) {
                      return singlePostScreenVars.isError && !appStore.isLoading
                          ? SizedBox(
                              height: context.height() * 0.88,
                              child: NoDataWidget(
                                imageWidget: NoDataLottieWidget(),
                                title: singlePostScreenVars.isError ? language.somethingWentWrong : language.noDataFound,
                                onRetry: () {
                                  postDetail();
                                },
                                retryText: '   ${language.clickToRefresh}   ',
                              ).center(),
                            )
                          : Offstage();
                    }),

                    /// empty list widget
                    Observer(builder: (context) {
                      return singlePostScreenVars.singlePost == null && !appStore.isLoading && !singlePostScreenVars.isError
                          ? SizedBox(
                              height: context.height() * 0.88,
                              child: NoDataWidget(
                                imageWidget: NoDataLottieWidget(),
                                title: singlePostScreenVars.isError ? language.somethingWentWrong : language.noDataFound,
                                onRetry: () {
                                  postDetail();
                                },
                                retryText: '   ${language.clickToRefresh}   ',
                              ).center(),
                            )
                          : Offstage();
                    }),

                    /// list data widget

                    Observer(builder: (context) {
                      return !appStore.isLoading && !singlePostScreenVars.isError && singlePostScreenVars.singlePost != null
                          ? AnimatedScrollView(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    cachedImage(
                                      singlePostScreenVars.singlePost!.userImage.validate(),
                                      height: 40,
                                      width: 40,
                                      fit: BoxFit.cover,
                                    ).cornerRadiusWithClipRRect(100),
                                    12.width,
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              singlePostScreenVars.singlePost!.userName.validate(),
                                              style: boldTextStyle(),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ).flexible(),
                                            if (singlePostScreenVars.singlePost!.isUserVerified == 1)
                                              Image.asset(ic_tick_filled, width: 18, height: 18, color: blueTickColor).paddingSymmetric(horizontal: 4),
                                          ],
                                        ),
                                       // Text("@${singlePostScreenVars.singlePost!.userName.validate()}", style: secondaryTextStyle()),
                                      ],
                                    ).expand(),
                                    Text(convertToAgo(singlePostScreenVars.singlePost!.dateRecorded.validate()), style: secondaryTextStyle()),
                                  ],
                                ).paddingSymmetric(horizontal: 16).onTap(() {
                                  MemberProfileScreen(memberId: singlePostScreenVars.singlePost!.userId.validate()).launch(context);
                                }, splashColor: Colors.transparent, highlightColor: Colors.transparent),
                                20.height,
                                Divider(height: 0),
                                8.height,
                                PostContentComponent(
                                  blogId: singlePostScreenVars.singlePost!.blogId,
                                  postType: singlePostScreenVars.singlePost!.type,
                                  hasMentions: singlePostScreenVars.singlePost!.hasMentions == 1,
                                  postContent: singlePostScreenVars.singlePost!.content,
                                  contentObject: singlePostScreenVars.singlePost!.contentObject,
                                ).paddingSymmetric(horizontal: 8),
                                PostMediaComponent(
                                  mediaTitle: singlePostScreenVars.singlePost!.userName.validate(),
                                  mediaType: singlePostScreenVars.singlePost!.mediaType,
                                  mediaList: singlePostScreenVars.singlePost!.medias,
                                  isFromPostDetail: true,
                                ).paddingSymmetric(horizontal: 8),
                                if (singlePostScreenVars.singlePost!.childPost != null) PostComponent(post: singlePostScreenVars.singlePost!.childPost!, childPost: true),
                                Observer(
                                  builder: (context) {
                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        if (appStore.isReactionEnable)
                                          if (appStore.reactions.validate().isNotEmpty)
                                            ReactionButton(
                                              isComments: false,
                                              isReacted: singlePostScreenVars.isReacted,
                                              currentUserReaction: singlePostScreenVars.singlePost!.curUserReaction,
                                              onReacted: (id) {
                                                singlePostScreenVars.isReacted = true;
                                                postReaction(addReaction: true, reactionID: id);
                                              },
                                              onReactionRemoved: () {
                                                singlePostScreenVars.isReacted = false;
                                                postReaction(addReaction: false);
                                              },
                                            ).paddingSymmetric(horizontal: 8)
                                          else
                                            Offstage()
                                        else
                                          LikeButtonWidget(
                                            key: ValueKey(singlePostScreenVars.isLike),
                                            onPostLike: () {
                                              postLike();
                                            },
                                            isPostLiked: singlePostScreenVars.isLike,
                                          ).paddingOnly(right: 6, bottom: 8, top: 8),
                                        TextButton(
                                          onPressed: () {
                                            FocusScope.of(context).requestFocus(commentFocus);
                                            isReply = true;
                                            setState(() {});
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
                                              Text(language.comment, style: secondaryTextStyle(color: appStore.isDarkMode ? viewLineColor : textPrimaryColor))
                                            ],
                                          ),
                                        ).paddingSymmetric(horizontal: 8),
                                        TextButton(
                                          onPressed: () {
                                            if (!appStore.isLoading) {
                                              String saveUrl = "$DOMAIN_URL/activitys/p/${widget.postId}";
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
                                              Text(language.share, style: secondaryTextStyle(color: appStore.isDarkMode ? viewLineColor : textPrimaryColor))
                                            ],
                                          ).paddingSymmetric(horizontal: 8),
                                        ),
                                      ],
                                    ).paddingOnly(bottom: 12);
                                  },
                                ),
                                12.height,
                                ThreeReactionComponent(
                                  isComments: false,
                                  id: singlePostScreenVars.singlePost!.activityId.validate(),
                                  postReactionCount: singlePostScreenVars.postReactionCount,
                                  postReactionList: singlePostScreenVars.postReactionList,
                                ).paddingSymmetric(horizontal: 16),
                                Observer(builder: (context) {
                                  return Row(
                                    children: [
                                      Stack(
                                        children: singlePostScreenVars.likeList.validate().take(3).map((e) {
                                          return Container(
                                            width: 32,
                                            height: 32,
                                            margin: EdgeInsets.only(left: 18 * singlePostScreenVars.likeList.validate().indexOf(e).toDouble()),
                                            child: cachedImage(
                                              singlePostScreenVars.likeList.validate()[singlePostScreenVars.likeList.validate().indexOf(e)].userAvatar.validate(),
                                              fit: BoxFit.cover,
                                            ).cornerRadiusWithClipRRect(100),
                                          );
                                        }).toList(),
                                      ),
                                      Observer(builder: (context) {
                                        return RichText(
                                          text: TextSpan(
                                            text: language.likedBy,
                                            style: secondaryTextStyle(size: 12, fontFamily: fontFamily),
                                            children: <TextSpan>[
                                              TextSpan(text: ' ${singlePostScreenVars.likeList.first.userName.validate()}', style: boldTextStyle(size: 12, fontFamily: fontFamily)),
                                              if (singlePostScreenVars.likeList.length > 1) TextSpan(text: ' And ', style: secondaryTextStyle(size: 12, fontFamily: fontFamily)),
                                              if (singlePostScreenVars.likeList.length > 1)
                                                TextSpan(text: '${singlePostScreenVars.likeCount - 1} others', style: boldTextStyle(size: 12, fontFamily: fontFamily)),
                                            ],
                                          ),
                                        ).paddingAll(8).onTap(
                                          () {
                                            PostLikesScreen(postId: singlePostScreenVars.singlePost!.activityId.validate()).launch(context);
                                          },
                                          splashColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                        );
                                      })
                                    ],
                                  ).paddingSymmetric(horizontal: 16).visible(singlePostScreenVars.likeList.isNotEmpty);
                                }),
                                8.height,
                                if (singlePostScreenVars.commentList.length > 0)
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      children: [
                                        Text(
                                          singlePostScreenVars.singlePost!.commentCount.validate() > 0 ? '${language.viewAll} ${language.comments}' : language.comments.capitalizeFirstLetter(),
                                          style: secondaryTextStyle(),
                                        ).paddingSymmetric(horizontal: 16).onTap(() {
                                          CommentScreen(postId: widget.postId).launch(context).then((value) {
                                            if (value ?? false) {
                                              singlePostScreenVars.isChange = true;
                                              postDetail();
                                            }
                                          });
                                        }),
                                        Icon(
                                          !singlePostScreenVars.isChange ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down_sharp,
                                          color: textSecondaryColor,
                                        ).onTap(() {
                                          singlePostScreenVars.isChange = !singlePostScreenVars.isChange;
                                          getComment();
                                        })
                                      ],
                                    ),
                                  ),
                                Observer(builder: (context) {
                                  return AnimatedListView(
                                    shrinkWrap: true,
                                    slideConfiguration: SlideConfiguration(
                                      delay: 80.milliseconds,
                                      verticalOffset: 300,
                                    ),
                                    physics: NeverScrollableScrollPhysics(),
                                    padding: EdgeInsets.fromLTRB(16, 16, 16, 76),
                                    itemCount: singlePostScreenVars.commentList.length,
                                    itemBuilder: (context, index) {
                                      CommentModel comment = singlePostScreenVars.commentList[index];
                                      return Column(
                                        children: [
                                          CommentComponent(
                                            onReply: () {
                                              FocusScope.of(context).requestFocus(commentFocus);
                                              singlePostScreenVars.commentParentId = comment.id.validate().toInt();
                                              isReply = true;
                                              setState(() {});
                                            },
                                            onEdit: () {
                                              getComment();
                                            },
                                            onDelete: () {
                                              showConfirmDialogCustom(
                                                context,
                                                dialogType: DialogType.DELETE,
                                                onAccept: (c) {
                                                  deleteComment(comment.id.validate().toInt());
                                                },
                                              );
                                            },
                                            isParent: true,
                                            comment: singlePostScreenVars.commentList.validate()[index],
                                            postId: widget.postId,
                                          ),
                                          if (comment.children.validate().isNotEmpty)
                                            ListView.builder(
                                              itemBuilder: (context, i) {
                                                CommentModel childComment = comment.children.validate()[i];
                                                return CommentComponent(
                                                  callback: () {
                                                    getComment();
                                                  },
                                                  isParent: false,
                                                  comment: childComment,
                                                  postId: widget.postId,
                                                  activityId: childComment.itemId.validate().toInt(),
                                                  parentId: childComment.secondaryItemId.validate().toInt(),
                                                  onDelete: () {
                                                    showConfirmDialogCustom(
                                                      context,
                                                      dialogType: DialogType.DELETE,
                                                      onAccept: (c) {
                                                        deleteComment(childComment.id.toInt());
                                                      },
                                                    );
                                                  },
                                                  onReply: () async {
                                                    FocusScope.of(context).requestFocus(commentFocus);
                                                    singlePostScreenVars.commentParentId = comment.id.validate().toInt();
                                                  },
                                                  onEdit: () {
                                                    // Inline editing is now handled within CommentComponent
                                                  },
                                                ).paddingOnly(bottom: 20);
                                              },
                                              itemCount: comment.children.validate().length,
                                              physics: NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              padding: EdgeInsets.only(left: 30),
                                              reverse: true,
                                            ),
                                        ],
                                      );
                                    },
                                  ).visible(singlePostScreenVars.commentList.isNotEmpty && singlePostScreenVars.isChange);
                                }),
                              ],
                            )
                          : Offstage();
                    })
                  ],
                ),
                Observer(builder: (context) {
                  return NoDataWidget(
                    imageWidget: NoDataLottieWidget(),
                    title: singlePostScreenVars.isError ? language.somethingWentWrong : language.noDataFound,
                    onRetry: () {
                      postDetail();
                    },
                    retryText: '   ${language.clickToRefresh}   ',
                  ).center().visible(singlePostScreenVars.isError);
                }),
                Observer(
                  builder: (_) {
                    if (appStore.isLoading) {
                      return LoadingWidget().center();
                    } else {
                      return Offstage();
                    }
                  },
                ),
                Observer(builder: (_) {
                  return Positioned(
                    bottom: context.navigationBarHeight,
                    child: Container(
                      width: context.width(),
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      color: context.scaffoldBackgroundColor,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              cachedImage(userStore.loginAvatarUrl, height: 36, width: 36, fit: BoxFit.cover).cornerRadiusWithClipRRect(100),
                              10.width,
                              AppTextField(
                                focus: commentFocus,
                                controller: commentController,
                                textFieldType: TextFieldType.MULTILINE,
                                textCapitalization: TextCapitalization.sentences,
                                keyboardType: TextInputType.multiline,
                                minLines: 1,
                                decoration: InputDecoration(
                                  hintText: language.writeAComment,
                                  hintStyle: secondaryTextStyle(size: 16),
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                ),
                                onChanged: (value) {
                                  if (value.length > 0) {
                                    isTyping = true;
                                  } else {
                                    isTyping = false;
                                  }
                                },
                                onTap: () {
                                  /// Clear recently posted comment id
                                  singlePostScreenVars.commentParentId = -1;
                                },
                              ).expand(),
                              if (appStore.showGif)
                                IconButton(
                                  onPressed: () {
                                    selectGif(context: context).then((value) {
                                      if (value != null) {
                                        singlePostScreenVars.commentGif = value;
                                        log('Gif Url: ${singlePostScreenVars.commentGif!.images!.original!.url.validate()}');
                                      }
                                    });
                                  },
                                  icon: cachedImage(ic_gif, color: appStore.isDarkMode ? bodyDark : bodyWhite, width: 30, height: 24, fit: BoxFit.contain),
                                ),
                              InkWell(
                                onTap: () {
                                  if (commentController.text.isNotEmpty || singlePostScreenVars.commentGif != null) {
                                    hideKeyboard(context);
                                    String content = commentController.text.trim().replaceAll("\n", "</br>").replaceAll(' ', '&nbsp;');
                                    commentController.clear();
                                    postComment(content, parentId: singlePostScreenVars.commentParentId == -1 ? null : singlePostScreenVars.commentParentId);
                                    singlePostScreenVars.isChange = true;
                                  } else {
                                    toast(language.writeComment);
                                  }
                                },
                                child: Icon(
                                  Icons.send,
                                  color: isTyping ? context.primaryColor : (appStore.isDarkMode ? bodyDark : bodyWhite),
                                  size: 24,
                                ).paddingAll(8),
                              ),
                            ],
                          ),
                          Observer(builder: (context) {
                            return singlePostScreenVars.commentGif != null
                                ? Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      LoadingWidget(isBlurBackground: false).paddingSymmetric(vertical: 16),
                                      cachedImage(singlePostScreenVars.commentGif!.images!.original!.url.validate(), height: 200)
                                          .cornerRadiusWithClipRRect(defaultAppButtonRadius)
                                          .paddingSymmetric(vertical: 8),
                                    ],
                                  )
                                : Offstage();
                          })
                        ],
                      ),
                    ),
                  ).visible(isReply);
                })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
