import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_dart_scan/qr_code_dart_scan.dart';

import '../../../constant/collection_name.dart';
import '../../../constant/constant.dart';
import '../../../constant/show_toast_dialog.dart';
import '../../../model/order_model.dart';
import '../../../themes/common_ui.dart';
import '../../../utils/dark_theme_provider.dart';
import '../../../utils/fire_store_utils.dart';
import '../after_scanned/after_scanned_screen_owner.dart';
import '../after_scanned/early_arrive_screen_owner.dart';


class QrCodeScanScreenOwner extends StatelessWidget {
  final String? orderId;

  const QrCodeScanScreenOwner({super.key, this.orderId});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Scaffold(
      appBar: UiInterface().customAppBar(context, themeChange, 'Scan QR code'.tr),
      body: QRCodeDartScanView(
        scanInvertedQRCode: true, // enable scan invert qr code ( default = false)
        typeScan: TypeScan.live, // if TypeScan.takePicture will try decode when click to take a picture(default TypeScan.live)
        onCapture: (Result result) async {
          Get.back();

          if (orderId == null) {
            ShowToastDialog.showLoader("Please wait".tr);
            await FireStoreUtils.fireStore.collection(CollectionName.bookedParkingOrder).doc(result.text).get().then((value) async {
              OrderModel orderModel = OrderModel.fromJson(value.data()!);
              ShowToastDialog.closeLoader();
              if (orderModel.parkingDetails!.userId != FireStoreUtils.getCurrentUid()) {
                ShowToastDialog.showToast("Invalid QR code".tr);
              } else if (orderModel.status == Constant.completed) {
                ShowToastDialog.showToast("This booking already completed".tr);
              } else if (orderModel.status == Constant.onGoing) {
                ShowToastDialog.showToast("This Order already scanned".tr);
              } else if (DateTime.now().isBefore(orderModel.bookingStartTime!.toDate())) {
                Get.to(() => const EarlyArriveScreenOwner(), arguments: {"orderModel": orderModel});
              } else {
                Get.to(() => const AfterScannedScreenOwner(), arguments: {"orderModel": orderModel});
              }
            });
            debugPrint('Barcode found! ${result.text}'.tr);
          } else {
            if (orderId == result.text) {
              await FireStoreUtils.fireStore.collection(CollectionName.bookedParkingOrder).doc(result.text).get().then((value) async {
                OrderModel orderModel = OrderModel.fromJson(value.data()!);
                ShowToastDialog.closeLoader();
                if (orderModel.parkingDetails!.userId != FireStoreUtils.getCurrentUid()) {
                  ShowToastDialog.showToast("Invalid QR code".tr);
                } else if (orderModel.status == Constant.completed) {
                  ShowToastDialog.showToast("This booking already completed".tr);
                } else if (orderModel.status == Constant.onGoing) {
                  ShowToastDialog.showToast("This Order already scanned".tr);
                } else if (DateTime.now().isBefore(orderModel.bookingStartTime!.toDate())) {
                  Get.to(() => const EarlyArriveScreenOwner(), arguments: {"orderModel": orderModel});
                } else {
                  Get.to(() => const AfterScannedScreenOwner(), arguments: {"orderModel": orderModel});
                }
              });
            } else {
              ShowToastDialog.showToast("Invalid QR code".tr);
            }
          }
        },
      ),
      // body: MobileScanner(
      //   // fit: BoxFit.contain,
      //   onDetect: (capture) async {
      //     final List<Barcode> barcodes = capture.barcodes;
      //     final Uint8List? image = capture.image;
      //     for (final barcode in barcodes) {
      //       Get.back();
      //
      //       if (orderId == null) {
      //         ShowToastDialog.showLoader("Please wait".tr);
      //         await FireStoreUtils.fireStore.collection(CollectionName.bookedParkingOrder).doc(barcode.rawValue).get().then((value) async {
      //           OrderModel orderModel = OrderModel.fromJson(value.data()!);
      //           ShowToastDialog.closeLoader();
      //           if (orderModel.parkingDetails!.userId != FireStoreUtils.getCurrentUid()) {
      //             ShowToastDialog.showToast("Invalid QR code".tr);
      //           } else if (orderModel.status == Constant.completed) {
      //             ShowToastDialog.showToast("This booking already completed".tr);
      //           } else if (orderModel.status == Constant.onGoing) {
      //             ShowToastDialog.showToast("This Order already scanned".tr);
      //           } else if (DateTime.now().isBefore(orderModel.bookingStartTime!.toDate())) {
      //             Get.to(() => const EarlyArriveScreen(), arguments: {"orderModel": orderModel});
      //           } else {
      //             Get.to(() => const AfterScannedScreen(), arguments: {"orderModel": orderModel});
      //           }
      //         });
      //         debugPrint('Barcode found! ${barcode.rawValue}'.tr);
      //       } else {
      //         if (orderId == barcode.rawValue) {
      //           await FireStoreUtils.fireStore.collection(CollectionName.bookedParkingOrder).doc(barcode.rawValue).get().then((value) async {
      //             OrderModel orderModel = OrderModel.fromJson(value.data()!);
      //             ShowToastDialog.closeLoader();
      //             if (orderModel.parkingDetails!.userId != FireStoreUtils.getCurrentUid()) {
      //               ShowToastDialog.showToast("Invalid QR code".tr);
      //             } else if (orderModel.status == Constant.completed) {
      //               ShowToastDialog.showToast("This booking already completed".tr);
      //             } else if (orderModel.status == Constant.onGoing) {
      //               ShowToastDialog.showToast("This Order already scanned".tr);
      //             } else if (DateTime.now().isBefore(orderModel.bookingStartTime!.toDate())) {
      //               Get.to(() => const EarlyArriveScreen(), arguments: {"orderModel": orderModel});
      //             } else {
      //               Get.to(() => const AfterScannedScreen(), arguments: {"orderModel": orderModel});
      //             }
      //           });
      //         } else {
      //           ShowToastDialog.showToast("Invalid QR code".tr);
      //         }
      //       }
      //     }
      //   },
      // ),
    );
  }
}
