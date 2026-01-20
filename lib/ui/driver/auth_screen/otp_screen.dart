import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phista/constant/constant.dart';
import 'package:phista/constant/show_toast_dialog.dart';
import 'package:phista/controller/driver_controller/otp_controller.dart';
import 'package:phista/model/user_model.dart';
import 'package:phista/themes/app_them_data.dart';
import 'package:phista/themes/common_ui.dart';
import 'package:phista/themes/round_button_gradiant.dart';
import 'package:phista/utils/dark_theme_provider.dart';
import 'package:phista/utils/fire_store_utils.dart';
import 'package:phista/utils/notification_service.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

import '../../../controller/driver_controller/dashboard_controller.dart';
import '../../../controller/driver_controller/home_controller.dart';

import '../dashboard_screen.dart';
import 'information_screen.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<OtpController>(
        init: OtpController(),
        builder: (controller) {
          return Scaffold(
            appBar: UiInterface().customAppBar(context, themeChange, "Back".tr),
            body: controller.isLoading.value
                ? Constant.loader()
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 75,
                          ),
                          Text(
                            "Verify your phone".tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey10,
                              fontSize: 24,
                              fontFamily: AppThemData.semiBold,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          Text(
                            "We have sent 6-digit code to ${controller.countryCode.value} ${controller.phoneNumber.value} please enter them below".tr,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppThemData.grey07,
                              fontSize: 14,
                              fontFamily: AppThemData.regular,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(
                            height: 72,
                          ),
                          PinCodeTextField(
                            length: 6,
                            appContext: context,
                            keyboardType: TextInputType.number,
                            enablePinAutofill: true,
                            hintCharacter: "-",
                            hintStyle: TextStyle(color: themeChange.getThem() ? AppThemData.grey06 : AppThemData.grey06, fontFamily: AppThemData.regular),
                            textStyle: TextStyle(color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey08, fontFamily: AppThemData.regular),
                            pinTheme: PinTheme(
                              selectedColor: themeChange.getThem() ? AppThemData.primary06 : AppThemData.primary06,
                              activeColor: themeChange.getThem() ? AppThemData.grey05 : AppThemData.grey05,
                              inactiveColor: themeChange.getThem() ? AppThemData.grey05 : AppThemData.grey05,
                              disabledColor: themeChange.getThem() ? AppThemData.grey05 : AppThemData.grey05,
                              shape: PinCodeFieldShape.underline,
                            ),
                            cursorColor: AppThemData.primary06,
                            controller: controller.otpController.value,
                            onCompleted: (v) async {},
                            onChanged: (value) {},
                          ),
                          const SizedBox(
                            height: 50,
                          ),
                          RoundedButtonGradiant(
                            title: "Verify & Next".tr,
                            onPress: () async {
                              if (controller.otpController.value.text.length == 6) {
                                ShowToastDialog.showLoader("verify_OTP".tr);

                                if(controller.screenType == "info"){
                                  FirebaseAuth.instance.currentUser?.delete();
                                }


                                PhoneAuthCredential credential =
                                    PhoneAuthProvider.credential(verificationId: controller.verificationId.value, smsCode: controller.otpController.value.text);
                                String? fcmToken = "";
                                if (!kIsWeb){
                                if(Platform.isIOS){
                                  fcmToken = await NotificationService.getToken();
                                }else{
                                  fcmToken = await NotificationService.getToken();
                                } }else{
          fcmToken = await NotificationService.getWebToken();
          }

                                await FirebaseAuth.instance.signInWithCredential(credential).then((value) async {
                                  if (value.additionalUserInfo!.isNewUser) {
                                    UserModel userModel = UserModel();
                                    userModel.id = value.user!.uid;
                                    userModel.countryCode = controller.countryCode.value;
                                    userModel.phoneNumber = controller.phoneNumber.value;
                                    userModel.loginType = Constant.phoneLoginType;
                                    userModel.fcmToken = fcmToken;

                                    ShowToastDialog.closeLoader();
                                    Get.off(const InformationScreen(), arguments: {
                                      "userModel": userModel,
                                      "verificationId" : controller.verificationId.value,
                                      "otp" : controller.otpController.value.text,
                                    });
                                  }
                                  else {
                                    await FireStoreUtils.userExistOrNot(value.user!.uid).then((userExit) async {
                                      ShowToastDialog.closeLoader();
                                      if (userExit == true) {
                                        UserModel? userModel = await FireStoreUtils.getUserProfile(value.user!.uid);
                                        if (userModel != null) {
                                          if (userModel.isActive == true && (userModel.role == "customer" || userModel.role == "owner")) {
                                            Constant.currentUserModel.value?.role = userModel.role;
                                            Get.delete<DashboardScreenController>();
                                            Get.delete<HomeController>();
                                            Get.offAll(const DashBoardScreen());
                                          } /*else if (userModel.role != "customer") {
                                            await FirebaseAuth.instance.signOut();
                                            ShowToastDialog.showToast("please enter valid credentials".tr);
                                          } */else {
                                            await FirebaseAuth.instance.signOut();
                                            ShowToastDialog.showToast("This user is disable please contact administrator".tr);
                                          }
                                        }
                                      }
                                      else {
                                        UserModel userModel = UserModel();
                                        userModel.id = value.user!.uid;
                                        userModel.countryCode = controller.countryCode.value;
                                        userModel.phoneNumber = controller.phoneNumber.value;
                                        userModel.loginType = Constant.phoneLoginType;
                                        userModel.fcmToken = fcmToken;

                                        Get.off(const InformationScreen(), arguments: {
                                          "userModel": userModel,
                                        });
                                      }
                                    });
                                  }
                                }).catchError((error) {
                                  ShowToastDialog.closeLoader();
                                  ShowToastDialog.showToast("invalid_code".tr);
                                });
                              } else {
                                ShowToastDialog.showToast("enter_valid_otp".tr);
                              }
                            },
                          ),
                          const SizedBox(
                            height: 21,
                          ),
                          Text.rich(
                            textAlign: TextAlign.center,
                            TextSpan(
                              text: "${'Did’t Receive a code ?'.tr} ",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                fontFamily: AppThemData.medium,
                                color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey08,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      controller.otpController.value.clear();
                                      controller.sendOTP();
                                    },
                                  text: 'Resend Code'.tr,
                                  style: TextStyle(
                                    color: themeChange.getThem() ? AppThemData.blueLight : AppThemData.blueLight,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                    fontFamily: AppThemData.medium,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
          );
        });
  }
}
