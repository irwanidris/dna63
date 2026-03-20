import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/store/profile_menu_store.dart';
import 'package:socialv/utils/app_constants.dart';

class NotificationSettings extends StatefulWidget {
  const NotificationSettings({Key? key}) : super(key: key);

  @override
  State<NotificationSettings> createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> {
  ProfileMenuStore notificationSettingsVars = ProfileMenuStore();

  @override
  void initState() {
    getNotificationSettings();
    super.initState();
  }

  Future<void> getNotificationSettings() async {
    appStore.setLoading(true);
    notificationSettingsVars.notificationList.clear();
    notificationSettingsVars.isError = false;
    await notificationsSettings().then((value) {
      notificationSettingsVars.notificationList.addAll(value);
      appStore.setLoading(false);
    }).catchError((e) {
      notificationSettingsVars.isError = true;
      appStore.setLoading(false);

      toast(e.toString());
    });
  }

  @override
  void dispose() {
    if (appStore.isLoading) appStore.setLoading(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: Text(
            '${language.notifications.capitalizeFirstLetter()} ${language.settings.capitalizeFirstLetter()}',
            style: boldTextStyle(size: 20),
          ),
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
              ///Error widget
              Observer(builder: (_) {
                return NoDataWidget(
                  imageWidget: NoDataLottieWidget(),
                  title: language.somethingWentWrong,
                ).center().visible(!appStore.isLoading && notificationSettingsVars.isError);
              }),

              ///No data widget
              Observer(builder: (_) {
                return NoDataWidget(
                  imageWidget: NoDataLottieWidget(),
                  title: language.noDataFound,
                ).center().visible(!appStore.isLoading && !notificationSettingsVars.isError && notificationSettingsVars.notificationList.isEmpty);
              }),

              ///List of notification
              Observer(builder: (_) {
                return AnimatedListView(
                  padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  itemCount: notificationSettingsVars.notificationList.length,
                  slideConfiguration: SlideConfiguration(
                    delay: 80.milliseconds,
                    verticalOffset: 300,
                  ),
                  itemBuilder: (context, index) {
                    return Observer(builder: (context) {
                      return SettingItemWidget(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        title: notificationSettingsVars.notificationList[index].name.validate(),
                        titleTextStyle: boldTextStyle(color: appStore.isDarkMode ? bodyDark : bodyWhite, size: 14),
                        trailing: Transform.scale(
                          scale: 0.8,
                          child: CupertinoSwitch(
                            activeTrackColor: context.primaryColor,
                            value: notificationSettingsVars.notificationList[index].value.validate(),
                            onChanged: (val) {
                              notificationSettingsVars.isChange = true;
                              notificationSettingsVars.notificationList[index].value = val;
                            },
                          ),
                        ),
                      );
                    });
                  },
                  shrinkWrap: true,
                  physics: AlwaysScrollableScrollPhysics(),
                ).visible(!appStore.isLoading && !notificationSettingsVars.isError && notificationSettingsVars.notificationList.isNotEmpty);
              }),

              ///Loading widget
              Observer(builder: (context) {
                return LoadingWidget().visible(appStore.isLoading);
              }),
            ],
          ),
        ),
        bottomNavigationBar: notificationSettingsVars.notificationList.isEmpty
            ? Offstage()
            : Observer(builder: (context) {
                return appButton(
                  context: context,
                  text: language.submit.capitalizeFirstLetter(),
                  onTap: () async {
                    if (notificationSettingsVars.isChange) {
                      ifNotTester(() async {
                        if (notificationSettingsVars.notificationList.isNotEmpty) {
                          appStore.setLoading(true);
                          await saveNotificationsSettings(requestList: notificationSettingsVars.notificationList).then((value) {
                            appStore.setLoading(false);
                            toast(value.message);
                            finish(context);
                          }).catchError((e) {
                            appStore.setLoading(false);
                            toast(e.toString());
                          });
                        }
                      });
                    } else {
                      finish(context);
                    }
                  },
                ).paddingAll(16).visible(!appStore.isLoading && !notificationSettingsVars.isError && notificationSettingsVars.notificationList.isNotEmpty);
              }),
      ),
    );
  }
}
