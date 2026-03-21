import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/file_picker_dialog_component.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/profile/components/expansion_body.dart';
import 'package:socialv/store/profile_menu_store.dart';
import 'package:socialv/utils/app_constants.dart';
import 'package:socialv/utils/cached_network_image.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  ProfileMenuStore editProfileScreenVars = ProfileMenuStore();

  TextEditingController nameCont = TextEditingController();

  FocusNode name = FocusNode();
  FocusNode mentionName = FocusNode();
  FocusNode dOB = FocusNode();
  FocusNode location = FocusNode();
  FocusNode bio = FocusNode();

  @override
  void initState() {
    editProfileScreenVars.avatarUrl = userStore.loginAvatarUrl;
    editProfileScreenVars.coverImage = AppImages.profileBackgroundImage;
    getFiledList();
    setStatusBarColor(Colors.transparent);
    super.initState();
    afterBuildCreated(() {
      init();
    });
  }

  Future<void> getFiledList() async {
    appStore.setLoading(true);
    isDetailChange = false;

    await getProfileFields().then((value) {
      editProfileScreenVars.fieldList.addAll(value);
      appStore.setLoading(false);
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  Future<void> init() async {
    editProfileScreenVars.avatarUrl = userStore.loginAvatarUrl;
    editProfileScreenVars.avatarImage = File('${userStore.loginAvatarUrl}');
    nameCont.text = userStore.loginFullName;
    nameCont.selection = TextSelection.fromPosition(TextPosition(offset: nameCont.text.length));

    await getMemberCoverImage(id: userStore.loginUserId).then((value) {
      editProfileScreenVars.cover = File("${value.first.image}");
      editProfileScreenVars.isCover = true;
    }).catchError((e) {
      editProfileScreenVars.coverImage = AppImages.profileBackgroundImage;
      editProfileScreenVars.isCover = false;
      log("Error : ${e.toString()}");
    });
  }

  void update() {
    ifNotTester(() async {
      if (nameCont.text.isNotEmpty && nameCont.text != userStore.loginFullName) {
        appStore.setLoading(true);
        Map request = {"name": nameCont.text};
        await updateLoginUser(request: request).then((value) {
          userStore.setLoginFullName(value.name.validate());
          toast(language.profileUpdatedSuccessfully, print: true);
          if (editProfileScreenVars.avatarImage == null && editProfileScreenVars.cover == null) {
            appStore.setLoading(false);
            finish(context, true);
          }
        }).catchError((e) {
          appStore.setLoading(false);
          log(e.toString());
        });
      }

/*      if (editProfileScreenVars.avatarImage != null) {
        appStore.setLoading(true);
        await attachMemberImage(id: userStore.loginUserId, image: editProfileScreenVars.avatarImage).then((value) {
          init();
          if (editProfileScreenVars.cover == null) {
            appStore.setLoading(false);
            finish(context, true);
          }
          toast(language.profilePictureUpdatedSuccessfully);
        }).catchError((e) {
          appStore.setLoading(false);
          editProfileScreenVars.avatarImage = null;
        });
      }*/

      /*   if (editProfileScreenVars.cover != null) {
        appStore.setLoading(true);
        await attachMemberImage(id: userStore.loginUserId, image: editProfileScreenVars.cover, isCover: true).then((value) {
          LiveStream().emit(OnAddPostProfile);
          appStore.setLoading(false);
          finish(context, true);
          toast(language.coverUpdatedSuccessfully);
        }).catchError((e) {
          appStore.setLoading(false);
          log(e.toString());
        });
      }*/
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pop(context, true);
        }
      },
      child: Observer(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: Text(language.editProfile, style: boldTextStyle(size: 20)),
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: context.iconColor),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  if (!appStore.isLoading) update();
                },
                child: Text(
                  language.update.capitalizeFirstLetter(),
                  style: secondaryTextStyle(color: context.primaryColor),
                ),
              ).paddingSymmetric(vertical: 8, horizontal: 8),
            ],
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          Observer(builder: (context) {
                            return editProfileScreenVars.cover == null
                                ? cachedImage(
                                    editProfileScreenVars.coverImage,
                                    width: context.width(),
                                    height: 220,
                                    fit: BoxFit.cover,
                                  ).cornerRadiusWithClipRRectOnly(topLeft: defaultRadius.toInt(), topRight: defaultRadius.toInt())
                                : cachedImage(
                                    editProfileScreenVars.cover!.path.toString(),
                                    width: context.width(),
                                    height: 220,
                                    fit: BoxFit.cover,
                                  ).cornerRadiusWithClipRRectOnly(topLeft: defaultRadius.toInt(), topRight: defaultRadius.toInt());
                          }),
                          Positioned(
                            right: 8,
                            top: 8,
                            child: GestureDetector(
                              onTap: () async {
                                if (!appStore.isLoading) {
                                  FileTypes? file = await showInDialog(
                                    context,
                                    contentPadding: EdgeInsets.symmetric(vertical: 16),
                                    backgroundColor: context.scaffoldBackgroundColor,
                                    title: Text(language.chooseAnAction, style: boldTextStyle()),
                                    builder: (p0) {
                                      return FilePickerDialog(
                                        isSelected: !editProfileScreenVars.isCover,
                                        avatarUrl: editProfileScreenVars.cover?.path ?? '',
                                        showRemoveOption: true,
                                        type: "cover",
                                      );
                                    },
                                  );
                                  if (file != null) {
                                    if (file == FileTypes.CANCEL) {
                                      ifNotTester(() async {
                                        appStore.setLoading(true);
                                        await deleteMemberCoverImage(id: userStore.loginUserId.toInt()).then((value) {
                                          appStore.setLoading(false);
                                          editProfileScreenVars.coverImage = AppImages.profileBackgroundImage;
                                          editProfileScreenVars.cover = null;
                                          toast(language.coverImageRemovedSuccessfully);
                                          // init();
                                        }).catchError((e) {
                                          appStore.setLoading(false);
                                          editProfileScreenVars.cover = null;
                                          toast(language.cRemoveCoverImage);
                                        });
                                      });
                                    } else {
                                      editProfileScreenVars.cover = await getImageSource(isCamera: file == FileTypes.CAMERA ? true : false);
                                      appStore.setLoading(true);
                                      await attachMemberImage(id: userStore.loginUserId, image: editProfileScreenVars.cover, isCover: true).then((value) {
                                        LiveStream().emit(OnAddPostProfile);
                                      }).catchError((e) {
                                        appStore.setLoading(false);
                                        log(e.toString());
                                      });
                                      appStore.setLoading(false);
                                      toast(language.coverUpdatedSuccessfully);
                                    }
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
                          Observer(builder: (context) {
                            return Positioned(
                              bottom: 0,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 2), shape: BoxShape.circle),
                                    child: editProfileScreenVars.avatarImage == null
                                        ? cachedImage(
                                            editProfileScreenVars.avatarUrl,
                                            height: 100,
                                            width: 100,
                                            fit: BoxFit.cover,
                                          ).cornerRadiusWithClipRRect(100)
                                        : cachedImage(
                                            editProfileScreenVars.avatarImage!.path.validate(),
                                            height: 100,
                                            width: 100,
                                            fit: BoxFit.cover,
                                          ).cornerRadiusWithClipRRect(100),
                                  ),
                                  Positioned(
                                    bottom: -4,
                                    right: -6,
                                    child: GestureDetector(
                                      onTap: () async {
                                        if (!appStore.isLoading) {
                                          FileTypes? file = await showInDialog(
                                            context,
                                            contentPadding: EdgeInsets.symmetric(vertical: 16),
                                            backgroundColor: context.scaffoldBackgroundColor,
                                            title: Text(language.chooseAnAction, style: boldTextStyle()),
                                            builder: (p0) {
                                              return FilePickerDialog(
                                                isSelected: !editProfileScreenVars.avatarUrl.contains(AppImages.defaultAvatarUrl),
                                                image: editProfileScreenVars.avatarImage,
                                                avatarUrl: editProfileScreenVars.avatarUrl,
                                                showRemoveOption: true,
                                              );
                                            },
                                          );

                                          if (file != null) {
                                            if (file == FileTypes.CANCEL) {
                                              ifNotTester(() async {
                                                appStore.setLoading(true);
                                                await deleteMemberAvatarImage(id: userStore.loginUserId).then((value) {
                                                  appStore.setLoading(false);
                                                  editProfileScreenVars.avatarImage = null;
                                                  editProfileScreenVars.avatarUrl = AppImages.defaultAvatarUrl;
                                                  toast(language.profilePictureRemovedSuccessfully);

                                                  //  editProfileScreenVars.avatarUrl = userStore.loginAvatarUrl;
                                                  userStore.loginAvatarUrl = AppImages.defaultAvatarUrl;
                                                  // editProfileScreenVars.avatarImage = null;
                                                }).catchError((e) {
                                                  appStore.setLoading(false);
                                                  editProfileScreenVars.avatarImage = null;
                                                  toast(language.somethingWentWrong);
                                                });
                                              });
                                            } else {
                                              await getImageSource(isCamera: file == FileTypes.CAMERA ? true : false).then((value) async {
                                                appStore.setLoading(false);
                                                if (value != null) editProfileScreenVars.avatarImage = value;

                                                await attachMemberImage(id: userStore.loginUserId, image: editProfileScreenVars.avatarImage).then((value) {
                                                  init();
                                                  if (editProfileScreenVars.cover == null) {}
                                                }).catchError((e) {
                                                  appStore.setLoading(false);
                                                  editProfileScreenVars.avatarImage = null;
                                                });
                                                toast(language.profilePictureUpdatedSuccessfully);
                                              });
                                            }
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
                            );
                          }),
                        ],
                      ),
                      height: 280,
                    ),
                    50.height,
                    AppTextField(
                      enabled: !appStore.isLoading,
                      controller: nameCont,
                      focus: name,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      textFieldType: TextFieldType.NAME,
                      textStyle: boldTextStyle(),
                      decoration: inputDecoration(
                        context,
                        label: language.fullName,
                        labelStyle: secondaryTextStyle(weight: FontWeight.w600),
                      ),
                    ).paddingSymmetric(horizontal: 16),
                    16.height,
                    if (editProfileScreenVars.fieldList.isNotEmpty)
                      Observer(builder: (context) {
                        return ExpansionPanelList.radio(
                          elevation: 0,
                          children: editProfileScreenVars.fieldList.map<ExpansionPanelRadio>(
                            (e) {
                              return ExpansionPanelRadio(
                                value: e.groupId.validate(),
                                canTapOnHeader: true,
                                backgroundColor: context.cardColor,
                                headerBuilder: (BuildContext context, bool isExpanded) {
                                  if (isExpanded) {
                                    group = e;
                                  }
                                  return ListTile(
                                    title: Text(
                                      e.groupName.validate(),
                                      style: primaryTextStyle(color: isExpanded ? context.primaryColor : context.iconColor),
                                    ),
                                  );
                                },
                                body: ExpansionBody(
                                  group: e,
                                  callback: () {
                                    appStore.setLoading(true);
                                  },
                                ),
                              );
                            },
                          ).toList(),
                        );
                      }),
                    60.height,
                  ],
                ),
              ),
              Observer(builder: (context) {
                return LoadingWidget().visible(appStore.isLoading).center();
              }),
            ],
          ),
        ),
      ),
    );
  }
}
