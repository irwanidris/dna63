import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/base_scaffold_widget.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/lms/lms_payment_model.dart';
import 'package:socialv/network/lms_rest_apis.dart';
import 'package:socialv/services/paypal_services.dart';
import 'package:socialv/store/profile_menu_store.dart';
import 'package:socialv/utils/app_constants.dart';
import 'package:socialv/utils/cached_network_image.dart';
import 'lms_order_screen.dart';

class BuyCourseScreen extends StatefulWidget {
  final String? courseImage;
  final String? courseName;
  final String? coursePriseRendered;
  final int? coursePrise;
  final int courseId;
  final VoidCallback? callback;

  const BuyCourseScreen({
    this.courseImage,
    this.courseName,
    this.coursePrise,
    required this.courseId,
    this.coursePriseRendered,
    this.callback,
  });

  @override
  State<BuyCourseScreen> createState() => _BuyCourseScreenState();
}

class _BuyCourseScreenState extends State<BuyCourseScreen> {
  ProfileMenuStore buyCourseScreenVars = ProfileMenuStore();
  TextEditingController note = TextEditingController();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    buyCourseScreenVars.isPaymentGatewayLoading = true;
    await getLmsPayments().then((value) {
      buyCourseScreenVars.paymentGateways.addAll(value);
      if (buyCourseScreenVars.paymentGateways.isNotEmpty) {
        buyCourseScreenVars.selectedPaymentMethod = buyCourseScreenVars.paymentGateways.firstWhere(
          (element) => element.isSelected.validate(),
          orElse: () => buyCourseScreenVars.paymentGateways.first,
        );
      }
      buyCourseScreenVars.isPaymentGatewayLoading = false;
    }).catchError((e) {
      buyCourseScreenVars.isPaymentGatewayLoading = false;
      buyCourseScreenVars.isError = true;
      toast(e.toString(), print: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: language.checkout,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(14),
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(color: context.cardColor, borderRadius: radius(commonRadius)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${language.yourOrder}:', style: boldTextStyle(size: 18)),
                  16.height,
                  Row(
                    children: [
                      cachedImage(widget.courseImage, height: 60, width: 60, fit: BoxFit.cover).cornerRadiusWithClipRRect(commonRadius),
                      16.width,
                      Text(widget.courseName.validate(), style: primaryTextStyle(), maxLines: 2, overflow: TextOverflow.ellipsis).expand(),
                    ],
                  ),
                  Divider(color: context.dividerColor, height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(language.subTotal, style: boldTextStyle(size: 14)),
                      Text(widget.coursePriseRendered.validate(), style: secondaryTextStyle()),
                    ],
                  ),
                  Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(language.total, style: boldTextStyle()),
                      Text(widget.coursePriseRendered.validate(), style: boldTextStyle(size: 20, color: appStore.isDarkMode ? bodyDark : bodyWhite)),
                    ],
                  ),
                ],
              ),
            ),
            AppTextField(
              controller: note,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.done,
              textFieldType: TextFieldType.MULTILINE,
              textStyle: boldTextStyle(),
              maxLength: 250,
              decoration: inputDecorationFilled(
                context,
                fillColor: context.cardColor,
                label: language.noteToAdministrator,
              ),
              minLines: 5,
            ).paddingSymmetric(horizontal: 16),
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(color: context.cardColor, borderRadius: radius(commonRadius)),
              child: Observer(builder: (context) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${language.paymentMethod}:', style: boldTextStyle()),
                    16.height,
                    if (buyCourseScreenVars.isPaymentGatewayLoading)
                      ThreeBounceLoadingWidget().paddingSymmetric(vertical: 16)
                    else if (buyCourseScreenVars.isError)
                      Row(
                        children: [
                          Icon(Icons.payment, color: context.iconColor, size: 20),
                          16.width,
                          Text(language.paymentGatewaysNotFound, style: primaryTextStyle()),
                        ],
                      ).paddingSymmetric(vertical: 16)
                    else if (buyCourseScreenVars.paymentGateways.isEmpty)
                      Row(
                        children: [
                          Icon(Icons.payment, color: context.iconColor, size: 20),
                          16.width,
                          Text(language.paymentGatewaysNotFound, style: primaryTextStyle()),
                        ],
                      ).paddingSymmetric(vertical: 16)
                    else
                      Observer(builder: (context) {
                        return ListView.builder(
                          itemCount: buyCourseScreenVars.paymentGateways.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (ctx, index) {
                            LmsPaymentModel payment = buyCourseScreenVars.paymentGateways[index];
                            return Observer(builder: (context) {
                              return InkWell(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () {
                                  if (buyCourseScreenVars.selectedPaymentMethod != payment) {
                                    buyCourseScreenVars.selectedPaymentMethod = payment;
                                  }
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      buyCourseScreenVars.selectedPaymentMethod!.id == payment.id ? Icons.check_circle_rounded : Icons.circle_outlined,
                                      color: buyCourseScreenVars.selectedPaymentMethod!.id == payment.id ? context.primaryColor : context.iconColor,
                                    ),
                                    16.width,
                                    Text(
                                      payment.description.validate(),
                                      style: primaryTextStyle(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ).expand(),
                                  ],
                                ),
                              ).paddingSymmetric(vertical: 4);
                            });
                          },
                        );
                      }),
                  ],
                );
              }),
            ),
            16.height,
            appButton(
                context: context,
                text: language.placeOrder,
                onTap: () async {
                  if (buyCourseScreenVars.selectedPaymentMethod != null) {
                    if (buyCourseScreenVars.selectedPaymentMethod!.id.validate() == 'paypal') {
                      if (buyCourseScreenVars.selectedPaymentMethod?.appClientId.isEmptyOrNull == true ||
                          buyCourseScreenVars.selectedPaymentMethod?.appClientSecret.isEmptyOrNull == true) {
                        toast('PayPal configuration is incomplete');
                        return;
                      }
                      await PayPalService().paypalCheckOut(
                        context: context,
                        totalAmount: widget.coursePrise.validate().toDouble(),
                        paymentModel: buyCourseScreenVars.selectedPaymentMethod,
                        onComplete: (data) {
                          lmsPlaceOrder(
                            courseIds: [widget.courseId],
                            subTotal: widget.coursePrise.validate().toDouble(),
                            total: widget.coursePrise.validate().toDouble(),
                            paymentMethod: buyCourseScreenVars.selectedPaymentMethod!.id.validate(),
                          ).then((value) {
                            appStore.setLoading(false);
                            finish(context);
                            LmsOrderScreen(orderDetail: value, isFromCheckOutScreen: true).launch(context).then((value) {
                              widget.callback?.call();
                            });
                          }).catchError((e) {
                            toast(e.toString());
                            appStore.setLoading(false); // Changed from true to false
                          });
                        },
                        loaderOnOFF: (loading) {
                          appStore.setLoading(loading); // Properly handle loading state
                        },
                      );
                    } else if (buyCourseScreenVars.selectedPaymentMethod!.id.validate() == 'offline-payment') {
                      appStore.setLoading(true);
                      await lmsPlaceOrder(
                        courseIds: [widget.courseId],
                        subTotal: widget.coursePrise.validate().toDouble(),
                        total: widget.coursePrise.validate().toDouble(),
                        paymentMethod: buyCourseScreenVars.selectedPaymentMethod!.id.validate(),
                      ).then((value) {
                        appStore.setLoading(false);
                        finish(context);
                        LmsOrderScreen(orderDetail: value, isFromCheckOutScreen: true).launch(context).then((value) {
                          widget.callback?.call();
                        });
                      }).catchError((e) {
                        toast(e.toString());
                        appStore.setLoading(true);
                      });
                    } else {
                      toast(language.paymentNotSupportedText);
                    }
                  } else {
                    toast(language.paymentMethodIsRequired);
                  }
                }),
            16.height,
          ],
        ),
      ),
    );
  }
}
