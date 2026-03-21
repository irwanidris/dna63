import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/main.dart';
import 'package:socialv/screens/forums/components/favourite_topics_component.dart';
import 'package:socialv/screens/forums/components/forum_replies_component.dart';
import 'package:socialv/screens/forums/components/forum_subscription_component.dart';
import 'package:socialv/screens/forums/components/user_topic_component.dart';
import 'package:socialv/screens/forums/components/forums_engagement_component.dart';
import 'package:socialv/store/profile_menu_store.dart';

import '../../../utils/app_constants.dart';

class MyForumsScreen extends StatefulWidget {
  const MyForumsScreen({Key? key}) : super(key: key);

  @override
  State<MyForumsScreen> createState() => _MyForumsScreenState();
}

class _MyForumsScreenState extends State<MyForumsScreen> {
  List<String> tabList = [language.topics, language.replies, language.engagement, language.favourite, language.subscriptions];

  ProfileMenuStore myForumsScreenVars = ProfileMenuStore();

  @override
  void initState() {
    super.initState();
    myForumsScreenVars.selectedTab = 0;
  }

  Widget getTabContainer() {
    if (myForumsScreenVars.selectedTab == 0) {
      return UserTopicComponent();
    } else if (myForumsScreenVars.selectedTab == 1) {
      return ForumRepliesComponent();
    } else if (myForumsScreenVars.selectedTab == 2) {
      return ForumsEngagementComponent();
    } else if (myForumsScreenVars.selectedTab == 3) {
      return FavouriteTopicComponent();
    } else {
      return ForumSubscriptionComponent();
    }
  }

  @override
  void dispose() {
    appStore.setLoading(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(language.forums, style: boldTextStyle(size: 20)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.iconColor),
          onPressed: () {
            finish(context);
          },
        ),
      ),
      body: Column(
        children: [
          ///Horizontal list
          HorizontalList(
            spacing: 0,
            padding: EdgeInsets.all(16),
            itemCount: tabList.length,
            itemBuilder: (context, index) {
              return Observer(
                builder: (_) => AppButton(
                  shapeBorder: RoundedRectangleBorder(borderRadius: radius(commonRadius)),
                  text: tabList[index],
                  textStyle: boldTextStyle(
                    color: myForumsScreenVars.selectedTab == index
                        ? Colors.white
                        : appStore.isDarkMode
                            ? bodyDark
                            : bodyWhite,
                    size: 14,
                  ),
                  onTap: () {
                    myForumsScreenVars.selectedTab = index;
                  },
                  elevation: 0,
                  color: myForumsScreenVars.selectedTab == index ? context.primaryColor : context.scaffoldBackgroundColor,
                ),
              );
            },
          ),

          Observer(
            builder: (_) => getTabContainer().expand(),
          )
        ],
      ),
    );
  }
}
