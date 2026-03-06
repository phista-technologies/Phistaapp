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

import '../../constant/constant.dart';
import '../../model/order_model.dart';
import '../../themes/custom_dialog_box.dart';
import '../../utils/utils.dart';

/*class BookingParkingDetailsController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isFromTimerScreen = false.obs;
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

 //New booking
  Rx<OrderModel> orderModel = OrderModel().obs;

  @override
  void onInit() {
    Constant.globalParkingModel.value = null;

    getArgument();
    super.onInit();

  }

  getArgument() async {
    dynamic argumentData = Get.arguments;
    Constant.bookingTypeConst = "hourly";
    if (argumentData != null) {
      parkingModel.value = argumentData['parkingModel'];
      isFromTimerScreen.value = argumentData['isFromTimerScreen'];
      if (isFromTimerScreen.value == true){
        preSelectedFormTimerScreen();
      }
      getParkingDetails();
    }
    await setDefaultVehicle();
    startTimeController.value.text = DateFormat('HH:mm').format(startTime.value);
    Duration duration = Duration(hours: selectedDuration.value.toInt());

    endTime.value = startTime.value.add(duration);
    endTimeController.value.text = DateFormat('HH:mm').format(endTime.value);

    isLoading.value = false;
    update();
  }

  preSelectedFormTimerScreen(){
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      orderModel.value = argumentData['orderModel'];
     if (orderModel.value.bookingType.toString() == "1"){
       radioValue.value = "hourly";
       print(orderModel.value.bookingEndTime!.toDate());
       startTimeController.value.text = DateFormat('HH:mm').format(orderModel.value.bookingEndTime!.toDate());
     }else{
       radioValue.value = "monthly";
     }


    }

  }

  getParkingDetails() async {
    await FireStoreUtils.getParkingDetails(parkingModel.value.id.toString()).then((value) async {
      if (value != null) {
        parkingModel.value = value;

      }
    });
  }
  setDefaultVehicle() async {
    await FireStoreUtils.getUserVehicle().then((value) {
      if (value != null && value.isNotEmpty) {
        selectedVehicle.value = value.first;   // 👉 default 0 index
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

  */
/*------------------ Parking Slot ----------------------------- */
/*

  Future<String> selectParkingSlot(String bookingTypeTemp,OrderModel orderModel)async{

    List<String> freeBookingSlotList = [];
    String tempSelectedParkingSlot = "";
    isNotAvailableAnyDay.value =  await isMonthParkingAvailable(bookingTypeTemp,orderModel);

    ///  isNotAvailableAnyDay == True(No parking Available) &&  isNotAvailableAnyDay == False (parking Available)
    if(!isNotAvailableAnyDay.value){ // parking Available
      List<OrderModel> selectedOrder =  await getBookedParking(bookingTypeTemp,orderModel);

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

      log("getOrderValue :-- ",error: value);

      if (value != null) {
        for (var element in value) {
          OrderModel orderModel1 = element;

          log("orderModel1 :-- ${orderModel1.bookingType} : ${orderModel1.parkingDetails?.name}");

          if (orderModel1.bookingType.toString() == "1") {
            if (orderModel1.bookingStartTime!.toDate().toUtc().isBefore(orderModel.bookingStartTime!.toDate().toUtc()) &&
                orderModel1.bookingEndTime!.toDate().toUtc().isAfter(orderModel.bookingStartTime!.toDate().toUtc())) {
              log("parking ===>${orderModel1.parkingSlotId}");
              selectedOrderModel.add(orderModel1);
            } else if (orderModel.bookingStartTime!.toDate().toUtc().isAtSameMomentAs(orderModel1.bookingStartTime!.toDate().toUtc())) {
              selectedOrderModel.add(orderModel1);
              log("parking ===>4 ${orderModel1.parkingSlotId}");
            } else if (orderModel.bookingStartTime!.toDate().toUtc().isBefore(orderModel1.bookingStartTime!.toDate().toUtc())) {
              if (orderModel.bookingEndTime!.toDate().toUtc().isAfter(orderModel1.bookingEndTime!.toDate().toUtc())) {
                selectedOrderModel.add(orderModel1);
                log("parking ===>2 ${orderModel1.parkingSlotId}");
              } else if (orderModel.bookingEndTime!.toDate().toUtc().isAtSameMomentAs(orderModel1.bookingEndTime!.toDate().toUtc())) {
                selectedOrderModel.add(orderModel1);
                log("parking ===>2 ${orderModel1.parkingSlotId}");
              } else if (orderModel.bookingEndTime!.toDate().toUtc().isBefore(orderModel1.bookingEndTime!.toDate().toUtc()) &&
                  orderModel.bookingEndTime!.toDate().toUtc().isAfter(orderModel1.bookingStartTime!.toDate().toUtc())) {
                selectedOrderModel.add(orderModel1);
                log("parking ===>3 ${orderModel1.parkingSlotId}");
              } else {
                log("parking ===>2 else");
              }
            } else {
              log("parking ===>1 else");
            }
          }
          else if (orderModel1.bookingType.toString() == "2") {
            selectedOrderModel.add(orderModel1);
          }
          else if (orderModel1.bookingType.toString() == "3") {
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
    }
    else if (type == "monthly") {
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
            }
            else if (orderModel1.bookingType.toString() == "3") {
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



}*/

class BookingParkingDetailsController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isFromTimerScreen = false.obs;
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
  Rx<String> radioValue = "hourly".obs; // "hourly" | "daily" | "monthly"
  Rx<DateTime> startTimeMonthly = DateTime.now().obs;
  RxInt bookingMonths = 1.obs;

  // Slot booking
  RxBool isNotAvailableAnyDay = false.obs;
  RxList<OrderModel> selectedOrderModel = <OrderModel>[].obs;

  // New booking
  Rx<OrderModel> orderModel = OrderModel().obs;

  @override
  void onInit() {
    Constant.globalParkingModel.value = null;
    super.onInit();
    // Make sure we await argument processing before UI relies on values
    // (onInit can be async, but keep initialization here and call async function)
    _initFromArguments();
  }

  Future<void> _initFromArguments() async {
    isLoading.value = true;
    await getArgument();
    isLoading.value = false;
    update();
  }

  Future<void> getArgument() async {
    dynamic argumentData = Get.arguments;
    Constant.bookingTypeConst = "hourly";

    // default initial times (ensure consistent start & end)
    startTime.value = DateTime.now();
    endTime.value = startTime.value.add(Duration(hours: selectedDuration.value.toInt()));
    startTimeController.value.text = DateFormat('HH:mm').format(startTime.value);
    endTimeController.value.text = DateFormat('HH:mm').format(endTime.value);

    if (argumentData != null) {
      if (argumentData['parkingModel'] != null) {
        parkingModel.value = argumentData['parkingModel'];
      }
      isFromTimerScreen.value = argumentData['isFromTimerScreen'] ?? false;

      // If coming from timer screen, preselect values from provided orderModel
      if (isFromTimerScreen.value == true) {
        orderModel.value = argumentData['orderModel'] ?? OrderModel();
        _preselectFromTimerScreen();
      }

      // fetch parking details (can update availability / prices)
      await getParkingDetails();
    }

    await setDefaultVehicle();

    // re-calc endTime if duration changed
    Duration duration = Duration(hours: selectedDuration.value.toInt());
    endTime.value = startTime.value.add(duration);
    endTimeController.value.text = DateFormat('HH:mm').format(endTime.value);

    // bookingMonths controller sync
    bookingMonthsController.value.text = bookingMonths.value.toString();

    update();
  }

  /// Robust preselection: fills radioValue, start/end times, selectedDateTime,
  /// selectedDuration and monthly range if applicable.
  void _preselectFromTimerScreen() {
    final om = orderModel.value;

    // bookingType mapping (from your logic: "1" -> hourly, "2" -> monthly, "3" -> daily)
    final bType = om.bookingType?.toString() ?? "1";

    if (bType == "1") {
      radioValue.value = "hourly";

      /// Use ONLY old bookingEndTime as new start
      if (om.bookingEndTime != null) {
        final endTs = om.bookingEndTime!.toDate();
        // NEW START = OLD END
        startTime.value = endTs;
        startTime.value = startTime.value.add(Duration(minutes: 1));
        
        // default 1 hour booking
        endTime.value = startTime.value.add(Duration(hours: 1,minutes: 1));
        selectedDuration.value = 1;
        // UI
        startTimeController.value.text = DateFormat('HH:mm').format(startTime.value);
        endTimeController.value.text = DateFormat('HH:mm').format(endTime.value);
        selectedDateTime.value = DateTime(endTs.year, endTs.month, endTs.day);
        return;   // VERY IMPORTANT so it does not run old logic
      }
    }
    // Ensure UI controllers reflect updated values
    bookingMonthsController.value.text = bookingMonths.value.toString();
    startTimeController.value.text = DateFormat('HH:mm').format(startTime.value);
    endTimeController.value.text = DateFormat('HH:mm').format(endTime.value);
  }

  int getMinMonth() {
    int minMonth = 1;

    if (parkingModel.value.isMin2Month == true) {
      minMonth = 2;
    }

    if (parkingModel.value.isMin4Month == true) {
      minMonth = 4;
    }

    return minMonth;
  }

  getParkingDetails() async {
    final value = await FireStoreUtils.getParkingDetails(parkingModel.value.id.toString());
    if (value != null) {
      parkingModel.value = value;
    }
  }

  setDefaultVehicle() async {
    final value = await FireStoreUtils.getUserVehicle();
    if (value != null && value.isNotEmpty) {
      selectedVehicle.value = value.first; // default 0 index
    }
  }

  /// Returns double amount (not string). Always returns a double.
  double calculateParkingAmount(String type, String noOfMonth) {
    try {
      if (type == "hourly") {
        if (selectedDuration.value <= 5.0) {
          return double.tryParse(parkingModel.value.perHrPrice?.toString() ?? "0")! * selectedDuration.value;
        } else {
          return double.tryParse(parkingModel.value.dailyPrice?.toString() ?? "0")!;
        }
      } else if (type == "monthly") {
        final months = int.tryParse(noOfMonth) ?? bookingMonths.value;
        return double.tryParse(parkingModel.value.monthlyPrice?.toString() ?? "0")! * months;
      } else {
        return 0.0;
      }
    } catch (e) {
      print("calculateParkingAmount error: $e");
      return 0.0;
    }
  }

  String calculateDuration(String? startTimeStr, String? endTimeStr) {
    if (startTimeStr != null && startTimeStr.isNotEmpty && endTimeStr != null && endTimeStr.isNotEmpty) {
      try {
        final startParts = startTimeStr.split(":");
        final endParts = endTimeStr.split(":");
        final start = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day,
            int.parse(startParts[0]), int.parse(startParts[1]));
        final end = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day,
            int.parse(endParts[0]), int.parse(endParts[1]));
        return end.difference(start).inHours.toString();
      } catch (e) {
        return "";
      }
    } else {
      return "";
    }
  }

  void showPopUp(String title, String msg) {
    Get.dialog(
      CustomDialogBoxOnlyOk(
        title: title,
        descriptions: msg,
        buttonText: "Okay".tr,
        onButtonTap: () {
          Get.back();
        },
        img: Image.asset("assets/images/parking_icon.png"),
      ),
      barrierDismissible: false,
    );
  }

  DateRangePickerSelectionMode selectionModeUser(String radioType) {
    if (radioType == "hourly") {
      return DateRangePickerSelectionMode.single;
    } else if (radioType == "daily") {
      return DateRangePickerSelectionMode.multiple;
    } else if (radioType == "monthly") {
      return DateRangePickerSelectionMode.range;
    }
    return DateRangePickerSelectionMode.single;
  }

  void setMonthValue(DateTime startDate, int numberOfMonth) {
    DateTime endDate = DateTime(
      startDate.year,
      startDate.month + numberOfMonth,
      startDate.day,
    );

    selectedRangeMonth.value = PickerDateRange(startDate, endDate);
    sfDateRangePickerCtrl.selectedRange = PickerDateRange(startDate, endDate);
    bookingMonths.value = numberOfMonth;
    bookingMonthsController.value.text = bookingMonths.value.toString();
  }

  void setStartTime(TimeOfDay? startTimeTemp) async {
    if (startTimeTemp != null) {
      // Here "endTime" in original was used as 'selected end', so I'll set startTime as earlier and endTime as provided
      final newStart = DateTime(
          selectedDateTime.value.year,
          selectedDateTime.value.month,
          selectedDateTime.value.day,
          startTimeTemp.hour,
          startTimeTemp.minute);

      startTime.value = newStart;
      startTimeController.value.text = DateFormat('HH:mm').format(startTime.value);

      // Recompute endTime based on selectedDuration
      Duration duration = Duration(hours: selectedDuration.value.toInt());
      endTime.value = startTime.value.add(duration);
      endTimeController.value.text = DateFormat('HH:mm').format(endTime.value);
    }
  }

  TimeOfDay parseSelectedTime(String timeString) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return TimeOfDay(hour: hour, minute: minute);
  }

  double timeHourDifference(String startTimeStr, String endTimeStr) {
    DateTime now = DateTime.now();
    DateTime start = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(startTimeStr.split(":")[0]),
      int.parse(startTimeStr.split(":")[1]),
    );

    DateTime end = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(endTimeStr.split(":")[0]),
      int.parse(endTimeStr.split(":")[1]),
    );

    Duration diff = end.difference(start);
    int hours = diff.inHours;
    print("Difference: $hours hours ");
    return hours.toDouble();
  }

  /*------------------ Parking Slot ----------------------------- */

 /* Future<String> selectParkingSlot(String bookingTypeTemp, OrderModel orderModel) async {
    List<String> freeBookingSlotList = [];
    String tempSelectedParkingSlot = "";
    isNotAvailableAnyDay.value = await isMonthParkingAvailable(bookingTypeTemp, orderModel);

    /// isNotAvailableAnyDay == True(No parking Available)
    if (!isNotAvailableAnyDay.value) {
      List<OrderModel> selectedOrder = await getBookedParking(bookingTypeTemp, orderModel);
      for (int index = 0; index < int.parse(parkingModel.value.parkingSpace.toString()); index++) {
        var isBooked = selectedOrder.where((element) => element.parkingSlotId.toString() == "A-${index + 1}");
        if (isBooked.isEmpty) {
          freeBookingSlotList.add("A-${index + 1}");
        }
      }
    }

    if (freeBookingSlotList.isNotEmpty) {
      tempSelectedParkingSlot = freeBookingSlotList[0];
    }

    return tempSelectedParkingSlot;
  }*/

  Future<String> selectParkingSlot(
      String bookingTypeTemp,
      OrderModel orderModel,
      {String? fixedSlotId}  // NEW OPTIONAL PARAM
      ) async {

    List<String> freeBookingSlotList = [];
    String tempSelectedParkingSlot = "";

    isNotAvailableAnyDay.value =
    await isMonthParkingAvailable(bookingTypeTemp, orderModel);

    if (!isNotAvailableAnyDay.value) {
      List<OrderModel> selectedOrder =
      await getBookedParking(bookingTypeTemp, orderModel);

      DateTime reqStart = orderModel.bookingStartTime!.toDate().toUtc();
      DateTime reqEnd = orderModel.bookingEndTime!.toDate().toUtc();

      // 🟦 CASE 1: FIXED SLOT CHECK
      if (fixedSlotId != null) {
        var slotBookings =
        selectedOrder.where((e) => e.parkingSlotId == fixedSlotId).toList();
        bool isBooked = false;
        for (var b in slotBookings) {
          DateTime s = b.bookingStartTime!.toDate().toUtc();
          DateTime e = b.bookingEndTime!.toDate().toUtc();
          bool overlaps = !(e.isBefore(reqStart) || s.isAfter(reqEnd));
          if (overlaps) {
            isBooked = true;
            break;
          }
        }
        return isBooked ? "" : fixedSlotId;
      }

      // 🟩 CASE 2: AUTO SLOT ASSIGNMENT (OLD FLOW)
      for (int index = 0;
      index < int.parse(parkingModel.value.parkingSpace.toString());
      index++) {
        String slotId = "A-${index + 1}";

        var slotBookings =
        selectedOrder.where((e) => e.parkingSlotId == slotId).toList();

        bool isBooked = false;

        for (var b in slotBookings) {
          DateTime s = b.bookingStartTime!.toDate().toUtc();
          DateTime e = b.bookingEndTime!.toDate().toUtc();
          bool overlaps = !(e.isBefore(reqStart) || s.isAfter(reqEnd));

          if (overlaps) {
            isBooked = true;
            break;
          }
        }

        if (!isBooked) {
          freeBookingSlotList.add(slotId);
        }
      }
    }

    if (freeBookingSlotList.isNotEmpty) {
      tempSelectedParkingSlot = freeBookingSlotList[0];
    }

    return tempSelectedParkingSlot;
  }


  getParkingDetailsSlot(String parkingId, String bookingTypeTemp, OrderModel orderModel) async {
    final value = await FireStoreUtils.getParkingDetails(parkingId);
    if (value != null) {
      parkingModel.value = value;
    }
    isLoading.value = false;
  }

  Future<List<OrderModel>> getBookedParking(String type, OrderModel orderModel) async {
    selectedOrderModel.clear(); // make sure list is fresh each call

    // (kept your original logic but fixed some small null-safety assumptions)
    if (type == "hourly") {
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
            final aStart = orderModel1.bookingStartTime!.toDate().toUtc();
            final aEnd = orderModel1.bookingEndTime!.toDate().toUtc();
            final bStart = orderModel.bookingStartTime!.toDate().toUtc();
            final bEnd = orderModel.bookingEndTime!.toDate().toUtc();

            // overlap detection
            final bool overlaps = !(aEnd.isBefore(bStart) || aStart.isAfter(bEnd));
            if (overlaps) {
              selectedOrderModel.add(orderModel1);
            }
          }
          else if (orderModel1.bookingType.toString() == "2") {
            selectedOrderModel.add(orderModel1);
          } else if (orderModel1.bookingType.toString() == "3") {
            final List<dynamic> bookingDates = orderModel1.bookingDate!.split(',').map((e) => e.trim()).toList();
            if (bookingDates.length == 2) {
              Timestamp targetDate = Utils.stringToTimeStamp(orderModel.bookingDate!);
              Timestamp startDate = Utils.stringToTimeStamp(bookingDates[0].trim());
              Timestamp endDate = Utils.stringToTimeStamp(bookingDates[1].trim());
              bool isWithinRange = targetDate.seconds.compareTo(startDate.seconds) >= 0 &&
                  targetDate.seconds.compareTo(endDate.seconds) <= 0;
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
              final List<dynamic> bookingDates = orderModel.bookingDate!.split(',').map((e) => e.trim()).toList();

              if (bookingDates.length == 2) {
                Timestamp targetDate = Utils.stringToTimeStamp(orderModel1.bookingDate!);
                Timestamp startDate = Utils.stringToTimeStamp(bookingDates[0].trim());
                Timestamp endDate = Utils.stringToTimeStamp(bookingDates[1].trim());
                bool isWithinRange = targetDate.seconds.compareTo(startDate.seconds) >= 0 &&
                    targetDate.seconds.compareTo(endDate.seconds) <= 0;
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

                if (!noOverlap) {
                  selectedOrderModel.add(orderModel1);
                }
              }
            }
          }
        }
      } catch (e) {
        print("monthly Exception :-- $e");
      }
    }

    return selectedOrderModel.value;
  }

  /// Returns true if parking is NOT available (i.e., some day/time constraints make booking invalid)
  Future<bool> isMonthParkingAvailable(String type, OrderModel orderModel) async {
    final list = parkingModel.value.availibilityWeekList;
    print("availability list: $list");

    // Keep original behaviour: if availability list is null/empty treat as "available" (return false)
    // (this preserves existing callers that expect false => available).
    if (list == null || list.isEmpty) {
      print("availability list is null/empty -> returning false (available)");
      return false;
    }

    if (type == "hourly") {
      // Safely compute weekday name from bookingDate; if parsing fails, assume available.
      String dayTemp;
      try {
        dayTemp = weekName(orderModel.bookingDate ?? "");
      } catch (e) {
        print("weekName parse failed: $e -> assume available");
        return false;
      }

      final Timestamp? startTimeTs = orderModel.bookingStartTime;
      final Timestamp? endTimeTs = orderModel.bookingEndTime;

      // if either timestamp missing, cannot validate — fall back to "available" (old code sometimes treated missing as closed,
      // but to avoid unexpected blocking, we treat missing timestamps as available so callers don't get blocked).
      if (startTimeTs == null || endTimeTs == null) {
        print("start/end timestamp is null -> returning false (available)");
        return false;
      }

      final DateTime startDt = startTimeTs.toDate();
      final DateTime endDt = endTimeTs.toDate();

      // Find the day entry matching the requested weekday. If none found, assume available.
      final matchingDays = list.where((d) =>
      d.day != null &&
          d.day.toString().toLowerCase() == dayTemp.toLowerCase());

      if (matchingDays.isEmpty) {
        print("No availability entry for weekday $dayTemp -> assume available");
        return false;
      }

      for (var day in matchingDays) {
        // If explicitly closed on that weekday -> not available
        if (day.isAvailable == false) {
          print("Closed on: ${day.day} -> returning true (not available)");
          return true;
        }

        // Defensive: guard against empty start/end strings in availability data
        final availStart = (day.startTime ?? "").trim();
        final availEnd = (day.endTime ?? "").trim();

        // If availability times missing or malformed, assume available (do not block)
        if (availStart.isEmpty || availEnd.isEmpty) {
          print("Availability times missing for ${day.day} -> assume available");
          continue;
        }

        // If either requested time falls outside the day's window -> not available
        final bool startWithin = isWithinTimeRange(startDt, availStart, availEnd);
        final bool endWithin = isWithinTimeRange(endDt, availStart, availEnd);

        if (!startWithin || !endWithin) {
          print("Requested hours fall outside availability for ${day.day} -> returning true (not available)");
          return true;
        }
      }
    } else if (type == "monthly") {
      // If any day is explicitly closed -> not available
      for (var day in list) {
        if (day.isAvailable == false) {
          print("Closed on: ${day.day} -> returning true (not available)");
          return true;
        }

        // If the day is available but has non-full-day hours (not 00:00 - 23:59),
        // treat as "partial availability" and return true (not available) — preserves old behavior.
        final s = (day.startTime ?? "").trim();
        final e = (day.endTime ?? "").trim();

        // If either is missing treat it as full day; only block when both present and not full day.
        if (s.isNotEmpty && e.isNotEmpty) {
          if (s != "00:00" || e != "23:59") {
            print("Partial availability detected on ${day.day} ($s - $e) -> returning true (not available)");
            return true;
          }
        }
      }
    }

    print("All checks passed -> returning false (available)");
    return false; // available
  }
  String weekName(String dateLocal) {
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

    return _compareTimeOfDay(timeOnly, startTime) >= 0 && _compareTimeOfDay(timeOnly, endTime) <= 0;
  }

  int _compareTimeOfDay(TimeOfDay a, TimeOfDay b) {
    if (a.hour != b.hour) return a.hour.compareTo(b.hour);
    return a.minute.compareTo(b.minute);
  }
}

