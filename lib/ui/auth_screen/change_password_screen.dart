import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:phista/ui/auth_screen/login_screen.dart';
import 'package:provider/provider.dart';

import '../../constant/constant.dart';
import '../../constant/show_toast_dialog.dart';
import '../../controller/forgotPasswordController.dart';
import '../../themes/app_them_data.dart';
import '../../themes/common_ui.dart';
import '../../themes/round_button_gradiant.dart';
import '../../themes/text_field_widget.dart';
import '../../utils/dark_theme_provider.dart';
import '../../utils/fire_store_utils.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<ForgotPasswordController>(
        init: ForgotPasswordController(),
        builder: (controller) {
          return Scaffold(
            appBar: UiInterface().customAppBar(context, themeChange, "Back".tr),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 75,
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Image.asset(
                        "assets/images/forgot-password.png",
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Please enter new password".tr,
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
                        const SizedBox(
                          height: 12,
                        ),
                        TextFieldWidget(
                          title: "Password".tr,
                          controller: controller.passwordController,
                          onPress: () {},
                          hintText: 'Enter Password'.tr,
                          obscureText: controller.passwordVisible.value,
                          enable: true,
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
                                  controller.passwordVisible.value =
                                      !controller.passwordVisible.value;
                                },
                                child: controller.passwordVisible.value
                                    ? SvgPicture.asset(
                                        "assets/icon/ic_password_show.svg",
                                        colorFilter: ColorFilter.mode(
                                          themeChange.getThem()
                                              ? AppThemData.grey02
                                              : AppThemData.grey08,
                                          BlendMode.srcIn,
                                        ),
                                      )
                                    : SvgPicture.asset(
                                        "assets/icon/ic_password_close.svg",
                                        colorFilter: ColorFilter.mode(
                                          themeChange.getThem()
                                              ? AppThemData.grey02
                                              : AppThemData.grey08,
                                          BlendMode.srcIn,
                                        ),
                                      )),
                          ),
                        ),
                        TextFieldWidget(
                          title: "Confirm Password".tr,
                          controller: controller.confirmPasswordController,
                          onPress: () {},
                          hintText: 'Enter Confirm Password'.tr,
                          obscureText: controller.confirmPasswordVisible.value,
                          enable: true,
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
                                  controller.confirmPasswordVisible.value =
                                      !controller.confirmPasswordVisible.value;
                                },
                                child: controller.confirmPasswordVisible.value
                                    ? SvgPicture.asset(
                                        "assets/icon/ic_password_show.svg",
                                        colorFilter: ColorFilter.mode(
                                          themeChange.getThem()
                                              ? AppThemData.grey02
                                              : AppThemData.grey08,
                                          BlendMode.srcIn,
                                        ),
                                      )
                                    : SvgPicture.asset(
                                        "assets/icon/ic_password_close.svg",
                                        colorFilter: ColorFilter.mode(
                                          themeChange.getThem()
                                              ? AppThemData.grey02
                                              : AppThemData.grey08,
                                          BlendMode.srcIn,
                                        ),
                                      )),
                          ),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        RoundedButtonGradiant(
                          title: "Save".tr,
                          onPress: () async {
                            if (controller.passwordController.text
                                .trim()
                                .isEmpty) {
                              ShowToastDialog.showToast(
                                  "please enter password".tr);
                            } else if (controller.confirmPasswordController.text
                                .trim()
                                .isEmpty) {
                              ShowToastDialog.showToast(
                                  "please enter confirm password".tr);
                            } else if (controller.passwordController.text
                                    .trim() !=
                                controller.confirmPasswordController.text
                                    .trim()) {
                              ShowToastDialog.showToast(
                                  "confirm password does not match".tr);
                            } else {
                              ShowToastDialog.showLoader("");

                              FireStoreUtils.getUserPasswordByEmail(
                                      controller.emailController.text.trim())
                                  .then(
                                (credentials) async {
                                  print("credentials:---$credentials");
                                  if (credentials != null &&
                                      credentials['password'] != null &&
                                      credentials['password']!.isNotEmpty) {
                                    final password = credentials['password']!;
                                    print("User password: $password");
                                    await FirebaseAuth.instance
                                        .signInWithEmailAndPassword(
                                            email: controller
                                                .emailController.text
                                                .trim(),
                                            password: password)
                                        .then(
                                      (user) async {
                                        if (user != null) {
                                          await user.user?.updatePassword(
                                              controller
                                                  .confirmPasswordController
                                                  .text
                                                  .trim());
                                          var isUpdated = await FireStoreUtils
                                              .updateUserPassword(
                                                  controller
                                                      .emailController.text
                                                      .trim(),
                                                  controller
                                                      .confirmPasswordController
                                                      .text
                                                      .trim());
                                          log("isUpdated :-- $isUpdated");
                                          ShowToastDialog.closeLoader();
                                          if (isUpdated) {
                                            ShowToastDialog.showToast(
                                                "password updated successfully"
                                                    .tr);
                                            await FirebaseAuth.instance
                                                .signOut();
                                            Get.offAll(LoginScreen());
                                          } else {
                                            ShowToastDialog.showToast(
                                                "password update failed".tr);
                                          }
                                        }
                                      },
                                    );
                                  }
                                },
                              );
                            }
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }
}
