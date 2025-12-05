
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../constant/constant.dart';
import '../../../controller/owner_controller/BookingDetailsWebController_Owner.dart';
import '../../../model/order_model.dart';
import '../../../themes/app_them_data.dart';
import '../../../themes/common_ui.dart';
import '../../../utils/dark_theme_provider.dart';


class BookingDetailsWebScreen_Owner extends StatelessWidget {
  const BookingDetailsWebScreen_Owner({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetX(
        init: BookingDetails_Web_Controller_Owner(),
        builder: (controller) {
          return Scaffold(
            appBar: UiInterface()
                .customAppBar(context, themeChange, "Booking Detail".tr),
            body: controller.isLoading.value
                ? Constant.loader()
                : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildBookingTable(controller),
                ],
              ),
            ),
          );
        });
  }

  // -------------------------------------------------------------------------
  // TABLE WIDGET
  // -------------------------------------------------------------------------
  Widget buildBookingTable(BookingDetails_Web_Controller_Owner controller) {
    const int columnCount = 9; // 9 columns in header

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            spreadRadius: 2,
          )
        ],
      ),
      child: Table(
        border: TableBorder.all(color: Colors.grey.shade300),
        columnWidths: const {
          0: FlexColumnWidth(1.2),
          1: FlexColumnWidth(2),
          2: FlexColumnWidth(2),
          3: FlexColumnWidth(2),
          4: FlexColumnWidth(1.5),
          5: FlexColumnWidth(1.5),
          6: FlexColumnWidth(2),
          7: FlexColumnWidth(1.5),
          8: FlexColumnWidth(1.4),
        },
        children: [
          _tableHeaderRow(),
          // ------------------ FIXED "NO RECORD FOUND" ROW -------------------
          if (controller.showOrderModelList.isEmpty)
            TableRow(
              children: List.generate(columnCount, (index) {
                if (index == (columnCount ~/ 2)) {
                  return Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Center(
                      child: Text(
                        "No Record Found",
                        style: TextStyle(
                          color: AppThemData.grey07,
                          fontSize: 14,
                          fontFamily: AppThemData.robotoSemiBold,
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox(); // empty cells
              }),
            ),
          // ------------------ DATA ROWS -------------------
          ...controller.showOrderModelList.map((order) {
            return _tableDataRow(order);
          }).toList()
        ],
      ),
    );
  }
  // -------------------------------------------------------------------------
  // TABLE HEADER
  // -------------------------------------------------------------------------
  TableRow _tableHeaderRow() {
    return TableRow(
      decoration: BoxDecoration(color: Colors.grey.shade200),
      children: [
        _headerCell("Booking Id"),
        _headerCell("Booked By"),
        _headerCell("Parking"),
        _headerCell("Date & Time"),
        _headerCell("Duration"),
        _headerCell("Slot"),
        _headerCell("Amount"),
        _headerCell("Created At"),
        _headerCell("Status"),
      ],
    );
  }

  Widget _headerCell(String title) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        title,
        style: TextStyle(
          color: AppThemData.black,
          fontSize: 14,
          fontFamily: AppThemData.robotoExtraBold,
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // TABLE DATA ROW
  // -------------------------------------------------------------------------
  TableRow _tableDataRow(OrderModel order) {
    return TableRow(
      children: [
        _dataCell(order.id ?? "-"),
        _dataCell(order.userVehicle?.vehicleNumber ?? "-"),
        _dataCell(order.parkingDetails?.name ?? "-"),
        _dataCell(
          "${order.bookingDate ?? ''} "
              "${order.bookingStartTime != null ? order.bookingStartTime!.toDate() : ''}",
        ),
        _dataCell(order.duration ?? "-"),
        _dataCell(order.parkingSlotId ?? "-"),
        _dataCell(order.subTotal ?? "-"),
        _dataCell(order.createdAt != null
            ? order.createdAt!.toDate().toString()
            : "-"),
        _dataCell(order.status ?? "-"),
      ],
    );
  }

  Widget _dataCell(String value) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        value,
        style: TextStyle(
          color: AppThemData.grey07,
          fontSize: 14,
          fontFamily: AppThemData.robotoSemiBold,
        ),
      ),
    );
  }
}




