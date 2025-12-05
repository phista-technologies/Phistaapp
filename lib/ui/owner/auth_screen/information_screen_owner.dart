
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../constant/constant.dart';
import '../../../constant/show_toast_dialog.dart';
import '../../../controller/owner_controller/information_controller_owner.dart';
import '../../../themes/app_them_data.dart';
import '../../../themes/common_ui.dart';
import '../../../themes/custom_dialog_box.dart';
import '../../../themes/mobile_number_textfield.dart';
import '../../../themes/responsive.dart';
import '../../../themes/round_button_gradiant.dart';
import '../../../themes/text_field_widget.dart';
import '../../../utils/dark_theme_provider.dart';
import '../../../utils/fire_store_utils.dart';
import '../../../utils/utils.dart';

class InformationScreenOwner extends StatelessWidget {
  const InformationScreenOwner({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetX<InformationControllerOwner>(
      init: InformationControllerOwner(),
      builder: (controller) {
        final bool isWeb = kIsWeb || MediaQuery.of(context).size.width >= 800;

        final formContent = Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Profile Image Circle
                 /* ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: controller.profileImage.isEmpty
                        ? Image.asset(
                      Constant.userPlaceHolder,
                      height: isWeb
                          ? Responsive.width(15, context)
                          : Responsive.width(30, context),
                      width: isWeb
                          ? Responsive.width(15, context)
                          : Responsive.width(30, context),
                      fit: BoxFit.cover,
                    )
                        : Image.file(File(controller.profileImage.value),
                      height: isWeb
                          ? Responsive.width(15, context)
                          : Responsive.width(30, context),
                      width: isWeb
                          ? Responsive.width(15, context)
                          : Responsive.width(30, context),
                      fit: BoxFit.cover,
                    ),
                  ),*/
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: controller.profileImage.isEmpty
                        ? Image.asset(
                      Constant.userPlaceHolder,
                      height: isWeb
                          ? Responsive.width(15, context)
                          : Responsive.width(30, context),
                      width: isWeb
                          ? Responsive.width(15, context)
                          : Responsive.width(30, context),
                      fit: BoxFit.cover,
                    )
                        : isWeb
                    // ✅ On Web → show image using bytes
                        ? Image.memory(
                      controller.profileImageBytes!, // <-- use Uint8List
                      height: Responsive.width(15, context),
                      width: Responsive.width(15, context),
                      fit: BoxFit.cover,
                    )
                    // ✅ On Mobile → show file path
                        : Image.file(
                      File(controller.profileImage.value),
                      height: Responsive.width(30, context),
                      width: Responsive.width(30, context),
                      fit: BoxFit.cover,
                    ),
                  ),


                  // Bottom-left Edit Icon
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: InkWell(
                      onTap: () {
                        buildBottomSheet(context, controller);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(6),
                        child: SvgPicture.asset(
                          "assets/images/ic_profile_edit.svg",
                          width: isWeb ? 26 : 30,
                          height: isWeb ? 26 : 30,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
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
            if (controller.gmailLogType.value != "EmailSignup")
              MobileNumberTextField(
                title: "Phone Number".tr,
                controller: controller.phoneNumberController.value,
                countryCodeController: controller.countryCode.value,
                enabled: controller.loginType.value == Constant.phoneLoginType ? false : true,
                dailCode: controller.loginType.value == Constant.phoneLoginType
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
                      bool isExist = await FireStoreUtils.getUserPhoneExist(number);
                      controller.fromPhoneNumberExist = isExist ? "1" : "2";
                    }
                  });
                },
              ),
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
              onChanged: (email) {
                controller.debouncer.run(() async {
                  if (email.isNotEmpty) {
                    bool isExist = await FireStoreUtils.getUserEmailExist(email);
                    controller.fromEmailCheckExist = isExist ? "1" : "2";
                  }
                });
              },
            ),
            if (controller.userModel.value.loginType != "apple" &&
                controller.userModel.value.loginType != "google")
              TextFieldWidget(
                title: 'Password'.tr,
                onPress: () {},
                controller: controller.passwordController.value,
                hintText: 'Enter Password'.tr,
                textInputType: TextInputType.visiblePassword,
                enable: true,
                prefix: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SvgPicture.asset("assets/icon/Password.svg"),
                ),
                obscureText: true,
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
                } else if (controller.emailController.value.text.isEmpty) {
                  ShowToastDialog.showToast("Please enter email address");
                } else if ((controller.userModel.value.loginType != "apple" &&
                    controller.userModel.value.loginType != "google") &&
                    controller.passwordController.value.text.isEmpty) {
                  ShowToastDialog.showToast("Please enter password");
                } else {
                  if (controller.gmailLogType != "EmailSignup") {
                    controller.createAccount();
                  } else {
                    final userCred = await controller.createUserWithEmailPassword(
                      email: controller.emailController.value.text,
                      password: controller.passwordController.value.text.trim(),
                    );
                    if (userCred != null) {
                      controller.createAccountWithEmailNew(userCred.user!.uid);
                    }
                  }
                }
              },
            ),
          ],
        );

        return Scaffold(
          appBar: UiInterface().customAppBar(context, themeChange, "fill_your_profile".tr,centerTile: kIsWeb ?true:false),
          body: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isWeb ? MediaQuery.of(context).size.width * 0.2 : 24,
                  vertical: isWeb ? 40 : 0,
                ),
                child: isWeb
                    ? Center(
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: themeChange.getThem()
                        ? AppThemData.grey03
                        : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: formContent,
                      ),
                    ),
                  ),
                )
                    : formContent,
              ),
            ),
          ),
        );
      },
    );
  }

  buildBottomSheet(BuildContext context, InformationControllerOwner controller) {
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
                    child: Text(
                      "please_select".tr,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          children: [
                            IconButton(
                              onPressed: () => controller.pickFile(source: ImageSource.camera),
                              icon: const Icon(Icons.camera_alt, size: 32),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Text("camera".tr),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          children: [
                            IconButton(
                              onPressed: () => controller.pickFile(source: ImageSource.gallery),
                              icon: const Icon(Icons.photo_library_sharp, size: 32),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Text("gallery".tr),
                            ),
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

