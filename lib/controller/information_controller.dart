import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phista/constant/constant.dart';
import 'package:phista/constant/show_toast_dialog.dart';
import 'package:phista/model/referral_model.dart';
import 'package:phista/model/user_model.dart';
import 'package:phista/ui/dashboard_screen.dart';
import 'package:phista/utils/fire_store_utils.dart';
import 'package:phista/utils/notification_service.dart';

import '../utils/debouncer.dart';

class InformationController extends GetxController {
  Rx<TextEditingController> fullNameController = TextEditingController().obs;
  TextEditingController emailController = TextEditingController();
  Rx<TextEditingController> phoneNumberController = TextEditingController().obs;
  Rx<TextEditingController> passwordController = TextEditingController().obs;
  Rx<TextEditingController> referralCodeController = TextEditingController().obs;
  Rx<TextEditingController> countryCode = TextEditingController().obs;
  RxString loginType = "".obs;
  final ImagePicker imagePicker = ImagePicker();
  RxString profileImage = "".obs;
  RxBool passwordVisible = true.obs;
  RxString gmailLogType = "".obs;
  String verificationIdPhone = "";
  String otpPhone = "";
  final debouncer = Debouncer(milliseconds: 1000);

  @override
  void onInit() {
    getArgument();
    print("gdfgdfhdfhdfhdf ${countryCode.value}");
    super.onInit();
  }

  Rx<UserModel> userModel = UserModel().obs;

  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      if (argumentData["TypeFrom"] != null){
        gmailLogType.value = argumentData['TypeFrom'];
      }
      if (argumentData["verificationId"] != null){
        verificationIdPhone = argumentData['verificationId'];
        otpPhone = argumentData['otp'];
      }

      print("gdfgdfhdfhdfhdf ${gmailLogType.value}");
      userModel.value = argumentData['userModel'];
      loginType.value = userModel.value.loginType.toString();
      if (loginType.value == Constant.phoneLoginType) {
        phoneNumberController.value.text =
            userModel.value.phoneNumber.toString();countryCode.value.text = userModel.value.countryCode.toString();
      } else {
        if (argumentData["TypeFrom"] == null){
          emailController.text = userModel.value.email.toString();
          fullNameController.value.text = userModel.value.fullName ?? '';
        }

      }
    }
    update();
  }

  createAccount() async {
    String fcmToken = "";
    if(Platform.isIOS){
     // fcmToken ="sdsadsdsd54545645sdas4dsa4dsd564sdas";
      fcmToken = await NotificationService.getToken();
    }else{
      fcmToken = await NotificationService.getToken();
    }

    if (profileImage.value.isNotEmpty) {
      profileImage.value = await Constant.uploadUserImageToFireStorage(
        File(profileImage.value),
        "profileImage/${FireStoreUtils.getCurrentUid()}",
        File(profileImage.value).path.split('/').last,
      );
    }
    if (referralCodeController.value.text.isNotEmpty) {
      await FireStoreUtils.checkReferralCodeValidOrNot(
              referralCodeController.value.text)
          .then((value) async {
        if (value == true) {
          ShowToastDialog.showLoader("please_wait".tr);
          UserModel userModelData = userModel.value;
          userModelData.fullName = fullNameController.value.text;
          userModelData.email = emailController.text.trim();
          userModelData.countryCode = countryCode.value.text;
          userModelData.phoneNumber = phoneNumberController.value.text;
          userModelData.profilePic = profileImage.value;
          userModelData.fcmToken = fcmToken;
          userModelData.createdAt = Timestamp.now();
          userModelData.isActive = true;
          userModelData.role = Constant.roleType;
          userModelData.password = passwordController.value.text;

          FireStoreUtils.getReferralUserByCode(
                  referralCodeController.value.text.trim())
              .then((value) async {
            if (value != null) {
              ReferralModel ownReferralModel = ReferralModel(
                  id: FireStoreUtils.getCurrentUid(),
                  referralBy: value.id,
                  referralCode: Constant.getReferralCode());
              await FireStoreUtils.referralAdd(ownReferralModel);
            } else {
              ReferralModel referralModel = ReferralModel(
                  id: FireStoreUtils.getCurrentUid(),
                  referralBy: "",
                  referralCode: Constant.getReferralCode());
              await FireStoreUtils.referralAdd(referralModel);
            }
          });

          await linkUserWithEmail(emailController.text.trim(),passwordController.value.text.trim());


          await FireStoreUtils.updateUser(userModelData).then((value) {
            ShowToastDialog.closeLoader();
            if (value == true) {
              Get.offAll(
                const DashBoardScreen(),
              );
            }
          });
        } else {
          ShowToastDialog.showToast("referral_code_invalid".tr);
        }
      });
    } else {
      ShowToastDialog.showLoader("please_wait".tr);

      UserModel userModelData = userModel.value;
      userModelData.fullName = fullNameController.value.text;
      userModelData.email = emailController.text.trim();
      userModelData.countryCode = countryCode.value.text;
      userModelData.phoneNumber = phoneNumberController.value.text;
      userModelData.profilePic = profileImage.value;
      userModelData.fcmToken = fcmToken;
      userModelData.createdAt = Timestamp.now();
      userModelData.isActive = true;
      userModelData.role = Constant.roleType;
      userModelData.password = passwordController.value.text;

      ReferralModel referralModel = ReferralModel(
          id: FireStoreUtils.getCurrentUid(),
          referralBy: "",
          referralCode: Constant.getReferralCode());
      await FireStoreUtils.referralAdd(referralModel);
      await linkUserWithEmail(emailController.text.trim(),passwordController.value.text.trim());
      await FireStoreUtils.updateUser(userModelData).then((value) {
        ShowToastDialog.closeLoader();
        if (value == true) {
          Get.offAll(const DashBoardScreen());
        }
      });
    }
  }

  createAccountWithEmailNew(String uid) async {

    String fcmToken = "";
    if(Platform.isIOS){
      fcmToken = await NotificationService.getToken();
    }else{
      fcmToken = await NotificationService.getToken();
    }
    if (profileImage.value.isNotEmpty) {
      profileImage.value = await Constant.uploadUserImageToFireStorage(
        File(profileImage.value),
        "profileImage/${FireStoreUtils.getCurrentUid()}",
        File(profileImage.value).path.split('/').last,
      );
    }
    if (referralCodeController.value.text.isNotEmpty) {
      await FireStoreUtils.checkReferralCodeValidOrNot(
          referralCodeController.value.text)
          .then((value) async {
        if (value == true) {
          ShowToastDialog.showLoader("please_wait".tr);
          UserModel userModelData = userModel.value;
          userModelData.id = uid;
          userModelData.fullName = fullNameController.value.text;
          userModelData.email = emailController.text.trim();
          // userModelData.countryCode = countryCode.value.text;
          // userModelData.phoneNumber = phoneNumberController.value.text;
          userModelData.profilePic = profileImage.value;
          userModelData.fcmToken = fcmToken;
          userModelData.createdAt = Timestamp.now();
          userModelData.isActive = true;
          userModelData.role = Constant.roleType;
          userModelData.password = passwordController.value.text;

          FireStoreUtils.getReferralUserByCode(
              referralCodeController.value.text.trim())
              .then((value) async {
            if (value != null) {
              ReferralModel ownReferralModel = ReferralModel(
                  id: FireStoreUtils.getCurrentUid(),
                  referralBy: value.id,
                  referralCode: Constant.getReferralCode());
              await FireStoreUtils.referralAdd(ownReferralModel);
            } else {
              ReferralModel referralModel = ReferralModel(
                  id: FireStoreUtils.getCurrentUid(),
                  referralBy: "",
                  referralCode: Constant.getReferralCode());
              await FireStoreUtils.referralAdd(referralModel);
            }
          });

       //   await linkUserWithEmail(emailController.text.trim(),passwordController.value.text.trim());


          await FireStoreUtils.updateUser(userModelData).then((value) {
            ShowToastDialog.closeLoader();
            if (value == true) {
              Get.offAll(
                const DashBoardScreen(),
              );
            }
          });
        } else {
          ShowToastDialog.showToast("referral_code_invalid".tr);
        }
      });
    } else {
      ShowToastDialog.showLoader("please_wait".tr);
      UserModel userModelData = userModel.value;
      userModelData.id = uid;
      userModelData.fullName = fullNameController.value.text;
      userModelData.email = emailController.text.trim();
      userModelData.profilePic = profileImage.value;
      userModelData.fcmToken = fcmToken;
      userModelData.createdAt = Timestamp.now();
      userModelData.isActive = true;
      userModelData.role = Constant.roleType;
      userModelData.password = passwordController.value.text;
      ReferralModel referralModel = ReferralModel(
          id: FireStoreUtils.getCurrentUid(),
          referralBy: "",
          referralCode: Constant.getReferralCode());
      await FireStoreUtils.referralAdd(referralModel);
      //await linkUserWithEmail(emailController.text.trim(),passwordController.value.text.trim());
      await FireStoreUtils.updateUser(userModelData).then((value) {
        ShowToastDialog.closeLoader();
        if (value == true) {
          Get.offAll(const DashBoardScreen());
        }
      });
    }
  }


  Future<void> linkUserWithEmail(String email, String password)async{
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      AuthCredential emailCredential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      try {
        await user.linkWithCredential(emailCredential);
        print("Email/password linked successfully");
      } catch (e) {
        print("Linking failed: $e");
      }
    }
  }

  Future pickFile({required ImageSource source}) async {
    try {
      XFile? image = await imagePicker.pickImage(source: source);
      if (image == null) return;
      Get.back();
      profileImage.value = image.path;
    } on PlatformException catch (e) {
      ShowToastDialog.showToast("${"failed_to_pick".tr} : \n $e");
    }
  }

  Future<UserCredential?> createUserWithEmailPassword({
    required String email,
    required String password,
  })
  async {
    try {
      ShowToastDialog.showLoader("please_wait".tr);
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      return credential;
    } on FirebaseAuthException catch (e) {
      ShowToastDialog.closeLoader();
      if (e.code == 'email-already-in-use') {
        ShowToastDialog.showToast("Email is already in use".tr);
      }
      else if (e.code == 'weak-password') {
        ShowToastDialog.showToast("Password is too weak".tr);
      } else {
        ShowToastDialog.showToast(e.message ?? "Signup failed");
      }
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
    return null;
  }

  Future<void> linkUserWithEmailToPhone(User?  user) async {

    try{
      PhoneAuthCredential phoneCredential = PhoneAuthProvider.credential(
        verificationId: verificationIdPhone,
        smsCode: otpPhone, // OTP entered by the user
      );

      await user?.linkWithCredential(phoneCredential).then((linkedUser) async{
        ShowToastDialog.closeLoader();
        print('Phone number linked to email account');
        UserModel? userModel = await FireStoreUtils.getUserProfile(user.uid);
        if (userModel != null) {
          if (userModel.isActive == true &&  (userModel.role == "customer" || userModel.role == "owner")) {
            Get.offAll(const DashBoardScreen());
          } /*else if (userModel.role != "customer") {
                  await FirebaseAuth.instance.signOut();
                  ShowToastDialog.showToast("please enter valid credentials".tr);
                } */else {
            await FirebaseAuth.instance.signOut();
            ShowToastDialog.showToast("This user is disable please contact administrator".tr);
          }
        }

      }).catchError((e) {
        ShowToastDialog.closeLoader();
        if (e is FirebaseAuthException && e.code == 'provider-already-linked') {
          print('Phone number already linked');
        } else if (e is FirebaseAuthException && e.code == 'credential-already-in-use') {
          print('This phone number is already used with another account');
        } else {
          print('Linking failed: ${e.message}');
        }
      });
    }catch(e){
      ShowToastDialog.closeLoader();
      print("Exception :-- $e");
    }


  }

  signInWithEmailAndPassword(String email, String password) async {
    ShowToastDialog.showLoader("please_wait".tr);
    try {
      FirebaseAuth.instance.signInWithEmailAndPassword(email: email,
          password: password).then((value) async {
        await FireStoreUtils.userExistOrNot(value.user!.uid).then((userExit) async {
          ShowToastDialog.closeLoader();
          if (userExit == true) {
            linkUserWithEmailToPhone(value.user);
          }
        });

      }).catchError((error) {
        var errorCode = error.code;
        var errorMessage = error.message;
        debugPrint("errorMessage--->$errorMessage");
        ShowToastDialog.closeLoader();
        if (errorCode == "user-not-found") {
          ShowToastDialog.showToast("Invalid email and password");
        } else if (errorCode == "wrong-password") {
          ShowToastDialog.showToast("Wrong password");
        } else {
          ShowToastDialog.showToast(errorMessage);
        }
      });
    } catch (e) {
      debugPrint("catchError--->$e");
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
  }




}
