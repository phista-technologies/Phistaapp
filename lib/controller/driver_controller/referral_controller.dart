import 'package:get/get.dart';
import 'package:phista/model/referral_model.dart';
import 'package:phista/utils/fire_store_utils.dart';

import '../../constant/constant.dart';

class ReferralController extends GetxController {
  @override
  void onInit() {
    getReferralCode();
    super.onInit();
  }

  Rx<ReferralModel> referralModel = ReferralModel().obs;
  RxBool isLoading = true.obs;

  getReferralCode() async {
    await FireStoreUtils.getReferral().then((value) async {
      if (value != null) {
        referralModel.value = value;
        isLoading.value = false;
      }else{
        ReferralModel referralModel = ReferralModel(
            id: FireStoreUtils.getCurrentUid(),
            referralBy: "",
            referralCode: Constant.getReferralCode());
        await FireStoreUtils.referralAdd(referralModel);
      }

    });
  }
}
