
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constant/constant.dart';
import '../../controller/edit_profile_controller.dart';
import '../../themes/app_them_data.dart';
import '../../themes/common_ui.dart';
import '../../themes/responsive.dart';
import '../../utils/dark_theme_provider.dart';


class DownloadAppScreen extends StatelessWidget {
  const DownloadAppScreen({super.key});
// Replace these with your actual links
  final String playStoreUrl = 'https://play.google.com/store/apps/details?id=com.phista.owner';
  final String appStoreUrl = 'https://apps.apple.com/us/app/phista-owners/id6746749570';

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }
  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetX<EditProfileController>(
      init: EditProfileController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppThemData.grey11,
          appBar: UiInterface().customAppBar(
            isBack: true,
            context,
            themeChange,
            'Phista'.tr,
          ),
          body: controller.isLoading.value
              ? Constant.loader():Column(
            children: [
              SizedBox(height: 70,),
              Center(
                child: Text(
                  'Download the Phista Owner App'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: themeChange.getThem()
                        ? AppThemData.primary07
                        : AppThemData.primary07,
                    fontSize: 25,
                    fontFamily: AppThemData.bold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 30,),
              Image.asset(
                "assets/images/PhistaOwnerLogo.png",height:110,width:110,
              ),
              SizedBox(height: 40,),
              Padding(
                 padding: EdgeInsets.only(left:20,right:20),
                 child: Text(
                  'Turn your private parking space into steady extra income.Manage bookings and payouts right from your phone-quick and hassle-free'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: themeChange.getThem()
                        ? AppThemData.white
                        : AppThemData.white,
                    fontSize: 15,
                    fontFamily: AppThemData.medium,
                    fontWeight: FontWeight.w500,
                  ),
                               ),
               ),
              SizedBox(height: 35,),
              InkWell(
                splashColor: Colors.transparent,       // removes splash
                highlightColor: Colors.transparent,    // removes highlight
                hoverColor: Colors.transparent,
                child: Image.asset(
                  "assets/images/Google_Play_store_ico.png",height:Responsive.height(7, context),width:Responsive.width(50, context),
                ),
                onTap: (){
                  _launchUrl(playStoreUrl);
                },
              ),
              SizedBox(height: 25,),
              InkWell(
                splashColor: Colors.transparent,       // removes splash
                highlightColor: Colors.transparent,    // removes highlight
                hoverColor: Colors.transparent,
                child: Image.asset(
                  "assets/images/Apple_Play_store_ico.png",height:Responsive.height(7, context),width:Responsive.width(50, context),
                ),
                onTap: () async {
                  _launchUrl(appStoreUrl);
                },
              ),
            ],
          ),

        );
      },
    );
  }
}
