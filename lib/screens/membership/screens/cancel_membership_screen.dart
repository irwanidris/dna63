import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/base_scaffold_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/network/pmp_repositry.dart';
import 'package:socialv/screens/dashboard_screen.dart';
import 'package:socialv/services/in_app_purchase_service.dart';
import 'package:socialv/store/profile_menu_store.dart';
import 'package:socialv/utils/app_constants.dart';
import 'package:socialv/utils/cached_network_image.dart';

class CancelMembershipScreen extends StatefulWidget {
  final String currentLevelId;

  const CancelMembershipScreen({required this.currentLevelId});

  @override
  State<CancelMembershipScreen> createState() => _CancelMembershipScreenState();
}

class _CancelMembershipScreenState extends State<CancelMembershipScreen> {
  ProfileMenuStore cancelMembershipScreenVars = ProfileMenuStore();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: language.cancelMembership,
      onBack: () {
        finish(context, cancelMembershipScreenVars.isCancelled);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          16.height,
          cachedImage(
            ic_shield_fail,
            color: context.primaryColor,
            height: 100,
            width: 100,
          ),
          Observer(builder: (_) {
            return cancelMembershipScreenVars.isCancelled
                ? Column(
                    children: [
                      Container(
                        margin: EdgeInsets.all(16),
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: context.primaryColor.withAlpha(30),
                          border: Border(left: BorderSide(color: context.primaryColor, width: 2)),
                        ),
                        child: Text(
                          appStore.hasInAppSubscription && !appStore.isFreeSubscription ? language.yourMembershipCancellationWill : language.yourMembershipCancelled,
                          style: primaryTextStyle(color: context.primaryColor),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      16.height,
                      InkWell(
                        onTap: () {
                          DashboardScreen().launch(context, isNewTask: true);
                        },
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(color: context.primaryColor, borderRadius: radius(4)),
                          child: Text(language.clickHereToVisitHomePage, style: secondaryTextStyle(color: Colors.white)).center(),
                        ),
                      ).paddingSymmetric(horizontal: 16),
                      16.height,
                    ],
                  )
                : Column(
                    children: [
                      Text(
                        language.cancelMembershipConfirmation,
                        style: primaryTextStyle(color: appStore.isDarkMode ? bodyDark : bodyWhite),
                        textAlign: TextAlign.center,
                      ),
                      16.height,
                      InkWell(
                        onTap: () {
                          ifNotTester(() {
                            if (appStore.hasInAppSubscription && !appStore.isFreeSubscription) {
                              InAppPurchase.cancelSubscription(context).then((value) async {
                                await 2.seconds.delay;
                                cancelMembershipScreenVars.isCancelled = true;
                                appStore.setLoading(false);
                              });
                            } else {
                              appStore.setLoading(true);
                              cancelMembershipLevel(levelId: widget.currentLevelId).then((value) {
                                pmpStore.setPmpMembership(null);
                                setRestrictions();
                                appStore.setFreeSubscription(false);
                                cancelMembershipScreenVars.isCancelled = true;
                                appStore.setLoading(false);
                              }).catchError((e) {
                                appStore.setLoading(false);
                                toast(e.toString());
                              });
                            }
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.red, borderRadius: radius(4)),
                          child: Text(language.yesCancelThisMembership, style: secondaryTextStyle(color: Colors.white)).center(),
                        ),
                      ).paddingSymmetric(horizontal: 16),
                      8.height,
                      InkWell(
                        onTap: () {
                          finish(context);
                        },
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(color: context.primaryColor, borderRadius: radius(4)),
                          child: Text(language.noKeepThisMembership, style: secondaryTextStyle(color: Colors.white)).center(),
                        ),
                      ).paddingAll(16),
                      16.height,
                    ],
                  );
          })
        ],
      ).paddingAll(5),
    );
  }
}
