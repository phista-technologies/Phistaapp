import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phista/themes/app_them_data.dart';
import 'package:phista/themes/responsive.dart';

import '../../../constant/constant.dart';
import '../../../controller/driver_controller/OngoingBookingTimerController.dart';
import '../../../themes/round_button_fill.dart';
import '../booking_process/booking_parking_details_screen.dart';

class OngoingBookingTimerScreen extends StatelessWidget {
  const OngoingBookingTimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX(
      init: OngoingBookingTimerController(),
        builder: (controller){
        return Scaffold(
          body:controller.isLoading.value
              ? Constant.loader():
          Container(
            height: Responsive.height(100, context),
            width: Responsive.width(100, context),
            color: AppThemData.grey11,
            child: Padding(
              padding: const EdgeInsets.only(top: 55),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: InkWell(
                      onTap: (){
                        Get.back();
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right:12),
                        child: Image.asset(
                          "assets/images/close_ico.png",
                          width: 25,
                          height: 25,
                          color: AppThemData.grey02,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Column(
                      children: [
                        Text(
                          "Current booking".tr,
                          style: const TextStyle(
                            color: AppThemData.primary06,
                            fontSize: 18,
                            fontFamily: AppThemData.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "#${controller.orderModel.value.id}".tr,
                          style: const TextStyle(
                            color: AppThemData.grey02,
                            fontSize: 16,
                            fontFamily: AppThemData.medium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 50,),
                  Obx(() => Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 210,
                        height: 210,
                        child: CircularProgressIndicator(
                          value: controller.progress.value,
                          strokeWidth: 10,
                          color: AppThemData.primary06,
                          backgroundColor: Colors.grey,
                        ),
                      ),
                      Column(
                        children: [
                          Image.asset("assets/images/car_image.png", width: 120),
                          const SizedBox(height: 13),
                          Text(
                            controller.orderModel.value.userVehicle?.vehicleNumber ?? "----",
                            style: const TextStyle(
                              color: AppThemData.primary06,
                              fontSize: 18,
                              fontFamily: AppThemData.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )),
                  SizedBox(height: 50,),
                  Text(controller.orderModel.value.bookingType == "1"?"Remaining Time".tr:"Remaining Days".tr,
                    style: const TextStyle(
                      color: AppThemData.grey02,
                      fontSize: 18,
                      fontFamily: AppThemData.medium,
                    ),
                  ),
                  Obx(() => Text(
                    controller.remainingTime.value,
                    style: const TextStyle(
                      color: AppThemData.grey02,
                      fontSize: 50,
                      fontFamily: AppThemData.robotoRegular,
                    ),
                  )),
                ],
              ),
            ),
          ),
          bottomNavigationBar: controller.orderModel.value.bookingType=="1"? Container(
            color: AppThemData.grey11,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: RoundedButtonFill(
              title: "Add more time".tr,
              color: AppThemData.primary06,
              fontSizes: 18,
              onPress: () async {
                Get.to(() => const BookingParkingDetailsScreen(), arguments: {
                  "parkingModel": controller.orderModel.value.parkingDetails,
                  "orderModel": controller.orderModel.value,
                  "isFromTimerScreen": true
                });

                // Get.to(() => const BookingParkingDetailsScreen(), arguments: {
                //   "parkingModel": controller.orderModel.value.parkingDetails
                // });

             }
            ),
          ):SizedBox.shrink(),
        );
        });
  }
}
