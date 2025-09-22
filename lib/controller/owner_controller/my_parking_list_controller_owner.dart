import 'package:get/get.dart';


import '../../model/parking_model.dart';
import '../../model/user_model.dart';
import '../../utils/fire_store_utils.dart';

class MyParkingListControllerOwner extends GetxController {
  RxBool isLoading = true.obs;
  RxList<ParkingModel> parkingList = <ParkingModel>[].obs;
  Rx<UserModel> userModel = UserModel().obs;


  /*getData() async {
    isLoading.value = true;

    userModel.value = await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid()) ?? UserModel();

    final list = await FireStoreUtils.getMyParkingList();

    if (list != null) {
      for (var item in list) {
        item.isBusy = await FireStoreUtils.parkingBookedOrNot(item.id); // ✅ check busy status
      }

      parkingList.value = list;
    }

    isLoading.value = false;
  }*/

  getData() async {
    userModel.value = await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid()) ?? UserModel();
    final list = await FireStoreUtils.getMyParkingListOwner();
    await FireStoreUtils.getMyParkingListOwner().then((value) {
      if (value != null) {
        parkingList.value = value;
      }
    });
    isLoading.value = false;
  }

  @override
  void onInit() {
    getData();
    super.onInit();
  }
}
