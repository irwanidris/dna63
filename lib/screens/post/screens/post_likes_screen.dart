import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/posts/get_post_likes_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/profile/screens/member_profile_screen.dart';
import 'package:socialv/store/fragment_store/home_fragment_store.dart';
import 'package:socialv/utils/cached_network_image.dart';

import '../../../utils/app_constants.dart';

class PostLikesScreen extends StatefulWidget {
  final int postId;

  const PostLikesScreen({required this.postId});

  @override
  State<PostLikesScreen> createState() => _PostLikesScreenState();
}

class _PostLikesScreenState extends State<PostLikesScreen> {
  HomeFragStore postLikesScreenVars = HomeFragStore();
  int mPage = 1;
  bool mIsLastPage = false;

  @override
  void initState() {
    likesList();
    super.initState();
  }

  Future<List<GetPostLikesModel>> likesList() async {
    appStore.setLoading(true);
    await getPostLikes(id: widget.postId, page: mPage).then((value) {
      if (mPage == 1) postLikesScreenVars.likePostList.clear();

      mIsLastPage = value.length != PER_PAGE;
      postLikesScreenVars.likePostList.addAll(value);
      postLikesScreenVars.isError = false;
      appStore.setLoading(false);
    }).catchError((e) {
      postLikesScreenVars.isError = true;
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });

    return postLikesScreenVars.likePostList;
  }

  Future<void> onRefresh() async {
    postLikesScreenVars.isError = false;
    mPage = 1;
    likesList();
  }

  @override
  void dispose() {
    appStore.setLoading(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        onRefresh();
      },
      color: context.primaryColor,
      child: Scaffold(
        appBar: AppBar(
          title: Text(language.likes, style: boldTextStyle(size: 20)),
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: context.iconColor),
            onPressed: () {
              finish(context);
            },
          ),
        ),
        body: Stack(
          alignment: Alignment.topCenter,
          children: [
            AnimatedScrollView(
              children: [
                /// error widget
                Observer(builder: (context) {
                  return postLikesScreenVars.isError && !appStore.isLoading
                      ? SizedBox(
                          height: context.height() * 0.88,
                          child: NoDataWidget(
                            imageWidget: NoDataLottieWidget(),
                            title: postLikesScreenVars.isError ? language.somethingWentWrong : language.noDataFound,
                            onRetry: () {
                              onRefresh();
                            },
                            retryText: '   ${language.clickToRefresh}   ',
                          ).center(),
                        )
                      : Offstage();
                }),

                /// empty list widget
                Observer(builder: (context) {
                  return postLikesScreenVars.likePostList.isEmpty && !postLikesScreenVars.isError && !appStore.isLoading
                      ? SizedBox(
                          height: context.height() * 0.88,
                          child: NoDataWidget(
                            imageWidget: NoDataLottieWidget(),
                            title: postLikesScreenVars.isError ? language.somethingWentWrong : language.noDataFound,
                            onRetry: () {
                              onRefresh();
                            },
                            retryText: '   ${language.clickToRefresh}   ',
                          ).center(),
                        )
                      : Offstage();
                }),

                Observer(builder: (context) {
                  return postLikesScreenVars.likePostList.isNotEmpty && !postLikesScreenVars.isError && !appStore.isLoading
                      ? AnimatedListView(
                          shrinkWrap: true,
                          slideConfiguration: SlideConfiguration(
                            delay: 80.milliseconds,
                            verticalOffset: 300,
                          ),
                          physics: AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.only(left: 16, right: 16, bottom: 50),
                          itemCount: postLikesScreenVars.likePostList.length,
                          itemBuilder: (context, index) {
                            GetPostLikesModel user = postLikesScreenVars.likePostList[index];

                            return Row(
                              children: [
                                cachedImage(
                                  user.userAvatar.validate(),
                                  height: 40,
                                  width: 40,
                                  fit: BoxFit.cover,
                                ).cornerRadiusWithClipRRect(100),
                                20.width,
                                Column(
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(text: user.userName.validate(), style: boldTextStyle(size: 14, fontFamily: fontFamily)),
                                          if (user.isUserVerified.validate()) WidgetSpan(child: Image.asset(ic_tick_filled, height: 18, width: 18, color: blueTickColor, fit: BoxFit.cover)),
                                        ],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.start,
                                    ),
                                    if (user.userMentionName.validate().isNotEmpty) Text(user.userMentionName.validate(), style: secondaryTextStyle()),
                                  ],
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                ).expand(),
                              ],
                            ).onTap(() async {
                              MemberProfileScreen(memberId: postLikesScreenVars.likePostList[index].userId.validate().toInt()).launch(context);
                            }, splashColor: Colors.transparent, highlightColor: Colors.transparent).paddingSymmetric(vertical: 8);
                          },
                          onNextPage: () {
                            if (!mIsLastPage) {
                              mPage++;
                              likesList();
                            }
                          },
                        )
                      : Offstage();
                }),
              ],
            ),
            Observer(
              builder: (_) {
                return Positioned(
                  bottom: mPage != 1 ? 10 : null,
                  child: LoadingWidget(isBlurBackground: mPage == 1 ? true : false),
                ).visible(appStore.isLoading);
              },
            ),
          ],
        ),
      ),
    );
  }
}
