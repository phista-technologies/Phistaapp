import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../controller/owner_controller/dashboard_controller_owner.dart';
import '../../themes/app_them_data.dart';
import '../../utils/dark_theme_provider.dart';

class DashBoardScreenOwner extends StatelessWidget {
  const DashBoardScreenOwner({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<DashboardScreenControllerOwner>(
        init: DashboardScreenControllerOwner(),
        builder: (controller) {
          return Scaffold(
            body: controller.pageList[controller.selectedIndex.value],
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              showUnselectedLabels: true,
              showSelectedLabels: true,
              currentIndex: controller.selectedIndex.value,
              backgroundColor: themeChange.getThem() ? AppThemData.grey11 : AppThemData.grey11,
              selectedItemColor: themeChange.getThem() ? AppThemData.primary06 : AppThemData.primary06,
              unselectedItemColor: themeChange.getThem() ? AppThemData.grey08 : AppThemData.grey08,
              onTap: (int index) {
                controller.selectedIndex.value = index;
              },
              items: [
                navigationBarItem(
                  themeChange,
                  index: 0,
                  assetIcon: "assets/icon/ic_my_booking_list.svg",
                  label: 'Booking'.tr,
                  controller: controller,
                ),
                navigationBarItem(
                  themeChange,
                  index: 1,
                  assetIcon: "assets/icon/ic_parking_p.svg",
                  label: 'Parking'.tr,
                  controller: controller,
                ),
                navigationBarItem(
                  themeChange,
                  index: 2,
                  assetIcon: "assets/icon/ic_wallet.svg",
                  label: 'wallet'.tr,
                  controller: controller,
                ),
                navigationBarItem(
                  themeChange,
                  index: 3,
                  assetIcon: "assets/icon/ic_account.svg",
                  label: 'profile'.tr,
                  controller: controller,
                ),
              ],
            ),
          );
        });
  }

  BottomNavigationBarItem navigationBarItem(themeChange, {required int index, required String label, required String assetIcon, required DashboardScreenControllerOwner controller}) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: SvgPicture.asset(
          assetIcon,
          height: 22,
          width: 22,
          color: controller.selectedIndex.value == index
              ? themeChange.getThem()
                  ? AppThemData.primary06
                  : AppThemData.primary06
              : themeChange.getThem()
                  ? AppThemData.grey08
                  : AppThemData.grey08,
        ),
      ),
      label: label,
    );
  }
}
