import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:phista/constant/constant.dart';
import 'package:phista/model/order_model.dart';
import 'package:phista/model/wallet_transaction_model.dart';
import 'package:phista/utils/fire_store_utils.dart';

import '../../constant/send_notification.dart';
import '../../constant/show_toast_dialog.dart';
import '../../model/user_model.dart';
import '../../themes/custom_dialog_box.dart';
import '../../ui/driver/dashboard_screen.dart';
import '../../utils/utils.dart';
import 'dashboard_controller.dart';

class ParkingTicketController extends GetxController {
  @override
  void onInit() {
    // TODO: implement onInit
    getArgument();
    super.onInit();
  }

  Rx<OrderModel> orderModel = OrderModel().obs;
  RxBool isLoading = true.obs;

  RxDouble couponAmount = 0.0.obs;

  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      orderModel.value = argumentData['orderModel'];
    }
    isLoading.value = false;
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
                Constant().calculateTax(amount: (double.parse(orderModel.value.subTotal.toString()) - couponAmount.value).toString(), taxModel: element))
            .toStringAsFixed(Constant.currencyModel!.decimalDigits!);
      }
    }
    return (double.parse(orderModel.value.subTotal.toString()) - couponAmount.value) + double.parse(taxAmount.value);
  }

  canceledOrderWallet() async {
    WalletTransactionModel transactionModel = WalletTransactionModel(
        id: Constant.getUuid(),
        amount: calculateAmount().toString(),
        createdDate: Timestamp.now(),
        paymentType: "Wallet",
        transactionId: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: FireStoreUtils.getCurrentUid(),
        isCredit: true,
        note: "Refund Amount");

    await FireStoreUtils.setWalletTransaction(transactionModel).then((value) async {
      if (value == true) {
        await FireStoreUtils.updateUserWallet(amount: calculateAmount().toString());
      }
    });

    WalletTransactionModel transactionParkingModel = WalletTransactionModel(
        id: Constant.getUuid(),
        amount: "-${calculateAmount().toString()}",
        createdDate: Timestamp.now(),
        paymentType: "Wallet",
        transactionId: orderModel.value.id,
        isCredit: false,
        userId: orderModel.value.parkingDetails!.userId.toString(),
        note: "Parking amount revers");

    await FireStoreUtils.setWalletTransaction(transactionParkingModel).then((value) async {
      if (value == true) {
        await FireStoreUtils.updateOtherUserWallet(amount: "-${calculateAmount().toString()}", id: orderModel.value.parkingDetails!.userId.toString());
      }
    });

    WalletTransactionModel adminCommissionWallet = WalletTransactionModel(
        id: Constant.getUuid(),
        amount:
            "${Constant.calculateAdminCommission(amount: (double.parse(orderModel.value.subTotal.toString()) - double.parse(couponAmount.toString())).toString(), adminCommissionLocal: orderModel.value.adminCommission)}",
        createdDate: Timestamp.now(),
        paymentType: "Wallet",
        transactionId: orderModel.value.id,
        isCredit: true,
        userId: orderModel.value.parkingDetails!.userId.toString(),
        note: "Admin commission revers");

    await FireStoreUtils.setWalletTransaction(adminCommissionWallet).then((value) async {
      if (value == true) {
        await FireStoreUtils.updateOtherUserWallet(
            amount:
                "${Constant.calculateAdminCommission(amount: (double.parse(orderModel.value.subTotal.toString()) - double.parse(couponAmount.toString())).toString(), adminCommissionLocal: orderModel.value.adminCommission)}",
            id: orderModel.value.parkingDetails!.userId.toString());
      }
    });
  }

  refundCashPaymentAmount() async {
    WalletTransactionModel adminCommissionWallet = WalletTransactionModel(
        id: Constant.getUuid(),
        amount:
            "${Constant.calculateAdminCommission(amount: (double.parse(orderModel.value.subTotal.toString()) - double.parse(couponAmount.toString())).toString(), adminCommissionLocal: orderModel.value.adminCommission)}",
        createdDate: Timestamp.now(),
        paymentType: "Wallet",
        transactionId: orderModel.value.id,
        isCredit: true,
        userId: orderModel.value.parkingDetails!.userId.toString(),
        note: "Admin commission revers");

    await FireStoreUtils.setWalletTransaction(adminCommissionWallet).then((value) async {
      if (value == true) {
        await FireStoreUtils.updateOtherUserWallet(
            amount:
                "${Constant.calculateAdminCommission(amount: (double.parse(orderModel.value.subTotal.toString()) - double.parse(couponAmount.toString())).toString(), adminCommissionLocal: orderModel.value.adminCommission)}",
            id: orderModel.value.parkingDetails!.userId.toString());
      }
    });
  }

  void cancelBooking()async{
    ShowToastDialog.showLoader(
        "Please wait".tr);
    print(orderModel.value.parkingDetails!.userId.toString());
    orderModel.value.status = Constant.canceled;

    UserModel? receiverUserModel = await FireStoreUtils.getUserProfile(orderModel.value.parkingDetails!.userId.toString());

    Map<String, dynamic> playLoad = <String, dynamic>{
      "type": "order",
      "orderId":
      orderModel.value.id
    };

    await SendNotification.sendOneNotification(
        token: receiverUserModel?.fcmToken
            .toString()??"",
        title: 'Booking Canceled'.tr,
        body:
        '${orderModel.value.parkingDetails!.name.toString()} Booking canceled on ${Constant.timestampToDate(Utils.stringToTimeStamp(orderModel.value.bookingDate!))}.'
            .tr,
        payload: playLoad);
    if (orderModel.value.paymentType
        .toString()
        .toLowerCase() !=
        'cash'.toLowerCase()) {
      await canceledOrderWallet();
    } else if (orderModel.value
        .paymentCompleted! &&
       orderModel.value.paymentType
            .toString()
            .toLowerCase() ==
            'cash'.toLowerCase()) {
      await refundCashPaymentAmount();
    }

    await FireStoreUtils.setOrder(
       orderModel.value)
        .then((value) {
      ShowToastDialog.closeLoader();
      DashboardScreenController
      dashboardController = Get.put(DashboardScreenController());
      dashboardController.selectedIndex(2);
      Constant.globalParkingModel.value = null;
      Get.offAll(() => const DashBoardScreen());

    });
  }


  bool canDeleteBookingHourly(Timestamp? timestamp) {
    DateTime bookingTime = timestamp!.toDate();
    DateTime deleteAllowedTime = bookingTime.add(Duration(minutes: 10));
    return DateTime.now().isAfter(deleteAllowedTime);
  }

  bool canDeleteBookingMonthly(String strDateTime){
    // Take only the first date from the string
    String dateStr = strDateTime.split(',').first.trim();

    DateTime startTime = parseCustomDateTime(dateStr);

    // User can cancel until 24 hours before start
    DateTime lastCancelTime = startTime.subtract(Duration(hours: 24));

    bool canCancel = DateTime.now().isBefore(lastCancelTime);

    print("Booking on $startTime → Can cancel? $canCancel");
    return canCancel;
  }

  /// Parse date like "5 September 2025 at 00:00:00 UTC+5:30"
  DateTime parseCustomDateTime(String input) {
    final parts = input.split(" UTC");

    final datePart = parts[0].trim(); // "5 September 2025 at 00:00:00"
    final offsetPart = parts.length > 1 ? parts[1].trim() : "+00:00"; // "+5:30"

    final dateFormat = DateFormat("d MMMM y 'at' HH:mm:ss");
    DateTime baseTime = dateFormat.parse(datePart, true).toUtc(); // UTC time

    final sign = offsetPart.startsWith('-') ? -1 : 1;
    final offsetClean = offsetPart.replaceAll(RegExp(r'[+-]'), '');
    final offsetParts = offsetClean.split(":");

    final offsetHours = int.parse(offsetParts[0]) * sign;
    final offsetMinutes = int.parse(offsetParts[1]) * sign;

    final totalOffset = Duration(hours: offsetHours, minutes: offsetMinutes);
    return baseTime.add(totalOffset); // return time adjusted to the correct UTC offset
  }

  void showPopUp(String title,String msg){
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

}
