import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../constant/constant.dart';
import '../../../controller/owner_controller/subscription_history_controller_owner.dart';
import '../../../themes/app_them_data.dart';
import '../../../utils/dark_theme_provider.dart';
import '../../../utils/network_image_widget.dart';

class SubscriptionHistoryScreenOwner extends StatelessWidget {
  const SubscriptionHistoryScreenOwner({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: SubscriptionHistoryControllerOwner(),
        builder: (controller) {
          return Scaffold(
              appBar: AppBar(
                title: Text(
                  "Purchase History".tr,
                  style: TextStyle(color: themeChange.getThem() ? AppThemData.grey900 : AppThemData.grey50, fontSize: 18, fontFamily: AppThemData.medium),
                ),
                backgroundColor: AppThemData.primary07,
                centerTitle: false,
                titleSpacing: 0,
                iconTheme: IconThemeData(color: themeChange.getThem() ? AppThemData.grey900 : AppThemData.grey50, size: 20),
              ),
              body: controller.isLoading.value
                  ? Constant.loader()
                  : controller.subscriptionHistoryList.isEmpty
                      ? Constant.showEmptyView(message: "Purchase History Not found")
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: controller.subscriptionHistoryList.length,
                          itemBuilder: (context, index) {
                            final subscriptionHistoryModel = controller.subscriptionHistoryList[index];
                            return Container(
                              margin: const EdgeInsets.only(left: 16, right: 16, top: 20),
                              decoration: ShapeDecoration(
                                color: themeChange.getThem() ? AppThemData.grey900 : AppThemData.grey50,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                shadows: const [
                                  BoxShadow(
                                    color: Color(0x07000000),
                                    blurRadius: 20,
                                    offset: Offset(0, 0),
                                    spreadRadius: 0,
                                  )
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              NetworkImageWidget(
                                                imageUrl: subscriptionHistoryModel.subscriptionPlan?.image ?? '',
                                                fit: BoxFit.cover,
                                                width: 45,
                                                height: 45,
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                subscriptionHistoryModel.subscriptionPlan?.name ?? '',
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  fontFamily: AppThemData.medium,
                                                  fontSize: 16,
                                                  color: themeChange.getThem() ? AppThemData.grey50 : AppThemData.grey900,
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (index == 0)
                                            const Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons.check_circle_outlined,
                                                  color: AppThemData.success07,
                                                ),
                                                SizedBox(width: 5),
                                                Text(
                                                  'Active',
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                    fontFamily: AppThemData.medium,
                                                    fontSize: 16,
                                                    color: AppThemData.success07,
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Divider(color: themeChange.getThem() ? AppThemData.grey800 : AppThemData.grey100),
                                    const SizedBox(height: 5),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('Validity',
                                                  textAlign: TextAlign.end,
                                                  maxLines: 2,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontFamily: AppThemData.regular,
                                                    color: themeChange.getThem() ? AppThemData.grey200 : AppThemData.grey900,
                                                  )),
                                              Text(
                                                  subscriptionHistoryModel.subscriptionPlan?.expiryDay == '-1'
                                                      ? "Unlimited"
                                                      : '${subscriptionHistoryModel.subscriptionPlan?.expiryDay ?? '0'}  Days',
                                                  textAlign: TextAlign.end,
                                                  maxLines: 2,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontFamily: AppThemData.medium,
                                                    color: themeChange.getThem() ? AppThemData.grey50 : AppThemData.grey800,
                                                  )),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('Price',
                                                  textAlign: TextAlign.end,
                                                  maxLines: 2,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontFamily: AppThemData.regular,
                                                    color: themeChange.getThem() ? AppThemData.grey200 : AppThemData.grey900,
                                                  )),
                                              Text(Constant.amountShow(amount: subscriptionHistoryModel.subscriptionPlan?.price ?? '0'),
                                                  textAlign: TextAlign.end,
                                                  maxLines: 2,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontFamily: AppThemData.medium,
                                                    color: themeChange.getThem() ? AppThemData.grey50 : AppThemData.grey800,
                                                  )),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('Payment Type',
                                                  textAlign: TextAlign.end,
                                                  maxLines: 2,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontFamily: AppThemData.regular,
                                                    color: themeChange.getThem() ? AppThemData.grey200 : AppThemData.grey900,
                                                  )),
                                              Text((subscriptionHistoryModel.paymentType ?? '').capitalizeString(),
                                                  textAlign: TextAlign.end,
                                                  maxLines: 2,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontFamily: AppThemData.medium,
                                                    color: themeChange.getThem() ? AppThemData.grey50 : AppThemData.grey800,
                                                  )),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('Purchase Date',
                                                  textAlign: TextAlign.end,
                                                  maxLines: 2,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontFamily: AppThemData.regular,
                                                    color: themeChange.getThem() ? AppThemData.grey200 : AppThemData.grey900,
                                                  )),
                                              Text(Constant.timestampToDateTime(subscriptionHistoryModel.subscriptionPlan!.createdAt!),
                                                  textAlign: TextAlign.end,
                                                  maxLines: 2,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontFamily: AppThemData.medium,
                                                    color: themeChange.getThem() ? AppThemData.grey50 : AppThemData.grey800,
                                                  )),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('Expiry Date',
                                                  textAlign: TextAlign.end,
                                                  maxLines: 2,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontFamily: AppThemData.regular,
                                                    color: themeChange.getThem() ? AppThemData.grey200 : AppThemData.grey900,
                                                  )),
                                              Text(subscriptionHistoryModel.expiryDate == null ? "Unlimited" : Constant.timestampToDateTime(subscriptionHistoryModel.expiryDate!),
                                                  textAlign: TextAlign.end,
                                                  maxLines: 2,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontFamily: AppThemData.medium,
                                                    color: themeChange.getThem() ? AppThemData.grey50 : AppThemData.grey800,
                                                  )),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          }));
        });
  }
}
