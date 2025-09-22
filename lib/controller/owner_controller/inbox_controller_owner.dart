import 'package:get/get.dart';

import '../../model/user_model.dart';
import '../../utils/fire_store_utils.dart';


class InboxControllerOwner extends GetxController {
  RxBool isLoading = true.obs;
  Rx<UserModel> senderUserModel = UserModel().obs;

  @override
  void onInit() {
    getUser();
    super.onInit();
  }

  getUser() async {
    await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid()).then((value) {
      senderUserModel.value = value!;
      print("senderUserModel.value${senderUserModel.value.id}");
    });
    isLoading.value = false;
  }
}
