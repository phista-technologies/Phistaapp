import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../constant/collection_name.dart';
import '../constant/constant.dart';
import '../utils/fire_store_utils.dart';

class BookingController extends GetxController {

  RxInt selectedTabIndex = 0.obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
  print("Booking controller");
    super.onInit();
    _checkAndUpdateExpiredBookings();
  }

  void _checkAndUpdateExpiredBookings() async {
    final now = DateTime.now();

    final querySnapshot = await FirebaseFirestore.instance
        .collection(CollectionName.bookedParkingOrder)
        .where("userId", isEqualTo: FireStoreUtils.getCurrentUid())
        .orderBy("createdAt", descending: true)
        .get();

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final status = data['status'];
      final Timestamp bookedEndTime = data['bookingEndTime'];

      if (status != Constant.completed &&
          bookedEndTime.toDate().isBefore(DateTime.now())) {
        await doc.reference.update({'status': Constant.completed});
      }
    }
  }

}
