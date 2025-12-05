import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:phista/constant/constant.dart';
import 'package:phista/controller/driver_controller/dashboard_controller.dart';
import 'package:phista/controller/driver_controller/select_user_type_controller.dart';
import 'package:phista/themes/app_them_data.dart';

import 'package:phista/utils/dark_theme_provider.dart';
import 'package:provider/provider.dart';

import '../../../themes/custom_dialog_box.dart';
import 'auth_screen/login_screen.dart';


class DashBoardScreen extends StatelessWidget {
  const DashBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<DashboardScreenController>(
        init: DashboardScreenController(),
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
                if(Constant.currentUserModel.value?.role.toString() != "Guest" || index == 0 || index == 2){
                  controller.selectedIndex.value = index;
                }else{
                  /// Show popup

                  showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context){
                        return CustomDialogBox(title: "Alert".tr,
                          descriptions: "You cannot access this feature, please signup/login first".tr,
                          img: SvgPicture.asset('assets/icon/alert_ico.svg'),
                          positiveString: "Login".tr,
                          negativeString: "Cancel".tr,
                          positiveBgColor: AppThemData.success07,
                          positiveClick: () async {
                            print("login");
                            Get.back();
                            Constant.isGustUser = true;
                            Constant.globalParkingModel.value = null;
                            Get.to(LoginScreen());


                          },
                          negativeClick: (){
                            print("cancel");
                            Get.back();
                          },
                        );
                      });
                }
              },
              items: [
                navigationBarItem(
                  themeChange,
                  index: 0,
                  assetIcon: "assets/icon/ic_home.svg",
                  label: 'Home'.tr,
                  controller: controller,
                ),
                navigationBarItem(
                  themeChange,
                  index: 1,
                  assetIcon: "assets/icon/ic_bookmark.svg",
                  label: 'Favorites'.tr,
                  controller: controller,
                ),
                navigationBarItem(
                  themeChange,
                  index: 2,
                  assetIcon: "assets/icon/ic_booking.svg",
                  label: 'Booking'.tr,
                  controller: controller,
                ),
                navigationBarItem(
                  themeChange,
                  index: 3,
                  assetIcon: "assets/icon/ic_chat_icon.svg",
                  label: 'Message'.tr,
                  controller: controller,
                ),
                navigationBarItem(
                  themeChange,
                  index: 4,
                  assetIcon: "assets/icon/ic_account.svg",
                  label: 'Profile'.tr,
                  controller: controller,
                ),

              ],
            ),
          );
        });
  }

  BottomNavigationBarItem navigationBarItem(themeChange, {required int index, required String label, required String assetIcon, required DashboardScreenController controller}) {
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
