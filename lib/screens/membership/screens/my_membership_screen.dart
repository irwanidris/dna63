import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:socialv/components/base_scaffold_widget.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/pmp_models/membership_model.dart';
import 'package:socialv/network/pmp_repositry.dart';
import 'package:socialv/screens/membership/components/past_invoices_component.dart';
import 'package:socialv/screens/membership/components/plan_subtitle_component.dart';
import 'package:socialv/screens/membership/screens/cancel_membership_screen.dart';
import 'package:socialv/screens/membership/screens/membership_plans_screen.dart';
// TEMP DISABLED: import 'package:socialv/screens/membership/screens/pmp_checkout_screen.dart';
import 'package:socialv/services/in_app_purchase_service.dart';
import 'package:socialv/store/profile_menu_store.dart';
import 'package:socialv/utils/cached_network_image.dart';
import '../../../utils/app_constants.dart';

class MyMembershipScreen extends StatefulWidget {
  const MyMembershipScreen({Key? key}) : super(key: key);

  @override
  State<MyMembershipScreen> createState() => _MyMembershipScreenState();
}

class _MyMembershipScreenState extends State<MyMembershipScreen> {
  ProfileMenuStore myMembershipScreenVars = ProfileMenuStore();
  Offering? offering;
  StoreProduct? activeSubscription;

  @override
  void initState() {
    super.initState();
    getMembership();
  }

  Future<void> getMembership() async {
    appStore.setLoading(true);
    await getMembershipLevelForUser(userId: userStore.loginUserId.validate().toInt()).then((value) async {
      if (value != null) {
        myMembershipScreenVars.hasMembership = true;
        myMembershipScreenVars.membership = MembershipModel.fromJson(value);
        pmpStore.setPmpMembership(myMembershipScreenVars.membership!.id.validate());

        if (appStore.hasInAppSubscription) {
          await getOffers().then((value) async {
            offering!.availablePackages.forEach((element) {
              if (element.storeProduct.identifier == appStore.inAppActiveSubscription) {
                activeSubscription = element.storeProduct;
              }
            });
          });
        }
        appStore.setLoading(false);
      } else {
        myMembershipScreenVars.hasMembership = false;
        pmpStore.setPmpMembership(null);
        appStore.setLoading(false);
      }
    }).catchError((e) {
      myMembershipScreenVars.isError = true;
      appStore.setLoading(false);
      log('Error: ${e.toString()}');
    });
  }

  Future<void> getOffers() async {
    await InAppPurchase.getOfferings().then((value) async {
      if (value != null) {
        offering = value.current;
      }
      appStore.setLoading(false);
    });
  }

  Future<void> downloadMembershipInvoice() async {
    try {
      String membershipId = myMembershipScreenVars.membership!.id.validate().toString();
      String userId = userStore.loginUserId.validate().toString();

      final File? invoiceFile = await InvoiceDownloader.downloadInvoice(
        type: InvoiceType.membership,
        params: {
          'membershipId': membershipId,
          'userId': userId,
        },
      );

      if (invoiceFile != null) {
        print('Membership Invoice downloaded to: ${invoiceFile.path}');
        toast(language.invoiceDownloadedSuccessfully);
      } else {
        toast(language.failedInvoiceDownload);
      }
    } catch (e) {
      toast("Error: $e");
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (appStore.isLoading) appStore.setLoading(false);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: language.membership,
      child: SafeArea(
        child: SingleChildScrollView(
            // padding: EdgeInsets.only(bottom: 5),
            child: Stack(
          children: [
            ///Error widget
            Observer(builder: (_) {
              return NoDataWidget(
                imageWidget: NoDataLottieWidget(),
                title: language.somethingWentWrong,
                onRetry: () {
                  getMembership();
                },
                retryText: '   ${language.clickToRefresh}   ',
              ).paddingTop(120).center().visible(!appStore.isLoading && myMembershipScreenVars.isError);
            }),

            ///Member data widget
            Observer(builder: (_) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: context.width(),
                    color: context.cardColor,
                    padding: EdgeInsets.all(16),
                    child: Text(language.myAccount, style: boldTextStyle(color: context.primaryColor)),
                  ),
                  16.height,
                  Row(
                    children: [
                      cachedImage(userStore.loginAvatarUrl, height: 44, width: 44, fit: BoxFit.cover).cornerRadiusWithClipRRect(22),
                      16.width,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(userStore.loginFullName, style: primaryTextStyle()),
                          4.height,
                          Text(userStore.loginEmail, style: secondaryTextStyle(), overflow: TextOverflow.ellipsis, maxLines: 1),
                        ],
                      ),
                    ],
                  ).paddingSymmetric(horizontal: 16),
                  16.height,
                  Container(
                    width: context.width(),
                    // color: context.cardColor,
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    decoration: boxDecorationDefault(
                      color: appStore.isDarkMode ? context.cardColor : cardLightColor,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                      // boxShadow: defaultBoxShadow(blurRadius: 0.0),
                    ),
                    child: Text(language.myMemberships, style: boldTextStyle(color: context.primaryColor)),
                  ),
                  Observer(builder: (_) {
                    return myMembershipScreenVars.hasMembership
                        ? Container(
                            margin: EdgeInsets.symmetric(horizontal: 16),
                            decoration: boxDecorationDefault(
                              color: appStore.isDarkMode ? context.cardColor : cardLightColor,
                              borderRadius: BorderRadius.only(bottomRight: Radius.circular(10), bottomLeft: Radius.circular(10)),
                              // boxShadow: defaultBoxShadow(blurRadius: 0.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(myMembershipScreenVars.membership!.name.validate(), style: boldTextStyle(weight: FontWeight.w900)),
                                    TextButton(
                                      onPressed: downloadMembershipInvoice,
                                      child: Text(
                                        "${language.downloadInvoice}",
                                        style: boldTextStyle(color: context.primaryColor, size: 14),
                                      ),
                                    ),
                                  ],
                                ),
                                6.height,
                                if (!appStore.hasInAppSubscription) PlanSubtitleComponent(plan: myMembershipScreenVars.membership!),
                                16.height,
                                if (myMembershipScreenVars.membership!.enddate != 0 && !appStore.hasInAppSubscription)
                                  Text(
                                    '${language.validTill} ${timeStampToDateFormat(myMembershipScreenVars.membership!.enddate.validate().toInt())}',
                                    style: secondaryTextStyle(size: 12),
                                  ),
                                if (appStore.hasInAppSubscription && appStore.isFreeSubscription)
                                  Text(
                                    '${language.validTill} ${timeStampToDateFormat(myMembershipScreenVars.membership!.enddate.validate().toInt())}',
                                    style: secondaryTextStyle(size: 12),
                                  ),
                                if (appStore.hasInAppSubscription && !appStore.isFreeSubscription && InAppPurchase.subscriptionExpirationDate.isNotEmpty)
                                  Text(
                                    '${language.validTill} ${DateFormat(DISPLAY_DATE_FORMAT).format(DateTime.parse(InAppPurchase.subscriptionExpirationDate))} ',
                                    style: secondaryTextStyle(size: 12),
                                  ),
                                16.height,
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (myMembershipScreenVars.membership!.isExpired.validate())
                                      appButton(
                                        height: 30,
                                        context: context,
                                        onTap: () {
                                          toast('Checkout temporarily disabled');  // TEMP DISABLED
                                        },
                                        color: appColorPrimary,
                                        text: language.renew,
                                      ).paddingRight(16).expand(),
                                    if (appStore.hasInAppSubscription)
                                      appButton(
                                        height: 30,
                                        context: context,
                                        onTap: () {
                                          MembershipPlansScreen(selectedPlanId: myMembershipScreenVars.membership!.id.validate()).launch(context);
                                        },
                                        text: language.change,
                                      ).paddingRight(16).expand(),
                                    appButton(
                                      height: 30,
                                      context: context,
                                      onTap: () {
                                        CancelMembershipScreen(currentLevelId: myMembershipScreenVars.membership!.id.validate()).launch(context).then((value) {
                                          if (value ?? false) {
                                            myMembershipScreenVars.hasMembership = false;
                                            getMembership();
                                          }
                                        });
                                      },
                                      text: language.cancel,
                                      color: Colors.red,
                                    ).expand(),
                                  ],
                                ),
                                if (appStore.hasInAppSubscription && !appStore.isLoading && !appStore.isFreeSubscription)
                                  appButton(
                                    height: 30,
                                    context: context,
                                    color: greenColor.withValues(alpha: 0.7),
                                    onTap: () {
                                      appStore.setLoading(true);
                                      InAppPurchase.restoreSubscription().then((value) async {
                                        await 1.seconds.delay;
                                        toast(language.subscriptionDetailsRestored);

                                        appStore.setLoading(false);
                                      }).catchError((e) {
                                        toast(e.toString(), print: true);
                                        appStore.setLoading(false);
                                      });
                                    },
                                    text: language.restore,
                                  ).paddingTop(16),
                                8.height,
                              ],
                            ).paddingSymmetric(horizontal: 14),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.asset(
                                ic_crown,
                                height: 60,
                                width: 60,
                                fit: BoxFit.cover,
                                color: context.iconColor,
                              ).center(),
                              8.height,
                              Text(
                                language.noMembershipText,
                                style: secondaryTextStyle(),
                                textAlign: TextAlign.center,
                              ).paddingSymmetric(horizontal: 8),
                              16.height,
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(color: context.primaryColor, borderRadius: radius(4)),
                                child: Text(language.viewAllMembershipOptions, style: primaryTextStyle(color: Colors.white)).center(),
                              ).onTap(() {
                                MembershipPlansScreen().launch(context);
                              }, splashColor: Colors.transparent, highlightColor: Colors.transparent),
                              16.height,
                              if (appStore.hasInAppSubscription && !appStore.isFreeSubscription)
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: greenColor.withValues(alpha: 0.7), borderRadius: radius(4)),
                                  child: Text(language.restorePurchases, style: primaryTextStyle(color: Colors.white)).center(),
                                ).onTap(() {
                                  appStore.setLoading(true);
                                  InAppPurchase.restoreSubscription().then((value) async {
                                    await 1.seconds.delay;
                                    toast(language.subscriptionDetailsRestored);
                                    appStore.setLoading(false);
                                  }).catchError((e) {
                                    toast(e.toString(), print: true);
                                    appStore.setLoading(false);
                                  });
                                }, splashColor: Colors.transparent, highlightColor: Colors.transparent),
                            ],
                          ).paddingSymmetric(horizontal: 16).visible(!myMembershipScreenVars.isError && !appStore.isLoading);
                  }),
                  PastInvoicesComponent(),
                ],
              );
            })
          ],
        )),
      ),
    );
  }
}
