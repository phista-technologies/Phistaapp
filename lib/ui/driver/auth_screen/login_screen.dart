import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:phista/constant/show_toast_dialog.dart';
import 'package:phista/controller/driver_controller/login_controller.dart';
import 'package:phista/themes/app_them_data.dart';
import 'package:phista/themes/mobile_number_textfield.dart';
import 'package:phista/themes/responsive.dart';
import 'package:phista/themes/round_button_gradiant.dart';
import 'package:phista/themes/segment_button_gradiant.dart';
import 'package:phista/utils/dark_theme_provider.dart';
import 'package:provider/provider.dart';

import '../../../constant/constant.dart';
import '../../../utils/fire_store_utils.dart';
import '../terms_and_condition/terms_and_condition_screen.dart';
import 'loginwithemail_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<LoginController>(
      init: LoginController(),
      builder: (controller) {
        return Scaffold(
          body: Center(
            child: SingleChildScrollView(
              child: Form(
                key: controller.formKey.value,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: Responsive.height(9, context)),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: InkWell(
                          child: Icon(Icons.arrow_back, color: themeChange.getThem() ? AppThemData.grey02 : AppThemData.grey11),
                          onTap: (){
                            Get.back();
                          },
                        ),
                      ),
                      Align(
                        alignment: Alignment.topCenter,
                        child: Image.asset(
                          "assets/images/login_logo.png",
                          width: 200,
                          height: 150,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Text(
                        "Log in or Sign up".tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: themeChange.getThem()
                              ? AppThemData.grey01
                              : AppThemData.grey10,
                          fontSize: 24,
                          fontFamily: AppThemData.semiBold,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Instant parking at your fingertips. No more circling - find, reserve, and pay instantly!"
                            .tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppThemData.grey07,
                          fontSize: 14,
                          fontFamily: AppThemData.regular,
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      SizedBox(height: Responsive.height(7, context)),
                      Column(
                        children: [
                          Visibility(
                            visible: Platform.isIOS,
                            child: InkWell(
                              onTap: () {
                                controller.loginWithApple();
                              },
                              child: Container(
                                width: Responsive.width(90, context),
                                height: Responsive.height(7, context),
                                decoration: BoxDecoration(
                                  color: themeChange.getThem()
                                      ? AppThemData.grey10
                                      : AppThemData.grey03,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment:
                                  CrossAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      "assets/icon/ic_apple.svg",
                                      height: 24,
                                      width: 24,
                                      color: themeChange.getThem()
                                          ? AppThemData.grey01
                                          : AppThemData.grey08,
                                    ),
                                    if (Platform.isIOS)
                                      const SizedBox(height: 12),
                                    Text(
                                      'Continue with Apple'.tr,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: themeChange.getThem()
                                            ? AppThemData.grey01
                                            : AppThemData.grey08,
                                        fontSize: 14,
                                        fontFamily: AppThemData.medium,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          InkWell(
                            onTap: () async{
                              if(Constant.isGustUser){
                                ShowToastDialog.showLoader("please_wait".tr);
                                await FireStoreUtils.deleteUser().then((value) {
                                  Constant.isGustUser = false;
                                  ShowToastDialog.closeLoader();
                                  if (value == true) {
                                    controller.loginWithGoogle();
                                  } else {
                                    ShowToastDialog.showToast(
                                        "Something went wrong".tr);
                                  }
                                });
                              }else{
                                controller.loginWithGoogle();
                              }
                            },
                            child: Container(
                              width: Responsive.width(90, context),
                              height: Responsive.height(7, context),
                              // padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: themeChange.getThem()
                                    ? AppThemData.grey10
                                    : AppThemData.grey03,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    "assets/icon/ic_google.svg",
                                    height: 24,
                                    width: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Continue with Google'.tr,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: themeChange.getThem()
                                          ? AppThemData.grey01
                                          : AppThemData.grey08,
                                      fontSize: 14,
                                      fontFamily: AppThemData.medium,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Expanded(child: Divider(thickness: 1)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              "or log in with".tr,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppThemData.grey06,
                                fontSize: 12,
                                fontFamily: AppThemData.medium,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 20),
                     // controller.fromLoginType.value == "Mobile" ?
                      MobileNumberTextField(
                        title: "Phone Number".tr,
                        controller: controller.phoneNumberController.value,
                        countryCodeController: controller.countryCode.value,
                        onPress: () {},
                      ),
                          //:SizedBox.shrink(),
                      const SizedBox(height: 20),
                      RoundedButtonGradiant(
                        title: "Continue".tr,
                        onPress: () async {
                          if (controller.phoneNumberController.value.text.isEmpty) {
                            ShowToastDialog.showToast(
                              "Enter valid phone number",
                            );
                            return;
                          } else {
                            if (controller.formKey.value.currentState!
                                .validate()) {

                              if(Constant.isGustUser){
                                ShowToastDialog.showLoader("please_wait".tr);
                                await FireStoreUtils.deleteUser().then((value) {
                                  Constant.isGustUser = false;
                                  ShowToastDialog.closeLoader();
                                  if (value == true) {
                                    controller.sendCode();
                                  } else {
                                    ShowToastDialog.showToast("Something went wrong".tr);
                                  }
                                });
                              }else{
                                controller.sendCode();
                              }
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          const Expanded(child: Divider(thickness: 1)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              "or log in with".tr,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppThemData.grey06,
                                fontSize: 12,
                                fontFamily: AppThemData.medium,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SegmentButtonGradiant(
                        title: "Continue with Email".tr,
                        onPress: () {
                          Get.to(const LoginWithEmail());
                        },),
                     /* Row(
                        children: [
                          Visibility(
                            visible: Platform.isIOS,
                            child: Expanded(
                              child: InkWell(
                                onTap: () {
                                  controller.loginWithApple();
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: themeChange.getThem()
                                        ? AppThemData.grey10
                                        : AppThemData.grey03,
                                    borderRadius: BorderRadius.circular(200),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        "assets/icon/ic_apple.svg",
                                        height: 24,
                                        width: 24,
                                        color: themeChange.getThem()
                                            ? AppThemData.grey01
                                            : AppThemData.grey08,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Apple'.tr,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: themeChange.getThem()
                                              ? AppThemData.grey01
                                              : AppThemData.grey08,
                                          fontSize: 14,
                                          fontFamily: AppThemData.medium,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                controller.loginWithGoogle();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: themeChange.getThem()
                                      ? AppThemData.grey10
                                      : AppThemData.grey03,
                                  borderRadius: BorderRadius.circular(200),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      "assets/icon/ic_google.svg",
                                      height: 24,
                                      width: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Google'.tr,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: themeChange.getThem()
                                            ? AppThemData.grey01
                                            : AppThemData.grey08,
                                        fontSize: 14,
                                        fontFamily: AppThemData.medium,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),*/
                    ],
                  ),
                ),
              ),
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Text.rich(
              textAlign: TextAlign.center,
              TextSpan(
                text: "${'tapping_next_agree'.tr} ",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  fontFamily: AppThemData.regular,
                  color: themeChange.getThem()
                      ? AppThemData.grey01
                      : AppThemData.grey08,
                ),
                children: <TextSpan>[
                  TextSpan(
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Get.to(const TermsAndConditionScreen(type: "terms"));
                      },
                    text: 'terms_and_conditions'.tr,
                    style: TextStyle(
                      color: themeChange.getThem()
                          ? AppThemData.blueLight
                          : AppThemData.blueLight,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      fontFamily: AppThemData.regular,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  TextSpan(
                    text: " ${"and".tr} ",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: themeChange.getThem()
                          ? AppThemData.grey01
                          : AppThemData.grey08,
                    ),
                  ),
                  TextSpan(
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Get.to(const TermsAndConditionScreen(type: "privacy"));
                      },
                    text: 'privacy_policy'.tr,
                    style: TextStyle(
                      color: themeChange.getThem()
                          ? AppThemData.blueLight
                          : AppThemData.blueLight,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      fontFamily: AppThemData.regular,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
