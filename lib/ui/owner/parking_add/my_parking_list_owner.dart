import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import 'package:provider/provider.dart';

import '../../../constant/constant.dart';
import '../../../constant/show_toast_dialog.dart';
import '../../../controller/owner_controller/my_parking_list_controller_owner.dart';
import '../../../model/parking_model.dart';
import '../../../themes/app_them_data.dart';
import '../../../themes/common_ui.dart';
import '../../../themes/custom_dialog_box.dart';
import '../../../themes/responsive.dart';
import '../../../themes/round_button_fill.dart';
import '../../../utils/dark_theme_provider.dart';
import '../../../utils/fire_store_utils.dart';
import '../../../utils/network_image_widget.dart';
import 'add_parking_details_screen_owner.dart';


class MyParkingListOwner extends StatelessWidget {
  final bool isBack;

  const MyParkingListOwner({required this.isBack, super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: MyParkingListControllerOwner(),
        builder: (controller) {
          return Scaffold(
            appBar: UiInterface().customAppBar(
                context, themeChange, 'My Parking'.tr,
                isBack: isBack,
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 8, right: 8),
                    child: RoundedButtonFexiable(
                      title: "Add Parking".tr,
                      color: AppThemData.primary06,
                      onPress: () async {
                        if ((Constant.isSubscriptionModelApplied == true ||
                                Constant.adminCommission?.enable == true) &&
                            controller.userModel.value.subscriptionPlan
                                    ?.itemLimit !=
                                '-1' &&
                            int.parse(controller.userModel.value
                                                .subscriptionPlan?.itemLimit !=
                                            null &&
                                        controller.userModel.value
                                                .subscriptionPlan?.itemLimit
                                                .toString() !=
                                            "null"
                                    ? "${controller.userModel.value.subscriptionPlan?.itemLimit}"
                                    : '0') <=
                                controller.parkingList.length) {
                          ShowToastDialog.showToast(
                              "Your current subscription plan has reached its maximum parking limit. Upgrade now to add more parking."
                                  .tr);
                        } else {
                          Get.to(() => const AddParkingDetailsScreenOwner())?.then((value) {
                            controller.getData();
                          });
                        }
                      },
                    ),
                  ),
                ]),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: controller.isLoading.value
                  ? Constant.loader()
                  : controller.parkingList.isEmpty
                      ? Constant.showEmptyView(message: "No parking added".tr)
                      : ListView.separated(
                          itemCount: controller.parkingList.length,
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, int index) {
                            ParkingModel parkingModel = controller.parkingList[index];
                            return InkWell(
                              onTap: () {
                                Get.to(() => const AddParkingDetailsScreenOwner(),
                                    arguments: {
                                      "parkingModel": parkingModel
                                    })?.then((value) {
                                  controller.getData();
                                });
                              },
                              child: Container(
                                height: Responsive.height(!kIsWeb?15:30, context),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: themeChange.getThem()
                                      ? AppThemData.grey10
                                      : AppThemData.white,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          bottomLeft: Radius.circular(12)),
                                      child: NetworkImageWidget(
                                        fit: BoxFit.cover,
                                        imageUrl: parkingModel.image.toString(),
                                        height:Responsive.height(!kIsWeb?15:30, context),
                                        width:!kIsWeb?100:200 ,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical:10),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    parkingModel.name
                                                        .toString(),
                                                    style: TextStyle(
                                                      color: themeChange
                                                              .getThem()
                                                          ? AppThemData.grey01
                                                          : AppThemData.grey10,
                                                      fontSize: !kIsWeb?14:25,
                                                      fontFamily:
                                                          AppThemData.semiBold,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 30,
                                                  width: 30,
                                                  child: const Icon(
                                                    Icons.edit,
                                                    color: AppThemData.warning08,
                                                  ),
                                                ),
                                                SizedBox(width:!kIsWeb?5:10,),
                                                 InkWell(
                                                   onTap: ()async{
                                                     bool isBooked = await FireStoreUtils.parkingBookedOrNot(parkingModel.id);
                                                     print("isBooked :-- $isBooked");
                                                     if(!isBooked){
                                                       print("you can delete");
                                                       showDialog(
                                                           context: context,
                                                           builder: (BuildContext context) {
                                                             return CustomDialogBox(
                                                               title: "Delete Parking".tr,
                                                               descriptions: "Are you sure want to delete this parking?".tr,
                                                               positiveBgColor: AppThemData.success07,
                                                               positiveClick: () async {
                                                                 ShowToastDialog.showLoader("Please wait".tr);
                                                                 FireStoreUtils.deleteParking(parkingModel.id).then((value) {
                                                                   ShowToastDialog.closeLoader();
                                                                   Get.back();
                                                                   if (value == true) {
                                                                     ShowToastDialog.showToast("Parking deleted successfully".tr);
                                                                     controller.parkingList.removeAt(index);
                                                                     controller.parkingList.refresh();
                                                                   } else {
                                                                     ShowToastDialog.showToast("contact_administrator".tr);
                                                                   }
                                                                 },);
                                                               },
                                                               positiveString: "Yes, Sure".tr,
                                                               negativeString: "No".tr,
                                                               negativeClick: () {
                                                                 Get.back();
                                                               },
                                                               img: SvgPicture.asset('assets/images/ic_delete_image.svg'),
                                                             );
                                                           });
                                                     }else{
                                                       print("booking on going");
                                                       showDialog(context: context, builder: (BuildContext context){
                                                         return CustomDialogBoxOnlyOk(
                                                           title: "Alert".tr,
                                                           descriptions: "You can't delete this parking due to ongoing booking.".tr,
                                                           buttonText: "Okay",
                                                           bgColor: AppThemData.error07,
                                                           onButtonTap: (){
                                                             Get.back();
                                                           },
                                                           img: SvgPicture.asset('assets/icon/alert_ico.svg'),
                                                         );
                                                       });
                                                     }
                                                   },
                                                  child: SizedBox(
                                                    height: 30,
                                                    width: 30,
                                                    child: Icon(
                                                      Icons.delete,
                                                      color: AppThemData.warning08,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: !kIsWeb?5:10,
                                            ),
                                            Text(
                                              parkingModel.address.toString(),
                                              maxLines: 2,
                                              style: const TextStyle(
                                                  color: AppThemData.grey07,
                                                  fontSize: !kIsWeb?12:24,
                                                  fontFamily:
                                                      AppThemData.regular,
                                                  overflow:
                                                      TextOverflow.ellipsis),
                                            ),
                                            Spacer(),
                                            Row(
                                              children: [
                                                Text(
                                                  "${Constant.amountShow(amount: parkingModel.perHrPrice.toString())}/hour"
                                                      .tr,
                                                  style: const TextStyle(
                                                    color:
                                                        AppThemData.blueLight07,
                                                    fontSize: !kIsWeb?12:24,
                                                    fontFamily:
                                                        AppThemData.semiBold,
                                                  ),
                                                ),
                                                const SizedBox(
                                                    height: 18,
                                                    child: VerticalDivider(
                                                        thickness: 1,
                                                        color: AppThemData
                                                            .grey05)),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: parkingModel
                                                                .isEnable ==
                                                            true
                                                        ? AppThemData.success07
                                                        : AppThemData.error07,
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                20)),
                                                  ),
                                                  child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 10,
                                                          vertical: 4),
                                                      child: Text(
                                                        parkingModel.isEnable ==
                                                                true
                                                            ? "Open".tr
                                                            : "Close".tr,
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            color: AppThemData
                                                                .white,
                                                            fontFamily:
                                                                AppThemData
                                                                    .medium),
                                                      )),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (context, index) {
                            return const SizedBox(
                              height: 8,
                            );
                          },
                        ),
            ),
          );
        });
  }
}
