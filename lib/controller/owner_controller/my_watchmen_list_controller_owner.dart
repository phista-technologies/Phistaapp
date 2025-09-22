import 'package:get/get.dart';

import '../../model/user_model.dart';
import '../../utils/fire_store_utils.dart';


class MyWatchmenListControllerOwner extends GetxController {
  RxBool isLoading = true.obs;
  RxList<UserModel> watchmen = <UserModel>[].obs;

  getData() async {
    await FireStoreUtils.getWatchmenList().then((value) {
      if (value != null) {
        watchmen.value = value;
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
