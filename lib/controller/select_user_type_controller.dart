
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constant/show_toast_dialog.dart';
import '../model/user_model.dart';
import '../ui/dashboard_screen.dart';
import '../utils/fire_store_utils.dart';
import '../utils/notification_service.dart';

class SelectUserTypeController extends GetxController{

  var counter = 0.obs;

  var isSelected = 0.obs;


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