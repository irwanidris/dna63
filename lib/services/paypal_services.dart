import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:socialv/utils/stubs.dart';
import 'package:nb_utils/nb_utils.dart';
import '../configs.dart';
import '../main.dart';
import '../models/lms/lms_payment_model.dart';
import '../utils/common.dart';

class PayPalService {
  Future paypalCheckOut(
      {required BuildContext context, required num totalAmount, LmsPaymentModel? paymentModel, required Function(Map<String, dynamic>) onComplete, required Function(bool) loaderOnOFF}) async {
    loaderOnOFF(true);

    if (paymentModel == null) {
      toast('Payment model is missing');
      loaderOnOFF(false);
      return;
    }
    String? clientId = paymentModel.appClientId;
    String? secretKey = paymentModel.appClientSecret;

    if (clientId == null || clientId.isEmpty) {
      toast('PayPal Client ID is missing');
      loaderOnOFF(false);
      return;
    }

    if (secretKey == null || secretKey.isEmpty) {
      toast('PayPal Secret Key is missing');
      appStore.isLoading = false;
      return;
    }

    await PaypalCheckout(
      sandboxMode: (!kReleaseMode || isIqonicProduct),
      clientId: paymentModel.appClientId!,
      secretKey: paymentModel.appClientSecret!,
      returnURL: "junedr375.github.io/junedr375-payment/",
      cancelURL: "junedr375.github.io/junedr375-payment/error.html",
      transactions: [
        {
          "amount": {
            "total": totalAmount,
            "currency": PAYPAL_CURRENCY_CODE,
            "details": {
              "subtotal": totalAmount,
              "shipping": '0',
              "shipping_discount": 0
            }
          },
          "description": 'Name: ${userStore.loginName} - Email: ${userStore.loginEmail}',
        }
      ],
      note: " - ",
      onSuccess: (Map params) async {
        log("onSuccess: $params");
        appStore.isLoading = false;
        if (params['message'] is String) {
          toast(params['message']);
        }
        onComplete.call({
          'transaction_id': params['data']?['id'],
        });
      },
      onError: (error) {
        log("onError: $error");
        appStore.isLoading = false;
        toast(error);
        finish(context);
      },
      onCancel: (params) {
        log("cancelled: $params");
        toast('cancelled');
        appStore.isLoading = false;
      },
    )
        .launch(context)
        .whenComplete(() => appStore.isLoading = false)
        .onError((e, stackTrace) {
      toast(e.toString());
      appStore.isLoading = false;
    });
  }
}
