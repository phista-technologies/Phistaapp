import 'package:get/get.dart';
import 'package:phista/model/referral_model.dart';
import 'package:phista/utils/fire_store_utils.dart';

class ReferralController extends GetxController {
  @override
  void onInit() {
    // TODO: implement onInit
    getReferralCode();
    super.onInit();
  }

  Rx<ReferralModel> referralModel = ReferralModel().obs;
  RxBool isLoading = true.obs;

  getReferralCode() async {
    await FireStoreUtils.getReferral().then((value) {
      if (value != null) {
        referralModel.value = value;
        isLoading.value = false;
      }
    });
  }
}
