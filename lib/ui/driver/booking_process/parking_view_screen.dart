import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:phista/constant/constant.dart';
import 'package:phista/constant/show_toast_dialog.dart';
import 'package:phista/controller/driver_controller/parking_view_controller.dart';
import 'package:phista/themes/app_them_data.dart';
import 'package:phista/themes/common_ui.dart';
import 'package:phista/themes/round_button_fill.dart';
import 'package:phista/ui/driver/booking_process/review_summery_screen.dart';
import 'package:phista/utils/dark_theme_provider.dart';
import 'package:provider/provider.dart';

class ParkingViewScreen extends StatelessWidget {
  const ParkingViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: ParkingViewController(),
        builder: (controller) {
          return Scaffold(
            appBar: UiInterface().customAppBar(context, themeChange,"pick_parking_spot".tr),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      'You can park in any available space, you don’t need to park in the exact spot selected, parkings are not mapped.'.tr,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: AppThemData.medium,
                        fontWeight: FontWeight.w700,
                        color: themeChange.getThem() ? AppThemData.grey09 : AppThemData.grey09,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  controller.isLoading.value
                      ? Constant.loader()
                      : Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: GridView.builder(
                        itemCount: int.parse(controller.parkingModel.value.parkingSpace.toString()),
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(4.0),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.5),
                        itemBuilder: (context, int index) {
                          return Obx(
                                () {
                                  print("isNotAvailableAnyDay:-- ${controller.isNotAvailableAnyDay}");
                              var isBooked = controller.selectedOrderModel.where((element) => element.parkingSlotId.toString() == "A-${index + 1}");
                              return InkWell(
                                onTap: () {
                                  if (isBooked.isEmpty) {
                                    controller.selectedParking.value = "A-${index + 1}";
                                  }
                                },
                                child: controller.isNotAvailableAnyDay.value == false ?
                                Container(
                                  decoration: BoxDecoration(
                                      border: Border(
                                          right: index.isEven ? const BorderSide(color: AppThemData.grey04) : BorderSide.none,
                                          bottom: const BorderSide(color: AppThemData.grey04),
                                          top: const BorderSide(color: AppThemData.grey04),
                                          left: index.isOdd ? const BorderSide(color: AppThemData.grey04) : BorderSide.none)),
                                  child: isBooked.isNotEmpty
                                      ? Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Image.asset(
                                      "assets/images/car_image.png",
                                    ),
                                  )
                                      : controller.selectedParking.value == "A-${index + 1}"
                                      ? Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    decoration: BoxDecoration(color: themeChange.getThem() ? AppThemData.grey10 : AppThemData.grey04),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset("assets/icon/ic_parking_select.svg", width: 24, height: 24),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          'A-${index + 1}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontFamily: AppThemData.medium,
                                            color: themeChange.getThem() ? AppThemData.primary06 : AppThemData.primary07,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                      : Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    child: Center(
                                      child: Text(
                                        'A-${index + 1}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: AppThemData.medium,
                                          color: themeChange.getThem() ? AppThemData.grey08 : AppThemData.grey08,
                                        ),
                                      ),
                                    ),
                                  ),
                                ):
                                Container(
                                  decoration: BoxDecoration(
                                      border: Border(
                                          right: index.isEven ? const BorderSide(color: AppThemData.grey04) : BorderSide.none,
                                          bottom: const BorderSide(color: AppThemData.grey04),
                                          top: const BorderSide(color: AppThemData.grey04),
                                          left: index.isOdd ? const BorderSide(color: AppThemData.grey04) : BorderSide.none)),
                                  child: Image.asset(
                                    "assets/images/close_ico.png",
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: Container(
              color: themeChange.getThem() ? AppThemData.grey10 : AppThemData.grey11,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: RoundedButtonFill(
                  title: "Next".tr,
                  color: AppThemData.primary06,
                  onPress: () {
                   if (controller.isNotAvailableAnyDay.value == true){
                     ShowToastDialog.showToast("Unfortunately,this parking is not available at the selected time".tr);

                   }else{
                     if (controller.selectedParking.value.isEmpty) {
                       ShowToastDialog.showToast("Please select your parking".tr);
                     } else {
                       controller.orderModel.value.parkingSlotId = controller.selectedParking.value;
                       Get.to(() => const ReviewSummaryScreen(), arguments: {"orderModel": controller.orderModel.value});
                   }



                    }
                  },
                ),
              ),
            ),
          );
        });
  }
}
