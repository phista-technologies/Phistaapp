import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../constant/collection_name.dart';
import '../../constant/constant.dart';
import '../../constant/show_toast_dialog.dart';
import '../../model/order_model.dart';
import '../../model/parking_model.dart';
import '../../model/user_model.dart';
import '../../model/wallet_transaction_model.dart';
import '../../utils/fire_store_utils.dart';

class MyParkingBookingControllerOwner extends GetxController {
  RxBool isLoading = true.obs;

  Rx<ParkingModel> selectedParkingModel = ParkingModel().obs;
  RxList<ParkingModel> parkingList = <ParkingModel>[].obs;
  Rx<DateTime> selectedDateTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).obs;
  RxList<OrderModel> onGoingOrderList = <OrderModel>[].obs;
  RxList<OrderModel> completedOrderList = <OrderModel>[].obs;
  RxList<OrderModel> cancelOrderList = <OrderModel>[].obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getData();
    super.onInit();
  }

  RxInt selectedTabIndex = 0.obs;

  getData() async {
    await FireStoreUtils.getMyParkingListOwner().then((value) {
      if (value != null) {
        parkingList.value = value;
        if (parkingList.isNotEmpty) {
          selectedParkingModel.value = parkingList.first;
        }
        print("selectedParkingModel${selectedParkingModel.value.id}");
      }
    });
    isLoading.value = false;
    update();
  }

  confirmPayment(OrderModel orderModel) async {
    RxDouble couponAmount = 0.0.obs;
    ShowToastDialog.showLoader("Please wait..");
    if (orderModel.coupon != null) {
      if (orderModel.coupon!.id != null) {
        if (orderModel.coupon!.type == "fix") {
          couponAmount.value = double.parse(orderModel.coupon!.amount.toString());
        } else {
          couponAmount.value = double.parse(orderModel.subTotal.toString()) * double.parse(orderModel.coupon!.amount.toString()) / 100;
        }
      }
    }
    orderModel.paymentCompleted = true;

    if (Constant.adminCommission?.enable == true) {
      UserModel? userModel = await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid());
      orderModel.adminCommission = Constant.adminCommission;
    }

    WalletTransactionModel adminCommissionWallet = WalletTransactionModel(
        id: Constant.getUuid(),
        amount:
            "-${Constant.calculateAdminCommission(amount: (double.parse(orderModel.subTotal.toString()) - double.parse(couponAmount.toString())).toString(), adminCommissionLocal: orderModel.adminCommission)}",
        createdDate: Timestamp.now(),
        paymentType: orderModel.paymentType.toString(),
        transactionId: orderModel.id,
        isCredit: false,
        userId: orderModel.parkingDetails!.userId.toString(),
        note: "Admin commission debited");

    await FireStoreUtils.setWalletTransaction(adminCommissionWallet).then((value) async {
      if (value == true) {
        await FireStoreUtils.updateUserWallet(
          amount:
              "-${Constant.calculateAdminCommission(amount: (double.parse(orderModel.subTotal.toString()) - double.parse(couponAmount.toString())).toString(), adminCommissionLocal: orderModel.adminCommission)}",
        );
      }
    });

    await FireStoreUtils.setOrder(orderModel).then((value) {
      if (value == true) {
        ShowToastDialog.closeLoader();
      }
    });
  }


  RxList<OrderModel> getOnGoingModelList(List<QueryDocumentSnapshot> docs,String selectedDate){
    RxList<OrderModel> tempOrderList = <OrderModel>[].obs;
     print("selectedDate :-- $selectedDate");
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


  void checkAndAutoUpdateBookings(List<QueryDocumentSnapshot> docs) {
    for (var doc in docs) {

      final data = doc.data() as Map<String, dynamic>;

        final bookingEndTime = (data['bookingEndTime'] as Timestamp).toDate();
        final status = data['status'];

        if (bookingEndTime.isBefore(DateTime.now()) && status != Constant.completed) {
          FirebaseFirestore.instance
              .collection(CollectionName.bookedParkingOrder)
              .doc(doc.id)
              .update({'status': Constant.completed});
        }



    }
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

}
