import 'dart:async';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../constant/constant.dart';
import '../../constant/show_toast_dialog.dart';
import '../../constant/version_checker.dart';
import '../../model/user_model.dart';
import '../../ui/owner/app_not_access_screen_owner.dart';
import '../../ui/owner/auth_screen/login_screen_owner.dart';
import '../../ui/owner/dashboard_screen_owner.dart';
import '../../ui/owner/on_boarding_screen_owner.dart';
import '../../ui/owner/subscription_plan_screen/subscription_plan_screen_owner.dart';
import '../../utils/fire_store_utils.dart';
import '../../utils/preferences.dart';


class SplashControllerOwner extends GetxController {
  @override
  void onInit() {
    WidgetsBinding.instance.addPostFrameCallback((_) async{
      try{
        var updateAvailable = await VersionChecker.checkForUpdate(Get.context!);

        if(updateAvailable){
          VersionChecker.showForceUpdateDialog(Get.context!);
        }else{
          Timer(const Duration(seconds: 3), () => redirectScreen());
        }
      }catch(e){
        log("Exception splash :-- ",error: e.toString());
        Timer(const Duration(seconds: 3), () => redirectScreen());
      }
    });

    super.onInit();
  }

  redirectScreen() async {
    if (Preferences.getBoolean(Preferences.isFinishOnBoardingKey) == false) {
      Get.offAll(const OnBoardingScreenOwner());
    } else {
      bool isLogin = await FireStoreUtils.isLogin();
      if (isLogin == true) {
        await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid()).then((value) async {
          if (value != null) {
            UserModel userModel = value;
            log(userModel.toJson().toString());
            if (userModel.isActive == true &&  (userModel.role == "customer" || userModel.role == "owner")) {
              bool isPlanExpire = false;
              if (userModel.subscriptionPlan?.id != null) {
                if (userModel.subscriptionExpiryDate == null) {
                  if (userModel.subscriptionPlan?.expiryDay == '-1') {
                    isPlanExpire = false;
                  } else {
                    isPlanExpire = true;
                  }
                } else {
                  DateTime expiryDate = userModel.subscriptionExpiryDate!.toDate();
                  isPlanExpire = expiryDate.isBefore(DateTime.now());
                }
              } else {
                isPlanExpire = true;
              }
              if (userModel.subscriptionPlanId == null || isPlanExpire == true) {
                if (Constant.adminCommission?.enable == false && Constant.isSubscriptionModelApplied == false) {
                  Get.offAll(const DashBoardScreenOwner());
                } else {
                  Get.offAll(const SubscriptionPlanScreenOwner());
                }
              } else if (userModel.subscriptionPlan?.features?.ownerMobileApp == true) {
                Get.offAll(const DashBoardScreenOwner());
              } else {
                Get.offAll(const AppNotAccessScreenOwner());
              }
            } else if (userModel.role != "owner") {
              await FirebaseAuth.instance.signOut();
              ShowToastDialog.showToast("please enter valid credentials".tr);
            } else {
              await FirebaseAuth.instance.signOut();
              ShowToastDialog.showToast("This user is disable please contact administrator".tr);
            }
          }
        });
      } else {
        Get.offAll(const LoginScreenOwner());
      }
    }
  }
}
