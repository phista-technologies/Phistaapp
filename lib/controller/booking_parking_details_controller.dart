import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:phista/model/parking_model.dart';
import 'package:phista/model/user_vehicle_model.dart';
import 'package:phista/utils/fire_store_utils.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../constant/constant.dart';
import '../model/order_model.dart';
import '../themes/custom_dialog_box.dart';
import '../utils/utils.dart';

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
  RxInt bookingMonths = 1.obs;


  //Slot booking
  RxBool isNotAvailableAnyDay = false.obs;
  RxList<OrderModel> selectedOrderModel = <OrderModel>[].obs;

  @override
  void onInit() {
    getArgument();
    super.onInit();

  }

  getArgument() async {
    dynamic argumentData = Get.arguments;
    Constant.bookingTypeConst = "hourly";
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
    await FireStoreUtils.getParkingDetails(parkingModel.value.id.toString()).then((value) async {
      if (value != null) {
        parkingModel.value = value;

      }
    });
  }

  calculateParkingAmount(String type,String noOfMonth) {

    if(type == "hourly" && selectedDuration.value <= 5.0){
      return double.parse(parkingModel.value.perHrPrice.toString()) * selectedDuration.value;
    }else if(type == "hourly" && selectedDuration.value >  5.0){
      print(parkingModel.value.dailyPrice.toString());
      return double.parse(parkingModel.value.dailyPrice.toString());
    }else if(type == "monthly"){
      print("type :- $type, $noOfMonth");
      return double.parse(parkingModel.value.monthlyPrice.toString()) * int.parse(noOfMonth);
    }else{
      return "0.0";
    }

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

  void showPopUp(String title,String msg) {
    Get.dialog(
      CustomDialogBoxOnlyOk(
        title:title,
        descriptions: msg,
        buttonText: "Okay".tr,
        onButtonTap: (){
          Get.back();
  }
  ,
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

  TimeOfDay parseSelectedTime(String timeString) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return TimeOfDay(hour: hour, minute: minute);
  }

  double timeHourDifference(String startTimeStr, String endTimeStr){
    DateTime now = DateTime.now();
    DateTime startTime = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(startTimeStr.split(":")[0]),
      int.parse(startTimeStr.split(":")[1]),
    );

    DateTime endTime = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(endTimeStr.split(":")[0]),
      int.parse(endTimeStr.split(":")[1]),
    );

    Duration diff = endTime.difference(startTime);

    // Get total hours
    int hours = diff.inHours;


    print("Difference: $hours hours ");
    return hours.toDouble();
  }

  /*------------------ Parking Slot ----------------------------- */
  Future<String> selectParkingSlot(String bookingTypeTemp,OrderModel orderModel)async{

    List<String> freeBookingSlotList = [];
    String tempSelectedParkingSlot = "";
    isNotAvailableAnyDay.value =  await isMonthParkingAvailable(bookingTypeTemp,orderModel);

    ///  isNotAvailableAnyDay == True(No parking Available) &&  isNotAvailableAnyDay == False (parking Available)
    if(!isNotAvailableAnyDay.value){ // parking Available
      List<OrderModel> selectedOrder =   await getBookedParking(bookingTypeTemp,orderModel);

      print("selectedOrder :-- ${selectedOrder.length}");

      for(int index = 0; index < int.parse(parkingModel.value.parkingSpace.toString()) ; index++){
        var isBooked = selectedOrder.where((element) => element.parkingSlotId.toString() == "A-${index + 1}");
        if(isBooked.isEmpty){
          freeBookingSlotList.add("A-${index + 1}");
        }
      }
    }


    for(var value in freeBookingSlotList){
      print("freeBookingSlotList :-- $value");
    }

    if(freeBookingSlotList.isNotEmpty){
      tempSelectedParkingSlot = freeBookingSlotList[0];
    }

    return tempSelectedParkingSlot;
  }

  getParkingDetailsSlot(String parkingId,String bookingTypeTemp,OrderModel orderModel) async {
    await FireStoreUtils.getParkingDetails(parkingId).then((value) async {
      if (value != null) {
        print("value:--->> ${value}");
        parkingModel.value = value;

        print("availabilityList:--->> ${parkingModel.value.availibilityWeekList}");
      }
    });
    isLoading.value = false;
  }



  Future<List<OrderModel>> getBookedParking(String type, OrderModel orderModel) async {
    selectedOrderModel.clear(); // make sure list is fresh each call

    if (type == "hourly") {
      log("myTime ===> ${Utils.stringToTimeStamp(orderModel.bookingDate!).toDate()} "
          "\n==>StartTime ${orderModel.bookingStartTime!.toDate()} "
          "\n==>endTime ${orderModel.bookingEndTime!.toDate()}");

      final value = await FireStoreUtils.getOrder(
        Utils.stringToTimeStamp(orderModel.bookingDate!),
        orderModel.bookingStartTime!,
        orderModel.bookingEndTime!,
        orderModel.parkingId.toString(),
        type,
      );

      if (value != null) {
        for (var element in value) {
          OrderModel orderModel1 = element;

          if (orderModel1.bookingType.toString() == "1") {
            if (orderModel1.bookingStartTime!.toDate().isBefore(orderModel.bookingStartTime!.toDate()) &&
                orderModel1.bookingEndTime!.toDate().isAfter(orderModel.bookingStartTime!.toDate())) {
              log("parking ===>${orderModel1.parkingSlotId}");
              selectedOrderModel.add(orderModel1);
            } else if (orderModel.bookingStartTime!.toDate().isAtSameMomentAs(orderModel1.bookingStartTime!.toDate())) {
              selectedOrderModel.add(orderModel1);
              log("parking ===>4 ${orderModel1.parkingSlotId}");
            } else if (orderModel.bookingStartTime!.toDate().isBefore(orderModel1.bookingStartTime!.toDate())) {
              if (orderModel.bookingEndTime!.toDate().isAfter(orderModel1.bookingEndTime!.toDate())) {
                selectedOrderModel.add(orderModel1);
                log("parking ===>2 ${orderModel1.parkingSlotId}");
              } else if (orderModel.bookingEndTime!.toDate().isAtSameMomentAs(orderModel1.bookingEndTime!.toDate())) {
                selectedOrderModel.add(orderModel1);
                log("parking ===>2 ${orderModel1.parkingSlotId}");
              } else if (orderModel.bookingEndTime!.toDate().isBefore(orderModel1.bookingEndTime!.toDate()) &&
                  orderModel.bookingEndTime!.toDate().isAfter(orderModel1.bookingStartTime!.toDate())) {
                selectedOrderModel.add(orderModel1);
                log("parking ===>3 ${orderModel1.parkingSlotId}");
              } else {
                log("parking ===>2 else");
              }
            } else {
              log("parking ===>1 else");
            }
          } else if (orderModel1.bookingType.toString() == "2") {
            selectedOrderModel.add(orderModel1);
          } else if (orderModel1.bookingType.toString() == "3") {
            final List<dynamic> bookingDates = orderModel1.bookingDate!.split(',').map((e) => e.trim()).toList();
            if (bookingDates.length == 2) {
              Timestamp targetDate = Utils.stringToTimeStamp(orderModel.bookingDate!);
              Timestamp startDate = Utils.stringToTimeStamp(bookingDates[0].trim());
              Timestamp endDate = Utils.stringToTimeStamp(bookingDates[1].trim());
              bool isWithinRange = targetDate.seconds.compareTo(startDate.seconds) >= 0 &&
                  targetDate.seconds.compareTo(endDate.seconds) <= 0;
              print("isWithinRange hourly:-- $isWithinRange");
              if (isWithinRange) {
                selectedOrderModel.add(orderModel1);
              }
            }
          }
        }
      }
    } else if (type == "monthly") {
      try {
        final value = await FireStoreUtils.getOrder(
          Utils.stringToTimeStamp(orderModel.bookingDate!), // not use
          orderModel.bookingStartTime!,
          orderModel.bookingEndTime!,
          orderModel.parkingId.toString(),
          type,
        );

        if (value != null) {
          for (var element in value) {
            OrderModel orderModel1 = element;

            if (orderModel1.bookingType.toString() == "1") {
              final List<dynamic> bookingDates =
              orderModel.bookingDate!.split(',').map((e) => e.trim()).toList();

              if (bookingDates.length == 2) {
                Timestamp targetDate = Utils.stringToTimeStamp(orderModel1.bookingDate!);
                Timestamp startDate = Utils.stringToTimeStamp(bookingDates[0].trim());
                Timestamp endDate = Utils.stringToTimeStamp(bookingDates[1].trim());
                bool isWithinRange = targetDate.seconds.compareTo(startDate.seconds) >= 0 &&
                    targetDate.seconds.compareTo(endDate.seconds) <= 0;
                print("isWithinRange :-- $isWithinRange");
                if (isWithinRange) {
                  selectedOrderModel.add(orderModel1);
                }
              }
            } else if (orderModel1.bookingType.toString() == "3") {
              String bookingDateFromFirebase = orderModel1.bookingDate!;
              String rangeDate = orderModel.bookingDate!;
              List<String> bookingParts = bookingDateFromFirebase.split(',');
              List<String> rangeParts = rangeDate.split(',');

              if (bookingParts.length == 2 && rangeParts.length == 2) {
                DateTime bookingStart = Utils.stringToTimeStamp(bookingParts[0].trim()).toDate();
                DateTime bookingEnd = Utils.stringToTimeStamp(bookingParts[1].trim()).toDate();
                DateTime rangeStart = Utils.stringToTimeStamp(rangeParts[0].trim()).toDate();
                DateTime rangeEnd = Utils.stringToTimeStamp(rangeParts[1].trim()).toDate();
                bool noOverlap = bookingEnd.isBefore(rangeStart) || bookingStart.isAfter(rangeEnd);

                if (noOverlap) {
                  print("No collision. The date ranges do not overlap.");
                } else {
                  print("Collision detected! Date ranges overlap.");
                  selectedOrderModel.add(orderModel1);
                }
              } else {
                print("Invalid date format in input.");
              }
            }
            print("isNotAvailableAnyDay1");
          }
        }
      } catch (e) {
        print("monthly Exception :-- $e");
      }
    }

    return selectedOrderModel.value;
  }


  Future<bool>isMonthParkingAvailable(String type,OrderModel orderModel) async {
    final list = parkingModel.value.availibilityWeekList;
    print("$list");
    // Treat null or empty as fully closed
    if (list == null || list.isEmpty) {
      print("return--null");
      return false;
    }

    if (type == "hourly"){
      var dayTemp = weekName(orderModel.bookingDate??"");
      Timestamp?  startTime = orderModel.bookingStartTime;
      Timestamp? endTime = orderModel.bookingEndTime;



      print("startTime :-- ${startTime?.toDate()} , endTime :-- $endTime ");


      print("bookingDay --> $dayTemp");
      for (var day in list) {
        print("within Range :-- ${isWithinTimeRange(endTime!.toDate(), day.startTime??"", day.endTime??"")}");
        if (day.isAvailable == false ) {
          if((day.day != null) && (dayTemp.toString().toLowerCase() == day.day.toString().toLowerCase()) ){
            print("Closed on 22 : ${day.day}");
            return true;
          }
        }
        else if((day.isAvailable == true && !isWithinTimeRange(startTime!.toDate(), day.startTime??"", day.endTime??"")) ||
            (day.isAvailable == true && !isWithinTimeRange(endTime!.toDate(), day.startTime??"", day.endTime??""))){
          return true;
        }
      }

    }
    else if(type == "monthly"){
      for (var day in list) {
        if (day.isAvailable == false ) {
          print("Closed on: ${day.day}");
          return true;
        }
        else if ((day.isAvailable == true && day.startTime != "00:00") || (day.isAvailable == true && day.endTime != "23:59") ){
          print("return25");
          return true;
        }
      }
    }
    print("return2");
    return false; // All days are open
  }


  String weekName(String dateLocal){
    String input = dateLocal;
    input = input.replaceAll(' at ', ' ');
    DateFormat format = DateFormat("d MMMM yyyy HH:mm:ss 'UTC'+H:mm");
    DateTime date = format.parse(input);

    String weekday = DateFormat('EEEE').format(date);

    return weekday;
  }


  bool isWithinTimeRange(DateTime dateTime, String startTimeStr, String endTimeStr) {
    final timeOnly = TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);

    final startParts = startTimeStr.split(":");
    final endParts = endTimeStr.split(":");
    final startTime = TimeOfDay(hour: int.parse(startParts[0]), minute: int.parse(startParts[1]));
    final endTime = TimeOfDay(hour: int.parse(endParts[0]), minute: int.parse(endParts[1]));

    return _compareTimeOfDay(timeOnly, startTime) >= 0 &&
        _compareTimeOfDay(timeOnly, endTime) <= 0;
  }

  int _compareTimeOfDay(TimeOfDay a, TimeOfDay b) {
    if (a.hour != b.hour) return a.hour.compareTo(b.hour);
    return a.minute.compareTo(b.minute);
  }



}
