import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/groups/group_response.dart';
import 'package:socialv/screens/groups/components/group_suggestions_component.dart';
import 'package:socialv/screens/groups/screens/group_detail_screen.dart';
import 'package:socialv/screens/membership/screens/membership_plans_screen.dart';
import 'package:socialv/screens/search/components/search_card_component.dart';
import 'package:socialv/utils/app_constants.dart';

class SearchGroupComponent extends StatelessWidget {
  final bool showRecent;

  const SearchGroupComponent({required this.showRecent});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (searchFragStore.isSearchFieldEmpty ) GroupSuggestionsComponent(),
        if (showRecent) Text(language.recent, style: boldTextStyle()).paddingOnly(left: 16, right: 16, top: 8),
        Observer(builder: (context) {
          return AnimatedListView(
            slideConfiguration: SlideConfiguration(delay: 80.milliseconds, verticalOffset: 300),
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
            itemCount: searchFragStore.groupList.isNotEmpty ? searchFragStore.groupList.length : searchFragStore.recentGroupsSearchList.length,
            itemBuilder: (context, index) {
              GroupResponse group = searchFragStore.groupList.isNotEmpty ? searchFragStore.groupList[index] : searchFragStore.recentGroupsSearchList[index];
              return Observer(builder: (context) {
                return SearchCardComponent(
                  isRecent: searchFragStore.groupList.isNotEmpty ? false : showRecent,
                  id: group.id.validate(),
                  isMember: false,
                  name: group.name.validate(),
                  image: group.avatarUrls != null ? group.avatarUrls!.full.validate() : AppImages.defaultAvatarUrl,
                  subTitle: parseHtmlString(group.description!.rendered.validate()),
                ).paddingSymmetric(vertical: 8).onTap(() async {
                  if (!searchFragStore.recentGroupsSearchList.any((element) => element.id.validate() == group.id)) {
                    searchFragStore.recentGroupsSearchList.add(group);
                    await setValue(SharePreferencesKey.RECENT_SEARCH_GROUPS, jsonEncode(searchFragStore.recentGroupsSearchList));
                  }
                  hideKeyboard(context);
                  if (pmpStore.viewSingleGroup) {
                    GroupDetailScreen(groupId: group.id.validate()).launch(context);
                  } else {
                    MembershipPlansScreen().launch(context);
                  }
                }, splashColor: Colors.transparent, highlightColor: Colors.transparent);
              });
            },
          ).visible(searchFragStore.groupList.isNotEmpty || searchFragStore.recentGroupsSearchList.isNotEmpty && searchFragStore.isSearchFieldEmpty);
        }),
      ],
    );
  }
}
