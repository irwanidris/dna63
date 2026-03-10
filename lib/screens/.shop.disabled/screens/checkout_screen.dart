import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/woo_commerce/cart_item_model.dart';
import 'package:socialv/models/woo_commerce/cart_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/shop/components/cart_coupons_component.dart';
import 'package:socialv/screens/shop/components/price_widget.dart';
import 'package:socialv/screens/shop/screens/edit_shop_details_screen.dart';
import 'package:socialv/screens/shop/screens/order_detail_screen.dart';
import 'package:socialv/services/razor_pay_services.dart';
import 'package:socialv/store/shop_store.dart';
import 'package:socialv/utils/app_constants.dart';
import 'package:socialv/utils/cached_network_image.dart';
import 'package:socialv/services/stripe_services.dart';

class CheckoutScreen extends StatefulWidget {
  final CartModel cartDetails;

  CheckoutScreen({required this.cartDetails});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  ShopStore checkoutScreenVars = ShopStore();
  TextEditingController orderNotesController = TextEditingController();

  @override
  void initState() {
    checkoutScreenVars.cartCheckout = widget.cartDetails;
    shopStore.billingAddress = widget.cartDetails.billingAddress!;
    super.initState();
    init();
    getCart();
  }

  Future<void> init() async {
    checkoutScreenVars.isPaymentGatewayLoading = true;

    await getPaymentMethods().then((value) {
      checkoutScreenVars.paymentGateways.clear();
      value.forEach((element) {
        if ((element.id == "stripe" || element.id == "razorpay" || element.id == 'cod') && (element.enabled == true) && (element.settings != null)) {
          checkoutScreenVars.paymentGateways.add(element);
        }
      });
      checkoutScreenVars.selectedPaymentMethod = value.firstWhere((element) => element.id == 'cod');
      checkoutScreenVars.isPaymentGatewayLoading = false;
    }).catchError((e) {
      checkoutScreenVars.isPaymentGatewayLoading = false;
      toast(e.toString(), print: true);
    });
  }
  String formatCurrency(num rawAmount, int minorUnit) {
    double normalized = rawAmount / pow(10, minorUnit);

    // force fixed decimal places
    String formatted = normalized.toStringAsFixed(minorUnit);

    return formatted;
  }

  Future<void> getCart({String? orderBy}) async {
    appStore.setLoading(true);

    await getCartDetails().then((value) {
      checkoutScreenVars.cartCheckout = value;
      shopStore.billingAddress = value.billingAddress!;
      appStore.setLoading(false);
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  Future<void> placeOrder() async {
    ifNotTester(() async {
      if (checkoutScreenVars.selectedPaymentMethod!.id == 'cod') {
        // Handle free plan processing
        Map request = {
          "payment_method": checkoutScreenVars.selectedPaymentMethod!.id,
          "payment_method_title": checkoutScreenVars.selectedPaymentMethod!.title,
          "set_paid": false,
          'customer_id': userStore.loginUserId,
          'status': "pending",
          "billing": checkoutScreenVars.cartCheckout!.billingAddress!.toJson(),
          "shipping": checkoutScreenVars.cartCheckout!.shippingAddress!.toJson(),
          "line_items": checkoutScreenVars.cartCheckout!.items!.map((e) {
            return {"product_id": e.id, "quantity": e.quantity};
          }).toList(),
          "shipping_lines": [],
          "coupon_lines": checkoutScreenVars.cartCheckout!.coupons.validate().map((e) => {"code": e.code}).toList(),
          "customer_note": orderNotesController.text.trim(),
        };

        appStore.setLoading(true);

        await createOrder(request: request).then((value) async {
          if (orderNotesController.text.isNotEmpty) {
            Map noteRequest = {"note": orderNotesController.text.trim(), "customer_note": true};
            await createOrderNotes(request: noteRequest, orderId: value.id.validate()).then((value) {}).catchError((e) {
              log('Order Note Error: ${e.toString()}');
            });
          }

          ///  Clear cart
          clearCart().then((value) {
            log("Removed products from cart.");
          });

          appStore.setCartCount(0);

          checkoutScreenVars.cartCheckout!.coupons!.forEach((coupon) {
            removeCoupon(code: coupon.code.validate()).then((value) {
              log('Coupon removed');
            }).catchError((e) {
              log('error remove coupon: ${e.toString()}');
            });
          });

          appStore.setLoading(false);
          finish(context);
          finish(context);
          shopStore.cartItemIndexList.clear();
          OrderDetailScreen(orderDetails: value).launch(context);
        }).catchError((e) {
          appStore.setLoading(false);
          toast(e.toString(), print: true);
        });

        appStore.setLoading(true);
      } else {
        var total = formatCurrency(
          checkoutScreenVars.cartCheckout!.totals!.totalPrice.validate().toDouble(),
          checkoutScreenVars.cartCheckout!.totals!.currencyMinorUnit.validate().toInt(), // ✅ use minor_unit
        );
        if (checkoutScreenVars.selectedPaymentMethod!.id.validate() == PaymentIds.stripe) {


          await stripeServices.init(
            discountCode: '',
            context: context,
            stripePaymentPublishKey: checkoutScreenVars.selectedPaymentMethod!.settings!.testMode!.isTestMode != true
                ? checkoutScreenVars.selectedPaymentMethod!.settings!.testPublishKey!.testKey.validate()
                : checkoutScreenVars.selectedPaymentMethod!.settings!.publishKey!.key.validate(),
            totalAmount: total.toDouble(),
            stripeURL: "https://api.stripe.com/v1/payment_intents",
            stripePaymentKey: checkoutScreenVars.selectedPaymentMethod!.settings!.testMode!.isTestMode != true
                ? checkoutScreenVars.selectedPaymentMethod!.settings!.testSecretKey!.testKey.validate()
                : checkoutScreenVars.selectedPaymentMethod!.settings!.secretKey!.key.validate(),
            levelId: "",
            isShop: true,
            mode: 'test',
            orderNote: orderNotesController.text.trim(),
            billingAddress: checkoutScreenVars.cartCheckout!.billingAddress!.toJson(),
            shippingAddress: checkoutScreenVars.cartCheckout!.shippingAddress!.toJson(),
            lineItems: checkoutScreenVars.cartCheckout!.items!.map((e) {
              return {"product_id": e.id, "quantity": e.quantity};
            }).toList(),
            coupon: checkoutScreenVars.cartCheckout!.coupons.validate().map((e) => {"code": e.code}).toList(),
          );
          await 1.seconds.delay;
          stripeServices.stripePay();
          appStore.setLoading(false);

          shopStore.cartItemIndexList.clear();

          ///  Clear cart
          clearCart().then((value) {
            log("Removed products from cart.");
          });

          appStore.setCartCount(0);
          checkoutScreenVars.cartCheckout!.coupons!.forEach((coupon) {
            removeCoupon(code: coupon.code.validate()).then((value) {
              log('Coupon removed');
            }).catchError((e) {
              log('error remove coupon: ${e.toString()}');
            });
          });
        } else if (checkoutScreenVars.selectedPaymentMethod!.id.validate() == PaymentIds.razorpay) {
          appStore.setLoading(true);
          final settings = checkoutScreenVars.selectedPaymentMethod?.settings;


          await RazorPayServices.init(
              disCode: '',
              razorKey: settings!.razorpayKey!.key!,
              amount: total.toDouble(),
              planId: "",
              ctx: context,
              paymentMode: "testing",
              url: "https://api.razorpay.com/v1/payments",
              secret: settings.razorpaySecretKey!.key!,
              orderNote: orderNotesController.text.trim(),
              billingAddress: checkoutScreenVars.cartCheckout!.billingAddress!.toJson(),
              shippingAddress: checkoutScreenVars.cartCheckout!.shippingAddress!.toJson(),
              lineItems: checkoutScreenVars.cartCheckout!.items!.map((e) {
                return {"product_id": e.id, "quantity": e.quantity};
              }).toList(),
              coupon: checkoutScreenVars.cartCheckout!.coupons.validate().map((e) => {"code": e.code}).toList(),
              isShop: true);

          await 1.seconds.delay;
          RazorPayServices.razorPayCheckout(checkoutScreenVars.cartCheckout!.totals!.totalPrice.validate().toDouble());
          appStore.setLoading(false);

          checkoutScreenVars.cartCheckout!.coupons!.forEach((coupon) {
            removeCoupon(code: coupon.code.validate()).then((value) {
              log('Coupon removed');
            }).catchError((e) {
              log('error remove coupon: ${e.toString()}');
            });
          });
        }

        //  OrderDetailScreen(orderDetails: value).launch(context);
      }
    });
  }

  getTotalPrice(int qty, int price) {
    return qty * price / 100;
  }

  @override
  void dispose() {
    appStore.setLoading(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          finish(context, checkoutScreenVars.isChange);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: context.iconColor),
            onPressed: () {
              finish(context, checkoutScreenVars.isChange);
            },
          ),
          titleSpacing: 0,
          title: Text(language.checkout, style: boldTextStyle(size: 22)),
          elevation: 0,
          centerTitle: true,
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Observer(builder: (context) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(language.products, style: boldTextStyle()),
                    16.height.visible(checkoutScreenVars.cartCheckout!.items.validate().isNotEmpty),

                    /// List Widget
                    Observer(builder: (context) {
                      return checkoutScreenVars.cartCheckout!.items.validate().isNotEmpty
                          ? ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: checkoutScreenVars.cartCheckout!.items!.length,
                              itemBuilder: (ctx, index) {
                                CartItemModel cartItem = checkoutScreenVars.cartCheckout!.items![index];
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    cachedImage(
                                      cartItem.images.validate().isNotEmpty ? cartItem.images!.first.src.validate() : '',
                                      height: 50,
                                      width: 50,
                                      fit: BoxFit.cover,
                                    ).cornerRadiusWithClipRRect(4),
                                    16.width,
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(cartItem.name.validate(), style: primaryTextStyle()),
                                        Text('${cartItem.quantity.validate()}*${getPrice(cartItem.prices!.currencySymbol.validate())}${getPrice(cartItem.prices!.price.validate())}', style: secondaryTextStyle()),
                                      ],
                                    ).expand(),
                                    Text('${getPrice(cartItem.prices!.currencySymbol.validate())} ${getTotalPrice(cartItem.quantity!.validate(), cartItem.prices!.price.toInt().validate())}', style: secondaryTextStyle()),
                                    16.width,
                                    Image.asset(ic_delete, color: Colors.red, height: 18, width: 18, fit: BoxFit.cover).onTap(() {
                                      showConfirmDialogCustom(
                                        context,
                                        onAccept: (c) {
                                          appStore.setLoading(true);
                                          shopStore.cartItemIndexList.removeAt(index);
                                          removeCartItem(productKey: cartItem.key.validate()).then((value) {
                                            toast(language.itemRemovedSuccessfully);
                                            getCart();
                                            checkoutScreenVars.isChange = true;
                                          }).catchError((e) {
                                            appStore.setLoading(false);
                                            toast(e.toString(), print: true);
                                          });
                                        },
                                        dialogType: DialogType.CONFIRMATION,
                                        title: language.removeFromCartConfirmation,
                                        positiveText: language.remove,
                                      );
                                    }, splashColor: Colors.transparent, highlightColor: Colors.transparent).paddingSymmetric(vertical: 4),
                                  ],
                                ).paddingSymmetric(vertical: 8);
                              },
                            )
                          : Text(language.yourCartIsCurrentlyEmpty, style: secondaryTextStyle());
                    }),

                    Observer(builder: (context) {
                      return Container(
                        decoration: BoxDecoration(color: context.cardColor, borderRadius: radius(commonRadius)),
                        child: CartCouponsComponent(
                          couponsList: checkoutScreenVars.cartCheckout!.coupons.validate(),
                          onCouponRemoved: (value) {
                            checkoutScreenVars.cartCheckout = value;
                            checkoutScreenVars.isChange = true;
                          },
                        ),
                      ).visible(checkoutScreenVars.cartCheckout!.coupons.validate().isNotEmpty);
                    }),

                    Container(
                      padding: EdgeInsets.all(16),
                      margin: EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(color: context.cardColor, borderRadius: radius(commonRadius)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(language.priceDetails, style: boldTextStyle()),
                          8.height,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(language.subTotal, style: secondaryTextStyle(size: 16)),
                              Observer(builder: (context) {
                                return PriceWidget(price: getPrice((checkoutScreenVars.cartCheckout!.totals!.totalItems.validate().toInt()).toString()), size: 16);
                              }),
                            ],
                          ),
                          4.height,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                language.discount,
                                style: secondaryTextStyle(size: 16),
                              ),
                              Observer(builder: (context) {
                                return Text(
                                  '-${checkoutScreenVars.cartCheckout!.totals!.currencySymbol}${getPrice(checkoutScreenVars.cartCheckout!.totals!.totalDiscount.validate())}',
                                  style: primaryTextStyle(color: appStore.isDarkMode ? Colors.green : Colors.green),
                                );
                              }),
                            ],
                          ),
                          4.height,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(language.totalAmount, style: secondaryTextStyle(size: 16)),
                              Observer(builder: (context) {
                                return PriceWidget(price: getPrice(checkoutScreenVars.cartCheckout!.totals!.totalPrice.toString()), size: 16);
                              }),
                            ],
                          ),
                        ],
                      ),
                    ),
                    8.height,

                    /// SHIPPING INFO
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: radius(16)),
                      child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Observer(builder: (context) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(language.billingAddress, style: boldTextStyle()),
                                    Image.asset(ic_edit, width: 18, height: 18, fit: BoxFit.cover, color: context.primaryColor).onTap(() {
                                      EditShopDetailsScreen().launch(context).then((value) {
                                        if (value ?? false) getCart();
                                      });
                                    }),
                                  ],
                                ),
                                12.height,
                                _orderInfoRow(Icons.person, language.name, "${shopStore.billingAddress.firstName} ${shopStore.billingAddress.lastName}"),
                                // _orderInfoRow(Icons.business, "Company", widget.orderDetails.billing.company),
                                _orderInfoRow(
                                    Icons.location_on,
                                    language.address,
                                    "${shopStore.billingAddress.address_1}, ${shopStore.billingAddress.address_2}, ${shopStore.billingAddress.city},"
                                    " ${shopStore.billingAddress.country}"
                                    "${shopStore.billingAddress.state}"
                                    " "),
                                _orderInfoRow(Icons.phone, language.phone, shopStore.billingAddress.phone?.validate() ?? ""),
                              ],
                            );
                          })),
                    ),
                    8.height,
                    Text(language.selectPaymentMethod, style: boldTextStyle()),
                    8.height,
                    Observer(builder: (context) {
                      return !checkoutScreenVars.isPaymentGatewayLoading
                          ? checkoutScreenVars.paymentGateways.isNotEmpty
                              ? Container(
                                  decoration: BoxDecoration(color: context.cardColor, borderRadius: radius(defaultAppButtonRadius)),
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    children: List.generate(checkoutScreenVars.paymentGateways.length, (index) {
                                      final payment = checkoutScreenVars.paymentGateways[index];
                                      return Container(
                                        margin: EdgeInsets.only(bottom: 8),
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: context.scaffoldBackgroundColor,
                                          borderRadius: radius(commonRadius),
                                          border: Border.all(color: context.primaryColor),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  checkoutScreenVars.selectedPaymentMethod == payment ? Icons.radio_button_checked : Icons.radio_button_off,
                                                  color: context.primaryColor,
                                                  size: 20,
                                                ),
                                                8.width,
                                                Text(payment.id.capitalizeFirstLetter(), style: primaryTextStyle()),
                                              ],
                                            ),
                                            if (checkoutScreenVars.selectedPaymentMethod == payment && payment.description != null && payment.description!.isNotEmpty)
                                              Container(
                                                padding: EdgeInsets.all(8),
                                                margin: EdgeInsets.only(top: 4, left: 16, bottom: 4),
                                                decoration: BoxDecoration(
                                                  color: context.scaffoldBackgroundColor,
                                                  borderRadius: radius(commonRadius),
                                                ),
                                                child: Text(payment.description!, style: secondaryTextStyle(size: 12)),
                                              ),
                                          ],
                                        ).onTap(() {
                                          checkoutScreenVars.selectedPaymentMethod = payment;
                                          setState(() {});
                                        }, splashColor: Colors.transparent, highlightColor: Colors.transparent),
                                      );
                                    }),
                                  ),
                                )
                              : Text(language.paymentGatewaysNotFound, style: secondaryTextStyle())
                          : ThreeBounceLoadingWidget();
                    }),
                    Text(language.placeOrderText, style: secondaryTextStyle()),
                    16.height,
                    RichText(
                      text: TextSpan(
                        text: '${language.addOrderNotes} ',
                        style: boldTextStyle(),
                        children: <TextSpan>[
                          TextSpan(text: '(${language.optional})', style: secondaryTextStyle(size: 12)),
                        ],
                      ),
                    ),
                    10.height,
                    Text(language.notesAboutYourOrder, style: secondaryTextStyle()),
                    16.height,
                    AppTextField(
                      controller: orderNotesController,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.done,
                      textFieldType: TextFieldType.MULTILINE,
                      textStyle: boldTextStyle(),
                      minLines: 3,
                      maxLines: 3,
                      decoration: inputDecorationFilled(context, fillColor: context.cardColor, label: 'Notes'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return language.pleaseEnterDescription;
                        }
                        return null;
                      },
                    ),
                    16.height,
                    appButton(
                      context: context,
                      text: language.placeOrder,
                      onTap: () async {
                        if (checkoutScreenVars.cartCheckout!.items.validate().isNotEmpty) {
                          if (checkoutScreenVars.cartCheckout!.billingAddress!.address_1.validate().isNotEmpty ||
                              checkoutScreenVars.cartCheckout!.billingAddress!.address_2.validate().isNotEmpty ||
                              checkoutScreenVars.cartCheckout!.billingAddress!.city.validate().isNotEmpty) {
                            placeOrder();
                          } else {
                            toast(language.pleaseEnterValidBilling);
                          }
                        } else {
                          toast(language.yourCartIsCurrentlyEmpty);
                        }
                      },
                    ),
                    50.height,
                  ],
                ).paddingSymmetric(horizontal: 16);
              }),
            ),
            // Observer(builder: (_) => LoadingWidget().center().visible(appStore.isLoading)),
          ],
        ),
      ),
    );
  }

  Widget _orderInfoRow(IconData icon, String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        12.width,
        //Text("$title:", style: secondaryTextStyle()).expand(flex: 2),
        Text(value.isEmptyOrNull ? "-" : value, style: primaryTextStyle()).expand(flex: 3),
      ],
    ).paddingOnly(bottom: 8);
  }
}
