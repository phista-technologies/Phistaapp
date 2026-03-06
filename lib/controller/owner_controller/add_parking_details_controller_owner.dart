
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../constant/constant.dart';
import '../../constant/show_toast_dialog.dart';
import '../../env.dart';
import '../../model/AvailabilityWeekModel.dart';
import '../../model/location_lat_lng.dart';
import '../../model/parking_facilities_model.dart';
import '../../model/parking_model.dart';
import '../../model/positions_model.dart';
import '../../model/user_model.dart';
import '../../utils/fire_store_utils.dart';
import '../../utils/utils.dart';
import '../../widgets/geoflutterfire/src/geoflutterfire.dart';
import '../../widgets/geoflutterfire/src/models/point.dart';

class AddParkingDetailsControllerOwner extends GetxController {
  Rx<TextEditingController> nameController = TextEditingController().obs;
  Rx<TextEditingController> detailsController = TextEditingController().obs;
  Rx<TextEditingController> addressController = TextEditingController().obs;
  Rx<TextEditingController> parkingSpaceController = TextEditingController()
      .obs;
  Rx<TextEditingController> priceController = TextEditingController(text: "3")
      .obs;
  Rx<TextEditingController> dailyPriceController = TextEditingController(
      text: "15").obs;
  Rx<TextEditingController> monthlyPriceController = TextEditingController(
      text: "120").obs;
  final ImagePicker imagePicker = ImagePicker();
  RxString parkingImage = "".obs;

  Rx<LocationLatLng> locationLatLng = LocationLatLng().obs;
  RxList<ParkingFacilitiesModel> parkingFacilitiesList = <ParkingFacilitiesModel>[].obs;
  RxList<ParkingFacilitiesModel> selectedParkingFacilitiesList = <ParkingFacilitiesModel>[].obs;

  RxBool isOpen = true.obs;
  RxBool isMin4Open = false.obs;
  RxBool isMin2Open = false.obs;
  RxBool isLoading = true.obs;

  RxString parkingType = "4".obs;
  // Your new week list structure

  var weekList = <AvailabilityWeekModel>[
    AvailabilityWeekModel(day: "Monday", isAvailable: true, startTime: "00:00", endTime: "23:59"),
    AvailabilityWeekModel(day: "Tuesday", isAvailable: true, startTime: "00:00", endTime: "23:59"),
    AvailabilityWeekModel(day: "Wednesday", isAvailable: true, startTime: "00:00", endTime: "23:59"),
    AvailabilityWeekModel(day: "Thursday", isAvailable: true, startTime: "00:00", endTime: "23:59"),
    AvailabilityWeekModel(day: "Friday", isAvailable: true, startTime: "00:00", endTime: "23:59"),
    AvailabilityWeekModel(day: "Saturday", isAvailable: true, startTime: "00:00", endTime: "23:59"),
    AvailabilityWeekModel(day: "Sunday", isAvailable: true, startTime: "00:00", endTime: "23:59"),
  ].obs;

  Rx<DateTime> selectedDateTime = DateTime.now().obs;
  bool isParkingEdit = false;

  void handleParkingChange(String? value) {
    parkingType.value = value!;
  }

  @override
  void onInit() {
    getArgument();
    getData();
    super.onInit();
  }

  Rx<ParkingModel> parkingModel = ParkingModel().obs;
  Rx<UserModel> userModel = UserModel().obs;

  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      parkingModel.value = argumentData['parkingModel'];
      isParkingEdit = true;
      await FireStoreUtils.getUserParkingDetails(
          parkingModel.value.id.toString()).then((value) {
        if (value != null) {
          parkingModel.value = value;
          nameController.value.text = value.name.toString();
          detailsController.value.text = value.description.toString();
          addressController.value.text = value.address.toString();
          parkingImage.value = value.image.toString();
          locationLatLng.value = value.location!;
          isOpen.value = value.isEnable!;
          isMin4Open.value = value.isMin4Month!;
          isMin2Open.value = value.isMin2Month!;

          priceController.value.text = value.perHrPrice.toString();
          dailyPriceController.value.text = value.dailyPrice.toString();
          monthlyPriceController.value.text = value.monthlyPrice.toString();
          parkingSpaceController.value.text = value.parkingSpace.toString();
          parkingType.value = value.parkingType.toString();
          if(value.availibilityWeekList != null){
            weekList.value = value.availibilityWeekList!;
          }


            if(parkingModel.value.facilities != null){
            for (var element in parkingModel.value.facilities!) {
              selectedParkingFacilitiesList.add(element);
            }
          }
        }
      });
    }

    await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid()).then((
        value) {
      if (value != null) {
        userModel.value = value;
      }
    });

    isLoading.value = false;
    update();
  }

  getData() async {
    parkingFacilitiesList.value = await FireStoreUtils.getParkingFacilities();
    update();
  }

  final geo = Geoflutterfire();

  saveDetails() async {
    ShowToastDialog.showLoader("Please wait");
    String imageFileName = File(parkingImage.value).path
        .split('/')
        .last;
   /* if (parkingImage.value.isNotEmpty && Constant().hasValidUrl(parkingImage.value) == false) {
      parkingImage.value = await Constant.uploadUserImageToFireStorage(
          File(parkingImage.value),
          "parkingImages/${FireStoreUtils.getCurrentUid()}", imageFileName);
    }*/

    if (!Constant().hasValidUrl(parkingImage.value) && parkingImage.value.isNotEmpty) {
      if (kIsWeb) {
        /// ✅ WEB — read bytes and upload
        final XFile webImage = XFile(parkingImage.value);

        Uint8List bytes = await webImage.readAsBytes();

        parkingImage.value = await Constant.uploadUserImageToFireStorageWeb(
          bytes,
          "profileImage/${FireStoreUtils.getCurrentUid()}",
          webImage.name, // ✅ correct file name
        );

      }
      else {
        /// ✅ MOBILE — use File()
        parkingImage.value = await Constant.uploadUserImageToFireStorage(
          File(parkingImage.value),
          "profileImage/${FireStoreUtils.getCurrentUid()}",
          File(parkingImage.value).path.split('/').last,
        );
      }
    }


    if (parkingModel.value.id == null || parkingModel.value.userId == null) {
      parkingModel.value.id = Constant.getUuid();
      parkingModel.value.userId = FireStoreUtils.getCurrentUid();
      parkingModel.value.subscriptionTotalOrders =
          userModel.value.subscriptionTotalOrders;
      parkingModel.value.subscriptionPlanId =
          userModel.value.subscriptionPlanId;
      parkingModel.value.subscriptionPlan = userModel.value.subscriptionPlan;
      parkingModel.value.subscriptionPlan?.createdAt =
          userModel.value.subscriptionPlan!.createdAt;
      parkingModel.value.subscriptionExpiryDate =
          userModel.value.subscriptionExpiryDate;
    }
    parkingModel.value.name = nameController.value.text;
    parkingModel.value.description = detailsController.value.text;
    parkingModel.value.address = addressController.value.text;
    parkingModel.value.image = parkingImage.value;
    parkingModel.value.isEnable = isOpen.value;
    parkingModel.value.isMin4Month = isMin4Open.value;
    parkingModel.value.isMin2Month = isMin2Open.value;
    parkingModel.value.location = locationLatLng.value;
    parkingModel.value.facilities = selectedParkingFacilitiesList;
    parkingModel.value.perHrPrice = priceController.value.text;
    parkingModel.value.dailyPrice = dailyPriceController.value.text;
    parkingModel.value.monthlyPrice = monthlyPriceController.value.text;
    parkingModel.value.parkingSpace = parkingSpaceController.value.text;
    parkingModel.value.parkingType = parkingType.value;
    parkingModel.value.availibilityWeekList = weekList;

    GeoFirePoint position = geo.point(latitude: locationLatLng.value.latitude!,
        longitude: locationLatLng.value.longitude!);
    parkingModel.value.position =
        Positions(geoPoint: position.geoPoint, geohash: position.hash);
    await FireStoreUtils.saveParkingDetails(parkingModel.value).then((value) async {

      if(!isParkingEdit){
        try{
          await Utils.sendEmailWithTemplateWithAllPlatForms(
            toEmail: ENV.adminEmail,
            templateId: ENV.templateIdAddParking,
            dynamicTemplateData: {
              "ownerName" : userModel.value.fullName,
              "address" : parkingModel.value.address
            },
          ).then((value) {
            ShowToastDialog.closeLoader();
          },);
        }catch(e){
          ShowToastDialog.closeLoader();
          log("Exception sending template :- ",error: e.toString());
        }
      }
      Get.back(result: true);

      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("Parking Information save");
    });
  }

  Future pickFile({
    required ImageSource source,
  }) async {
    try {
      XFile? image = await imagePicker.pickImage(source: source);
      if (image == null) return;
      Get.back();

      parkingImage.value = image.path;
    } on PlatformException catch (e) {
      ShowToastDialog.showToast("Failed to Pick : \n $e");
    }
  }


  bool checkAvailability(List<AvailabilityWeekModel> tempWeekList){

    if (!tempWeekList.any((element) => element.isAvailable!)) {
      print('Please select at least one availability.');
      return false;
    }

    return true;
  }

  TimeOfDay parseSelectedTime(String timeString) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return TimeOfDay(hour: hour, minute: minute);
  }


}
