import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../../constant/constant.dart';
import '../../../constant/show_toast_dialog.dart';
import '../../../controller/owner_controller/login_controller_owner.dart';
import '../../../themes/app_them_data.dart';
import '../../../themes/mobile_number_textfield.dart';
import '../../../themes/responsive.dart';
import '../../../themes/round_button_gradiant.dart';
import '../../../themes/segment_button_gradiant.dart';
import '../../../utils/dark_theme_provider.dart';
import '../../../utils/fire_store_utils.dart';
import '../terms_and_condition/terms_and_condition_screen_owner.dart';
import 'forgotPasswordScreen_owner.dart';
import 'loginwithemail_screen_owner.dart';

class LoginScreenOwner extends StatelessWidget {
  const LoginScreenOwner({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetBuilder<LoginControllerOwner>(
      init: LoginControllerOwner(),
      builder: (controller) {
        return Scaffold(
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Form(
                        key: controller.formKey.value,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Obx(
                            () => Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(height: 40),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: InkWell(
                                    child: Icon(Icons.arrow_back, color: themeChange.getThem() ? AppThemData.grey02 : AppThemData.grey11),
                                    onTap: (){
                                      Get.back();
                                    },
                                  ),
                                ),
                                Image.asset(
                                  "assets/images/login_logo.png",
                                  width: 120,
                                  height: 80,
                                ),
                                const SizedBox(height: 40),
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
                                SizedBox(height: Responsive.height(5, context)),
                                Column(
                                  children: [
                                    if (!kIsWeb && Platform.isIOS)
                                      Visibility(
                                        visible:!kIsWeb && Platform.isIOS,
                                        child: InkWell(
                                          onTap: () async {
                                            if(Constant.isGustUser){
                                              ShowToastDialog.showLoader("please_wait".tr);
                                              await FireStoreUtils.deleteUser().then((value) {
                                                Constant.isGustUser = false;
                                                ShowToastDialog.closeLoader();
                                                if (value == true) {
                                                  controller.loginWithApple();
                                                } else {
                                                  ShowToastDialog.showToast(
                                                      "Something went wrong".tr);
                                                }
                                              });
                                            }
                                            else{
                                              controller.loginWithApple();
                                            }



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
                                                const SizedBox(width: 12),
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
                                    if (!kIsWeb && Platform.isIOS)
                                      const SizedBox(height: 12),
                                    InkWell(
                                      onTap: () async {
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
                                        }
                                        else{
                                          controller.loginWithGoogle();
                                        }

                                      },
                                      child: Container(
                                        width: Responsive.width(90, context),
                                        height: Responsive.height(7, context),
                                        decoration: BoxDecoration(
                                          color: themeChange.getThem()
                                              ? AppThemData.grey10
                                              : AppThemData.grey03,
                                          borderRadius:
                                          BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          crossAxisAlignment:
                                          CrossAxisAlignment.center,
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
                                                fontFamily:
                                                AppThemData.medium,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    const Expanded(
                                        child: Divider(thickness: 1)),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
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
                                MobileNumberTextField(
                                  validator: ((v) {
                                    if (v?.isEmpty == true) {
                                      return "Enter valid phone number".tr;
                                    }
                                    return null;
                                  }),
                                  title: "Phone Number".tr,
                                  controller: controller
                                      .phoneNumberController.value,
                                  countryCodeController: controller.countryCode.value,
                                  onPress: () {},
                                ),
                                // SizedBox(
                                //   height: 40,
                                //   child: Row(
                                //     mainAxisAlignment:
                                //         MainAxisAlignment.spaceBetween,
                                //     children: [
                                //       // Login with Phone
                                //       InkWell(
                                //         onTap: () {
                                //           controller.fromLoginType.value =
                                //               "Mobile";
                                //         },
                                //         child: Container(
                                //           width: Responsive.width(42, context),
                                //           height:
                                //               Responsive.height(4.5, context),
                                //           decoration: BoxDecoration(
                                //             gradient: controller
                                //                         .fromLoginType.value ==
                                //                     "Mobile"
                                //                 ? const LinearGradient(
                                //                     begin:
                                //                         Alignment.bottomCenter,
                                //                     end: Alignment.topCenter,
                                //                     colors:
                                //                         AppThemData.gradient03,
                                //                   )
                                //                 : null,
                                //             color: controller
                                //                         .fromLoginType.value ==
                                //                     "Mobile"
                                //                 ? null
                                //                 : AppThemData.grey03,
                                //             borderRadius:
                                //                 const BorderRadius.only(
                                //               topLeft: Radius.circular(20),
                                //               topRight: Radius.circular(20),
                                //             ),
                                //           ),
                                //           child: Center(
                                //             child: Text(
                                //               "Phone",
                                //               textAlign: TextAlign.center,
                                //               style: TextStyle(
                                //                 fontFamily: AppThemData.medium,
                                //                 color:
                                //                     controller.fromLoginType ==
                                //                             "Phone"
                                //                         ? AppThemData.grey11
                                //                         : AppThemData.grey09,
                                //                 fontSize: 15,
                                //                 fontWeight: FontWeight.w500,
                                //               ),
                                //             ),
                                //           ),
                                //         ),
                                //       ),
                                //
                                //       // Login with Email
                                //       InkWell(
                                //         onTap: () {
                                //           controller.fromLoginType.value =
                                //               "email";
                                //         },
                                //         child: Container(
                                //           width: Responsive.width(42, context),
                                //           height:
                                //               Responsive.height(4.5, context),
                                //           decoration: BoxDecoration(
                                //             gradient: controller
                                //                         .fromLoginType ==
                                //                     "email"
                                //                 ? const LinearGradient(
                                //                     begin:
                                //                         Alignment.bottomCenter,
                                //                     end: Alignment.topCenter,
                                //                     colors:
                                //                         AppThemData.gradient03,
                                //                   )
                                //                 : null,
                                //             color: controller.fromLoginType ==
                                //                     "email"
                                //                 ? null
                                //                 : AppThemData.grey03,
                                //             borderRadius:
                                //                 const BorderRadius.only(
                                //               topLeft: Radius.circular(20),
                                //               topRight: Radius.circular(20),
                                //             ),
                                //           ),
                                //           child: Center(
                                //             child: Text(
                                //               "Email",
                                //               textAlign: TextAlign.center,
                                //               style: TextStyle(
                                //                 fontFamily: AppThemData.medium,
                                //                 color:
                                //                     controller.fromLoginType ==
                                //                             "email"
                                //                         ? AppThemData.grey09
                                //                         : AppThemData.grey11,
                                //                 fontSize: 15,
                                //                 fontWeight: FontWeight.w500,
                                //               ),
                                //             ),
                                //           ),
                                //         ),
                                //       ),
                                //     ],
                                //   ),
                                // ),
                                // SizedBox(height: Responsive.height(5, context)),
                                const SizedBox(height: 20),
                                RoundedButtonGradiant(
                                  title:"Continue".tr,

                                  onPress: () async {
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
                                      }
                                      else{
                                        controller.sendCode();
                                      }

                                    }

                                  },
                                ),
                                const SizedBox(height: 12),

                                Row(
                                  children: [
                                    const Expanded(
                                        child: Divider(thickness: 1)),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
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
                                    Get.to(const LoginWithEmailOwner());
                                  },),
                                const SizedBox(height: 20),
                                const Spacer(), // Pushes Terms & Conditions to the bottom
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
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
                          Get.to(
                            const TermsAndConditionScreenOwner(
                              type: "terms",
                            ),
                          );
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
                              : AppThemData.grey08),
                    ),
                    TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Get.to(
                            const TermsAndConditionScreenOwner(
                              type: "privacy",
                            ),
                          );
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
              )),
        );
      },
    );
  }
}
