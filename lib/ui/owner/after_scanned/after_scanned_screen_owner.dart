import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:provider/provider.dart';

import '../../../constant/constant.dart';
import '../../../constant/show_toast_dialog.dart';
import '../../../controller/owner_controller/after_scanned_controller_owner.dart';
import '../../../themes/app_them_data.dart';
import '../../../themes/common_ui.dart';
import '../../../themes/round_button_fill.dart';
import '../../../utils/dark_theme_provider.dart';
import '../../../utils/fire_store_utils.dart';
import '../../../utils/utils.dart';

class AfterScannedScreenOwner extends StatelessWidget {
  const AfterScannedScreenOwner({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetBuilder(
        init: AfterScannedControllerOwner(),
        builder: (controller) {
          return Scaffold(
            appBar: UiInterface().customAppBar(context, themeChange, "".tr, onBackTap: () {
              Get.back();
            }, isBack: true),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset("assets/icon/ic_right.svg"),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    "QR Code Successfully Scanned".tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey10,
                      fontSize: 24,
                      fontFamily: AppThemData.semiBold,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Success! Your QR code has been scanned, and you're all set to enjoy your parking experience. Have a great stay!".tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: themeChange.getThem() ? AppThemData.grey07 : AppThemData.grey07,
                      fontSize: 14,
                      fontFamily: AppThemData.medium,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: themeChange.getThem() ? AppThemData.grey10 : AppThemData.white,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "ID: ${controller.orderModel.value.id}".tr,
                          style: TextStyle(fontSize: 14, fontFamily: AppThemData.semiBold, color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey08),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Divider(thickness: 1, color: AppThemData.grey04),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.calendar_today, color: AppThemData.grey07, size: 20),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        Constant.timestampToDate(Utils.stringToTimeStamp(controller.orderModel.value.bookingDate!)),
                                        style: TextStyle(
                                          color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey09,
                                          fontSize: 16,
                                          fontFamily: AppThemData.medium,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        "${Constant.timestampToTime(controller.orderModel.value.bookingStartTime!)} - ${Constant.timestampToTime(controller.orderModel.value.bookingEndTime!)}",
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
                                  const Icon(Icons.local_parking, color: AppThemData.grey07, size: 20),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        controller.orderModel.value.parkingSlotId.toString(),
                                        style: TextStyle(
                                          color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey09,
                                          fontSize: 16,
                                          fontFamily: AppThemData.medium,
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
                                          fontFamily: AppThemData.regular,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
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
                                        controller.orderModel.value.userVehicle!.vehicleModel!.name.toString(),
                                        style: TextStyle(
                                          color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey09,
                                          fontSize: 16,
                                          fontFamily: AppThemData.medium,
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
                                  const Icon(Icons.access_time_rounded, color: AppThemData.grey07, size: 20),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${controller.orderModel.value.duration.toString()} hours".tr,
                                        style: TextStyle(
                                          color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey09,
                                          fontSize: 16,
                                          fontFamily: AppThemData.medium,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        "Time Durations".tr,
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
                            )
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            bottomNavigationBar: Container(
              color: themeChange.getThem() ? AppThemData.grey10 : AppThemData.grey11,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: RoundedButtonFill(
                    title: "Allow access".tr,
                    color: AppThemData.primary06,
                    onPress: () async {
                      ShowToastDialog.showLoader("Please wait".tr);
                      controller.orderModel.value.status = Constant.onGoing;
                      await FireStoreUtils.setOrder(controller.orderModel.value).then((value) {
                        ShowToastDialog.showToast("Access Allowed");
                        ShowToastDialog.closeLoader();
                        Get.back();
                      });
                    },
                  )),
            ),
          );
        });
  }
}
