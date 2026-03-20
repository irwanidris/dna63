import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/forums/forum_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/forums/components/forums_card_component.dart';
import 'package:socialv/screens/forums/screens/forum_detail_screen.dart';
import 'package:socialv/store/profile_menu_store.dart';

import '../../../utils/app_constants.dart';

class ForumsScreen extends StatefulWidget {
  @override
  State<ForumsScreen> createState() => _ForumsScreenState();
}

class _ForumsScreenState extends State<ForumsScreen> {
  ProfileMenuStore forumsScreenVars = ProfileMenuStore();
  late Future<List<ForumModel>> future;

  int mPage = 1;
  bool mIsLastPage = false;
  bool isUpdate = false;

  @override
  void initState() {
    getForums();
    super.initState();
  }

  Future<void> getForums() async {
    appStore.setLoading(true);

    await subscribedList(page: mPage).then((value) {
      if (mPage == 1) forumsScreenVars.forumsList.clear();
      mIsLastPage = value.forums.validate().length != PER_PAGE;
      forumsScreenVars.forumsList.addAll(value.forums.validate());
      forumsScreenVars.isError = false;
      appStore.setLoading(false);
    }).catchError((e) {
      forumsScreenVars.isError = true;
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  @override
  void dispose() {
    if (appStore.isLoading) appStore.setLoading(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          appStore.setLoading(false);
          finish(context, isUpdate);
        }
      },
      child: RefreshIndicator(
        onRefresh: () async {
          mPage = 1;
          getForums();
        },
        color: context.primaryColor,
        child: Scaffold(
          appBar: AppBar(
            title: Text(language.forums, style: boldTextStyle(size: 20)),
            centerTitle: true,
          ),
          body: Stack(
            alignment: Alignment.topCenter,
            children: [
              Observer(builder: (context) {
                if (forumsScreenVars.isError && !appStore.isLoading) {
                  /// Error Widget
                  return SizedBox(
                    height: context.height() * 0.88,
                    child: NoDataWidget(
                      imageWidget: NoDataLottieWidget(),
                      title: forumsScreenVars.isError ? language.somethingWentWrong : language.noDataFound,
                      onRetry: () {
                        mPage = 1;
                        getForums();
                      },
                      retryText: '   ${language.clickToRefresh}   ',
                    ).center(),
                  );
                } else if (forumsScreenVars.forumsList.isEmpty && !forumsScreenVars.isError && !appStore.isLoading) {
                  /// Empty Widget
                  return SizedBox(
                    height: context.height() * 0.88,
                    child: NoDataWidget(
                      imageWidget: NoDataLottieWidget(),
                      title: forumsScreenVars.isError ? language.somethingWentWrong : language.noDataFound,
                      onRetry: () {
                        mPage = 1;
                        getForums();
                      },
                      retryText: '   ${language.clickToRefresh}   ',
                    ).center(),
                  );
                } else if (forumsScreenVars.forumsList.isNotEmpty && !forumsScreenVars.isError && !appStore.isLoading) {
                  /// List Widget
                  return AnimatedListView(
                    slideConfiguration: SlideConfiguration(delay: 80.milliseconds, verticalOffset: 300),
                    padding: EdgeInsets.only(left: 16, right: 16, bottom: 50),
                    itemCount: forumsScreenVars.forumsList.length,
                    itemBuilder: (context, index) {
                      ForumModel data = forumsScreenVars.forumsList[index];
                      return InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () {
                          ForumDetailScreen(
                            forumId: data.id.validate(),
                            type: data.type.validate(),
                            forumTitle: data.title.validate(),
                          ).launch(context).then((value) {
                            if (value ?? false) {
                              mPage = 1;
                              isUpdate = true;
                              getForums();
                            }
                          });
                        },
                        child: ForumsCardComponent(
                          title: data.title,
                          description: data.description,
                          postCount: data.postCount,
                          topicCount: data.topicCount,
                          freshness: data.freshness,
                        ),
                      );
                    },
                    onNextPage: () {
                      if (!mIsLastPage) {
                        mPage++;
                        getForums();
                      }
                    },
                  );
                } else {
                  return Offstage();
                }
              }),
              Observer(
                builder: (_) {
                  if (appStore.isLoading) {
                    return Positioned(
                      bottom: mPage != 1 ? 10 : null,
                      child: LoadingWidget(isBlurBackground: mPage == 1 ? true : false),
                    );
                  } else {
                    return Offstage();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
