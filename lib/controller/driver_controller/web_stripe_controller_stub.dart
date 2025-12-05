// file: controller/driver_controller/web_stripe_controller_stub.dart

import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebStripeController extends GetxController {
  final String amount;
  final String secretKey;
  WebStripeController(this.amount,this.secretKey);

  // ✅ Dummy reactive variables to prevent build errors
  final RxBool isLoading = false.obs;
  final RxnString checkoutUrl = RxnString(null);

  // ✅ Dummy webview controller so UI compiles
  late final WebViewController webViewController =
  WebViewController()..loadHtmlString("<html><body>Web only</body></html>");
}
