import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as maths;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_paypal/flutter_paypal.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as STRIPE;
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:phista/constant/constant.dart';
import 'package:phista/constant/send_notification.dart';
import 'package:phista/constant/show_toast_dialog.dart';
import 'package:phista/model/order_model.dart';
import 'package:phista/model/parking_model.dart';
import 'package:phista/model/payment/xenditModel.dart';
import 'package:phista/model/payment_method_model.dart';
import 'package:phista/model/user_model.dart';
import 'package:phista/model/wallet_transaction_model.dart';
import 'package:phista/payment/MercadoPagoScreen.dart';
import 'package:phista/payment/PayFastScreen.dart';
import 'package:phista/payment/getPaytmTxtToken.dart';
import 'package:phista/payment/midtrans_screen.dart';
import 'package:phista/payment/orangePayScreen.dart';
import 'package:phista/payment/paystack/pay_stack_screen.dart';
import 'package:phista/payment/paystack/pay_stack_url_model.dart';
import 'package:phista/payment/paystack/paystack_url_genrater.dart';
import 'package:phista/payment/stripe_failed_model.dart';
import 'package:phista/payment/xenditScreen.dart';
import 'package:phista/themes/app_them_data.dart';
import 'package:phista/utils/fire_store_utils.dart';
import 'package:phista/utils/pdf_%20generater.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../env.dart';
import '../../model/tax_model.dart';
import '../../ui/driver/my_booking/parking_ticket_screen.dart';
import '../../utils/utils.dart';
import '../../utils/web_stripe_checkout_screen.dart';
import '../../utils/web_stripe_checkout_screen_stub.dart'
if (dart.library.html) '../../utils/web_stripe_checkout_screen.dart';


class PaymentSelectController extends GetxController {
  Rx<PaymentModel> paymentModel = PaymentModel().obs;
  RxString selectedPaymentMethod = "".obs;
  RxBool isLoading = false.obs;
  RxBool isFromApple = false.obs;
  RxBool isFromGoogle = false.obs;

  Rx<OrderModel> orderModel = OrderModel().obs;

  Rx<UserModel> userModel = UserModel().obs;
  String bookingTypePayment = "";
  String APPLE_PAY = "Apple Pay";
  String GOOGLE_PAY = "Google Pay";
  Rx<ParkingModel> parkingDetail = ParkingModel().obs;
  Rx<UserModel> ownerUserModel = UserModel().obs;
  File? invoicePdf;
  String couponAmountReview = "";
  String totalAmountReview = "";
  List<TaxModel>? taxList = [];

  @override
  void onInit() {
    //_checkStripeStatus();
    log("payment select controller");
    _checkStripeStatus();
    getArgument();
    super.onInit();
    getParkingDetail(orderModel.value.parkingId??"");
    createdPdf();
  }


  void createdPdf()async{

     await sendPdfByEmail(orderModel.value.parkingDetails?.name??"",
        orderModel.value.parkingDetails?.address??"",
        orderModel.value.parkingSlotId??"",
        orderModel.value.userVehicle?.vehicleModel?.name??"",
        orderModel.value.duration.toString(),
         Constant.amountShow(amount: orderModel.value.subTotal.toString()),
         Constant.amountShow(amount: couponAmountReview),
         Constant.amountShow(amount: totalAmountReview),
       taxList
     ).then((value) async {
       invoicePdf =value;
      print("invoice send :-- $invoicePdf" );
       // Preview the saved file
       //await Printing.layoutPdf(onLayout: (_) => invoicePdf!.readAsBytes());

    },);
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

  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      bookingTypePayment = Constant.bookingTypeConst;
      orderModel.value = argumentData['orderModel'];
      couponAmountReview = argumentData['couponAmount'];
      totalAmountReview = argumentData['totalAmount'];
      print("totalAmountReview:--$totalAmountReview");
      taxList = argumentData['taxList'];

    }
    await getPaymentData();
    update();
  }

  getPaymentData() async {
    log("walletAmount1:-->  ${userModel.value.walletAmount}");
    log("Current UID: ${FireStoreUtils.getCurrentUid()}");
    await FireStoreUtils().getPayment().then((value) {
      log("get payment value :-- $value");
      if (value != null) {
        paymentModel.value = value;
        if (paymentModel.value.strip?.enable == true) {
          STRIPE.Stripe.publishableKey = paymentModel.value.strip!.clientpublishableKey.toString();//ENV.pkTestPublishableKey;
          STRIPE.Stripe.merchantIdentifier = "merchant.com.phista.ios";
          STRIPE.Stripe.instance.applySettings();
        }
        setRef();
        selectedPaymentMethod.value = orderModel.value.paymentType.toString();
        if (!kIsWeb) {
          razorPay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccess);
          razorPay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWaller);
          razorPay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentError);
        }

      }
      isLoading.value = true;
    });
    log("Current UID1: ${FireStoreUtils.getCurrentUid()}");

    await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid())
        .then((value) {
      if (value != null) {
        userModel.value = value;
        log("walletAmount2:-->${userModel.value.walletAmount}");
      }
    });

    isLoading.value = false;
    update();
  }

  RxDouble couponAmount = 0.0.obs;

  /*double calculateAmount() {
    if (orderModel.value.coupon != null) {
      if (orderModel.value.coupon!.id != null) {
        if (orderModel.value.coupon!.type == "fix") {
          couponAmount.value = double.parse(orderModel.value.coupon!.amount.toString());
        } else {
          couponAmount.value = double.parse(orderModel.value.subTotal.toString()) *
                  double.parse(orderModel.value.coupon!.amount.toString()) /
                  100;
        }
      }
    }
    RxString taxAmount = "0.0".obs;
    if (orderModel.value.taxList != null) {
      for (var element in orderModel.value.taxList!) {
        taxAmount.value = (double.parse(taxAmount.value) +
                Constant().calculateTax(
                    amount:
                        (double.parse(orderModel.value.subTotal.toString()) -
                                double.parse(couponAmount.toString()))
                            .toString(),
                    taxModel: element))
            .toStringAsFixed(Constant.currencyModel!.decimalDigits!);
      }
    }
    if (couponAmount.value >= double.parse(orderModel.value.subTotal.toString())){
      return double.parse(totalAmountReview);
    }else{
      return (double.parse(orderModel.value.subTotal.toString()) -
          double.parse(couponAmount.toString())) +
          double.parse(taxAmount.value);
    }

  }*/

  double calculateAmount() {
    double subTotal = double.parse(orderModel.value.subTotal.toString());
    double coupon = 0.0;

    // ---------------- COUPON ----------------
    if (orderModel.value.coupon != null &&
        orderModel.value.coupon!.id != null) {

      bool validParking =
          orderModel.value.coupon!.parkingId == null ||
              orderModel.value.coupon!.parkingId == "" ||
              orderModel.value.coupon!.parkingId == orderModel.value.parkingId;

      if (validParking) {
        if (orderModel.value.coupon!.type == "fix") {
          coupon = double.parse(orderModel.value.coupon!.amount.toString());
        } else {
          coupon = subTotal *
              double.parse(orderModel.value.coupon!.amount.toString()) /
              100;
        }
      } else {
        orderModel.value.coupon = null;
      }
    }

    // Coupon cannot exceed subtotal
    couponAmount.value = coupon > subTotal ? subTotal : coupon;

    // ---------------- TAX ----------------
    double tax = 0.0;
    if (orderModel.value.taxList != null) {
      for (var element in orderModel.value.taxList!) {
        tax += Constant().calculateTax(
          amount: (subTotal - couponAmount.value).toString(),
          taxModel: element,
        );
      }
    }

    double currentTotal = (subTotal - couponAmount.value) + tax;

    // Edge case: free booking
    if (currentTotal <= 0) {
      return 0.0;
    }

    // ---------------- PROCESSING / SERVICE FEE ----------------
    // Platform fee = 4%
    // currentTotal = 96%
    // finalTotal = currentTotal / 0.96
    double finalTotal = currentTotal / 0.96;

    return double.parse(
      finalTotal.toStringAsFixed(
        Constant.currencyModel!.decimalDigits!,
      ),
    );
  }



  completeCashOrder() async {
    ShowToastDialog.showLoader("Please wait..");
    log("Cash Pay :: ${orderModel.value.parkingDetails!.userId.toString()}");
    UserModel? receiverUserModel = await FireStoreUtils.getUserProfile(
        orderModel.value.parkingDetails!.userId.toString());
    orderModel.value.paymentCompleted = false;
    orderModel.value.paymentType = selectedPaymentMethod.value;

   // orderModel.value.adminCommission = receiverUserModel?.adminCommission ?? Constant.adminCommission;
    orderModel.value.adminCommission = Constant.adminCommission;
    orderModel.value.createdAt = Timestamp.now();
    orderModel.value.updateAt = Timestamp.now();

    // await FireStoreUtils.getFirestOrderOrNOt(orderModel.value)
    //     .then((value) async {
    //   if (value == true) {
    await FireStoreUtils.updateReferralAmount(orderModel.value);
    // }
    // });

    if (receiverUserModel != null) {
      if (receiverUserModel.subscriptionTotalOrders != null &&
          receiverUserModel.subscriptionTotalOrders != "0.0" &&
          receiverUserModel.subscriptionTotalOrders != "0") {
        receiverUserModel.subscriptionTotalOrders =
            (int.parse(receiverUserModel.subscriptionTotalOrders.toString()) -
                    1)
                .toString();
      }

      Map<String, dynamic> playLoad = <String, dynamic>{
        "type": "order",
        "orderId": orderModel.value.id
      };

      await SendNotification.sendOneNotification(
          token: receiverUserModel.fcmToken.toString(),
          title: 'Booking Placed',
          body:
              '${orderModel.value.parkingDetails!.name.toString()} Booking placed on ${Constant.timestampToDate(Utils.stringToTimeStamp(orderModel.value.bookingDate!))}.',
          payload: playLoad);

      await FireStoreUtils.getWatchman(
              orderModel.value.parkingDetails!.id.toString(),
              orderModel.value.parkingDetails!.userId.toString())
          .then((value) async {
        if (value != null) {
          await SendNotification.sendOneNotification(
              token: value.fcmToken.toString(),
              title: 'Booking Placed',
              body:
                  '${orderModel.value.parkingDetails!.name.toString()} Booking placed on ${Constant.timestampToDate(Utils.stringToTimeStamp(orderModel.value.bookingDate!))}.',
              payload: playLoad);
        }
      });
      await FireStoreUtils.updateUser(receiverUserModel);
    }
    await FireStoreUtils.getMyParkingList(
            orderModel.value.parkingDetails!.userId.toString())
        .then((value) async {
      if (value != null) {
        for (var element in value) {
          if (element.subscriptionTotalOrders != null &&
              element.subscriptionTotalOrders != "0.0" &&
              element.subscriptionTotalOrders != "0") {
            element.subscriptionTotalOrders =
                (int.parse(element.subscriptionTotalOrders.toString()) - 1)
                    .toString();
            FireStoreUtils.saveParkingDetails(element);
          }
        }
      }
    });
    await FireStoreUtils.setOrder(orderModel.value).then((value) {
      if (value == true) {
        ShowToastDialog.closeLoader();
        log("orderModel.value1 :-- ${orderModel.value}");
        Get.to(() => const ParkingTicketScreen(),
            arguments: {"orderModel": orderModel.value});
      }
    });
  }

  paypalPaymentSheet(String amount, context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => UsePaypal(
            sandboxMode:
                paymentModel.value.paypal!.isSandbox == true ? false : true,
            clientId: paymentModel.value.paypal!.paypalClient ?? '',
            secretKey: paymentModel.value.paypal!.paypalSecret ?? '',
            returnURL: "com.phista://paypalpay",
            cancelURL: "com.phista://paypalpay",
            transactions: [
              {
                "amount": {
                  "total": amount,
                  "currency": "USD",
                  "details": {"subtotal": amount}
                },
              }
            ],
            note: "Contact us for any questions on your order.",
            onSuccess: (Map params) async {
              completeOrder();
              ShowToastDialog.showToast("Payment Successful!!");
            },
            onError: (error) {
              Get.back();
              ShowToastDialog.showToast("Payment UnSuccessful!!");
            },
            onCancel: (params) {
              Get.back();
              ShowToastDialog.showToast("Payment UnSuccessful!!");
            }),
      ),
    );
  }

  double getOwnerWalletCreditAmount() {
    double subTotal = double.parse(orderModel.value.subTotal.toString());
    double coupon = couponAmount.value;

    double ownerAmount = subTotal - coupon;

    if (ownerAmount < 0) {
      ownerAmount = 0;
    }

    return double.parse(
      ownerAmount.toStringAsFixed(
        Constant.currencyModel!.decimalDigits!,
      ),
    );
  }


  completeOrder({int? index}) async {
    ShowToastDialog.showLoader("Please wait..");
    int numberOfDays= await getDifferenceBetweenStartAndEndDate(orderModel.value.bookingDate??"");
    log("Online Pay :: ${orderModel.value.parkingDetails!.userId.toString()}");
    UserModel? receiverUserModel = await FireStoreUtils.getUserProfile(
    orderModel.value.parkingDetails!.userId.toString());
    orderModel.value.paymentCompleted = true;
    orderModel.value.paymentType = selectedPaymentMethod.value;

   // orderModel.value.adminCommission = receiverUserModel?.adminCommission ?? Constant.adminCommission;
   orderModel.value.adminCommission =  Constant.adminCommission;
   orderModel.value.createdAt = Timestamp.now();
   orderModel.value.updateAt = Timestamp.now();
   double ownerCreditAmount = getOwnerWalletCreditAmount();
   WalletTransactionModel transactionModel = WalletTransactionModel(
        id: Constant.getUuid(),
        amount: ownerCreditAmount.toString(),//calculateAmount().toString(),
        createdDate: Timestamp.now(),
        paymentType: selectedPaymentMethod.value,
        transactionId: orderModel.value.id,
        isCredit: true,
        userId: orderModel.value.parkingDetails!.userId.toString(),
        note: "Parking amount credited");

    await FireStoreUtils.setWalletTransaction(transactionModel)
        .then((value) async {
      if (value == true) {
        await FireStoreUtils.updateOtherUserWallet(
            amount: ownerCreditAmount.toString(),//calculateAmount().toString(),
            id: orderModel.value.parkingDetails!.userId.toString());
      }
    });

    WalletTransactionModel adminCommissionWallet = WalletTransactionModel(
        id: Constant.getUuid(),
        amount: "-${Constant.calculateAdminCommission(
            amount: (double.parse(orderModel.value.subTotal.toString()) -
                double.parse(couponAmount.toString())).toString(),
            adminCommissionLocal: orderModel.value.adminCommission)}",
        createdDate: Timestamp.now(),
        paymentType: selectedPaymentMethod.value,
        transactionId: orderModel.value.id,
        isCredit: false,
        userId: orderModel.value.parkingDetails!.userId.toString(),
        note: "Admin commission debited");

    await FireStoreUtils.setWalletTransaction(adminCommissionWallet)
        .then((value) async {
      if (value == true) {
        await FireStoreUtils.updateOtherUserWallet(
            amount:
            "-${Constant.calculateAdminCommission(
                amount: (double.parse(orderModel.value.subTotal.toString()) -
                    double.parse(couponAmount.toString())).toString(),
                adminCommissionLocal: orderModel.value.adminCommission)}",
            id: orderModel.value.parkingDetails!.userId.toString());
      }
    });

    // await FireStoreUtils.getFirestOrderOrNOt(orderModel.value)
    //     .then((value) async {
    //   if (value == true) {
    await FireStoreUtils.updateReferralAmount(orderModel.value);
    // }
    // });

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

    log("invoicePdf :-- ",error: invoicePdf?.path);
    if(invoicePdf !=null){
      print("currentUserModel-Email ${Constant.currentUserModel.value?.email}");
      await Utils.sendEmailWithTemplateWithAllPlatForms(toEmail: Constant.currentUserModel.value?.email??"",
          templateId: ENV.templateIdSendBilling, dynamicTemplateData: {},attachmentFile: invoicePdf);
    }

    if(orderModel.value.bookingType.toString() == "3"){

     /* await Utils.sendRemainderEmailWithTemplateWithAllPlateForm(toEmail: Constant.currentUserModel.value?.email??"",
          templateId: ENV.templateIdRemainder, dynamicTemplateData: {},numberOfDays: numberOfDays);

      await Utils.sendRemainderEmailWithTemplateWithAllPlateForm(toEmail: Constant.currentUserModel.value?.email??"",
          templateId: ENV.templateIdRemainder, dynamicTemplateData: {},numberOfDays: numberOfDays-3);

     await Utils.sendRemainderEmailWithTemplateWithAllPlateForm(toEmail: Constant.currentUserModel.value?.email??"",
          templateId: ENV.templateIdRemainder, dynamicTemplateData: {},mintSend:10);*/

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
      log("orderModel.value2 :-- ${orderModel.value}");
        Get.to(() => const ParkingTicketScreen(),
            arguments: {"orderModel": orderModel.value});
      }
    });
  }

  /*completeOrder({int? index}) async {
    ShowToastDialog.showLoader("Please wait..");
    int numberOfDays = await getDifferenceBetweenStartAndEndDate(orderModel.value.bookingDate ?? "");
    log("Online Pay :: ${orderModel.value.parkingDetails!.userId.toString()}");
    UserModel? receiverUserModel = await FireStoreUtils.getUserProfile(
      orderModel.value.parkingDetails!.userId.toString(),
    );
    orderModel.value.paymentCompleted = true;
    orderModel.value.paymentType = selectedPaymentMethod.value;
    orderModel.value.adminCommission = Constant.adminCommission;
    orderModel.value.createdAt = Timestamp.now();
    orderModel.value.updateAt = Timestamp.now();

    // ✅ Credit parking amount to host wallet
    WalletTransactionModel transactionModel = WalletTransactionModel(
      id: Constant.getUuid(),
      amount: calculateAmount().toString(),
      createdDate: Timestamp.now(),
      paymentType: selectedPaymentMethod.value,
      transactionId: orderModel.value.id,
      isCredit: true,
      userId: orderModel.value.parkingDetails!.userId.toString(),
      note: "Parking amount credited",
    );

    await FireStoreUtils.setWalletTransaction(transactionModel).then((value) async {
      if (value == true) {
        await FireStoreUtils.updateOtherUserWallet(
          amount: calculateAmount().toString(),
          id: orderModel.value.parkingDetails!.userId.toString(),
        );
      }
    });

    // ✅ Calculate admin commission (ensure it’s negative for debit)
    double adminCommissionValue = Constant.calculateAdminCommission(
      amount: (double.parse(orderModel.value.subTotal.toString()) -
          double.parse(couponAmount.toString()))
          .toString(),
      adminCommissionLocal: orderModel.value.adminCommission,
    );

    // Force admin commission to be negative (debit)
    if (adminCommissionValue > 0) {
      adminCommissionValue = -adminCommissionValue;
    }

    // ✅ Create admin commission transaction
    WalletTransactionModel adminCommissionWallet = WalletTransactionModel(
      id: Constant.getUuid(),
      amount: adminCommissionValue.toString(),
      createdDate: Timestamp.now(),
      paymentType: selectedPaymentMethod.value,
      transactionId: orderModel.value.id,
      isCredit: false,
      userId: orderModel.value.parkingDetails!.userId.toString(),
      note: "Admin commission debited",
    );

    await FireStoreUtils.setWalletTransaction(adminCommissionWallet).then((value) async {
      if (value == true) {
        await FireStoreUtils.updateOtherUserWallet(
          amount: adminCommissionValue.toString(),
          id: orderModel.value.parkingDetails!.userId.toString(),
        );
      }
    });

    // ✅ Update referral and parking list data
    await FireStoreUtils.updateReferralAmount(orderModel.value);

    await FireStoreUtils.getMyParkingList(orderModel.value.parkingDetails!.userId.toString())
        .then((value) async {
      if (value != null) {
        for (var element in value) {
          if (element.subscriptionTotalOrders != null &&
              element.subscriptionTotalOrders != "0.0" &&
              element.subscriptionTotalOrders != "0") {
            element.subscriptionTotalOrders =
                (int.parse(element.subscriptionTotalOrders.toString()) - 1).toString();
            await FireStoreUtils.saveParkingDetails(element);
          }
        }
      }
    });

    // ✅ Send notifications
    Map<String, dynamic> playLoad = <String, dynamic>{
      "type": "order",
      "orderId": orderModel.value.id,
    };

    if (receiverUserModel != null) {
      await SendNotification.sendOneNotification(
        token: receiverUserModel.fcmToken.toString(),
        title: 'Booking Placed',
        body:
        '${orderModel.value.parkingDetails!.name} Booking placed on ${Constant.timestampToDate(Utils.stringToTimeStamp(orderModel.value.bookingDate!))}.',
        payload: playLoad,
      );
    }

    await FireStoreUtils.getWatchman(
      orderModel.value.parkingDetails!.id.toString(),
      orderModel.value.parkingDetails!.userId.toString(),
    ).then((value) async {
      if (value != null) {
        await SendNotification.sendOneNotification(
          token: value.fcmToken.toString(),
          title: 'Booking Placed',
          body:
          '${orderModel.value.parkingDetails!.name} Booking placed on ${Constant.timestampToDate(Utils.stringToTimeStamp(orderModel.value.bookingDate!))}.',
          payload: playLoad,
        );
      }
    });

    // ✅ Send invoice email
    log("invoicePdf :-- ", error: invoicePdf?.path);
    if (invoicePdf != null) {
      print("currentUserModel-Email ${Constant.currentUserModel.value?.email}");
      await Utils.sendEmailWithTemplate(
        toEmail: Constant.currentUserModel.value?.email ?? "",
        templateId: ENV.templateIdSendBilling,
        dynamicTemplateData: {},
        attachmentFile: invoicePdf,
      );
    }

    // ✅ Send reminder emails (if bookingType = 3)
    if (orderModel.value.bookingType.toString() == "3") {
      await Utils.sendRemainderEmailWithTemplate(
        toEmail: Constant.currentUserModel.value?.email ?? "",
        templateId: ENV.templateIdRemainder,
        dynamicTemplateData: {},
        numberOfDays: numberOfDays,
      );

      await Utils.sendRemainderEmailWithTemplate(
        toEmail: Constant.currentUserModel.value?.email ?? "",
        templateId: ENV.templateIdRemainder,
        dynamicTemplateData: {},
        numberOfDays: numberOfDays - 3,
      );
    }

    // ✅ Save order and send confirmation email
    await FireStoreUtils.setOrder(orderModel.value).then((value) async {
      if (value == true) {
        try {
          Map<String, dynamic> senMap = {
            "hostFullName": ownerUserModel.value.fullName,
            "address": orderModel.value.parkingDetails?.address ?? "",
            "clientFullName": Constant.currentUserModel.value?.fullName,
            "vehicleLicensePlate": orderModel.value.userVehicle?.vehicleNumber ?? "",
          };

          print("senMap :- $senMap");

          await Utils.sendEmailWithTemplate(
            toEmail: ownerUserModel.value.email ?? "",
            templateId: ENV.templateIdNewReservation,
            dynamicTemplateData: senMap,
          ).then((value) {
            print("Sending Booking Template");
            ShowToastDialog.closeLoader();
          });
        } catch (e) {
          ShowToastDialog.closeLoader();
          log("Exception :-- ", error: e.toString());
        }

        Get.to(
              () => const ParkingTicketScreen(),
          arguments: {"orderModel": orderModel.value},
        );
      }
    });
  }*/


  // Strip
  Future<void> stripeMakePayment1({required String amount}) async {
    print("amount :-- $amount");
    log(double.parse(amount).toStringAsFixed(0));
    try {
      Map<String, dynamic>? paymentIntentData = await createStripeIntent(amount: amount);
      print(" paymentIntentData['client_secret']:-- ${ paymentIntentData?['client_secret']}");
      if (paymentIntentData!.containsKey("error")) {
        Get.back();
        ShowToastDialog.showToast(
            "Something went wrong, please contact admin.");
      } else {
        if(selectedPaymentMethod.value.toString() == APPLE_PAY){ //  for Apple pay
       bool? status =  await payWithApplePay(paymentIntentData['client_secret'], amount);

       print("payWithApplePay :-- ${status}");

       if(status??false){
         ShowToastDialog.showToast("Payment successfully");
         completeOrder();
       }else{
         ShowToastDialog.showToast("Payment fail");
       }

        }
        else  if(selectedPaymentMethod.value.toString() == GOOGLE_PAY){ //  for Google pay

          await initGooglePayPaymentSheet(paymentIntentData['client_secret']);
          await presentPaymentSheet();

        }
        else {
          await STRIPE.Stripe.instance.initPaymentSheet(
              paymentSheetParameters: STRIPE.SetupPaymentSheetParameters(
                  paymentIntentClientSecret: paymentIntentData['client_secret'],
                  allowsDelayedPaymentMethods: false,
                  googlePay: STRIPE.PaymentSheetGooglePay(
                    merchantCountryCode: 'CA',
                    testEnv: paymentModel.value.strip?.isSandbox == true
                        ? true
                        : false,
                    currencyCode: "CAD",
                  ),
                  style: ThemeMode.system,
                  appearance: const STRIPE.PaymentSheetAppearance(
                    colors: STRIPE.PaymentSheetAppearanceColors(
                      primary: AppThemData.primary06,
                    ),
                  ),
                  merchantDisplayName: 'Phista'));
          displayStripePaymentSheet(amount: amount);
        }

      }
    } catch (e, s) {
      log("$e \n$s");
      ShowToastDialog.showToast("exception:$e \n$s");
    }
  }

  Future<void> stripeMakePayment({required String amount}) async {
    log("amount :-- $amount");

    try {
      // 🌐 --- WEB FLOW ---
      if (kIsWeb) {
        // On web, open the Stripe checkout screen you created
        final result = await Get.to(() => WebStripeCheckoutScreen(amount: amount, secretKey: paymentModel.value.strip!.stripeSecret!));

        print("stripe result when payment done");

        if (result?['status'] == 'success') {
          completeOrder();
        } else {
          ShowToastDialog.showToast("Payment cancelled");
        }

   /*     // Optionally handle the result (if success or cancel)
        if (result != null && result['status'] == 'success') {
          ShowToastDialog.showToast("Payment successful");
          completeOrder();
        } else if (result != null && result['status'] == 'cancel') {
          ShowToastDialog.showToast("Payment cancelled");
        } else {
          ShowToastDialog.showToast("Payment failed or cancelled");
        }*/

        return;
      }

      // 📱 --- MOBILE FLOW ---
      Map<String, dynamic>? paymentIntentData = await createStripeIntent(amount: amount);
      log("paymentIntentData['client_secret']:-- ${paymentIntentData?['client_secret']}");

      if (paymentIntentData == null || paymentIntentData.containsKey("error")) {
        Get.back();
        ShowToastDialog.showToast("Something went wrong, please contact admin.");
        return;
      }

      // Apple Pay
      if (isFromApple.value == true) {
        bool? status = await payWithApplePay(paymentIntentData['client_secret'], amount);
        log("payWithApplePay :-- $status");
        if (status ?? false) {
          ShowToastDialog.showToast("Payment successfully");
          completeOrder();
        } else {
          ShowToastDialog.showToast("Payment failed");
        }
      }
      // Google Pay
      else if (isFromGoogle.value == true) {
        await initGooglePayPaymentSheet(paymentIntentData['client_secret']);
        await presentPaymentSheet();
      }
      // Normal Card Payment (Stripe PaymentSheet)
      else {
        await STRIPE.Stripe.instance.initPaymentSheet(
          paymentSheetParameters: STRIPE.SetupPaymentSheetParameters(
            paymentIntentClientSecret: paymentIntentData['client_secret'],
            allowsDelayedPaymentMethods: false,
            googlePay: STRIPE.PaymentSheetGooglePay(
              merchantCountryCode: 'CA',
              testEnv: paymentModel.value.strip?.isSandbox == true,
              currencyCode: "CAD",
            ),
            style: ThemeMode.system,
            appearance: const STRIPE.PaymentSheetAppearance(
              colors: STRIPE.PaymentSheetAppearanceColors(
                primary: AppThemData.primary06,
              ),
            ),
            merchantDisplayName: 'Phista',
          ),
        );

        await displayStripePaymentSheet(amount: amount);
      }
    } catch (e, s) {
      log("$e \n$s");
      ShowToastDialog.showToast("exception: $e \n$s");
    }
  }


  void _checkStripeStatus() {
    final uri = Uri.base; // full current URL
    final status = uri.queryParameters['status'];
    log("check stripe status :-- $status");
    if (status == 'success') {
      ShowToastDialog.showToast("Payment Successful");
      log("check stripe status ");
      // ✅ Call your order complete function
      completeOrder();
    } else if (status == 'cancel') {
      ShowToastDialog.showToast("Payment Cancelled");
    }
  }

/*  Future<void> stripeMakePayment({required String amount}) async {
    log("amount :-- $amount");

    try {
      Map<String, dynamic>? paymentIntentData = await createStripeIntent(amount: amount);
      log("paymentIntentData['client_secret']:-- ${paymentIntentData?['client_secret']}");

      if (paymentIntentData == null || paymentIntentData.containsKey("error")) {
        Get.back();
        ShowToastDialog.showToast("Something went wrong, please contact admin.");
        return;
      }

      if (kIsWeb) {
        // 🌐 --- WEB PAYMENT FLOW ---
        await _openStripeCheckoutWeb(amount: amount);
      } else {
        // 📱 --- MOBILE FLOW ---
        if (selectedPaymentMethod.value.toString() == APPLE_PAY) {
          bool? status = await payWithApplePay(paymentIntentData['client_secret'], amount);
          if (status ?? false) {
            ShowToastDialog.showToast("Payment successful");
            completeOrder();
          } else {
            ShowToastDialog.showToast("Payment failed");
          }
        } else if (selectedPaymentMethod.value.toString() == GOOGLE_PAY) {
          await initGooglePayPaymentSheet(paymentIntentData['client_secret']);
          await presentPaymentSheet();
        } else {
          await STRIPE.Stripe.instance.initPaymentSheet(
            paymentSheetParameters: STRIPE.SetupPaymentSheetParameters(
              paymentIntentClientSecret: paymentIntentData['client_secret'],
              allowsDelayedPaymentMethods: false,
              googlePay: STRIPE.PaymentSheetGooglePay(
                merchantCountryCode: 'CA',
                testEnv: paymentModel.value.strip?.isSandbox == true,
                currencyCode: "CAD",
              ),
              style: ThemeMode.system,
              appearance: const STRIPE.PaymentSheetAppearance(
                colors: STRIPE.PaymentSheetAppearanceColors(
                  primary: AppThemData.primary06,
                ),
              ),
              merchantDisplayName: 'Phista',
            ),
          );

          await displayStripePaymentSheet(amount: amount);
        }
      }
    } catch (e, s) {
      log("Stripe Payment Error: $e \n$s");
      ShowToastDialog.showToast("exception: $e");
    }
  }*/

  displayStripePaymentSheet({required String amount}) async {
    try {
      await STRIPE.Stripe.instance.presentPaymentSheet().then((value) {
        ShowToastDialog.showToast("Payment successfully");
        completeOrder();
      });
    } on STRIPE.StripeException catch (e) {
      var lo1 = jsonEncode(e);
      var lo2 = jsonDecode(lo1);
      StripePayFailedModel lom = StripePayFailedModel.fromJson(lo2);
      ShowToastDialog.showToast(lom.error.message);
    } catch (e) {
      ShowToastDialog.showToast(e.toString());
    }
  }

/*  Future<void> _openStripeCheckoutWeb({required String amount}) async {
    try {
      String stripeSecretKey = ENV.skTestSecretKey; // ⚠️ Test key only
      String stripePublishableKey = ENV.pkTestPublishableKey;

      final response = await http.post(
        Uri.parse("https://api.stripe.com/v1/checkout/sessions"),
        headers: {
          "Authorization": "Bearer $stripeSecretKey",
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          "mode": "payment",
          "payment_method_types[]": "card",
          "line_items[0][price_data][currency]": "cad",
          "line_items[0][price_data][product_data][name]": "Phista Payment",
          "line_items[0][price_data][unit_amount]":
          (double.parse(amount) * 100).toInt().toString(),
          "line_items[0][quantity]": "1",
          "success_url": "http://localhost:8080/#/PaymentSelectScreen/PaymentSuccess",
          "cancel_url": "http://localhost:8080/#/PaymentSelectScreen/PaymentFailed",
        },
      );

      final data = jsonDecode(response.body);

      if (data["url"] != null) {
        // 👇 open in same tab instead of new window
        html.window.location.href = data["url"];
      } else {
        log("Error creating Checkout Session: $data");
        ShowToastDialog.showToast("Stripe checkout failed.");
      }
    } catch (e, s) {
      log("Stripe Web Checkout Error: $e\n$s");
      ShowToastDialog.showToast("Stripe web payment error: $e");
    }
  }*/

/*  void _checkStripeStatus() {
    final status = html.window.localStorage['stripe_status'];

    if (status == 'success') {
      ShowToastDialog.showToast("Payment successful");
      completeOrder();
      html.window.localStorage.remove('stripe_status'); // clear it
    } else if (status == 'failed') {
      ShowToastDialog.showToast("Payment cancelled");
      html.window.localStorage.remove('stripe_status');
    }
  }*/

  createStripeIntent({required String amount}) async {
    try {
      Map<String, dynamic> body = {
        'amount': ((double.parse(amount) * 100).round()).toString(),
        'currency': "CAD",
        'payment_method_types[]': 'card',
        "description": "Strip Payment",
        "customer":userModel.value.stripeCustomerId,
        "shipping[name]": userModel.value.fullName,
        "shipping[address][line1]": "510 Townsend St",
        "shipping[address][postal_code]": "98140",
        "shipping[address][city]": "San Francisco",
        "shipping[address][state]": "AB",
        "shipping[address][country]": "CA",
      };
      Map<String, dynamic> bodyGuest = {
        'amount': ((double.parse(amount) * 100).round()).toString(),
        'currency': "CAD",
        'payment_method_types[]': 'card',
        "description": "Strip Payment",
        "shipping[name]": userModel.value.fullName,
        "shipping[address][line1]": "510 Townsend St",
        "shipping[address][postal_code]": "98140",
        "shipping[address][city]": "San Francisco",
        "shipping[address][state]": "AB",
        "shipping[address][country]": "CA",
      };


      var stripeSecret = paymentModel.value.strip!.stripeSecret; //ENV.skTestSecretKey;
      log(stripeSecret.toString());
      var response = await http.post(
          Uri.parse('https://api.stripe.com/v1/payment_intents'),
          body:userModel.value.role != "Guest"?body:bodyGuest,
          headers: {
            'Authorization': 'Bearer $stripeSecret',
            'Content-Type': 'application/x-www-form-urlencoded'
          });
      return jsonDecode(response.body);
    } catch (e) {
      log(e.toString());
    }
  }

 /* createStripeIntent({required String amount}) async {
    try {
      var stripeSecret = ENV.skTestSecretKey;//paymentModel.value.strip!.stripeSecret;//ENV.skTestSecretKey;
      // -------------------------------------------------------
      // STEP 1: Create Customer
      // -------------------------------------------------------
      var customerRes = await http.post(
        Uri.parse('https://api.stripe.com/v1/customers'),
        headers: {
          'Authorization': 'Bearer $stripeSecret',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          "name": userModel.value.fullName,
          "email": userModel.value.email ?? "",
        },
      );
      var customerId = jsonDecode(customerRes.body)["id"];

      Map<String, dynamic> body = {
        'amount': ((double.parse(amount) * 100).round()).toString(),
        'currency': "CAD",
        'payment_method_types[]': 'card',
        "description": "Stripe Payment",
        // Attach customer
        "customer": customerId,
        // Shipping info (optional)
        "shipping[name]": userModel.value.fullName,
        "shipping[address][line1]": "510 Townsend St",
        "shipping[address][postal_code]": "98140",
        "shipping[address][city]": "San Francisco",
        "shipping[address][state]": "AB",
        "shipping[address][country]": "CA",
      };
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        body: body,
        headers: {
          'Authorization': 'Bearer $stripeSecret',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      log("Stripe Error: $e");
    }
  }*/
  //mercadoo
  mercadoPagoMakePayment(
      {required BuildContext context, required String amount}) async {
    final headers = {
      'Authorization': 'Bearer ${paymentModel.value.mercadoPago!.accessToken}',
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      "items": [
        {
          "title": "Test",
          "description": "Test Payment",
          "quantity": 1,
          "currency_id": "BRL", // or your preferred currency
          "unit_price": double.parse(amount),
        }
      ],
      "payer": {"email": userModel.value.email.toString()},
      "back_urls": {
        "failure": "${Constant.globalUrl}payment/failure",
        "pending": "${Constant.globalUrl}payment/pending",
        "success": "${Constant.globalUrl}payment/success",
      },
      "auto_return":
          "approved" // Automatically return after payment is approved
    });
    final response = await http.post(
      Uri.parse("https://api.mercadopago.com/checkout/preferences"),
      headers: headers,
      body: body,
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final bool isDone = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  MercadoPagoScreen(initialURl: data['init_point'])));

      if (isDone) {
        ShowToastDialog.showToast("Payment Successful!!");
        completeOrder();
      } else {
        ShowToastDialog.showToast("Payment UnSuccessful!!");
      }
    }
    else {
      print('Error creating preference: ${response.body}');
      return null;
    }

  }

  flutterWaveInitiatePayment(
      {required BuildContext context, required String amount}) async
  {
    final url = Uri.parse('https://api.flutterwave.com/v3/payments');
    final headers = {
      'Authorization':
          'Bearer ${paymentModel.value.flutterWave!.secretKey.toString().trim()}',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      "tx_ref": _ref,
      "amount": amount,
      "currency": "NGN",
      "redirect_url": "${Constant.globalUrl}payment/success",
      "payment_options": "ussd, card, barter, payattitude",
      "customer": {
        "email": userModel.value.email.toString(),
        "phonenumber":
            userModel.value.phoneNumber.toString(), // Add a real phone number
        "name": userModel.value.fullName.toString(), // Add a real customer name
      },
      "customizations": {
        "title": "Payment for Services",
        "description": "Payment for XYZ services",
      }
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final bool isDone = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  MercadoPagoScreen(initialURl: data['data']['link'])));

      if (isDone) {
        ShowToastDialog.showToast("Payment Successful!!");
        completeOrder();
      } else {
        ShowToastDialog.showToast("Payment UnSuccessful!!");
      }
    } else {
      print('Payment initialization failed: ${response.body}');
      return null;
    }
  }




  ///PayStack Payment Method
  payStackPayment(String totalAmount) async {
    await PayStackURLGen.payStackURLGen(
            amount: (double.parse(totalAmount) * 100).toString(),
            currency: "NGN",
            secretKey: paymentModel.value.payStack!.secretKey.toString(),
            userModel: userModel.value)
        .then((value) async {
      if (value != null) {
        PayStackUrlModel payStackModel = value;
        Get.to(PayStackScreen(
          secretKey: paymentModel.value.payStack!.secretKey.toString(),
          callBackUrl: paymentModel.value.payStack!.callbackURL.toString(),
          initialURl: payStackModel.data.authorizationUrl,
          amount: totalAmount,
          reference: payStackModel.data.reference,
        ))!
            .then((value) {
          if (value) {
            ShowToastDialog.showToast("Payment Successful!!");
            completeOrder();
          } else {
            ShowToastDialog.showToast("Payment UnSuccessful!!");
          }
        });
      } else {
        ShowToastDialog.showToast(
            "Something went wrong, please contact admin.");
      }
    });
  }

  String? _ref;

/*  setRef() {
    maths.Random numRef = maths.Random();
    int year = DateTime.now().year;
    int refNumber = numRef.nextInt(20000);
    if (Platform.isAndroid) {
      _ref = "AndroidRef$year$refNumber";
    } else if (Platform.isIOS) {
      _ref = "IOSRef$year$refNumber";
    }else{

    }
  }*/

  void setRef() {
    maths.Random numRef = maths.Random();
    int year = DateTime.now().year;
    int refNumber = numRef.nextInt(20000);

    if (kIsWeb) {
      // ✅ Web-safe version
      _ref = "WebRef$year$refNumber";
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      _ref = "AndroidRef$year$refNumber";
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      _ref = "IOSRef$year$refNumber";
    } else {
      // ✅ fallback (for desktop or other platforms)
      _ref = "OtherRef$year$refNumber";
    }

    debugPrint("Generated Ref: $_ref");
  }

  // payFast
  payFastPayment({required BuildContext context, required String amount}) {
    PayStackURLGen.getPayHTML(
            payFastSettingData: paymentModel.value.payfast!,
            amount: amount.toString(),
            userModel: userModel.value)
        .then((String? value) async {
      bool isDone = await Get.to(PayFastScreen(
          htmlData: value!, payFastSettingData: paymentModel.value.payfast!));
      if (isDone) {
        ShowToastDialog.showToast("Payment successfully");
        completeOrder();
      } else {
        ShowToastDialog.showToast("Payment Failed");
      }
    });
  }

  ///For Apple pay
  Future<bool?> payWithApplePay(
      String clientSecret,
      String amount,) async
  {
   try {

      final STRIPE.PaymentIntent paymentIntent = await STRIPE.Stripe.instance.confirmPlatformPayPaymentIntent(
        clientSecret: clientSecret,
        confirmParams: STRIPE.PlatformPayConfirmParams.applePay(
          applePay: STRIPE.ApplePayParams(
            merchantCountryCode: 'CA',
            currencyCode:"CAD",
            cartItems: [
              STRIPE.ApplePayCartSummaryItem.immediate(
                label: "Phista",
                amount: amount,
              ),
            ],
          /*  cartItems: [
              if (isWallet != "1")
                STRIPE.ApplePayCartSummaryItem.immediate(
                  label: "Recharge Amount",
                  amount: rechargeAmount ?? "",
                ),



              STRIPE.ApplePayCartSummaryItem.immediate(
                label: "Processing Fee",
                amount: processingFee ?? "",
              ),
              STRIPE.ApplePayCartSummaryItem.immediate(
                label: "Phista",
                amount: amount,
              ),
            ],*/
          ),
        ),
      );

      print("Apple payment paymentIntent :-- ${paymentIntent.status}");
      if (paymentIntent.status == STRIPE.PaymentIntentsStatus.Succeeded) {
        log('Payment Successful');
        print('Apple intent Payment :- $paymentIntent');

       /* reController.clientSecretId.value = paymentIntent.id;
        print(
            " reController.clientSecretId.value ${reController.clientSecretId.value}");
        print(" isWallet ${isWallet}");
        reController.payPalId.value = "";

        if (isWallet == "1") {
          walletModuleController.addMoney("", welcomeCodeStatus);
        } else {
          rechargePayment();
        }*/

        return true;
      }
      else {
        throw Exception(paymentIntent.status);
      }
    } on PlatformException catch (exception) {
      log(exception.message ?? 'Something went wrong');
    } catch (exception) {
      log(exception.toString());
    }
    return false;
  }
  ///Paytm payment function
  // getPaytmCheckSum(context, {required double amount}) async {
  //   final String orderId = DateTime.now().millisecondsSinceEpoch.toString();
  //   String getChecksum = "${Constant.globalUrl}payments/getpaytmchecksum";

  //   final response = await http.post(
  //       Uri.parse(
  //         getChecksum,
  //       ),
  //       headers: {},
  //       body: {
  //         "mid": paymentModel.value.paytm!.paytmMID.toString(),
  //         "order_id": orderId,
  //         "key_secret": paymentModel.value.paytm!.merchantKey.toString(),
  //       });

  //   final data = jsonDecode(response.body);
  //   log(paymentModel.value.paytm!.paytmMID.toString());

  //   await verifyCheckSum(checkSum: data["code"], amount: amount, orderId: orderId).then((value) {
  //     initiatePayment(amount: amount, orderId: orderId).then((value) {
  //       String callback = "";
  //       if (paymentModel.value.paytm!.isSandbox == true) {
  //         callback = "${callback}https://securegw-stage.paytm.in/theia/paytmCallback?ORDER_ID=$orderId";
  //       } else {
  //         callback = "${callback}https://securegw.paytm.in/theia/paytmCallback?ORDER_ID=$orderId";
  //       }

  //       GetPaymentTxtTokenModel result = value;
  //       startTransaction(context, txnTokenBy: result.body.txnToken, orderId: orderId, amount: amount, callBackURL: callback, isStaging: paymentModel.value.paytm!.isSandbox);
  //     });
  //   });
  // }

  // Future<void> startTransaction(context, {required String txnTokenBy, required orderId, required double amount, required callBackURL, required isStaging}) async {
  //   try {
  //     var response = AllInOneSdk.startTransaction(
  //       paymentModel.value.paytm!.paytmMID.toString(),
  //       orderId,
  //       amount.toString(),
  //       txnTokenBy,
  //       callBackURL,
  //       isStaging,
  //       true,
  //       true,
  //     );

  //     response.then((value) {
  //       if (value!["RESPMSG"] == "Txn Success") {
  //         log("txt done!!");
  //         ShowToastDialog.showToast("Payment Successful!!");
  //         completeOrder();
  //       }
  //     }).catchError((onError) {
  //       if (onError is PlatformException) {
  //         Get.back();

  //         ShowToastDialog.showToast(onError.message.toString());
  //       } else {
  //         log("======>>2");
  //         Get.back();
  //         ShowToastDialog.showToast(onError.message.toString());
  //       }
  //     });
  //   } catch (err) {
  //     Get.back();
  //     ShowToastDialog.showToast(err.toString());
  //   }
  // }

  // Future verifyCheckSum({required String checkSum, required double amount, required orderId}) async {
  //   String getChecksum = "${Constant.globalUrl}payments/validatechecksum";
  //   final response = await http.post(
  //       Uri.parse(
  //         getChecksum,
  //       ),
  //       headers: {},
  //       body: {
  //         "mid": paymentModel.value.paytm!.paytmMID.toString(),
  //         "order_id": orderId,
  //         "key_secret": paymentModel.value.paytm!.merchantKey.toString(),
  //         "checksum_value": checkSum,
  //       });
  //   final data = jsonDecode(response.body);
  //   return data['status'];
  // }

  Future<GetPaymentTxtTokenModel> initiatePayment(
      {required double amount, required orderId}) async
  {
    String initiateURL = "${Constant.globalUrl}payments/initiatepaytmpayment";
    String callback = "";
    if (paymentModel.value.paytm!.isSandbox == true) {
      callback =
          "${callback}https://securegw-stage.paytm.in/theia/paytmCallback?ORDER_ID=$orderId";
    } else {
      callback =
          "${callback}https://securegw.paytm.in/theia/paytmCallback?ORDER_ID=$orderId";
    }
    final response =
        await http.post(Uri.parse(initiateURL), headers: {}, body: {
      "mid": paymentModel.value.paytm!.paytmMID,
      "order_id": orderId,
      "key_secret": paymentModel.value.paytm!.merchantKey,
      "amount": amount.toString(),
      "currency": "INR",
      "callback_url": callback,
      "custId": FireStoreUtils.getCurrentUid(),
      "issandbox": paymentModel.value.paytm!.isSandbox == true ? "1" : "2",
    });
    log(response.body);
    final data = jsonDecode(response.body);
    if (data["body"]["txnToken"] == null ||
        data["body"]["txnToken"].toString().isEmpty) {
      Get.back();
      ShowToastDialog.showToast("something went wrong, please contact admin.");
    }
    return GetPaymentTxtTokenModel.fromJson(data);
  }

  ///RazorPay payment function
  final Razorpay razorPay = Razorpay();

  void openCheckout({required amount, required orderId}) async {
    var options = {
      'key': paymentModel.value.razorpay!.razorpayKey,
      'amount': amount * 100,
      'name': 'GoRide',
      'order_id': orderId,
      "currency": "INR",
      'description': 'wallet Topup',
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {
        'contact': userModel.value.phoneNumber,
        'email': userModel.value.email,
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      razorPay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void handlePaymentSuccess(PaymentSuccessResponse response) {
    ShowToastDialog.showToast("Payment Successful!!");
    completeOrder();
  }

  void handleExternalWaller(ExternalWalletResponse response) {
    ShowToastDialog.showToast("Payment Processing!! via");
  }

  void handlePaymentError(PaymentFailureResponse response) {
    // RazorPayFailedModel lom = RazorPayFailedModel.fromJson(jsonDecode(response.message!.toString()));
    ShowToastDialog.showToast("Payment Failed!!");
  }

//XenditPayment
  xenditPayment(context, amount) async {
    await createXenditInvoice(amount: amount).then((model) {
      if (model.id != null) {
        Get.to(() => XenditScreen(
                  initialURl: model.invoiceUrl ?? '',
                  transId: model.id ?? '',
                  apiKey: paymentModel.value.xendit?.apiKey ?? '',
                ))!
            .then((value) {
          if (value == true) {
            ShowToastDialog.showToast("Payment Successful!!");
            completeOrder();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Payment Unsuccessful!! \n"),
              backgroundColor: Colors.red,
            ));
          }
        });
      }
    });
  }

  Future<XenditModel> createXenditInvoice({required var amount}) async {
    const url = 'https://api.xendit.co/v2/invoices';
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': generateBasicAuthHeader(
          paymentModel.value.xendit!.apiKey!.toString()),
      // 'Cookie': '__cf_bm=yERkrx3xDITyFGiou0bbKY1bi7xEwovHNwxV1vCNbVc-1724155511-1.0.1.1-jekyYQmPCwY6vIJ524K0V6_CEw6O.dAwOmQnHtwmaXO_MfTrdnmZMka0KZvjukQgXu5B.K_6FJm47SGOPeWviQ',
    };

    final body = jsonEncode({
      'external_id': const Uuid().v1(),
      'amount': amount,
      'payer_email': 'customer@domain.com',
      'description': 'Test - VA Successful invoice payment',
      'currency': 'IDR', //IDR, PHP, THB, VND, MYR
    });

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        XenditModel model = XenditModel.fromJson(jsonDecode(response.body));
        return model;
      } else {
        return XenditModel();
      }
    } catch (e) {
      return XenditModel();
    }
  }

  String generateBasicAuthHeader(String apiKey) {
    String credentials = '$apiKey:';
    String base64Encoded = base64Encode(utf8.encode(credentials));
    return 'Basic $base64Encoded';
  }

//Orangepay payment
  static String accessToken = '';
  static String payToken = '';
  static String orderId = '';
  static String amount = '';

  orangeMakePayment(
      {required String amount, required BuildContext context}) async {
    reset();
    var id = const Uuid().v4();
    var paymentURL = await fetchToken(
        context: context, orderId: id, amount: amount, currency: 'USD');

    if (paymentURL.toString() != '') {
      Get.to(() => OrangeMoneyScreen(
                initialURl: paymentURL,
                accessToken: accessToken,
                amount: amount,
                orangePay: paymentModel.value.orangePay!,
                orderId: orderId,
                payToken: payToken,
              ))!
          .then((value) {
        if (value == true) {
          ShowToastDialog.showToast("Payment Successful!!");
          completeOrder();
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Payment Unsuccessful!! \n"),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future fetchToken(
      {required String orderId,
      required String currency,
      required BuildContext context,
      required String amount}) async {
    String apiUrl = 'https://api.orange.com/oauth/v3/token';
    Map<String, String> requestBody = {
      'grant_type': 'client_credentials',
    };

    var response = await http.post(Uri.parse(apiUrl),
        headers: <String, String>{
          'Authorization': "Basic ${paymentModel.value.orangePay!.auth!}",
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: requestBody);

    // Handle the response

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);

      accessToken = responseData['access_token'];
      // ignore: use_build_context_synchronously
      return await webpayment(
          context: context,
          amountData: amount,
          currency: currency,
          orderIdData: orderId);
    } else
    {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Color(0xff635bff),
          content: Text(
            "Something went wrong, please contact admin.",
            style: TextStyle(fontSize: 17),
          )));

      return '';
    }
  }

  Future webpayment(
      {required String orderIdData,
      required BuildContext context,
      required String currency,
      required String amountData}) async
  {
    orderId = orderIdData;
    amount = amountData;
    String apiUrl = paymentModel.value.orangePay!.isSandbox! == true
        ? 'https://api.orange.com/orange-money-webpay/dev/v1/webpayment'
        : 'https://api.orange.com/orange-money-webpay/cm/v1/webpayment';
    Map<String, String> requestBody = {
      "merchant_key": paymentModel.value.orangePay!.merchantKey ?? '',
      "currency":
          paymentModel.value.orangePay!.isSandbox == true ? "OUV" : currency,
      "order_id": orderId,
      "amount": amount,
      "reference": 'Y-Note Test',
      "lang": "en",
      "return_url": paymentModel.value.orangePay!.returnUrl!.toString(),
      "cancel_url": paymentModel.value.orangePay!.cancelUrl!.toString(),
      "notif_url": paymentModel.value.orangePay!.notifyUrl!.toString(),
    };

    var response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: json.encode(requestBody),
    );

    // Handle the response
    if (response.statusCode == 201) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      if (responseData['message'] == 'OK') {
        payToken = responseData['pay_token'];
        return responseData['payment_url'];
      } else {
        return '';
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Color(0xff635bff),
          content: Text(
            "Something went wrong, please contact admin.",
            style: TextStyle(fontSize: 17),
          )));
      return '';
    }
  }

  static reset() {
    accessToken = '';
    payToken = '';
    orderId = '';
    amount = '';
  }

//Midtrans payment
  midtransMakePayment(
      {required String amount, required BuildContext context}) async
  {
    await createPaymentLink(amount: amount).then((url) {
      if (url != '') {
        Get.to(() => MidtransScreen(
                  initialURl: url,
                ))!
            .then((value) {
          if (value == true) {
            ShowToastDialog.showToast("Payment Successful!!");
            completeOrder();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Payment Unsuccessful!! \n"),
              backgroundColor: Colors.red,
            ));
          }
        });
      }
    });
  }

  Future<String> createPaymentLink({required var amount}) async {
    var ordersId = const Uuid().v1();
    final url = Uri.parse(paymentModel.value.midtrans!.isSandbox!
        ? 'https://api.sandbox.midtrans.com/v1/payment-links'
        : 'https://api.midtrans.com/v1/payment-links');

    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization':
            generateBasicAuthHeader(paymentModel.value.midtrans!.serverKey!),
      },
      body: jsonEncode({
        'transaction_details': {
          'order_id': ordersId,
          'gross_amount': double.parse(amount.toString()).toInt(),
        },
        'usage_limit': 2,
        "callbacks": {
          "finish": "https://www.google.com?merchant_order_id=$ordersId"
        },
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      print('Payment link created: ${responseData['payment_url']}');
      return responseData['payment_url'];
    } else {
      return '';
    }
  }


  ///Google pay
  Future<void> initGooglePayPaymentSheet(String clientSecret) async {

    var gPay= STRIPE.PaymentSheetGooglePay(
      merchantCountryCode:'CA',
      currencyCode: "CAD",
      testEnv: true,
    );

    await STRIPE.Stripe.instance.initPaymentSheet(
      paymentSheetParameters: STRIPE.SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          googlePay: gPay,
          style: ThemeMode.system,
          appearance: const STRIPE.PaymentSheetAppearance(
            colors: STRIPE.PaymentSheetAppearanceColors(
              primary: AppThemData.primary06,
            ),
          ),
          merchantDisplayName: 'Phista'
      ),
    );
  }

  Future<void> presentPaymentSheet() async {
    try {
      await STRIPE.Stripe.instance.presentPaymentSheet().then((value) {
        print("presentPaymentSheet :-- $value");
      },);
      print('Payment completed');
    } catch (e) {
      print('Error: $e');
    }
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
