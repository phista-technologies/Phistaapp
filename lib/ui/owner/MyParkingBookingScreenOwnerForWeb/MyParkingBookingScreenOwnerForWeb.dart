import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_getx_widget.dart';
import 'package:phista/themes/responsive.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../constant/collection_name.dart';
import '../../../constant/constant.dart';
import '../../../constant/show_toast_dialog.dart';
import '../../../controller/owner_controller/MyBookingControllerForWeb.dart';
import '../../../controller/owner_controller/my_parking_booking_controller_owner.dart';
import '../../../model/order_model.dart';
import '../../../model/parking_model.dart';
import '../../../themes/app_them_data.dart';
import '../../../themes/common_ui.dart';
import '../../../themes/round_button_fill.dart';
import '../../../themes/text_field_widget.dart';
import '../../../utils/dark_theme_provider.dart';
import '../../../utils/fire_store_utils.dart';
import '../../../utils/utils.dart';
import '../parking_add/my_summery_screen_owner.dart';
import '../qr_code_scan_screen/qr_code_scan_screen_owner.dart';
import 'BookingDetailsWebScreen_Owner.dart';

/*
class MyParkingBookingScreenOwnerForWeb extends StatelessWidget {
  final bool isBack;

  const MyParkingBookingScreenOwnerForWeb({required this.isBack, super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetX(
        init: MyParkingBookingControllerOwnerForWeb(),
        builder: (controller) {
          return Scaffold(
            appBar: UiInterface().customAppBar(
                isBack: isBack, context, themeChange, "My Booking List".tr),
            body: controller.isLoading.value ? Constant.loader() :
            controller.selectedParkingModel.value.id == null
                ? Constant.showEmptyView(message: "Parking Not available")
                : Obx(() {
                  return Center(
                    child: Container(
                      height: Get.height/1.1,
                      width: Get.width/1.1,
                      decoration: BoxDecoration(color: AppThemData.white,),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding:EdgeInsets.only(left:Get.width/1.8,top: 20,right: 10),
                            child:Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Select Parking".tr,
                                  style: TextStyle(color: AppThemData.grey11, fontFamily: AppThemData.robotoBold, fontSize:20),
                                ),
                                SizedBox(height: 5,),
                                DropdownButtonFormField<ParkingModel>(
                                    isExpanded: true,
                                    decoration: InputDecoration(
                                      errorStyle: const TextStyle(color: Colors.red),
                                      isDense: true,
                                      filled: true,
                                      fillColor: themeChange.getThem()
                                          ? AppThemData.grey10
                                          : AppThemData.grey03,
                                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                                      prefixIcon: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: SvgPicture.asset(
                                            "assets/icon/ic_car_image.svg",
                                            height: 24,
                                            width: 24),
                                      ),
                                      disabledBorder: UnderlineInputBorder(
                                        borderRadius:
                                        //const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                                        const BorderRadius.all(Radius.circular(8)),
                                        borderSide: BorderSide(
                                            color: themeChange.getThem()
                                                ? AppThemData.grey09
                                                : AppThemData.grey04,
                                            width: 1),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                                        // const BorderRadius.only(topLeft:Radius.circular(12),topRight:Radius.circular(12)),
                                        borderSide: BorderSide(
                                            color: themeChange.getThem()
                                                ? AppThemData.primary06
                                                : AppThemData.primary06,
                                            width: 1),
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderRadius:const BorderRadius.all(Radius.circular(8)),
                                        //const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                                        borderSide: BorderSide(
                                            color: themeChange.getThem()
                                                ? AppThemData.grey09
                                                : AppThemData.grey04,
                                            width: 1),
                                      ),
                                      errorBorder: UnderlineInputBorder(
                                        borderRadius:const BorderRadius.all(Radius.circular(8)),
                                        // const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                                        borderSide: BorderSide(
                                            color: themeChange.getThem()
                                                ? AppThemData.grey09
                                                : AppThemData.grey04,
                                            width: 1),
                                      ),
                                      border: UnderlineInputBorder(
                                        borderRadius: const BorderRadius.all(Radius.circular(8)),//const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                                        borderSide: BorderSide(
                                            color: themeChange.getThem()
                                                ? AppThemData.grey09
                                                : AppThemData.grey04,
                                            width: 1),
                                      ),
                                      hintStyle: TextStyle(
                                          fontSize: 14,
                                          color: themeChange.getThem()
                                              ? AppThemData.grey06
                                              : AppThemData.grey06,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: AppThemData.medium),
                                    ),
                                    value: controller.selectedParkingModel.value.id == null ? null
                                        : controller.selectedParkingModel.value,
                                    onChanged: (value) {
                                      controller.selectedParkingModel.value = value!;
                                      controller.update();
                                    },
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: themeChange.getThem()
                                            ? AppThemData.grey02
                                            : AppThemData.grey08,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: AppThemData.medium),
                                    hint: Text(
                                      "Select Your Parking".tr,
                                      style: TextStyle(
                                          color: themeChange.getThem()
                                              ? AppThemData.grey07
                                              : AppThemData.grey07),
                                    ),
                                    items:
                                    controller.parkingList.map((item) {
                                      return DropdownMenuItem<ParkingModel>(
                                        value: item,
                                        child: Text(item.name.toString(),style: const TextStyle()),
                                      );
                                    }).toList()),
                              ],
                            ),
                          ),
                          Padding(
                            padding:EdgeInsets.only(left:Responsive.width(3, context),top: 10,bottom: 10),
                            child: Text(
                              "Today's Summary".tr,
                              style: TextStyle(color: AppThemData.grey11, fontFamily: AppThemData.semiBold, fontSize:20),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              left: Responsive.width(3, context),
                              right: Responsive.width(3, context),
                            ),
                            child: StreamBuilder<QuerySnapshot>(
                              key: ValueKey(controller.selectedDateTime.value),
                              stream: FirebaseFirestore.instance
                                  .collection(CollectionName.bookedParkingOrder)
                                  .where('parkingId', isEqualTo: controller.selectedParkingModel.value.id)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Constant.loader();
                                }
                                final docs = snapshot.data?.docs ?? [];
                                controller.checkAndAutoUpdateBookings(
                                    docs);
                                List<QueryDocumentSnapshot> activeDocs = docs.where(
                                      (d) => d['status'] == Constant.placed || d['status'] == Constant.onGoing,
                                ).toList();
                                List<QueryDocumentSnapshot> completedDocs =
                                docs.where((d) => d['status'] == Constant.completed).toList();
                                List<QueryDocumentSnapshot> cancelledDocs =
                                docs.where((d) => d['status'] == Constant.canceled).toList();
                                int total = docs.length;
                                var onGoingList = controller.getOnGoingModelList(
                                  activeDocs,
                                  Utils.formatTimestampToIST(
                                    Timestamp.fromDate(controller.selectedDateTime.value),
                                  ),
                                );
                                var completedList = controller.getOnGoingModelList(
                                  completedDocs,
                                  Utils.formatTimestampToIST(
                                    Timestamp.fromDate(controller.selectedDateTime.value),
                                  ),
                                );
                                var cancelledList = controller.getOnGoingModelList(
                                  cancelledDocs,
                                  Utils.formatTimestampToIST(
                                    Timestamp.fromDate(controller.selectedDateTime.value),
                                  ),
                                );
                                var upcomingList = controller.getUpcomingBookings(
                                  activeDocs,
                                  Utils.formatTimestampToIST(
                                    Timestamp.fromDate(controller.selectedDateTime.value),
                                  ),
                                );
                                return Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        bookingDetailBox("TotalBookings".tr, "TotalBookingicon.png", total.toString(),docs, context,controller),
                                        bookingDetailBox("CompletedBookings".tr, "CompleteBookingicon.png", completedList.length.toString(),completedDocs ,context,controller),
                                        bookingDetailBox("ActiveBookings".tr, "PlacedBookingicon.png", onGoingList.length.toString(),activeDocs, context,controller),
                                        bookingDetailBox("CanceledBookings".tr, "CancelBookingicon.png", cancelledList.length.toString(),cancelledDocs ,context,controller),
                                        bookingDetailBox("UpcomingBookings".tr, "CancelBookingicon.png", upcomingList.length.toString(),activeDocs,context,controller),
                                      ],
                                    ),
                                    SizedBox(height: Responsive.height(2, context),),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        totalEarningDetailBox("TotalEarnings".tr, "CancelBookingicon.png", "\$${controller.totalEarnings.value.toString()}", context),
                                        totalEarningDetailBox("MonthlyEarnings".tr, "CancelBookingicon.png", "\$${controller.monthlyEarnings.value.toString()}", context),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 15,top: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  margin: EdgeInsets.all(5),
                                  height: Get.height/3,
                                  width: Get.width/4,
                                  decoration: BoxDecoration(
                                    color: themeChange.getThem()
                                        ? AppThemData.white
                                        : AppThemData.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppThemData.grey10,width: 1.5),

                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Padding(
                                      padding:EdgeInsets.all(8),
                                      child: buildCalendar(controller),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],),),
                  );
                },),
          );
        }
        );
  }

  Widget bookingDetailBox(String type,String img,String count,List<QueryDocumentSnapshot> docs,context,controller)
  {
    return InkWell(
        onTap: () {
          List<OrderModel> orderList = [];
          if (type == "ActiveBookings".tr) {
            orderList = controller.getOnGoingModelList(
              docs,
              Utils.formatTimestampToIST(
                Timestamp.fromDate(controller.selectedDateTime.value),
              ),
            );
          }
          else if (type == "CompletedBookings".tr) {
            orderList = controller.convertDocsToOrderModel(docs);
          }
          else if (type == "CanceledBookings".tr) {
            orderList = controller.convertDocsToOrderModel(docs);
          }
          else if (type == "TotalBookings".tr) {
            orderList = controller.convertDocsToOrderModel(docs);
          }
          else if (type == "UpcomingBookings".tr) {
            orderList = controller.getUpcomingBookings(
              docs,
              Utils.formatTimestampToIST(
                Timestamp.fromDate(controller.selectedDateTime.value),
              ),
            );
          }

          Get.to(() => const BookingDetailsWebScreen_Owner(),
            arguments: {"orderList": orderList},
          );
        },
        child: Container(
        height: Responsive.height(Responsive.height(1.3, context), context),
        width: Responsive.width(Responsive.width(0.7, context), context),
        decoration: BoxDecoration(
            border: Border.all(color: AppThemData.BookingBGColor,width: 1),
          borderRadius: BorderRadius.circular(10)
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left:10),
              child: Image.asset("assets/icon/${img}",width: 62,height: 62,fit: BoxFit.cover,),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0,top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    type,
                    style: TextStyle(color: AppThemData.grey09, fontFamily: AppThemData.robotoRegular, fontSize:16),
                  ),
                  Text(
                    count,
                    style: TextStyle(color: AppThemData.grey12, fontFamily: AppThemData.robotoBold, fontSize:32),
                  )
              ],),
            )
          ],
        ),
      ),
    );
  }

  Widget totalEarningDetailBox(String type,String img,String amt,context)
  {
    return Container(
      height: Responsive.height(Responsive.height(1.3, context), context),
      width: Responsive.width(Responsive.width(1.5, context), context),
      decoration: BoxDecoration(
          border: Border.all(color: AppThemData.BookingBGColor,width: 1),
          borderRadius: BorderRadius.circular(10)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left:10),
            child: Image.asset("assets/icon/${img}",width: 62,height: 62,fit: BoxFit.cover,),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0,top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  type,
                  style: TextStyle(color: AppThemData.grey09, fontFamily: AppThemData.robotoRegular, fontSize:16),
                ),
                Text(
                  amt,
                  style: TextStyle(color: AppThemData.grey12, fontFamily: AppThemData.robotoBold, fontSize:32),
                )
              ],),
          )

        ],
      ),
    );
  }

  Widget buildCalendar(MyParkingBookingControllerOwnerForWeb controller)
  {

    return Obx(() {
      return SfDateRangePicker(
        enablePastDates: false,
        backgroundColor: AppThemData.white,
        controller: controller.sfDateRangePickerCtrl,
        selectionMode: DateRangePickerSelectionMode.single,
        onSelectionChanged: controller.onDateSelected,
        initialSelectedDate: controller.selectedDateTime.value,
        selectionColor: AppThemData.primary06,
        todayHighlightColor: AppThemData.black,
        view: DateRangePickerView.month,
        headerStyle: const DateRangePickerHeaderStyle(
          backgroundColor: Colors.white,
          textStyle: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        monthViewSettings: const DateRangePickerMonthViewSettings(
          viewHeaderStyle: DateRangePickerViewHeaderStyle(
            textStyle: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        monthCellStyle: const DateRangePickerMonthCellStyle(
          textStyle: TextStyle(color: Colors.black),
          todayTextStyle: TextStyle(color: Colors.black),
          rangeTextStyle: TextStyle(color: Colors.black),
          leadingDatesTextStyle: TextStyle(color: Colors.black),
          disabledDatesTextStyle: TextStyle(color: Colors.grey),
        ),
        showNavigationArrow: true,
      );
    });

  }

}*/

/*class MyParkingBookingScreenOwnerForWeb extends StatelessWidget {
  final bool isBack;

  const MyParkingBookingScreenOwnerForWeb({required this.isBack, super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<MyParkingBookingControllerOwnerForWeb>(
      init: MyParkingBookingControllerOwnerForWeb(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppThemData.white,
          appBar: UiInterface().customAppBar(
            isBack: isBack,
            context,
            themeChange,
            "My Booking List".tr,
          ),
          body: controller.isLoading.value
              ? Constant.loader()
              : controller.selectedParkingModel.value.id == null
              ? Constant.showEmptyView(message: "Parking Not available",)
              : SingleChildScrollView(
                child: LayoutBuilder(builder: (context, constraints) {
                final isDesktop = constraints.maxWidth >= 1200;
                return Center(
                  child: ConstrainedBox(
                    constraints:
                    const BoxConstraints(maxWidth: 1400),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          /// SELECT PARKING
                          Align(
                            alignment: isDesktop
                                ? Alignment.centerRight : Alignment.centerLeft,
                            child: SizedBox(
                              width: isDesktop ? 400 : double.infinity,
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Select Parking".tr,
                                    style: TextStyle(
                                      color:
                                      AppThemData.grey11,
                                      fontFamily:
                                      AppThemData.robotoBold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  /// Obx ONLY here
                                  Obx(() => DropdownButtonFormField<
                                      ParkingModel>(
                                    isExpanded: true,
                                    decoration:
                                    _dropdownDecoration(
                                        themeChange),
                                    value: controller
                                        .selectedParkingModel
                                        .value
                                        .id ==
                                        null
                                        ? null
                                        : controller
                                        .selectedParkingModel
                                        .value,
                                    onChanged: (value) {
                                      controller
                                          .selectedParkingModel
                                          .value = value!;
                                    },
                                    items: controller.parkingList
                                        .map((item) {
                                      return DropdownMenuItem<
                                          ParkingModel>(
                                        value: item,
                                        child: Text(item.name
                                            .toString()),
                                      );
                                    }).toList(),
                                  )),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          /// SUMMARY TITLE
                          Text(
                            "Today's Summary".tr,
                            style: TextStyle(
                              color: AppThemData.grey11,
                              fontFamily:
                              AppThemData.semiBold,
                              fontSize: 20,
                            ),
                          ),

                          const SizedBox(height: 10),

                          /// SUMMARY DATA
                          StreamBuilder<QuerySnapshot>(
                            key: ValueKey(controller
                                .selectedDateTime.value),
                            stream: FirebaseFirestore.instance
                                .collection(CollectionName
                                .bookedParkingOrder)
                                .where(
                              'parkingId',
                              isEqualTo: controller
                                  .selectedParkingModel
                                  .value
                                  .id,
                            )
                                .snapshots(),
                            builder: (context, snapshot) {

                              if (snapshot.connectionState == ConnectionState.waiting &&
                                  !snapshot.hasData) {
                                return Constant.loader();
                              }
                              final docs = snapshot.data?.docs ?? [];

                              controller
                                  .checkAndAutoUpdateBookings(
                                  docs);

                              final activeDocs = docs
                                  .where((d) =>
                              d['status'] ==
                                  Constant.placed ||
                                  d['status'] ==
                                      Constant.onGoing)
                                  .toList();

                              final completedDocs = docs
                                  .where((d) =>
                              d['status'] ==
                                  Constant.completed)
                                  .toList();

                              final cancelledDocs = docs
                                  .where((d) =>
                              d['status'] ==
                                  Constant.canceled)
                                  .toList();

                              final total = docs.length;

                              final onGoingList =
                              controller.getOnGoingModelList(
                                activeDocs,
                                Utils.formatTimestampToIST(
                                  Timestamp.fromDate(controller
                                      .selectedDateTime.value),
                                ),
                              );

                              final upcomingList =
                              controller.getUpcomingBookings(
                                activeDocs,
                                Utils.formatTimestampToIST(
                                  Timestamp.fromDate(controller
                                      .selectedDateTime.value),
                                ),
                              );
                              return Column(
                                children: [
                                  /// BOOKING CARDS
                                  Wrap(
                                    spacing: 16,
                                    runSpacing: 16,
                                    children: [
                                      bookingDetailBox(
                                        "TotalBookings".tr,
                                        "TotalBookingicon.png",
                                        total.toString(),
                                        docs,
                                        context,
                                        controller,
                                      ),
                                      bookingDetailBox(
                                        "CompletedBookings".tr,
                                        "CompleteBookingicon.png",
                                        completedDocs.length
                                            .toString(),
                                        completedDocs,
                                        context,
                                        controller,
                                      ),
                                      bookingDetailBox(
                                        "ActiveBookings".tr,
                                        "PlacedBookingicon.png",
                                        onGoingList.length
                                            .toString(),
                                        activeDocs,
                                        context,
                                        controller,
                                      ),
                                      bookingDetailBox(
                                        "CanceledBookings".tr,
                                        "CancelBookingicon.png",
                                        cancelledDocs.length
                                            .toString(),
                                        cancelledDocs,
                                        context,
                                        controller,
                                      ),
                                      bookingDetailBox(
                                        "UpcomingBookings".tr,
                                        "CancelBookingicon.png",
                                        upcomingList.length
                                            .toString(),
                                        activeDocs,
                                        context,
                                        controller,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  /// EARNINGS
                                  Wrap(
                                    spacing: 16,
                                    runSpacing: 16,
                                    children: [
                                      totalEarningDetailBox(
                                        "TotalEarnings".tr,
                                        "CancelBookingicon.png",
                                        "\$${controller.totalEarnings.value}",
                                        context,
                                      ),
                                      totalEarningDetailBox(
                                        "MonthlyEarnings".tr,
                                        "CancelBookingicon.png",
                                        "\$${controller.monthlyEarnings.value}",
                                        context,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 32),
                                  /// CALENDAR
                                  Align(
                                    alignment: isDesktop
                                        ? Alignment.centerRight
                                        : Alignment.center,
                                    child: SizedBox(
                                      width: isDesktop ? 330 : 380,
                                      height: 300,
                                      child: buildCalendar(
                                          controller),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
                            },
                          ),
              ),
        );
      },
    );
  }

  InputDecoration _dropdownDecoration(DarkThemeProvider themeChange) {
    return InputDecoration(
      isDense: true,
      filled: true,
      fillColor: themeChange.getThem()
          ? AppThemData.grey10
          : AppThemData.grey03,
      contentPadding:
      const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  /// ✅ INCLUDED bookingDetailBox
  Widget bookingDetailBox(
      String type,
      String img,
      String count,
      List<QueryDocumentSnapshot> docs,
      BuildContext context,
      MyParkingBookingControllerOwnerForWeb controller,
      ) {
    return InkWell(
      onTap: () {
        List<OrderModel> orderList = [];
        if (type == "ActiveBookings".tr) {
          orderList = controller.getOnGoingModelList(
            docs,
            Utils.formatTimestampToIST(
              Timestamp.fromDate(controller.selectedDateTime.value),
            ),
          );
        } else if (type == "UpcomingBookings".tr) {
          orderList = controller.getUpcomingBookings(
            docs,
            Utils.formatTimestampToIST(
              Timestamp.fromDate(controller.selectedDateTime.value),
            ),
          );
        } else {
          orderList = controller.convertDocsToOrderModel(docs);
        }
        Get.to(
              () => const BookingDetailsWebScreen_Owner(),
          arguments: {"orderList": orderList},
        );
      },
      child: Container(
        width: 260,
        height: 120,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
              color: AppThemData.BookingBGColor, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Image.asset("assets/icon/$img",
                width: 50, height: 50),
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: TextStyle(
                      color: AppThemData.grey09, fontSize: 14),
                ),
                Text(
                  count,
                  style: TextStyle(
                    color: AppThemData.grey12,
                    fontSize: 26,
                    fontFamily: AppThemData.robotoBold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ INCLUDED totalEarningDetailBox
  Widget totalEarningDetailBox(
      String type,
      String img,
      String amt,
      BuildContext context,
      ) {
    return Container(
      width: 380,
      height: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
            color: AppThemData.BookingBGColor, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Image.asset("assets/icon/$img",
              width: 50, height: 50),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                type,
                style: TextStyle(
                    color: AppThemData.grey09, fontSize: 14),
              ),
              Text(
                amt,
                style: TextStyle(
                  color: AppThemData.grey12,
                  fontSize: 26,
                  fontFamily: AppThemData.robotoBold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildCalendar(
      MyParkingBookingControllerOwnerForWeb controller) {
    return Obx(() {
      return SfDateRangePicker(
        enablePastDates: false,
        controller: controller.sfDateRangePickerCtrl,
        selectionMode: DateRangePickerSelectionMode.single,
        onSelectionChanged: controller.onDateSelected,
        initialSelectedDate: controller.selectedDateTime.value,
        selectionColor: AppThemData.primary06,
        showNavigationArrow: true,
      );
    });
  }
}*/

class MyParkingBookingScreenOwnerForWeb extends StatelessWidget {
  final bool isBack;

  const MyParkingBookingScreenOwnerForWeb({required this.isBack, super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetX<MyParkingBookingControllerOwnerForWeb>(
      init: MyParkingBookingControllerOwnerForWeb(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppThemData.white,
          appBar: UiInterface().customAppBar(
            isBack: isBack,
            context,
            themeChange,
            "My Booking List".tr,
          ),
          body: controller.isLoading.value
              ? Constant.loader()
              : SingleChildScrollView(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth >= 1200;
                return Center(
                  child: ConstrainedBox(
                    constraints:
                    const BoxConstraints(maxWidth: 1400),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          /// ================= SELECT PARKING =================
                          Align(
                            alignment: isDesktop
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: SizedBox(
                              width: isDesktop ? 400 : double.infinity,
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Select Parking".tr,
                                    style: TextStyle(
                                      color: AppThemData.grey11,
                                      fontFamily:
                                      AppThemData.robotoBold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Obx(() {
                                    final hasParking =
                                        controller.parkingList.isNotEmpty;

                                    return DropdownButtonFormField<
                                        ParkingModel>(
                                      isExpanded: true,
                                      decoration:
                                      _dropdownDecoration(themeChange),
                                      value: hasParking &&
                                          controller
                                              .selectedParkingModel
                                              .value
                                              .id !=
                                              null
                                          ? controller
                                          .selectedParkingModel.value
                                          : null,
                                      hint: Text(
                                        hasParking
                                            ? "Select Parking".tr
                                            : "No Parking Available".tr,
                                        style: const TextStyle(
                                            color: Colors.grey),
                                      ),
                                      onChanged: hasParking
                                          ? (value) {
                                        controller
                                            .selectedParkingModel
                                            .value = value!;
                                      }
                                          : null,
                                      items: hasParking
                                          ? controller.parkingList
                                          .map((item) {
                                        return DropdownMenuItem<
                                            ParkingModel>(
                                          value: item,
                                          child: Text(
                                              item.name.toString()),
                                        );
                                      }).toList()
                                          : [],
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          /// ================= SUMMARY TITLE =================
                          Text(
                            "Today's Summary".tr,
                            style: TextStyle(
                              color: AppThemData.grey11,
                              fontFamily:
                              AppThemData.semiBold,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 16),
                          /// ================= SUMMARY DATA =================
                          Obx(() {
                            if (controller.parkingList.isEmpty ||
                                controller.selectedParkingModel.value.id ==
                                    null) {
                              return _zeroBookingUI(
                                  context, controller);
                            }

                            return StreamBuilder<QuerySnapshot>(
                              key: ValueKey(controller
                                  .selectedDateTime.value),
                              stream: FirebaseFirestore.instance
                                  .collection(CollectionName
                                  .bookedParkingOrder)
                                  .where(
                                'parkingId',
                                isEqualTo: controller
                                    .selectedParkingModel
                                    .value
                                    .id,
                              )
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting &&
                                    !snapshot.hasData) {
                                  return Constant.loader();
                                }

                                final docs =
                                    snapshot.data?.docs ?? [];

                                controller
                                    .checkAndAutoUpdateBookings(
                                    docs);

                                final activeDocs = docs
                                    .where((d) =>
                                d['status'] ==
                                    Constant.placed ||
                                    d['status'] ==
                                        Constant.onGoing)
                                    .toList();

                                final completedDocs = docs
                                    .where((d) =>
                                d['status'] ==
                                    Constant.completed)
                                    .toList();

                                final cancelledDocs = docs
                                    .where((d) =>
                                d['status'] ==
                                    Constant.canceled)
                                    .toList();

                                final onGoingList = controller
                                    .getOnGoingModelList(
                                  activeDocs,
                                  Utils.formatTimestampToIST(
                                    Timestamp.fromDate(controller
                                        .selectedDateTime.value),
                                  ),
                                );

                                final upcomingList = controller
                                    .getUpcomingBookings(
                                  activeDocs,
                                  Utils.formatTimestampToIST(
                                    Timestamp.fromDate(controller
                                        .selectedDateTime.value),
                                  ),
                                );

                                return _bookingUI(
                                  context,
                                  controller,
                                  docs.length,
                                  completedDocs.length,
                                  onGoingList.length,
                                  cancelledDocs.length,
                                  upcomingList.length,
                                  docs,
                                  completedDocs,
                                  activeDocs,
                                  cancelledDocs,
                                );
                              },
                            );
                          }),
                          const SizedBox(height: 32),
                          /// ================= CALENDAR =================
                          Align(
                            alignment: isDesktop
                                ? Alignment.centerRight
                                : Alignment.center,
                            child: SizedBox(
                              width: isDesktop ? 330 : 380,
                              height: 300,
                              child: buildCalendar(controller),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }


  InputDecoration _dropdownDecoration(DarkThemeProvider themeChange) {
    return InputDecoration(
      isDense: true,
      filled: true,
      fillColor: themeChange.getThem()
          ? AppThemData.grey10
          : AppThemData.grey03,
      contentPadding:
      const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }


  Widget _zeroBookingUI(
      BuildContext context,
      MyParkingBookingControllerOwnerForWeb controller,
      ) {
    return _bookingUI(
      context,
      controller,
      0,
      0,
      0,
      0,
      0,
      [],
      [],
      [],
      [],
    );
  }


  Widget _bookingUI(
      BuildContext context,
      MyParkingBookingControllerOwnerForWeb controller,
      int total,
      int completed,
      int active,
      int cancelled,
      int upcoming,
      List<QueryDocumentSnapshot> docs,
      List<QueryDocumentSnapshot> completedDocs,
      List<QueryDocumentSnapshot> activeDocs,
      List<QueryDocumentSnapshot> cancelledDocs,
      ) {
    return Column(
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            bookingDetailBox(
              "TotalBookings".tr,
              "TotalBookingicon.png",
              total.toString(),
              docs,
              context,
              controller,
            ),
            bookingDetailBox(
              "CompletedBookings".tr,
              "CompleteBookingicon.png",
              completed.toString(),
              completedDocs,
              context,
              controller,
            ),
            bookingDetailBox(
              "ActiveBookings".tr,
              "PlacedBookingicon.png",
              active.toString(),
              activeDocs,
              context,
              controller,
            ),
            bookingDetailBox(
              "CanceledBookings".tr,
              "CancelBookingicon.png",
              cancelled.toString(),
              cancelledDocs,
              context,
              controller,
            ),
            bookingDetailBox(
              "UpcomingBookings".tr,
              "CancelBookingicon.png",
              upcoming.toString(),
              activeDocs,
              context,
              controller,
            ),
          ],
        ),

        const SizedBox(height: 24),

        /// ================= EARNINGS =================
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            totalEarningDetailBox(
              "TotalEarnings".tr,
              "CancelBookingicon.png",
              "\$${controller.totalEarnings.value}",
              context,
            ),
            totalEarningDetailBox(
              "MonthlyEarnings".tr,
              "CancelBookingicon.png",
              "\$${controller.monthlyEarnings.value}",
              context,
            ),
          ],
        ),
      ],
    );
  }


  Widget buildCalendar(
      MyParkingBookingControllerOwnerForWeb controller) {
    return Obx(() {
      return SfDateRangePicker(
        enablePastDates: false,
        controller: controller.sfDateRangePickerCtrl,
        selectionMode: DateRangePickerSelectionMode.single,
        onSelectionChanged: controller.onDateSelected,
        initialSelectedDate: controller.selectedDateTime.value,
        selectionColor: AppThemData.primary06,
        showNavigationArrow: true,
      );
    });
  }


  Widget bookingDetailBox(
      String type,
      String img,
      String count,
      List<QueryDocumentSnapshot> docs,
      BuildContext context,
      MyParkingBookingControllerOwnerForWeb controller,
      ) {
    return InkWell(
      onTap: () {
        List<OrderModel> orderList = [];

        if (type == "ActiveBookings".tr) {
          orderList = controller.getOnGoingModelList(
            docs,
            Utils.formatTimestampToIST(
              Timestamp.fromDate(controller.selectedDateTime.value),
            ),
          );
        } else if (type == "UpcomingBookings".tr) {
          orderList = controller.getUpcomingBookings(
            docs,
            Utils.formatTimestampToIST(
              Timestamp.fromDate(controller.selectedDateTime.value),
            ),
          );
        } else {
          orderList = controller.convertDocsToOrderModel(docs);
        }

        Get.to(
              () => const BookingDetailsWebScreen_Owner(),
          arguments: {"orderList": orderList},
        );
      },
      child: Container(
        width: 260,
        height: 120,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppThemData.BookingBGColor,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Image.asset(
              "assets/icon/$img",
              width: 50,
              height: 50,
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: TextStyle(
                    color: AppThemData.grey09,
                    fontSize: 14,
                  ),
                ),
                Text(
                  count,
                  style: TextStyle(
                    color: AppThemData.grey12,
                    fontSize: 26,
                    fontFamily: AppThemData.robotoBold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }



  Widget totalEarningDetailBox(
      String type,
      String img,
      String amt,
      BuildContext context,
      ) {
    return Container(
      width: 380,
      height: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppThemData.BookingBGColor,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Image.asset(
            "assets/icon/$img",
            width: 50,
            height: 50,
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                type,
                style: TextStyle(
                  color: AppThemData.grey09,
                  fontSize: 14,
                ),
              ),
              Text(
                amt,
                style: TextStyle(
                  color: AppThemData.grey12,
                  fontSize: 26,
                  fontFamily: AppThemData.robotoBold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


}




