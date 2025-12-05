import 'dart:convert';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:html' as html;

import '../../constant/show_toast_dialog.dart';
import '../../env.dart';

class WebStripeController extends GetxController {
  final String amount;
  final String secretKey;
  WebStripeController(this.amount, this.secretKey);

  final RxBool isLoading = true.obs;
  final RxnString checkoutUrl = RxnString();
  late final WebViewController webViewController;

  @override
  void onInit() {
    super.onInit();
    _checkStripeStatus();
    openStripeCheckoutWeb(amount: amount,secretKey:secretKey);
  }

  Future<void> _createCheckoutSession() async {
    try {
      // Replace this with your backend endpoint
      final uri = Uri.parse("https://your-backend.com/create-checkout-session");

      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"amount": amount}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        checkoutUrl.value = data['url'];
        _initWebView();
      } else {
        Get.snackbar("Error", "Failed to create checkout session");
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> openStripeCheckoutWeb({required String amount,required String secretKey}) async {
    try {
      String stripeSecretKey = secretKey;//ENV.skTestSecretKey;

      final response = await http.post(
        Uri.parse("https://api.stripe.com/v1/checkout/sessions"),
        headers: {
          "Authorization": "Bearer $stripeSecretKey",
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          "mode": "payment",
          "payment_method_types[]": "card",
          "line_items[0][price_data][currency]": "cad",
          "line_items[0][price_data][product_data][name]": "Phista Payment",
          "line_items[0][price_data][unit_amount]":
          (double.parse(amount) * 100).toInt().toString(),
          "line_items[0][quantity]": "1",
          // "success_url": "http://localhost:8080/payment_return.html?status=success",
          // "cancel_url": "http://localhost:8080/payment_return.html?status=cancel",
          "success_url": "https://test.phista.ca/payment_return.html?status=success",
          "cancel_url": "https://test.phista.ca/payment_return.html?status=cancel",
        },
      );
      final data = jsonDecode(response.body);
      if (data["url"] != null) {
        log("launch url after stripe ${data["url"]}");
        html.window.open(data["url"], "_blank");
      } else {
        log("Error creating Checkout Session: $data");
        ShowToastDialog.showToast("Stripe checkout failed.");
      }
    } catch (e, s) {
      log("Stripe Web Checkout Error: $e\n$s");
      ShowToastDialog.showToast("Stripe web payment error: $e");
    }
  }

  void _checkStripeStatus() {
    final result = html.window.localStorage['stripe_result'];

    if (result == "success") {
      html.window.localStorage.remove('stripe_result');
      Get.back(result: {"status": "success"});
    }
    else if (result == "cancel") {
      html.window.localStorage.remove('stripe_result');
      Get.back(result: {"status": "cancel"});
    }
  }


  void _initWebView() {
    if (checkoutUrl.value == null) return;

    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(checkoutUrl.value!))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            if (url.contains("payment-success")) {
              Get.back(result: {"status": "success"});
            } else if (url.contains("payment-cancel")) {
              Get.back(result: {"status": "cancel"});
            }
          },
        ),
      );
  }
}
