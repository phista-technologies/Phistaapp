import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../constant/constant.dart';
import '../controller/driver_controller/dashboard_controller.dart';
import '../controller/driver_controller/web_stripe_controller_stub.dart'
if (dart.library.html) '../controller/driver_controller/web_stripe_controller.dart';

import '../themes/app_them_data.dart';
import '../themes/common_ui.dart';
import '../ui/driver/dashboard_screen.dart';
import 'dark_theme_provider.dart';

class WebStripeCheckoutScreen extends StatelessWidget {
  final String amount;
  final String secretKey;

  const WebStripeCheckoutScreen({super.key, required this.amount, required this.secretKey});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final controller = Get.put(WebStripeController(amount,secretKey));

    return Scaffold(
      backgroundColor: themeChange.getThem()
          ? AppThemData.warning06
          : AppThemData.warning06,
      appBar: UiInterface().customAppBar(
        context,
        themeChange,
        "Stripe Payment".tr,
        onBackTap: () {
          DashboardScreenController dashboardController =
          Get.put(DashboardScreenController());
          dashboardController.selectedIndex(2);
          Constant.globalParkingModel.value = null;
          Get.offAll(() => const DashBoardScreen());
        },
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.checkoutUrl.value == null) {
          return const Center(
            child: Text("Unable to load Stripe Checkout"),
          );
        }

        return WebViewWidget(
          controller: controller.webViewController,
        );
      }),
    );
  }
}
