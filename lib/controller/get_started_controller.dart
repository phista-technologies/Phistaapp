


import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:get/get.dart';

import '../constant/show_toast_dialog.dart';
import '../model/parking_model.dart';
import '../model/user_model.dart';
import '../ui/dashboard_screen.dart';
import '../utils/fire_store_utils.dart';
import '../utils/notification_service.dart';

class GetStartedController extends GetxController{
  var counter = 0.obs;

  Rx<ParkingModel> parkingModel = ParkingModel().obs;


  @override
  void onInit() {
    super.onInit();
    log("onInit",error: ">>>>>>>>>>>>>>>>>>>>>>.");
    getArgument();
  }




  getArgument() async {
    log("object:--> ${Get.arguments}");
    dynamic argumentData = Get.arguments;
    //Constant.bookingTypeConst = "hourly";
    if (argumentData != null) {
      parkingModel.value = argumentData['parkingModel'];
    }

   // update();
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

        Get.offAll(const DashBoardScreen());
      }else{

      }
    });





  }
}