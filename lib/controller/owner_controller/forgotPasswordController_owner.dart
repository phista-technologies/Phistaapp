


import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:http/http.dart' as http;

import '../../constant/constant.dart';
import '../../constant/show_toast_dialog.dart';
import '../../env.dart';
import '../../utils/fire_store_utils.dart';


class ForgotPasswordControllerOwner extends GetxController {
  Rx<TextEditingController> otpController = TextEditingController().obs;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  RxBool passwordVisible = true.obs;
  RxBool confirmPasswordVisible = true.obs;
  RxString countryCode = "".obs;
  RxString phoneNumber = "".obs;
  RxString verificationId = "".obs;

  // RxInt resendToken = 0.obs;
  RxBool isLoading = true.obs;
  RxBool otpSend = false.obs;


  @override
  void onInit() {
    Constant.forgotPassOTP = -1;
    super.onInit();
  }




  Future<void> sendEmailWithTemplate({
    required String toEmail,
    required String templateId,
    required Map<String, dynamic> dynamicTemplateData,
  })
  async {
    final url = Uri.parse('https://api.sendgrid.com/v3/mail/send');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer ${ENV.sandGridApiKey}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "personalizations": [
          {
            "to": [
              {"email": toEmail}
            ],
            "dynamic_template_data": dynamicTemplateData,
          }
        ],
        "from": {"email": "support@phista.ca"},
        "template_id": templateId,
      }),
    );

    if (response.statusCode == 202) {
      print("✅ Email sent with template!");
    } else {
      print("❌ Failed to send email: ${response.statusCode}\n${response.body}");
    }
  }

  Future<void> sendEmailWithSendGrid({
    required String toEmail,
    required String subject,
    required String content,
  })
  async {
    print("Email:-- $toEmail");
    final url = Uri.parse('https://api.sendgrid.com/v3/mail/send');



    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer ${ENV.sandGridApiKey}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "personalizations": [
          {
            "to": [
              {"email": toEmail}
            ],
            "subject": subject,
          }
        ],
        "from": {"email": "support@phista.ca"}, // must be verified
        "content": [
          {
            "type": "text/plain",
            "value": content,
          }
        ],
      }),
    );

    if (response.statusCode == 202) {
      print("Email sent!");
    } else {
      print("Failed to send email: ${response.body}");
    }
  }

  /// new setup for send email with all platforms (android,ios,web)  Devendra 30 Oct 2025
  Future<void> sendEmailWithSendGridWithAllPlateForm({
    required String toEmail,
    required String subject,
    required String content,
  })
  async {
    print("Email:-- $toEmail");
    final url = Uri.parse("https://us-central1-phista-81bf8.cloudfunctions.net/sendEmail");
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "to": toEmail ,
        "subject": subject,
        "content": content.trim(),
      }),
    );

    if (response.statusCode == 200) {
      print("Email sent!");
    } else {
      print("Failed to send email: ${response.body}");
    }
  }


  signInWithEmailAndPassword(BuildContext context,String email, String password) async {

    try {
      FirebaseAuth.instance.signInWithEmailAndPassword(email: email,
          password: password).then((value) async {
        await FireStoreUtils.userExistOrNot(value.user!.uid).then((userExit) async {


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