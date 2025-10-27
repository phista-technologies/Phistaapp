import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:phista/constant/constant.dart';
import 'package:phista/constant/send_notification.dart';
import 'package:phista/constant/show_toast_dialog.dart';
import 'package:phista/controller/driver_controller/dashboard_controller.dart';
import 'package:phista/controller/driver_controller/parking_ticket_controller.dart';
import 'package:phista/model/tax_model.dart';
import 'package:phista/model/user_model.dart';
import 'package:phista/themes/app_them_data.dart';
import 'package:phista/themes/common_ui.dart';
import 'package:phista/themes/responsive.dart';
import 'package:phista/themes/round_button_fill.dart';
import 'package:phista/utils/dark_theme_provider.dart';
import 'package:phista/utils/fire_store_utils.dart';
import 'package:phista/utils/network_image_widget.dart';
import 'package:phista/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../dashboard_screen.dart';
import '../live_tracking_screen/live_tracking_screen.dart';

class ParkingTicketScreen extends StatelessWidget {
  const ParkingTicketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return WillPopScope(
      onWillPop: () async {
        DashboardScreenController dashboardController =
        Get.put(DashboardScreenController());
        dashboardController.selectedIndex(2);
        Constant.globalParkingModel.value = null;
        Get.offAll(() => const DashBoardScreen());

        return false;
      },
      child: GetX(
          init: ParkingTicketController(),
          builder: (controller) {
            return Scaffold(
              backgroundColor: themeChange.getThem()
                  ? AppThemData.warning06
                  : AppThemData.warning06,
              appBar: UiInterface().customAppBar(
                context,
                themeChange,
                "".tr,
                onBackTap: () {
                  DashboardScreenController dashboardController =
                      Get.put(DashboardScreenController());
                  dashboardController.selectedIndex(2);
                  Constant.globalParkingModel.value = null;
                  Get.offAll(() => const DashBoardScreen());
                },
                backgroundColor: AppThemData.warning06,
              ),
              body: controller.isLoading.value
                  ? Constant.loader()
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Stack(
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              color: AppThemData.white,
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(8)),
                                      child: NetworkImageWidget(
                                        imageUrl: controller.orderModel.value
                                            .parkingDetails!.image
                                            .toString(),
                                        height: Responsive.height(12, context),
                                        width: Responsive.height(100, context),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
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
                                      height: 5,
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.location_on_outlined,
                                            color: AppThemData.grey07, size: 20),
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
                                      height: 5,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          'Vehicle'.tr,
                                          style: const TextStyle(
                                            color: AppThemData.grey07,
                                            fontSize: 14,
                                            fontFamily: AppThemData.regular,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          "${controller.orderModel.value.userVehicle!.vehicleBrand!.name.toString()} ${controller.orderModel.value.userVehicle!.vehicleModel!.name.toString()}",
                                          style: TextStyle(
                                            color: themeChange.getThem()
                                                ? AppThemData.grey06
                                                : AppThemData.grey09,
                                            fontSize: 14,
                                            fontFamily: AppThemData.medium,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          'Parking Spot'.tr,
                                          style: const TextStyle(
                                            color: AppThemData.grey07,
                                            fontSize: 14,
                                            fontFamily: AppThemData.regular,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          controller
                                              .orderModel.value.parkingSlotId
                                              .toString(),
                                          style: TextStyle(
                                            color: themeChange.getThem()
                                                ? AppThemData.grey06
                                                : AppThemData.grey09,
                                            fontSize: 14,
                                            fontFamily: AppThemData.medium,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 20),
                                    ),
                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: QrImageView(
                                            data: controller.orderModel.value.id
                                                .toString(),
                                            version: QrVersions.auto,
                                            padding: EdgeInsets.zero,
                                            size: 80.0,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            'if required at the location scan this on the scanner machine when you are in the parking slot'
                                                .tr,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontFamily: AppThemData.medium,
                                              color: themeChange.getThem()
                                                  ? AppThemData.grey08
                                                  : AppThemData.grey08,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 5),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  'Total'.tr,
                                                  style: const TextStyle(
                                                    color: AppThemData.grey08,
                                                    fontSize: 14,
                                                    fontFamily:
                                                        AppThemData.semiBold,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                Constant.amountShow(
                                                    amount: controller
                                                        .calculateAmount()
                                                        .toString()),
                                                style: const TextStyle(
                                                  color: AppThemData.primary07,
                                                  fontSize: 14,
                                                  fontFamily:
                                                      AppThemData.semiBold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Divider(
                                          thickness: 1,
                                          color: themeChange.getThem()
                                              ? AppThemData.grey09
                                              : AppThemData.grey03,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 5),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  'Sub Total'.tr,
                                                  style: const TextStyle(
                                                    color: AppThemData.grey07,
                                                    fontSize: 14,
                                                    fontFamily:
                                                        AppThemData.medium,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                Constant.amountShow(
                                                    amount: controller
                                                        .orderModel.value.subTotal
                                                        .toString()),
                                                style: const TextStyle(
                                                  color: AppThemData.grey08,
                                                  fontSize: 14,
                                                  fontFamily:
                                                      AppThemData.semiBold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 5),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  'Coupon Applied'.tr,
                                                  style: const TextStyle(
                                                    color: AppThemData.grey07,
                                                    fontSize: 16,
                                                    fontFamily:
                                                        AppThemData.medium,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                Constant.amountShow(
                                                    amount: controller
                                                        .couponAmount
                                                        .toString()),
                                                style: const TextStyle(
                                                  color: AppThemData.grey08,
                                                  fontSize: 16,
                                                  fontFamily:
                                                      AppThemData.semiBold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        controller.orderModel.value.taxList ==
                                                null
                                            ? const SizedBox()
                                            : ListView.builder(
                                                itemCount: controller.orderModel
                                                    .value.taxList!.length,
                                                shrinkWrap: true,
                                                padding: EdgeInsets.zero,
                                                itemBuilder: (context, index) {
                                                  TaxModel taxModel = controller
                                                      .orderModel
                                                      .value
                                                      .taxList![index];
                                                  return Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(vertical: 5),
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            "${taxModel.title.toString()} (${taxModel.type == "fix" ? Constant.amountShow(amount: taxModel.tax) : "${taxModel.tax}%"})",
                                                            style:
                                                                const TextStyle(
                                                              color: AppThemData
                                                                  .grey07,
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  AppThemData
                                                                      .medium,
                                                            ),
                                                          ),
                                                        ),
                                                        if(controller.couponAmount <= double.parse(controller.orderModel.value.subTotal.toString()))
                                                        Text(
                                                          "${Constant.amountShow(amount: Constant().calculateTax(amount: (double.parse(controller.orderModel.value.subTotal.toString()) - double.parse(controller.couponAmount.value.toString())).toString(), taxModel: taxModel).toStringAsFixed(Constant.currencyModel!.decimalDigits!).toString())} ",
                                                          style: const TextStyle(
                                                            color: AppThemData
                                                                .grey08,
                                                            fontSize: 14,
                                                            fontFamily:
                                                                AppThemData
                                                                    .semiBold,
                                                          ),
                                                        ),
                                                        if(controller.couponAmount >= double.parse(controller.orderModel.value.subTotal.toString()))
                                                          Text(
                                                            "0.00\$",
                                                            style: const TextStyle(
                                                              color: AppThemData
                                                                  .grey08,
                                                              fontSize: 14,
                                                              fontFamily:
                                                              AppThemData
                                                                  .semiBold,
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  );
                                                }),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    // Padding(
                                    //   padding: const EdgeInsets.symmetric(vertical: 5),
                                    //   child: Row(
                                    //     children: [
                                    //       const Expanded(
                                    //         child: Text(
                                    //           'Duration',
                                    //           style: TextStyle(
                                    //             color: AppThemData.grey07,
                                    //             fontSize: 16,
                                    //             fontFamily: AppThemData.medium,
                                    //           ),
                                    //         ),
                                    //       ),
                                    //       Text(
                                    //         "${controller.orderModel.value.duration.toString()} hours",
                                    //         style: const TextStyle(
                                    //           color: AppThemData.grey08,
                                    //           fontSize: 16,
                                    //           fontFamily: AppThemData.semiBold,
                                    //         ),
                                    //       ),
                                    //     ],
                                    //   ),
                                    // ),
                                    // Padding(
                                    //   padding: const EdgeInsets.symmetric(vertical: 5),
                                    //   child: Row(
                                    //     children: [
                                    //       const Expanded(
                                    //         child: Text(
                                    //           'Date',
                                    //           style: TextStyle(
                                    //             color: AppThemData.grey07,
                                    //             fontSize: 16,
                                    //             fontFamily: AppThemData.medium,
                                    //           ),
                                    //         ),
                                    //       ),
                                    //       Text(
                                    //         Constant.timestampToDate(controller.Utils.stringToTimeStamp(orderModel.value.bookingDate!),
                                    //         style: const TextStyle(
                                    //           color: AppThemData.grey08,
                                    //           fontSize: 16,
                                    //           fontFamily: AppThemData.semiBold,
                                    //         ),
                                    //       ),
                                    //     ],
                                    //   ),
                                    // ),
                                    // Padding(
                                    //   padding: const EdgeInsets.symmetric(vertical: 5),
                                    //   child: Row(
                                    //     children: [
                                    //       const Expanded(
                                    //         child: Text(
                                    //           'Name',
                                    //           style: TextStyle(
                                    //             color: AppThemData.grey07,
                                    //             fontSize: 16,
                                    //             fontFamily: AppThemData.medium,
                                    //           ),
                                    //         ),
                                    //       ),
                                    //       Text(
                                    //         "${Constant.timestampToTime(controller.orderModel.value.bookingStartTime!)} to ${Constant.timestampToTime(controller.orderModel.value.bookingEndTime!)}",
                                    //         style: const TextStyle(
                                    //           color: AppThemData.grey08,
                                    //           fontSize: 16,
                                    //           fontFamily: AppThemData.semiBold,
                                    //         ),
                                    //       ),
                                    //     ],
                                    //   ),
                                    // ),
                                    // const SizedBox(
                                    //   height: 20,
                                    // ),
                                    RoundedButtonFill(
                                      title: "Navigate the Parking Slot".tr,
                                      height: 6,
                                      color: AppThemData.primary06,
                                      fontSizes: 16,
      
                                      onPress: () async {
                                        print(Constant.mapType);
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
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    RoundedButtonFill(
                                      title: "Cancel Booking".tr,
                                      height: 6,
                                      color: AppThemData.grey04,
                                      fontSizes: 16,
                                      onPress: () async {
      
                                        if( controller.orderModel.value.bookingType == "1" ){
                                          if(!controller.canDeleteBookingHourly(controller.orderModel.value.bookingStartTime)){
                                            controller.cancelBooking();
                                          }else{
                                             // you can delete it after 10 mints
                                            controller.showPopUp("Alert".tr,"Cancellation is no longer possible as your booking has passed the 10-minute limit".tr);
                                          }
                                        }else if( controller.orderModel.value.bookingType == "3"){
                                          if(controller.canDeleteBookingMonthly(controller.orderModel.value.bookingDate??"")){
                                            controller.cancelBooking();
                                          }else{
                                            // you can delete it after 24 hours
                                            controller.showPopUp("Alert".tr,"Please note that monthly bookings can only be cancelled up to 24 hours before the start time.".tr);
                                          }
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                              left: -5,
                              top: Responsive.height(30, context),
                              child: Container(
                                height: 20,
                                width: 20,
                                decoration: const BoxDecoration(
                                    color: AppThemData.warning06,
                                    shape: BoxShape.circle),
                              )),
                          Positioned(
                              right: -5,
                              top: Responsive.height(30, context),
                              child: Container(
                                height: 20,
                                width: 20,
                                decoration: const BoxDecoration(
                                    color: AppThemData.warning06,
                                    shape: BoxShape.circle),
                              )),
                        ],
                      ),
                    ),
            );
          }),
    );
  }



}
