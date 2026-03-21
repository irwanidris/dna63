import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/forums/topic_model.dart';
import 'package:socialv/screens/forums/components/topic_card_component.dart';
import 'package:socialv/screens/forums/screens/topic_detail_screen.dart';
import 'package:socialv/store/profile_menu_store.dart';
import 'package:socialv/utils/app_constants.dart';

import '../../../network/rest_apis.dart';

class FavouriteTopicComponent extends StatefulWidget {
  @override
  State<FavouriteTopicComponent> createState() => _FavouriteTopicComponentState();
}

class _FavouriteTopicComponentState extends State<FavouriteTopicComponent> {
  int mPage = 1;
  bool mIsLastPage = false;
  ProfileMenuStore favouriteTopicComponentVars = ProfileMenuStore();

  @override
  void initState() {
    super.initState();
    getList();
  }

  Future<void> getList() async {
    favouriteTopicComponentVars.setLoading(true);
    await getTopicList(
      type: TopicType.favorite,
      page: mPage,
      topicList: favouriteTopicComponentVars.topicsFavouriteList,
      lastPageCallback: (p0) {
        mIsLastPage = p0;
      },
    ).then((value) {
      favouriteTopicComponentVars.setLoading(false);
    }).catchError((e) {
      toast(e.toString());
      favouriteTopicComponentVars.setLoading(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.height() * 0.8,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Observer(builder: (_) {
            return AnimatedListView(
              padding: EdgeInsets.only(left: 16, right: 16, bottom: 50, top: 16),
              itemBuilder: (context, index) {
                TopicModel topic = favouriteTopicComponentVars.topicsFavouriteList[index];
                return InkWell(
                  onTap: () {
                    TopicDetailScreen(topicId: topic.id.validate()).launch(context).then((value) {
                      if (value ?? false) {
                        favouriteTopicComponentVars.topicsFavouriteList.removeAt(index);
                      }
                    });
                  },
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: TopicCardComponent(
                    topic: topic,
                    isFavTab: true,
                    callback: () {
                      favouriteTopicComponentVars.topicsFavouriteList.removeAt(index);
                    },
                  ),
                );
              },
              itemCount: favouriteTopicComponentVars.topicsFavouriteList.length,
              shrinkWrap: true,
              onNextPage: () {
                if (!mIsLastPage) {
                  mPage++;

                  getList();
                }
              },
            );
          }),
          Observer(builder: (_) {
            return favouriteTopicComponentVars.isLoading
                ? Positioned(
                    bottom: mPage != 1 ? 10 : null,
                    child: LoadingWidget(isBlurBackground: false).center(),
                  )
                : NoDataWidget(
                    imageWidget: NoDataLottieWidget(),
                    title: favouriteTopicComponentVars.isError ? language.somethingWentWrong : language.noDataFound,
                    onRetry: () {
                      mPage = 1;
                      getList();
                    },
                    retryText: '   ${language.clickToRefresh}   ',
                  ).center().visible(favouriteTopicComponentVars.topicsFavouriteList.isEmpty);
          })
        ],
      ),
    );
  }
}
