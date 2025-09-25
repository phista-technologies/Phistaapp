import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import '../../constant/constant.dart';
import '../../themes/app_them_data.dart';
import '../../themes/round_button_fill.dart';
import '../../utils/dark_theme_provider.dart';
import 'subscription_plan_screen/subscription_plan_screen_owner.dart';

class AppNotAccessScreenOwner extends StatelessWidget {
  const AppNotAccessScreenOwner({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Scaffold(
        body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: ShapeDecoration(
                color: themeChange.getThem() ? AppThemData.grey700 : AppThemData.grey200,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(120),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SvgPicture.asset("assets/icon/ic_payment_card.svg"),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              "Access denied".tr,
              style: TextStyle(
                color: themeChange.getThem() ? AppThemData.grey100 : AppThemData.grey800,
                fontFamily: AppThemData.semiBold,
                fontSize: 20,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Constant.showEmptyView(message: "Your current plan doesn’t include this feature. Upgrade to get access now.".tr),
            const SizedBox(
              height: 40,
            ),
            RoundedButtonFill(
              width: 60,
              title: "Upgrade Plan".tr,
              color: AppThemData.primary07,
              textColor: AppThemData.grey50,
              onPress: () async {
                Get.to(const SubscriptionPlanScreenOwner(isBack: false));
              },
            ),
          ],
        ),
      ),
    ));
  }
}
