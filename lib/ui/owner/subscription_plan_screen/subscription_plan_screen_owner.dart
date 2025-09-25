import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:phista/ui/owner/subscription_plan_screen/select_payment_screen_owner.dart';

import 'package:provider/provider.dart';

import '../../../constant/constant.dart';
import '../../../controller/owner_controller/subscription_controller_owner.dart';
import '../../../model/subscription_plan_model.dart';
import '../../../themes/app_them_data.dart';
import '../../../themes/responsive.dart';
import '../../../themes/round_button_fill.dart';
import '../../../utils/dark_theme_provider.dart';
import '../../../utils/network_image_widget.dart';

class SubscriptionPlanScreenOwner extends StatelessWidget {
  final bool isBack;
  const SubscriptionPlanScreenOwner({required this.isBack,super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: SubscriptionControllerOwner(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppThemData.primary07,
              centerTitle: false,
              titleSpacing: 0,
              iconTheme: const IconThemeData(color: AppThemData.grey50, size: 20),
              automaticallyImplyLeading: !isBack,
              leading: isBack
                  ? InkWell(
                onTap: () {
                      Get.back();
                    },
                child: Icon(Icons.arrow_back, color: themeChange.getThem() ? AppThemData.grey900 : AppThemData.grey900),
              )
                  : null,

            ),

            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 40,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Choose Your Business Plan".tr,
                            style: TextStyle(
                              color: themeChange.getThem() ? AppThemData.grey50 : AppThemData.grey900,
                              fontSize: 24,
                              fontFamily: AppThemData.semiBold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Select the most suitable business plan for your parking to maximize your potential and access exclusive features.".tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: themeChange.getThem() ? AppThemData.grey400 : AppThemData.grey500,
                              fontSize: 16,
                              fontFamily: AppThemData.regular,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    controller.isLoading.value
                        ? Constant.loader()
                        : controller.subscriptionPlanList.isEmpty
                            ? SizedBox(
                                width: Responsive.width(100, context),
                                height: Responsive.height(50, context),
                                child: Constant.showEmptyView(message: "Subscription plan not found.".tr))
                            : ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                primary: false,
                                itemCount: controller.subscriptionPlanList.length,
                                itemBuilder: (context, index) {
                                  final subscriptionPlanModel = controller.subscriptionPlanList[index];
                                  return SubscriptionPlanWidget(
                                    onContainClick: () {
                                      controller.selectedSubscriptionPlan.value = subscriptionPlanModel;
                                      controller.totalAmount.value = double.parse(subscriptionPlanModel.price ?? '0.0');
                                      controller.update();
                                    },
                                    onClick: () {
                                      if (controller.selectedSubscriptionPlan.value.id == subscriptionPlanModel.id) {
                                        if (controller.selectedSubscriptionPlan.value.type == 'free' ||
                                            controller.selectedSubscriptionPlan.value.id == Constant.commissionSubscriptionID) {
                                          controller.selectedPaymentMethod.value = 'free';
                                          controller.setOrder();
                                        } else {
                                          Get.to(const SelectPaymentScreenOwner());
                                        }
                                      }
                                    },
                                    type: 'Plan',
                                    subscriptionPlanModel: subscriptionPlanModel,
                                  );
                                }),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}

class FeatureItem extends StatelessWidget {
  final String title;
  final bool isActive;
  final bool selectedPlan;

  const FeatureItem({super.key, required this.title, required this.isActive, required this.selectedPlan});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.4,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          isActive == true
              ? SvgPicture.asset(
                  'assets/icon/ic_check.svg',
                )
              : SvgPicture.asset(
                  'assets/icon/ic_close.svg',
                  colorFilter: const ColorFilter.mode(
                    AppThemData.error07,
                    BlendMode.srcIn,
                  ),
                ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              title == 'chat'
                  ? 'Chat'
                  : title == 'ownerMobileApp'
                      ? 'Owner Mobile App'
                      : '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontFamily: AppThemData.medium,
                color: themeChange.getThem()
                    ? selectedPlan == true
                        ? AppThemData.grey900
                        : AppThemData.grey50
                    : selectedPlan == true
                        ? AppThemData.grey50
                        : AppThemData.grey900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SubscriptionPlanWidget extends StatelessWidget {
  final VoidCallback onClick;
  final VoidCallback onContainClick;
  final String type;
  final SubscriptionPlanModel subscriptionPlanModel;

  const SubscriptionPlanWidget({super.key, required this.onClick, required this.type, required this.subscriptionPlanModel, required this.onContainClick});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetX(
        init: SubscriptionControllerOwner(),
        builder: (controller) {
          return InkWell(
            splashColor: Colors.transparent,
            onTap: onContainClick,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: themeChange.getThem() ? AppThemData.grey800 : AppThemData.grey200),
                color: controller.selectedSubscriptionPlan.value.id == subscriptionPlanModel.id
                    ? themeChange.getThem()
                        ? AppThemData.grey50
                        : AppThemData.grey800
                    : themeChange.getThem()
                        ? AppThemData.grey900
                        : AppThemData.grey50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        NetworkImageWidget(
                          imageUrl: subscriptionPlanModel.image ?? '',
                          fit: BoxFit.cover,
                          width: 50,
                          height: 50,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                subscriptionPlanModel.name ?? '',
                                style: TextStyle(
                                  color: controller.selectedSubscriptionPlan.value.id == subscriptionPlanModel.id
                                      ? themeChange.getThem()
                                          ? AppThemData.grey900
                                          : AppThemData.grey50
                                      : themeChange.getThem()
                                          ? AppThemData.grey50
                                          : AppThemData.grey900,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: AppThemData.semiBold,
                                ),
                              ),
                              Text(
                                "${subscriptionPlanModel.description}",
                                maxLines: 2,
                                softWrap: true,
                                style: const TextStyle(
                                  fontFamily: AppThemData.regular,
                                  fontSize: 14,
                                  color: AppThemData.grey400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        controller.userModel.value.subscriptionPlanId == subscriptionPlanModel.id
                            ? RoundedButtonFill(
                                title: "Active".tr,
                                width: 18,
                                height: 4,
                                color: AppThemData.success07,
                                textColor: AppThemData.grey50,
                                onPress: () async {},
                              )
                            : SizedBox(),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subscriptionPlanModel.type == "free" ? "Free" : Constant.amountShow(amount: double.parse(subscriptionPlanModel.price ?? '0.0').toString()),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: controller.selectedSubscriptionPlan.value.id == subscriptionPlanModel.id
                                ? themeChange.getThem()
                                    ? AppThemData.grey800
                                    : AppThemData.grey200
                                : themeChange.getThem()
                                    ? AppThemData.grey200
                                    : AppThemData.grey800,
                            fontFamily: AppThemData.semiBold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subscriptionPlanModel.expiryDay == "-1" ? "Lifetime" : "${subscriptionPlanModel.expiryDay} Days",
                          style: TextStyle(
                            fontFamily: AppThemData.medium,
                            fontSize: 14,
                            color: controller.selectedSubscriptionPlan.value.id == subscriptionPlanModel.id
                                ? themeChange.getThem()
                                    ? AppThemData.grey500
                                    : AppThemData.grey500
                                : themeChange.getThem()
                                    ? AppThemData.grey500
                                    : AppThemData.grey500,
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                    Divider(
                        color: controller.selectedSubscriptionPlan.value.id == subscriptionPlanModel.id
                            ? themeChange.getThem()
                                ? AppThemData.grey200
                                : AppThemData.grey700
                            : themeChange.getThem()
                                ? AppThemData.grey700
                                : AppThemData.grey200),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 0,
                      runSpacing: 12,
                      children: subscriptionPlanModel.features?.toJson().entries.map((entry) {
                            return FeatureItem(title: entry.key, isActive: entry.value, selectedPlan: controller.selectedSubscriptionPlan.value.id == subscriptionPlanModel.id);
                          }).toList() ??
                          [],
                    ),
                    if (subscriptionPlanModel.id == Constant.commissionSubscriptionID)
                      Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Text('•  ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: AppThemData.medium,
                                    color: themeChange.getThem()
                                        ? controller.selectedSubscriptionPlan.value.id == subscriptionPlanModel.id
                                            ? AppThemData.grey800
                                            : AppThemData.grey200
                                        : controller.selectedSubscriptionPlan.value.id == subscriptionPlanModel.id
                                            ? AppThemData.grey200
                                            : AppThemData.grey800,
                                  )),
                              Expanded(
                                child: Text(
                                    // Constant.userModel!.vendorID != null && Constant.userModel!.vendorID!.isNotEmpty
                                    //     ? "Pay a commission of ${Constant.vendorAdminCommission?.commissionType == 'percentage' ? "${Constant.vendorAdminCommission?.amount} %" : "${Constant.amountShow(amount: Constant.vendorAdminCommission?.amount)} Flat"} on each order"
                                    //         .tr
                                    //     :

                                    "${"Pay a commission of".tr} ${Constant.adminCommission?.type == 'percentage' ? "${Constant.adminCommission?.amount} %" : "${Constant.amountShow(amount: Constant.adminCommission?.amount)} Flat"} ${"on each booking".tr}",
                                    maxLines: 2,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: AppThemData.regular,
                                      color: themeChange.getThem()
                                          ? controller.selectedSubscriptionPlan.value.id == subscriptionPlanModel.id
                                              ? AppThemData.grey800
                                              : AppThemData.grey200
                                          : controller.selectedSubscriptionPlan.value.id == subscriptionPlanModel.id
                                              ? AppThemData.grey200
                                              : AppThemData.grey800,
                                    )),
                              ),
                            ],
                          )),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: subscriptionPlanModel.planPoints?.length,
                      itemBuilder: (BuildContext? context, int index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Text('•  ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: AppThemData.medium,
                                    color: themeChange.getThem()
                                        ? controller.selectedSubscriptionPlan.value.id == subscriptionPlanModel.id
                                            ? AppThemData.grey800
                                            : AppThemData.grey200
                                        : controller.selectedSubscriptionPlan.value.id == subscriptionPlanModel.id
                                            ? AppThemData.grey200
                                            : AppThemData.grey800,
                                  )),
                              Expanded(
                                child: Text(subscriptionPlanModel.planPoints?[index] ?? '',
                                    maxLines: 2,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: AppThemData.regular,
                                      color: themeChange.getThem()
                                          ? controller.selectedSubscriptionPlan.value.id == subscriptionPlanModel.id
                                              ? AppThemData.grey800
                                              : AppThemData.grey200
                                          : controller.selectedSubscriptionPlan.value.id == subscriptionPlanModel.id
                                              ? AppThemData.grey200
                                              : AppThemData.grey800,
                                    )),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    Divider(
                        color: controller.selectedSubscriptionPlan.value.id == subscriptionPlanModel.id
                            ? themeChange.getThem()
                                ? AppThemData.grey200
                                : AppThemData.grey700
                            : themeChange.getThem()
                                ? AppThemData.grey700
                                : AppThemData.grey200),
                    const SizedBox(height: 10),
                    Text('Add Parking limits : ${subscriptionPlanModel.itemLimit == '-1' ? 'Unlimited' : subscriptionPlanModel.itemLimit ?? '0'}',
                        maxLines: 2,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 14,
                            fontFamily: AppThemData.regular,
                            color: themeChange.getThem()
                                ? controller.selectedSubscriptionPlan.value.id == subscriptionPlanModel.id
                                    ? AppThemData.grey900
                                    : AppThemData.grey50
                                : controller.selectedSubscriptionPlan.value.id == subscriptionPlanModel.id
                                    ? AppThemData.grey50
                                    : AppThemData.grey900)),
                    const SizedBox(height: 10),
                    Text('Accept Booking limits : ${subscriptionPlanModel.orderLimit == '-1' ? 'Unlimited' : subscriptionPlanModel.orderLimit ?? '0'}',
                        textAlign: TextAlign.end,
                        maxLines: 2,
                        style: TextStyle(
                            fontSize: 14,
                            fontFamily: AppThemData.regular,
                            color: themeChange.getThem()
                                ? controller.selectedSubscriptionPlan.value.id == subscriptionPlanModel.id
                                    ? AppThemData.grey900
                                    : AppThemData.grey50
                                : controller.selectedSubscriptionPlan.value.id == subscriptionPlanModel.id
                                    ? AppThemData.grey50
                                    : AppThemData.grey900)),
                    const SizedBox(height: 20),
                    RoundedButtonFill(
                      textColor: controller.selectedSubscriptionPlan.value.id == subscriptionPlanModel.id
                          ? AppThemData.grey200
                          : themeChange.getThem()
                              ? AppThemData.grey500
                              : AppThemData.grey500,
                      title: controller.userModel.value.subscriptionPlanId == subscriptionPlanModel.id
                          ? "Renew"
                          : controller.selectedSubscriptionPlan.value.id == subscriptionPlanModel.id
                              ? "Active".tr
                              : "Select Plan".tr,
                      color: controller.selectedSubscriptionPlan.value.id == subscriptionPlanModel.id
                          ? AppThemData.secondary07
                          : themeChange.getThem()
                              ? AppThemData.grey800
                              : AppThemData.grey200,
                      width: 80,
                      height: 5,
                      onPress: onClick,
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
