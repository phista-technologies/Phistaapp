import 'dart:developer';

import 'package:clipboard/clipboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:phista/constant/collection_name.dart';
import 'package:phista/constant/constant.dart';
import 'package:phista/constant/show_toast_dialog.dart';
import 'package:phista/controller/driver_controller/review_summary_controller.dart';
import 'package:phista/model/coupon_model.dart';
import 'package:phista/model/tax_model.dart';
import 'package:phista/model/user_model.dart';
import 'package:phista/themes/app_them_data.dart';
import 'package:phista/themes/common_ui.dart';
import 'package:phista/themes/round_button_fill.dart';
import 'package:phista/ui/driver/booking_process/payment_select_screen.dart';
import 'package:phista/utils/dark_theme_provider.dart';
import 'package:phista/utils/fire_store_utils.dart';
import 'package:phista/utils/utils.dart';
import 'package:provider/provider.dart';

import '../chat/chat_screen.dart';
import '../live_tracking_screen/live_tracking_screen.dart';
import '../review/review_screen.dart';

class ReviewSummaryScreen extends StatelessWidget {
  const ReviewSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: ReviewSummaryController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: AppThemData.grey02,
            appBar: UiInterface()
                .customAppBar1(context, themeChange, "review_summary".tr,backgroundColor:AppThemData.white,textColor: AppThemData.black),
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: !kIsWeb?5:120),
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: themeChange.getThem()
                            ? AppThemData.white
                            : AppThemData.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: AppThemData.grey10,width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Parking ID'.tr,
                                    style: const TextStyle(
                                      color: AppThemData.grey07,
                                      fontSize: 14,
                                      fontFamily: AppThemData.regular,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 6,
                                  ),
                                  Text(
                                    '#${controller.orderModel.value.id}',
                                    style: const TextStyle(
                                      color: AppThemData.grey07,
                                      fontSize: 13,
                                      fontFamily: AppThemData.medium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                FlutterClipboard.copy(
                                    controller.orderModel.value.id.toString())
                                    .then((value) {
                                  ShowToastDialog.showToast(
                                      "Parking ID copied".tr);
                                });
                              },
                              child: SvgPicture.asset(
                                "assets/icon/ic_content_copy.svg",
                                height: 24,
                                width: 24,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: themeChange.getThem()
                                  ? AppThemData.white
                                  : AppThemData.white,
                              borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Parking Info'.tr,
                                    style: const TextStyle(
                                      color: AppThemData.grey07,
                                      fontSize: 16,
                                      fontFamily: AppThemData.medium,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                    decoration: ShapeDecoration(
                                      color: controller.orderModel.value
                                          .paymentCompleted ==
                                          true
                                          ? AppThemData.success02
                                          : AppThemData.error02,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(200),
                                      ),
                                    ),
                                    child: Text(
                                      controller.orderModel.value
                                          .paymentCompleted ==
                                          true
                                          ? "Payment completed".tr
                                          : 'Payment Incomplete'.tr,
                                      style: TextStyle(
                                        color: controller.orderModel.value
                                            .paymentCompleted ==
                                            true
                                            ? AppThemData.success08
                                            : AppThemData.error08,
                                        fontSize: 12,
                                        fontFamily: 'Golos Text',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 24,
                                  ),
                                  Text(
                                    controller
                                        .orderModel.value.parkingDetails!.name
                                        .toString(),
                                    style: TextStyle(
                                      color: themeChange.getThem()
                                          ? AppThemData.grey06
                                          : AppThemData.grey09,
                                      fontSize: 18,
                                      fontFamily: AppThemData.semiBold,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.location_on_outlined,
                                        color: AppThemData.grey07,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Expanded(
                                        child: Text(
                                          controller.orderModel.value
                                              .parkingDetails!.address
                                              .toString(),
                                          style: const TextStyle(
                                            color: AppThemData.grey07,
                                            fontSize: 14,
                                            fontFamily: AppThemData.regular,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Row(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            const Icon(Icons.local_parking,
                                                color: AppThemData.grey07,
                                                size: 20),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    controller.orderModel.value
                                                        .parkingSlotId
                                                        .toString(),
                                                    style: TextStyle(
                                                      color: themeChange.getThem()
                                                          ? AppThemData.grey06
                                                          : AppThemData.grey09,
                                                      fontSize: 16,
                                                      fontFamily:
                                                      AppThemData.medium,
                                                        overflow: TextOverflow.ellipsis
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(
                                                    "Parking Slot".tr,
                                                    style: const TextStyle(
                                                      color: AppThemData.grey07,
                                                      fontSize: 12,
                                                      fontFamily:
                                                      AppThemData.regular,
                                                      overflow: TextOverflow.ellipsis
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Row(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            SvgPicture.asset(
                                                "assets/icon/ic_car_image.svg",
                                                height: 24,
                                                width: 24),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  controller
                                                      .orderModel
                                                      .value
                                                      .userVehicle!
                                                      .vehicleModel!
                                                      .name
                                                      .toString(),
                                                  style: TextStyle(
                                                    color: themeChange.getThem()
                                                        ? AppThemData.grey06
                                                        : AppThemData.grey09,
                                                    fontSize: 16,
                                                    fontFamily:
                                                    AppThemData.medium,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  "vehicle Detail".tr,
                                                  style: const TextStyle(
                                                    color: AppThemData.grey07,
                                                    fontSize: 12,
                                                    fontFamily:
                                                    AppThemData.regular,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SvgPicture.asset("assets/icon/ic_car_image.svg", height: 24, width: 24),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  Constant.currentUserModel.value?.role != "Guest"?controller.vehicleDriverName.value:"Guest",
                                                  style: TextStyle(
                                                    color: themeChange.getThem() ? AppThemData.grey06 : AppThemData.grey09,
                                                    fontSize: 16,
                                                    fontFamily: AppThemData.medium,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  "Vehicle Driver Name".tr,
                                                  style: const TextStyle(
                                                    color: AppThemData.grey07,
                                                    fontSize: 12,
                                                    fontFamily: AppThemData.regular,
                                                  ),
                                                ),
                                              ],
                                            ),

                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SvgPicture.asset("assets/icon/ic_car_image.svg", height: 24, width: 24),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  controller.orderModel.value.userVehicle!.vehicleNumber.toString(),
                                                  style: TextStyle(
                                                    color: themeChange.getThem() ? AppThemData.grey06 : AppThemData.grey09,
                                                    fontSize: 16,
                                                    fontFamily: AppThemData.medium,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  "Vehicle Number".tr,
                                                  style: const TextStyle(
                                                    color: AppThemData.grey07,
                                                    fontSize: 12,
                                                    fontFamily: AppThemData.regular,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      if (controller.vehicleDriverNumber.value != "")
                                        Expanded(
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              SvgPicture.asset("assets/icon/ic_car_image.svg", height: 24, width: 24),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    controller.vehicleDriverNumber.value,
                                                    style: TextStyle(
                                                      color: themeChange.getThem() ? AppThemData.grey06 : AppThemData.grey09,
                                                      fontSize: 16,
                                                      fontFamily: AppThemData.medium,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(
                                                    "Vehicle Driver Number".tr,
                                                    style: const TextStyle(
                                                      color: AppThemData.grey07,
                                                      fontSize: 12,
                                                      fontFamily: AppThemData.regular,
                                                    ),
                                                  ),
                                                ],
                                              ),

                                            ],
                                          ),
                                        ),

                                    ],
                                  ),



                                  /*Row(
                                    children: [
                                      Expanded(
                                        child: Row(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            const Icon(Icons.access_time_rounded,
                                                color: AppThemData.grey07,
                                                size: 20),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                Constant.bookingTypeConst != "monthly"?Text(
                                                  "${controller.orderModel.value
                                                      .duration
                                                      .toString()} hours",
                                                  style: TextStyle(
                                                    color: themeChange.getThem()
                                                        ? AppThemData.grey06
                                                        : AppThemData.grey09,
                                                    fontSize: 16,
                                                    fontFamily:
                                                    AppThemData.medium,
                                                  ),
                                                ):Text(
                                                  "Monthly Booking",
                                                  style: TextStyle(
                                                    color: themeChange.getThem()
                                                        ? AppThemData.grey06
                                                        : AppThemData.grey09,
                                                    fontSize: 16,
                                                    fontFamily:
                                                    AppThemData.medium,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),

                                                if(Constant.bookingTypeConst != "monthly")
                                                Text(
                                                  "Time Durations".tr,
                                                  style: const TextStyle(
                                                    color: AppThemData.grey07,
                                                    fontSize: 12,
                                                    fontFamily:
                                                    AppThemData.regular,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),*/
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  if(Constant.bookingTypeConst == "hourly")
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment
                                              .start,
                                          children: [
                                            const Icon(Icons.calendar_today,
                                                color: AppThemData.grey07,
                                                size: 20),
                                            const SizedBox(width: 10,),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment
                                                  .start,
                                              children: [
                                                Text(Constant.timestampToDate(
                                                    Utils.stringToTimeStamp(controller.orderModel.value.bookingDate!)),
                                                  style: TextStyle(
                                                    color: themeChange.getThem()
                                                        ? AppThemData.grey06
                                                        : AppThemData.grey09,
                                                    fontSize: 16,
                                                    fontFamily: AppThemData
                                                        .medium,),),
                                                const SizedBox(height: 5,),

                                                if(Constant.bookingTypeConst == "hourly")
                                                  Text("${Constant.timestampToTime(
                                                      controller.orderModel.value
                                                          .bookingStartTime!)} - ${Constant.timestampToTime(controller.orderModel.value.bookingEndTime!)}",
                                                    style: const TextStyle(
                                                      color: AppThemData.grey07,
                                                      fontSize: 12,
                                                      fontFamily: AppThemData
                                                          .regular,),)
                                              ],),
                                          ],),
                                      ),
                                    ],
                                  ),

                                  if(Constant.bookingTypeConst == "monthly")
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment
                                              .start,
                                          children: [
                                            const Icon(Icons.calendar_today,
                                                color: AppThemData.grey07,
                                                size: 20),
                                            const SizedBox(width: 10,),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment
                                                  .start,
                                              children: [
                                                Text(Constant.timestampToDate(
                                                    Utils.stringToTimeStamp(controller.orderModel.value.bookingDate!.split(',').map((e) => e.trim()).toList()[0])),
                                                  style: TextStyle(
                                                    color: themeChange.getThem()
                                                        ? AppThemData.grey06
                                                        : AppThemData.grey09,
                                                    fontSize: 16,
                                                    fontFamily: AppThemData
                                                        .medium,),),
                                                const SizedBox(height: 5,),

                                              ],),
                                          ],),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text("To",
                                          style: TextStyle(
                                            color: themeChange.getThem()
                                                ? AppThemData.grey06
                                                : AppThemData.grey09,
                                            fontSize: 16,
                                            fontFamily: AppThemData
                                                .medium,),
                                        textAlign: TextAlign.center,),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment
                                              .start,
                                          children: [
                                            const Icon(Icons.calendar_today,
                                                color: AppThemData.grey07,
                                                size: 20),
                                            const SizedBox(width: 10,),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment
                                                  .start,
                                              children: [
                                                Text(Constant.timestampToDate(
                                                    Utils.stringToTimeStamp(controller.orderModel.value.bookingDate!.split(',').map((e) => e.trim()).toList()[1])),
                                                  style: TextStyle(
                                                    color: themeChange.getThem()
                                                        ? AppThemData.grey06
                                                        : AppThemData.grey09,
                                                    fontSize: 16,
                                                    fontFamily: AppThemData
                                                        .medium,),),

                                              ],),
                                          ],),
                                      ),
                                    ],
                                  ),
                                  if(Constant.bookingTypeConst == "daily")
                                  GridView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    gridDelegate:  SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent: Get.width/2,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                      childAspectRatio: 3.5, // Adjust based on design
                                    ),
                                    itemCount: controller.orderModel.value.bookingDate!.split(',').map((e) => e.trim()).toList().length,
                                    itemBuilder: (_, index) {
                                      var dateList = controller.orderModel.value.bookingDate!.split(',').map((e) => e.trim()).toList();
                                      print(dateList[index]);
                                     var tempDate= controller.sortDateStrings(dateList);
                                      return Row(
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start,
                                        children: [
                                          const Icon(Icons.calendar_today,
                                              color: AppThemData.grey07,
                                              size: 20),
                                          const SizedBox(width: 10,),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment
                                                .start,
                                            children: [
                                              Text(Constant.timestampToDate(
                                                  Utils.stringToTimeStamp(tempDate[index])),
                                                style: TextStyle(
                                                  color: themeChange.getThem()
                                                      ? AppThemData.grey06
                                                      : AppThemData.grey09,
                                                  fontSize: 16,
                                                  fontFamily: AppThemData
                                                      .medium,),),
                                              const SizedBox(height: 5,),

                                              Constant.bookingTypeConst == "hourly"?
                                              Text("${Constant.timestampToTime(
                                                  controller.orderModel.value
                                                      .bookingStartTime!)} - ${Constant.timestampToTime(controller.orderModel.value.bookingEndTime!)}",
                                                style: const TextStyle(
                                                  color: AppThemData.grey07,
                                                  fontSize: 12,
                                                  fontFamily: AppThemData
                                                      .regular,),):

                                              Text("Full day",
                                                style: const TextStyle(
                                                  color: AppThemData.grey07,
                                                  fontSize: 12,
                                                  fontFamily: AppThemData
                                                      .regular,),),
                                            ],),
                                        ],);

                                    },

                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Visibility(
                                    visible: controller.orderModel.value.status == Constant.placed ||
                                             controller.orderModel.value.status == Constant.onGoing,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: RoundedButtonFill(
                                            radius: 10,
                                            title: "Chat US".tr,
                                            color: themeChange.getThem()
                                                ? AppThemData.primary06
                                                : AppThemData.primary06,
                                            textColor: themeChange.getThem()
                                                ? AppThemData.grey09
                                                : AppThemData.grey09,
                                           /* icon: Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 5),
                                              child: SvgPicture.asset(
                                                  "assets/icon/ic_chat_icon.svg",
                                                  color: themeChange.getThem()
                                                      ? AppThemData.grey01
                                                      : AppThemData.grey10),
                                            ),*/
                                            isRight: true,
                                            onPress: () async {
                                              await FireStoreUtils.getUserProfile(
                                                  controller.orderModel.value
                                                      .parkingDetails!.userId
                                                      .toString())
                                                  .then((value) {
                                                UserModel userModel = value!;
                                                Get.to(const ChatScreen(),
                                                    arguments: {
                                                      "receiverModel": userModel
                                                    });
                                              });
                                            },
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: RoundedButtonFill(
                                            radius: 10,
                                            title: "Call Now".tr,
                                            color: themeChange.getThem()
                                                ? AppThemData.primary06
                                                : AppThemData.primary06,
                                            textColor: themeChange.getThem()
                                                ? AppThemData.grey09
                                                : AppThemData.grey09,
                                            isRight: true,
                                           /* icon: SvgPicture.asset(
                                                "assets/icon/ic_call_support.svg",
                                                color: themeChange.getThem()
                                                    ? AppThemData.grey01
                                                    : AppThemData.grey10),*/
                                            onPress: () async {
                                              ShowToastDialog.showLoader(
                                                  "Please wait".tr);
                                              UserModel? userModel =
                                              await FireStoreUtils
                                                  .getUserProfile(controller
                                                  .orderModel
                                                  .value
                                                  .parkingDetails!
                                                  .userId!
                                                  .toString());
                                              ShowToastDialog.closeLoader();
                                              Constant.makePhoneCall(
                                                  "${userModel!
                                                      .countryCode}${userModel
                                                      .phoneNumber}");
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          // if (controller.orderModel.value.paymentCompleted == false && controller.orderModel.value.paymentType.toString().toLowerCase() == 'cash'.toLowerCase())
                          Visibility(
                            visible:
                            controller.orderModel.value.paymentCompleted ==
                                true
                                ? false
                                : true,
                            child: Visibility(
                              visible:
                              controller.orderModel.value.paymentCompleted ==
                                  false &&
                                  controller.orderModel.value.paymentType
                                      .toString()
                                      .toLowerCase() ==
                                      'cash'.toLowerCase()
                                  ? false
                                  : true,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                          child: Text('Apply Coupon Code'.tr,
                                              style: const TextStyle(
                                                  fontFamily: AppThemData.medium,
                                                  fontSize: 14,
                                                  color: AppThemData.grey07))),
                                      InkWell(
                                          onTap: () {
                                            showCouponCode(context, controller);
                                          },
                                          child: Text('View All'.tr,
                                              style: const TextStyle(
                                                  fontFamily: AppThemData.medium,
                                                  fontSize: 14,
                                                  color: AppThemData.primary07)))
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  TextFormField(
                                    keyboardType: TextInputType.text,
                                    textCapitalization:
                                    TextCapitalization.sentences,
                                    controller: controller.couponCodeTextFieldController.value,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: themeChange.getThem()
                                            ? AppThemData.grey01
                                            : AppThemData.grey08,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: AppThemData.medium),
                                    decoration: InputDecoration(
                                        errorStyle:
                                        const TextStyle(color: Colors.red),
                                        isDense: true,
                                        filled: true,
                                        fillColor: themeChange.getThem()
                                            ? AppThemData.grey10
                                            : AppThemData.grey03,
                                        contentPadding:
                                        const EdgeInsets.symmetric(
                                            vertical: 16, horizontal: 16),
                                        suffixIcon: Padding(
                                          padding: const EdgeInsets.only(top: 14),
                                          child: InkWell(
                                            onTap: () async {
                                              controller.couponAmount.value = 0.0;
                                              if (controller.couponCodeTextFieldController.value.text.isNotEmpty) {
                                                ShowToastDialog.showLoader("Please wait".tr);
                                                await FireStoreUtils.fireStore.collection(CollectionName.coupon)
                                                    .where('code',isEqualTo: controller.couponCodeTextFieldController.value.text)
                                                    .where('enable', isEqualTo: true)
                                                    .where('validity', isGreaterThanOrEqualTo: Timestamp.now())
                                                    .get()
                                                    .then((value) {
                                                  ShowToastDialog.closeLoader();
                                                  if (value.docs.isNotEmpty) {
                                                    controller.selectedCouponModel.value = CouponModel.fromJson(value.docs.first.data());
                                                    controller.couponCodeTextFieldController.value.text = controller.selectedCouponModel.value.code.toString();
                                                    if (controller.selectedCouponModel.value.type == "fix") {
                                                      if (controller.selectedCouponModel.value.parkingId == ""){
                                                        controller.couponAmount.value = double.parse(controller.selectedCouponModel.value.amount.toString());
                                                        ShowToastDialog.closeLoader();
                                                        ShowToastDialog.showToast("Coupon Applied".tr);
                                                      }
                                                      else{
                                                      if (controller.selectedCouponModel.value.parkingId == controller.orderModel.value.parkingId){
                                                        controller.couponAmount.value = double.parse(controller.selectedCouponModel.value.amount.toString());
                                                        ShowToastDialog.closeLoader();
                                                        ShowToastDialog.showToast(
                                                            "Coupon Applied".tr);
                                                      }
                                                      else{
                                                        ShowToastDialog.closeLoader();
                                                        ShowToastDialog.showToast(
                                                            "Coupon code is Invalid".tr);
                                                      }
                                                      }
                                                    }
                                                    else {
                                                      if (controller.selectedCouponModel.value.parkingId == ""){
                                                        controller.couponAmount.value = double.parse(controller.orderModel.value.subTotal.toString()) *
                                                            double.parse(controller.selectedCouponModel.value.amount.toString()) / 100;
                                                        ShowToastDialog.closeLoader();
                                                        ShowToastDialog.showToast(
                                                            "Coupon Applied".tr);
                                                      }
                                                      else{
                                                        if (controller.selectedCouponModel.value.parkingId == controller.orderModel.value.parkingId){
                                                          controller.couponAmount.value = double.parse(controller.orderModel.value.subTotal.toString()) *
                                                              double.parse(controller.selectedCouponModel.value.amount.toString()) / 100;
                                                          ShowToastDialog.closeLoader();
                                                          ShowToastDialog.showToast(
                                                              "Coupon Applied".tr);
                                                        }
                                                        else{
                                                          ShowToastDialog.closeLoader();
                                                          ShowToastDialog.showToast(
                                                              "Coupon code is Invalid".tr);
                                                        }
                                                      }
                                                    }

                                                  } else {
                                                    ShowToastDialog.closeLoader();
                                                    ShowToastDialog.showToast(
                                                        "Coupon code is Invalid".tr);
                                                  }
                                                }).catchError((error) {
                                                  ShowToastDialog.closeLoader();
                                                  log(error.toString());
                                                });
                                              } else {
                                                ShowToastDialog.closeLoader();
                                                ShowToastDialog.showToast(
                                                    "Please Enter coupon code"
                                                        .tr);
                                              }
                                            },
                                            child: Text("Apply".tr,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: themeChange.getThem()
                                                        ? AppThemData.secondary07
                                                        : AppThemData.secondary07,
                                                    fontFamily:
                                                    AppThemData.medium)),
                                          ),
                                        ),
                                        disabledBorder: UnderlineInputBorder(
                                          borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(12),
                                              topRight: Radius.circular(12)),
                                          borderSide: BorderSide(
                                              color: themeChange.getThem()
                                                  ? AppThemData.grey04
                                                  : AppThemData.grey04,
                                              width: 1),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(12),
                                              topRight: Radius.circular(12)),
                                          borderSide: BorderSide(
                                              color: themeChange.getThem()
                                                  ? AppThemData.primary06
                                                  : AppThemData.primary06,
                                              width: 1),
                                        ),
                                        enabledBorder: UnderlineInputBorder(
                                          borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(12),
                                              topRight: Radius.circular(12)),
                                          borderSide: BorderSide(
                                              color: themeChange.getThem()
                                                  ? AppThemData.grey04
                                                  : AppThemData.grey04,
                                              width: 1),
                                        ),
                                        errorBorder: UnderlineInputBorder(
                                          borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(12),
                                              topRight: Radius.circular(12)),
                                          borderSide: BorderSide(
                                              color: themeChange.getThem()
                                                  ? AppThemData.grey04
                                                  : AppThemData.grey04,
                                              width: 1),
                                        ),
                                        border: UnderlineInputBorder(
                                          borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(12),
                                              topRight: Radius.circular(12)),
                                          borderSide: BorderSide(
                                              color: themeChange.getThem()
                                                  ? AppThemData.grey04
                                                  : AppThemData.grey04,
                                              width: 1),
                                        ),
                                        hintText: "Enter Coupon code".tr,
                                        hintStyle: TextStyle(
                                            fontSize: 14,
                                            color: themeChange.getThem()
                                                ? AppThemData.grey06
                                                : AppThemData.grey06,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: AppThemData.medium)),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: themeChange.getThem()
                                  ? AppThemData.white
                                  : AppThemData.white,
                              border: Border.all(color: AppThemData.grey07,width: 1),
                              borderRadius: const BorderRadius.all(Radius.circular(10),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Sub Total'.tr,
                                            style: TextStyle(
                                              color: themeChange.getThem()
                                                  ? AppThemData.grey07
                                                  : AppThemData.grey07,
                                              fontSize: 17,
                                              fontFamily: AppThemData.medium,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          Constant.amountShow(
                                              amount: controller
                                                  .orderModel.value.subTotal
                                                  .toString()),
                                          style: TextStyle(
                                            color: themeChange.getThem()
                                                ? AppThemData.grey07
                                                : AppThemData.grey07,
                                            fontSize: 18,
                                            fontFamily: AppThemData.semiBold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Coupon Applied'.tr,
                                            style: TextStyle(
                                              color: themeChange.getThem()
                                                  ? AppThemData.grey07
                                                  : AppThemData.grey07,
                                              fontSize: 17,
                                              fontFamily: AppThemData.medium,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          Constant.amountShow(
                                              amount: controller.couponAmount
                                                  .toString()),
                                          style: TextStyle(
                                            color: themeChange.getThem()
                                                ? AppThemData.grey07
                                                : AppThemData.grey07,
                                            fontSize: 18,
                                            fontFamily: AppThemData.semiBold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  controller.orderModel.value.taxList == null
                                      ? const SizedBox()
                                      : ListView.builder(
                                      itemCount: controller.orderModel.value.taxList!.length,
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        TaxModel taxModel = controller.orderModel.value.taxList![index];
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 5),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  "${taxModel.title.toString()} (${taxModel.type == "fix"
                                                      ? Constant.amountShow(
                                                      amount: taxModel.tax)
                                                      : "${taxModel.tax}%"})",
                                                  style: TextStyle(
                                                    color: themeChange
                                                        .getThem()
                                                        ? AppThemData.grey07
                                                        : AppThemData.grey07,
                                                    fontSize: 17,
                                                    fontFamily:
                                                    AppThemData.medium,
                                                  ),
                                                ),
                                              ),
                                              if (controller.couponAmount <= double.parse(controller.orderModel.value.subTotal.toString()))
                                              Text(
                                                "${Constant.amountShow(
                                                    amount: Constant()
                                                        .calculateTax(
                                                        amount: (double.parse(
                                                            controller.orderModel
                                                                .value.subTotal
                                                                .toString()) -
                                                            double.parse(
                                                                controller
                                                                    .couponAmount
                                                                    .value
                                                                    .toString()))
                                                            .toString(),
                                                        taxModel: taxModel)
                                                        .toStringAsFixed(
                                                        Constant.currencyModel!
                                                            .decimalDigits!)
                                                        .toString())} ",
                                                style: TextStyle(
                                                  color: themeChange.getThem()
                                                      ? AppThemData.grey07
                                                      : AppThemData.grey07,
                                                  fontSize: 18,
                                                  fontFamily:
                                                  AppThemData.semiBold,
                                                ),
                                              ),
                                              if (controller.couponAmount >= double.parse(controller.orderModel.value.subTotal.toString()))
                                                Text(
                                                  "0.00\$ ",
                                                  style: TextStyle(
                                                    color: themeChange.getThem()
                                                        ? AppThemData.grey07
                                                        : AppThemData.grey07,
                                                    fontSize: 18,
                                                    fontFamily:
                                                    AppThemData.semiBold,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        );
                                      }),
                                  Divider(
                                    thickness: 1,
                                    color: themeChange.getThem()
                                        ? AppThemData.grey09
                                        : AppThemData.grey03,
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Total'.tr,
                                            style: TextStyle(
                                              color: themeChange.getThem()
                                                  ? AppThemData.grey07
                                                  : AppThemData.grey07,
                                              fontSize: 17,
                                              fontFamily: AppThemData.medium,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          Constant.amountShow(
                                              amount: controller.calculateAmount()
                                                  .toString()),
                                          style: TextStyle(
                                            color: themeChange.getThem()
                                                ? AppThemData.grey07
                                                : AppThemData.grey07,
                                            fontSize: 18,
                                            fontFamily: AppThemData.semiBold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height:20,)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: Container(
              color: themeChange.getThem()
                  ? AppThemData.white
                  : AppThemData.white,
              padding: const EdgeInsets.symmetric(horizontal: !kIsWeb?16:120, vertical: 16),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: controller.orderModel.value.status == Constant.completed
                    ? RoundedButtonFill(
                  title: "Add Review".tr,
                  color: AppThemData.primary06,
                  isRight: false,
                  icon: const Icon(Icons.add),
                  onPress: () {
                    Get.to(() => const ReviewScreen(), arguments: {
                      "orderModel": controller.orderModel.value
                    });
                  },
                )
                    : controller.orderModel.value.paymentCompleted == false &&
                    controller.orderModel.value.paymentType
                        .toString()
                        .toLowerCase() ==
                        'cash'.toLowerCase()
                    ? RoundedButtonFill(
                  title: "Navigate to parking".tr,
                  color: AppThemData.primary06,
                  onPress: () {
                    if (Constant.mapType == "inappmap") {
                      Get.to(() => const LiveTrackingScreen(),
                          arguments: {
                            "orderModel": controller.orderModel.value
                          });
                    } else {
                      Utils.redirectMap(
                          latitude: controller.orderModel.value
                              .parkingDetails!.location!.latitude!,
                          longLatitude: controller.orderModel.value
                              .parkingDetails!.location!.longitude!,
                          name: controller
                              .orderModel.value.parkingDetails!.name
                              .toString());
                    }
                  },
                )
                    : controller.orderModel.value.paymentCompleted == true
                    ? RoundedButtonFill(
                  title: "Navigate to parking".tr,
                  color: AppThemData.primary06,
                  onPress: () {
                    if (Constant.mapType == "inappmap") {
                      Get.to(() => const LiveTrackingScreen(),
                          arguments: {
                            "orderModel":
                            controller.orderModel.value
                          });
                    } else {
                      Utils.redirectMap(
                          latitude: controller
                              .orderModel
                              .value
                              .parkingDetails!
                              .location!
                              .latitude!,
                          longLatitude: controller
                              .orderModel
                              .value
                              .parkingDetails!
                              .location!
                              .longitude!,
                          name: controller.orderModel.value
                              .parkingDetails!.name
                              .toString());
                    }
                  },
                )
                    : RoundedButtonFill(
                  radius: 10,
                  title:controller.couponAmount >= double.parse(controller.orderModel.value.subTotal.toString())?"Confirm".tr:"Go to payment".tr,
                  color: AppThemData.primary06,
                  onPress: () {
                    if (controller.couponAmount >= double.parse(controller.orderModel.value.subTotal.toString())){
                      controller.orderModel.value.coupon = controller.selectedCouponModel.value;
                     controller.completeOrder();
                    }else{
                      controller.orderModel.value.coupon = controller.selectedCouponModel.value;
                      Get.to(() => const PaymentSelectScreen(),
                          arguments: {
                            "orderModel": controller.orderModel.value,
                            "couponAmount" : controller.couponAmount.toString(),
                            "totalAmount" : controller.calculateAmount().toString(),
                            "taxList" : controller.orderModel.value.taxList
                          });
                    }

                  },
                ),
              ),
            ),
          );
        });
  }

  showCouponCode(BuildContext context, ReviewSummaryController controller) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (context) =>
          DraggableScrollableSheet(
            initialChildSize: 0.90,
            minChildSize: 0.20,
            maxChildSize: 0.92,
            expand: false,
            builder: (context, scrollController) {
              final themeChange = Provider.of<DarkThemeProvider>(context);
              return Scaffold(
                body: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Center(
                        child: Container(
                          width: 134,
                          height: 5,
                          margin: const EdgeInsets.only(top: 12, bottom: 6),
                          decoration: ShapeDecoration(
                            color: AppThemData.labelColorLightPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Coupon Code'.tr,
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: AppThemData.medium,
                          color: themeChange.getThem()
                              ? AppThemData.grey01
                              : AppThemData.grey10,
                        ),
                      ),
                    ),
                    Divider(
                        color: themeChange.getThem()
                            ? AppThemData.grey10
                            : AppThemData.grey03,
                        thickness: 1),
                    Expanded(
                      child: FutureBuilder<List<CouponModel>?>(
                          future: FireStoreUtils().getCoupon(),
                          builder: (context, snapshot) {
                            switch (snapshot.connectionState) {
                              case ConnectionState.waiting:
                                return Constant.loader();
                              case ConnectionState.done:
                                if (snapshot.hasError) {
                                  return Text(snapshot.error.toString());
                                } else {
                                  List<CouponModel> couponList = snapshot.data!;
                                  return couponList.isEmpty
                                      ? Constant.showEmptyView(
                                      message: "No coupons found")
                                      : ListView.builder(
                                    itemCount: couponList.length,
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      CouponModel couponModel =
                                      couponList[index];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 18, vertical: 12),
                                          decoration: ShapeDecoration(
                                            color: themeChange.getThem()
                                                ? AppThemData.grey10
                                                : AppThemData.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment.start,
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    flex: 2,
                                                    child: Row(
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .end,
                                                      children: [
                                                        Text(
                                                          couponModel.type == "fix" ?
                                                          Constant.amountShow(amount: couponModel.amount.toString())
                                                              : "${couponModel.amount.toString()}%",
                                                          style:
                                                          const TextStyle(
                                                            color: AppThemData
                                                                .primary07,
                                                            fontSize: 24,
                                                            fontFamily:
                                                            AppThemData
                                                                .semiBold,
                                                            fontWeight:
                                                            FontWeight
                                                                .w600,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        Text(
                                                          'off',
                                                          style: TextStyle(
                                                            color: themeChange
                                                                .getThem()
                                                                ? AppThemData
                                                                .grey01
                                                                : AppThemData
                                                                .grey07,
                                                            fontSize: 14,
                                                            fontFamily:
                                                            AppThemData
                                                                .medium,
                                                            fontWeight:
                                                            FontWeight
                                                                .w600,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: RoundedButtonFill(
                                                      title: "Apply",
                                                      color:
                                                      AppThemData.grey04,
                                                      height: 5,
                                                      fontSizes: 16,
                                                      onPress: () {
                                                        controller.couponAmount.value = 0.0;
                                                        controller.selectedCouponModel.value = couponModel;
                                                        controller.couponCodeTextFieldController.value.text = controller.selectedCouponModel.value.code.toString();
                                                        if (couponModel.type == "fix") {
                                                          if (couponModel.parkingId == ""){
                                                            controller.couponAmount.value = double.parse(couponModel.amount.toString());
                                                            ShowToastDialog.closeLoader();
                                                            ShowToastDialog.showToast(
                                                                "Coupon Applied".tr);
                                                          }
                                                          else{
                                                            if (couponModel.parkingId == controller.orderModel.value.parkingId){
                                                              controller.couponAmount.value = double.parse(couponModel.amount.toString());
                                                              ShowToastDialog.closeLoader();
                                                              ShowToastDialog.showToast(
                                                                  "Coupon Applied".tr);
                                                            }
                                                            else{
                                                              print("P I equle");
                                                              ShowToastDialog.closeLoader();
                                                              ShowToastDialog.showToast(
                                                                  "Coupon code is Invalid".tr);
                                                            }
                                                          }
                                                        }
                                                        else {
                                                          if (couponModel.parkingId == ""){
                                                            controller.couponAmount.value = double.parse(controller.orderModel.value.subTotal.toString()) *
                                                                double.parse(couponModel.amount.toString()) / 100;
                                                            ShowToastDialog.closeLoader();
                                                            ShowToastDialog.showToast(
                                                                "Coupon Applied".tr);
                                                          }
                                                          else{
                                                            if (couponModel.parkingId == controller.orderModel.value.parkingId){
                                                              controller.couponAmount.value = double.parse(controller.orderModel.value.subTotal.toString()) *
                                                                  double.parse(couponModel.amount.toString()) / 100;
                                                              ShowToastDialog.closeLoader();
                                                              ShowToastDialog.showToast(
                                                                  "Coupon Applied".tr);
                                                            }
                                                            else{
                                                              print("P I equle");
                                                              ShowToastDialog.closeLoader();
                                                              ShowToastDialog.showToast(
                                                                  "Coupon code is Invalid".tr);
                                                            }
                                                          }
                                                        }
                                                        Get.back();
                                                      },
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Text(
                                                couponModel.title.toString(),
                                                style: TextStyle(
                                                  color: themeChange.getThem()
                                                      ? AppThemData.grey01
                                                      : AppThemData.grey10,
                                                  fontSize: 16,
                                                  fontFamily:
                                                  AppThemData.semiBold,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              TextFormField(
                                                initialValue: couponModel.code
                                                    .toString(),
                                                keyboardType:
                                                TextInputType.text,
                                                textCapitalization:
                                                TextCapitalization
                                                    .sentences,
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: themeChange
                                                        .getThem()
                                                        ? AppThemData.grey01
                                                        : AppThemData.grey08,
                                                    fontWeight:
                                                    FontWeight.w500,
                                                    fontFamily:
                                                    AppThemData.medium),
                                                decoration: InputDecoration(
                                                    errorStyle:
                                                    const TextStyle(
                                                        color:
                                                        Colors.red),
                                                    isDense: true,
                                                    filled: true,
                                                    fillColor: themeChange
                                                        .getThem()
                                                        ? AppThemData.grey08
                                                        : AppThemData.grey03,
                                                    contentPadding:
                                                    const EdgeInsets
                                                        .symmetric(
                                                        vertical: 16,
                                                        horizontal: 16),
                                                    suffixIcon: Padding(
                                                      padding:
                                                      const EdgeInsets
                                                          .only(top: 14),
                                                      child: InkWell(
                                                        onTap: () {
                                                          FlutterClipboard.copy(
                                                              couponModel
                                                                  .code
                                                                  .toString())
                                                              .then((value) {
                                                            ShowToastDialog
                                                                .showToast(
                                                                "Coupon code copied"
                                                                    .tr);
                                                          });
                                                        },
                                                        child: Text("Copy".tr,
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                color: themeChange
                                                                    .getThem()
                                                                    ? AppThemData
                                                                    .secondary07
                                                                    : AppThemData
                                                                    .secondary07,
                                                                fontFamily:
                                                                AppThemData
                                                                    .medium)),
                                                      ),
                                                    ),
                                                    disabledBorder:
                                                    UnderlineInputBorder(
                                                      borderRadius:
                                                      const BorderRadius
                                                          .only(
                                                          topLeft: Radius
                                                              .circular(
                                                              12),
                                                          topRight: Radius
                                                              .circular(
                                                              12)),
                                                      borderSide: BorderSide(
                                                          color: themeChange
                                                              .getThem()
                                                              ? AppThemData
                                                              .grey04
                                                              : AppThemData
                                                              .grey04,
                                                          width: 1),
                                                    ),
                                                    focusedBorder:
                                                    UnderlineInputBorder(
                                                      borderRadius:
                                                      const BorderRadius
                                                          .only(
                                                          topLeft: Radius
                                                              .circular(
                                                              12),
                                                          topRight: Radius
                                                              .circular(
                                                              12)),
                                                      borderSide: BorderSide(
                                                          color: themeChange
                                                              .getThem()
                                                              ? AppThemData
                                                              .primary06
                                                              : AppThemData
                                                              .primary06,
                                                          width: 1),
                                                    ),
                                                    enabledBorder:
                                                    UnderlineInputBorder(
                                                      borderRadius:
                                                      const BorderRadius
                                                          .only(
                                                          topLeft: Radius
                                                              .circular(
                                                              12),
                                                          topRight: Radius
                                                              .circular(
                                                              12)),
                                                      borderSide: BorderSide(
                                                          color: themeChange
                                                              .getThem()
                                                              ? AppThemData
                                                              .grey04
                                                              : AppThemData
                                                              .grey04,
                                                          width: 1),
                                                    ),
                                                    errorBorder:
                                                    UnderlineInputBorder(
                                                      borderRadius:
                                                      const BorderRadius
                                                          .only(
                                                          topLeft: Radius
                                                              .circular(
                                                              12),
                                                          topRight: Radius
                                                              .circular(
                                                              12)),
                                                      borderSide: BorderSide(
                                                          color: themeChange
                                                              .getThem()
                                                              ? AppThemData
                                                              .grey04
                                                              : AppThemData
                                                              .grey04,
                                                          width: 1),
                                                    ),
                                                    border:
                                                    UnderlineInputBorder(
                                                      borderRadius:
                                                      const BorderRadius
                                                          .only(
                                                          topLeft: Radius
                                                              .circular(
                                                              12),
                                                          topRight: Radius
                                                              .circular(
                                                              12)),
                                                      borderSide: BorderSide(
                                                          color: themeChange
                                                              .getThem()
                                                              ? AppThemData
                                                              .grey04
                                                              : AppThemData
                                                              .grey04,
                                                          width: 1),
                                                    ),
                                                    hintText:
                                                    "Enter Coupon code"
                                                        .tr,
                                                    hintStyle: TextStyle(
                                                        fontSize: 14,
                                                        color: themeChange
                                                            .getThem()
                                                            ? AppThemData
                                                            .grey06
                                                            : AppThemData
                                                            .grey06,
                                                        fontWeight:
                                                        FontWeight.w500,
                                                        fontFamily:
                                                        AppThemData
                                                            .medium)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }
                              default:
                                return Text('Error'.tr);
                            }
                          }),
                    ),
                  ],
                ),
                bottomNavigationBar: Container(
                  color: themeChange.getThem()
                      ? AppThemData.grey10
                      : AppThemData.grey11,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 20),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: RoundedButtonFill(
                      title: "Save",
                      height: 5.5,
                      color: AppThemData.primary06,
                      fontSizes: 16,
                      onPress: () {},
                    ),
                  ),
                ),
              );
            },
          ),
    );
  }
}
