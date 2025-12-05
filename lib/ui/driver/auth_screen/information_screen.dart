
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
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

  bool isDesktop(BuildContext context) {
    return kIsWeb || MediaQuery.of(context).size.width >= 800;
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetX<InformationController>(
      init: InformationController(),
      builder: (controller) {
        final profileSize = isDesktop(context)
            ? Responsive.width(15, context)
            : Responsive.width(30, context);

        final content = Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Circle
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
        controller.profileImage.isEmpty
        ? ClipRRect(
        borderRadius: BorderRadius.circular(100),
            child: Image.asset(
        Constant.userPlaceHolder,
        height: profileSize,
        width: profileSize,
        fit: BoxFit.cover,
        ),
        )
            : ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: kIsWeb
        ? Image.memory(
        controller.profileImageBytes!,
        height: profileSize,
        width: profileSize,
        fit: BoxFit.cover,
        )
            : Image.file(
        File(controller.profileImage.value),
        height: profileSize,
        width: profileSize,
        fit: BoxFit.cover,
        ),
        ),

        /*controller.profileImage.isEmpty
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.asset(
                      Constant.userPlaceHolder,
                      height: profileSize,
                      width: profileSize,
                      fit: BoxFit.cover,
                    ),
                  )
                      : ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.file(
                      File(controller.profileImage.value),
                      height: profileSize,
                      width: profileSize,
                      fit: BoxFit.cover,
                    ),
                  ),*/
        Positioned(
                    bottom: 6,
                    right: 6,
                    // bottom: 0,
                    // left: profileSize / 2 - 40,
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
            ),
            const SizedBox(height: 50),

            // Full Name
            TextFieldWidget(
              title: 'Full Name'.tr,
              onPress: () {},
              controller: controller.fullNameController.value,
              hintText: 'Enter Full Name'.tr,
              prefix: Padding(
                padding: const EdgeInsets.all(12.0),
                child: SvgPicture.asset("assets/icon/ic_user.svg"),
              ),
            ),

            if (controller.gmailLogType != "EmailSignup")
              MobileNumberTextField(
                title: "Phone Number".tr,
                controller: controller.phoneNumberController.value,
                countryCodeController: controller.countryCode.value,
                enabled: controller.loginType.value == Constant.phoneLoginType
                    ? false
                    : true,
                dailCode:
                controller.loginType.value == Constant.phoneLoginType
                    ? controller.countryCode.value.text == "+1"
                    ? "CA"
                    : controller.countryCode.value.text
                    : "CA",
                onPress: () {},
                isoCode: (isoCode) {
                  controller.isoCode = isoCode;
                },
                onChange: (number) {
                  controller.debouncer.run(() async {
                    if (number.isNotEmpty) {
                      bool isExist =
                      await FireStoreUtils.getUserPhoneExist(number);
                      controller.fromPhoneNumberExist =
                      isExist ? "1" : "2";
                    }
                  });
                },
              ),

            // Email
            TextFieldWidget(
              title: 'Email Address'.tr,
              onPress: () {},
              controller: controller.emailController,
              hintText: 'Enter Email Address'.tr,
              textInputType: TextInputType.emailAddress,
              enable: controller.loginType.value == Constant.googleLoginType
                  ? false
                  : true,
              prefix: Padding(
                padding: const EdgeInsets.all(12.0),
                child: SvgPicture.asset("assets/icon/ic_email.svg"),
              ),
              onChanged: (email) {
                controller.debouncer.run(() async {
                  if (email.isNotEmpty) {
                    bool isExist =
                    await FireStoreUtils.getUserEmailExist(email);
                    controller.fromEmailCheckExist = isExist ? "1" : "2";
                  }
                });
              },
            ),

            // Password
            if (controller.userModel.value.loginType != "apple" &&
                controller.userModel.value.loginType != "google")
              TextFieldWidget(
                title: "Password".tr,
                controller: controller.passwordController.value,
                onPress: () {},
                hintText: 'Enter Password'.tr,
                obscureText: controller.passwordVisible.value,
                enable: true,
                prefix: Padding(
                  padding: const EdgeInsets.all(12),
                  child: SvgPicture.asset("assets/icon/Password.svg"),
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
                    ),
                  ),
                ),
              ),

            // Coupon
            TextFieldWidget(
              title: 'Coupon Code (Optional)'.tr,
              onPress: () {},
              controller: controller.referralCodeController.value,
              textInputType:
              const TextInputType.numberWithOptions(decimal: true, signed: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[0-9]')),
              ],
              hintText: 'Enter Coupon Code (Optional)'.tr,
              prefix: Padding(
                padding: const EdgeInsets.all(12.0),
                child: SvgPicture.asset("assets/icon/ic_coupon.svg"),
              ),
            ),

            const SizedBox(height: 40),

            RoundedButtonGradiant(
              title: "create_account".tr,
              onPress: () async {
                if (controller.fullNameController.value.text.isEmpty) {
                  ShowToastDialog.showToast("Please enter full name");
                } else if (controller.gmailLogType != "EmailSignup" &&
                    controller.phoneNumberController.value.text.isEmpty) {
                  ShowToastDialog.showToast("Please enter phone number");
                } else if (controller.emailController.text.isEmpty) {
                  ShowToastDialog.showToast("Please enter email address");
                } else if ((controller.userModel.value.loginType != "apple" &&
                    controller.userModel.value.loginType != "google") &&
                    controller.passwordController.value.text.isEmpty) {
                  ShowToastDialog.showToast("Please enter password");
                } else {
                  if (controller.gmailLogType != "EmailSignup") {
                    controller.createAccount();
                  } else {
                    if (Constant.isGustUser) {
                      ShowToastDialog.showLoader("please_wait".tr);
                      await FireStoreUtils.deleteUser();
                      Constant.isGustUser = false;
                    }
                    final userCred =
                    await controller.createUserWithEmailPassword(
                      email: controller.emailController.text,
                      password: controller.passwordController.value.text.trim(),
                    );
                    if (userCred != null) {
                      controller
                          .createAccountWithEmailNew(userCred.user!.uid);
                    }
                  }
                }
              },
            ),
            const SizedBox(height: 40),
          ],
        );

        return Scaffold(
          appBar: UiInterface().customAppBar(
            context,
            themeChange,
            "fill_your_profile".tr,
            centerTile: kIsWeb ?true: false
          ),
          body: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding:
                EdgeInsets.symmetric(horizontal: isDesktop(context) ? 0 : 24),
                child: isDesktop(context)
                    ? Center(
                  child: Container(
                    width: 700,
                    padding: const EdgeInsets.all(32),
                    margin: const EdgeInsets.symmetric(vertical: 30),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: content,
                  ),
                )
                    : content,
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
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          children: [
                            IconButton(
                              onPressed: () =>
                                  controller.pickFile(source: ImageSource.camera),
                              icon: const Icon(Icons.camera_alt, size: 32),
                            ),
                            const SizedBox(height: 4),
                            Text("camera".tr),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          children: [
                            IconButton(
                              onPressed: () =>
                                  controller.pickFile(source: ImageSource.gallery),
                              icon:
                              const Icon(Icons.photo_library_sharp, size: 32),
                            ),
                            const SizedBox(height: 4),
                            Text("gallery".tr),
                          ],
                        ),
                      ),
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
