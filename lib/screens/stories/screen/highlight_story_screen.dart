import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/main.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/stories/component/highlight_component.dart';
import 'package:socialv/screens/stories/model/highlight_model.dart';
import 'package:socialv/store/profile_menu_store.dart';
import 'package:socialv/utils/app_constants.dart';

import '../component/new_highlight_screen_component.dart';

class HighlightStoryScreen extends StatefulWidget {
  const HighlightStoryScreen({Key? key}) : super(key: key);

  @override
  State<HighlightStoryScreen> createState() => _HighlightStoryScreenState();
}

class _HighlightStoryScreenState extends State<HighlightStoryScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  ProfileMenuStore userStoryScreenVars = ProfileMenuStore();
  List<StoryHighlight> highlightList = [];

  @override
  void initState() {
    _animationController = BottomSheet.createAnimationController(this);
    _animationController.duration = const Duration(milliseconds: 300);
    _animationController.drive(CurveTween(curve: Curves.easeOutQuad));
    super.initState();
    userStoryScreenVars.title = language.highlightStories;
    userStoryScreenVars.status = StoryHighlightOptions.publish;
    userStoryScreenVars.showHighlightStory = true;
    getStories();
    fetchHighlightStory();
  }

  void fetchHighlightStory() async {
    highlightList = await getHighlightStoryList().then((value) {
      return value;
    });
  }

  Future<void> getStories() async {
    appStore.setLoading(true);
    userStoryScreenVars.highlightList.clear();
    await getHighlightStories(status: userStoryScreenVars.status).then((value) {
      userStoryScreenVars.highlightList.addAll(value);
      appStore.setLoading(false);
    }).catchError((e) {
      log('error : ${e.toString()}');
      appStore.setLoading(false);
    });
  }

  @override
  void dispose() {
    if (appStore.isLoading) appStore.setLoading(false);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.iconColor),
          onPressed: () {
            Navigator.of(context).pop();
            finish(context);
          },
        ),
        actions: [
          Observer(builder: (context) {
            return PopupMenuButton(
              enabled: !appStore.isLoading,
              position: PopupMenuPosition.under,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(commonRadius)),
              onSelected: (val) async {
                if (val == 0) {
                  userStoryScreenVars.status = StoryHighlightOptions.publish;
                  userStoryScreenVars.title = language.highlightStories;
                } else if (val == 1) {
                  userStoryScreenVars.status = StoryHighlightOptions.draft;
                  userStoryScreenVars.title = language.draftStories;
                } else if (val == 2) {
                  userStoryScreenVars.status = StoryHighlightOptions.trash;
                  userStoryScreenVars.title = language.trashStories;
                }

                userStoryScreenVars.currentValue = val.toString().toInt();
                getStories();
              },
              icon: Icon(Icons.more_horiz, color: context.iconColor),
              itemBuilder: (context) => <PopupMenuEntry>[
                if (userStoryScreenVars.status != StoryHighlightOptions.publish)
                  PopupMenuItem(
                    value: 0,
                    child: Text(language.highlightStories, style: primaryTextStyle()),
                  ),
                if (userStoryScreenVars.status != StoryHighlightOptions.draft)
                  PopupMenuItem(
                    value: 1,
                    child: Text(language.draftStories, style: primaryTextStyle()),
                  ),
                if (userStoryScreenVars.status != StoryHighlightOptions.trash)
                  PopupMenuItem(
                    value: 2,
                    child: Text(language.trashStories, style: primaryTextStyle()),
                  ),
              ],
            );
          }),
        ],
        title: Observer(builder: (context) {
          return Text(userStoryScreenVars.title, style: boldTextStyle(size: 20));
        }),
        elevation: 0,
        centerTitle: true,
      ),
      body: Observer(
        builder: (_) {
          return HighlightComponent(
            highlightList: userStoryScreenVars.highlightList,
            status: userStoryScreenVars.status,
            addStory: () {
              NewHighlightScreen(
                allStories: highlightList, // fetch your stories
                onCreated: () {
                  getStories(); // refresh highlights list
                },
              ).launch(context);
              // addStory();
            },
            callback: () {
              getStories();
            },
          );
        },
      ),
      floatingActionButton: Observer(builder: (context) {
        return FloatingActionButton(
          backgroundColor: appColorPrimary,
          onPressed: () async {
            NewHighlightScreen(
              allStories: await highlightList, // fetch your stories
              onCreated: () {
                getStories(); // refresh highlights list
              },
            ).launch(context);
            // addStory();
          },
          child: Icon(Icons.add, color: Colors.white),
        ).visible(userStoryScreenVars.title == language.highlightStories && userStoryScreenVars.highlightList.isNotEmpty);
      }),
    );
  }
}
