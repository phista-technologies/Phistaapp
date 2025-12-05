import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../constant/constant.dart';
import '../../constant/show_toast_dialog.dart';
import '../../model/user_model.dart';
import '../../utils/fire_store_utils.dart';


class EditProfileControllerOwner extends GetxController {
  RxBool isLoading = true.obs;
  Rx<UserModel> userModel = UserModel().obs;

  Rx<TextEditingController> fullNameController = TextEditingController().obs;
  Rx<TextEditingController> emailController = TextEditingController().obs;
  Rx<TextEditingController> dateOfBirthController = TextEditingController().obs;
  Rx<TextEditingController> phoneNumberController = TextEditingController().obs;
  Rx<TextEditingController> countryCodeController = TextEditingController(text: "+1").obs;

  Rx<GlobalKey<FormState>> formKey = GlobalKey<FormState>().obs;

  RxString gender = "Male".obs;

  void handleGenderChange(String? value) {
    gender.value = value!;
  }

  @override
  void onInit() {
    getData();
    super.onInit();
  }

  getData() async {
    await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid()).then((value) {
      if (value != null) {
        userModel.value = value;
        print("userModel.value.profilePic:--${userModel.value.profilePic}");
        phoneNumberController.value.text = userModel.value.phoneNumber??"";
        countryCodeController.value.text = userModel.value.countryCode.toString();
        emailController.value.text = userModel.value.email.toString();
        fullNameController.value.text = userModel.value.fullName.toString();
        dateOfBirthController.value.text = userModel.value.dateOfBirth.toString();
        profileImage.value = userModel.value.profilePic ?? "";
        //gender.value = userModel.value.gender.toString();
        isLoading.value = false;
      }
    });
  }

  final ImagePicker _imagePicker = ImagePicker();
  RxString profileImage = "".obs;

  /*Future pickFile({required ImageSource source}) async {
    try {
      XFile? image = await _imagePicker.pickImage(source: source);
      if (image == null) return;
      Get.back();
      profileImage.value = image.path;
    } on PlatformException catch (e) {
      ShowToastDialog.showToast("${"failed_to_pick".tr} : \n $e");
    }
  }*/

  Future pickFile({required ImageSource source}) async {
    try {
      XFile? image = await _imagePicker.pickImage(source: source);
      if (image == null) return;

      Get.back();

      if (kIsWeb) {
        // ✅ On Web → image.path is a Blob URL, use it directly
        profileImage.value = image.path;
      } else {
        // ✅ On Mobile → use local file path
        profileImage.value = image.path;
      }

    } on PlatformException catch (e) {
      ShowToastDialog.showToast("${"failed_to_pick".tr} : \n $e");
    }
  }


  updateProfile() async {
    ShowToastDialog.showLoader("Please wait".tr);
    /*if (Constant().hasValidUrl(profileImage.value) == false && profileImage.value.isNotEmpty) {
      profileImage.value = await Constant.uploadUserImageToFireStorage(
        File(profileImage.value),
        "profileImage/${FireStoreUtils.getCurrentUid()}",
        File(profileImage.value).path.split('/').last,
      );
    }*/

    if (!Constant().hasValidUrl(profileImage.value) && profileImage.value.isNotEmpty) {
      if (kIsWeb) {
        /// ✅ WEB — read bytes and upload
        final XFile webImage = XFile(profileImage.value);

        Uint8List bytes = await webImage.readAsBytes();

        profileImage.value = await Constant.uploadUserImageToFireStorageWeb(
          bytes,
          "profileImage/${FireStoreUtils.getCurrentUid()}",
          webImage.name, // ✅ correct file name
        );

      }
      else {
        /// ✅ MOBILE — use File()
        profileImage.value = await Constant.uploadUserImageToFireStorage(
          File(profileImage.value),
          "profileImage/${FireStoreUtils.getCurrentUid()}",
          File(profileImage.value).path.split('/').last,
        );
      }
    }

    UserModel userModelData = userModel.value;
    userModelData.fullName = fullNameController.value.text;
    userModelData.profilePic = profileImage.value;
    userModelData.dateOfBirth = dateOfBirthController.value.text;
    userModelData.email = emailController.value.text;
    userModelData.phoneNumber = phoneNumberController.value.text;
    userModelData.countryCode = countryCodeController.value.text;
    //userModelData.gender = gender.value;

    FireStoreUtils.updateUser(userModelData).then(
      (value) {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(
          "profile_updated_successfully".tr,
        );
        Get.back();
        update();
      },
    );
  }
}
