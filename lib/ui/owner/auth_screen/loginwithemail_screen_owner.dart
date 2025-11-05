/*

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_getx_widget.dart';
import 'package:provider/provider.dart';
import '../../../constant/constant.dart';
import '../../../constant/show_toast_dialog.dart';
import '../../../controller/owner_controller/login_controller_owner.dart';
import '../../../themes/app_them_data.dart';
import '../../../themes/responsive.dart';
import '../../../themes/round_button_gradiant.dart';
import '../../../themes/segment_button_gradiant.dart';
import '../../../themes/text_field_widget.dart';
import '../../../utils/dark_theme_provider.dart';
import 'forgotPasswordScreen_owner.dart';
import 'information_screen_owner.dart';

class LoginWithEmailOwner extends StatelessWidget {
  const LoginWithEmailOwner({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<LoginControllerOwner>(
      init: LoginControllerOwner(),
      builder: (controller) {
        return Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: Responsive.height(9, context)),
                  InkWell(
                    child: Icon(Icons.arrow_back, color: themeChange.getThem() ? AppThemData.grey02 : AppThemData.grey11),
                    onTap: (){
                      Get.back();
                    },
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Image.asset(
                      "assets/images/login_logo.png",
                      width: 100,
                      height: 100,
                    ),
                  ),
                  SizedBox(height: Responsive.height(2, context)),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      "Sign in with Email".tr,
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
                  ),

                  SizedBox(height: Responsive.height(8, context)),
                  TextFieldWidget(
                    title: 'Email Address'.tr,
                    onPress: () {},
                    controller: controller.emailController.value,
                    hintText: 'Enter Email Address'.tr,
                    textInputType: TextInputType.emailAddress,
                    enable:
                    controller.loginType.value == Constant.googleLoginType
                        ? false
                        : true,
                    prefix: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SvgPicture.asset(
                        "assets/icon/ic_email.svg",
                      ),
                    ),
                  ),
                  TextFieldWidget(
                    title: "Password".tr,
                    controller: controller.passwordController.value,
                    onPress: () {},
                    hintText: 'Enter Password'.tr,
                    obscureText: controller.passwordVisible.value,
                    prefix: Padding(
                      padding: const EdgeInsets.all(12),
                      child: SvgPicture.asset(
                        "assets/icon/Password.svg",

                      ),
                    ),
                    suffix: Padding(
                      padding: const EdgeInsets.all(12),
                      child: InkWell(
                          onTap: () {
                            controller.passwordVisible.value = !controller.passwordVisible.value;
                          },
                          child: controller.passwordVisible.value
                              ? SvgPicture.asset(
                            "assets/icon/ic_password_show.svg",
                            colorFilter: ColorFilter.mode(
                              themeChange.getThem() ? AppThemData.grey02 : AppThemData.grey08,
                              BlendMode.srcIn,
                            ),
                          )
                              : SvgPicture.asset(
                            "assets/icon/ic_password_close.svg",
                            colorFilter: ColorFilter.mode(
                              themeChange.getThem() ? AppThemData.grey02 : AppThemData.grey08,
                              BlendMode.srcIn,
                            ),
                          )),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () async {
                        Get.to(ForgotPasswordScreenOwner());
                      },
                      child: Text(
                        "Forgot Password?".tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppThemData.warning06,
                          fontSize: 17,
                          fontFamily: AppThemData.medium,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  RoundedButtonGradiant(
                    title: "Login".tr,
                    onPress: () {
                      if (controller.checkValidation() != null) {
                        ShowToastDialog.showToast(controller.checkValidation().toString());
                      } else {
                        print("Enter");
                        controller.signInWithEmailAndPassword();

                      }
                    },
                  ),
                  const SizedBox(height: 30),
                  SegmentButtonGradiant(
                    title: "Create account".tr,
                    onPress: () {
                      Get.to(const InformationScreenOwner(), arguments: {
                        "TypeFrom": "EmailSignup",
                      });
                    },),



                ],
              ),
            ),
          ),
          // bottomNavigationBar: Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          //   child: Text.rich(
          //     textAlign: TextAlign.center,
          //     TextSpan(
          //       text: "${'tapping_next_agree'.tr} ",
          //       style: TextStyle(
          //         fontWeight: FontWeight.w500,
          //         fontSize: 12,
          //         fontFamily: AppThemData.regular,
          //         color: themeChange.getThem()
          //             ? AppThemData.grey01
          //             : AppThemData.grey08,
          //       ),
          //       children: <TextSpan>[
          //         TextSpan(
          //           recognizer: TapGestureRecognizer()
          //             ..onTap = () {
          //               Get.to(const TermsAndConditionScreen(type: "terms"));
          //             },
          //           text: 'terms_and_conditions'.tr,
          //           style: TextStyle(
          //             color: themeChange.getThem()
          //                 ? AppThemData.blueLight
          //                 : AppThemData.blueLight,
          //             fontWeight: FontWeight.w500,
          //             fontSize: 12,
          //             fontFamily: AppThemData.regular,
          //             decoration: TextDecoration.underline,
          //           ),
          //         ),
          //         TextSpan(
          //           text: " ${"and".tr} ",
          //           style: TextStyle(
          //             fontWeight: FontWeight.w500,
          //             fontSize: 16,
          //             color: themeChange.getThem()
          //                 ? AppThemData.grey01
          //                 : AppThemData.grey08,
          //           ),
          //         ),
          //         TextSpan(
          //           recognizer: TapGestureRecognizer()
          //             ..onTap = () {
          //               Get.to(const TermsAndConditionScreen(type: "privacy"));
          //             },
          //           text: 'privacy_policy'.tr,
          //           style: TextStyle(
          //             color: themeChange.getThem()
          //                 ? AppThemData.blueLight
          //                 : AppThemData.blueLight,
          //             fontWeight: FontWeight.w500,
          //             fontSize: 12,
          //             fontFamily: AppThemData.regular,
          //             decoration: TextDecoration.underline,
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
        );
      },
    );
  }
}
*/


import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_getx_widget.dart';
import 'package:provider/provider.dart';
import '../../../constant/constant.dart';
import '../../../constant/show_toast_dialog.dart';
import '../../../controller/owner_controller/login_controller_owner.dart';
import '../../../themes/app_them_data.dart';
import '../../../themes/responsive.dart';
import '../../../themes/round_button_gradiant.dart';
import '../../../themes/segment_button_gradiant.dart';
import '../../../themes/text_field_widget.dart';
import '../../../utils/dark_theme_provider.dart';
import 'forgotPasswordScreen_owner.dart';
import 'information_screen_owner.dart';
import 'package:flutter/foundation.dart';

class LoginWithEmailOwner extends StatelessWidget {
  const LoginWithEmailOwner({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetX<LoginControllerOwner>(
      init: LoginControllerOwner(),
      builder: (controller) {
        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              child: kIsWeb
                  ? Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  margin: const EdgeInsets.all(20),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: _buildEmailLoginForm(controller, themeChange, context),
                    ),
                  ),
                ),
              )
                  : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildEmailLoginForm(controller, themeChange, context),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmailLoginForm(
      LoginControllerOwner controller, DarkThemeProvider themeChange, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: Responsive.height(9, context)),
        InkWell(
          child: Icon(
            Icons.arrow_back,
            color: themeChange.getThem() ? AppThemData.grey02 : AppThemData.grey11,
          ),
          onTap: () {
            Get.back();
          },
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Image.asset(
            "assets/images/login_logo.png",
            width: 100,
            height: 100,
          ),
        ),
        SizedBox(height: Responsive.height(2, context)),
        Align(
          alignment: Alignment.topCenter,
          child: Text(
            "Sign in with Email".tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey10,
              fontSize: 24,
              fontFamily: AppThemData.semiBold,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        SizedBox(height: Responsive.height(8, context)),
        TextFieldWidget(
          title: 'Email Address'.tr,
          onPress: () {},
          controller: controller.emailController.value,
          hintText: 'Enter Email Address'.tr,
          textInputType: TextInputType.emailAddress,
          enable: controller.loginType.value == Constant.googleLoginType ? false : true,
          prefix: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SvgPicture.asset("assets/icon/ic_email.svg"),
          ),
        ),
        TextFieldWidget(
          title: "Password".tr,
          controller: controller.passwordController.value,
          onPress: () {},
          hintText: 'Enter Password'.tr,
          obscureText: controller.passwordVisible.value,
          prefix: Padding(
            padding: const EdgeInsets.all(12),
            child: SvgPicture.asset("assets/icon/Password.svg"),
          ),
          suffix: Padding(
            padding: const EdgeInsets.all(12),
            child: InkWell(
              onTap: () {
                controller.passwordVisible.value = !controller.passwordVisible.value;
              },
              child: controller.passwordVisible.value
                  ? SvgPicture.asset(
                "assets/icon/ic_password_show.svg",
                colorFilter: ColorFilter.mode(
                  themeChange.getThem() ? AppThemData.grey02 : AppThemData.grey08,
                  BlendMode.srcIn,
                ),
              )
                  : SvgPicture.asset(
                "assets/icon/ic_password_close.svg",
                colorFilter: ColorFilter.mode(
                  themeChange.getThem() ? AppThemData.grey02 : AppThemData.grey08,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: InkWell(
            onTap: () async {
              Get.to(ForgotPasswordScreenOwner());
            },
            child: Text(
              "Forgot Password?".tr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppThemData.warning06,
                fontSize: 17,
                fontFamily: AppThemData.medium,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(height: 30),
        RoundedButtonGradiant(
          title: "Login".tr,
          onPress: () {
            if (controller.checkValidation() != null) {
              ShowToastDialog.showToast(controller.checkValidation().toString());
            } else {
              controller.signInWithEmailAndPassword();
            }
          },
        ),
        const SizedBox(height: 30),
        SegmentButtonGradiant(
          title: "Create account".tr,
          onPress: () {
            Get.to(
              const InformationScreenOwner(),
              arguments: {"TypeFrom": "EmailSignup"},
            );
          },
        ),
      ],
    );
  }
}
