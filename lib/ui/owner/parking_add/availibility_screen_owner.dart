
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../constant/constant.dart';
import '../../../constant/show_toast_dialog.dart';
import '../../../controller/owner_controller/add_parking_details_controller_owner.dart';
import '../../../themes/app_them_data.dart';
import '../../../themes/common_ui.dart';
import '../../../themes/round_button_gradiant.dart';
import '../../../themes/text_field_widget.dart';
import '../../../utils/dark_theme_provider.dart';

class AvailibilityScreenOwner extends StatelessWidget{
  const AvailibilityScreenOwner({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: AddParkingDetailsControllerOwner(),
        builder: (controller) {
          return Scaffold(
            appBar: UiInterface().customAppBar( context, themeChange, "Availability".tr),
            body: controller.isLoading.value
                ? Constant.loader()
                : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    itemCount: controller.weekList.length,
                    itemBuilder: (context, index) {
                      final day = controller.weekList[index].day;
                      return availableDay(day!, controller, context,index);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: RoundedButtonGradiant(
                    width: 95,
                    title: "Done".tr,
                    onPress: () async {
                      // Save action
                     Get.back();
                    },
                  ),
                ),
              ],
            ),

          );
        });
  }


  Widget availableDay(String day, AddParkingDetailsControllerOwner controller, BuildContext context,int index) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      color: AppThemData.grey01,
      child: Obx(
      () =>  Column(
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  day.tr,
                  style: TextStyle(
                    fontFamily: AppThemData.semiBold,
                    fontSize: 16,
                    color: AppThemData.grey07,
                  ),
                ),
                Switch(
                  value: controller.weekList[index].isAvailable!,
                  onChanged: (value) {
                    controller.weekList[index].isAvailable = value;
                    controller.weekList.refresh();
                  },
                  activeColor: AppThemData.primary06,
                ),

              ],
            ),
            const SizedBox(height: 10),
            controller.weekList[index].isAvailable!?
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      TimeOfDay timeSelected = controller.parseSelectedTime( controller.weekList[index].startTime!);
                      TimeOfDay? picked = await Constant.selectTime(context,timeSelected);
                      if (picked != null) {
                        String endStr = controller.weekList[index].endTime!;

                        DateTime selectedEnd = DateFormat("HH:mm").parse(endStr);
                        DateTime selectedStart = DateTime(1970, 1, 1, picked.hour, picked.minute);

                        if (selectedStart.isBefore(selectedEnd)) {
                          String startTimeStr = DateFormat('HH:mm').format(selectedStart);
                          controller.weekList[index].startTime= startTimeStr;
                          controller.weekList.refresh();
                        }else{
                          ShowToastDialog.showToast(
                              "Start time should be less than end time");
                        }

                      }
                    },
                    child: TextFieldWidget(
                      controller:TextEditingController(text: controller.weekList[index].startTime.toString()),
                      enable: false,
                      hintText: 'Select Time'.tr,
                      prefix: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: SvgPicture.asset("assets/icon/ic_clock.svg"),
                      ),
                      onPress: () {},
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      TimeOfDay timeSelected = controller.parseSelectedTime( controller.weekList[index].endTime!);
                      TimeOfDay? picked = await Constant.selectTime(context,timeSelected);
                      if (picked != null) {
                        String startStr = controller.weekList[index].startTime!;

                        DateTime selectedStart = DateFormat("HH:mm").parse(startStr);
                        DateTime selectedEnd = DateTime(1970, 1, 1, picked.hour, picked.minute);

                        if (selectedEnd.isAfter(selectedStart)) {
                          String endTimeStr = DateFormat('HH:mm').format(selectedEnd);
                          controller.weekList[index].endTime = endTimeStr;
                          controller.weekList.refresh();
                        }else{
                          ShowToastDialog.showToast(
                              "End time should be greater than start time");
                        }
                      }
                    },
                    child: TextFieldWidget(
                      controller:TextEditingController(text: controller.weekList[index].endTime.toString()),
                      enable: false,
                      hintText: 'Select Time'.tr,
                      prefix: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: SvgPicture.asset("assets/icon/ic_clock.svg"),
                      ),
                      onPress: () {},
                    ),
                  ),
                ),
              ],
            )
                : const SizedBox.shrink(),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }






}