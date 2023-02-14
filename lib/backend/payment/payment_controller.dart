import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../model/admin/payment_credentials_model.dart';
import '../../utils/my_print.dart';
import '../data/data_controller.dart';

class PaymentController {
  Future createPayment({required double amount, required Function(String, String, String) handleSuccess, required Function(String) handleCancel, required Function handleFailure}) async {
    PaymentCredentialsModel? paymentCredentialsModel = await DataController.getPaymentCredentialsData();

    if(paymentCredentialsModel == null) {
      await handleFailure();
      return;
    }

    String key = paymentCredentialsModel.testKey;
    String secret = paymentCredentialsModel.testSecret;

    /*String key = paymentCredentialsModel.key;
    String secret = paymentCredentialsModel.secret;*/

    String orderId = await _createAnOrder(amount, "INR", key, secret);
    MyPrint.printOnConsole("Order Id:$orderId");

    if(orderId.isEmpty) {
      await handleFailure();
      return;
    }

    var options = {
      'key': key,
      'amount': '${(amount * 100).toInt()}' ,
      "order_id" : orderId,
      'payment_capture': true,
      'name': 'Brandwala App',
      'prefill': {'contact': '', "email" : ""},
      'external': {},
      "remember_customer" : true,
    };
    if(orderId.isNotEmpty) options.addAll({'order_id': orderId,});

    final Completer completer = Completer();

    try {
      Razorpay razorpay = Razorpay();
      razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (PaymentSuccessResponse res) async {
        MyPrint.printOnConsole("Payment Success");
        razorpay.clear();
        await handleSuccess(res.paymentId ?? "", res.orderId ?? "", res.signature ?? "");
        completer.complete();
      });
      razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (PaymentFailureResponse failureResponse) async {
        MyPrint.printOnConsole("Payment Failed");
        razorpay.clear();
        await handleCancel(failureResponse.message ?? "");
        completer.complete();
      });
      razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, (ExternalWalletResponse externalWalletResponse){
        MyPrint.printOnConsole("wallet:'${externalWalletResponse.walletName}'");
        razorpay.clear();
        completer.complete();
        //MyToast.showSuccess("wallet", context);
      });
      razorpay.open(options);
      MyPrint.printOnConsole("Open Called");
    }
    catch (e, s) {
      MyPrint.printOnConsole("Error in Creating Razorpay Payment : $e");
      MyPrint.printOnConsole(s);
    }

    await completer.future;
  }

  Future<String> _createAnOrder(double amount, String currency, String key, String secret) async {
    String basicAuth = 'Basic ${base64.encode(utf8.encode('$key:$secret'))}';
    MyPrint.printOnConsole(basicAuth);

    MyPrint.printOnConsole("Payment Key:$key");
    MyPrint.printOnConsole("Payment Secret:$secret");
    MyPrint.printOnConsole("Payment Header:$basicAuth");

    try {
      http.Response response = await http.post(
        Uri.parse('https://api.razorpay.com/v1/orders',),
        headers: {
          "Content-Type": "application/json",
          HttpHeaders.authorizationHeader : basicAuth,
          HttpHeaders.acceptHeader: "application/json",
          "Cache-Control": "no-cache",
          HttpHeaders.hostHeader: "api.razorpay.com"
        },
        body: jsonEncode(<String, dynamic>{
          "amount": '${(amount * 100).toInt()}',
          "currency": currency,
          "receipt": "receipts#1",
          "payment_capture": "1",
          "payment": {
            "capture": "automatic",
            "capture_options": {
              //"automatic_expiry_period": 12,
              //"manual_expiry_period": 7200,
              "refund_speed": "optimum"
            }
          },
        }),
      );
      final responseJson = json.decode(response.body);

      MyPrint.printOnConsole("Response : $responseJson");

      if(response.statusCode == 200) {
        return responseJson['id'];
      }
      else {
        return "";
      }
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in PaymentController._createAnOrder():$e");
      MyPrint.printOnConsole(s);
      return "";
    }
  }
}