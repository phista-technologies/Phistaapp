import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:provider/provider.dart';

import '../../../constant/constant.dart';
import '../../../controller/owner_controller/language_controller_owner.dart';
import '../../../services/localization_service.dart';
import '../../../themes/app_them_data.dart';
import '../../../themes/common_ui.dart';
import '../../../themes/round_button_fill.dart';
import '../../../utils/dark_theme_provider.dart';
import '../../../utils/preferences.dart';


class ChooseLanguageScreenOwner extends StatelessWidget {
  const ChooseLanguageScreenOwner({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<LanguageControllerOwner>(
      init: LanguageControllerOwner(),
      builder: (controller) {
        return Scaffold(
          appBar: UiInterface().customAppBar(
            context,
            themeChange,
            'change_language'.tr,
          ),
          body: controller.isLoading.value
              ? Constant.loader()
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: controller.languageList.length,
                        itemBuilder: (context, int index) {
                          return Obx(
                            () => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    controller.languageList[index].name.toString(),
                                    style: TextStyle(fontSize: 16, fontFamily: AppThemData.medium, color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey10),
                                  ),
                                  Radio(
                                      value: controller.languageList[index],
                                      groupValue: controller.selectedLanguage.value,
                                      activeColor: AppThemData.primary06,
                                      onChanged: (value) {
                                        controller.selectedLanguage.value = controller.languageList[index];
                                      })
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
          bottomNavigationBar: Container(
            color: themeChange.getThem() ? AppThemData.grey10 : AppThemData.grey11,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: RoundedButtonFill(
                title: "Save".tr,
                color: AppThemData.primary06,
                onPress: () {
                  LocalizationService().changeLocale(controller.selectedLanguage.value.code.toString());
                  Preferences.setString(
                    Preferences.languageCodeKey,
                    jsonEncode(
                      controller.selectedLanguage.value,
                    ),
                  );
                  Get.back(result: true);
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
