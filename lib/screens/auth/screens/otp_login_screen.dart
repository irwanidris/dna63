import 'dart:convert';

import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/base_scaffold_body.dart';
import 'package:socialv/main.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/auth/screens/complete_profile_screen.dart';
import 'package:socialv/screens/dashboard_screen.dart';
import 'package:socialv/store/app_store.dart';
import 'package:socialv/utils/app_constants.dart';

class OTPLoginScreen extends StatefulWidget {
  final String? deepLink;

  const OTPLoginScreen({this.deepLink});

  @override
  State<OTPLoginScreen> createState() => _OTPLoginScreenState();
}

class _OTPLoginScreenState extends State<OTPLoginScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController numberController = TextEditingController();

  AppStore store = AppStore();

  @override
  void initState() {
    super.initState();
    afterBuildCreated(() => init());
  }

  Future<void> init() async {
    appStore.setLoading(false);
  }

  //region Methods
  Future<void> changeCountry() async {
    showCountryPicker(
      context: context,
      countryListTheme: CountryListThemeData(
        textStyle: secondaryTextStyle(color: textSecondaryColorGlobal),
        bottomSheetHeight: context.height() / 2,
        borderRadius: BorderRadius.all(Radius.circular(14)),
      ),
      showPhoneCode: true,
      onSelect: (Country country) {
        store.selectedCountry = country;
        log(jsonEncode(store.selectedCountry.toJson()));
      },
    );
  }

  Future<void> login({required Map req, bool isSocialLogin = false}) async {
    appStore.setLoading(true);

    hideKeyboard(context);

    await loginUser(request: req, isSocialLogin: isSocialLogin, setLoggedIn: false).then((value) async {
      if (value.isProfileUpdated.validate()) {
        appStore.setLoggedIn(true);
        if (widget.deepLink.validate().isNotEmpty) {
          handleDeepLinking(context: context, deepLink: widget.deepLink.validate());
        } else {
          push(DashboardScreen(), isNewTask: true, pageRouteAnimation: PageRouteAnimation.Slide);
        }
      } else {
        appStore.setLoading(false);
        CompleteProfileScreen(deepLink: widget.deepLink, contact: numberController.text).launch(context);
      }
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  Future<void> sendOTP() async {
    if (numberController.text.trim().isEmpty || numberController.text.length < 10) {
      toast(language.enterValidNumber);
      return;
    }

    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      hideKeyboard(context);

      appStore.setLoading(true);
      toast(language.sendingOtp);

      await loginService.loginWithOTP(
        context,
        phoneNumber: numberController.text.trim(),
        countryCode: store.selectedCountry.phoneCode,
        countryISOCode: store.selectedCountry.countryCode,
        callback: (request) async {
          await login(req: request, isSocialLogin: true);
        },
      ).then((res) async {
        //
      }).catchError(
        (e) {
          appStore.setLoading(false);

          toast(e.toString(), print: true);
        },
      );
    }
  }

  // endregion

  @override
  void dispose() {
    if (appStore.isLoading) appStore.setLoading(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: context.scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.iconColor),
          onPressed: () {
            finish(context);
          },
        ),
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(statusBarIconBrightness: appStore.isDarkMode ? Brightness.light : Brightness.dark, statusBarColor: context.scaffoldBackgroundColor),
      ),
      body: Body(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(language.enterYourPhoneNumber, style: boldTextStyle()),
              16.height,
              Form(
                key: formKey,
                child: AppTextField(
                  controller: numberController,
                  textFieldType: TextFieldType.PHONE,
                  decoration: inputDecorationFilled(
                    context,
                    fillColor: context.cardColor,
                    prefix: GestureDetector(
                      onTap: () => changeCountry(),
                      child: Text('${store.selectedCountry.flagEmoji} +${store.selectedCountry.phoneCode}  ', style: primaryTextStyle()),
                    ),
                    hint: store.selectedCountry.example,
                    hintStyle: secondaryTextStyle(color: appStore.isDarkMode ? bodyDark : bodyWhite),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return language.enterValidNumber;
                    } else if (value.length >= 15) {
                      return language.enterValidNumber;
                    }
                    return null;
                  },
                  autoFocus: true,
                  onFieldSubmitted: (s) {
                    sendOTP();
                  },
                ),
              ),
              30.height,
              AppButton(
                onTap: () {
                  sendOTP();
                },
                text: language.sendOtp,
                color: context.primaryColor,
                textColor: Colors.white,
                width: context.width(),
                elevation: 0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
