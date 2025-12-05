
import 'package:get/get.dart';
import '../../model/order_model.dart';

class BookingDetails_Web_Controller_Owner extends GetxController {

  RxList<OrderModel> showOrderModelList = <OrderModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    getArgument();

  }
  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      if (argumentData != null) {
        showOrderModelList.value = List<OrderModel>.from(argumentData['orderList']);
      }
      print("showOrderModelList:-${showOrderModelList.value.length}");
    }
    update();
  }


}

