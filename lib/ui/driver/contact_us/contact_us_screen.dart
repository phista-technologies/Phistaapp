import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:phista/constant/constant.dart';
import 'package:phista/controller/driver_controller/contact_us_controller.dart';
import 'package:phista/themes/app_them_data.dart';
import 'package:phista/themes/common_ui.dart';
import 'package:phista/themes/round_button_fill.dart';
import 'package:phista/themes/text_field_widget.dart';
import 'package:phista/utils/dark_theme_provider.dart';
import 'package:provider/provider.dart';

import '../../../model/user_model.dart';
import '../../../utils/fire_store_utils.dart';
import '../chat/chat_screen.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<ContactUsController>(
      init:ContactUsController(),
      builder: (controller) {
        return Scaffold(
          appBar: UiInterface().customAppBar(
            context,
            themeChange,
            'contact_us'.tr,
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: controller.isLoading.value
                ? Constant.loader()
                : Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: DefaultTabController(
                      length: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "know_your_issues_feedback".tr,
                              style: TextStyle(fontFamily: AppThemData.semiBold, fontSize: 24, color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey10),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            TabBar(
                              labelStyle: const TextStyle(fontFamily: AppThemData.semiBold),
                              labelColor: themeChange.getThem() ? AppThemData.primary07 : AppThemData.grey10,
                              unselectedLabelStyle: const TextStyle(fontFamily: AppThemData.medium),
                              unselectedLabelColor: themeChange.getThem() ? AppThemData.grey06 : AppThemData.grey06,
                              indicatorColor: AppThemData.primary06,
                              indicatorWeight: 1,
                              tabs: [
                                Tab(
                                  child: Text(
                                    "call Us".tr,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: AppThemData.medium,
                                      color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey08,
                                    ),
                                  ),
                                ),
                                Tab(
                                  child: Text(
                                    "email_us".tr,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: AppThemData.medium,
                                      color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey08,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              child: TabBarView(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: Column(
                                      children: [
                                       /* InkWell(
                                          onTap: () {
                                            Constant.makePhoneCall(controller.phone.value);
                                          },
                                          child: Row(
                                            children: [
                                              Icon(Icons.call, color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey07),
                                              const SizedBox(
                                                width: 20,
                                              ),
                                              Text(
                                                controller.phone.value,
                                                style: TextStyle(color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey07),
                                              )
                                            ],
                                          ),
                                        ),*/
                                       /* const SizedBox(
                                          height: 10,
                                        ),
                                        const Divider(),*/
                                        RoundedButtonFill(
                                          radius: 10,
                                          title: "Chat US".tr,
                                          color: themeChange.getThem()
                                              ? AppThemData.primary06
                                              : AppThemData.primary06,
                                          textColor: themeChange.getThem()
                                              ? AppThemData.grey09
                                              : AppThemData.grey09,
                                          isRight: true,
                                          onPress: () async {
                                            await FireStoreUtils.getUserProfile(
                                                "imXiU7CxVUZMmIct9Py5b65yQyr1")
                                                .then((value) {
                                              UserModel userModel = value!;
                                              Get.to(const ChatScreen(),
                                                  arguments: {
                                                    "receiverModel": userModel
                                                  });
                                            });

                                          },
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            Icon(Icons.location_on, color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey07),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            Expanded(
                                              child: Text(
                                                controller.address.value,
                                                style: TextStyle(color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey07),
                                              ),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          TextFieldWidget(
                                            title: 'email'.tr,
                                            onPress: () {},
                                            controller: controller.emailController.value,
                                            textInputType: TextInputType.emailAddress,
                                            hintText: 'Enter email'.tr,
                                            prefix: Padding(
                                              padding: const EdgeInsets.all(12.0),
                                              child: SvgPicture.asset(
                                                "assets/icon/ic_email.svg",
                                              ),
                                            ),
                                          ),
                                          TextFieldWidget(
                                            title: 'FeedBack'.tr,
                                            onPress: () {},
                                            maxLine: 5,
                                            controller: controller.feedbackController.value,
                                            hintText: 'describe_issues_feedback'.tr,
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
             bottomNavigationBar: Container(
            color: themeChange.getThem() ? AppThemData.grey10 : AppThemData.grey11,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: RoundedButtonFill(
                title: "Submit".tr,
                color: AppThemData.primary06,
                onPress: () {
                  controller.submitFeedback();
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
