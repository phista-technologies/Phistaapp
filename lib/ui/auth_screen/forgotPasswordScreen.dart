import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_getx_widget.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

import '../../constant/constant.dart';
import '../../constant/show_toast_dialog.dart';
import '../../controller/forgotPasswordController.dart';
import '../../controller/otp_controller.dart';
import '../../model/user_model.dart';
import '../../themes/app_them_data.dart';
import '../../themes/common_ui.dart';
import '../../themes/round_button_gradiant.dart';
import '../../themes/text_field_widget.dart';
import '../../utils/dark_theme_provider.dart';
import '../../utils/fire_store_utils.dart';
import '../../utils/notification_service.dart';
import '../../utils/utils.dart';
import '../dashboard_screen.dart';
import 'change_password_screen.dart';
import 'information_screen.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

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
                    !controller.otpSend.value?
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Please enter your email".tr,
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
                          TextFieldWidget(
                            title: 'Email Address'.tr,
                            onPress: () {},
                            controller: controller.emailController,
                            hintText: 'Enter Email Address'.tr,
                            textInputType: TextInputType.emailAddress,
                            prefix: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: SvgPicture.asset(
                                "assets/icon/ic_email.svg",
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          RoundedButtonGradiant(
                            title: "Send Otp".tr,
                            onPress: () async {
                              if(controller.emailController.text.trim().isNotEmpty){
                                var isExit = await FireStoreUtils.getUserEmailExist(controller.emailController.text.trim());
                                print(isExit);
                                if(isExit){
                                  Constant.forgotPassOTP = Utils.generateSixDigitCode();
                                  print("Constant.forgotPassOTP :-- ${Constant.forgotPassOTP}");
                                  ShowToastDialog.showLoader("");
/*                           await controller.sendEmailWithTemplate(
                                                      toEmail: 'himanshu.mindiii@gmail.com',
                                                      templateId: 'd-9bc2f671fe9d4a94aa82d36d46c823a9',
                                                      dynamicTemplateData: {
                                                        "name": "OTP for forgot password",
                                                        "app_name": "Phista App ",
                                                        "code": "${Constant.forgotPassOTP}"
                                                      },
                                                    );*/
                                  await controller.sendEmailWithSendGrid(
                                    toEmail: controller.emailController.text.trim(),
                                    subject: 'OTP for forgot password',
                                    content: '${Constant.forgotPassOTP} -- OTP',
                                  ).then((value) {
                                    controller.otpSend.value = true;
                                    ShowToastDialog.closeLoader();

                                  },);
                                }else{
                                  ShowToastDialog.showToast("email not found".tr);
                                }
                              }else{
                                ShowToastDialog.showToast("please enter email".tr);
                              }

                            },
                          ),
                        ],
                      )


                      :
                    Column(
                      children: [
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
                          "We have sent 6-digit code to ${controller.emailController.text.trim()} please enter them below".tr,
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
                          keyboardType: TextInputType.phone,
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
                          title: "Verify".tr,
                          onPress: () async {
                            if (controller.otpController.value.text.length == 6) {
                              if(controller.otpController.value.text.trim() == Constant.forgotPassOTP.toString()){
                                //ShowToastDialog.showLoader("verify_OTP".tr);
                                Get.to(ChangePasswordScreen());
                                //  ShowToastDialog.closeLoader();
                              }else{
                                ShowToastDialog.showToast("enter_valid_otp".tr);
                              }



                            } else {
                              ShowToastDialog.showToast("enter_valid_otp".tr);
                            }
                          },
                        ),
                        const SizedBox(
                          height: 21,
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