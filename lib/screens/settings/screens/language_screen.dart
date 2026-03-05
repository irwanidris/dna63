import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/main.dart';
import 'package:socialv/store/profile_menu_store.dart';
import 'package:socialv/utils/app_constants.dart';

class LanguageScreen extends StatefulWidget {
  @override
  _LanguageScreenState createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  ProfileMenuStore languageScreenVars = ProfileMenuStore();

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    localeLanguageList.forEach((element) {
      if (appStore.selectedLanguage == element.languageCode.validate()) {
        languageScreenVars.selectedLanguageIndex = localeLanguageList.indexOf(element);
      }
    });
  }

  Color? getSelectedColor(LanguageDataModel data) {
    if (appStore.selectedLanguage == data.languageCode.validate() && appStore.isDarkMode) {
      return Colors.white54;
    } else if (appStore.selectedLanguage == data.languageCode.validate() && !appStore.isDarkMode) {
      return appColorPrimary.withAlpha(40);
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(language.appLanguage, style: boldTextStyle(size: 20)),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.iconColor),
          onPressed: () {
            finish(context);
          },
        ),
      ),
      body: ListView.builder(
        itemCount: localeLanguageList.length,
        itemBuilder: (context, index) {
          LanguageDataModel data = localeLanguageList[index];
          return Observer(
            builder: (context) {
              return Container(
                padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
                color: appStore.selectedLanguage == data.languageCode.validate() ? context.cardColor : context.scaffoldBackgroundColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset(data.flag.validate(), width: 20),
                        16.width,
                        Observer(builder: (context) {
                          return Text(
                            '${data.name.validate()}',
                            style: boldTextStyle(
                                size: 14,
                                color: languageScreenVars.selectedLanguageIndex == index
                                    ? context.iconColor
                                    : appStore.isDarkMode
                                        ? bodyDark
                                        : bodyWhite),
                          );
                        }),
                      ],
                    ),
                    Observer(builder: (context) {
                      return Icon(Icons.check, color: appColorPrimary).visible(appStore.selectedLanguage == data.languageCode.validate());
                    })
                  ],
                ).onTap(
                  () async {
                    languageScreenVars.selectedLanguageIndex = index;
                    setValue(SELECTED_LANGUAGE_CODE, data.languageCode);
                    selectedLanguageDataModel = data;
                    appStore.setLanguage(data.languageCode!);
                    finish(context);
                  },
                ),
              );
            }
          );
        },
      ),
    );
  }
}
