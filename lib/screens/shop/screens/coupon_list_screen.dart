import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/woo_commerce/coupon_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/store/profile_menu_store.dart';
import 'package:socialv/utils/app_constants.dart';

class CouponListScreen extends StatefulWidget {
  const CouponListScreen({Key? key}) : super(key: key);

  @override
  State<CouponListScreen> createState() => _CouponListScreenState();
}

class _CouponListScreenState extends State<CouponListScreen> {
  ProfileMenuStore couponListScreenVars = ProfileMenuStore();

  int mPage = 1;
  bool mIsLastPage = false;

  @override
  void initState() {
    couponList();

    setStatusBarColor(Colors.transparent);
    super.initState();
  }

  Future<void> couponList() async {
    appStore.setLoading(true);

    await getCouponsList().then((value) {
      if (mPage == 1) couponListScreenVars.couponsList.clear();

      mIsLastPage = value.length != 20;
      couponListScreenVars.couponsList.addAll(value);
      appStore.setLoading(false);
    }).catchError((e) {
      couponListScreenVars.isError = true;
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  Color getColor(bool isExpired) {
    if (isExpired)
      return appStore.isDarkMode ? bodyDark : bodyWhite;
    else
      return appStore.isDarkMode?bodyWhite:blackColor;
  }

  Color getCardColor(bool isExpired) {
    if (isExpired)
      return appStore.isDarkMode ? bodyDark : bodyWhite;
    else
      return appColorPrimary;
  }

  @override
  void dispose() {
    appStore.setLoading(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        ///List of coupons
        Observer(builder: (_) {
          return Container(
            padding: EdgeInsets.only(top: 16, left: 16, right: 16),
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                 language.allCoupons,
                  style: boldTextStyle(size: 18),
                ),
                16.height,
                AnimatedListView(
                  shrinkWrap: true,
                  slideConfiguration: SlideConfiguration(
                    delay: 80.milliseconds,
                    verticalOffset: 300,
                  ),
                  physics: AlwaysScrollableScrollPhysics(),
                  // padding: EdgeInsets.only(left: 16, right: 16, bottom: 50),
                  itemCount: couponListScreenVars.couponsList.length,
                  itemBuilder: (context, index) {
                    CouponModel coupon = couponListScreenVars.couponsList[index];
                    bool isExpired = false;
                    if (coupon.dateExpires.validate().isNotEmpty) {
                      DateTime input = DateFormat(DATE_FORMAT_2).parse(coupon.dateExpires.validate(), true);
                      isExpired = input.compareTo(DateTime.now()) <= 0;
                    }

                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      decoration: boxDecorationDefault(color: context.scaffoldBackgroundColor, borderRadius: radius(commonRadius), border: Border.all(color: Colors.grey.shade200, width: 1)),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    coupon.discountType != 'percent' ? 'Extra ${appStore.wooCurrency}${coupon.amount.toDouble().round()} ${language.off}' : 'Extra ${coupon.amount.toDouble().round()}% ${language.off}',
                                    style: boldTextStyle(size: 16, color: getColor(isExpired)),
                                  ),

                                  /// add apply button if not expired
                                  if (!isExpired)
                                    TextButton(
                                        onPressed: () {
                                          toast(language.copiedToClipboard);
                                          Clipboard.setData(new ClipboardData(text: coupon.code.validate()));
                                          finish(context, coupon.code.validate());
                                        },
                                        child: Text(
                                          language.applyCoupon,
                                          style: boldTextStyle(color: appColorPrimary),
                                        ))
                                ],
                              ),
                              if (coupon.description.validate().isNotEmpty) ...[
                                Text(coupon.description.validate(), style: primaryTextStyle()),
                                8.height,
                              ],
                              Row(
                                children: [
                                  InkWell(
                                    child: DottedBorderWidget(
                                      child: Container(
                                        decoration: BoxDecoration(color: context.cardColor, borderRadius: radius(commonRadius)),
                                        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                                        child: Text(
                                          coupon.code.validate(),
                                          style: boldTextStyle(color: getCardColor(isExpired)),
                                        ),
                                      ),
                                      radius: commonRadius,
                                      color: getCardColor(isExpired),
                                    ),
                                    onTap: () {
                                      if (!isExpired) {
                                        toast(language.copiedToClipboard);
                                        Clipboard.setData(new ClipboardData(text: coupon.code.validate()));
                                      }
                                    },
                                  ),
                                ],
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              ),
                              16.height,
                              if (coupon.dateExpires.validate().isNotEmpty) ...[
                                Row(
                                  children: [
                                    Text('${language.expiresOn} ${formatDate(coupon.dateExpires.validate())}', style: secondaryTextStyle()),
                                    Container(
                                      width: 80,
                                      padding: EdgeInsets.symmetric(vertical: 8),
                                      child: Text(language.expired, style: boldTextStyle()).center(),
                                      decoration: BoxDecoration(color: appStore.isDarkMode ? bodyDark.withValues(alpha: 0.2) : bodyWhite.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(15)),
                                    ).visible(isExpired),
                                  ],
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                ),
                                8.height,
                              ]
                            ],
                          ).paddingOnly(left: 16, right: 16),
                        ],
                      ),
                    );
                  },
                  onNextPage: () {
                    if (!mIsLastPage) {
                      mPage++;
                      couponList();
                    }
                  },
                ).visible(couponListScreenVars.couponsList.isNotEmpty && !appStore.isLoading && !couponListScreenVars.isError).expand(),
              ],
            ),
          );
        }),

        ///Error widget
        Observer(builder: (_) {
          return NoDataWidget(
            imageWidget: NoDataLottieWidget(),
            title: language.somethingWentWrong,
            onRetry: () {
              couponListScreenVars.isError = false;
              mPage = 1;
              couponList();
            },
            retryText: '   ${language.clickToRefresh}   ',
          ).center().visible(!appStore.isLoading && couponListScreenVars.isError);
        }),

        ///No data widget
        Observer(builder: (_) {
          return NoDataWidget(
            imageWidget: NoDataLottieWidget(),
            title: language.noDataFound,
            onRetry: () {
              couponListScreenVars.isError = false;
              mPage = 1;
              couponList();
            },
            retryText: '   ${language.clickToRefresh}   ',
          ).center().visible(!appStore.isLoading && !couponListScreenVars.isError && couponListScreenVars.couponsList.isEmpty);
        }),

        ///Loading widget
        Observer(
          builder: (_) {
            if (appStore.isLoading) {
              return Container(
                padding: EdgeInsets.only(top: 16, left: 16, right: 16),
                decoration: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Align(
                  alignment: mPage != 1 ? Alignment.bottomCenter : Alignment.center,
                  child: LoadingWidget(isBlurBackground: mPage == 1),
                ),
              );
            } else {
              return Offstage();
            }
          },
        ),
      ],
    );
  }
}
