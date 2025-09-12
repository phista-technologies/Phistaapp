import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:phista/constant/constant.dart';
import 'package:phista/model/coupon_model.dart';
import 'package:phista/model/order_model.dart';

import '../utils/fire_store_utils.dart';

class ReviewSummaryController extends GetxController {
  Rx<TextEditingController> couponCodeTextFieldController = TextEditingController().obs;

  @override
  void onInit() {
    super.onInit();
    print("Constant.bookingTypeConst:--> ${Constant.bookingTypeConst}");
    getArgument();
  }

  Rx<OrderModel> orderModel = OrderModel().obs;
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
    return (double.parse(orderModel.value.subTotal.toString()) - double.parse(couponAmount.toString())) + double.parse(taxAmount.value);
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


}
