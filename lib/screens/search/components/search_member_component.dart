import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/members/member_response.dart';
import 'package:socialv/screens/dashboard_screen.dart';
import 'package:socialv/screens/profile/screens/member_profile_screen.dart';
import 'package:socialv/screens/search/components/search_card_component.dart';
import 'package:socialv/utils/app_constants.dart';

class SearchMemberComponent extends StatelessWidget {
  final bool showRecent;

  const SearchMemberComponent({required this.showRecent});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showRecent) Text(language.recent, style: boldTextStyle()).paddingOnly(left: 16, right: 16, top: 8),
        8.height,
        Observer(builder: (context) {
          return AnimatedListView(
            slideConfiguration: SlideConfiguration(delay: 80.milliseconds, verticalOffset: 300),
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.only(left: 16, right: 16, bottom: 60),
            itemCount: searchFragStore.memberList.isNotEmpty ? searchFragStore.memberList.length : searchFragStore.recentMemberSearchList.length,
            itemBuilder: (context, index) {
              MemberResponse member = searchFragStore.memberList.isNotEmpty ? searchFragStore.memberList[index] : searchFragStore.recentMemberSearchList[index];

              return Observer(builder: (context) {
                return SearchCardComponent(
                  isRecent: searchFragStore.memberList.isNotEmpty ? false : showRecent,
                  id: member.id.validate(),
                  name: member.name.validate(),
                  image: member.avatarUrls!.full.validate(),
                  subTitle: member.userLogin.validate().contains('@') ? '' : member.userLogin.validate(),
                  isMember: true,
                  isVerified: member.isUserVerified.validate(),
                ).paddingSymmetric(vertical: 8).onTap(
                  () async {
                    if (!searchFragStore.recentMemberSearchList.any((element) => element.id.validate() == member.id)) {
                      searchFragStore.recentMemberSearchList.add(searchFragStore.memberList[index]);
                      await setValue(SharePreferencesKey.RECENT_SEARCH_MEMBERS, jsonEncode(searchFragStore.recentMemberSearchList));
                    }
                    hideKeyboard(context);
                    if (member.id.validate().toString() == userStore.loginUserId.validate().toString()) {
                      appStore.currentDashboardIndex = 4;
                      DashboardScreen(
                        index: 4,
                      ).launch(context);
                    } else {
                      MemberProfileScreen(memberId: member.id.validate()).launch(context);
                    }
                  },
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                );
              });
            },
          ).visible(searchFragStore.memberList.isNotEmpty || (searchFragStore.recentMemberSearchList.isNotEmpty && searchFragStore.isSearchFieldEmpty));
        }),
      ],
    );
  }
}
