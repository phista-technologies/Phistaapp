import 'package:get/get.dart';

import '../../constant/constant.dart';
import '../../model/user_model.dart';
import '../../ui/owner/parking_add/my_parking_booking_screen_owner.dart';
import '../../ui/owner/parking_add/my_parking_list_owner.dart';
import '../../ui/owner/profile/profile_screen_owner.dart';
import '../../ui/owner/wallet/wallet_screen_owner.dart';
import '../../utils/fire_store_utils.dart';


class DashboardScreenControllerOwner extends GetxController {
  RxInt selectedIndex = 1.obs;

  Rx<UserModel> userModel = UserModel().obs;

  RxList pageList = [
    const MyParkingBooingScreenOwner(isBack: false),
    const MyParkingListOwner(isBack: false),
    const WalletScreenOwner(isBack: false),
    const ProfileScreenOwner(),
  ].obs;

  @override
  void onInit() {
    super.onInit();
    getData();
  }

  getData() async {
    await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid())
        .then((value) {
      if (value != null) {
        userModel.value = value;
        updateLastLoginType();

      }
    });
  }

  Future<void> updateLastLoginType() async {
    userModel.update((val) {
      val?.lastLoginType = Constant.roleTypeForOwner;
    });
    await FireStoreUtils.updateUser(userModel.value);
  }

}
