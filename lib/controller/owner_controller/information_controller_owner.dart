import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../constant/constant.dart';
import '../../constant/show_toast_dialog.dart';
import '../../env.dart';
import '../../model/user_model.dart';
import '../../themes/custom_dialog_box.dart';
import '../../ui/owner/app_not_access_screen_owner.dart';
import '../../ui/owner/dashboard_screen_owner.dart';
import '../../ui/owner/subscription_plan_screen/subscription_plan_screen_owner.dart';
import '../../utils/debouncer.dart';
import '../../utils/fire_store_utils.dart';
import '../../utils/notification_service.dart';
import '../../utils/utils.dart';


class InformationControllerOwner extends GetxController {
  Rx<TextEditingController> fullNameController = TextEditingController().obs;
  Rx<TextEditingController> emailController = TextEditingController().obs;
  Rx<TextEditingController> phoneNumberController = TextEditingController().obs;
  Rx<TextEditingController> passwordController = TextEditingController().obs;
  Rx<TextEditingController> countryCode = TextEditingController(text: "+1").obs;
  Rx<TextEditingController> otpController = TextEditingController().obs;
  RxString loginType = "".obs;
  final ImagePicker imagePicker = ImagePicker();
  RxString profileImage = "".obs;
  RxString gmailLogType = "".obs;
  RxString verificationIdAL = "".obs;
  RxString otpTextAL = "".obs;
  var isFirstTimeDelete = false;
  var isoCode = "";
  var fromEmailCheckExist = "0"; // 0= intial value , 1= exit, 2= not exit
  var fromPhoneNumberExist = "0"; // 0= intial value , 1= exit, 2= not exit
  final debouncer = Debouncer(milliseconds: 1000);


  @override
  void onInit() {
    getArgument();
    super.onInit();
  }

  Rx<UserModel> userModel = UserModel().obs;

  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      if (argumentData["TypeFrom"] != null){
        gmailLogType.value = argumentData['TypeFrom'];
      }
      userModel.value = argumentData['userModel'];
      loginType.value = userModel.value.loginType.toString();
      print("countryCode.value.text:--${userModel.value.countryCode.toString()}");
      if (loginType.value == Constant.phoneLoginType) {
        phoneNumberController.value.text = userModel.value.phoneNumber.toString();
        countryCode.value.text = userModel.value.countryCode.toString();
      } else {
        emailController.value.text = userModel.value.email.toString();
        fullNameController.value.text = userModel.value.fullName ?? '';

      }
    }
    update();
  }

  createAccount() async {
    ShowToastDialog.showLoader("Please wait".tr);
    String fcmToken = "";
    if(Platform.isIOS){
      fcmToken = await NotificationService.getToken();
       //fcmToken = "fdsklfdkfjaks;fjas;jfals68904567589789yuy";
    }else if (kIsWeb){
      fcmToken = "await NotificationService.getToken()dsfdfdf";
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

    UserModel userModelData = userModel.value;
    userModelData.fullName = fullNameController.value.text;
    userModelData.email = emailController.value.text;
    userModelData.countryCode = countryCode.value.text;
    userModelData.phoneNumber = phoneNumberController.value.text;
    userModelData.profilePic = profileImage.value;
    userModelData.fcmToken = fcmToken;
    userModelData.createdAt = Timestamp.now();
    userModelData.isActive = true;
    userModelData.role = Constant.roleTypeForOwner;
    userModelData.lastLoginType = Constant.roleTypeForOwner;
    userModelData.adminCommission = Constant.adminCommission;
    userModelData.password = passwordController.value.text;

    await linkUserWithEmail(emailController.value.text.trim(),passwordController.value.text.trim());
    if(verificationIdAL.value.isNotEmpty){
      await linkUserWithEmailToPhone(FirebaseAuth.instance.currentUser,  verificationIdAL.value,
          otpTextAL.value);
    }

    await FireStoreUtils.updateUser(userModelData).then((value) async {
      //ShowToastDialog.closeLoader();
      if (value == true) {
        try{
          await Utils.sendEmailWithTemplate(
            toEmail: emailController.value.text.trim().toString(),
            templateId: ENV.templateIdCreateAccount,
            dynamicTemplateData: {
              "fullName": fullNameController.value.text.trim().toString()
            },
          ).then((value) {
            ShowToastDialog.closeLoader();
          },);
        }catch(e){
          ShowToastDialog.closeLoader();
          log("Exception sending template :- ",error: e.toString());
        }

        bool isPlanExpire = false;
        if (userModelData.subscriptionPlan?.id != null) {
          if (userModelData.subscriptionExpiryDate == null) {
            if (userModelData.subscriptionPlan?.expiryDay == '-1') {
              isPlanExpire = false;
            } else {
              isPlanExpire = true;
            }
          } else {
            DateTime expiryDate = userModelData.subscriptionExpiryDate!.toDate();
            isPlanExpire = expiryDate.isBefore(DateTime.now());
          }
        }
        else {
          isPlanExpire = true;
        }
        if (userModelData.subscriptionPlanId == null || isPlanExpire == true) {
          if (Constant.adminCommission?.enable == false && Constant.isSubscriptionModelApplied == false) {

            Get.offAll(const DashBoardScreenOwner());
          } else {
            Get.offAll(const SubscriptionPlanScreenOwner(isBack: false));
          }
        }
        else if (userModelData.subscriptionPlan?.features?.ownerMobileApp == true) {

          Get.offAll(const DashBoardScreenOwner());
        } else {
          Get.offAll(const AppNotAccessScreenOwner());
        }
      }else{
        ShowToastDialog.closeLoader();
      }
    });
  }

  createAccountWithEmailNew(String uid) async {
    ShowToastDialog.showLoader("Please wait".tr);
    String fcmToken = "";
    if(Platform.isIOS){
      fcmToken = await NotificationService.getToken();
      //fcmToken = "fdsklfdkfjaks;fjas;jfals68904567589789yuy";
    }else if (kIsWeb){
      fcmToken = "await NotificationService.getToken()dsfdfdf";
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

    UserModel userModelData = userModel.value;
    userModelData.id = uid;
    userModelData.fullName = fullNameController.value.text;
    userModelData.email = emailController.value.text;
    // userModelData.countryCode = countryCode.value.text;
    // userModelData.phoneNumber = phoneNumberController.value.text;
    userModelData.profilePic = profileImage.value;
    userModelData.fcmToken = fcmToken;
    userModelData.createdAt = Timestamp.now();
    userModelData.isActive = true;
    userModelData.role = Constant.roleTypeForOwner;
    userModelData.lastLoginType = Constant.roleTypeForOwner;
    userModelData.adminCommission = Constant.adminCommission;
    userModelData.password = passwordController.value.text;
    await linkUserWithEmailToPhone(FirebaseAuth.instance.currentUser,  verificationIdAL.value,
        otpTextAL.value);
   // await linkUserWithEmail(emailController.value.text.trim(),passwordController.value.text.trim());

    await FireStoreUtils.updateUser(userModelData).then((value) async {
      //ShowToastDialog.closeLoader();
      if (value == true) {
        try{
          await Utils.sendEmailWithTemplate(
            toEmail: emailController.value.text.trim().toString(),
            templateId: ENV.templateIdCreateAccount,
            dynamicTemplateData: {
              "fullName": fullNameController.value.text.trim().toString()
            },
          ).then((value) {
            ShowToastDialog.closeLoader();
          },);
        }catch(e){
          ShowToastDialog.closeLoader();
          log("Exception sending template :- ",error: e.toString());
        }



        bool isPlanExpire = false;
        if (userModelData.subscriptionPlan?.id != null) {
          if (userModelData.subscriptionExpiryDate == null) {
            if (userModelData.subscriptionPlan?.expiryDay == '-1') {
              isPlanExpire = false;
            } else {
              isPlanExpire = true;
            }
          } else {
            DateTime expiryDate = userModelData.subscriptionExpiryDate!.toDate();
            isPlanExpire = expiryDate.isBefore(DateTime.now());
          }
        } else {
          isPlanExpire = true;
        }
        if (userModelData.subscriptionPlanId == null || isPlanExpire == true) {
          if (Constant.adminCommission?.enable == false && Constant.isSubscriptionModelApplied == false) {
            try{
              await Utils.sendEmailWithTemplate(
                toEmail: emailController.value.text.trim().toString(),
                templateId: ENV.templateIdCreateAccount,
                dynamicTemplateData: {
                  "fullName": fullNameController.value.text.trim().toString()
                },
              ).then((value) {
                ShowToastDialog.closeLoader();
              },);
            }catch(e){
              ShowToastDialog.closeLoader();
              log("Exception sending template :- ",error: e.toString());
            }
            Get.offAll(const DashBoardScreenOwner());
          } else {
            Get.offAll(const SubscriptionPlanScreenOwner(isBack: false));
          }
        }
        else if (userModelData.subscriptionPlan?.features?.ownerMobileApp == true) {
          Get.offAll(const DashBoardScreenOwner());
        } else {
          Get.offAll(const AppNotAccessScreenOwner());
        }
      }else{
        ShowToastDialog.closeLoader();
      }
    });
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

  Future<void> linkUserWithEmailToPhone(User?  user,String verificationIdPhone,String otpPhone) async {

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
            Get.offAll(const DashBoardScreenOwner());
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
  signInWithEmailAndPassword(BuildContext context,String email, String password) async {
    ShowToastDialog.showLoader("please_wait".tr);
    try {
      FirebaseAuth.instance.signInWithEmailAndPassword(email: email,
          password: password).then((value) async {
        await FireStoreUtils.userExistOrNot(value.user!.uid).then((userExit) async {
          ShowToastDialog.closeLoader();
          if (userExit == true) {
            await sendCode(context,user: value.user,
                descMsg: 'Enter the 6-digit code sent to your number.',type: "");
           // await sendCode(context,value.user,'Enter the 6-digit code sent to your number.',"");

            //linkUserWithEmailToPhone(value.user,verificationId.value,otpController.value.text);
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


  sendCode(BuildContext context,{User? user, String? descMsg, String? type}) async {
    ShowToastDialog.showLoader("please_wait".tr);
    await FirebaseAuth.instance
        .verifyPhoneNumber(
      phoneNumber: countryCode.value.text + phoneNumberController.value.text,
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        debugPrint("FirebaseAuthException--->${e.message}");
        ShowToastDialog.closeLoader();
        if (e.code == 'invalid-phone-number') {
          ShowToastDialog.showToast("Enter valid phone number".tr);
        } else {
          ShowToastDialog.showToast(e.code);
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        ShowToastDialog.closeLoader();
        showDialog(
          context: Get.context!,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return CustomDialogBoxOtp(
              title: 'Verify OTP',
              descriptions: descMsg ?? "",
              img:SvgPicture.asset('assets/icon/alert_ico.svg'),
              buttonText: 'Done',
              onButtonTap: () async {
                if (otpController.value.text.length == 6) {
                  Navigator.of(context).pop(); // Close dialog
                  ShowToastDialog.showLoader("Verifying OTP...");
                  try {
                    if(type == ""){
                      await linkUserWithEmailToPhone(
                        user,
                        verificationId,
                        otpController.value.text,
                      );
                    }
                    else{
                      verificationIdAL.value = verificationId;
                      otpTextAL.value = otpController.value.text.trim().toString();
                      if (gmailLogType != "EmailSignup"){
                        createAccount();
                      }
                      else{
                        print("email password");
                        final userCred = await createUserWithEmailPassword(email:emailController.value.text,
                            password: passwordController.value.text.trim());

                        if (userCred != null) {
                          print("userCred:--${userCred.additionalUserInfo!.isNewUser}");
                          print("userCredmmmm:--${userCred}");

                          createAccountWithEmailNew(userCred.user!.uid);
                        }
                      }

                    }
                    ShowToastDialog.closeLoader();
                    ShowToastDialog.showToast("Verification successful");
                    // Navigate to next screen or do login success logic

                  } catch (e) {
                    ShowToastDialog.closeLoader();
                    ShowToastDialog.showToast("Invalid OTP: $e");
                  }
                } else {
                  ShowToastDialog.showToast("Please enter 6-digit OTP");
                }
              },
              otpController: otpController.value,
            );
          },
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    )
        .catchError((error) {
      debugPrint("catchError--->$error");
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("multiple_time_request".tr);
    });
  }



}
