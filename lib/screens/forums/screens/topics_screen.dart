import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/forums/topic_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/screens/forums/components/topic_card_component.dart';
import 'package:socialv/screens/forums/screens/topic_detail_screen.dart';
import 'package:socialv/store/profile_menu_store.dart';

import '../../../utils/app_constants.dart';

class TopicsScreen extends StatefulWidget {
  const TopicsScreen({Key? key}) : super(key: key);

  @override
  State<TopicsScreen> createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen> {
  ProfileMenuStore topicsScreenVars = ProfileMenuStore();
  int mPage = 1;
  bool mIsLastPage = false;
  bool isUpdate = false;

  @override
  void initState() {
    getTopics();
    super.initState();
  }

  Future<void> getTopics() async {
    topicsScreenVars.isError = false;
    appStore.setLoading(true);

    await subscribedList(page: mPage).then((value) {
      if (mPage == 1) topicsScreenVars.topicsViewList.clear();
      mIsLastPage = value.topics.validate().length != PER_PAGE;
      topicsScreenVars.topicsViewList.addAll(value.topics.validate());
      topicsScreenVars.isError = false;
      appStore.setLoading(false);
    }).catchError((e) {
      topicsScreenVars.isError = true;
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
          finish(context, isUpdate);
          appStore.setLoading(false);
        }
      },
      child: RefreshIndicator(
        onRefresh: () async {
          mPage = 1;
          getTopics();
        },
        color: context.primaryColor,
        child: Scaffold(
          appBar: AppBar(
            title: Text(language.topics, style: boldTextStyle(size: 20)),
            centerTitle: true,
          ),
          body: Stack(
            alignment: Alignment.topCenter,
            children: [
              AnimatedScrollView(children: [
                /// error widget
                Observer(builder: (context) {
                  return topicsScreenVars.isError && !appStore.isLoading
                      ? SizedBox(
                          height: context.height() * 0.88,
                          child: NoDataWidget(
                            imageWidget: NoDataLottieWidget(),
                            title: topicsScreenVars.isError ? language.somethingWentWrong : language.noDataFound,
                            onRetry: () {
                              mPage = 1;
                              getTopics();
                            },
                            retryText: '   ${language.clickToRefresh}   ',
                          ).center(),
                        )
                      : Offstage();
                }),

                /// empty widget
                Observer(builder: (context) {
                  return topicsScreenVars.topicsViewList.isEmpty && !topicsScreenVars.isError && !appStore.isLoading
                      ? SizedBox(
                          height: context.height() * 0.88,
                          child: NoDataWidget(
                            imageWidget: NoDataLottieWidget(),
                            title: topicsScreenVars.isError ? language.somethingWentWrong : language.noDataFound,
                            onRetry: () {
                              mPage = 1;
                              getTopics();
                            },
                            retryText: '   ${language.clickToRefresh}   ',
                          ).center(),
                        )
                      : Offstage();
                }),

                /// list widget

                Observer(builder: (context) {
                  return topicsScreenVars.topicsViewList.isNotEmpty /*&& !topicsScreenVars.isError*/
                      ? AnimatedListView(
                          slideConfiguration: SlideConfiguration(delay: 80.milliseconds, verticalOffset: 300),
                          padding: EdgeInsets.only(left: 16, right: 16, bottom: 50),
                          itemCount: topicsScreenVars.topicsViewList.length,
                          itemBuilder: (context, index) {
                            TopicModel data = topicsScreenVars.topicsViewList[index];

                            return InkWell(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () {
                                TopicDetailScreen(topicId: data.id.validate()).launch(context).then((value) {
                                  if (value ?? false) {
                                    isUpdate = true;
                                    getTopics();
                                  }
                                });
                              },
                              child: TopicCardComponent(topic: data, isFavTab: false),
                            );
                          },
                          onNextPage: () {
                            if (!mIsLastPage) {
                              mPage++;
                              getTopics();
                            }
                          },
                        )
                      : Offstage();
                }),
              ]),
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
