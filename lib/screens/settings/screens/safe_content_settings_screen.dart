import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/base_scaffold_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/store/profile_menu_store.dart';

import '../../../utils/app_constants.dart';

enum GroupType { FILTER, OFF }

class SafeContentSettingsScreen extends StatefulWidget {
  const SafeContentSettingsScreen({super.key});

  @override
  State<SafeContentSettingsScreen> createState() => _SafeContentSettingsScreenState();
}

class _SafeContentSettingsScreenState extends State<SafeContentSettingsScreen> {
  ProfileMenuStore safeContentSettingsScreenVars = ProfileMenuStore();

  @override
  void initState() {
    super.initState();

    if (appStore.filterContent) {
      safeContentSettingsScreenVars.groupType = GroupType.FILTER;
    } else {
      safeContentSettingsScreenVars.groupType = GroupType.OFF;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: language.contentSafety,
      child: Observer(builder: (_) {
        return SingleChildScrollView(
          child: Column(
            children: [
              Text(
                language.contentSafetyText,
                style: secondaryTextStyle(),
              ).paddingSymmetric(horizontal: 16),
              16.height,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RadioGroup(
                    child: Radio<GroupType>(value: GroupType.FILTER),
                    groupValue: safeContentSettingsScreenVars.groupType,
                    onChanged: (GroupType? value) {
                      if (!appStore.isLoading) {
                        safeContentSettingsScreenVars.groupType = value;

                        appStore.setFilterContent(true);
                      }
                    },
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(language.filter, style: boldTextStyle()).paddingTop(12),
                      6.height,
                      Text(language.contentFilterText, style: secondaryTextStyle(size: 12)),
                      8.height,
                    ],
                  ).expand(),
                ],
              ).onTap(() {
                if (!appStore.isLoading) {
                  safeContentSettingsScreenVars.groupType = GroupType.FILTER;

                  appStore.setFilterContent(true);
                }
              }),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RadioGroup<GroupType>(
                    groupValue: safeContentSettingsScreenVars.groupType,
                    onChanged: (GroupType? value) {
                      if (!appStore.isLoading && value != null) {
                        appStore.setFilterContent(value == GroupType.OFF ? false : true);
                        safeContentSettingsScreenVars.groupType = value;
                      }
                    },
                    child: Radio<GroupType>(value: GroupType.OFF),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(language.off, style: boldTextStyle()).paddingTop(12),
                      6.height,
                      Text(language.contentFilterText, style: secondaryTextStyle(size: 12)),
                      8.height,
                    ],
                  ).expand(),
                ],
              ).onTap(() {
                if (!appStore.isLoading) {
                  appStore.setFilterContent(false);
                  safeContentSettingsScreenVars.groupType = GroupType.OFF;
                }
              }),
              16.height,
              ExpansionTile(
                title: Text(language.moreAboutContentSafety, style: primaryTextStyle()),
                iconColor: context.primaryColor,
                collapsedIconColor: appStore.isDarkMode ? bodyDark : bodyWhite,
                childrenPadding: EdgeInsets.all(16),
                children: <Widget>[
                  Text(
                    language.contentSafetyIsDesigned,
                    style: secondaryTextStyle(),
                  )
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}
