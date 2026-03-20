import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/main.dart';
import 'package:socialv/screens/home/components/member_list_component.dart';
import 'package:socialv/screens/home/components/member_suggestion_list_component.dart';
import 'package:socialv/store/fragment_store/home_fragment_store.dart';
import 'package:socialv/utils/app_constants.dart';

// ignore: must_be_immutable
class MembersListScreen extends StatefulWidget {
  bool isSuggested;

  MembersListScreen({this.isSuggested = false});

  @override
  State<MembersListScreen> createState() => _MembersListScreenState();
}

class _MembersListScreenState extends State<MembersListScreen> {
  HomeFragStore membersListScreenVars = HomeFragStore();

  @override
  void initState() {
    membersListScreenVars.isSuggested = widget.isSuggested;
    super.initState();
  }

  @override
  void dispose() {
    if (appStore.isLoading) appStore.setLoading(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: context.iconColor),
        title: Observer(builder: (context) {
          return Text(membersListScreenVars.isSuggested.validate() ? language.suggestions : language.allMembers, style: boldTextStyle(size: 20));
        }),
        elevation: 0,
        centerTitle: true,
        actions: [
          Theme(
            data: Theme.of(context).copyWith(
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
            ),
            child: Observer(builder: (context) {
              return PopupMenuButton(
                enabled: !appStore.isLoading,
                position: PopupMenuPosition.under,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(commonRadius)),
                onSelected: (val) async {
                  if (val == 1 && membersListScreenVars.isSuggested) {
                    membersListScreenVars.isSuggested = false;
                  } else if (val == 2 && !membersListScreenVars.isSuggested) {
                    membersListScreenVars.isSuggested = true;
                  }
                },
                icon: Icon(Icons.more_horiz),
                itemBuilder: (context) => <PopupMenuEntry>[
                  PopupMenuItem(
                    value: 1,
                    child: Text(language.allMembers, style: primaryTextStyle()),
                    textStyle: secondaryTextStyle(color: !membersListScreenVars.isSuggested ? appColorPrimary : null),
                  ),
                  PopupMenuItem(
                    value: 2,
                    child: Text(language.suggestions, style: primaryTextStyle()),
                    textStyle: secondaryTextStyle(color: membersListScreenVars.isSuggested ? appColorPrimary : null),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
      body: Observer(builder: (context) {
        return membersListScreenVars.isSuggested ? MemberSuggestionListComponent() : MemberListComponent();
      }),
    );
  }
}
