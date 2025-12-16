
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../constant/collection_name.dart';
import '../../constant/constant.dart';
import '../../constant/show_toast_dialog.dart';
import '../../model/order_model.dart';
import '../../model/parking_model.dart';
import '../../model/user_model.dart';
import '../../model/wallet_transaction_model.dart';
import '../../utils/debouncer.dart';
import '../../utils/fire_store_utils.dart';
import '../../utils/utils.dart';
class MyParkingBookingControllerOwnerForWeb extends GetxController {
  RxBool isLoading = false.obs;
  Rx<ParkingModel> selectedParkingModel = ParkingModel().obs;
  RxList<ParkingModel> parkingList = <ParkingModel>[].obs;
  Rx<DateTime> selectedDateTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).obs;
  DateRangePickerController sfDateRangePickerCtrl = DateRangePickerController();
  var totalEarnings = 0.0.obs;
  var monthlyEarnings = 0.0.obs;


  /*
  RxList<OrderModel> onGoingOrderList = <OrderModel>[].obs;
  RxList<OrderModel> completedOrderList = <OrderModel>[].obs;
  RxList<OrderModel> cancelOrderList = <OrderModel>[].obs;
  Rx<TextEditingController> searchControllerOnGoing = TextEditingController().obs;
  Rx<TextEditingController> searchControllerComplete = TextEditingController().obs;
  Rx<TextEditingController> searchControllerCancel = TextEditingController().obs;
  RxList<OrderModel> filteredOnGoingList = <OrderModel>[].obs;
  RxList<OrderModel> filteredOnCompleteList = <OrderModel>[].obs;
  RxList<OrderModel> filteredOnCancelList = <OrderModel>[].obs;
  final debouncer = Debouncer(milliseconds: 1000);*/


  @override
  void onInit() {
    // TODO: implement onInit
    getData();
    sfDateRangePickerCtrl.selectedDate = selectedDateTime.value;
    super.onInit();
  }

  RxInt selectedTabIndex = 0.obs;
  void onDateSelected(DateRangePickerSelectionChangedArgs args) {
    if (args.value is DateTime) {
      selectedDateTime.value = args.value;
      print("Selected date → ${selectedDateTime.value}");
    }
  }
  getData() async {
    await FireStoreUtils.getMyParkingListOwner().then((value) {
      if (value != null) {
        parkingList.value = value;
        if (parkingList.isNotEmpty) {
          selectedParkingModel.value = parkingList.first;
        }
        getParkingMonthlyEarnings(
          selectedParkingModel.value.id!,
          selectedDateTime.value,
        );
        print("selectedParkingModel${selectedParkingModel.value.id}");
        fetchTotalEarnings();
      }
    });

    isLoading.value = false;
    update();
  }

  Stream<QuerySnapshot> bookingSummaryStream() {
    return FirebaseFirestore.instance
        .collection(CollectionName.bookedParkingOrder)
        .where('parkingId', isEqualTo: selectedParkingModel.value.id)
        //.where('bookingDate', isEqualTo: Utils.formatTimestampToIST(Timestamp.fromDate(selectedDateTime.value)))
        .snapshots();
  }
  void fetchTotalEarnings() async {
    final snapshot = await FirebaseFirestore.instance
        .collection(CollectionName.bookedParkingOrder)
        .where('parkingId', isEqualTo: selectedParkingModel.value.id)
        .get();

    double total = 0.0;
    for (var doc in snapshot.docs) {
      total += double.tryParse(doc['subTotal'].toString()) ?? 0.0;
    }

    totalEarnings.value = total;  // UI auto-updates
  }

  void getParkingMonthlyEarnings(String parkingId, DateTime date) async {
    print("start");

    final monthStart = DateTime(date.year, date.month, 1);
    final monthEnd = DateTime(date.year, date.month + 1, 1);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(CollectionName.bookedParkingOrder)
          .where('parkingId', isEqualTo: parkingId)
          .get();

      double total = 0.0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final createdAt = (data['createdAt'] as Timestamp).toDate();

        // Normalize timestamps (remove time)
        final createdDateOnly = DateTime(createdAt.year, createdAt.month, createdAt.day);
        final monthStartOnly = DateTime(monthStart.year, monthStart.month, monthStart.day);
        final monthEndOnly = DateTime(monthEnd.year, monthEnd.month, monthEnd.day);

        // Final strict month check
        if (createdDateOnly.isAtSameMomentAs(monthStartOnly) ||
            (createdDateOnly.isAfter(monthStartOnly) && createdDateOnly.isBefore(monthEndOnly))) {
          total += double.tryParse(data['subTotal'].toString()) ?? 0.0;
        }
      }
      print("total:--> $total");
      monthlyEarnings.value = total;

    } catch (e) {
      print("Error in monthly earnings: $e");
    }
  }

  RxList<OrderModel> getOnGoingModelList(List<QueryDocumentSnapshot> docs,String selectedDate){
    RxList<OrderModel> tempOrderList = <OrderModel>[].obs;
    print("selectedDate :-- $selectedDate");
    fetchTotalEarnings();
    getParkingMonthlyEarnings(
      selectedParkingModel.value.id!,
      selectedDateTime.value,
    );
    for(var tempData in docs){
      final data = tempData.data();
      final bookingDateString = (data as Map)['bookingDate'] ?? '';
      print("bookingDateString :-- $bookingDateString");
      if((data)['bookingType'].toString() == "1" && selectedDate.toString() == bookingDateString.toString()){
        tempOrderList.add(OrderModel.fromJson(tempData.data() as Map<String, dynamic>));
      }else if((data)['bookingType'].toString() == "3"){
        List<String> bookingParts = bookingDateString.split(',');
        if(bookingParts.length >1){
          var isExist = isSelectedDateInRange(selectedDate,bookingParts[0],bookingParts[1]);
          print("isExist :-- $isExist");
          if(isExist){
            tempOrderList.add(OrderModel.fromJson(tempData.data() as Map<String, dynamic>));
          }
        }
      }
    }
    print("tempOrderList :-- ${tempOrderList.length}");
    for(var value in tempOrderList){
      print("booking Type :-- ${value.bookingType}");
    }
    return tempOrderList;
  }

  RxList<OrderModel> getUpcomingBookings(List<QueryDocumentSnapshot> docs, String selectedDate) {

    RxList<OrderModel> tempOrderList = <OrderModel>[].obs;

    for (var tempData in docs) {
      final data = tempData.data() as Map<String, dynamic>;
      final bookingDateString = data['bookingDate'] ?? '';
      final bookingType = data['bookingType'].toString();

      // Single-day booking
      if (bookingType == "1") {
        // FUTURE date only
        if (bookingDateString.compareTo(selectedDate) > 0) {
          tempOrderList.add(OrderModel.fromJson(data));
        }
      }

      // Date-range bookings
      else if (bookingType == "3") {
        List<String> bookingParts = bookingDateString.split(',');

        if (bookingParts.length > 1) {
          String startDate = bookingParts[0];
          String endDate = bookingParts[1];

          // selectedDate < startDate  → Upcoming
          if (selectedDate.compareTo(startDate) < 0) {
            tempOrderList.add(OrderModel.fromJson(data));
          }
        }
      }
    }

    return tempOrderList;
  }

  List<OrderModel> convertDocsToOrderModel(List<QueryDocumentSnapshot> docs) {
    return docs
        .map((d) => OrderModel.fromJson(d.data() as Map<String, dynamic>))
        .toList();
  }


  bool isSelectedDateInRange(String selectedDateString,String startDateString,String endDateString){
    selectedDateString.replaceAll("UTC", "").trim();
    DateFormat format = DateFormat("dd MMMM yyyy 'at' HH:mm:ss");
    DateTime selectedDate = format.parse(selectedDateString);
    startDateString.replaceAll("UTC", "").trim();
    DateTime startDate =format.parse(startDateString);
    endDateString.replaceAll("UTC", "").trim();
    DateTime endDate = format.parse(endDateString);
    if (selectedDate.isAfter(startDate.subtract(Duration(days: 1))) && selectedDate.isBefore(endDate.add(Duration(days: 1)))) {
      print("The selected date is between the start and end date.");
      return true;
    } else {
      print("The selected date is NOT between the start and end date.");
      return false;
    }
  }

  void checkAndAutoUpdateBookings(List<QueryDocumentSnapshot> docs) {
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final status = data['status'];
      final bookingType = data["bookingType"].toString();

      try {
        if (bookingType == "1") {
          //  Hourly Booking
          final bookingEndTime = (data['bookingEndTime'] as Timestamp).toDate();

          if (bookingEndTime.isBefore(DateTime.now()) &&
              status != Constant.completed) {
            FirebaseFirestore.instance
                .collection(CollectionName.bookedParkingOrder)
                .doc(doc.id)
                .update({'status': Constant.completed});
          }
        } else if (bookingType == "3") {
          //  Monthly Booking
          final bookingDateString = data['bookingDate']?.toString() ?? "";
          DateTime? endDate;

          if (bookingDateString.contains(',')) {
            final parts = bookingDateString.split(',');
            if (parts.length >= 2) {
              try {
                endDate = DateFormat("d MMMM yyyy 'at' HH:mm:ss 'UTC'Z")
                    .parseUtc(parts[1].trim())
                    .toLocal();
              } catch (error) {
                print(' Error parsing monthly booking date: $error');
              }
            }
          }

          if (endDate != null &&
              endDate.isBefore(DateTime.now()) &&
              status != Constant.completed) {
            FirebaseFirestore.instance
                .collection(CollectionName.bookedParkingOrder)
                .doc(doc.id)
                .update({'status': Constant.completed});
          }
        }
      } catch (e) {
        print(' Error processing booking ${doc.id}: $e');
      }
    }
  }

  


}