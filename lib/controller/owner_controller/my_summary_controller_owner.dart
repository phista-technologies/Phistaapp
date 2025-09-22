import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constant/constant.dart';
import '../../constant/show_toast_dialog.dart';
import '../../model/order_model.dart';
import '../../model/review_model.dart';
import '../../model/user_model.dart';
import '../../model/wallet_transaction_model.dart';
import '../../utils/fire_store_utils.dart';


class MySummaryControllerOwner extends GetxController {
  Rx<TextEditingController> couponCodeTextFieldController = TextEditingController().obs;
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getArgument();
    super.onInit();
  }

  Rx<OrderModel> orderModel = OrderModel().obs;
  Rx<ReviewModel> reviewModel = ReviewModel().obs;
  Rx<UserModel> otherUserModel = UserModel().obs;
  var vehicleDriverName = "".obs;
  var vehicleDriverNumber = "".obs;
  var vehicleDriverRole = "".obs;
  RxDouble couponAmount = 0.0.obs;

  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
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
    }
    getReview();
    update();
  }

  getReview() async {
    await FireStoreUtils.getReview(orderModel.value.id.toString()).then((value) {
      if (value != null) {
        reviewModel.value = value;
      }
    });
    await FireStoreUtils.getUserProfile(reviewModel.value.customerId.toString()).then((value) {
      if (value != null) {
        otherUserModel.value = value;
      }
    });

    await FireStoreUtils.getUserProfile(orderModel.value.userVehicle!.userId.toString()).then((value) {
      print("value:-->$value");

      if (value != null) {
       vehicleDriverName.value = value.fullName.toString() ?? "";
       vehicleDriverRole.value = value.role.toString()?? "";
       if ((value.phoneNumber ?? "").isNotEmpty) {
         vehicleDriverNumber.value = value.phoneNumber.toString();
       }
      }
    });
    print(vehicleDriverName.value);
    print(vehicleDriverNumber.value);

    isLoading.value = false;
  }

  double calculateAmount() {
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

  confirmPayment() async {
    ShowToastDialog.showLoader("Please wait..");
    orderModel.value.paymentCompleted = true;

    if (Constant.adminCommission?.enable == true) {
      UserModel? userModel = await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid());
      orderModel.value.adminCommission = Constant.adminCommission;
    }
    WalletTransactionModel adminCommissionWallet = WalletTransactionModel(
        id: Constant.getUuid(),
        amount:
            "-${Constant.calculateAdminCommission(amount: (double.parse(orderModel.value.subTotal.toString()) - double.parse(couponAmount.toString())).toString(), adminCommissionLocal: orderModel.value.adminCommission)}",
        createdDate: Timestamp.now(),
        paymentType: orderModel.value.paymentType.toString(),
        transactionId: orderModel.value.id,
        isCredit: false,
        userId: orderModel.value.parkingDetails!.userId.toString(),
        note: "Admin commission debited");

    await FireStoreUtils.setWalletTransaction(adminCommissionWallet).then((value) async {
      if (value == true) {
        await FireStoreUtils.updateUserWallet(
          amount:
              "-${Constant.calculateAdminCommission(amount: (double.parse(orderModel.value.subTotal.toString()) - double.parse(couponAmount.toString())).toString(), adminCommissionLocal: orderModel.value.adminCommission)}",
        );
      }
    });

    await FireStoreUtils.setOrder(orderModel.value).then((value) {
      if (value == true) {
        ShowToastDialog.closeLoader();
        Get.back();
      }
    });
  }
}
