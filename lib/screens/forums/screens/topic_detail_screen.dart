import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/forums/common_models.dart';
import 'package:socialv/models/forums/topic_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/forums/components/topic_reply_component.dart';
import 'package:socialv/screens/forums/components/write_topic_reply_component.dart';
import 'package:socialv/screens/shop/components/cached_image_widget.dart';
import 'package:socialv/store/fragment_store/forums_fragment_store.dart';
import 'package:socialv/store/profile_menu_store.dart';
import 'package:socialv/utils/app_constants.dart';
import 'package:socialv/utils/extentions/str_extentions.dart';

class TopicDetailScreen extends StatefulWidget {
  final int topicId;
  final bool isFromFav;

  const TopicDetailScreen({required this.topicId, this.isFromFav = false});

  @override
  State<TopicDetailScreen> createState() => _TopicDetailScreenState();
}

class _TopicDetailScreenState extends State<TopicDetailScreen> {
  ScrollController _scrollController = ScrollController();
  ProfileMenuStore topicDetailScreenVars = ProfileMenuStore();
  ForumsFragStore forumStoreVars = ForumsFragStore();

  int mPage = 1;
  bool mIsLastPage = false;

  bool isUpdate = false;

  @override
  void initState() {
    super.initState();
    getDetails();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        if (!mIsLastPage) {
          mPage++;
          topicDetailScreenVars.setLoading(true);
          getDetails();
        }
      }
    });

    LiveStream().on(GetTopicDetail, (p0) {
      getDetails();
    });
  }

  Future<TopicModel> getDetails() async {
    topicDetailScreenVars.isError = false;
    topicDetailScreenVars.setLoading(true);

    if (mPage == 1) {
      forumStoreVars.postList.clear();
    }

    await getTopicDetail(topicId: widget.topicId, page: mPage).then((value) async {
      forumStoreVars.topic = value;

      mIsLastPage = value.postList.validate().length != PER_PAGE;
      forumStoreVars.postList.addAll(value.postList.validate());

      topicDetailScreenVars.isSubscribed = value.isSubscribed.validate();
      topicDetailScreenVars.isFavourite = value.isFavorites.validate();

      topicDetailScreenVars.setLoading(false);
    }).catchError((e) {
      topicDetailScreenVars.isError = true;

      topicDetailScreenVars.setLoading(false);

      toast(e.toString(), print: true);
    });

    return forumStoreVars.topic;
  }

  @override
  void dispose() {
    LiveStream().dispose(GetTopicDetail);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          topicDetailScreenVars.setLoading(false);
          finish(context, isUpdate);
        }
      },
      child: RefreshIndicator(
        onRefresh: () async {
          getDetails();
        },
        color: context.primaryColor,
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            centerTitle: true,
            title: Observer(builder: (context) {
              return Text(forumStoreVars.topic.title.validate().validateAndFilter(), style: boldTextStyle(size: 24));
            }),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: context.iconColor),
              onPressed: () {
                finish(context, isUpdate);
              },
            ),
          ),
          body: Stack(
            alignment: Alignment.topCenter,
            children: [
              ///Fetch details
              Observer(builder: (context) {
                return Container(
                  height: context.height(),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CachedImageWidget(
                          url: forumStoreVars.topic.image.toString(),
                          height: 200,
                          width: context.width(),
                          fit: BoxFit.cover,
                        ).visible(!topicDetailScreenVars.isLoading && forumStoreVars.topic.image.toString() != ""),
                        8.height.visible(forumStoreVars.topic.tags.validate().isNotEmpty),
                        Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "${forumStoreVars.topic.tags?.map((tag) => "#${tag.name} ").join(", ") ?? ""}",
                              style: boldTextStyle(color: appColorPrimary, size: 14),
                            )).visible(!topicDetailScreenVars.isLoading),
                        Container(
                          width: context.width(),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              //  color: context.primaryColor.withAlpha(30),
                              ),
                          child: Text(forumStoreVars.topic.description.validate(), style: secondaryTextStyle()),
                        ).visible(!topicDetailScreenVars.isLoading),
                        16.height.visible(forumStoreVars.topic.image.validate().isNotEmpty),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            AppButton(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              elevation: 0,
                              color: topicDetailScreenVars.isSubscribed ? appOrangeColor : appGreenColor,
                              child: Text(topicDetailScreenVars.isSubscribed ? language.unsubscribe : language.subscribe, style: boldTextStyle(color: Colors.white)),
                              onTap: () {
                                ifNotTester(() {
                                  topicDetailScreenVars.isSubscribed = !topicDetailScreenVars.isSubscribed;

                                  if (topicDetailScreenVars.isSubscribed) {
                                    toast(language.subscribedSuccessfully);
                                  } else {
                                    toast(language.unsubscribedSuccessfully);
                                  }

                                  subscribeForum(forumId: widget.topicId).then((value) {
                                    isUpdate = true;
                                  }).catchError((e) {
                                    log(e.toString());
                                  });
                                });
                              },
                            ),
                            20.width,
                            InkWell(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () {
                                ifNotTester(() {
                                  topicDetailScreenVars.isFavourite = !topicDetailScreenVars.isFavourite;

                                  if (topicDetailScreenVars.isFavourite) {
                                    toast(language.addedToFavourites);
                                    if (widget.isFromFav) isUpdate = false;
                                  } else {
                                    toast(language.removedFromFavourites);
                                    isUpdate = true;
                                  }

                                  favoriteTopic(topicId: widget.topicId).then((value) {
                                    log(value.message);
                                  }).catchError((e) {
                                    log(e.toString());
                                  });
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.all(6),
                                decoration: BoxDecoration(color: appOrangeColor, borderRadius: radius(defaultAppButtonRadius)),
                                child: Image.asset(topicDetailScreenVars.isFavourite ? ic_star_filled : ic_star, width: 26, height: 26, color: Colors.white),
                              ),
                            ),
                          ],
                        ).visible(!topicDetailScreenVars.isLoading),
                        16.height,
                        if (!topicDetailScreenVars.isLoading)
                          Observer(builder: (context) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                '${language.viewing} ${forumStoreVars.postList.length} ${language.replies.toLowerCase()}',
                                style: primaryTextStyle(),
                              ).visible(forumStoreVars.topic.postList.validate().isNotEmpty && forumStoreVars.topic.postCount != '1'),
                            );
                          }),
                        Align(
                          alignment: Alignment.topRight,
                          child: AppButton(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            elevation: 0,
                            color: context.scaffoldBackgroundColor,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(
                                  Icons.reply,
                                  color: appColorPrimary,
                                ),
                                12.width,
                                Text(language.reply, style: boldTextStyle(color: appColorPrimary)),
                              ],
                            ),
                            onTap: () {
                              showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return WriteTopicReplyComponent(
                                      topicName: forumStoreVars.topic.title.validate(),
                                      topicId: forumStoreVars.topic.id.validate(),
                                    );
                                  }).then((value) {
                                getDetails();
                              });
                            },
                          ).visible(forumStoreVars.postList.length < 1 && !topicDetailScreenVars.isLoading),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: forumStoreVars.postList.validate().length,
                          itemBuilder: (ctx, index) {
                            TopicReplyModel reply = forumStoreVars.postList[index];

                            return Column(
                              children: [
                                TopicReplyComponent(
                                  topicId: widget.topicId,
                                  reply: reply,
                                  callback: () {
                                    getDetails();
                                  },
                                  isParent: true,
                                ),
                              ],
                            );
                          },
                        ).visible(forumStoreVars.postList.validate().isNotEmpty),
                        70.height,
                      ],
                    ),
                  ),
                ).visible(!topicDetailScreenVars.isError && !topicDetailScreenVars.isLoading);
              }),

              Observer(builder: (context) {
                return LoadingWidget().visible(topicDetailScreenVars.isLoading);
              })
            ],
          ),
        ),
      ),
    );
  }
}
