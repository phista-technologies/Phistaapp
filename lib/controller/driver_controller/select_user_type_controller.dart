
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../constant/constant.dart';
import '../../constant/show_toast_dialog.dart';
import '../../model/language_model.dart';
import '../../model/user_model.dart';
import '../../services/localization_service.dart';
import '../../themes/app_them_data.dart';
import '../../themes/round_button_fill.dart';
import '../../ui/driver/dashboard_screen.dart';
import '../../ui/owner/choose_language/choose_language_screen_owner.dart';
import '../../utils/dark_theme_provider.dart';
import '../../utils/fire_store_utils.dart';
import '../../utils/notification_service.dart';
import '../../utils/preferences.dart';
import 'dashboard_controller.dart';
import 'home_controller.dart';

class SelectUserTypeController extends GetxController{

  var counter = 0.obs;
  var isSelected = 0.obs;
  Rx<LanguageModel> selectedLanguage = LanguageModel().obs;
  RxList<LanguageModel> languageList = <LanguageModel>[].obs;


  @override
  void onInit() {
    super.onInit();
    if (!Constant.isLanguagePopupShow){
      Constant.isLanguagePopupShow = true;
      ShowToastDialog.showLoader("please_wait".tr);
      Future.delayed(Duration.zero,() {
        getLanguage();
      },);
    }

  }

  getLanguage() async {
    await FireStoreUtils.getLanguage().then((value) {
      if (value != null) {
        languageList.value = value;
        if (Preferences.getString(Preferences.languageCodeKey).toString().isNotEmpty) {
          LanguageModel pref = Constant.getLanguage();
          for (var element in languageList) {
            if (element.id == pref.id) {
              selectedLanguage.value = element;
            }
          }
        }
        if (selectedLanguage.value.id == null || selectedLanguage.value.id!.isEmpty) {
          final defaultFrench = languageList.firstWhere(
                (lang) => lang.code?.toLowerCase() == "fr",
            orElse: () => languageList.first, // fallback if French not found
          );
          selectedLanguage.value = defaultFrench;
          LocalizationService().changeLocale(selectedLanguage.value.code.toString());
        }
      }

    });
    counter.value = 1;
    update();
    showLanguage();
    ShowToastDialog.closeLoader();
  }

  Future<void>createGuestUser()async{
    String fcmToken = "";
    if(Platform.isIOS){
      fcmToken = await NotificationService.getToken();
    }else{
      fcmToken = await NotificationService.getToken();
    }
    ShowToastDialog.showLoader("please_wait".tr);
    final userCredential = await FirebaseAuth.instance.signInAnonymously();
    final uid = userCredential.user?.uid;


    UserModel userModelData = UserModel();
    userModelData.id = uid;
    userModelData.fullName = "Guest User";
    userModelData.email = "N/A";
    userModelData.countryCode = "N/A";
    userModelData.phoneNumber = "N/A";
    userModelData.profilePic = "N/A";
    userModelData.fcmToken = fcmToken;
    userModelData.createdAt = Timestamp.now();
    userModelData.isActive = true;
    userModelData.role = "Guest";
    userModelData.password = "N/A";

    await FireStoreUtils.updateUser(userModelData).then((value) async{
      ShowToastDialog.closeLoader();
      if (value == true) {
        Get.delete<DashboardScreenController>();
        Get.delete<HomeController>();
        Get.offAll(const DashBoardScreen());
      }else{

      }
    });
  }


  showLanguage() {
    return showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      isDismissible: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.42,
        minChildSize: 0.20,
        maxChildSize: 0.85,
        expand: false,
        builder: (context, scrollController) {
          final themeChange = Provider.of<DarkThemeProvider>(context);
          return Obx(
                () => Scaffold(
              body: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Center(
                      child: Container(
                        width: 134,
                        margin: const EdgeInsets.only(top: 12, bottom: 6),
                        decoration: ShapeDecoration(
                          color: AppThemData.labelColorLightPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Select Language'.tr,
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: AppThemData.medium,
                        color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey10,
                      ),
                    ),
                  ),
                  Divider(color: themeChange.getThem() ? AppThemData.grey10 : AppThemData.grey03, thickness: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: languageList.length,
                          itemBuilder: (context, int index) {
                            return Obx(
                                  () => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      languageList[index].name.toString(),
                                      style: TextStyle(fontSize: 16, fontFamily: AppThemData.medium, color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey10),
                                    ),
                                    Radio(
                                        value: languageList[index],
                                        groupValue:selectedLanguage.value,
                                        activeColor: AppThemData.primary06,
                                        onChanged: (value) {
                                          selectedLanguage.value = languageList[index];
                                        })
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  )
                ],
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
                            LocalizationService().changeLocale(selectedLanguage.value.code.toString());
                            Preferences.setString(
                              Preferences.languageCodeKey,
                              jsonEncode(
                                selectedLanguage.value,
                              ),
                            );
                            Get.back(result: true);
                          },
                        ),
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

}