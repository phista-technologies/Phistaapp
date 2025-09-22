import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

import 'package:provider/provider.dart';

import '../../../constant/constant.dart';
import '../../controller/driver_controller/get_started_controller.dart';
import '../../../themes/app_them_data.dart';
import '../../../themes/responsive.dart';
import '../../../themes/round_button_gradiant.dart';
import '../../../themes/segment_button_gradiant.dart';
import '../../../utils/dark_theme_provider.dart';
import '../driver/auth_screen/login_screen.dart';
import '../driver/booking_process/booking_parking_details_screen.dart';

class GetStartedScreen extends StatelessWidget{
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetBuilder<GetStartedController>(
      init: GetStartedController(),
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
                    width: Get.width/1.5,
                    child: Text(
                      "Welcome to phista app".tr,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: themeChange.getThem()
                            ? AppThemData.grey01
                            : AppThemData.grey10,
                        fontSize: 35,
                        fontFamily: AppThemData.bold,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(height: 10,),
                  SizedBox(
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
                  ),
                   Spacer(),
                   Container(
                     margin: EdgeInsets.only(left: 5,right: 5,bottom: 10),
                     width: Responsive.width(100, context),
                     decoration: BoxDecoration(
                         borderRadius: BorderRadius.circular(20),
                         color: Colors.white
                     ),
                     child: Padding(
                       padding: const EdgeInsets.only(left: 15.0),
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         mainAxisAlignment: MainAxisAlignment.start,
                         children: [
                           Padding(
                             padding: const EdgeInsets.only(top: 21.0),
                             child: Image.asset("assets/images/ic_parking_iconnew.png",height: 68,width: 68,),
                           ),
                           SizedBox(height: 15,),
                           SizedBox(
                             width: Get.width,
                             child: Text(
                               "Get Started".tr,
                               textAlign: TextAlign.start,
                               style: TextStyle(
                                 color: themeChange.getThem()
                                     ? AppThemData.grey01
                                     : AppThemData.grey10,
                                 fontSize: 20,
                                 fontFamily: AppThemData.semiBold,
                                 fontWeight: FontWeight.w600,
                               ),
                             ),
                           ),
                           SizedBox(height: 10,),
                           Text(
                             "A few clicks away from beginning your journey.".tr,
                             textAlign: TextAlign.start,
                             style: TextStyle(
                               color: themeChange.getThem()
                                   ? AppThemData.getStartedgrayTextcolor
                                   : AppThemData.getStartedgrayTextcolor,
                               fontSize: 15,
                               fontFamily: AppThemData.medium,
                               fontWeight: FontWeight.w400,
                             ),
                           ),
                           SizedBox(height: 20,),
                           Padding(
                             padding: const EdgeInsets.symmetric(horizontal: 8),
                             child: RoundedButtonGradiant(
                               title: "Login/SignUp".tr,
                               onPress: () {
                                 Constant.isGustUser = true;
                                 Get.to(LoginScreen());


                               },
                             ),
                           ),
                           SizedBox(height: 20,),
                           Padding(
                             padding: const EdgeInsets.symmetric(horizontal: 8),
                             child: SegmentButtonGradiant(
                               title: "Browse parkings as guest".tr,
                               onPress: () async {
                                 print("parkingModel.value${controller.parkingModel.value}");


                                 Get.to(() => const BookingParkingDetailsScreen(),arguments:{"parkingModel": controller.parkingModel.value});

                               },),
                           ),
                           SizedBox(height: 25,),


                         ],
                       ),
                     ),
                   )

                ],
              ),
            ),
          ),
        );
      },
    );
  }
}