import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:phista/model/parking_model.dart';
import 'package:phista/model/user_vehicle_model.dart';
import 'package:phista/utils/fire_store_utils.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../constant/constant.dart';
import '../themes/custom_dialog_box.dart';

class BookingParkingDetailsController extends GetxController {
  RxBool isLoading = false.obs;
  RxString currentMonth = DateFormat.yMMMM().format(DateTime.now()).obs;

  RxDouble selectedDuration = 1.0.obs;

  Rx<DateTime> selectedDateTime = DateTime.now().obs;
  var selectedDatesDaily = <DateTime>[].obs;
  var selectedRangeMonth = PickerDateRange(
    DateTime.now(),
    DateTime.now().add(Duration(days: 30)),
  ).obs;
  DateRangePickerController sfDateRangePickerCtrl = DateRangePickerController();



  Rx<ParkingModel> parkingModel = ParkingModel().obs;
  Rx<UserVehicleModel> vehicle = UserVehicleModel().obs;

  Rx<DateTime> startTime = DateTime.now().obs;
  Rx<DateTime> endTime = DateTime.now().obs;

  Rx<TextEditingController> startTimeController = TextEditingController().obs;
  Rx<TextEditingController> endTimeController = TextEditingController().obs;
  Rx<TextEditingController> bookingMonthsController = TextEditingController(text: "1").obs;

  Rx<UserVehicleModel> selectedVehicle = UserVehicleModel().obs;

  Rx<String> radioValue = "hourly".obs;
  Rx<DateTime> startTimeMonthly = DateTime.now().obs;
  @override
  void onInit() {
    getArgument();
    super.onInit();

  }

  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      parkingModel.value = argumentData['parkingModel'];
      getParkingDetails();
    }

    startTimeController.value.text = DateFormat('HH:mm').format(startTime.value);
    Duration duration = Duration(hours: selectedDuration.value.toInt());

    endTime.value = startTime.value.add(duration);
    endTimeController.value.text = DateFormat('HH:mm').format(endTime.value);

    isLoading.value = false;
    update();
  }

  getParkingDetails() async {
    await FireStoreUtils.getParkingDetails(parkingModel.value.id.toString()).then((value) {
      if (value != null) {
        parkingModel.value = value;
      }
    });
  }

  calculateParkingAmount() {
    return double.parse(parkingModel.value.perHrPrice.toString()) * selectedDuration.value;
  }

  String calculateDuration(String? startTime, String? endTime) {
    if (startTime != null && startTime.isNotEmpty && endTime != null && endTime.isNotEmpty) {
      return DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, int.parse(endTime.split(":").first), int.parse(endTime.split(":").last))
          .difference(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, int.parse(startTime.split(":").first), int.parse(startTime.split(":").last)))
          .inHours
          .toString();
    } else {
      return "";
    }
  }

  void showPopUp( Function() onTap) {
    Get.dialog(
      CustomDialogBoxOnlyOk(
        title: "Book Spot".tr,
        descriptions: "You can park in any available space, you don’t need to park in the exact spot selected, parkings are not mapped.".tr,
        buttonText: "Okay",
        onButtonTap: onTap,
        img: Image.asset("assets/images/parking_icon.png")
      ),
      barrierDismissible: false,
    );
  }

  DateRangePickerSelectionMode selectionModeUser(String radioType){
    if(radioType == "hourly"){
      return  DateRangePickerSelectionMode.single;
    }else if(radioType == "daily"){
      return  DateRangePickerSelectionMode.multiple;
    }else if(radioType == "monthly"){
      return  DateRangePickerSelectionMode.range;
    }
    return  DateRangePickerSelectionMode.single;
  }

  void setMonthValue(DateTime startDate,int numberOfMonth){
    DateTime endDate = DateTime(
      startDate.year,
      startDate.month + numberOfMonth,
      startDate.day,
    );

    selectedRangeMonth.value = PickerDateRange(startDate, endDate);
    sfDateRangePickerCtrl.selectedRange = PickerDateRange(startDate, endDate);
  }


  void setStartTime(TimeOfDay? startTimeTemp)async{

    if (startTimeTemp != null) {
      endTime.value = DateTime(
          selectedDateTime.value.year,
          selectedDateTime.value.month,
          selectedDateTime.value.day,
          startTimeTemp.hour, startTimeTemp.minute);

      endTimeController.value.text = DateFormat('HH:mm').format(endTime.value);

      Duration duration = Duration(
          hours: selectedDuration.value.toInt());

      startTime.value = endTime.value.subtract(duration);
      startTimeController.value.text = DateFormat('HH:mm').format(startTime.value);
    }
  }


}
