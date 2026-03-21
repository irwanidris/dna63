import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/screens/groups/screens/create_group_screen.dart';
import 'package:socialv/store/group_store.dart';

import '../../../components/loading_widget.dart';
import '../../../main.dart';
import '../../../network/rest_apis.dart';
import '../../../utils/colors.dart';
import '../../../utils/common.dart';

class CreateGroupStepSecond extends StatefulWidget {
  final Function(int)? onNextPage;
  final bool? isAPartOfSteps;
  final String? groupInviteStatus;
  final int? isGalleryEnabled;
  final GroupInvitations? groupInvitations;

  const CreateGroupStepSecond({Key? key, this.onNextPage, this.isAPartOfSteps = true, this.groupInviteStatus, this.isGalleryEnabled, this.groupInvitations = GroupInvitations.members}) : super(key: key);

  @override
  State<CreateGroupStepSecond> createState() => _CreateGroupStepSecondState();
}

enum GroupInvitations { members, mods, admins }

enum EnableGallery { yes, no }

class _CreateGroupStepSecondState extends State<CreateGroupStepSecond> {
  String isGalleryEnabled = EnableGallery.no.toString();
  GroupStore createGroupStepSecondVars = GroupStore();

  @override
  void initState() {
    super.initState();
    createGroupStepSecondVars.enableGallery = widget.isGalleryEnabled == 1;
    isGalleryEnabled = createGroupStepSecondVars.enableGallery ? EnableGallery.yes.toString() : EnableGallery.no.toString();
    if (widget.groupInviteStatus.validate().isNotEmpty) {
      switch (widget.groupInviteStatus?.toLowerCase()) {
        case "members":
          createGroupStepSecondVars.groupInvitations = GroupInvitations.members;
          break;
        case "mods":
          createGroupStepSecondVars.groupInvitations = GroupInvitations.mods;
          break;
        case "admins":
          createGroupStepSecondVars.groupInvitations = GroupInvitations.admins;
          break;
        default:
          createGroupStepSecondVars.groupInvitations = widget.groupInvitations ?? GroupInvitations.members;
      }
    } else {
      createGroupStepSecondVars.groupInvitations = widget.groupInvitations ?? GroupInvitations.members;
    }
  }

  Future<void> editGroup() async {
    ifNotTester(() async {
      appStore.setLoading(true);
      Map<String, dynamic> request = {"invite_status": createGroupStepSecondVars.groupInvitations.toString().split('.').last, "enable_gallery": createGroupStepSecondVars.enableGallery ? "yes" : "no"};

      await editGroupSettings(groupId: groupId, request: request).then((value) {
        appStore.setLoading(false);
        toast(value.message.toString());
        if (widget.isAPartOfSteps.validate()) {
          widget.onNextPage?.call(2);
        } else {
          finish(context, true);
        }
      }).catchError((e) {
        log(e.toString());
        appStore.setLoading(false);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => Container(
        decoration: BoxDecoration(
          borderRadius: radiusOnly(topRight: defaultRadius, topLeft: defaultRadius),
        ),
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.isAPartOfSteps.validate())
                      Text(
                        "2. ${language.groupSettings}",
                        style: primaryTextStyle(color: appStore.isDarkMode ? bodyDark : bodyWhite, size: 18),
                      ).paddingTop(16),
                    16.height,
                    Text(language.groupInvites, style: primaryTextStyle(color: appStore.isDarkMode ? bodyDark : bodyWhite, size: 18)),
                    16.height,
                    Text(language.groupInvitationsSubtitle, style: secondaryTextStyle()),
                    16.height,
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Observer(builder: (context) {
                          return Radio<GroupInvitations>(
                value: GroupInvitations.members,
                groupValue: createGroupStepSecondVars.groupInvitations,
                onChanged: (GroupInvitations? value) {
                  if (!appStore.isLoading) createGroupStepSecondVars.groupInvitations = value;
                },
              );
                        }),
                        Text(language.allGroupMembers, style: boldTextStyle()).paddingTop(12),
                      ],
                    ).onTap(() {
                      if (!appStore.isLoading) createGroupStepSecondVars.groupInvitations = GroupInvitations.members;
                    }),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Radio<GroupInvitations>(
                value: GroupInvitations.mods,
                groupValue: createGroupStepSecondVars.groupInvitations,
                onChanged: (GroupInvitations? value) {
                  if (!appStore.isLoading) createGroupStepSecondVars.groupInvitations = value;
                },
              ),
                        Text(language.groupAdminsAndModsOnly, style: boldTextStyle()).paddingTop(12),
                      ],
                    ).onTap(() {
                      if (!appStore.isLoading) createGroupStepSecondVars.groupInvitations = GroupInvitations.mods;
                    }),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Observer(builder: (context) {
                          return Radio<GroupInvitations>(
                value: GroupInvitations.admins,
                groupValue: createGroupStepSecondVars.groupInvitations,
                onChanged: (GroupInvitations? value) {
                  if (!appStore.isLoading) createGroupStepSecondVars.groupInvitations = value;
                },
              );
                        }),
                        Text(language.groupAdminsOnly, style: boldTextStyle()).paddingTop(12),
                      ],
                    ).onTap(() {
                      if (!appStore.isLoading) createGroupStepSecondVars.groupInvitations = GroupInvitations.admins;
                    }),
                    8.height,
                    Text(language.enableGallery, style: primaryTextStyle(color: appStore.isDarkMode ? bodyDark : bodyWhite, size: 18)),
                    16.height,
                    Text(language.enableGallerySubtitle, style: secondaryTextStyle()),
                    16.height,
                    Row(
                      children: [
                        Observer(builder: (context) {
                          return Checkbox(
                            shape: RoundedRectangleBorder(borderRadius: radius(2)),
                            activeColor: context.primaryColor,
                            value: createGroupStepSecondVars.enableGallery,
                            onChanged: (val) {
                              createGroupStepSecondVars.enableGallery = !createGroupStepSecondVars.enableGallery;
                              isGalleryEnabled = createGroupStepSecondVars.enableGallery ? EnableGallery.yes.toString() : EnableGallery.no.toString();
                            },
                          );
                        }),
                        Text(language.enableGalleryCheckBoxText, style: secondaryTextStyle()).onTap(() {
                          createGroupStepSecondVars.enableGallery = !createGroupStepSecondVars.enableGallery;
                        }, splashColor: Colors.transparent, highlightColor: Colors.transparent),
                      ],
                    ),
                    32.height,
                    appButton(
                      context: context,
                      text: language.submit.capitalizeFirstLetter(),
                      onTap: () {
                        if (widget.isAPartOfSteps.validate()) {
                          editGroup();
                          widget.onNextPage?.call(2);
                        } else {
                          editGroup();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            Observer(builder: (_) => LoadingWidget().center().visible(appStore.isLoading)),
          ],
        ),
      ),
    );
  }
}
