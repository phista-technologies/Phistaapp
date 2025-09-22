import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../constant/constant.dart';
import '../../../constant/show_toast_dialog.dart';
import '../../../controller/owner_controller/bank_details_controller_owner.dart';
import '../../../model/bank_details_model.dart';
import '../../../themes/app_them_data.dart';
import '../../../themes/common_ui.dart';
import '../../../themes/round_button_fill.dart';
import '../../../themes/text_field_widget.dart';
import '../../../utils/dark_theme_provider.dart';
import '../../../utils/fire_store_utils.dart';

class BankDetailsScreenOwner extends StatelessWidget {
  const BankDetailsScreenOwner({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: BankDetailsControllerOwner(),
        builder: (controller) {
          return Scaffold(
            appBar: UiInterface().customAppBar(
              context,
              themeChange,
              isBack: true,
              'Bank Details'.tr,
            ),
            body: controller.isLoading.value
                ? Constant.loader()
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          TextFieldWidget(
                            title: 'Bank Name'.tr,
                            onPress: () {},
                            controller: controller.bankNameController.value,
                            hintText: 'Enter Bank Name'.tr,
                            prefix: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: SvgPicture.asset(
                                "assets/icon/ic_bank.svg",
                                color: AppThemData.grey08,
                              ),
                            ),
                          ),
                          TextFieldWidget(
                            title: 'Branch Name'.tr,
                            onPress: () {},
                            controller: controller.branchNameController.value,
                            hintText: 'Enter Branch Name'.tr,
                            prefix: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: SvgPicture.asset(
                                "assets/icon/ic_user.svg",
                              ),
                            ),
                          ),
                          TextFieldWidget(
                            title: 'Account Holder Name'.tr,
                            onPress: () {},
                            controller: controller.holderNameController.value,
                            hintText: 'Enter Account Holder Name'.tr,
                            prefix: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: SvgPicture.asset(
                                "assets/icon/ic_tag.svg",
                              ),
                            ),
                          ),
                          TextFieldWidget(
                            title: 'Account Number'.tr,
                            onPress: () {},
                            controller: controller.accountNumberController.value,
                            hintText: 'Enter Account Number'.tr,
                            prefix: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: SvgPicture.asset(
                                "assets/icon/ic_tag.svg",
                              ),
                            ),
                          ),
                          TextFieldWidget(
                            title: 'Other Information'.tr,
                            onPress: () {},
                            controller: controller.otherInformationController.value,
                            hintText: 'Enter Other Information'.tr,
                            maxLine: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
            bottomNavigationBar: Container(
              color: themeChange.getThem() ? AppThemData.grey10 : AppThemData.grey11,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: RoundedButtonFill(
                  title: "Save".tr,
                  color: AppThemData.primary06,
                  onPress: () async {
                    if (controller.bankNameController.value.text.isEmpty) {
                      ShowToastDialog.showToast("Please enter bank name".tr);
                    } else if (controller.branchNameController.value.text.isEmpty) {
                      ShowToastDialog.showToast("Please enter branch name".tr);
                    } else if (controller.holderNameController.value.text.isEmpty) {
                      ShowToastDialog.showToast("Please enter holder name".tr);
                    } else if (controller.accountNumberController.value.text.isEmpty) {
                      ShowToastDialog.showToast("Please enter account number".tr);
                    } else {
                      ShowToastDialog.showLoader("Please wait".tr);
                      BankDetailsModel bankDetailsModel = controller.bankDetailsModel.value;

                      bankDetailsModel.userId = FireStoreUtils.getCurrentUid();
                      bankDetailsModel.bankName = controller.bankNameController.value.text;
                      bankDetailsModel.branchName = controller.branchNameController.value.text;
                      bankDetailsModel.holderName = controller.holderNameController.value.text;
                      bankDetailsModel.accountNumber = controller.accountNumberController.value.text;
                      bankDetailsModel.otherInformation = controller.otherInformationController.value.text;

                      await FireStoreUtils.updateBankDetails(bankDetailsModel).then((value) {
                        ShowToastDialog.closeLoader();
                        ShowToastDialog.showToast("Bank details update successfully".tr);
                        Get.back();
                      });
                    }
                  },
                ),
              ),
            ),
          );
        });
  }
}
