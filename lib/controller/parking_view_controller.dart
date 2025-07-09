import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:phista/constant/constant.dart';
import 'package:phista/model/order_model.dart';
import 'package:phista/model/parking_model.dart';
import 'package:phista/utils/fire_store_utils.dart';
import 'package:phista/utils/utils.dart';

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
    await FireStoreUtils.getParkingDetails(parkingId).then((value) {
      if (value != null) {
        parkingModel.value = value;
      }
    });
    isLoading.value = false;
  }

  RxList<OrderModel> selectedOrderModel = <OrderModel>[].obs;

  getBookedParking(String type) async {
    if (type == "hourly") {
      log("myTime ===>${Utils.stringToTimeStamp(orderModel.value.bookingDate!).toDate()} \n==>StartTime ${orderModel.value.bookingStartTime!.toDate()} \n==>endTime ${orderModel.value.bookingEndTime!.toDate()}");
      await FireStoreUtils.getOrder(
              Utils.stringToTimeStamp(orderModel.value.bookingDate!),
              orderModel.value.bookingStartTime!,
              orderModel.value.bookingEndTime!,
              orderModel.value.parkingId.toString(),
              type)
          .then((value) {
        if (value != null) {
          for (var element in value) {
            OrderModel orderModel1 = element;

            if (orderModel1.bookingType.toString() == "1") {
              if (orderModel1.bookingStartTime!
                      .toDate()
                      .isBefore(orderModel.value.bookingStartTime!.toDate()) &&
                  orderModel1.bookingEndTime!
                      .toDate()
                      .isAfter(orderModel.value.bookingStartTime!.toDate())) {
                log("parking ===>${orderModel1.parkingSlotId}");
                selectedOrderModel.add(orderModel1);
              } else if (orderModel.value.bookingStartTime!
                  .toDate()
                  .isAtSameMomentAs(orderModel1.bookingStartTime!.toDate())) {
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
                Timestamp targetDate =
                    Utils.stringToTimeStamp(orderModel.value.bookingDate!);
                Timestamp startDate =
                    Utils.stringToTimeStamp(bookingDates[0].trim());
                Timestamp endDate =
                    Utils.stringToTimeStamp(bookingDates[1].trim());
                bool isWithinRange =
                    targetDate.seconds.compareTo(startDate.seconds) >= 0 &&
                        targetDate.seconds.compareTo(endDate.seconds) <= 0;
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
                  Timestamp targetDate =
                      Utils.stringToTimeStamp(orderModel1.bookingDate!);
                  Timestamp startDate =
                      Utils.stringToTimeStamp(bookingDates[0].trim());
                  Timestamp endDate =
                      Utils.stringToTimeStamp(bookingDates[1].trim());
                  bool isWithinRange =
                      targetDate.seconds.compareTo(startDate.seconds) >= 0 &&
                          targetDate.seconds.compareTo(endDate.seconds) <= 0;
                  print("isWithinRange :-- $isWithinRange");
                  if (isWithinRange) {
                    selectedOrderModel.add(orderModel1);
                  }
                }
              } else if (orderModel1.bookingType.toString() == "3") {
                String bookingDateFromFirebase = orderModel1.bookingDate!;
                String rangeDate = orderModel.value.bookingDate!;
                List<String> bookingParts = bookingDateFromFirebase.split(',');
                List<String> rangeParts = rangeDate.split(',');
                if (bookingParts.length == 2 && rangeParts.length == 2) {
                  DateTime bookingStart =
                      Utils.stringToTimeStamp(bookingParts[0].trim()).toDate();
                  DateTime bookingEnd =
                      Utils.stringToTimeStamp(bookingParts[1].trim()).toDate();
                  DateTime rangeStart =
                      Utils.stringToTimeStamp(rangeParts[0].trim()).toDate();
                  DateTime rangeEnd =
                      Utils.stringToTimeStamp(rangeParts[1].trim()).toDate();
                  bool noOverlap = bookingEnd.isBefore(rangeStart) ||
                      bookingStart.isAfter(rangeEnd);

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
            }
          }
        });
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
}
