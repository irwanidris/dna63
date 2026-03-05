import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/screens/auth/components/login_in_component.dart';
import 'package:socialv/screens/auth/components/sign_up_component.dart';
import 'package:socialv/store/app_store.dart';

import '../../../utils/app_constants.dart';

class SignInScreen extends StatefulWidget {
  final String? deepLink;

  const SignInScreen({this.deepLink});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  AppStore store = AppStore();

  @override
  void initState() {
    super.initState();

    appStore.setLoading(false);
    setStatusBarColorBasedOnTheme();
  }

  Widget getFragment() {
    if (store.selectedSignInIndex == 0) {
      return LoginInComponent(
        deepLink: widget.deepLink,
        callback: () {
          store.selectedSignInIndex = 1;
        },
      );
    } else {
      return SignUpComponent(
        deepLink: widget.deepLink,
        callback: () {
          store.selectedSignInIndex = 0;
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            GestureDetector(
              onHorizontalDragUpdate: (details) {
                int sensitivity = 8;
                if (details.delta.dx > sensitivity) {
                  store.selectedSignInIndex = 0;
                } else if (details.delta.dx < -sensitivity) {
                  store.selectedSignInIndex = 1;
                }
              },
              child: CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      children: [
                        SizedBox(height: context.statusBarHeight + 50),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(APP_ICON, height: 40, width: 40, fit: BoxFit.cover),
                            8.width,
                            Text(APP_NAME, style: boldTextStyle(color: context.primaryColor, size: 28)),
                          ],
                        ),
                        40.height,
                        headerContainer(
                          context: context,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Observer(builder: (context) {
                                return TextButton(
                                  child: Text(language.login.toUpperCase(), style: boldTextStyle(color: store.selectedSignInIndex == 0 ? Colors.white : Colors.white54)),
                                  onPressed: () {
                                    store.selectedSignInIndex = 0;
                                  },
                                );
                              }),
                              Observer(builder: (context) {
                                return TextButton(
                                  child: Text(language.signUp.toUpperCase(), style: boldTextStyle(color: store.selectedSignInIndex == 1 ? Colors.white : Colors.white54)),
                                  onPressed: () {
                                    store.selectedSignInIndex = 1;
                                  },
                                );
                              }),
                            ],
                          ),
                        ),
                        Observer(builder: (context) {
                          return getFragment().expand();
                        }),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Observer(builder: (_) => LoadingWidget().visible(appStore.isLoading).center())
          ],
        ),
      ),
    );
  }
}
