import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_getx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:phista/themes/responsive.dart';
import 'package:phista/ui/owner/auth_screen/login_screen_owner.dart';

import 'package:provider/provider.dart';

import '../../controller/driver_controller/select_user_type_controller.dart';
import '../../../themes/app_them_data.dart';
import '../../../themes/custom_dialog_box.dart';
import '../../../themes/round_button_gradiant.dart';
import '../../../utils/dark_theme_provider.dart';
import '../../themes/round_button_fill.dart';
import '../../utils/preferences.dart';
import '../driver/auth_screen/login_screen.dart';


class SelectUserTypeScreen extends StatelessWidget{

  const SelectUserTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetBuilder<SelectUserTypeController>(
      init: SelectUserTypeController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppThemData.primary06,
          body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/splash_bg.png"),
                fit: BoxFit.fill,
              ),
            ),
           child: Padding(
             padding: EdgeInsets.symmetric(horizontal: 10),
             child: Column(
               mainAxisAlignment: MainAxisAlignment.start,
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 SizedBox(
                   height: kBottomNavigationBarHeight,
                 ),
                 SizedBox(
                   width: double.infinity,
                   child: Text(
                     "Select a user type".tr,
                     textAlign: TextAlign.start,
                     style: TextStyle(
                       color: themeChange.getThem()
                           ? AppThemData.grey01
                           : AppThemData.grey10,
                       fontSize: 30,
                       fontFamily: AppThemData.semiBold,
                       fontWeight: FontWeight.w400,
                     ),
                   ),
                 ),
                 SizedBox(height: 10,),
                 /*SizedBox(
                   width: double.infinity,
                   child: Text(
                     "Contrary to popular belief, Lorem Ipsum is not simply random text.".tr,
                     textAlign: TextAlign.start,
                     style: TextStyle(
                       color: themeChange.getThem()
                           ? AppThemData.grey01
                           : AppThemData.grey10,
                       fontSize: 15,
                       fontFamily: AppThemData.semiBold,
                       fontWeight: FontWeight.w400,
                     ),
                   ),
                 ),*/
                 Obx(() {
                   return Container(
                     margin: EdgeInsets.symmetric(horizontal: 5,vertical: 35),
                     width: Responsive.width(100, context),
                     decoration: BoxDecoration(
                         borderRadius: BorderRadius.circular(20),
                         color: Colors.white
                     ),
                     child: Column(
                       children: [
                         SizedBox(height: 40,),
                         InkWell(
                           onTap: (){
                             controller.isSelected.value = 0;

                           },
                           child: Container(
                             padding: const EdgeInsets.symmetric(vertical: 25,horizontal: 35),
                             decoration: BoxDecoration(
                               borderRadius: BorderRadius.circular(10),
                               border: Border.all(color: AppThemData.selectUserBorderColor,width: 1.5),
                               gradient: LinearGradient(
                                 begin: Alignment(0.00, 1.00),
                                 end: Alignment(0, -1),
                                 colors: controller.isSelected.value == 0 ?AppThemData.gradient03:
                                 [AppThemData.selectUserBgColor,AppThemData.selectUserBgColor],
                               ),
                             ),
                             child: Column(
                               children: [
                                 Image.asset("assets/images/truck-driver_Img.png",height: 45,width: 45,),
                                 SizedBox(height: 10,),
                                 Text(
                                   "DRIVER".tr,
                                   textAlign: TextAlign.start,
                                   style: TextStyle(
                                     color: themeChange.getThem()
                                         ? AppThemData.grey01
                                         : AppThemData.grey10,
                                     fontSize: 18,
                                     fontFamily: AppThemData.semiBold,
                                     fontWeight: FontWeight.w500,
                                   ),
                                 )
                               ],
                             ),
                           ),

                         ),
                         SizedBox(height: 40,),
                         Row(
                           mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                             SizedBox(
                               width: Get.width/5,
                               child: Divider(
                                 height: 1,
                                 color: Colors.black,
                               ),
                             ),
                             Padding(
                               padding: const EdgeInsets.symmetric(horizontal: 8),
                               child: Text(
                                 "OR".tr,
                                 textAlign: TextAlign.center,
                                 style: TextStyle(
                                   color: themeChange.getThem()
                                       ? AppThemData.grey01
                                       : AppThemData.grey10,
                                   fontSize: 16,
                                   fontFamily: AppThemData.semiBold,
                                   fontWeight: FontWeight.w500,
                                 ),
                               ),
                             ),
                             SizedBox(
                               width: Get.width/5,
                               child: Divider(
                                 height: 1,
                                 color: Colors.black,
                               ),
                             ),
                           ],
                         ),
                         SizedBox(height: 40,),
                         InkWell(
                           onTap: (){
                             controller.isSelected.value = 1;

                             /*showDialog(context: context,
                                 barrierDismissible: false,
                                 builder: (BuildContext context){
                                   return CustomDialogBoxOnlyOk(
                                     title: "Alert".tr,
                                     descriptions: "Under Development".tr,
                                     buttonText: "Okay",
                                     onButtonTap: (){
                                       Get.back();
                                     },
                                     img: SvgPicture.asset('assets/icon/alert_ico.svg'),
                                   );
                                 });*/

                           },
                           child: Container(
                             padding: const EdgeInsets.symmetric(vertical: 25,horizontal: 35),
                             decoration: BoxDecoration(
                               borderRadius: BorderRadius.circular(10),
                               border: Border.all(color: AppThemData.selectUserBorderColor,width: 1.5),
                               gradient: LinearGradient(
                                 begin: Alignment(0.00, 1.00),
                                 end: Alignment(0, -1),
                                 colors: controller.isSelected.value == 1 ?AppThemData.gradient03:
                                 [AppThemData.selectUserBgColor,AppThemData.selectUserBgColor],
                               ),
                             ),
                             child: Column(
                               children: [
                                 Image.asset("assets/images/OwnerImg.png",height: 45,width: 45,),
                                 SizedBox(height: 10,),
                                 Text(
                                   "OWNER".tr,
                                   textAlign: TextAlign.start,
                                   style: TextStyle(
                                     color: themeChange.getThem()
                                         ? AppThemData.grey01
                                         : AppThemData.grey10,
                                     fontSize: 18,
                                     fontFamily: AppThemData.semiBold,
                                     fontWeight: FontWeight.w500,
                                   ),
                                 )
                               ],
                             ),
                           ),
                         ),
                         SizedBox(height: 40,),
                         Padding(
                           padding: const EdgeInsets.symmetric(horizontal: 10),
                           child: RoundedButtonGradiant(
                             title: "Continue".tr,
                             onPress: () {
                               if (controller.isSelected.value == 0){
                                 controller.createGuestUser();
                               }else{
                                 Get.to(const LoginScreenOwner());
                               }

                               //Get.to(GetStartedScreen());
                             },
                           ),
                         ),
                         SizedBox(height: 40,),

                       ],

                     ),

                   );
                 },)



               ],
             ),
           ),
          ),
        );
      },
    );


  }






}