import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:phista/constant/constant.dart';
import 'package:phista/constant/show_toast_dialog.dart';
import 'package:phista/controller/booking_parking_details_controller.dart';
import 'package:phista/controller/vehicle_list_controller.dart';
import 'package:phista/model/order_model.dart';
import 'package:phista/themes/app_them_data.dart';
import 'package:phista/themes/common_ui.dart';
import 'package:phista/themes/responsive.dart';
import 'package:phista/themes/round_button_fill.dart';
import 'package:phista/themes/text_field_widget.dart';
import 'package:phista/ui/add_select_vehicle/select_vehicle_screen.dart';
import 'package:phista/ui/booking_process/parking_view_screen.dart';
import 'package:phista/ui/booking_process/review_summery_screen.dart';
import 'package:phista/utils/dark_theme_provider.dart';
import 'package:phista/utils/fire_store_utils.dart';
import 'package:phista/utils/network_image_widget.dart';
import 'package:phista/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class BookingParkingDetailsScreen extends StatelessWidget {
  const BookingParkingDetailsScreen({super.key});

initState(){
  print("devendra");
}


  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: BookingParkingDetailsController(),
        builder: (controller) {
          controller.startTimeMonthly.value = DateTime.now();
          return Scaffold(
            appBar: UiInterface()
                .customAppBar(context, themeChange, "Select Date and Time".tr),
            body: controller.isLoading.value
                ? Constant.loader()
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'select_date'.tr,
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: AppThemData.medium,
                              fontWeight: FontWeight.w700,
                              color: themeChange.getThem()
                                  ? AppThemData.grey07
                                  : AppThemData.grey07,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Obx(() {
                            final selectionMode = controller
                                .selectionModeUser(controller.radioValue.value);
                            return Container(
                              decoration: BoxDecoration(
                                  color: themeChange.getThem()
                                      ? AppThemData.grey10
                                      : AppThemData.grey03,
                                  borderRadius: BorderRadius.circular(15)),
                              child: SfDateRangePicker(
                                controller: controller.sfDateRangePickerCtrl,
                                selectionMode: selectionMode,
                                view: DateRangePickerView.month,
                                selectionColor: AppThemData.primary06,
                                startRangeSelectionColor: AppThemData.primary06,
                                rangeSelectionColor: AppThemData.primary06,
                                endRangeSelectionColor: AppThemData.primary06,
                                initialSelectedDate: selectionMode ==
                                        DateRangePickerSelectionMode.single
                                    ? controller.selectedDateTime.value
                                    : null,
                                initialSelectedDates: selectionMode ==
                                        DateRangePickerSelectionMode.multiple
                                    ? controller.selectedDatesDaily.value
                                    : null,
                                selectionTextStyle:
                                    const TextStyle(color: Colors.black),
                                onSelectionChanged: (args) {
                                  switch (selectionMode) {
                                    case DateRangePickerSelectionMode.single:
                                      controller.selectedDateTime.value =
                                          args.value;
                                      DateTime now = DateTime.now();

                                      controller.startTime.value = DateTime(
                                          controller
                                              .selectedDateTime.value.year,
                                          controller
                                              .selectedDateTime.value.month,
                                          controller.selectedDateTime.value.day,
                                          now.hour,
                                          now.minute,
                                          now.second);

                                      Duration duration = Duration(
                                          hours: controller
                                              .selectedDuration.value
                                              .toInt());

                                      controller.endTime.value = controller
                                          .startTime.value
                                          .add(duration);

                                      break;
                                    case DateRangePickerSelectionMode.multiple:
                                      controller.selectedDatesDaily.value =
                                          args.value;
                                      break;

                                    case DateRangePickerSelectionMode.range:
                                      if (selectionMode ==
                                          DateRangePickerSelectionMode.range) {
                                        if (args.value is PickerDateRange) {
                                          final PickerDateRange range =
                                              args.value;
                                          final DateTime? startDate =
                                              range.startDate;
                                          controller.startTimeMonthly.value =
                                              range.startDate!;
                                          if (startDate != null) {
                                            controller.setMonthValue(
                                                controller
                                                    .startTimeMonthly.value,
                                                int.parse(controller
                                                    .bookingMonths
                                                    .value.toString()));
                                          }
                                        }
                                      }
                                      controller.selectedRangeMonth.refresh();
                                      break;
                                    default:
                                      break;
                                  }
                                },
                                minDate: DateTime.now(),
                              ),
                            );
                          }),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                  flex: 1,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,

                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Hourly'.tr,
                                            maxLines: 1,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontFamily: AppThemData.medium,
                                              fontWeight: FontWeight.w700,
                                              color: themeChange.getThem()
                                                  ? AppThemData.grey07
                                                  : AppThemData.grey07,
                                            ),
                                          ),
                                          Radio<String>(
                                            value: "hourly",
                                            groupValue:
                                                controller.radioValue.value,
                                            activeColor: AppThemData.primary07,
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                            onChanged: (value) {
                                              controller
                                                  .selectedDuration.value = 1;
                                              controller.radioValue.value =
                                                  value ?? "";
                                              //controller.resetValue();
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  )),

                              Expanded(
                                  flex: 1,
                                  child:Constant.currentUserModel.value?.role.toString() != "Guest"?
                                  Column(
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Monthly'.tr,
                                            maxLines: 1,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontFamily: AppThemData.medium,
                                              fontWeight: FontWeight.w700,
                                              color: themeChange.getThem()
                                                  ? AppThemData.grey07
                                                  : AppThemData.grey07,
                                            ),
                                          ),
                                          Radio<String>(
                                            value: "monthly",
                                            groupValue:
                                                controller.radioValue.value,
                                            activeColor: AppThemData.primary07,
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                            onChanged: (value) {
                                              controller
                                                  .selectedDuration.value = 24;
                                              controller.radioValue.value =
                                                  value ?? "";
                                              controller.setMonthValue(
                                                  controller
                                                      .startTimeMonthly.value,
                                                  int.parse(controller
                                                      .bookingMonths
                                                      .value.toString()));
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ):SizedBox()),
                            ],
                          ),
                          const SizedBox(
                            height: 7,
                          ),
                          if (controller.radioValue.value == "monthly")
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Booking Months'.tr,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppThemData.grey07),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  height: 45,
                                  width: Responsive.width(35, context),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.remove_circle_outline),
                                        onPressed: () {
                                          if (controller.bookingMonths.value > 1) {
                                            controller.bookingMonths.value--;
                                            controller.setMonthValue(
                                              controller.startTimeMonthly.value,
                                              controller.bookingMonths.value,
                                            );
                                          }
                                        },
                                      ),
                                      Obx(() => Text(
                                        controller.bookingMonths.value.toString(),
                                        style: TextStyle(fontSize: 18),
                                      )),
                                      IconButton(
                                        icon: Icon(Icons.add_circle_outline),
                                        onPressed: () {
                                          if (controller.bookingMonths.value < 12) {
                                            controller.bookingMonths.value++;
                                            controller.setMonthValue(
                                              controller.startTimeMonthly.value,
                                              controller.bookingMonths.value,
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          if (controller.radioValue.value == "monthly")
                          const SizedBox(
                            height: 10,
                          ),
                          if (controller.radioValue.value == "hourly")

                            ///show if hourly is selected
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'duration'.tr,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: AppThemData.medium,
                                    fontWeight: FontWeight.w700,
                                    color: themeChange.getThem()
                                        ? AppThemData.grey07
                                        : AppThemData.grey07,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Text(
                                    'Full day'.tr,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: AppThemData.medium,
                                      fontWeight: FontWeight.w700,
                                      color: themeChange.getThem()
                                          ? AppThemData.grey07
                                          : AppThemData.grey07,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          if (controller.radioValue.value == "hourly")
                            const SizedBox(
                              height: 10,
                            ),
                          if (controller.radioValue.value == "hourly")
                            Obx(
                              () => Slider(
                                value: controller.selectedDuration.value,
                                onChanged: (value) {
                                  controller.selectedDuration.value = value;
                                  controller.startTimeController.value.text =
                                      DateFormat('HH:mm')
                                          .format(controller.startTime.value);
                                  Duration duration = Duration(
                                      hours: controller.selectedDuration.value
                                          .toInt());
                                  controller.endTime.value =
                                      controller.startTime.value.add(duration);
                                  controller.endTimeController.value.text =
                                      DateFormat('HH:mm')
                                          .format(controller.endTime.value);
                                },
                                autofocus: false,
                                activeColor: AppThemData.primary06,
                                inactiveColor: AppThemData.grey03,
                                min: 0,
                                max: 24,
                                divisions: 24,
                                label:
                                    "${controller.selectedDuration.value.round().toString()} hours"
                                        .tr,
                              ),
                            ),
                          if (controller.radioValue.value == "hourly")
                            const SizedBox(
                              height: 10,
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (controller.radioValue.value == "hourly"
                                  && controller.selectedDuration.value <= 5.0)
                              Text(
                                  Constant.amountShow(amount: ((double.tryParse(controller.parkingModel.value.perHrPrice.toString()) ?? 0.0) * controller.selectedDuration.value.toDouble()).toString()),
                                  style: TextStyle(
                                    color: themeChange.getThem() ? AppThemData.grey07 : AppThemData.grey07,
                                    fontSize: 14,
                                    height: 1.57,
                                    fontFamily: AppThemData.medium,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                ),
                              if (controller.radioValue.value == "hourly" && controller.selectedDuration.value > 5.0)
                              Text(
                                Constant.amountShow(amount: controller.parkingModel.value.dailyPrice.toString()),
                                style: TextStyle(
                                  color: themeChange.getThem()
                                      ? AppThemData.grey07
                                      : AppThemData.grey07,
                                  fontSize: 14,
                                  height: 1.57,
                                  fontFamily: AppThemData.medium,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                              ),
                              if (controller.radioValue.value == "monthly")
                                Text(
                                  Constant.amountShow(amount: ((double.tryParse(controller.parkingModel.value.monthlyPrice.toString()) ?? 0.0) * controller.bookingMonths.value.toDouble()).toString()),
                                  style: TextStyle(
                                    color: themeChange.getThem() ? AppThemData.grey07 : AppThemData.grey07,
                                    fontSize: 14,
                                    height: 1.57,
                                    fontFamily: AppThemData.medium,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                ),

                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          if (controller.radioValue.value == "hourly")
                            Text(
                              'Select Time'.tr,
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: AppThemData.medium,
                                fontWeight: FontWeight.w700,
                                color: themeChange.getThem()
                                    ? AppThemData.grey07
                                    : AppThemData.grey07,
                              ),
                            ),
                          if (controller.radioValue.value == "hourly")
                            const SizedBox(
                              height: 14,
                            ),
                          if (controller.radioValue.value == "hourly")
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () async {
                                     if(Constant.currentUserModel.value?.role.toString() != "Guest"){
                                       TimeOfDay timeSelected = controller.parseSelectedTime(controller.startTimeController.value.text);
                                       TimeOfDay? startTime =
                                       await Constant.selectTime(context,timeSelected);

                                       if (startTime != null) {
                                         controller.startTime.value = DateTime(
                                             controller
                                                 .selectedDateTime.value.year,
                                             controller
                                                 .selectedDateTime.value.month,
                                             controller
                                                 .selectedDateTime.value.day,
                                             startTime.hour,
                                             startTime.minute);

                                         controller.startTimeController.value
                                             .text = DateFormat('HH:mm').format(
                                             controller.startTime.value);

                                         Duration duration = Duration(
                                             hours: controller
                                                 .selectedDuration.value
                                                 .toInt());

                                         controller.endTime.value = controller
                                             .startTime.value
                                             .add(duration);
                                         controller
                                             .endTimeController.value.text =
                                             DateFormat('HH:mm').format(
                                                 controller.endTime.value);
                                       }
                                     }
                                    },
                                    child: TextFieldWidget(
                                      onPress: () {},
                                      controller:
                                          controller.startTimeController.value,
                                      textInputType:
                                          const TextInputType.numberWithOptions(
                                              decimal: true, signed: true),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                            RegExp('[0-9]')),
                                      ],
                                      hintText: 'Select Time'.tr,
                                      enable: false,
                                      prefix: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: SvgPicture.asset(
                                          "assets/icon/ic_clock.svg",
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () async {
                                      if(Constant.currentUserModel.value?.role.toString() != "Guest") {
                                        TimeOfDay timeSelected = controller.parseSelectedTime(
                                            controller.endTimeController.value.text);
                                        TimeOfDay? startTime =
                                        await Constant.selectTime(context, timeSelected);

                                        if (startTime != null) {
                                          controller.endTime.value = DateTime(
                                              controller
                                                  .selectedDateTime.value.year,
                                              controller
                                                  .selectedDateTime.value.month,
                                              controller
                                                  .selectedDateTime.value.day,
                                              startTime.hour,
                                              startTime.minute);

                                          controller
                                              .endTimeController.value.text =
                                              DateFormat('HH:mm').format(
                                                  controller.endTime.value);

                                          double duration = controller.timeHourDifference(
                                              controller.startTimeController.value.text.trim(),
                                              controller.endTimeController.value.text.trim());
                                          print("duration:--- $duration");
                                          controller.selectedDuration.value = duration;
                                          controller.selectedDuration.refresh();

                                          /*Duration duration = Duration(
                                                                        hours: controller
                                                                            .selectedDuration.value
                                                                            .toInt());

                                                                    controller.startTime.value = controller
                                                                        .endTime.value
                                                                        .subtract(duration);
                                                                    controller.startTimeController.value
                                                                            .text =
                                                                        DateFormat('HH:mm').format(
                                                                            controller.startTime.value);*/
                                        }
                                      }
                                    },
                                    child: TextFieldWidget(
                                      onPress: () {},
                                      controller:
                                          controller.endTimeController.value,
                                      textInputType:
                                          const TextInputType.numberWithOptions(
                                              decimal: true, signed: true),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                            RegExp('[0-9]')),
                                      ],
                                      hintText: 'Select Time'.tr,
                                      enable: false,
                                      prefix: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: SvgPicture.asset(
                                          "assets/icon/ic_clock.svg",
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            'Vehicle'.tr,
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: AppThemData.medium,
                              fontWeight: FontWeight.w700,
                              color: themeChange.getThem()
                                  ? AppThemData.grey07
                                  : AppThemData.grey07,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          controller.selectedVehicle.value.id != null
                              ? Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: themeChange.getThem()
                                        ? AppThemData.grey10
                                        : AppThemData.grey03,
                                  ),
                                  child: Row(
                                    children: [
                                      NetworkImageWidget(
                                        height: 60,
                                        width: 60,
                                        imageUrl: controller.selectedVehicle
                                            .value.vehicleModel!.image
                                            .toString(),
                                      ),
                                      const SizedBox(
                                        width: 15,
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              controller.selectedVehicle.value
                                                  .vehicleModel!.name
                                                  .toString(),
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontFamily:
                                                      AppThemData.medium,
                                                  color: themeChange.getThem()
                                                      ? AppThemData.grey01
                                                      : AppThemData.grey08),
                                            ),
                                            const SizedBox(
                                              height: 4,
                                            ),
                                            Text(
                                              controller.selectedVehicle.value
                                                  .vehicleNumber
                                                  .toString(),
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontFamily:
                                                      AppThemData.medium,
                                                  color: themeChange.getThem()
                                                      ? AppThemData.grey07
                                                      : AppThemData.grey07),
                                            ),
                                          ],
                                        ),
                                      ),
                                      InkWell(
                                          onTap: () {
                                            VehicleListController
                                                vehicleListController = Get.put(
                                                    VehicleListController());
                                            vehicleListController
                                                    .selectedVehicle.value =
                                                controller
                                                    .selectedVehicle.value;
                                            showBottomSheet(context);
                                          },
                                          child: Text(
                                            "Change".tr,
                                            style: TextStyle(
                                                fontSize: 14,
                                                decoration:
                                                    TextDecoration.underline,
                                                fontFamily: AppThemData.regular,
                                                color: themeChange.getThem()
                                                    ? AppThemData.blueLight07
                                                    : AppThemData.blueLight07),
                                          ))
                                    ],
                                  ),
                                )
                              : InkWell(
                                  onTap: () {
                                    VehicleListController
                                        vehicleListController =
                                        Get.put(VehicleListController());
                                    vehicleListController
                                            .selectedVehicle.value =
                                        controller.selectedVehicle.value;
                                    showBottomSheet(context);
                                  },
                                  child: SizedBox(
                                    width: Responsive.width(100, context),
                                    child: DottedBorder(
                                      borderType: BorderType.RRect,
                                      radius: const Radius.circular(40),
                                      color: AppThemData.primary09,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                            color: AppThemData.warning03,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(40))),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.add,
                                                color: AppThemData.primary09,
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                'Select Vehicle'.tr,
                                                style: const TextStyle(
                                                  color: AppThemData.primary09,
                                                  fontSize: 14,
                                                  fontFamily:
                                                      AppThemData.medium,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                          const SizedBox(
                            height: 15,
                          ),
                        ],
                      ),
                    ),
                  ),
            bottomNavigationBar: Container(
              color: themeChange.getThem()
                  ? AppThemData.grey10
                  : AppThemData.grey11,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: RoundedButtonFill(
                  title: "Next".tr,
                  color: AppThemData.primary06,
                  onPress: () async {
                    if (controller.selectedVehicle.value.id == null) {
                      ShowToastDialog.showToast(
                          "Please select your vehicle".tr);
                    } else if (controller.selectedDuration.value < 1 &&
                        controller.radioValue.value == "hourly") {
                      ShowToastDialog.showToast(
                          "Please select duration minimum one hour".tr);
                    } else {
                      ShowToastDialog.showLoader("Please wait..");
                      print(controller.radioValue.value);
                      OrderModel orderModel = OrderModel();
                      if (controller.radioValue.value == "hourly") {
                        Constant.bookingTypeConst = "hourly";
                        orderModel.bookingType = "1";
                        orderModel.bookingMonth = "";
                        orderModel.bookingDate = Utils.formatTimestampToIST(
                            Timestamp.fromDate(DateTime(
                                controller.selectedDateTime.value.year,
                                controller.selectedDateTime.value.month,
                                controller.selectedDateTime.value.day)));

                        orderModel.bookingStartTime =
                            Timestamp.fromDate(controller.startTime.value);
                        orderModel.bookingEndTime =
                            Timestamp.fromDate(controller.endTime.value);
                        print("bookingStartTime :-- ${orderModel.bookingStartTime}");
                      }

                      else if (controller.radioValue.value == "monthly") {
                        print(
                            "monthly date startDate:-- ${controller.sfDateRangePickerCtrl.selectedRange?.startDate}");
                        print(
                            "monthly date endDate:-- ${controller.sfDateRangePickerCtrl.selectedRange?.endDate}");
                        DateTime? startDateMonthly = controller.sfDateRangePickerCtrl.selectedRange?.startDate;
                        DateTime? endDateMonthly = controller.sfDateRangePickerCtrl.selectedRange?.endDate;

                        List tempMonthDate = [];
                        Constant.bookingTypeConst = "monthly";
                        orderModel.bookingType = "3";
                        orderModel.bookingMonth = controller.bookingMonths.value.toString();

                        controller.selectedDuration.value = 24.0;

                        if (startDateMonthly != null) {
                          controller.startTime.value = DateTime(
                              startDateMonthly.year,
                              startDateMonthly.month,
                              startDateMonthly.day,
                              startDateMonthly.hour,
                              startDateMonthly.minute,
                              startDateMonthly.second);
                        }

                        Duration duration = Duration(
                            hours: controller.selectedDuration.value.toInt());
                        controller.endTime.value =
                            controller.startTime.value.add(duration);
                        orderModel.bookingStartTime = Timestamp.fromDate(controller.startTime.value);
                        orderModel.bookingEndTime = Timestamp.fromDate(controller.endTime.value);

                        if (startDateMonthly != null) {
                          tempMonthDate.add(Utils.formatTimestampToIST(Timestamp.fromDate(
                              DateTime(
                                  startDateMonthly.year,
                                  startDateMonthly.month,
                                  startDateMonthly.day))));
                        }

                        if (endDateMonthly != null) {
                          tempMonthDate.add(Utils.formatTimestampToIST(Timestamp.fromDate(
                              DateTime(endDateMonthly.year,
                                  endDateMonthly.month, endDateMonthly.day))));
                        }

                        orderModel.bookingDate = tempMonthDate.join(',');

                        print("orderModel.bookingDate month :- ${orderModel.bookingDate}");
                      }


                      orderModel.parkingDetails = controller.parkingModel.value;
                      orderModel.userVehicle = controller.vehicle.value;
                      orderModel.duration =
                          controller.selectedDuration.value.toString();

                      orderModel.status = Constant.placed;
                      orderModel.userId = FireStoreUtils.getCurrentUid();
                      orderModel.id = Constant.getUuid();
                      orderModel.parkingId = controller.parkingModel.value.id;
                      orderModel.subTotal = controller.calculateParkingAmount(controller.radioValue.value,
                          controller.bookingMonths.value.toString()).toString();
                      orderModel.taxList = Constant.taxList;
                      orderModel.userVehicle = controller.selectedVehicle.value;
                      print("orderModel.subTotal :-- ${orderModel.subTotal} :-- ${controller.selectedDuration.value.toString()}");
                     var selectedParkingSlot = await controller.selectParkingSlot(controller.radioValue.value,orderModel);

                     print("selectedParkingSlot :- ${selectedParkingSlot}");
                      ShowToastDialog.closeLoader();
                     if(selectedParkingSlot.isEmpty){
                       controller.showPopUp("Alert".tr,"Sorry, you cannot park here, this location is full, all the spots are reserved".tr);
                     }else{
                       orderModel.parkingSlotId = selectedParkingSlot;
                       Get.to(() => const ReviewSummaryScreen(), arguments: {"orderModel": orderModel});
                      // Get.to(() => const ParkingViewScreen(),arguments: {"orderModel": orderModel,"selectedParkingSlot" :selectedParkingSlot});
                     }
                    }
                  },
                ),
              ),
            ),
          );
        });
  }

  showBottomSheet(BuildContext context) {
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
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.45,
        maxChildSize: 0.85,
        expand: false,
        builder: (_, scrollController) => const SelectVehicleScreen(),
      ),
    );
  }
}
