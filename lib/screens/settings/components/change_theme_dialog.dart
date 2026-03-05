import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/main.dart';

import '../../../utils/app_constants.dart';

class ChangeThemeDialog extends StatelessWidget {
  final double? width;
  final VoidCallback voidCallback;

  const ChangeThemeDialog({this.width, required this.voidCallback});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(defaultRadius)),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 0,
      backgroundColor: context.scaffoldBackgroundColor,
      insetAnimationCurve: Curves.linear,
      insetAnimationDuration: 0.seconds,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            width: width,
            decoration: BoxDecoration(color: context.primaryColor),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(language.appTheme, style: boldTextStyle(color: Colors.white, size: 20)),
                Image.asset(ic_close_square, height: 24, width: 24, fit: BoxFit.cover, color: Colors.white).onTap(() {
                  voidCallback.call();
                }, splashColor: Colors.transparent, highlightColor: Colors.transparent)
              ],
            ),
          ),
          RadioGroup<int>(
            groupValue: getIntAsync(SharePreferencesKey.APP_THEME),
            onChanged: (val) async {
              if (val == AppThemeMode.ThemeModeSystem) {
                appStore.toggleDarkMode(value: MediaQuery.of(context).platformBrightness == Brightness.dark);
                await setValue(SharePreferencesKey.APP_THEME, AppThemeMode.ThemeModeSystem);
                await setValue(SharePreferencesKey.IS_DARK_MODE, MediaQuery.of(context).platformBrightness == Brightness.dark);
              } else if (val == AppThemeMode.ThemeModeDark) {
                appStore.toggleDarkMode(value: true);
                await setValue(SharePreferencesKey.APP_THEME, AppThemeMode.ThemeModeDark);
                await setValue(SharePreferencesKey.IS_DARK_MODE, true);
              } else if (val == AppThemeMode.ThemeModeLight) {
                appStore.toggleDarkMode(value: false);
                await setValue(SharePreferencesKey.APP_THEME, AppThemeMode.ThemeModeLight);
                await setValue(SharePreferencesKey.IS_DARK_MODE, false);
              }
              voidCallback.call();
            },
            child: Column(
              children: [
                RadioListTile<int>(
                  value: AppThemeMode.ThemeModeSystem,
                  title: Text(language.systemDefault, style: primaryTextStyle()),
                ),
                RadioListTile<int>(
                  value: AppThemeMode.ThemeModeDark,
                  title: Text(language.darkMode, style: primaryTextStyle()),
                ),
                RadioListTile<int>(
                  value: AppThemeMode.ThemeModeLight,
                  title: Text(language.lightMode, style: primaryTextStyle()),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
