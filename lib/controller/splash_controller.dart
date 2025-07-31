import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:phista/ui/auth_screen/login_screen.dart';
import 'package:phista/ui/dashboard_screen.dart';
import 'package:phista/ui/on_boarding_screen.dart';
import 'package:phista/utils/fire_store_utils.dart';
import 'package:phista/utils/preferences.dart';

import '../constant/version_checker.dart';

class SplashController extends GetxController {
  @override
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
        Get.offAll(
          const DashBoardScreen(),
        );
      } else {
        Get.offAll(const LoginScreen());
      }
    }
  }
}
