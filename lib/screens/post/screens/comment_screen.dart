import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:mobx/mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/common_models/post_mdeia_model.dart';
import 'package:socialv/models/posts/comment_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/post/components/comment_component.dart';
import 'package:socialv/screens/post/components/update_comment_component.dart';
import 'package:socialv/store/fragment_store/home_fragment_store.dart';
import 'package:socialv/utils/app_constants.dart';
import 'package:socialv/utils/cached_network_image.dart';

class CommentScreen extends StatefulWidget {
  final int postId;
  final VoidCallback? callback;

  const CommentScreen({required this.postId, this.callback});

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  HomeFragStore commentScreenVars = HomeFragStore();
  TextEditingController commentController = TextEditingController();
  ScrollController _scrollController = ScrollController();

  FocusNode commentFocus = FocusNode();
  int mPage = 1;
  bool mIsLastPage = false;
  bool isTyping = false;
  TextEditingController commentReply = TextEditingController();

  @override
  void initState() {
    super.initState();
    init();
    _scrollController = ScrollController();

    commentController.addListener(() {
    setState(() {
        isTyping = commentController.text.trim().isNotEmpty || commentScreenVars.commentGif != null;
      });
    });

    afterBuildCreated(() {
      setStatusBarColor(context.cardColor);
    });
  }

  Future<void> init({bool showLoader = true, int page = 1}) async {
    appStore.setLoading(showLoader);
    getComments(
      id: widget.postId,
      page: page,
      commentList: commentScreenVars.commentList,
      lastPageCallback: (p0) {
        mIsLastPage = p0;
      },
    ).then((value) {
      appStore.setLoading(false);
      commentScreenVars.isError = false;
      return value;
    }).catchError((e) {
      commentScreenVars.isError = true;
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  void deleteComment(int commentId) async {
    ifNotTester(() async {
      appStore.setLoading(true);
      await deletePostComment(postId: widget.postId, commentId: commentId)
          .then((value) {
        init();
        toast("Comment successfully deleted");
        widget.callback?.call();
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
        medias: commentScreenVars.commentGif != null
            ? [
                PostMediaModel(
                  url: commentScreenVars.commentGif!.images!.original!.url
                      .validate(),
                )
              ]
            : [],
        children: ObservableList<CommentModel>(),
      );

      int? scrollToIndex;

      runInAction(() {
        if (parentId == null) {
          commentScreenVars.commentList.add(newComment);
          scrollToIndex = commentScreenVars.commentList.length - 1;
        } else {
          var parentIndex =
              commentScreenVars.commentList.indexWhere((e) => e.id == parentId);
          if (parentIndex != -1) {
            commentScreenVars.commentList[parentIndex].children
                ?.add(newComment);
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
      commentScreenVars.commentGif = null;

      Map<String, dynamic> request = {
        "content": commentContent,
        "media_type":
            commentScreenVars.commentGif != null ? MediaTypes.gif : "",
        "media_id": commentScreenVars.commentGif?.id ?? "",
        "media": commentScreenVars.commentGif?.images?.original?.url ?? "",
      };

      if (parentId != null) {
        request["parent_comment_id"] = parentId;
      }

      await savePostComment(postId: widget.postId, request: request)
          .then((value) {
        init();
        widget.callback?.call();
      }).catchError((e) {
        appStore.setLoading(false);
        toast(e.toString());
      });
    });
  }

  Future<void> onRefresh() async {
    init();
  }

  @override
  void dispose() {
    setStatusBarColorBasedOnTheme();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          appStore.setLoading(false);
          finish(context, true);
        }
      },
      child: RefreshIndicator(
        onRefresh: () async {
          onRefresh();
        },
        color: context.primaryColor,
        child: Scaffold(
          backgroundColor: context.cardColor,
          appBar: AppBar(
            backgroundColor: context.cardColor,
            title: Text(language.comments, style: boldTextStyle(size: 20)),
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: context.iconColor),
              onPressed: () {
                finish(context);
              },
            ),
          ),
          body: SizedBox(
            height: context.height(),
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                AnimatedScrollView(
                  children: [
                    ///Loading Widget
                    Observer(builder: (_) {
                      return LoadingWidget()
                          .visible(appStore.isLoading &&
                              commentScreenVars.commentList.isEmpty)
                          .center();
                    }),

                    /// error widget
                    Observer(builder: (context) {
                      return commentScreenVars.isError && !appStore.isLoading
                          ? SizedBox(
                              height: context.height() * 0.88,
                              child: NoDataWidget(
                                imageWidget: NoDataLottieWidget(),
                                title: language.somethingWentWrong,
                                onRetry: () {
                                  onRefresh();
                                },
                                retryText: '   ${language.clickToRefresh}   ',
                              ).center(),
                            )
                          : Offstage();
                    }),

                    /// empty widget
                    Observer(builder: (context) {
                      return commentScreenVars.commentList.isEmpty &&
                              !commentScreenVars.isError &&
                              !appStore.isLoading
                          ? SizedBox(
                              height: context.height() * 0.88,
                              child: NoDataWidget(
                                imageWidget: NoDataLottieWidget(),
                                title: language.noCommentsYet,
                              ).center(),
                            )
                          : Offstage();
                    }),

                    /// list widget
                    Observer(builder: (context) {
                      return commentScreenVars.commentList.isNotEmpty &&
                              !commentScreenVars.isError
                          ? AnimatedListView(
                              shrinkWrap: true,
                              slideConfiguration: SlideConfiguration(
                                delay: 80.milliseconds,
                                verticalOffset: 300,
                              ),
                              physics: NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              itemCount: commentScreenVars.commentList.length,
                              itemBuilder: (context, index) {
                                CommentModel _comment =
                                    commentScreenVars.commentList[index];

                                return Column(
                                  children: [
                                    CommentComponent(
                                      isParent: true,
                                      comment: _comment,
                                      postId: widget.postId,
                                      onDelete: () {
                                        showConfirmDialogCustom(
                                          context,
                                          dialogType: DialogType.DELETE,
                                          onAccept: (c) {
                                            deleteComment(
                                                _comment.id.validate().toInt());
                                          },
                                        );
                                /*        showConfirmDialogCustom(
                                          context,
                                          dialogType: DialogType.DELETE,
                                          title: "",
                                          onAccept: (c) {
                                            deleteComment(
                                                _comment.id.validate().toInt());
                                          },
                                        );*/
                                      },
                                      onReply: () async {
                                        FocusScope.of(context)
                                            .requestFocus(commentFocus);
                                        commentScreenVars.commentParentId =
                                            _comment.id.validate().toInt();
                                        // commentController.text="@"+_comment.userName.toString()+"  ";
                                      },
                                      onEdit: () {
                                    /*    showInDialog(
                                          context,
                                          contentPadding: EdgeInsets.zero,
                                          backgroundColor: context.scaffoldBackgroundColor,
                                          builder: (p0) {
                                            return UpdateCommentComponent(
                                              id: _comment.id
                                                  .validate()
                                                  .toInt(),
                                              activityId: _comment.itemId
                                                  .validate()
                                                  .toInt(),
                                              comment: _comment.content,
                                              medias:
                                                  _comment.medias.validate(),
                                              callback: (x) {
                                                init();
                                              },
                                            );
                                          },
                                        );*/
                                        init();
                                      },
                                    ),
                                    if (_comment.children.validate().isNotEmpty)
                                      ListView.builder(
                                        itemBuilder: (context, i) {
                                          CommentModel childComment =
                                              _comment.children.validate()[i];
                                          return CommentComponent(
                                            callback: () {
                                              init();
                                            },
                                            isParent: false,
                                            comment: childComment,
                                            postId: widget.postId,
                                            onDelete: () {
                                              showConfirmDialogCustom(
                                                context,
                                                dialogType: DialogType.DELETE,
                                                onAccept: (c) {
                                                  deleteComment(
                                                      childComment.id.toInt());
                                                },
                                              );
                                            },
                                            onReply: () async {
                                              FocusScope.of(context)
                                                  .requestFocus(commentFocus);
                                              commentScreenVars
                                                      .commentParentId =
                                                  _comment.id
                                                      .validate()
                                                      .toInt();
                                            },
                                            onEdit: () {
                                              showInDialog(
                                                context,
                                                contentPadding: EdgeInsets.zero,
                                                backgroundColor: context.scaffoldBackgroundColor,
                                                builder: (p0) {
                                                  return UpdateCommentComponent(
                                                    id: childComment.id
                                                        .validate()
                                                        .toInt(),
                                                    activityId: childComment
                                                        .itemId
                                                        .validate()
                                                        .toInt(),
                                                    comment:
                                                        childComment.content,
                                                    parentId: childComment
                                                        .secondaryItemId
                                                        .validate()
                                                        .toInt(),
                                                    medias: childComment.medias
                                                        .validate(),
                                                    callback: (x) {
                                                      init();
                                                    },
                                                  );
                                                },
                                              );
                                            },
                                          );
                                        },
                                        itemCount:
                                            _comment.children.validate().length,
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        padding: EdgeInsets.only(left: 30),
                                        reverse: true,
                                      ),
                                  ],
                                );
                              },
                              onNextPage: () {
                                if (!mIsLastPage) {
                                  mPage++;
                                  init(page: mPage);
                                }
                              },
                            ).paddingBottom(66)
                          : Offstage();
                    }),
                  ],
                ),
                Positioned(
                  bottom: context.navigationBarHeight,
                  child: Container(
                    width: context.width(),
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    color: context.scaffoldBackgroundColor,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            cachedImage(userStore.loginAvatarUrl,
                                    height: 36, width: 36, fit: BoxFit.cover)
                                .cornerRadiusWithClipRRect(100),
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
                              onTap: () {
                                /// Clear recently posted comment id
                                commentScreenVars.commentParentId = -1;
                              },
                            ).expand(),
                            if (appStore.showGif)
                              IconButton(
                                onPressed: () {
                                  selectGif(context: context).then((value) {
                                    if (value != null) {
                                      commentScreenVars.commentGif = value;
                                      log('Gif Url: ${commentScreenVars.commentGif!.images!.original!.url.validate()}');
                                    }
                                  });
                                },
                                icon: cachedImage(ic_gif,
                                    color: appStore.isDarkMode
                                        ? bodyDark
                                        : bodyWhite,
                                    width: 30,
                                    height: 24,
                                    fit: BoxFit.contain),
                              ),
                            InkWell(
                              onTap: () {
                                if (commentController.text.isNotEmpty ||
                                    commentScreenVars.commentGif != null) {
                                  hideKeyboard(context);
                                  String content = commentController.text
                                      .trim()
                                      .replaceAll("\n", "</br>")
                                      .replaceAll(' ', '&nbsp;');
                                  commentController.clear();
                                  postComment(content,
                                      parentId: commentScreenVars
                                                  .commentParentId ==
                                              -1
                                          ? null
                                          : commentScreenVars.commentParentId);
                                } else {
                                  toast(language.writeComment);
                                }
                              },
                              child: cachedImage(ic_send,
                                  color: isTyping ? context.primaryColor : (appStore.isDarkMode ? bodyDark : bodyWhite),
                                  width: 24,
                                  height: 24,
                                  fit: BoxFit.cover),
                            ),
                          ],
                        ),
                        Observer(builder: (context) {
                          return commentScreenVars.commentGif != null
                              ? Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    LoadingWidget(isBlurBackground: false)
                                        .paddingSymmetric(vertical: 16),
                                    cachedImage(
                                            commentScreenVars.commentGif!
                                                .images!.original!.url
                                                .validate(),
                                            height: 200)
                                        .cornerRadiusWithClipRRect(
                                            defaultAppButtonRadius)
                                        .paddingSymmetric(vertical: 8),
                                  ],
                                )
                              : Offstage();
                        })
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
