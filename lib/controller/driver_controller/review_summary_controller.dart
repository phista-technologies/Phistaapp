import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:phista/constant/constant.dart';
import 'package:phista/model/coupon_model.dart';
import 'package:phista/model/order_model.dart';

import '../../constant/send_notification.dart';
import '../../constant/show_toast_dialog.dart';
import '../../env.dart';
import '../../model/user_model.dart';
import '../../ui/driver/my_booking/parking_ticket_screen.dart';
import '../../utils/fire_store_utils.dart';
import '../../utils/utils.dart';

class ReviewSummaryController extends GetxController {
  Rx<TextEditingController> couponCodeTextFieldController = TextEditingController().obs;

  @override
  void onInit() {
    super.onInit();
    print("Constant.bookingTypeConst:--> ${Constant.bookingTypeConst}");
    getArgument();
  }

  Rx<OrderModel> orderModel = OrderModel().obs;
  Rx<UserModel> ownerUserModel = UserModel().obs;
  var orderModelDailyList = <OrderModel>[].obs;
  RxDouble couponAmount = 0.0.obs;
  Rx<CouponModel> selectedCouponModel = CouponModel().obs;
  String bookingTypeReview = "";
  var vehicleDriverName = "".obs;
  var vehicleDriverNumber = "".obs;

  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      bookingTypeReview = Constant.bookingTypeConst;
        orderModel.value = argumentData['orderModel'];
        if (orderModel.value.coupon != null) {
          if (orderModel.value.coupon!.id != null) {
            if (orderModel.value.coupon!.type == "fix") {
              couponAmount.value = double.parse(orderModel.value.coupon!.amount.toString());
            } else {
              couponAmount.value = double.parse(orderModel.value.subTotal.toString()) * double.parse(orderModel.value.coupon!.amount.toString()) / 100;
            }
          }
        }
      getUserDetail();
      getParkingDetail(orderModel.value.parkingId??"");




    }
    update();
  }

  double calculateAmount() {

    if (orderModel.value.coupon != null) {
      if (orderModel.value.coupon!.id != null) {
        if (orderModel.value.coupon!.type == "fix") {
          couponAmount.value = double.parse(orderModel.value.coupon!.amount.toString());
        } else {
          couponAmount.value = double.parse(orderModel.value.subTotal.toString()) * double.parse(orderModel.value.coupon!.amount.toString()) / 100;
        }
      }
    }
    RxString taxAmount = "0.0".obs;
    if (orderModel.value.taxList != null) {
      for (var element in orderModel.value.taxList!) {
        taxAmount.value = (double.parse(taxAmount.value) +
                Constant().calculateTax(amount: (double.parse(orderModel.value.subTotal.toString()) - double.parse(couponAmount.toString())).toString(), taxModel: element))
            .toStringAsFixed(Constant.currencyModel!.decimalDigits!);
      }
    }
    print("couponAmount:--$couponAmount");
    if (couponAmount.value >= double.parse(orderModel.value.subTotal.toString())){
      return 0.0;
    }else{
      return (double.parse(orderModel.value.subTotal.toString()) - double.parse(couponAmount.toString())) + double.parse(taxAmount.value);
    }

  }

  getUserDetail() async{
    await FireStoreUtils.getUserProfile(orderModel.value.userVehicle!.userId.toString()).then((value) {
      print("value:-->$value");
      if (value != null) {
        vehicleDriverName.value = value.fullName.toString() ?? "";
        if ((value.phoneNumber ?? "").isNotEmpty) {
          vehicleDriverNumber.value = value.phoneNumber.toString();
        }
      }
    });
    print(vehicleDriverName.value);
    print(vehicleDriverNumber.value);
  }

  void getParkingDetail(String parkingId)async{
    try{
      ShowToastDialog.showLoader("");
      await FireStoreUtils.getParkingDetails(parkingId).then((parkingDetail) async{
        await FireStoreUtils.getUserProfile(parkingDetail?.userId??"").then((userDetail) {
          ShowToastDialog.closeLoader();
          if(userDetail != null) {
            ownerUserModel.value = userDetail;
          }
        },);
      },);
    }catch(e){
      ShowToastDialog.closeLoader();
    }

  }

  List<String> sortDateStrings(List<String> dateStrings) {
    DateFormat format = DateFormat("d MMMM yyyy 'at' HH:mm:ss 'UTC+5:30'");

    dateStrings.sort((a, b) {
      // Remove the "date " prefix before parsing
      String cleanA = a.replaceFirst('date ', '');
      String cleanB = b.replaceFirst('date ', '');
      DateTime dateA = format.parse(cleanA);
      DateTime dateB = format.parse(cleanB);
      return dateA.compareTo(dateB);
    });

    return dateStrings;
  }

  completeOrder() async {
    ShowToastDialog.showLoader("Please wait..");
    int numberOfDays= await getDifferenceBetweenStartAndEndDate(orderModel.value.bookingDate??"");
    UserModel? receiverUserModel = await FireStoreUtils.getUserProfile(
        orderModel.value.parkingDetails!.userId.toString());
    orderModel.value.paymentCompleted = true;
    orderModel.value.adminCommission =  Constant.adminCommission;
    orderModel.value.createdAt = Timestamp.now();
    orderModel.value.updateAt = Timestamp.now();

    await FireStoreUtils.getMyParkingList(
        orderModel.value.parkingDetails!.userId.toString())
        .then((value) async {
      if (value != null) {
        for (var element in value) {
          if (element.subscriptionTotalOrders != null &&
              element.subscriptionTotalOrders != "0.0" &&
              element.subscriptionTotalOrders != "0") {
            element.subscriptionTotalOrders = (int.parse(element.subscriptionTotalOrders.toString()) - 1).toString();
            await FireStoreUtils.saveParkingDetails(element);
          }
        }
      }
    });

    Map<String, dynamic> playLoad = <String, dynamic>{
      "type": "order",
      "orderId": orderModel.value.id
    };
    if (receiverUserModel != null) {
      await SendNotification.sendOneNotification(
          token: receiverUserModel.fcmToken.toString(),
          title: 'Booking Placed',
          body:
          '${orderModel.value.parkingDetails!.name
              .toString()} Booking placed on ${Constant.timestampToDate(
              Utils.stringToTimeStamp(orderModel.value.bookingDate!))}.',
          payload: playLoad);
    }

    await FireStoreUtils.getWatchman(
        orderModel.value.parkingDetails!.id.toString(),
        orderModel.value.parkingDetails!.userId.toString())
        .then((value) async {
      if (value != null) {
        await SendNotification.sendOneNotification(
            token: value.fcmToken.toString(),
            title: 'Booking Placed',
            body:
            '${orderModel.value.parkingDetails!.name
                .toString()} Booking placed on ${Constant.timestampToDate(
                Utils.stringToTimeStamp(orderModel.value.bookingDate!))}.',
            payload: playLoad);
      }
    });

    if(orderModel.value.bookingType.toString() == "3"){
      await Utils.sendRemainderEmailWithTemplateWithAllPlateForm(toEmail: Constant.currentUserModel.value?.email??"",
          templateId: ENV.templateIdRemainder, dynamicTemplateData: {},numberOfDays: numberOfDays);
      await Utils.sendRemainderEmailWithTemplateWithAllPlateForm(toEmail: Constant.currentUserModel.value?.email??"",
          templateId: ENV.templateIdRemainder, dynamicTemplateData: {},numberOfDays: numberOfDays-3);

      await Utils.sendRemainderEmailWithTemplateWithAllPlateForm(toEmail: Constant.currentUserModel.value?.email??"",
          templateId: ENV.templateIdRemainder, dynamicTemplateData: {},mintSend:10);

    }

    await FireStoreUtils.setOrder(orderModel.value).then((value) async {
      if (value == true) {
        //Constant.bookingTypeConst = "hourly";
        try{
          Map<String,dynamic> senMap = {
            "hostFullName":ownerUserModel.value.fullName,
            "address":orderModel.value.parkingDetails?.address??"",
            "clientFullName" :Constant.currentUserModel.value?.fullName,
            "vehicleLicensePlate" :orderModel.value.userVehicle?.vehicleNumber??""
          };

          print("senMap :- $senMap");

          await  Utils.sendEmailWithTemplateWithAllPlatForms(toEmail: ownerUserModel.value.email??"",
              templateId: ENV.templateIdNewReservation,
              dynamicTemplateData: senMap).then((value) {
            print("Sending Booking Template");
            ShowToastDialog.closeLoader();
          },);
        }catch(e){
          ShowToastDialog.closeLoader();
          log("Exception :-- ",error: e.toString());
        }

        Get.to(() => const ParkingTicketScreen(),
            arguments: {"orderModel": orderModel.value});
      }
    });

  }


  Future<int> getDifferenceBetweenStartAndEndDate(String bookingDateString) async {
    int daysBetween = 0;
    try{
      List<String> parts = bookingDateString.split(",");
      String startString = parts[0];
      String endString = parts[1];

      DateTime startDate = DateTime.parse(
          startString.replaceAll(" at ", " ").replaceAll("UTC", "+"));
      DateTime endDate = DateTime.parse(
          endString.replaceAll(" at ", " ").replaceAll("UTC", "+"));
      daysBetween = endDate.difference(startDate).inDays;
      print("Days between: $daysBetween");
    }catch(e){
      log("DifferenceBetweenStart Exception :- ",error:  e.toString());
    }
    return daysBetween;
  }


}
