import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/payment/razorpay_model.dart';
import 'package:socialv/network/network_utils.dart';
import 'package:socialv/network/pmp_repositry.dart';
import 'package:socialv/screens/membership/screens/pmp_order_detail_screen.dart';
import 'package:socialv/utils/app_constants.dart';

class RazorPayOrderServices {
  static late Razorpay razorPay;
  static late String razorKeys;
  static late String razorUrl;
  static late String razorSecret;
  static num totalAmount = 0;
  static late BuildContext context;
  static String mode = '';
  String? orderNote;
  static Map<String, dynamic>? billingAddress;
  static Map<String, dynamic>? shippingAddress;
  static List<Map<String, dynamic>>? lineItems = [];
  static List<Map<String, dynamic>>? coupon = [];

  static init({
    required String razorKey,
    required String url,
    required String secret,
    required num amount,
    required BuildContext ctx,
    String orderNote = "",
    Map<String, dynamic>? billingAddress,
    Map<String, dynamic>? shippingAddress,
    List<Map<String, dynamic>>? lineItems,
    List<Map<String, dynamic>>? coupon,
  }) {
    razorKeys = razorKey;
    razorPay = Razorpay();
    razorPay.on(Razorpay.EVENT_PAYMENT_SUCCESS, RazorPayOrderServices.handlePaymentSuccess);
    razorPay.on(Razorpay.EVENT_PAYMENT_ERROR, RazorPayOrderServices.handlePaymentError);
    razorPay.on(Razorpay.EVENT_EXTERNAL_WALLET, RazorPayOrderServices.handleExternalWallet);
    totalAmount = amount;
    context = ctx;
    razorUrl = url;
    razorSecret = secret;
    billingAddress = billingAddress;
    shippingAddress = shippingAddress;
    lineItems = lineItems ?? [];
    coupon = coupon ?? [];
  }

  static void handlePaymentSuccess(PaymentSuccessResponse response) async {
    getRazorPaymentDetails(
      amount: totalAmount,
      id: response.paymentId.validate(),
      context: context,
      mode: mode,
      key: razorKeys,
      secretKey: razorSecret,
      url: razorUrl,
      billingAddress: billingAddress,
      shippingAddress: shippingAddress,
      lineItems: lineItems ?? [],
      coupon: coupon,
    );
  }

  static void handlePaymentError(PaymentFailureResponse response) {
    toast("Error: " + response.code.toString() + " - " + response.message!, print: true);
    appStore.setLoading(false);
  }

  static void handleExternalWallet(ExternalWalletResponse response) {
    getRazorPaymentDetails(
      amount: totalAmount,
      externalWallet: response.walletName!,
      context: context,
      mode: mode,
      key: razorKeys,
      secretKey: razorSecret,
      url: razorUrl,
      billingAddress: billingAddress,
      shippingAddress: shippingAddress,
      lineItems: lineItems ?? [],
      coupon: coupon,
    );
    toast("externalWallet: " + response.walletName!);
  }

  static void razorPayCheckout(num mAmount) async {
    log('razorPay AMOUNT: $mAmount');
    var options = {
      'key': razorKeys,
      'amount': (mAmount * 100),
      'name': APP_NAME,
      'theme.color': appColorPrimary.toHex(),
      'description': '',
      'image': 'https://razorpay.com/assets/razorpay-glyph.svg',
      'currency': RAZORPAY_CURRENCY_CODE,
      'prefill': {'contact': '', 'email': userStore.loginEmail},
      'external': {
        'wallets': ['paytm']
      }
    };
    try {
      razorPay.open(options);
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}

Future<void> getRazorPaymentDetails({
  String? id,
  String? externalWallet,
  required num amount,
  required BuildContext context,
  required String mode,
  required String url,
  required String key,
  required String secretKey,
  Map<String, dynamic>? billingAddress,
  Map<String, dynamic>? shippingAddress,
  required List<Map<String, dynamic>> lineItems,
  List<Map<String, dynamic>>? coupon,
}) async {
  final String apiUrl = '$url/$id';
  final String keyId = key;
  final String keySecret = secretKey;
  String basicAuth = 'Basic ' + base64Encode(utf8.encode('$keyId:$keySecret'));
  print(basicAuth);

  final response = await http.get(
    Uri.parse(apiUrl),
    headers: {'Authorization': basicAuth},
  );
  if (response.statusCode.isSuccessful()) {
    RazorPayModel res = RazorPayModel.fromJson(await handleResponse(response));

    Map request = {
      "payment_method": "stripe",
      "payment_method_title": "Stripe",
      "set_paid": false,
      'customer_id': userStore.loginUserId,
      'status': "pending",
      "billing": billingAddress,
      "shipping": shippingAddress,
      "card_details": res.method == 'card' ? {"card_name": "${res.card!.network}", "account_number": res.card!.last4.validate(), "exp_month": "", "exp_year": "", "type": res.card!.type.validate()} : null, // for card payment else null

/*      "card_details": res.charges?.data.validate().isNotEmpty == true
          ? {
        "card_name": res.charges!.data!.first.paymentMethodDetails?.card?.brand ?? "",
        "account_number": res.charges!.data!.first.paymentMethodDetails?.card?.last4 ?? "",
        "exp_month": res.charges!.data!.first.paymentMethodDetails?.card?.expMonth ?? "",
        "exp_year": res.charges!.data!.first.paymentMethodDetails?.card?.expYear ?? "",
        "type": res.charges!.data!.first.paymentMethodDetails?.card?.funding ?? "",
      }
          : null,*/
      "transaction_id": res.id,
      "line_items": lineItems,
      "shipping_lines": [],
      "coupon_lines": coupon ?? [],
    };

    log('REQ: $request');

    appStore.setLoading(true);
    generateOrder(request).then((order) async {
      pmpStore.setPmpMembership(order.membershipId);
      setRestrictions(levelId: order.membershipId);
      appStore.setLoading(false);

      PmpOrderDetailScreen(isFromCheckOutScreen: true, orderDetail: order).launch(context);
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
    });
  }
}
