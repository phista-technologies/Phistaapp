import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../constant/constant.dart';
import '../../../controller/owner_controller/profile_controller_owner.dart';
import '../../../model/user_model.dart';
import '../../../themes/app_them_data.dart';
import '../../../themes/common_ui.dart';
import '../../../themes/custom_dialog_box.dart';
import '../../../themes/responsive.dart';
import '../../../themes/round_button_fill.dart';
import '../../../utils/dark_theme_provider.dart';
import '../../../utils/network_image_widget.dart';
import '../../driver/dashboard_screen.dart';
import '../../select_usertype/select_usertypescreen.dart';
import '../auth_screen/login_screen_owner.dart';
import '../bank_details/bank_details_screen_owner.dart';
import '../chat/inbox_screen_owner.dart';
import '../contact_us/contact_us_screen_owner.dart';
import '../faq/faq_screen_owner.dart';
import '../qr_code_scan_screen/qr_code_scan_screen_owner.dart';
import '../setting_screen/setting_screen_owner.dart';
import '../subscription_plan_screen/subscription_history_screen_owner.dart';
import '../subscription_plan_screen/subscription_plan_screen_owner.dart';
import '../terms_and_condition/terms_and_condition_screen_owner.dart';
import '../watchmen_screen/my_watchmen_list_owner.dart';
import 'edit_profile_screen_owner.dart';

class ProfileScreenOwner extends StatelessWidget {
  const ProfileScreenOwner({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: ProfileControllerOwner(),
        builder: (controller) {
          return controller.isLoading.value
              ? Constant.loader()
              : Scaffold(
                  appBar: UiInterface().customAppBar(
                    context,
                    themeChange,
                    isBack: false,
                    'profile'.tr,
                    actions: [
                      InkWell(
                        onTap: () {
                          Get.to(const QrCodeScanScreenOwner());
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Icon(Icons.qr_code_scanner,
                              color: themeChange.getThem()
                                  ? AppThemData.grey01
                                  : AppThemData.grey08),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      controller.userModel.value.subscriptionPlan?.features
                                  ?.chat ==
                              true
                          ? InkWell(
                              onTap: () {
                                Get.to(const InboxScreenOwner());
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Icon(Icons.chat_bubble_outline,
                                    color: themeChange.getThem()
                                        ? AppThemData.grey01
                                        : AppThemData.grey08),
                              ),
                            )
                          : SizedBox()
                    ],
                  ),
                  body: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 30),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(60),
                                  child: NetworkImageWidget(
                                    imageUrl: controller
                                        .userModel.value.profilePic
                                        .toString(),
                                    height: Responsive.width(26, context),
                                    width: Responsive.width(26, context),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        controller.userModel.value.fullName
                                            .toString(),
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontFamily: AppThemData.medium,
                                            color: themeChange.getThem()
                                                ? AppThemData.grey01
                                                : AppThemData.grey10),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        controller.userModel.value.email
                                            .toString(),
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: AppThemData.medium,
                                            color: themeChange.getThem()
                                                ? AppThemData.grey06
                                                : AppThemData.grey06),
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      RoundedButtonFexiable(
                                        title: "Edit Details".tr,
                                        textColor: AppThemData.grey11,
                                        height: 05.55,
                                        isRight: false,
                                        icon: const Icon(Icons.edit,
                                            color: AppThemData.grey11),
                                        color: AppThemData.primary06,
                                        onPress: () {
                                          Get.to(const EditProfileScreenOwner());
                                        },
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (Constant.isSubscriptionModelApplied == true ||
                              Constant.adminCommission?.enable == true)
                            Visibility(
                              visible: controller.userModel.value
                                      .subscriptionPlanId?.isNotEmpty ==
                                  true,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: SubscriptionPlanWidget(
                                  onClick: () {
                                    Get.to(const SubscriptionPlanScreenOwner(isBack: false),
                                            arguments: {'isProfile': true})
                                        ?.then((value) {
                                      if (value == true) {
                                        controller.getData();
                                      }
                                    });
                                  },
                                  userModel: controller.userModel.value,
                                ),
                              ),
                            ),
                          menuItemWidgetForSwitchProfile(
                            title: "Switch To Driver".tr,
                            pngImage: "assets/icon/switch_profile_ico.png",
                            onTap: () {
                              showDialog(
                                  context: context,
                                  barrierDismissible: true,
                                  builder: (BuildContext context) {
                                    return CustomDialogBox(
                                        title: "Alert".tr,
                                        descriptions: "Are you sure want to switch your profile?".tr,
                                        img: Image.asset(
                                          "assets/icon/switch_profile_ico.png",
                                          height: 85,
                                          width: 85,
                                        ),
                                        positiveString: "Ok".tr,
                                        negativeString: "Cancel".tr,
                                        positiveBgColor: AppThemData.success07,
                                        positiveClick: () async{
                                          Get.offAll(const DashBoardScreen());
                                        },
                                        negativeClick: () async {

                                          Get.back();


                                        }
                                    );
                                  });

                              //Get.to(() => const SettingScreen());
                            },
                            themeChange: themeChange,
                          ),
                          menuItemWidget(
                            title: "Watchmen List".tr,
                            svgImage: "assets/icon/ic_account.svg",
                            onTap: () {
                              Get.to(() => const MyWatchmenListOwner(isBack: true));
                            },
                            themeChange: themeChange,
                          ),
                          menuItemWidget(
                            title: "Bank Details".tr,
                            svgImage: "assets/icon/ic_bank.svg",
                            onTap: () {
                              Get.to(() => const BankDetailsScreenOwner());
                            },
                            themeChange: themeChange,
                          ),
                          const Divider(
                              color: AppThemData.grey04, thickness: 1),
                          (Constant.isSubscriptionModelApplied == true ||
                                  Constant.adminCommission?.enable == true)
                              ? menuItemWidget(
                                  title: "Subscription Packages".tr,
                                  svgImage: "assets/icon/ic_subscription.svg",
                                  onTap: () {
                                    Get.to(const SubscriptionPlanScreenOwner(isBack: false),
                                            arguments: {'isProfile': true})
                                        ?.then((value) {
                                      if (value == true) {
                                        controller.getData();
                                      }
                                    });
                                  },
                                  themeChange: themeChange,
                                )
                              : SizedBox(),
                          menuItemWidget(
                            title: "Subscription History".tr,
                            svgImage: "assets/icon/ic_history.svg",
                            onTap: () {
                              Get.to(const SubscriptionHistoryScreenOwner());
                            },
                            themeChange: themeChange,
                          ),
                          const Divider(
                              color: AppThemData.grey04, thickness: 1),
                          menuItemWidget(
                            title: "Settings".tr,
                            svgImage: "assets/icon/ic_setting.svg",
                            onTap: () {
                              Get.to(() => const SettingScreenOwner());
                            },
                            themeChange: themeChange,
                          ),
                          menuItemWidget(
                            title: "Privacy Policy".tr,
                            svgImage: "assets/icon/ic_privacy_policy.svg",
                            onTap: () {
                              Get.to(const TermsAndConditionScreenOwner(
                                type: "privacy",
                              ));
                            },
                            themeChange: themeChange,
                          ),
                          menuItemWidget(
                            title: "Terms & Conditions".tr,
                            svgImage: "assets/icon/ic_terms_condition.svg",
                            onTap: () {
                              Get.to(const TermsAndConditionScreenOwner(
                                type: "terms",
                              ));
                            },
                            themeChange: themeChange,
                          ),
                          menuItemWidget(
                            title: "Support".tr,
                            svgImage: "assets/icon/ic_support.svg",
                            onTap: () async {
                              final Uri url =
                                  Uri.parse(Constant.supportURL.toString());
                              if (!await launchUrl(url)) {
                                throw Exception(
                                    'Could not launch ${Constant.supportURL.toString()}'
                                        .tr);
                              }
                            },
                            themeChange: themeChange,
                          ),
                          menuItemWidget(
                            title: "Contact Us".tr,
                            svgImage: "assets/icon/ic_call_support.svg",
                            onTap: () {
                              Get.to(
                                () => const ContactUsScreenOwner(),
                              );
                            },
                            themeChange: themeChange,
                          ),
                          menuItemWidget(
                            title: "FAQ’s".tr,
                            svgImage: "assets/icon/ic_faq.svg",
                            onTap: () {
                              Get.to(() => const FaqScreenOwner());
                            },
                            themeChange: themeChange,
                          ),
                          const Divider(
                              color: AppThemData.grey04, thickness: 1),
                          menuItemWidget(
                            title: "Log Out".tr,
                            svgImage: "assets/icon/ic_logout.svg",
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return CustomDialogBox(
                                      title: "Signing out for now?".tr,
                                      descriptions:
                                          "Ensure your account's security with a quick log out. Your parking solutions will be here when you return!"
                                              .tr,
                                      positiveString: "Log out".tr,
                                      negativeString: "Cancel".tr,
                                      positiveClick: () async {
                                        // Navigator.of(context).pop(); // Close the dialog
                                        final GoogleSignIn googleSignIn = GoogleSignIn();
                                        if (await googleSignIn.isSignedIn()) {
                                          await googleSignIn.signOut();
                                          await googleSignIn.disconnect();
                                        }
                                        await FirebaseAuth.instance.signOut();
                                        Get.offAll(const SelectUserTypeScreen());
                                      },
                                      negativeClick: () {
                                        Get.back();
                                      },
                                      img: SvgPicture.asset(
                                          'assets/images/ic_logout_image.svg'),
                                    );
                                  });
                              // showLogoutAccountDialog(context, themeChange);
                            },
                            themeChange: themeChange,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
        });
  }

  Widget menuItemWidget({
    required String svgImage,
    required String title,
    required VoidCallback onTap,
    required themeChange,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      horizontalTitleGap: 6,
      onTap: onTap,
      trailing: const Icon(Icons.arrow_forward_ios, size: 18),
      leading: SvgPicture.asset(
        svgImage,
        color: title == "Log Out"
            ? AppThemData.error08
            : themeChange.getThem()
                ? AppThemData.grey01
                : AppThemData.grey09,
        height: 26,
      ),
      title: Text(
        title,
        style: TextStyle(
            fontSize: 16,
            fontFamily: AppThemData.medium,
            color: title == "Log Out"
                ? AppThemData.error08
                : themeChange.getThem()
                    ? AppThemData.grey01
                    : AppThemData.grey09),
      ),
    );
  }

  Widget menuItemWidgetForSwitchProfile({
    required String pngImage,
    required String title,
    required VoidCallback onTap,
    required themeChange,
  })
  {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      horizontalTitleGap: 6,
      onTap: onTap,
      trailing: const Icon(Icons.arrow_forward_ios, size: 18),
      leading:Image.asset(
        pngImage,
        height: 26,
        color: title == "Log Out"
            ? AppThemData.error08
            : themeChange.getThem()
            ? AppThemData.grey01
            : AppThemData.grey09,
      ),
      title: Text(
        title,
        style: TextStyle(
            fontSize: 16,
            fontFamily: AppThemData.medium,
            color: title == "Log Out"
                ? AppThemData.error08
                : themeChange.getThem()
                ? AppThemData.grey01
                : AppThemData.grey09),
      ),
    );
  }
}

class SubscriptionPlanWidget extends StatelessWidget {
  final VoidCallback onClick;
  final UserModel userModel;

  const SubscriptionPlanWidget({
    super.key,
    required this.onClick,
    required this.userModel,
  });

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(
            color: themeChange.getThem()
                ? AppThemData.grey800
                : AppThemData.grey200),
        color: themeChange.getThem() ? AppThemData.grey50 : AppThemData.grey800,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned(
              bottom: 0,
              top: 10,
              child: Opacity(
                  opacity: 0.8,
                  child: Image.asset(
                    width: Responsive.width(100, context),
                    height: Responsive.height(100, context),
                    "assets/images/ic_gradient.png",
                    color: AppThemData.primary07,
                    fit: BoxFit.fill,
                  ))),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    NetworkImageWidget(
                      imageUrl: userModel.subscriptionPlan?.image ?? '',
                      fit: BoxFit.cover,
                      width: 50,
                      height: 50,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userModel.subscriptionPlan?.name ?? '',
                                  style: TextStyle(
                                    color: themeChange.getThem()
                                        ? AppThemData.grey900
                                        : AppThemData.grey50,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: AppThemData.semiBold,
                                  ),
                                ),
                                Text(
                                  userModel.subscriptionPlan?.type == 'free'
                                      ? userModel
                                              .subscriptionPlan?.description ??
                                          ''
                                      : Constant.amountShow(
                                          amount: userModel
                                              .subscriptionPlan?.price),
                                  style: const TextStyle(
                                    fontFamily: AppThemData.medium,
                                    fontSize: 14,
                                    color: AppThemData.grey400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (userModel.subscriptionPlan?.type == 'paid')
                            SizedBox(
                              width: 14,
                            ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Expiry Date'.tr,
                                style: TextStyle(
                                  fontFamily: AppThemData.medium,
                                  fontSize: 12,
                                  color: themeChange.getThem()
                                      ? AppThemData.grey900
                                      : AppThemData.grey50,
                                ),
                              ),
                              Text(
                                userModel.subscriptionPlan!.expiryDay == "-1"
                                    ? "LifeTime"
                                    : Constant.timestampToDate(
                                        userModel.subscriptionExpiryDate!),
                                style: const TextStyle(
                                  fontFamily: AppThemData.regular,
                                  fontSize: 12,
                                  color: AppThemData.grey400,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                RoundedButtonFill(
                  textColor: AppThemData.grey200,
                  title: "Change Plan".tr,
                  color: AppThemData.primary07,
                  width: 80,
                  height: 5,
                  onPress: onClick,
                ),
                if (Constant.adminCommission?.enable == true)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      userModel.adminCommission != null
                          ? "${userModel.adminCommission?.type == 'percentage' ? "${userModel.adminCommission?.amount} %" : "${Constant.amountShow(amount: userModel.adminCommission?.amount)} Flat"} ${"admin commission will be charged from your account".tr}"
                          : "${Constant.adminCommission?.type == 'percentage' ? "${Constant.adminCommission?.amount} %" : "${Constant.amountShow(amount: Constant.adminCommission?.amount)} Flat"} ${"admin commission will be charged from your account".tr}",
                      style: const TextStyle(
                        fontFamily: AppThemData.medium,
                        fontSize: 9,
                        color: AppThemData.grey400,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
