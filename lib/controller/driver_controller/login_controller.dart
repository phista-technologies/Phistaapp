import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:phista/constant/constant.dart';
import 'package:phista/constant/show_toast_dialog.dart';
import 'package:phista/controller/driver_controller/dashboard_controller.dart';
import 'package:phista/controller/driver_controller/home_controller.dart';
import 'package:phista/model/user_model.dart';

import 'package:phista/ui/driver/dashboard_screen.dart';
import 'package:phista/utils/fire_store_utils.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../constant/extension_data.dart';
import '../../model/payment/AppleUserDataModel.dart';
import '../../ui/driver/auth_screen/information_screen.dart';
import '../../ui/driver/auth_screen/otp_screen.dart';
import '../../utils/notification_service.dart';
import '../../utils/utils.dart';


class LoginController extends GetxController {

  Rx<TextEditingController> phoneNumberController = TextEditingController().obs;
  Rx<TextEditingController> emailController = TextEditingController().obs;
  Rx<TextEditingController> passwordController = TextEditingController().obs;
  Rx<TextEditingController> countryCode = TextEditingController(text: "+1").obs;
  RxBool passwordVisible = true.obs;
  RxString loginType = "".obs;
  Rx<GlobalKey<FormState>> formKey = GlobalKey<FormState>().obs;
  RxString fromLoginType = "Mobile".obs;

  sendCode() async {
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
        Get.to(const OtpScreen(), arguments: {
          "countryCode": countryCode.value.text,
          "phoneNumber": phoneNumberController.value.text,
          "verificationId": verificationId,
          "screenType":""
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    )
        .catchError((error) {
      debugPrint("catchError--->$error");
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("multiple_time_request".tr);
    });
  }

  /*Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      // Ensure fresh login (optional)
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.disconnect();
        await googleSignIn.signOut();
      }

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("Login cancelled");
        return null;
      }

      debugPrint("Google User Email: ${googleUser.email}");

      // Check if user exists in Firestore with password
      final credentials = await FireStoreUtils.getUserPasswordByEmail(googleUser.email);

      if (credentials != null && credentials['password'] != null && credentials['password']!.isNotEmpty) {
        final password = credentials['password']!;
        debugPrint("User password (Google): $password");

        try {
          final value = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: googleUser.email.trim(),
            password: password,
          );

          ShowToastDialog.closeLoader();
          debugPrint("Firebase Sign-in success");

          return value;
        } catch (e) {
          debugPrint("Firebase Email/Password Sign-in failed: $e");
        }
      }

      // If no password found -> proceed with normal Google Sign-in
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      return userCredential;
    } catch (e) {
      debugPrint("signInWithGoogle error: $e");
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("Something went wrong. Try again.");
      return null;
    }
  }*/

  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();

        final userCredential = await FirebaseAuth.instance.signInWithPopup(googleProvider);
        debugPrint("✅ Google Web Sign-in success: ${userCredential.user?.email}");
        return userCredential;
      } else {
        // 📱 Mobile flow (Android/iOS)
        final GoogleSignIn googleSignIn = GoogleSignIn();

        // Force logout old session to always show account picker
        if (await googleSignIn.isSignedIn()) {
          await googleSignIn.disconnect();
          await googleSignIn.signOut();
        }

        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser == null) {
          ShowToastDialog.closeLoader();
          ShowToastDialog.showToast("Login cancelled");
          return null;
        }

        final credentials = await FireStoreUtils.getUserPasswordByEmail(googleUser.email);
        if (credentials != null && credentials['password'] != null && credentials['password']!.isNotEmpty) {
          try {
            final value = await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: googleUser.email.trim(),
              password: credentials['password']!,
            );
            ShowToastDialog.closeLoader();
            return value;
          } catch (e) {
            debugPrint("Firebase Email/Password Sign-in failed: $e");
          }
        }

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        debugPrint("✅ Google Mobile Sign-in success: ${userCredential.user?.email}");
        return userCredential;
      }
    } catch (e) {
      debugPrint("signInWithGoogle error: $e");
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("Something went wrong. Try again.");
      return null;
    }
  }

  Future<Map<String, dynamic>?> signInWithApple() async {
    try {
      String appleUserEmail = "";
      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);

      // Request credential for the currently signed in Apple account.
      AuthorizationCredentialAppleID appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
        // webAuthenticationOptions: WebAuthenticationOptions(clientId: clientID, redirectUri: Uri.parse(redirectURL)),
      );

      debugPrint("userIdentifier : ${appleCredential.userIdentifier}");
      final tempAppleEmail = await FireStoreUtils.getAppleUserData(appleCredential.userIdentifier??"N/A");

      debugPrint("appleEmail : $tempAppleEmail");

      if(tempAppleEmail != null){
        appleUserEmail = tempAppleEmail.email??"N/A";
      }else{
        appleUserEmail = appleCredential.email??"N/A";
        debugPrint("appleCredential.email : ${appleCredential.email}");
      }
      debugPrint("appleEmail : $appleUserEmail");
      final credentials = await FireStoreUtils.getUserPasswordByEmail(appleUserEmail);
      if (credentials != null && credentials['password'] != null && credentials['password']!.isNotEmpty) {
        final password = credentials['password']!;
        debugPrint("User password (Apple): $password");

        try {
          final value = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: appleUserEmail,
            password: password,
          );

          ShowToastDialog.closeLoader();
          debugPrint("Firebase Sign-in success");

          return {
            "userCredential" :value,
            "appleCredential" :appleCredential
          };
        } catch (e) {
          debugPrint("Firebase Email/Password Sign-in failed: $e");
        }
      }


      // Create an `OAuthCredential` from the credential returned by Apple.
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in the user with Firebase. If the nonce we generated earlier does
      // not match the nonce in `appleCredential.identityToken`, sign in will fail.
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(oauthCredential);
      return {"appleCredential": appleCredential, "userCredential": userCredential};
    } catch (e) {
      debugPrint("signInWithApple :: $e");
    }
    return null;
  }

  String generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  loginWithGoogle() async {
    ShowToastDialog.showLoader("please_wait".tr);

    await signInWithGoogle().then((value) async {
      ShowToastDialog.closeLoader();

      if (value != null) {
        String uid = value.user!.uid;

        if (value.additionalUserInfo!.isNewUser) {
          UserModel userModel = UserModel();
          userModel.id = uid;
          userModel.email = value.user!.email;
          userModel.fullName = value.user!.displayName;
          userModel.profilePic = value.user!.photoURL;
          userModel.loginType = Constant.googleLoginType;
          userModel.role = Constant.roleTypeForCustomer; // e.g. "customer"

          Get.to(const InformationScreen(), arguments: {
            "userModel": userModel,
          });

        }
        else {
          FireStoreUtils.userExistOrNot(uid).then((userExists) async {
            if (userExists) {
              UserModel? userModel = await FireStoreUtils.getUserProfile(uid);
              String? fcmToken = "";
              if(Platform.isIOS){
                fcmToken = await NotificationService.getToken();
              }else if (kIsWeb){
                fcmToken = await NotificationService.getToken();
              }
              else{
                fcmToken = await NotificationService.getToken();
              }
              if (userModel != null) {
                if (userModel.stripeCustomerId == null || userModel.stripeCustomerId == "") {
                  String? newStripeId = await Utils.createStripeCustomerIfNotExists(userModel);
                  if (newStripeId != null && newStripeId.isNotEmpty) {
                    userModel.stripeCustomerId = newStripeId;
                    await FireStoreUtils.updateUser(userModel);
                  }
                }
                userModel.fcmToken = fcmToken;
                await FireStoreUtils.updateUser(userModel);
                if (userModel.isActive == true && (userModel.role == "customer" || userModel.role == "owner")) {

                  Constant.currentUserModel.value?.role = userModel.role;
                  Get.delete<DashboardScreenController>();
                  Get.delete<HomeController>();
                  Get.offAll(const DashBoardScreen());
                } /*else if (userModel.role != "customer") {

                  await FirebaseAuth.instance.signOut();
                  ShowToastDialog.showToast("This account is not allowed in this app.".tr);
                } */else {
                  await FirebaseAuth.instance.signOut();
                  ShowToastDialog.showToast("This user is disabled. Please contact support.".tr);
                }
              } else {
                await FirebaseAuth.instance.signOut();
                ShowToastDialog.showToast("User profile not found.".tr);
              }
            } else {
              UserModel userModel = UserModel();
              userModel.id = uid;
              userModel.email = value.user!.email;
              userModel.fullName = value.user!.displayName;
              userModel.profilePic = value.user!.photoURL;
              userModel.loginType = Constant.googleLoginType;
              userModel.role = Constant.roleTypeForCustomer;

              Get.to(const InformationScreen(), arguments: {
                "userModel": userModel,
              });
            }
          });
        }
      }
    });
  }


  loginWithApple() async {
    try {
      ShowToastDialog.showLoader("please_wait".tr);
      final result = await signInWithApple();
      ShowToastDialog.closeLoader();
      if (result != null) {
        Map<String, dynamic> map = result;
        AuthorizationCredentialAppleID appleCredential = map['appleCredential'];
        UserCredential userCredential = map['userCredential'];


        print("appleCredential :- ${appleCredential.givenName}");
        print("userCredential :- $userCredential");


        AppleUserDataModel? appleUserDataModel;
        if (appleCredential.givenName?.isNotEmpty??false){
          appleUserDataModel = AppleUserDataModel(
            userIdentifier: appleCredential.userIdentifier,
            email: appleCredential.email,
            givenName: appleCredential.givenName,
            familyName: appleCredential.familyName,
            authorizationCode: appleCredential.authorizationCode,
            identityToken: appleCredential.identityToken,
            state: appleCredential.state,
          );
          FireStoreUtils.appleUserData(appleUserDataModel);
        }
        else{
          appleUserDataModel = await FireStoreUtils.getAppleUserData(appleCredential.userIdentifier??"");
        }

        if (userCredential.additionalUserInfo?.isNewUser == true) {

          UserModel userModel = UserModel();
          if (appleCredential.givenName?.isNotEmpty??false){

            userModel.id = userCredential.user!.uid;
            userModel.email = userCredential.user!.email ?? appleCredential.email;
            userModel.fullName = "${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}".trim();
            userModel.profilePic = userCredential.user!.photoURL;
            userModel.loginType = Constant.appleLoginType;
            userModel.role = Constant.roleTypeForCustomer;
            userModel.isActive = true;

          }
          else{
            userModel.id = userCredential.user!.uid;
            userModel.email = appleUserDataModel?.email;
            userModel.fullName = "${ appleUserDataModel?.givenName ?? ''} ${ appleUserDataModel?.familyName ?? ''}".trim();
            userModel.profilePic = userCredential.user!.photoURL;
            userModel.loginType = Constant.appleLoginType;
            userModel.role = Constant.roleTypeForCustomer;
            userModel.isActive = true;
          }

          // await FireStoreUtils.updateUser(userModel);
          Get.to(const InformationScreen(), arguments: {"userModel": userModel});
        }
        else {
          bool userExists = await FireStoreUtils.userExistOrNot(userCredential.user!.uid);

          if (userExists) {
            UserModel? userModel = await FireStoreUtils.getUserProfile(userCredential.user!.uid);
            String? fcmToken = "";
            if(Platform.isIOS){
              fcmToken = await NotificationService.getToken();
            }else if (kIsWeb){
              fcmToken = await NotificationService.getToken();
            }
            else{
              fcmToken = await NotificationService.getToken();
            }
            if (userModel != null) {
              if (userModel.stripeCustomerId == null || userModel.stripeCustomerId == "") {
                String? newStripeId = await Utils.createStripeCustomerIfNotExists(userModel);
                if (newStripeId != null && newStripeId.isNotEmpty) {
                  userModel.stripeCustomerId = newStripeId;
                  await FireStoreUtils.updateUser(userModel);
                }
              }
              userModel.fcmToken = fcmToken;
              await FireStoreUtils.updateUser(userModel);
              if (userModel.isActive == true && (userModel.role == "customer" || userModel.role == "owner")) {
                Constant.currentUserModel.value?.role = userModel.role;
                Get.delete<DashboardScreenController>();
                Get.delete<HomeController>();
                Get.offAll(const DashBoardScreen());
              }
              else {
                await FirebaseAuth.instance.signOut();
                ShowToastDialog.showToast("This user is disabled. Please contact administrator.".tr);
              }
            }
          } else {
            UserModel userModel = UserModel();
            userModel.id = userCredential.user?.uid;
            userModel.email = userCredential.user!.email ?? appleCredential.email;
            userModel.profilePic = userCredential.user?.photoURL;
            userModel.loginType = Constant.appleLoginType;
            userModel.role = Constant.roleTypeForCustomer;
            Get.to(const InformationScreen(), arguments: {
              "userModel": userModel,
            });
          }
        }
      } else {
        ShowToastDialog.showToast("Apple sign-in was cancelled or failed.".tr);
      }
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("Apple sign-in failed: ${e.toString()}");
      print("Apple login error: $e");
    }
  }

  signInWithEmailAndPassword() async {
    ShowToastDialog.showLoader("please_wait".tr);
    try {
      FirebaseAuth.instance.signInWithEmailAndPassword(email: emailController.value.text.trim(),
          password: passwordController.value.text.trim()).then((value) async {
          await FireStoreUtils.userExistOrNot(value.user!.uid).then((userExit) async {
            ShowToastDialog.closeLoader();
            String? fcmToken = "";
            if(Platform.isIOS){
              fcmToken = await NotificationService.getToken();
            }else if (kIsWeb){
              fcmToken = await NotificationService.getToken();
            }
            else{
              fcmToken = await NotificationService.getToken();
            }
            if (userExit == true) {
              UserModel? userModel = await FireStoreUtils.getUserProfile(value.user!.uid);
              if (userModel?.stripeCustomerId == null || userModel?.stripeCustomerId == "") {
                String? newStripeId = await Utils.createStripeCustomerIfNotExists(userModel!);
                if (newStripeId != null && newStripeId.isNotEmpty) {
                  userModel.stripeCustomerId = newStripeId;
                  await FireStoreUtils.updateUser(userModel);
                }
              }
              userModel?.fcmToken = fcmToken;
              await FireStoreUtils.updateUser(userModel!);
              if (userModel != null) {
                if (userModel.isActive == true &&  (userModel.role == "customer" || userModel.role == "owner")) {
                  Constant.currentUserModel.value?.role = userModel.role;
                  Get.delete<DashboardScreenController>();
                  Get.delete<HomeController>();
                  Get.offAll(const DashBoardScreen());
                } /*else if (userModel.role != "customer") {
                  await FirebaseAuth.instance.signOut();
                  ShowToastDialog.showToast("please enter valid credentials".tr);
                } */else {
                  await FirebaseAuth.instance.signOut();
                  ShowToastDialog.showToast("This user is disable please contact administrator".tr);
                }
              }
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

  checkValidation() {
    if (!isEmail(emailController.value.text)) {
      return "Please Enter Valid Email address";
    } else if (passwordController.value.text.isEmpty) {
      return "Please Enter Password";
    } else {
      return null;
    }
  }

}
