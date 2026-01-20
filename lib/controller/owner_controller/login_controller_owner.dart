import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../constant/constant.dart';
import '../../constant/extension_data.dart';
import '../../constant/show_toast_dialog.dart';
import '../../model/payment/AppleUserDataModel.dart';
import '../../model/user_model.dart';
import '../../ui/owner/app_not_access_screen_owner.dart';
import '../../ui/owner/auth_screen/information_screen_owner.dart';
import '../../ui/owner/auth_screen/otp_screen_owner.dart';
import '../../ui/owner/dashboard_screen_owner.dart';
import '../../ui/owner/subscription_plan_screen/subscription_plan_screen_owner.dart';
import '../../utils/fire_store_utils.dart';
import '../../utils/notification_service.dart';
import '../../utils/utils.dart';


class LoginControllerOwner extends GetxController {
  Rx<TextEditingController> phoneNumberController = TextEditingController().obs;
  Rx<TextEditingController> emailController = TextEditingController().obs;
  Rx<TextEditingController> passwordController = TextEditingController().obs;
  Rx<TextEditingController> countryCode = TextEditingController(text: "+1").obs;
  RxString fromLoginType = "Mobile".obs;
  RxBool passwordVisible = true.obs;
  RxString loginType = "".obs;
  Rx<GlobalKey<FormState>> formKey = GlobalKey<FormState>().obs;

  sendCode() async {
    ShowToastDialog.showLoader("Please wait".tr);
    await FirebaseAuth.instance
        .verifyPhoneNumber(
      phoneNumber: countryCode.value.text + phoneNumberController.value.text,
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        debugPrint("FirebaseAuthException--->${e.message}");
        ShowToastDialog.closeLoader();
        if (e.code == 'invalid-phone-number') {
          ShowToastDialog.showToast("Phone number is Invalid".tr);
        } else {
          ShowToastDialog.showToast(e.code);
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        ShowToastDialog.closeLoader();
        Get.to(
          const OtpScreenOwner(),
          arguments: {
            "countryCode": countryCode.value.text,
            "phoneNumber": phoneNumberController.value.text,
            "verificationId": verificationId,
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

  /*Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      // 🧹 Force logout previous session to allow fresh account selection
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.disconnect();
        await googleSignIn.signOut();
      }

      // This will now show the account selection popup
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("Login cancelled");
        return null;
      }

      debugPrint("Google User Email: ${googleUser.email}");
      final credentials = await FireStoreUtils.getUserPasswordByEmail(googleUser.email);
      if (credentials != null && credentials['password'] != null && credentials['password']!.isNotEmpty) {
        final password = credentials['password']!;
        debugPrint("User password (Google): $password");

        try{
          final value = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: googleUser.email.trim(),
            password: password,
          );
          ShowToastDialog.closeLoader();
          debugPrint("Firebase Sign-in success");
          return value;
        }catch(e){
          debugPrint("Firebase Email/Password Sign-in failed: $e");
        }
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
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
      AuthorizationCredentialAppleID appleCredential =
          await SignInWithApple.getAppleIDCredential(
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
        try{
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
        }catch(e){
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
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(oauthCredential);
      return {
        "appleCredential": appleCredential,
        "userCredential": userCredential,
      };
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }


  loginWithGoogle() async {
    ShowToastDialog.showLoader("Please wait".tr);

    final value = await signInWithGoogle();

    ShowToastDialog.closeLoader();

    if (value == null) return;

    final uid = value.user!.uid;

    // New user
    if (value.additionalUserInfo!.isNewUser) {
      UserModel userModel = UserModel()
        ..id = uid
        ..email = value.user!.email
        ..fullName = value.user!.displayName
        ..profilePic = value.user!.photoURL
        ..loginType = Constant.googleLoginType
        ..role = Constant.roleTypeForCustomer; // should be 'owner'

      Get.to(const InformationScreenOwner(), arguments: {"userModel": userModel});
      return;
    }

    //  Existing user
    final userExists = await FireStoreUtils.userExistOrNot(uid);

    if (!userExists) {
      // First login but FirebaseAuth had user
      UserModel userModel = UserModel()
        ..id = uid
        ..email = value.user!.email
        ..fullName = value.user!.displayName
        ..profilePic = value.user!.photoURL
        ..loginType = Constant.googleLoginType
        ..role = Constant.roleTypeForCustomer;

      Get.to(const InformationScreenOwner(), arguments: {"userModel": userModel});
      return;
    }

    // Fetch profile
    UserModel? userModel = await FireStoreUtils.getUserProfile(uid);
    String fcmToken = "";
    if(Platform.isIOS){
      fcmToken = await NotificationService.getToken();
    }else if (kIsWeb){
      fcmToken = await NotificationService.getToken();
    }
    else{
      fcmToken = await NotificationService.getToken();
    }
    if (userModel?.stripeCustomerId == null || userModel?.stripeCustomerId == "") {
      String? newStripeId = await Utils.createStripeCustomerIfNotExists(userModel!);
      if (newStripeId != null && newStripeId.isNotEmpty) {
        userModel?.stripeCustomerId = newStripeId;
        await FireStoreUtils.updateUser(userModel!);
      }
    }
    userModel?.fcmToken = fcmToken;
    await FireStoreUtils.updateUser(userModel!);
    if (userModel == null) {
      await FirebaseAuth.instance.signOut();
      ShowToastDialog.showToast("User profile not found.".tr);
      return;
    }

    if (userModel.role != "owner" && userModel.role != "customer") {
      await FirebaseAuth.instance.signOut();
      ShowToastDialog.showToast("please enter valid credentials".tr);
      return;
    }


    if (userModel.isActive != true) {
      await FirebaseAuth.instance.signOut();
      ShowToastDialog.showToast("This user is disabled. Please contact administrator".tr);
      return;
    }

    bool isPlanExpired = true;

    if (userModel.subscriptionPlan?.id != null) {
      if (userModel.subscriptionExpiryDate == null) {
        isPlanExpired = userModel.subscriptionPlan?.expiryDay != "-1";
      } else {
        final expiryDate = userModel.subscriptionExpiryDate!.toDate();
        isPlanExpired = expiryDate.isBefore(DateTime.now());
      }
    }

    // Navigate based on subscription & access
    if (userModel.subscriptionPlanId == null || isPlanExpired) {
      if (Constant.adminCommission?.enable == false &&
          Constant.isSubscriptionModelApplied == false) {
        Get.offAll(const DashBoardScreenOwner());
      } else {
        Get.offAll(const SubscriptionPlanScreenOwner(isBack: false));
      }
    }
    else if (userModel.subscriptionPlan?.features?.ownerMobileApp == true) {
      Get.offAll(const DashBoardScreenOwner());
    }
    else {
      Get.offAll(const AppNotAccessScreenOwner());
    }
  }

  loginWithApple() async {
    ShowToastDialog.showLoader("Please wait".tr);
    await signInWithApple().then((value) async {
      print("value:--->$value");
      ShowToastDialog.closeLoader();
      if (value != null) {
        Map<String, dynamic> map = value;
        AuthorizationCredentialAppleID appleCredential = map['appleCredential'];
        UserCredential userCredential = map['userCredential'];

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

        if (userCredential.additionalUserInfo!.isNewUser) {
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
          Get.to(const InformationScreenOwner(), arguments: {"userModel": userModel});
         // Get.offAll(const SubscriptionPlanScreen());
          // Get.offAll(const DashBoardScreen());
        }
        else {
          FireStoreUtils.userExistOrNot(userCredential.user!.uid).then((userExit) async {
            ShowToastDialog.closeLoader();

            if (userExit == true) {
              UserModel? userModel = await FireStoreUtils.getUserProfile(userCredential.user!.uid);

              if (userModel != null) {
                navigateUserBasedOnAccess(userModel);
             /*   if (userModel.isActive == true &&  (userModel.role == "customer" || userModel.role == "owner")) {
                  Get.offAll(const DashBoardScreen());
                } else if (userModel.role != "owner") {
                  await FirebaseAuth.instance.signOut();
                  ShowToastDialog.showToast("please enter valid credentials".tr);
                }
                else {
                  await FirebaseAuth.instance.signOut();
                  ShowToastDialog.showToast("This user is disable please contact administrator".tr);
                }*/
              }

            } else {
              UserModel userModel = UserModel();
              userModel.id = userCredential.user!.uid;
              userModel.email = userCredential.user!.email ?? appleCredential.email;
              userModel.fullName = "${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}".trim();
              userModel.profilePic = userCredential.user!.photoURL;
              userModel.loginType = Constant.appleLoginType;
              userModel.role = Constant.roleTypeForCustomer;
              userModel.isActive = true;
              await FireStoreUtils.updateUser(userModel);
              Get.offAll(const DashBoardScreenOwner());
            }
          });
        }
      }
    });
  }

  Future<void> navigateUserBasedOnAccess(UserModel userModel) async {
    String fcmToken = "";
    if(Platform.isIOS){
      fcmToken = await NotificationService.getToken();
    }else if (kIsWeb){
      fcmToken = await NotificationService.getToken();
    }
    else{
      fcmToken = await NotificationService.getToken();
    }
    if (userModel.stripeCustomerId == null || userModel.stripeCustomerId == "") {
      String? newStripeId = await Utils.createStripeCustomerIfNotExists(userModel);
      if (newStripeId != null && newStripeId.isNotEmpty) {
        userModel.stripeCustomerId = newStripeId;
        await FireStoreUtils.updateUser(userModel);
      }
    }
    userModel.fcmToken = fcmToken;
    await FireStoreUtils.updateUser(userModel);
    if (userModel.role != "owner" && userModel.role != "customer") {
      FirebaseAuth.instance.signOut();
      ShowToastDialog.showToast("please enter valid credentials".tr);
      return;
    }

    if (userModel.isActive != true) {
      FirebaseAuth.instance.signOut();
      ShowToastDialog.showToast("This user is disabled. Please contact administrator".tr);
      return;
    }

    bool isPlanExpired = true;

    if (userModel.subscriptionPlan?.id != null) {
      if (userModel.subscriptionExpiryDate == null) {
        isPlanExpired = userModel.subscriptionPlan?.expiryDay != "-1";
      } else {
        final expiryDate = userModel.subscriptionExpiryDate!.toDate();
        isPlanExpired = expiryDate.isBefore(DateTime.now());
      }
    }

    if (userModel.subscriptionPlanId == null || isPlanExpired) {
      if (Constant.adminCommission?.enable == false &&
          Constant.isSubscriptionModelApplied == false) {
        Get.offAll(const DashBoardScreenOwner());
      } else {
        Get.offAll(const SubscriptionPlanScreenOwner(isBack: false));
      }
    } else if (userModel.subscriptionPlan?.features?.ownerMobileApp == true) {
      Get.offAll(const DashBoardScreenOwner());
    } else {
      Get.offAll(const AppNotAccessScreenOwner());
    }
  }


  signInWithEmailAndPassword() async {
    ShowToastDialog.showLoader("please_wait".tr);
    try {
      FirebaseAuth.instance.signInWithEmailAndPassword(email: emailController.value.text.trim(),
          password: passwordController.value.text.trim()).then((value) async {
        await FireStoreUtils.userExistOrNot(value.user!.uid).then((userExit) async {
          ShowToastDialog.closeLoader();
            UserModel? userModel = await FireStoreUtils.getUserProfile(
                value.user!.uid);
          String fcmToken = "";
          if(Platform.isIOS){
            fcmToken = await NotificationService.getToken();
          }else if (kIsWeb){
            fcmToken = await NotificationService.getToken();
          }
          else{
            fcmToken = await NotificationService.getToken();
          }
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
              if (userModel.isActive == true &&
                  (userModel.role == "customer" || userModel.role == "owner")) {
                bool isPlanExpire = false;
                if (userModel.subscriptionPlan?.id != null) {
                  if (userModel.subscriptionExpiryDate == null) {
                    if (userModel.subscriptionPlan?.expiryDay == '-1') {
                      isPlanExpire = false;
                    } else {
                      isPlanExpire = true;
                    }
                  } else {
                    DateTime expiryDate = userModel
                        .subscriptionExpiryDate!
                        .toDate();
                    isPlanExpire = expiryDate
                        .isBefore(DateTime.now());
                  }
                } else {
                  isPlanExpire = true;
                }
                if (userModel.subscriptionPlanId == null || isPlanExpire == true) {
                  if (Constant.adminCommission?.enable == false && Constant.isSubscriptionModelApplied == false) {
                    Get.offAll(const DashBoardScreenOwner());
                  } else {
                    Get.offAll(const SubscriptionPlanScreenOwner(isBack: false));
                  }
                } else if (userModel.subscriptionPlan?.features?.ownerMobileApp == true) {
                  Get.offAll(const DashBoardScreenOwner());
                } else {
                  Get.offAll(const AppNotAccessScreenOwner());
                }
              }
              /*else if (userModel.role !=
                                              "owner") {
                                            await FirebaseAuth.instance
                                                .signOut();
                                            ShowToastDialog.showToast(
                                                "please enter valid credentials"
                                                    .tr);
                                          }*/ else {
                await FirebaseAuth.instance
                    .signOut();
                ShowToastDialog.showToast(
                    "This user is disable please contact administrator"
                        .tr);
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
