import 'dart:async';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:phista/ui/driver/dashboard_screen.dart';
import 'package:phista/ui/driver/on_boarding_screen.dart';
import 'package:phista/ui/owner/dashboard_screen_owner.dart';
import 'package:phista/utils/fire_store_utils.dart';
import 'package:phista/utils/preferences.dart';

import '../../constant/version_checker.dart';
import '../../ui/select_usertype/select_usertypescreen.dart';

class SplashController extends GetxController {
  @override

  var userLastLoginType = "".obs;

  void onInit() {
try{
  WidgetsBinding.instance.addPostFrameCallback((_) async{
   var updateAvailable = await VersionChecker.checkForUpdate(Get.context!);
   if(updateAvailable){
     VersionChecker.showForceUpdateDialog(Get.context!);
   }else{
     Timer(const Duration(seconds: 3), () => redirectScreen());
   }
  });
}catch(e){
  log("Exception splash :- ",error: e.toString());
  Timer(const Duration(seconds: 3), () => redirectScreen());
}


    super.onInit();
  }



  redirectScreen() async {
    if (Preferences.getBoolean(Preferences.isFinishOnBoardingKey) == false) {
      Get.offAll(const OnBoardingScreen());
    } else {
      bool isLogin = await FireStoreUtils.isLogin();
      if (isLogin == true) {
        String lastLoginType = await FireStoreUtils.getUserLastLoginType();
        print("lastLoginType:-->  $lastLoginType");
        if (lastLoginType == "owner"){

          Get.offAll(const DashBoardScreenOwner());
        }else{
          Get.offAll(const DashBoardScreen());
        }

      } else {
        //Get.offAll(const LoginScreen());
        Get.offAll(const SelectUserTypeScreen());
      }
    }
  }


}
