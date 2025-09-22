import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../constant/constant.dart';
import '../../../constant/show_toast_dialog.dart';
import '../../../controller/owner_controller/subscription_controller_owner.dart';
import '../../../payment/createRazorPayOrderModel.dart';
import '../../../payment/rozorpayConroller.dart';
import '../../../themes/app_them_data.dart';
import '../../../themes/round_button_fill.dart';
import '../../../utils/dark_theme_provider.dart';
import '../../../utils/network_image_widget.dart';

class SelectPaymentScreenOwner extends StatelessWidget {
  const SelectPaymentScreenOwner({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
      init: SubscriptionControllerOwner(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: themeChange.getThem()
              ? AppThemData.surfaceDark
              : AppThemData.surface,
          appBar: AppBar(
            backgroundColor: themeChange.getThem()
                ? AppThemData.surfaceDark
                : AppThemData.surface,
            centerTitle: false,
            titleSpacing: 0,
            leading: InkWell(
                onTap: () {
                  Get.back();
                },
                child: Icon(Icons.arrow_back,
                    color: themeChange.getThem()
                        ? AppThemData.grey02
                        : AppThemData.grey09)),
            title: Text(
              "Payment Option",
              textAlign: TextAlign.start,
              style: TextStyle(
                fontFamily: AppThemData.medium,
                fontSize: 16,
                color: themeChange.getThem()
                    ? AppThemData.grey50
                    : AppThemData.grey900,
              ),
            ),
          ),
          body: controller.isLoading.value
              ? Constant.loader()
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: ShapeDecoration(
                            color: themeChange.getThem()
                                ? AppThemData.grey900
                                : AppThemData.grey50,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            shadows: const [
                              BoxShadow(
                                color: Color(0x07000000),
                                blurRadius: 20,
                                offset: Offset(0, 0),
                                spreadRadius: 0,
                              )
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Visibility(
                                  visible:
                                      controller.paymentModel.value.wallet !=
                                              null &&
                                          controller.paymentModel.value.wallet!
                                                  .enable ==
                                              true,
                                  child: cardDecoration(
                                      controller,
                                      controller.paymentModel.value.wallet!.name
                                          .toString(),
                                      themeChange,
                                      "assets/images/wallet.png"),
                                ),
                                Visibility(
                                  visible:
                                      controller.paymentModel.value.strip !=
                                              null &&
                                          controller.paymentModel.value.strip!
                                                  .enable ==
                                              true,
                                  child: cardDecoration(
                                      controller,
                                      controller
                                              .paymentModel.value.strip?.name ??
                                          '',
                                      themeChange,
                                      controller.paymentModel.value.strip
                                              ?.image ??
                                          "assets/images/strip.png"),
                                ),
                                Visibility(
                                  visible:
                                      controller.paymentModel.value.paypal !=
                                              null &&
                                          controller.paymentModel.value.paypal!
                                                  .enable ==
                                              true,
                                  child: cardDecoration(
                                      controller,
                                      controller.paymentModel.value.paypal
                                              ?.name ??
                                          ''.toString(),
                                      themeChange,
                                      "assets/images/paypal.png"),
                                ),
                                Visibility(
                                  visible:
                                      controller.paymentModel.value.payStack !=
                                              null &&
                                          controller.paymentModel.value
                                                  .payStack!.enable ==
                                              true,
                                  child: cardDecoration(
                                      controller,
                                      controller
                                          .paymentModel.value.payStack!.name
                                          .toString(),
                                      themeChange,
                                      "assets/images/paystack.png"),
                                ),
                                Visibility(
                                  visible: controller
                                              .paymentModel.value.mercadoPago !=
                                          null &&
                                      controller.paymentModel.value.mercadoPago!
                                              .enable ==
                                          true,
                                  child: cardDecoration(
                                      controller,
                                      controller
                                          .paymentModel.value.mercadoPago!.name
                                          .toString(),
                                      themeChange,
                                      "assets/images/mercadopogo.png"),
                                ),
                                Visibility(
                                  visible: controller
                                              .paymentModel.value.flutterWave !=
                                          null &&
                                      controller.paymentModel.value.flutterWave!
                                              .enable ==
                                          true,
                                  child: cardDecoration(
                                      controller,
                                      controller
                                          .paymentModel.value.flutterWave!.name
                                          .toString(),
                                      themeChange,
                                      "assets/images/flutterwave.png"),
                                ),
                                Visibility(
                                  visible:
                                      controller.paymentModel.value.payfast !=
                                              null &&
                                          controller.paymentModel.value.payfast!
                                                  .enable ==
                                              true,
                                  child: cardDecoration(
                                      controller,
                                      controller
                                          .paymentModel.value.payfast!.name
                                          .toString(),
                                      themeChange,
                                      "assets/images/payfast.png"),
                                ),
                                // Visibility(
                                //   visible: controller.paymentModel.value.paytm != null && controller.paymentModel.value.paytm!.enable == true,
                                //   child: cardDecoration(controller, controller.paymentModel.value.paytm!.name.toString(), themeChange, "assets/images/paytm.png"),
                                // ),
                                Visibility(
                                  visible:
                                      controller.paymentModel.value.razorpay !=
                                              null &&
                                          controller.paymentModel.value
                                                  .razorpay!.enable ==
                                              true,
                                  child: cardDecoration(
                                      controller,
                                      controller
                                          .paymentModel.value.razorpay!.name
                                          .toString(),
                                      themeChange,
                                      "assets/images/rezorpay.png"),
                                ),
                                Visibility(
                                  visible:
                                      controller.paymentModel.value.xendit !=
                                              null &&
                                          controller.paymentModel.value.xendit!
                                                  .enable ==
                                              true,
                                  child: cardDecoration(
                                      controller,
                                      controller.paymentModel.value.xendit!.name
                                          .toString(),
                                      themeChange,
                                      "assets/images/xendit.png"),
                                ),
                                Visibility(
                                  visible:
                                      controller.paymentModel.value.orangePay !=
                                              null &&
                                          controller.paymentModel.value
                                                  .orangePay!.enable ==
                                              true,
                                  child: cardDecoration(
                                      controller,
                                      controller
                                          .paymentModel.value.orangePay!.name
                                          .toString(),
                                      themeChange,
                                      "assets/images/orangeMoney.png"),
                                ),
                                Visibility(
                                  visible:
                                      controller.paymentModel.value.midtrans !=
                                              null &&
                                          controller.paymentModel.value
                                                  .midtrans!.enable ==
                                              true,
                                  child: cardDecoration(
                                      controller,
                                      controller
                                          .paymentModel.value.midtrans!.name
                                          .toString(),
                                      themeChange,
                                      "assets/images/midtrans.png"),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
                color: themeChange.getThem()
                    ? AppThemData.grey900
                    : AppThemData.grey50,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20))),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: RoundedButtonFill(
                title:
                    "Pay Now | ${Constant.amountShow(amount: controller.totalAmount.value.toString())}"
                        .tr,
                height: 5,
                color: themeChange.getThem()
                    ? AppThemData.primary07
                    : AppThemData.primary07,
                textColor: AppThemData.grey50,
                fontSizes: 16,
                onPress: () async {
                  if (controller.selectedPaymentMethod.value == '') {
                    ShowToastDialog.showToast("Please Select Payment Method.");
                  } else {
                    if (controller.selectedPaymentMethod.value ==
                        controller.paymentModel.value.strip!.name) {
                      controller.stripeMakePayment(
                          amount: controller.totalAmount.value.toString());
                    } else if (controller.selectedPaymentMethod.value ==
                        controller.paymentModel.value.paypal!.name) {
                      // controller.paypalPayment(controller.totalAmount.value.toString());
                      controller.paypalPaymentSheet(
                          controller.totalAmount.value.toString(), context);
                    } else if (controller.selectedPaymentMethod.value ==
                        controller.paymentModel.value.payStack!.name) {
                      controller.payStackPayment(
                          controller.totalAmount.value.toString());
                    } else if (controller.selectedPaymentMethod.value ==
                        controller.paymentModel.value.mercadoPago!.name) {
                      controller.mercadoPagoMakePayment(
                          context: context,
                          amount: controller.totalAmount.value.toString());
                    } else if (controller.selectedPaymentMethod.value ==
                        controller.paymentModel.value.flutterWave!.name) {
                      controller.flutterWaveInitiatePayment(
                          context: context,
                          amount: controller.totalAmount.value.toString());
                    } else if (controller.selectedPaymentMethod.value ==
                        controller.paymentModel.value.payfast!.name) {
                      controller.payFastPayment(
                          context: context,
                          amount: controller.totalAmount.value.toString());
                    } else if (controller.selectedPaymentMethod.value ==
                        controller.paymentModel.value.xendit!.name) {
                      controller.xenditPayment(
                          context,
                          double.parse(
                              controller.totalAmount.value.toString()));
                    } else if (controller.selectedPaymentMethod.value ==
                        controller.paymentModel.value.orangePay!.name) {
                      controller.orangeMakePayment(
                          amount: controller.totalAmount.value
                              .toString()
                              .toString(),
                          context: context);
                    } else if (controller.selectedPaymentMethod.value ==
                        controller.paymentModel.value.midtrans!.name) {
                      controller.midtransMakePayment(
                          amount: controller.totalAmount.value
                              .toString()
                              .toString(),
                          context: context);
                    } else if (controller.selectedPaymentMethod.value ==
                        controller.paymentModel.value.wallet!.name) {
                      if (double.parse(controller.userModel.value.walletAmount
                              .toString()) >=
                          controller.totalAmount.value) {
                        Get.back();
                        controller.setOrder();
                      } else {
                        ShowToastDialog.showToast(
                            "You don't have sufficient wallet balance to purchase the subscription plan");
                      }
                    } else if (controller.selectedPaymentMethod.value ==
                        controller.paymentModel.value.razorpay!.name) {
                      RazorPayController()
                          .createOrderRazorPay(
                              amount: int.parse(
                                  controller.totalAmount.value.toString()),
                              razorpayModel:
                                  controller.paymentModel.value.razorpay)
                          .then((value) {
                        if (value == null) {
                          Get.back();
                          ShowToastDialog.showToast(
                              "Something went wrong, please contact admin.".tr);
                        } else {
                          CreateRazorPayOrderModel result = value;
                          controller.openCheckout(
                              amount: controller.totalAmount.value.toString(),
                              orderId: result.id);
                        }
                      });
                    } else {
                      ShowToastDialog.showToast(
                          "Please select payment method".tr);
                    }
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }

  cardDecoration(SubscriptionControllerOwner controller, String value, themeChange,
      String image) {
    return Obx(
      () => Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          InkWell(
            onTap: () {
              controller.selectedPaymentMethod.value = value;
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: themeChange.getThem()
                            ? AppThemData.grey10
                            : AppThemData.grey03,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Constant.isValidUrl(image) == true
                          ? NetworkImageWidget(
                              imageUrl: image,
                              width: 60,
                              height: 30,
                              fit: BoxFit.contain,
                            )
                          : Image.asset(
                              image,
                              width: 60,
                              height: 30,
                            ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          value,
                          style: TextStyle(
                              fontSize: 14,
                              fontFamily: AppThemData.bold,
                              color: themeChange.getThem()
                                  ? AppThemData.grey06
                                  : AppThemData.grey10),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        value == controller.paymentModel.value.wallet!.name
                            ? Text(
                                Constant.amountShow(
                                    amount: controller
                                                .userModel.value.walletAmount ==
                                            null
                                        ? '0.0'
                                        : controller
                                            .userModel.value.walletAmount
                                            .toString()),
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontFamily: AppThemData.semiBold,
                                  fontSize: 16,
                                  color: AppThemData.primary08,
                                ),
                              )
                            : SizedBox(),
                      ],
                    ),
                  ),
                  Radio(
                    value: value.toString(),
                    groupValue: controller.selectedPaymentMethod.value,
                    activeColor: themeChange.getThem()
                        ? AppThemData.primary08
                        : AppThemData.primary08,
                    onChanged: (value) {
                      controller.selectedPaymentMethod.value = value.toString();
                    },
                  )
                ],
              ),
            ),
          ),
          Divider(
              thickness: 1,
              color: themeChange.getThem()
                  ? AppThemData.grey08
                  : AppThemData.grey04),
        ],
      ),
    );
  }
}
