import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../constant/constant.dart';
import '../../controller/owner_controller/on_boarding_controller_owner.dart';
import '../../themes/app_them_data.dart';
import '../../themes/round_button_gradiant.dart';
import '../../utils/dark_theme_provider.dart';
import '../../utils/preferences.dart';
import 'auth_screen/login_screen_owner.dart';

class OnBoardingScreenOwner extends StatelessWidget {
  const OnBoardingScreenOwner({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<OnBoardingControllerOwner>(
      init: OnBoardingControllerOwner(),
      builder: (controller) {
        return Scaffold(
          body: controller.isLoading.value
              ? Constant.loader()
              : Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(controller.selectedPageIndex.value == 0
                              ? themeChange.getThem()
                                  ? "assets/images/onBoarding_bg1.png"
                                  : "assets/images/onBoarding_bg1.png"
                              : controller.selectedPageIndex.value == 1
                                  ? themeChange.getThem()
                                      ? "assets/images/onBoarding_bg2.png"
                                      : "assets/images/onBoarding_bg2.png"
                                  : themeChange.getThem()
                                      ? "assets/images/onBoarding_bg3.png"
                                      : "assets/images/onBoarding_bg3.png"),fit: BoxFit.cover)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: PageView.builder(
                              controller: controller.pageController,
                              onPageChanged: controller.selectedPageIndex.call,
                              itemCount: controller.onBoardingList.length,
                              itemBuilder: (context, index) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      controller.onBoardingList[index].title.toString().tr,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey01,
                                        fontSize: 24,
                                        fontFamily: AppThemData.semiBold,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 12,
                                    ),
                                    Text(
                                      controller.onBoardingList[index].description.toString().tr,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: AppThemData.grey01,
                                        fontSize: 14,
                                        fontFamily: AppThemData.regular,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                );
                              }),
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            controller.onBoardingList.length,
                            (index) => Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: controller.selectedPageIndex.value == index ? 38 : 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: controller.selectedPageIndex.value == index
                                      ? themeChange.getThem()
                                          ? AppThemData.grey04
                                          : AppThemData.primary06
                                      : AppThemData.grey04,
                                  borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                                )),
                          ),
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        SquareButtonGradiant(
                          title: controller.selectedPageIndex.value == 2 ? "Get Started".tr : "Next".tr,
                          onPress: () {
                            if (controller.selectedPageIndex.value == 2) {
                              Preferences.setBoolean(Preferences.isFinishOnBoardingKey, true);
                              Get.offAll(const LoginScreenOwner());
                            } else {
                              controller.pageController.jumpToPage(controller.selectedPageIndex.value + 1);
                            }
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        controller.selectedPageIndex.value == 2
                            ? const Text(
                          '',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppThemData.grey08,
                            fontSize: 16,
                            fontFamily: AppThemData.medium,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                            : SquareButtonOutLine(onPress: (){
                          Preferences.setBoolean(Preferences.isFinishOnBoardingKey, true);
                          Get.offAll(const LoginScreenOwner());
                        },title: 'Skip'.tr,),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}
