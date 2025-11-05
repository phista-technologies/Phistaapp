import 'dart:developer';

import 'package:get/get.dart';
import 'package:phista/ui/driver/chat/inbox_screen.dart';


import '../../constant/constant.dart';
import '../../model/user_model.dart';
import '../../ui/driver/home/home_screen.dart';
import '../../ui/driver/my_booking/my_booking_screen.dart';
import '../../ui/driver/profile/profile_screen.dart';
import '../../ui/driver/saved/saved_screen.dart';
import '../../utils/fire_store_utils.dart';


class DashboardScreenController extends GetxController {
  RxInt selectedIndex = 0.obs;
  Rx<UserModel> userModel = UserModel().obs;

  RxList pageList = [
    const HomeScreen(),
    const SavedScreen(),
    const MyBookingScreen(isBack: false),
    const InboxScreen(),
    const ProfileScreen(),
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

  /*updateLastLoginType(){
    UserModel userModelData = userModel.value;
    userModelData.lastLoginType = Constant.roleTypeForCustomer;
    FireStoreUtils.updateUser(userModelData).then(
          (value) {

        update();
      },
    );

  }*/

  Future<void> updateLastLoginType() async {
    userModel.update((val) {
      val?.lastLoginType = Constant.roleTypeForCustomer;
    });
    await FireStoreUtils.updateUser(userModel.value);
  }

}
