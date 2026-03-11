import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/file_picker_dialog_component.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/groups/components/create_group_step_one.dart';
import 'package:socialv/screens/groups/screens/create_group_screen.dart';
import 'package:socialv/store/group_store.dart';
import 'package:socialv/utils/app_constants.dart';
import 'package:socialv/utils/cached_network_image.dart';
import '../../../components/radio_group.dart';

import 'edit_group_settings_screen.dart';

class EditGroupScreen extends StatefulWidget {
  final int groupId;

  const EditGroupScreen({required this.groupId});

  @override
  State<EditGroupScreen> createState() => _EditGroupScreenState();
}

class _EditGroupScreenState extends State<EditGroupScreen> {
  GroupStore editGroupScreenVars = GroupStore();

  TextEditingController nameCont = TextEditingController();
  TextEditingController descriptionCont = TextEditingController();

  FocusNode name = FocusNode();
  FocusNode description = FocusNode();

  bool isChange = false;
  bool detailsChanged = false;

  List<List<String>> get groupTypeRule => [
        [
          language.createGroupPublicA,
          language.createGroupPublicB,
          language.createGroupPublicC,
        ],
        [
          language.createGroupPrivateA,
          language.createGroupPrivateB,
          language.createGroupPrivateC,
        ],
        [
          language.createGroupHiddenA,
          language.createGroupHiddenB,
          language.createGroupHiddenC,
        ],
      ];

  @override
  void initState() {
    setStatusBarColor(Colors.transparent);
    super.initState();
    editGroupScreenVars.avatarUrl = AppImages.placeHolderImage;
    editGroupScreenVars.coverUrl = AppImages.profileBackgroundImage;
    editGroupScreenVars.groupType = GroupType.PUBLIC;
    afterBuildCreated(() {
      init();
    });
  }

  Future<void> init() async {
    appStore.setLoading(true);

    await getGroupDetail(groupId: widget.groupId.validate()).then((value) {
      editGroupScreenVars.group = value;
      editGroupScreenVars.enableForum = editGroupScreenVars.group.isForumEnable.validate();

      appStore.setLoading(false);
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });

    editGroupScreenVars.coverUrl = editGroupScreenVars.group.groupCoverImage.validate().isNotEmpty ? editGroupScreenVars.group.groupCoverImage.validate() : AppImages.profileBackgroundImage;
    if (editGroupScreenVars.group.groupAvatarImage.validate().isNotEmpty) editGroupScreenVars.avatarUrl = editGroupScreenVars.group.groupAvatarImage.validate();
    nameCont.text = editGroupScreenVars.group.name.validate();
    descriptionCont.text = editGroupScreenVars.group.description!.validate();

    if (editGroupScreenVars.group.groupType.validate() == AccountType.public) {
      editGroupScreenVars.groupType = GroupType.PUBLIC;
    } else if (editGroupScreenVars.group.groupType.validate() == AccountType.private) {
      editGroupScreenVars.groupType = GroupType.PRIVATE;
    } else {
      editGroupScreenVars.groupType = GroupType.HIDDEN;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          finish(context, isChange);
        }
      },
      child: Observer(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: Text(language.editGroup, style: boldTextStyle(size: 20)),
            elevation: 0,
            centerTitle: true,
            actions: [
              cachedImage(
                ic_setting,
                color: appStore.isDarkMode ? bodyDark : bodyWhite,
                height: 22,
                width: 22,
              ).paddingAll(8).onTap(
                () {
                  groupId = editGroupScreenVars.group.id.validate();
                  log('group: ${editGroupScreenVars.group.id.validate()}');
                  EditGroupSettingsScreen(
                    groupId: editGroupScreenVars.group.id.validate(),
                    groupInviteStatus: editGroupScreenVars.group.inviteStatus.validate(),
                    isGalleryEnabled: editGroupScreenVars.group.isGalleryEnabled,
                    groupInvitations: editGroupScreenVars.groupInvitations,
                  ).launch(context).then(
                    (value) {
                      if (value ?? false) {
                        isChange = true;
                        init();
                      }
                    },
                  );
                },
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
              IconButton(
                onPressed: () {
                  if (!appStore.isLoading)
                    showConfirmDialogCustom(
                      context,
                      onAccept: (c) {
                        ifNotTester(() {
                          appStore.setLoading(true);
                          deleteGroup(id: widget.groupId.toString().validate()).then((value) {
                            finish(context);
                            toast(language.groupDeletedSuccessfully, print: true);
                            finish(context, true);
                          }).catchError((e) {
                            appStore.setLoading(false);
                            toast(e.toString(), print: true);
                          });
                        });
                      },
                      dialogType: DialogType.DELETE,
                      title: language.doYouWantTo,
                    );
                },
                icon: Icon(Icons.delete_outline, color: appStore.isDarkMode ? bodyDark : bodyWhite),
              )
            ],
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Observer(builder: (context) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        child: Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            editGroupScreenVars.coverImage == null
                                ? cachedImage(
                                    editGroupScreenVars.coverUrl,
                                    width: context.width(),
                                    height: 220,
                                    fit: BoxFit.cover,
                                  ).cornerRadiusWithClipRRectOnly(topLeft: defaultRadius.toInt(), topRight: defaultRadius.toInt())
                                : Image.file(
                                    File(editGroupScreenVars.coverImage!.path.validate()),
                                    width: context.width(),
                                    height: 220,
                                    fit: BoxFit.cover,
                                  ).cornerRadiusWithClipRRectOnly(topLeft: defaultRadius.toInt(), topRight: defaultRadius.toInt()),
                            Positioned(
                              right: 8,
                              top: 8,
                              child: GestureDetector(
                                onTap: () async {
                                  FileTypes? file = await showInDialog(
                                    context,
                                    contentPadding: EdgeInsets.symmetric(vertical: 16),
                                    backgroundColor: context.scaffoldBackgroundColor,
                                    title: Text(language.chooseAnAction, style: boldTextStyle()),
                                    builder: (p0) {
                                      return FilePickerDialog(isSelected: editGroupScreenVars.coverUrl == AppImages.profileBackgroundImage);
                                    },
                                  );

                                  if (file != null) {
                                    if (file == FileTypes.CANCEL) {
                                      ifNotTester(() async {
                                        appStore.setLoading(true);
                                        await deleteGroupCoverImage(id: widget.groupId.validate()).then((value) {
                                          toast(language.coverImageRemovedSuccessfully);
                                          isChange = true;
                                          init();
                                        }).catchError((e) {
                                          appStore.setLoading(false);
                                          toast(language.cRemoveCoverImage);
                                        });
                                      });
                                    } else {
                                      editGroupScreenVars.coverImage = await getImageSource(isCamera: file == FileTypes.CAMERA ? true : false);
                                      appStore.setLoading(false);
                                    }
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: appColorPrimary, borderRadius: radius(100)),
                                  child: Icon(Icons.edit_outlined, color: Colors.white, size: 18),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 2), shape: BoxShape.circle),
                                    child: editGroupScreenVars.avatarImage == null
                                        ? cachedImage(
                                            editGroupScreenVars.avatarUrl,
                                            height: 100,
                                            width: 100,
                                            fit: BoxFit.cover,
                                          ).cornerRadiusWithClipRRect(100)
                                        : Image.file(
                                            File(editGroupScreenVars.avatarImage!.path.validate()),
                                            height: 100,
                                            width: 100,
                                            fit: BoxFit.cover,
                                          ).cornerRadiusWithClipRRect(100),
                                  ),
                                  Positioned(
                                    bottom: 2,
                                    right: -2,
                                    child: GestureDetector(
                                      onTap: () async {
                                        FileTypes? file = await showInDialog(
                                          context,
                                          contentPadding: EdgeInsets.symmetric(vertical: 16),
                                          backgroundColor: context.scaffoldBackgroundColor,
                                          title: Text(language.chooseAnAction, style: boldTextStyle()),
                                          builder: (p0) {
                                            return FilePickerDialog(isSelected: getSourceLink(editGroupScreenVars.avatarUrl) == AppImages.defaultAvatarUrl);
                                          },
                                        );

                                        if (file != null) {
                                          if (file == FileTypes.CANCEL) {
                                            ifNotTester(() async {
                                              appStore.setLoading(true);
                                              await deleteAvatarImage(id: widget.groupId.toString().validate(), isGroup: true).then((value) {
                                                isChange = true;
                                                init();
                                              }).catchError((e) {
                                                appStore.setLoading(true);
                                                toast(e.toString());
                                              });
                                            });
                                          } else {
                                            editGroupScreenVars.avatarImage = await getImageSource(isCamera: file == FileTypes.CAMERA ? true : false);
                                            appStore.setLoading(false);
                                          }
                                        }
                                      },
                                      child: Container(
                                        clipBehavior: Clip.antiAlias,
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(color: appColorPrimary, shape: BoxShape.circle),
                                        child: Icon(Icons.edit_outlined, color: Colors.white, size: 18),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        height: 280,
                      ),
                      66.height,
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: AppTextField(
                          enabled: !appStore.isLoading,
                          controller: nameCont,
                          focus: name,
                          nextFocus: description,
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                          textFieldType: TextFieldType.NAME,
                          textStyle: boldTextStyle(),
                          decoration: inputDecoration(
                            context,
                            label: language.name,
                            labelStyle: secondaryTextStyle(weight: FontWeight.w600),
                          ),
                          onChanged: (x) {
                            detailsChanged = true;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: AppTextField(
                          enabled: !appStore.isLoading,
                          controller: descriptionCont,
                          focus: description,
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.done,
                          textFieldType: TextFieldType.NAME,
                          textStyle: boldTextStyle(),
                          decoration: inputDecoration(
                            context,
                            label: language.description,
                            labelStyle: secondaryTextStyle(weight: FontWeight.w600),
                          ),
                          onChanged: (x) {
                            detailsChanged = true;
                          },
                        ),
                      ),
                      24.height,
                      Text(
                        language.privacyOptions,
                        style: primaryTextStyle(color: appStore.isDarkMode ? bodyDark : bodyWhite, size: 18),
                      ).paddingSymmetric(horizontal: 16),
                      16.height,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Observer(builder: (context) {
                            return RadioGroup(
                              groupValue: editGroupScreenVars.groupType,
                              onChanged: (GroupType? value) {
                                log("value $value");
                                if (!appStore.isLoading) editGroupScreenVars.groupType = value;
                                log("${editGroupScreenVars.groupType}");
                              },
                              child: Radio(value: GroupType.PUBLIC),
                            );
                          }),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(language.thisIsAPublic, style: boldTextStyle()).paddingTop(12),
                              6.height,
                              Column(
                                children: groupTypeRule[0].map((e) {
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Icon(Icons.circle, color: Colors.grey.shade500, size: 8).paddingTop(4),
                                      8.width,
                                      Text(e.validate(), style: secondaryTextStyle(size: 12)).expand(),
                                    ],
                                  ).paddingSymmetric(vertical: 2);
                                }).toList(),
                              ).paddingOnly(right: 16),
                            ],
                          ).expand(),
                        ],
                      ).onTap(() {
                        detailsChanged = true;
                        editGroupScreenVars.groupType = GroupType.PUBLIC;
                        log("${editGroupScreenVars.groupType}");
                      }, splashColor: Colors.transparent, highlightColor: Colors.transparent),
                      16.height,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Observer(builder: (context) {
                            return RadioGroup(
                              groupValue: editGroupScreenVars.groupType,
                              onChanged: (GroupType? value) {
                                log("value $value");
                                detailsChanged = true;
                                editGroupScreenVars.groupType = value;
                              },
                              child: Radio(value: GroupType.PRIVATE),
                            );
                          }),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(language.thisIsAPrivate, style: boldTextStyle()).paddingTop(12),
                              6.height,
                              Column(
                                children: groupTypeRule[1].map((e) {
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Icon(Icons.circle, color: Colors.grey.shade500, size: 8).paddingTop(4),
                                      8.width,
                                      Text(e.validate(), style: secondaryTextStyle(size: 12)).expand(),
                                    ],
                                  ).paddingSymmetric(vertical: 2);
                                }).toList(),
                              ).paddingOnly(right: 16),
                            ],
                          ).expand(),
                        ],
                      ).onTap(() {
                        detailsChanged = true;
                        editGroupScreenVars.groupType = GroupType.PRIVATE;
                      }, splashColor: Colors.transparent, highlightColor: Colors.transparent),
                      16.height,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Observer(builder: (context) {
                            return RadioGroup(
                              groupValue: editGroupScreenVars.groupType,
                              onChanged: (GroupType? value) {
                                detailsChanged = true;
                                editGroupScreenVars.groupType = value;
                                log("${editGroupScreenVars.groupType}");
                              },
                              child: Radio(value: GroupType.HIDDEN),
                            );
                          }),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(language.thisIsAHidden, style: boldTextStyle()).paddingTop(12),
                              6.height,
                              Column(
                                children: groupTypeRule[2].map((e) {
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.circle, color: Colors.grey.shade500, size: 8).paddingTop(4),
                                      8.width,
                                      Text(e.validate(), style: secondaryTextStyle(size: 12)).expand(),
                                    ],
                                  ).paddingSymmetric(vertical: 2);
                                }).toList(),
                              ).paddingOnly(right: 16),
                            ],
                          ).expand(),
                        ],
                      ).onTap(() {
                        detailsChanged = true;
                        editGroupScreenVars.groupType = GroupType.HIDDEN;
                      }),
                      16.height,
                      Text(language.groupForum, style: primaryTextStyle(color: appStore.isDarkMode ? bodyDark : bodyWhite, size: 18)).paddingSymmetric(horizontal: 16),
                      10.height,
                      Text(language.groupAsForumText, style: secondaryTextStyle()).paddingSymmetric(horizontal: 16),
                      16.height,
                      Row(
                        children: [
                          Observer(builder: (context) {
                            return Checkbox(
                              shape: RoundedRectangleBorder(borderRadius: radius(2)),
                              activeColor: context.primaryColor,
                              value: editGroupScreenVars.enableForum,
                              onChanged: (val) {
                                editGroupScreenVars.enableForum = !editGroupScreenVars.enableForum;
                                detailsChanged = true;
                              },
                            );
                          }),
                          Text(language.wantGroupAsForum, style: secondaryTextStyle()).onTap(
                            () {
                              editGroupScreenVars.enableForum = !editGroupScreenVars.enableForum;
                              detailsChanged = true;
                            },
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                          ),
                        ],
                      ),
                    ],
                  );
                }),
              ),
              LoadingWidget().visible(appStore.isLoading).center(),
            ],
          ),
          bottomNavigationBar: appStore.isLoading
              ? Offstage()
              : appButton(
                  context: context,
                  text: language.update.capitalizeFirstLetter(),
                  onTap: () async {
                    ifNotTester(() async {
                      if (nameCont.text.isNotEmpty && detailsChanged) {
                        Map request = {
                          "name": nameCont.text,
                          "description": descriptionCont.text,
                          "status": editGroupScreenVars.groupType == GroupType.PUBLIC
                              ? AccountType.public
                              : editGroupScreenVars.groupType == GroupType.PRIVATE
                                  ? AccountType.private
                                  : AccountType.hidden,
                          "enable_forum": editGroupScreenVars.enableForum,
                        };

                        await updateGroup(request: request, groupId: widget.groupId.validate()).then((value) {
                          toast(language.groupUpdatedSuccessfully, print: true);
                        }).catchError((e) {
                          toast(e.toString(), print: true);
                        });
                      }

                      if (editGroupScreenVars.avatarImage != null) {
                        await groupAttachImage(id: widget.groupId.validate(), image: editGroupScreenVars.avatarImage).then((value) => init());
                      }

                      if (editGroupScreenVars.coverImage != null) {
                        await groupAttachImage(id: widget.groupId.validate(), image: editGroupScreenVars.coverImage, isCoverImage: true).then((value) => init()).catchError((e) {
                          log(e.toString());
                        });
                      }
                      finish(context);
                      finish(context, true);
                    });
                  },
                ).paddingAll(16),
        ),
      ),
    );
  }
}
