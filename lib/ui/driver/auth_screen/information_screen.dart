import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phista/constant/constant.dart';
import 'package:phista/constant/show_toast_dialog.dart';
import 'package:phista/controller/driver_controller/information_controller.dart';
import 'package:phista/themes/common_ui.dart';
import 'package:phista/themes/mobile_number_textfield.dart';
import 'package:phista/themes/responsive.dart';
import 'package:phista/themes/round_button_gradiant.dart';
import 'package:phista/themes/text_field_widget.dart';
import 'package:phista/utils/dark_theme_provider.dart';
import 'package:phista/utils/fire_store_utils.dart';
import 'package:phista/utils/utils.dart';
import 'package:provider/provider.dart';

import '../../../themes/app_them_data.dart';
import '../../../themes/custom_dialog_box.dart';

class InformationScreen extends StatelessWidget {
  const InformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetX<InformationController>(
      init: InformationController(),
      builder: (controller) {
        return Scaffold(
          appBar: UiInterface().customAppBar(
            context,
            themeChange,
            "fill_your_profile".tr,
          ),
          body: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Center(
                            child: controller.profileImage.isEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(60),
                                    child: Image.asset(
                                      Constant.userPlaceHolder,
                                      height: Responsive.width(30, context),
                                      width: Responsive.width(30, context),
                                      fit: BoxFit.fill,
                                    ),
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(60),
                                    child: Image.file(
                                      File(controller.profileImage.value),
                                      height: Responsive.width(30, context),
                                      width: Responsive.width(30, context),
                                      fit: BoxFit.fill,
                                    ),
                                  )),
                        Positioned(
                          right: Responsive.width(28, context),
                          child: InkWell(
                            onTap: () {
                              buildBottomSheet(context, controller);
                            },
                            child: SvgPicture.asset(
                              "assets/images/ic_profile_edit.svg",
                              width: 40,
                              height: 40,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 53,
                    ),
                    TextFieldWidget(
                      title: 'Full Name'.tr,
                      onPress: () {},
                      controller: controller.fullNameController.value,
                      hintText: 'Enter Full Name'.tr,
                      prefix: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: SvgPicture.asset(
                          "assets/icon/ic_user.svg",
                        ),
                      ),
                    ),
                    if (controller.gmailLogType != "EmailSignup")
                    MobileNumberTextField(
                      title: "Phone Number".tr,
                      controller: controller.phoneNumberController.value,
                      countryCodeController: controller.countryCode.value,
                      enabled:
                          controller.loginType.value == Constant.phoneLoginType
                              ? false
                              : true,
                      dailCode: controller.loginType.value == Constant.phoneLoginType?
                      controller.countryCode.value.text == "+1" ? "CA" : controller.countryCode.value.text :"CA",
                      onPress: () {
                      },
                      isoCode: (isoCode){
                        print("isoCode :-- $isoCode");
                        controller.isoCode = isoCode;
                      },
                      onChange: (number) {
                        controller.debouncer.run(() async{
                          print("number :-- $number");
                          if (number.isNotEmpty){
                           var isExist = await FireStoreUtils.getUserPhoneExist(number);

                           if(isExist){
                             controller.fromPhoneNumberExist = "1";
                           }else{
                             controller.fromPhoneNumberExist = "2";
                           }

                            print("isExist :-- ${controller.fromPhoneNumberExist}");

                          }
                        },);
                      },

                    ),
                    TextFieldWidget(
                      title: 'Email Address'.tr,
                      onPress: () {},
                      controller: controller.emailController,
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

                      onChanged: (email){
                        controller.debouncer.run(() async{
                          print("email :-- $email");
                          if(email.isNotEmpty){
                          bool isExist = await FireStoreUtils.getUserEmailExist(email);
                          print("email Exist :--- $isExist");
                          if(isExist){
                            controller.fromEmailCheckExist = "1";

                          }else{
                            controller.fromEmailCheckExist = "2";
                          }
                          }
                        },);
                      },
                    ),
                    TextFieldWidget(
                      title: "Password".tr,
                      controller: controller.passwordController.value,
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
                    TextFieldWidget(
                      title: 'Coupon Code (Optional)'.tr,
                      onPress: () {},
                      controller: controller.referralCodeController.value,
                      textInputType: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                      ],
                      hintText: 'Enter Coupon Code (Optional)'.tr,
                      prefix: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: SvgPicture.asset(
                          "assets/icon/ic_coupon.svg",
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    RoundedButtonGradiant(
                      title: "create_account".tr,
                      onPress: () async {
                        if (controller.fullNameController.value.text.isEmpty) {
                          ShowToastDialog.showToast("Please enter full name");
                        }
                        else if (controller.gmailLogType != "EmailSignup" && controller
                            .phoneNumberController.value.text.isEmpty) {
                          ShowToastDialog.showToast(
                              "Please enter phone number");
                        }
                        else if (controller.emailController.text.isEmpty) {
                          ShowToastDialog.showToast(
                              "Please enter email address");
                        }
                        else if (controller.passwordController.value.text.isEmpty)
                        {
                          ShowToastDialog.showToast(
                              "Please enter password");
                        }
                        else {
                          if (controller.fromPhoneNumberExist.toString() == "1"){
                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context){
                                  return CustomDialogBox(title: "Alert".tr,
                                    descriptions: "This phone number is already exists. You want to login with existing (******${controller.phoneNumberController.value.text.trim().substring(controller.phoneNumberController.value.text.trim().length - 4)}) number?".tr,
                                    img: SvgPicture.asset('assets/icon/alert_ico.svg'),
                                    positiveString: "Login",
                                    negativeString: "Cancel",
                                    positiveClick: (){
                                      print("login");
                                      controller.sendCode(context,type: "loginExist");
                                    },
                                    negativeClick: (){
                                      print("cancel");
                                      controller.phoneNumberController.value.clear();
                                      Get.back();
                                    },
                                  );
                                });
                          }
                          else  if (controller.fromPhoneNumberExist.toString() == "2"){
                            var isValid =   await Utils
                                .getPhoneNumberValidation(
                                controller.phoneNumberController.value.text.trim(),controller.isoCode,controller.countryCode.value.text.trim());
                            if(isValid){
                              controller.sendCode(context, user: FirebaseAuth.instance.currentUser,
                                  descMsg: 'Enter the 6-digit code sent to your number, to link your number.',
                                  type: "phoneTextFrom");
                            }
                          }
                          else if (controller.fromEmailCheckExist.toString() == "1"){
                            FireStoreUtils.getUserPasswordByEmail(controller.emailController.text.trim()).then((credentials)async {
                              print("credentials:---$credentials");
                              if (credentials != null &&
                                  credentials['password'] != null &&
                                  credentials['password']!.isNotEmpty) {
                                final password = credentials['password']!;
                                final phoneNumber = credentials['phoneNumber'] ?? '';
                                print("User password: $password");
                                print("User phone number: $phoneNumber");

                                if( controller.isFirstTimeDelete){
                                  await FirebaseAuth.instance.signOut();
                                }

                                if (phoneNumber.isEmpty){
                                  showDialog(
                                      barrierDismissible: false,
                                      context: context,
                                      builder: (BuildContext context) {
                                        return CustomDialogBox(
                                          title: "Alert".tr,
                                          descriptions:
                                          "This email is already exists. You want to link existing email with this phone number?"
                                              .tr,
                                          positiveString: "Ok".tr,
                                          negativeString: "Cancel".tr,
                                          positiveClick: () async {
                                            Get.back();
                                            ShowToastDialog.showLoader("please_wait".tr);
                                            if(!controller.isFirstTimeDelete){
                                              await FirebaseAuth.instance.currentUser!.delete().then((value) {
                                                controller.isFirstTimeDelete =true;
                                                controller.signInWithEmailAndPassword(context,controller.emailController.text.trim(), password);
                                              });
                                            }else{
                                              controller.signInWithEmailAndPassword(context,controller.emailController.text.trim(), password);
                                            }

                                          },
                                          negativeClick: () {
                                            controller.emailController.clear();
                                            Get.back();
                                          },
                                          img: SvgPicture.asset('assets/icon/alert_ico.svg'),
                                        );
                                      });
                                }
                                else{
                                  showDialog(context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext context){
                                        return CustomDialogBoxOnlyOk(
                                          title: "Alert".tr,
                                          descriptions: "This email is already linked with other phone number so please try with different email or phone number.".tr,
                                          buttonText: "Okay",
                                          onButtonTap: (){
                                            controller.emailController.clear();
                                            Get.back();
                                          },
                                          img: SvgPicture.asset('assets/icon/alert_ico.svg'),
                                        );
                                      });
                                }
                              }
                            },);
                          }
                          else {
                             if (controller.gmailLogType != "EmailSignup"){
                            controller.createAccount();
                         }
                         else{
                           print("email password");
                           if(Constant.isGustUser){
                             ShowToastDialog.showLoader("please_wait".tr);
                             await FireStoreUtils.deleteUser();
                             Constant.isGustUser = false;
                           }
                           final userCred = await controller.createUserWithEmailPassword(email: controller.emailController.text,
                               password: controller.passwordController.value.text.trim());

                           if (userCred != null) {
                             print("userCred:--${userCred.additionalUserInfo!.isNewUser}");
                             print("userCredmmmm:--${userCred}");

                             controller.createAccountWithEmailNew(userCred.user!.uid);
                           }
                         }
                          }

                        }
                      },
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  buildBottomSheet(BuildContext context, InformationController controller) {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SizedBox(
              height: Responsive.height(22, context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Text("please_select".tr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                                onPressed: () => controller.pickFile(
                                    source: ImageSource.camera),
                                icon: const Icon(
                                  Icons.camera_alt,
                                  size: 32,
                                )),
                            Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Text(
                                "camera".tr,
                                style: const TextStyle(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                                onPressed: () => controller.pickFile(
                                    source: ImageSource.gallery),
                                icon: const Icon(
                                  Icons.photo_library_sharp,
                                  size: 32,
                                )),
                            Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Text(
                                "gallery".tr,
                                style: const TextStyle(),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
