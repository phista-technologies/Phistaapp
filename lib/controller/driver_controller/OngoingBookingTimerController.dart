
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:phista/utils/fire_store_utils.dart';
import '../../model/order_model.dart';
import '../../model/parking_model.dart';

class OngoingBookingTimerController extends GetxController {
  RxBool isLoading = true.obs;
  RxDouble progress = 1.0.obs;
  RxString remainingTime = "00:00:00".obs;

  Rx<OrderModel> orderModel = OrderModel().obs;

  Timer? _timer;

  @override
  void onInit() {
    getArgument();
    super.onInit();
  }

  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      orderModel.value = argumentData['orderModel'];
      startTimer();
    }
    isLoading.value = false;
    update();
  }


  void startTimer() {
    String? bookingDate = orderModel.value.bookingDate;
    String bookingType = orderModel.value.bookingType ?? "";
    print("bookingType:-- $bookingType");
    if (bookingType == "3") {
      _startMonthlyTimer(bookingDate);
    } else {
      _startDailyTimer();
    }
  }

  /// -------------------------
  /// DAILY BOOKING TIMER
  /// -------------------------
  void _startDailyTimer() {
    Timestamp? start = orderModel.value.bookingStartTime;
    Timestamp? end = orderModel.value.bookingEndTime;

    if (start == null || end == null) return;

    DateTime startTime = start.toDate();
    DateTime endTime = end.toDate();

    Duration totalDuration = endTime.difference(startTime);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      DateTime now = DateTime.now();

      if (now.isAfter(endTime)) {
        progress.value = 0;
        remainingTime.value = "00:00:00";
        timer.cancel();
        return;
      }

      Duration remaining = endTime.difference(now);
      Duration passed = now.difference(startTime);

      progress.value = passed.inSeconds / totalDuration.inSeconds;
      remainingTime.value = _formatDuration(remaining);
    });
  }

  /// -------------------------
  /// MONTHLY BOOKING TIMER
  /// -------------------------
  void _startMonthlyTimer(String? bookingDate) {
    if (bookingDate == null || bookingDate.isEmpty) return;

    List<String> parts = bookingDate.split(",");
    if (parts.length != 2) return;

    DateTime cycleStart = parseCustomDateTime(parts[0].trim());
    DateTime cycleEnd   = parseCustomDateTime(parts[1].trim());

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      DateTime now = DateTime.now();

      if (now.isAfter(cycleEnd)) {
        progress.value = 1.0;
        remainingTime.value = "0 Days";
        timer.cancel();
        return;
      }

      /// normalize to remove hours & minutes
      DateTime today = DateTime(now.year, now.month, now.day);
      DateTime startDate = DateTime(cycleStart.year, cycleStart.month, cycleStart.day);
      DateTime endDate   = DateTime(cycleEnd.year, cycleEnd.month, cycleEnd.day);

      int totalDays = endDate.difference(startDate).inDays;
      int passedDays = today.difference(startDate).inDays;
      int remainingDays = endDate.difference(today).inDays;

      progress.value = passedDays / totalDays;

      remainingTime.value = "$remainingDays Days";
    });
  }



  DateTime parseCustomDateTime(String input) {
    final parts = input.split(" UTC");

    final datePart = parts[0].trim(); // "5 September 2025 at 00:00:00"
    final offsetPart = parts.length > 1 ? parts[1].trim() : "+00:00"; // "+5:30"

    final dateFormat = DateFormat("d MMMM y 'at' HH:mm:ss");
    DateTime baseTime = dateFormat.parse(datePart, true).toUtc(); // UTC time

    final sign = offsetPart.startsWith('-') ? -1 : 1;
    final offsetClean = offsetPart.replaceAll(RegExp(r'[+-]'), '');
    final offsetParts = offsetClean.split(":");

    final offsetHours = int.parse(offsetParts[0]) * sign;
    final offsetMinutes = int.parse(offsetParts[1]) * sign;

    final totalOffset = Duration(hours: offsetHours, minutes: offsetMinutes);
    return baseTime.add(totalOffset); // return time adjusted to the correct UTC offset
  }

  /// Convert "29 September 2025 at 09:30:00 UTC+5:30"
  /// to ISO format, so DateTime.parse() works.
  String _convertToISO(String input) {
    return input
        .replaceAll(" at ", "T")
        .replaceAll(" ", "-")
        .replaceAll("UTC", "");
  }



  /// Format HH:MM:SS
  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(d.inHours)}:"
        "${twoDigits(d.inMinutes.remainder(60))}:"
        "${twoDigits(d.inSeconds.remainder(60))}";
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}

