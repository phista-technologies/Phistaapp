import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:phista/constant/constant.dart';
import 'package:phista/model/order_model.dart';
import 'package:phista/model/parking_model.dart';
import 'package:phista/utils/fire_store_utils.dart';
import 'package:phista/utils/utils.dart';

import '../constant/collection_name.dart';
import '../themes/custom_dialog_box.dart';

class ParkingViewController extends GetxController {
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    getArgument();
    super.onInit();
  }

  RxString selectedParking = "".obs;
  Rx<OrderModel> orderModel = OrderModel().obs;

  Rx<ParkingModel> parkingModel = ParkingModel().obs;
  String bookingTypeTemp = "";
  RxBool isNotAvailableAnyDay = false.obs;

  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      bookingTypeTemp = Constant.bookingTypeConst;
      orderModel.value = argumentData['orderModel'];
      getParkingDetails(orderModel.value.parkingDetails!.id.toString());
      await getBookedParking(bookingTypeTemp);
    }
    update();
  }

  getParkingDetails(String parkingId) async {
    await FireStoreUtils.getParkingDetails(parkingId).then((value) async {
      if (value != null) {
        print("value:--->> ${value}");
        parkingModel.value = value;
        isNotAvailableAnyDay.value =  await isMonthParkingAvailable(bookingTypeTemp);

        print("availabilityList:--->> ${parkingModel.value.availibilityWeekList}");
      }
    });
    isLoading.value = false;
  }

  RxList<OrderModel> selectedOrderModel = <OrderModel>[].obs;

  getBookedParking(String type) async {
    if (type == "hourly") {
      log("myTime ===> ${Utils.stringToTimeStamp(orderModel.value.bookingDate!).toDate()} \n==>StartTime ${orderModel.value.bookingStartTime!.toDate()} \n==>endTime ${orderModel.value.bookingEndTime!.toDate()}");
      await FireStoreUtils.getOrder(
              Utils.stringToTimeStamp(orderModel.value.bookingDate!),
              orderModel.value.bookingStartTime!,
              orderModel.value.bookingEndTime!,
              orderModel.value.parkingId.toString(),
              type)
          .then((value) {
        print("value:---$value");
        if (value != null) {
          for (var element in value) {
            OrderModel orderModel1 = element;

            if (orderModel1.bookingType.toString() == "1") {
              if (orderModel1.bookingStartTime!.toDate()
                      .isBefore(orderModel.value.bookingStartTime!.toDate()) &&

                  orderModel1.bookingEndTime!
                      .toDate()
                      .isAfter(orderModel.value.bookingStartTime!.toDate())) {
                log("parking ===>${orderModel1.parkingSlotId}");
                selectedOrderModel.add(orderModel1);
              } else if (orderModel.value.bookingStartTime!.toDate().isAtSameMomentAs(orderModel1.bookingStartTime!.toDate())) {
                selectedOrderModel.add(orderModel1);
                log("parking ===>4 ${orderModel1.parkingSlotId}");
              } else if (orderModel.value.bookingStartTime!
                  .toDate()
                  .isBefore(orderModel1.bookingStartTime!.toDate())) {
                if (orderModel.value.bookingEndTime!
                    .toDate()
                    .isAfter(orderModel1.bookingEndTime!.toDate())) {
                  selectedOrderModel.add(orderModel1);
                  log("parking ===>2 ${orderModel1.parkingSlotId}");
                } else if (orderModel.value.bookingEndTime!
                    .toDate()
                    .isAtSameMomentAs(orderModel1.bookingEndTime!.toDate())) {
                  selectedOrderModel.add(orderModel1);
                  log("parking ===>2 ${orderModel1.parkingSlotId}");
                } else if (orderModel.value.bookingEndTime!
                        .toDate()
                        .isBefore(orderModel1.bookingEndTime!.toDate()) &&
                    orderModel.value.bookingEndTime!
                        .toDate()
                        .isAfter(orderModel1.bookingStartTime!.toDate())) {
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
              final List<dynamic> bookingDates = orderModel1.bookingDate!
                  .split(',')
                  .map((e) => e.trim())
                  .toList();
              if (bookingDates.length == 2) {
                Timestamp targetDate = Utils.stringToTimeStamp(orderModel.value.bookingDate!);
                Timestamp startDate = Utils.stringToTimeStamp(bookingDates[0].trim());
                Timestamp endDate = Utils.stringToTimeStamp(bookingDates[1].trim());
                bool isWithinRange = targetDate.seconds.compareTo(startDate.seconds) >= 0 && targetDate.seconds.compareTo(endDate.seconds) <= 0;
                print("isWithinRange hourly:-- $isWithinRange");
                if (isWithinRange) {
                  selectedOrderModel.add(orderModel1);
                }
              }
            }
          }
        }
      });
    }
    else if (type == "monthly") {
      try {
        if (!isNotAvailableAnyDay.value){
          FireStoreUtils.getOrder(
              Utils.stringToTimeStamp(
                  orderModel.value.bookingDate!), // not use
              orderModel.value.bookingStartTime!,
              orderModel.value.bookingEndTime!,
              orderModel.value.parkingId.toString(),
              type)
              .then((value) {
            if (value != null) {
              for (var element in value) {
                OrderModel orderModel1 = element;
                if (orderModel1.bookingType.toString() == "1") {
                  final List<dynamic> bookingDates = orderModel.value.bookingDate!
                      .split(',')
                      .map((e) => e.trim())
                      .toList();

                  if (bookingDates.length == 2) {
                    Timestamp targetDate = Utils.stringToTimeStamp(orderModel1.bookingDate!);
                    Timestamp startDate = Utils.stringToTimeStamp(bookingDates[0].trim());
                    Timestamp endDate = Utils.stringToTimeStamp(bookingDates[1].trim());
                    bool isWithinRange = targetDate.seconds.compareTo(startDate.seconds) >= 0 && targetDate.seconds.compareTo(endDate.seconds) <= 0;
                    print("isWithinRange :-- $isWithinRange");
                    if (isWithinRange) {
                      selectedOrderModel.add(orderModel1);
                    }
                  }
                }
                else if (orderModel1.bookingType.toString() == "3") {
                  String bookingDateFromFirebase = orderModel1.bookingDate!;
                  String rangeDate = orderModel.value.bookingDate!;
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
          });
        }
      } catch (e) {
        print("monthly Exception :-- $e");
      }
    }
    /* else if(type == "daily" && orderModel.value != null){

      final List<dynamic> bookingDates = orderModel.value.bookingDate!.split(',').map((e) => e.trim()).toList();

      for(var dailyValue in bookingDates){
        await FireStoreUtils.getOrder(
            Utils.stringToTimeStamp(dailyValue),
            orderModel.value.bookingStartTime!,
            orderModel.value.bookingEndTime!,
            orderModel.value.parkingId.toString())
            .then((value) {
          if (value != null) {
            for (var element in value) {
              OrderModel orderModel1 = element;
              selectedOrderModel.add(orderModel1);
            }
          }
        });
      }
    }*/

  }

  Future<bool>isMonthParkingAvailable(String type) async {
    final list = parkingModel.value.availibilityWeekList;
    print("$list");
    // Treat null or empty as fully closed
    if (list == null || list.isEmpty) {
      print("return--null");
      return false;
    }

    if (type == "hourly"){
      var dayTemp = weekName(orderModel.value.bookingDate??"");
      Timestamp?  startTime = orderModel.value.bookingStartTime;
      Timestamp? endTime = orderModel.value.bookingEndTime;



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
