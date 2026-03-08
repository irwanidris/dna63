import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/payment/stripe_pay_model.dart';
import 'package:socialv/models/payment/stripe_payment_details_model.dart';
import 'package:socialv/network/network_utils.dart';
import 'package:socialv/network/pmp_repositry.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/membership/screens/pmp_order_detail_screen.dart';
import 'package:socialv/screens/shop/screens/order_detail_screen.dart';

import '../utils/app_constants.dart';

class StripeServices {
  num totalAmount = 0;
  String stripeURL = "";
  String stripePaymentKey = "";
  bool isTest = false;
  late BuildContext context;
  String levelId = "";
  String? discountCode = "";
  String mode = "";
  bool isShop = false;
  String? orderNote;
  Map<String, dynamic>? billingAddress;
  Map<String, dynamic>? shippingAddress;
  List<Map<String, dynamic>>? lineItems = [];
  List<Map<String, dynamic>>? coupon = [];

  init({
    required String stripePaymentPublishKey,
    required num totalAmount,
    required String stripeURL,
    required String stripePaymentKey,
    required BuildContext context,
    required String levelId,
    required String? discountCode,
    required String mode,
    isShop = false,
    String orderNote = "",
    Map<String, dynamic>? billingAddress,
    Map<String, dynamic>? shippingAddress,
    Map<String, dynamic>? stripeRequest,
    List<Map<String, dynamic>>? lineItems,
    List<Map<String, dynamic>>? coupon,
  }) async {
    Stripe.publishableKey = stripePaymentPublishKey;
    Stripe.merchantIdentifier = 'merchant.flutter.stripe.test';
    this.totalAmount = totalAmount;
    this.stripeURL = stripeURL;
    this.stripePaymentKey = stripePaymentKey;
    this.isTest = isTest;
    this.context = context;
    this.levelId = levelId;
    this.discountCode = discountCode;
    this.mode = mode;
    this.isShop = isShop;
    this.orderNote = orderNote;
    this.billingAddress = billingAddress;
    this.shippingAddress = shippingAddress;
    this.lineItems = lineItems ?? [];
    this.coupon = coupon ?? [];
    setValue("StripeKeyPayment", stripePaymentKey);

    await Stripe.instance.applySettings().then((value) {}).catchError((e) {
      toast(e.toString(), print: true);
      throw e.toString();
    });
  }

  //StripPayment
  void stripePay() async {
    Map<String, String> headers = {
      HttpHeaders.authorizationHeader: 'Bearer $stripePaymentKey',
      HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
    };

    log('headers : $headers');

    var request = http.Request(HttpMethodType.POST.name, Uri.parse(stripeURL));

    request.bodyFields = {
      'amount': '${(totalAmount.toInt() * 100).toInt()}',
      'currency': STRIPE_CURRENCY_CODE,
      'description': 'Name: ${userStore.loginFullName} - Email: ${userStore.loginEmail}',
    };

    log(request.bodyFields);
    request.headers.addAll(headers);

    appStore.setLoading(true);

    await request.send().then((value) {
      appStore.setLoading(false);
      http.Response.fromStream(value).then((response) async {
        log("status code---------${response.statusCode}");
        if (response.statusCode.isSuccessful()) {
          StripePayModel res = StripePayModel.fromJson(await handleResponse(response));

          log('res : ${res.toJson()}');

          SetupPaymentSheetParameters setupPaymentSheetParameters = SetupPaymentSheetParameters(
            paymentIntentClientSecret: res.clientSecret.validate(),
            style: appStore.isDarkMode ? ThemeMode.dark : ThemeMode.dark,
            appearance: PaymentSheetAppearance(colors: PaymentSheetAppearanceColors(primary: appColorPrimary)),
            applePay: PaymentSheetApplePay(merchantCountryCode: kReleaseMode ? STRIPE_MERCHANT_COUNTRY_CODE : STRIPE_MERCHANT_COUNTRY_CODE),
            googlePay: PaymentSheetGooglePay(merchantCountryCode: kReleaseMode ? STRIPE_MERCHANT_COUNTRY_CODE : STRIPE_MERCHANT_COUNTRY_CODE, testEnv: isTest),
            merchantDisplayName: APP_NAME,
            customerId: userStore.loginUserId.toString(),
            customerEphemeralKeySecret: isAndroid ? res.ephemeralKey.validate() : null,
            setupIntentClientSecret: res.clientSecret.validate(),
          );

          await Stripe.instance.initPaymentSheet(paymentSheetParameters: setupPaymentSheetParameters).then((value) async {
            await Stripe.instance.presentPaymentSheet().then((value) async {
              if (isShop) {
                getStripePayment(
                  id: res.id.validate(),
                  stripePaymentKey: stripePaymentKey,
                  stripeURL: stripeURL,
                  context: context,
                  orderNote: orderNote,
                  billingAddress: billingAddress,
                  shippingAddress: shippingAddress,
                  lineItems: lineItems ?? [],
                  coupon: coupon,
                );
              } else {
                getStripePaymentDetails(
                  totalAmount: totalAmount,
                  discountCode: discountCode,
                  id: res.id.validate(),
                  stripePaymentKey: stripePaymentKey,
                  stripeURL: stripeURL,
                  levelId: levelId,
                  context: context,
                  mode: mode,
                );
              }
              //finish(context);
            }).catchError((e) {
              if (e is StripeException) {
                // Handle Stripe-specific exception
                toast('Stripe Error: ${e.error.localizedMessage}', print: true);
                log('StripeException: ${e.toString()}');
              } else {
                // Handle other exceptions
                toast(e.toString(), print: true);
              }
            });
          });
        } else if (response.statusCode == 400) {
          toast("Testing Credential cannot pay more than 500");
        }
      });
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);

      throw e.toString();
    });
  }
}

StripeServices stripeServices = StripeServices();

Future<void> getStripePaymentDetails({
  required String id,
  required num totalAmount,
  required String stripePaymentKey,
  required String stripeURL,
  required String levelId,
  String? discountCode,
  required BuildContext context,
  required String mode,
}) async {
  Map<String, String> headers = {
    HttpHeaders.authorizationHeader: 'Bearer $stripePaymentKey',
    HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
  };

  var request = http.Request(HttpMethodType.GET.name, Uri.parse('$stripeURL/$id'));
  request.headers.addAll(headers);

  request.send().then((value) async {
    http.Response.fromStream(value).then((response) async {
      if (response.statusCode.isSuccessful()) {
        StripePaymentDetailsModel res = StripePaymentDetailsModel.fromJson(await handleResponse(response));
        Map request = {
          "billing_amount": totalAmount,
          "billing_details": '',
          "card_details": res.charges?.data.validate().isNotEmpty == true
              ? {
                  "card_name": res.charges!.data!.first.paymentMethodDetails?.card?.brand ?? "",
                  "account_number": res.charges!.data!.first.paymentMethodDetails?.card?.last4 ?? "",
                  "exp_month": res.charges!.data!.first.paymentMethodDetails?.card?.expMonth ?? "",
                  "exp_year": res.charges!.data!.first.paymentMethodDetails?.card?.expYear ?? "",
                  "type": res.charges!.data!.first.paymentMethodDetails?.card?.funding ?? "",
                }
              : null, // fallback if charges is null // for card payment else null
          "gateway": "stripe",
          "payment_by": "card",
          "email": userStore.loginEmail,
          "contact": '',
          "meta_value": "",
          "transaction_id": res.id,
          "level_id": levelId,
          "discount_code": discountCode,
          "gateway_mode": mode,
          "coupon_amount": totalAmount,
        };

        log('REQ: $request');

        appStore.setLoading(true);
        generateOrder(request).then((order) async {
          pmpStore.setPmpMembership(order.membershipId);
          setRestrictions(levelId: order.membershipId);

          appStore.setLoading(false);
          PmpOrderDetailScreen(isFromCheckOutScreen: true, orderDetail: order).launch(context).then((value) {
            if (value ?? false) {
              finish(context);
            }
          });
        }).catchError((e) {
          appStore.setLoading(false);
          toast(e.toString());
        });
      }
    });
  });
}

Future<void> getStripePayment({
  required String id,
  required String stripePaymentKey,
  required String stripeURL,
  String? orderNote,
  required BuildContext context,
  Map<String, dynamic>? billingAddress,
  Map<String, dynamic>? shippingAddress,
  required List<Map<String, dynamic>> lineItems,
  List<Map<String, dynamic>>? coupon,
}) async {
  Map<String, String> headers = {
    HttpHeaders.authorizationHeader: 'Bearer $stripePaymentKey',
    HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
  };

  var request = http.Request(HttpMethodType.GET.name, Uri.parse('$stripeURL/$id'));
  request.headers.addAll(headers);

  request.send().then((value) async {
    http.Response.fromStream(value).then((response) async {
      if (response.statusCode.isSuccessful()) {
        StripePaymentDetailsModel res = StripePaymentDetailsModel.fromJson(await handleResponse(response));
        Map request = {
          "payment_method": "stripe",
          "payment_method_title": "Stripe",
          "set_paid": true,
          'customer_id': userStore.loginUserId,
          'status': "pending",
          "billing": billingAddress,
          "shipping": shippingAddress,
          "card_details": res.charges?.data.validate().isNotEmpty == true
              ? {
                  "card_name": res.charges!.data!.first.paymentMethodDetails?.card?.brand ?? "",
                  "account_number": res.charges!.data!.first.paymentMethodDetails?.card?.last4 ?? "",
                  "exp_month": res.charges!.data!.first.paymentMethodDetails?.card?.expMonth ?? "",
                  "exp_year": res.charges!.data!.first.paymentMethodDetails?.card?.expYear ?? "",
                  "type": res.charges!.data!.first.paymentMethodDetails?.card?.funding ?? "",
                }
              : null,
          "transaction_id": res.id,
          "line_items": lineItems,
          "shipping_lines": [],
          "coupon_lines": coupon ?? [],
        };

        appStore.setLoading(true);
        await createOrder(request: request).then((value) async {
          if (orderNote != null && orderNote.isNotEmpty) {
            Map noteRequest = {"note": orderNote.trim(), "customer_note": true};
            await createOrderNotes(request: noteRequest, orderId: value.id.validate()).then((value) {}).catchError((e) {
              log('Order Note Error: ${e.toString()}');
            });
          }
          if (context.mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => OrderDetailScreen(orderDetails: value),
              ),
              (route) => route.isFirst, // keep only the first route (Dashboard) below
            );
          }
        }).catchError((e) {
          appStore.setLoading(false);
          toast(e.toString(), print: true);
        });
        appStore.setLoading(false);
      } else {
        toast("Testing Credential cannot pay more than 500");
      }
    });
  }).catchError((e) {
    appStore.setLoading(false);
    toast(e.toString(), print: true);
    throw e.toString();
  });
}
