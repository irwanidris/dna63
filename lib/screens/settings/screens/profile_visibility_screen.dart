import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/members/profile_visibility_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/store/profile_menu_store.dart';
import 'package:socialv/utils/app_constants.dart';

import '../../../models/general_settings_model.dart';

class ProfileVisibilityScreen extends StatefulWidget {
  const ProfileVisibilityScreen({Key? key}) : super(key: key);

  @override
  State<ProfileVisibilityScreen> createState() => _ProfileVisibilityScreenState();
}

class _ProfileVisibilityScreenState extends State<ProfileVisibilityScreen> {
  ProfileMenuStore profileVisibilityScreenVars = ProfileMenuStore();

  @override
  void initState() {
    getFiledList();
    super.initState();
  }

  Future<void> getFiledList() async {
    profileVisibilityScreenVars.profileList.clear();

    appStore.setLoading(true);

    await getProfileVisibility().then((value) {
      appStore.setLoading(false);
      profileVisibilityScreenVars.profileList.addAll(value);
      profileVisibilityScreenVars.isError = false;
      appStore.setProfileVisibility(profileVisibilityScreenVars.profileList);
    }).catchError((e) {
      profileVisibilityScreenVars.isError = true;
      profileVisibilityScreenVars.errorMSG = e.toString();
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
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
        title: Text(language.profileVisibility, style: boldTextStyle(size: 20)),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.iconColor),
          onPressed: () {
            finish(context);
          },
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            AnimatedScrollView(children: [
              /// error widget
              Observer(builder: (context) {
                return profileVisibilityScreenVars.isError && !appStore.isLoading
                    ? SizedBox(
                        height: context.height() * 0.8,
                        child: NoDataWidget(
                          imageWidget: NoDataLottieWidget(),
                          title: language.somethingWentWrong,
                          subTitle: profileVisibilityScreenVars.errorMSG,
                        ).center(),
                      )
                    : Offstage();
              }),

              /// empty list widget
              Observer(builder: (context) {
                return profileVisibilityScreenVars.profileList.isEmpty && !profileVisibilityScreenVars.isError && !appStore.isLoading
                    ? SizedBox(
                        height: context.height() * 0.8,
                        child: NoDataWidget(
                          imageWidget: NoDataLottieWidget(),
                          title: language.noDataFound,
                        ).center(),
                      )
                    : Offstage();
              }),

              /// list widget

              Observer(builder: (context) {
                return profileVisibilityScreenVars.profileList.isNotEmpty && !profileVisibilityScreenVars.isError
                    ? ListView.builder(
                        itemCount: profileVisibilityScreenVars.profileList.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (ctx, index) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: context.width(),
                                color: context.cardColor,
                                padding: EdgeInsets.all(16),
                                child: Text(profileVisibilityScreenVars.profileList[index].groupName.validate().toUpperCase(), style: boldTextStyle(color: context.primaryColor)),
                              ),
                              ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                itemCount: profileVisibilityScreenVars.profileList[index].fields.validate().length,
                                itemBuilder: (context, i) {
                                  return VisibilityComponent(
                                    field: profileVisibilityScreenVars.profileList[index].fields.validate()[i],
                                    groupIndex: index,
                                    fieldIndex: i,
                                    type: profileVisibilityScreenVars.profileList[index].groupType.validate(),
                                  );
                                },
                                shrinkWrap: true,
                              ),
                            ],
                          );
                        },
                      )
                    : Offstage();
              }),
            ]),
            Observer(
              builder: (_) {
                if (appStore.isLoading) {
                  return LoadingWidget();
                } else {
                  return Offstage();
                }
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Observer(builder: (context) {
        return profileVisibilityScreenVars.profileList.isEmpty
            ? Offstage()
            : appButton(
                context: context,
                text: language.submit.capitalizeFirstLetter(),
                onTap: () async {
                  ifNotTester(() {
                    if (appStore.profileVisibility.isNotEmpty) {
                      appStore.profileVisibility.forEach((element) {
                        log('${element.groupName} ${element.isChange}');
                        if (element.isChange) {
                          appStore.setLoading(true);
                          profileVisibilityScreenVars.futures.add(saveProfileVisibility(request: element.toJson()).then((value) {
                            appStore.setLoading(false);
                            profileVisibilityScreenVars.messages.add('${element.groupName} Settings');
                          }).catchError((e) {
                            appStore.setLoading(false);
                            profileVisibilityScreenVars.messages.add('Couldn\'t update ${element.groupName}');
                            toast(e.toString());
                          }));
                        }
                      });
                      Future.wait(profileVisibilityScreenVars.futures).then((results) {
                        // This will be called after all the API calls are completed
                        String finalMessage = profileVisibilityScreenVars.messages.join(', ');
                        toast("Updated " + finalMessage);
                        finish(context);
                      }).catchError((e) {
                        toast('Error : $e', print: true);
                      });
                    }
                  });
                },
              ).paddingAll(16);
      }),
    );
  }
}

class VisibilityComponent extends StatefulWidget {
  final Field field;
  final int fieldIndex;
  final int groupIndex;
  final String type;

  VisibilityComponent({required this.field, required this.groupIndex, required this.fieldIndex, required this.type});

  @override
  State<VisibilityComponent> createState() => _VisibilityComponentState();
}

class _VisibilityComponentState extends State<VisibilityComponent> {
  ProfileMenuStore visibilityComponentVars = ProfileMenuStore();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    visibilityComponentVars.dropdownValue = widget.type == ProfileVisibilityTypes.dynamicSettings
        ? appStore.visibilities.validate().firstWhere((element) => element.id == widget.field.level)
        : appStore.accountPrivacyVisibility.validate().firstWhere((element) => element.id == widget.field.level);

    if (widget.type == ProfileVisibilityTypes.dynamicSettings) {
      appStore.accountPrivacyVisibility.forEach((element) {
        if (element.label == widget.field.visibility) {
          visibilityComponentVars.dropdownValue = element;
        }
      });
    } else {
      appStore.visibilities.forEach((element) {
        if (element.label == widget.field.visibility) {
          visibilityComponentVars.dropdownValue = element;
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.field.canChange.validate()) {
      return Row(
        children: [
          Text(widget.field.name.validate(), style: primaryTextStyle(color: appStore.isDarkMode ? bodyDark : bodyWhite)).expand(),
          widget.type == ProfileVisibilityTypes.dynamicSettings
              ? IgnorePointer(
                  ignoring: appStore.isLoading,
                  child: Container(
                    height: 40,
                    child: Observer(builder: (context) {
                      return DropdownButton<Visibilities>(
                        borderRadius: BorderRadius.circular(commonRadius),
                        value: visibilityComponentVars.dropdownValue,
                        isExpanded: true,
                        icon: Icon(Icons.arrow_drop_down, color: appStore.isDarkMode ? bodyDark : bodyWhite),
                        elevation: 16,
                        underline: Container(height: 2, color: appColorPrimary),
                        style: primaryTextStyle(),
                        onChanged: (Visibilities? newValue) {
                          visibilityComponentVars.dropdownValue = newValue!;
                          appStore.updateProfileVisibility(widget.groupIndex, widget.fieldIndex, newValue.id.toString());
                        },
                        items: appStore.visibilities.validate().map<DropdownMenuItem<Visibilities>>((e) {
                          return DropdownMenuItem<Visibilities>(
                            value: e,
                            child: Text('${e.label.validate()}', overflow: TextOverflow.ellipsis, maxLines: 1),
                          );
                        }).toList(),
                      ).paddingSymmetric(horizontal: 16);
                    }),
                  ),
                ).expand()
              : IgnorePointer(
                  ignoring: appStore.isLoading,
                  child: Container(
                    height: 40,
                    child: Observer(builder: (context) {
                      return DropdownButton<Visibilities>(
                        borderRadius: BorderRadius.circular(commonRadius),
                        value: visibilityComponentVars.dropdownValue,
                        isExpanded: true,
                        icon: Icon(Icons.arrow_drop_down, color: appStore.isDarkMode ? bodyDark : bodyWhite),
                        elevation: 16,
                        underline: Container(height: 2, color: appColorPrimary),
                        style: primaryTextStyle(),
                        onChanged: (Visibilities? newValue) {
                          visibilityComponentVars.dropdownValue = newValue!;
                          appStore.updateProfileVisibility(widget.groupIndex, widget.fieldIndex, newValue.id.toString());
                        },
                        items: appStore.accountPrivacyVisibility.map<DropdownMenuItem<Visibilities>>((e) {
                          return DropdownMenuItem<Visibilities>(
                            value: e,
                            child: Text('${e.label.validate()}', overflow: TextOverflow.ellipsis, maxLines: 1),
                          );
                        }).toList(),
                      ).paddingSymmetric(horizontal: 16);
                    }),
                  ),
                ).expand(),
        ],
      );
    } else {
      return Row(
        children: [
          Text(widget.field.name.validate(), style: primaryTextStyle(color: appStore.isDarkMode ? bodyDark : bodyWhite)).expand(),
          Text(
            widget.field.visibility.validate(),
            style: primaryTextStyle(fontStyle: FontStyle.italic, color: textSecondaryColor),
          ).paddingSymmetric(horizontal: 16, vertical: 8).expand(),
        ],
      );
    }
  }
}
