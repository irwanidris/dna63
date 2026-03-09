import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/payment/razorpay_model.dart';
import 'package:socialv/network/network_utils.dart';
import 'package:socialv/network/pmp_repositry.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/membership/screens/pmp_order_detail_screen.dart';
// MVP: Shop disabled - import 'package:socialv/screens/shop/screens/order_detail_screen.dart';
import 'package:socialv/utils/app_constants.dart';
import 'package:socialv/utils/stubs.dart';

class RazorPayServices {
  static late Razorpay razorPay;
  static late String razorKeys;
  static late String razorUrl;
  static late String razorSecret;
  static num totalAmount = 0;
  static String levelId = '';
  static String? discountCode = '';
  static late BuildContext context;
  static String mode = '';

  static bool? isShop = false;
  static Map<String, dynamic>? billingAddress;
  static Map<String, dynamic>? shippingAddress;
  static List<Map<String, dynamic>>? lineItems = [];
  static List<Map<String, dynamic>>? coupon = [];
  static String? orderNote;

  static init({
    required String razorKey,
    required String url,
    required String secret,
    required num amount,
    required String planId,
    required String? disCode,
    required BuildContext ctx,
    required String paymentMode,
    Map<String, dynamic>? billingAddress,
    Map<String, dynamic>? shippingAddress,
    Map<String, dynamic>? stripeRequest,
    List<Map<String, dynamic>>? lineItems,
    List<Map<String, dynamic>>? coupon,
    String? orderNote,
    bool? isShop = false,
  }) {
    razorKeys = razorKey;
    razorPay = Razorpay();
    razorPay.on(Razorpay.EVENT_PAYMENT_SUCCESS, RazorPayServices.handlePaymentSuccess);
    razorPay.on(Razorpay.EVENT_PAYMENT_ERROR, RazorPayServices.handlePaymentError);
    razorPay.on(Razorpay.EVENT_EXTERNAL_WALLET, RazorPayServices.handleExternalWallet);
    totalAmount = amount;
    levelId = planId;
    discountCode = disCode;
    context = ctx;
    mode = paymentMode;
    razorUrl = url;
    razorSecret = secret;
    RazorPayServices.isShop = isShop;
    RazorPayServices.billingAddress = billingAddress;
    RazorPayServices.shippingAddress = shippingAddress;
    RazorPayServices.lineItems = lineItems;
    RazorPayServices.coupon = coupon;
    RazorPayServices.orderNote = orderNote;
  }

  static void handlePaymentSuccess(PaymentSuccessResponse response) async {
    getRazorPaymentDetails(
      amount: totalAmount,
      id: response.paymentId.validate(),
      levelId: levelId,
      disCode: discountCode,
      context: context,
      mode: mode,
      key: razorKeys,
      secretKey: razorSecret,
      url: razorUrl,
      isShop: isShop,
      billingAddress: billingAddress,
      shippingAddress: shippingAddress,
      lineItems: lineItems,
      coupon: coupon,
      orderNote: orderNote,
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
      levelId: levelId,
      disCode: discountCode,
      context: context,
      mode: mode,
      key: razorKeys,
      secretKey: razorSecret,
      url: razorUrl,
      isShop: isShop,
      billingAddress: billingAddress,
      shippingAddress: shippingAddress,
      lineItems: lineItems,
      coupon: coupon,
    );
    toast("externalWallet: " + response.walletName!);
  }

  static void razorPayCheckout(num mAmount) async {
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
  required String levelId,
  required num amount,
  String? disCode,
  required BuildContext context,
  required String mode,
  required String url,
  required String key,
  required String secretKey,
  Map<String, dynamic>? billingAddress,
  Map<String, dynamic>? shippingAddress,
  Map<String, dynamic>? stripeRequest,
  List<Map<String, dynamic>>? lineItems,
  List<Map<String, dynamic>>? coupon,
  String? orderNote,
  bool? isShop = false,
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

    String meta = '';
    String transactionId = '';

    if (res.method == PaymentMethods.upi) {
      meta = res.vpa.validate();
      transactionId = res.acquirerData!.upiTransactionId.validate();
    } else if (res.method == PaymentMethods.netBanking) {
      meta = res.bank.validate();
      transactionId = res.acquirerData!.bankTransactionId.validate();
    } else if (res.method == PaymentMethods.paylater) {
      meta = res.wallet.validate();
    } else {
      //
    }

    if (isShop == false) {
      Map request = {
        "billing_amount": amount,
        "billing_details": '',
        "card_details": res.method == 'card' ? {"card_name": "${res.card!.network}", "account_number": res.card!.last4.validate(), "exp_month": "", "exp_year": "", "type": res.card!.type.validate()} : null, // for card payment else null
        "gateway": "razorpay",
        "payment_by": res.method,
        "email": userStore.loginEmail,
        "contact": '',
        "meta_value": meta,
        "transaction_id": transactionId,
        "level_id": levelId,
        "discount_code": disCode,
        "gateway_mode": mode,
        "coupon_amount": amount,
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
        toast(e.toString(), print: true);
      });
      appStore.setLoading(false);
    } else {
      ///shop
      Map request = {
        "payment_method": "razorpay",
        "payment_method_title": "Pay with Razorpay",
        "set_paid": true,
        'customer_id': userStore.loginUserId,
        'status': "pending",
        "billing": billingAddress,
        "shipping": shippingAddress,
        "card_details": (res.card != null && res.card!.id.validate().isNotEmpty)
            ? {
                "card_name": res.card!.network.validate(),
                "account_number": res.card!.last4.validate(),
                "exp_month": "",
                "exp_year": "",
                "type": res.card!.type.validate(),
              }
            : null,
        "transaction_id": res.id,
        "line_items": lineItems,
        "shipping_lines": [],
        "coupon_lines": coupon ?? [],
        "customer_note": orderNote,
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
        shopStore.cartItemIndexList.clear();

        ///  Clear cart
        clearCart().then((value) {
          log("Removed products from cart.");
        });

        appStore.setCartCount(0);
        appStore.setLoading(false);
      }).catchError((e) {
        appStore.setLoading(false);
        toast(e.toString());
      });
    }
  }
}
