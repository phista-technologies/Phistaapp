
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../constant/constant.dart';
import '../../constant/show_toast_dialog.dart';
import '../../model/language_model.dart';
import '../../model/user_model.dart';
import '../../services/localization_service.dart';
import '../../themes/app_them_data.dart';
import '../../themes/custom_dialog_box.dart';
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
    //FireStoreUtils.deleteGuestUsersIfAllBookingsCompleted();
  }

 /* getLanguage() async {
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
    showLanguageDialog(Get.context!);
    ShowToastDialog.closeLoader();
  }*/

  Future<void> getLanguage() async {
    String? lang = Preferences.getString(Preferences.languageCodeKey);

    //  Step 1: Set default language (French) if not found
    if (lang == null || lang.isEmpty) {
      await Preferences.setString(Preferences.languageCodeKey, "fr");
      lang = "fr";
    }

    //  Step 2: Apply the selected or default locale
    LocalizationService().changeLocale(lang);

    // Step 3: Close loader first
    ShowToastDialog.closeLoader();

    //  Step 4: Small delay to ensure context is available
    Future.delayed(const Duration(milliseconds: 300), () {
      if (Get.context != null) {
        showLanguageDialog(Get.context!);
      } else {
        debugPrint("Context not available yet, retrying...");
        Future.delayed(const Duration(milliseconds: 300), () {
          if (Get.context != null) {
            showLanguageDialog(Get.context!);
          }
        });
      }
    });
  }

  Future<void>createGuestUser()async {
    String? fcmToken = "";
    if (!kIsWeb) {
    if (Platform.isIOS) {
      fcmToken = await NotificationService.getToken();
    }
    else {
      fcmToken = await NotificationService.getToken();
    }
  }else{
      fcmToken = await NotificationService.getWebToken();
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

  /*showLanguage() {
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
  }*/

  void showLanguageDialog1(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierLabel: "LanguageDialog",
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7), // dark overlay
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, anim1, anim2) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0), // blur background
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                margin: !kIsWeb ?EdgeInsets.symmetric(horizontal: 24,vertical: 24):EdgeInsets.symmetric(horizontal: 250,vertical: 50),
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppThemData.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo circle
                    Container(
                      height: 60,
                      width: 60,
                      child: Image.asset("assets/images/ic_parking_iconnew.png"),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Bonjour / Hello',
                      style: TextStyle(
                        color: AppThemData.grey10,
                        fontSize: 18,
                        fontFamily: AppThemData.robotoBold,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Choisissez la langue que vous préférez utiliser.\nSelect your preferred language.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppThemData.grey10,
                        fontSize: 14,
                        fontFamily: AppThemData.robotoMedium,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                        onPressed: () async {
                           await Preferences.setString(Preferences.languageCodeKey, "fr");
                           LocalizationService().changeLocale("fr");
                           Get.back();
        },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFA726),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                          child: const Text(
                            'Français',
                            style: TextStyle(
                              color: AppThemData.grey10,
                              fontSize: 20,
                              fontFamily: AppThemData.robotoSemiBold,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () async {
                            await Preferences.setString(Preferences.languageCodeKey, "en");
                            LocalizationService().changeLocale("en");
                            Get.back();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFA726),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                          child: const Text(
                            'English',
                            style: TextStyle(
                              color: AppThemData.grey10,
                              fontSize: 20,
                              fontFamily: AppThemData.robotoSemiBold,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),



                  ],
                ),
              ),

              Center(child: Image.asset("assets/images/phistaIcon.png",height: 50,width: 250,fit: BoxFit.cover,color: AppThemData.white,))
            ],
          ),
        );
      },
    );
  }

  void showLanguageDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierLabel: "LanguageDialog",
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, anim1, anim2) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
          child: Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                double maxWidth;

                if (!kIsWeb) {
                  // 🔹 Mobile layout
                  maxWidth = constraints.maxWidth * 0.9;
                } else if (constraints.maxWidth > 1200) {
                  // 🔹 Large desktop screens
                  maxWidth = 600;
                } else if (constraints.maxWidth > 800) {
                  // 🔹 Medium web screens
                  maxWidth = 500;
                } else {
                  // 🔹 Small browser windows or tablets
                  maxWidth = 400;
                }

                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      width: maxWidth,
                      margin: !kIsWeb
                          ? const EdgeInsets.symmetric(horizontal: 24, vertical: 24)
                          : const EdgeInsets.symmetric(horizontal: 50, vertical: 50),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppThemData.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 🔹 App logo
                          SizedBox(
                            height: 60,
                            width: 60,
                            child: Image.asset("assets/images/ic_parking_iconnew.png"),
                          ),
                          const SizedBox(height: 16),

                          const Text(
                            'Bonjour / Hello',
                            style: TextStyle(
                              color: AppThemData.grey10,
                              fontSize: 18,
                              fontFamily: AppThemData.robotoBold,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 8),

                          const Text(
                            'Choisissez la langue que vous préférez utiliser.\nSelect your preferred language.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppThemData.grey10,
                              fontSize: 14,
                              fontFamily: AppThemData.robotoMedium,
                              fontWeight: FontWeight.w400,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // 🔹 Language Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  await Preferences.setString(
                                      Preferences.languageCodeKey, "fr");
                                  LocalizationService().changeLocale("fr");
                                  Get.back();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFA726),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                ),
                                child: const Text(
                                  'Français',
                                  style: TextStyle(
                                    color: AppThemData.grey10,
                                    fontSize: 20,
                                    fontFamily: AppThemData.robotoSemiBold,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton(
                                onPressed: () async {
                                  await Preferences.setString(
                                      Preferences.languageCodeKey, "en");
                                  LocalizationService().changeLocale("en");
                                  Get.back();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFA726),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                ),
                                child: const Text(
                                  'English',
                                  style: TextStyle(
                                    color: AppThemData.grey10,
                                    fontSize: 20,
                                    fontFamily: AppThemData.robotoSemiBold,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // 🔹 Bottom brand logo
                    Image.asset(
                      "assets/images/phistaIcon.png",
                      height: 50,
                      width: 250,
                      fit: BoxFit.cover,
                      color: AppThemData.white,
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

}