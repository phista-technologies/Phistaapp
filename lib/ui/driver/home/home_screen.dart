// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:phista/constant/constant.dart';
import 'package:phista/constant/show_toast_dialog.dart';
import 'package:phista/controller/driver_controller/home_controller.dart';
import 'package:phista/model/parking_model.dart';
import 'package:phista/themes/app_them_data.dart';
import 'package:phista/themes/responsive.dart';
import 'package:phista/themes/round_button_fill.dart';
import 'package:phista/ui/owner/auth_screen/login_screen_owner.dart';
import 'package:phista/utils/dark_theme_provider.dart';
import 'package:phista/utils/fire_store_utils.dart';
import 'package:phista/utils/network_image_widget.dart';
import 'package:provider/provider.dart';
import '../../../themes/custom_dialog_box.dart';
import '../../owner/app_not_access_screen_owner.dart';
import '../../owner/dashboard_screen_owner.dart';
import '../../owner/subscription_plan_screen/subscription_plan_screen_owner.dart';
import '../auth_screen/login_screen.dart';
import '../booking_process/booking_parking_details_screen.dart';
import '../chat/inbox_screen.dart';
import '../parking_details_screen/parking_details_screen.dart';
import '../search/search_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(100),
          child: Padding(
            padding: const EdgeInsets.only(top: 25),
            child: AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              automaticallyImplyLeading: false,
              titleSpacing: 10,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Expanded Search Field
                  kIsWeb
                      ? InkWell(
                          onTap: () {
                            Get.to(const SearchScreen());
                          },
                          child: searchField())
                      : Expanded(
                          flex: 2,
                          child: InkWell(
                            onTap: () {
                              print(
                                  "Constant.currentUserModel.value?.role :: - ${Constant.currentUserModel.value?.role}");
                              Get.to(const SearchScreen());
                            },
                            child: searchField(),
                          ),
                        ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () {
                      showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (BuildContext context) {
                            return CustomDialogBox(
                                title: "Alert".tr,
                                descriptions: "do you want to switch as owner?".tr,
                                img: Image.asset(
                                  "assets/icon/switch_profile_ico.png",
                                  height: 85,
                                  width: 85,
                                ),
                                positiveString: "Ok".tr,
                                negativeString: "Cancel".tr,
                                positiveBgColor: AppThemData.success07,
                                positiveClick: () async{
                                  print("currentUserModel:-  ${Constant.currentUserModel.value?.role}");

                                  if (Constant.currentUserModel.value?.role == "Guest"){
                                    print("object1");
                                    Get.back();
                                    Get.to(LoginScreenOwner());
                                    //Constant.isGustUser = true;
                                  }else{
                                    bool isPlanExpire = false;
                                    if (Constant.currentUserModel.value?.subscriptionPlan?.id != null) {
                                      if (Constant.currentUserModel.value?.subscriptionExpiryDate == null) {
                                        if (Constant.currentUserModel.value?.subscriptionPlan?.expiryDay == '-1') {
                                          isPlanExpire = false;
                                        } else {
                                          isPlanExpire = true;
                                        }
                                      } else {
                                        if (Constant.currentUserModel.value!.subscriptionExpiryDate != null){
                                          DateTime expiryDate = Constant.currentUserModel.value!.subscriptionExpiryDate!.toDate();
                                          isPlanExpire = expiryDate.isBefore(DateTime.now());
                                        }
                                      }
                                    }
                                    else {
                                      isPlanExpire = true;
                                    }
                                    if ( Constant.currentUserModel.value?.subscriptionPlanId == null || isPlanExpire == true) {
                                      if (Constant.adminCommission?.enable == false && Constant.isSubscriptionModelApplied == false) {
                                        Get.offAll(const DashBoardScreenOwner());
                                      } else {
                                        Get.back();
                                        Get.to(const SubscriptionPlanScreenOwner(isBack: true),);
                                      }
                                    }
                                    else if (Constant.currentUserModel.value?.subscriptionPlan?.features?.ownerMobileApp == true) {

                                      Get.offAll(const DashBoardScreenOwner());
                                    } else {
                                      Get.offAll(const AppNotAccessScreenOwner());
                                    }
                                  }
                                },
                                negativeClick: () async {
                                  Get.back();
                                }
                            );
                          });

                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10, bottom: 10),
                      child: Image.asset(
                        'assets/icon/switch_profile_ico.png',
                        height: kIsWeb ? 70 : 35, // adjust size as needed
                        width: kIsWeb ? 70 : 35,
                        color: themeChange.getThem()
                            ? AppThemData.primary06
                            : AppThemData.primary06,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: GetX<HomeController>(
            init: HomeController(),
            builder: (controller) {
              return controller.isLoading.value
                  ? Constant.loader()
                  : controller.permissionDenied.value
                      ? Center(
                          child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 62),
                          child: RoundedButtonFill(
                            title: "Allow Permission".tr,
                            height: 5.5,
                            color: AppThemData.primary06,
                            fontSizes: 16,
                            onPress: () async {
                              controller.getLocation();
                            },
                          ),
                        ))
                      : Stack(
                          children: [
                            Constant.selectedMapType == 'osm'
                                ? OSMFlutter(
                                    controller: controller.mapOsmController,
                                    osmOption: const OSMOption(
                                      userTrackingOption: UserTrackingOption(
                                        enableTracking: false,
                                        unFollowUser: false,
                                      ),
                                      zoomOption: ZoomOption(
                                        initZoom: 16,
                                        minZoomLevel: 2,
                                        maxZoomLevel: 19,
                                        stepZoom: 1.0,
                                      ),
                                    ),
                                    onMapIsReady: (active) async {
                                      if (active) {
                                        // controller.getArgument();
                                        // ShowToastDialog.closeLoader();
                                      }
                                    })
                                : GoogleMap(
                                    myLocationEnabled: true,
                                    myLocationButtonEnabled: true,
                                    zoomControlsEnabled: false,
                                    mapType: MapType.terrain,
                                    markers: Set<Marker>.of(
                                        controller.markers.values),
                                    onMapCreated:
                                        (GoogleMapController mapController) {
                                      controller.mapController = mapController;
                                    },
                                    mapToolbarEnabled: true,
                                    initialCameraPosition: CameraPosition(
                                      zoom: 15,
                                      target: LatLng(
                                        Constant.currentLocation != null
                                            ? Constant
                                                .currentLocation!.latitude!
                                            : 45.521563,
                                        Constant.currentLocation != null
                                            ? Constant
                                                .currentLocation!.longitude!
                                            : -122.677433,
                                      ),
                                    ),
                                  ),
                            /*if(Constant.currentUserModel.value?.role == "Guest")
                            Positioned(
                              top: 10,
                              right: 10,
                              left: 10,
                              child: Container(
                                color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                                  horizontalTitleGap: 6,
                                  onTap: (){
                                    Get.to(LoginScreenOwner());
                                    Constant.isGustUser = true;
                                  },
                                  trailing: const Icon(Icons.arrow_forward_ios, size: 18,color: AppThemData.primary06,),
                                  leading: Image.asset(
                                    "assets/icon/switch_profile_ico.png",
                                    height: 26,
                                    color: AppThemData.primary06,
                                  ),
                                  title: Text(
                                    "Continue as owner".tr,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: AppThemData.bold,
                                        color: AppThemData.primary06),
                                  ),
                                ),
                              ),
                            ),*/
                            controller.parkingList.isEmpty
                                ? Container()
                                : Align(
                                    alignment: Alignment.bottomCenter,
                                    child: SizedBox(
                                      height: Responsive.height(40, context),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          /*Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 22),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                    child: Text("Near You".tr,
                                                        style: TextStyle(
                                                          color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey10,
                                                          fontSize: 16,
                                                          fontFamily:
                                                              AppThemData
                                                                  .robotoSemiBold,
                                                        ))),
                                                InkWell(
                                                  onTap: () async {
                                                    Get.to(
                                                        const SearchScreen());
                                                  },
                                                  child: Row(
                                                    children: [
                                                      Text("View All".tr,
                                                          style:
                                                              const TextStyle(
                                                            color: AppThemData
                                                                .primary09,
                                                            fontSize: 14,
                                                            fontFamily:
                                                                AppThemData
                                                                    .robotoSemiBold,
                                                          )),
                                                      const Icon(
                                                        Icons.chevron_right,
                                                        color: AppThemData
                                                            .primary09,
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),*/
                                          Expanded(
                                            child: PageView.builder(
                                              padEnds: false,
                                              pageSnapping: true,
                                              scrollBehavior:
                                                  ScrollConfiguration.of(
                                                          context)
                                                      .copyWith(
                                                dragDevices: {
                                                  PointerDeviceKind.touch,
                                                  PointerDeviceKind.mouse,
                                                  PointerDeviceKind.trackpad,
                                                },
                                              ),
                                              physics:
                                                  const AlwaysScrollableScrollPhysics(), // Always enable scrolling
                                              controller: PageController(
                                                  viewportFraction:
                                                      kIsWeb ? 0.5 : 0.95),
                                              onPageChanged: (value) {
                                                if (Constant.selectedMapType ==
                                                    'osm') {
                                                  controller.mapOsmController.moveTo(
                                                      GeoPoint(
                                                          latitude: controller
                                                              .parkingList[
                                                                  value]
                                                              .location!
                                                              .latitude!,
                                                          longitude: controller
                                                              .parkingList[
                                                                  value]
                                                              .location!
                                                              .longitude!),
                                                      animate: true);
                                                } else {
                                                  CameraUpdate cameraUpdate =
                                                      CameraUpdate
                                                          .newCameraPosition(
                                                              CameraPosition(
                                                    zoom: 18,
                                                    target: LatLng(
                                                      controller
                                                          .parkingList[value]
                                                          .location!
                                                          .latitude!,
                                                      controller
                                                          .parkingList[value]
                                                          .location!
                                                          .longitude!,
                                                    ),
                                                  ));
                                                  controller.mapController!
                                                      .animateCamera(
                                                          cameraUpdate);
                                                }
                                              },
                                              itemCount:
                                                  controller.parkingList.length,
                                              scrollDirection: Axis.horizontal,
                                              itemBuilder: (context, index) {
                                                ParkingModel parkingModel =
                                                    controller
                                                        .parkingList[index];
                                                return Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal:
                                                          index == 0 ? 10 : 10),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            14),
                                                    child: Container(
                                                      color: themeChange
                                                              .getThem()
                                                          ? AppThemData.grey10
                                                          : AppThemData.white,
                                                      child: Stack(
                                                        children: [
                                                          Column(
                                                            children: [
                                                              SizedBox(
                                                                height: 10,
                                                              ),
                                                              Padding(
                                                                padding: EdgeInsets.only(
                                                                    left: index ==
                                                                            0
                                                                        ? 17
                                                                        : 8),
                                                                child: Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .topLeft,
                                                                  child: Text(
                                                                      "Parking near you"
                                                                          .tr,
                                                                      style:
                                                                          TextStyle(
                                                                        color: themeChange.getThem()
                                                                            ? AppThemData.grey01
                                                                            : AppThemData.grey10,
                                                                        fontSize:
                                                                            16,
                                                                        fontFamily:
                                                                            AppThemData.bold,
                                                                      )),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: 10,
                                                              ),
                                                              ClipRRect(
                                                                borderRadius:
                                                                    const BorderRadius
                                                                        .all(
                                                                        Radius.circular(
                                                                            14)), // You can adjust radius
                                                                child: SizedBox(
                                                                  width: Responsive
                                                                      .width(85,
                                                                          context),
                                                                  height: 140,
                                                                  child:
                                                                      NetworkImageWidget(
                                                                    imageUrl: parkingModel
                                                                        .image
                                                                        .toString(),
                                                                  ),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        7,
                                                                    vertical:
                                                                        5),
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Padding(
                                                                      padding: EdgeInsets.only(
                                                                          left: index == 0
                                                                              ? 10
                                                                              : 5),
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          Expanded(
                                                                            child:
                                                                                Text(
                                                                              parkingModel.name.toString(),
                                                                              style: TextStyle(
                                                                                color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey10,
                                                                                fontSize: 16,
                                                                                height: 1.57,
                                                                                fontFamily: AppThemData.robotoBold,
                                                                                fontWeight: FontWeight.w500,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    /*const SizedBox(
                                                                      height: 7,
                                                                    ),
                                                                    Row(
                                                                      children: [
                                                                        Expanded(
                                                                          flex:
                                                                              1,
                                                                          child:
                                                                              Text(
                                                                            "${Constant.amountShow(amount: parkingModel.perHrPrice.toString())}/hour",
                                                                            style:
                                                                                const TextStyle(
                                                                              color: AppThemData.blueLight07,
                                                                              fontSize: 11.5,
                                                                              height: 1.57,
                                                                              fontFamily: AppThemData.medium,
                                                                              fontWeight: FontWeight.w500,
                                                                            ),
                                                                            maxLines:
                                                                                1,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                          ),
                                                                        ),
                                                                        Expanded(
                                                                          flex:
                                                                              2,
                                                                          child:
                                                                              Text(
                                                                            "${Constant.amountShow(amount: parkingModel.dailyPrice.toString())}/daily(5h+).".tr,
                                                                            style:
                                                                                const TextStyle(
                                                                              color: AppThemData.blueLight07,
                                                                              fontSize: 11.5,
                                                                              height: 1.57,
                                                                              fontFamily: AppThemData.medium,
                                                                              fontWeight: FontWeight.w500,
                                                                            ),
                                                                            maxLines:
                                                                                1,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                          ),
                                                                        ),
                                                                        Expanded(
                                                                          flex:
                                                                              2,
                                                                          child:
                                                                              Text(
                                                                            "${Constant.amountShow(amount: parkingModel.monthlyPrice.toString())}/month".tr,
                                                                            style:
                                                                                const TextStyle(
                                                                              color: AppThemData.blueLight07,
                                                                              fontSize: 11.5,
                                                                              height: 1.57,
                                                                              fontFamily: AppThemData.medium,
                                                                              fontWeight: FontWeight.w500,
                                                                            ),
                                                                            maxLines:
                                                                                1,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),*/
                                                                    const SizedBox(
                                                                      height: 7,
                                                                    ),
                                                                    Padding(
                                                                      padding: EdgeInsets.only(
                                                                          left: index == 0
                                                                              ? 10
                                                                              : 5),
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          Expanded(
                                                                            child:
                                                                                Text(
                                                                              parkingModel.address.toString(),
                                                                              maxLines: 1,
                                                                              style: TextStyle(
                                                                                color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey10,
                                                                                fontSize: 12,
                                                                                height: 1.57,
                                                                                overflow: TextOverflow.ellipsis,
                                                                                fontFamily: AppThemData.robotoRegular,
                                                                                fontWeight: FontWeight.w500,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                            width:
                                                                                10,
                                                                          ),
                                                                          Row(
                                                                            children: [
                                                                              SvgPicture.asset(
                                                                                parkingModel.parkingType == "2" ? "assets/icon/ic_bike.svg" : "assets/icon/ic_car_fill.svg",
                                                                                color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey10,
                                                                              ),
                                                                              Text(
                                                                                " ${parkingModel.parkingType.toString()} wheel".tr,
                                                                                maxLines: 1,
                                                                                style: TextStyle(
                                                                                  color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey10,
                                                                                  fontSize: 12,
                                                                                  height: 1.57,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                  fontFamily: AppThemData.robotoSemiBold,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      height:
                                                                          10,
                                                                    ),
                                                                    Padding(
                                                                      padding: EdgeInsets.only(
                                                                          left: index == 0
                                                                              ? 10
                                                                              : 0),
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          Expanded(
                                                                            child:
                                                                                RoundedButtonFill(
                                                                              title: "Book Now".tr,
                                                                              height: 4.5,
                                                                              color: AppThemData.primary06,
                                                                              fontSizes: 12,
                                                                              radius: 10,
                                                                              onPress: () {
                                                                                if (Constant.currentUserModel.value?.role.toString() == "Guest") {
                                                                                  showDialog(
                                                                                      context: context,
                                                                                      barrierDismissible: true,
                                                                                      builder: (BuildContext context) {
                                                                                        return CustomDialogBox(
                                                                                          title: "Alert".tr,
                                                                                          descriptions: "Would you like to park immediately or reserve this spot for later?".tr,
                                                                                          img: Image.asset(
                                                                                            "assets/images/parking_icon.png",
                                                                                            height: 85,
                                                                                            width: 85,
                                                                                          ),
                                                                                          positiveString: "Park Now".tr,
                                                                                          negativeString: "Reserve Parking".tr,
                                                                                          positiveBgColor: AppThemData.success07,
                                                                                          positiveClick: () async {
                                                                                            Constant.isFromParkNow = true;

                                                                                            if (parkingModel.userId == FireStoreUtils.getCurrentUid()) {
                                                                                              ShowToastDialog.showToast("You can't book your own parking.");
                                                                                            } else {
                                                                                              Get.back();
                                                                                              if (Constant.currentUserModel.value?.role.toString() == "Guest") {
                                                                                                print("if LoginScreen");
                                                                                                Constant.isGustUser = true;
                                                                                                showDialog(
                                                                                                    context: context,
                                                                                                    barrierDismissible: true,
                                                                                                    builder: (BuildContext context) {
                                                                                                      return CustomDialogPayAsGuest(
                                                                                                        img: Image.asset(
                                                                                                          "assets/images/parking_icon.png",
                                                                                                          height: 85,
                                                                                                          width: 85,
                                                                                                        ),
                                                                                                        positiveString: "Login/Signup".tr,
                                                                                                        negativeString: "Pay as a guest".tr,
                                                                                                        positiveBgColor: AppThemData.success07,
                                                                                                        positiveClick: () async {
                                                                                                          Get.back();
                                                                                                          Constant.globalParkingModel.value = parkingModel;
                                                                                                          print("globalParkingModel.value Home :-- ${Constant.globalParkingModel.value}");
                                                                                                          Get.to(const LoginScreen());
                                                                                                        },
                                                                                                        negativeClick: () async {
                                                                                                          Get.back();
                                                                                                          Get.to(() => const BookingParkingDetailsScreen(), arguments: {
                                                                                                            "parkingModel": parkingModel
                                                                                                          });
                                                                                                        },
                                                                                                      );
                                                                                                    });
                                                                                              } else {
                                                                                                if (parkingModel.userId == FireStoreUtils.getCurrentUid()) {
                                                                                                  ShowToastDialog.showToast("You can't book your own parking.");
                                                                                                } else {
                                                                                                  print("else BookingParkingDetailsScreen");
                                                                                                  Get.to(() => const BookingParkingDetailsScreen(), arguments: {
                                                                                                    "parkingModel": parkingModel
                                                                                                  });
                                                                                                }
                                                                                              }
                                                                                              //Get.to(() => const GetStartedScreen(),arguments: {"parkingModel":parkingModel} );
                                                                                            }
                                                                                          },
                                                                                          negativeClick: () async {
                                                                                            Constant.isFromParkNow = false;
                                                                                            Get.back();
                                                                                            if (Constant.currentUserModel.value?.role.toString() == "Guest") {
                                                                                              showDialog(
                                                                                                  context: context,
                                                                                                  barrierDismissible: true,
                                                                                                  builder: (BuildContext context) {
                                                                                                    return CustomDialogBox(
                                                                                                      title: "Alert".tr,
                                                                                                      descriptions: "To reserve the parking you should log in first".tr,
                                                                                                      img: Image.asset(
                                                                                                        "assets/images/parking_icon.png",
                                                                                                        height: 85,
                                                                                                        width: 85,
                                                                                                      ),
                                                                                                      positiveString: "Continue".tr,
                                                                                                      negativeString: "Cancel".tr,
                                                                                                      positiveBgColor: AppThemData.success07,
                                                                                                      positiveClick: () async {
                                                                                                        Get.back();
                                                                                                        Constant.isGustUser = true;
                                                                                                        Constant.globalParkingModel.value = parkingModel;
                                                                                                        print("globalParkingModel.value Home2 :-- ${Constant.globalParkingModel.value}");
                                                                                                        Get.to(const LoginScreen());
                                                                                                      },
                                                                                                      negativeClick: () async {
                                                                                                        Get.back();
                                                                                                      },
                                                                                                    );
                                                                                                  });
                                                                                            } else {
                                                                                              if (parkingModel.userId == FireStoreUtils.getCurrentUid()) {
                                                                                                ShowToastDialog.showToast("You can't book your own parking.");
                                                                                              } else {
                                                                                                Get.to(() => const BookingParkingDetailsScreen(), arguments: {
                                                                                                  "parkingModel": parkingModel
                                                                                                });
                                                                                              }
                                                                                            }
                                                                                          },
                                                                                        );
                                                                                      });
                                                                                } else {
                                                                                  if (parkingModel.userId == FireStoreUtils.getCurrentUid()) {
                                                                                    ShowToastDialog.showToast("You can't book your own parking.");
                                                                                  } else {
                                                                                    Get.to(() => const BookingParkingDetailsScreen(), arguments: {
                                                                                      "parkingModel": parkingModel
                                                                                    });
                                                                                  }
                                                                                }
                                                                                /*  if (Constant.currentUserModel.value?.role.toString() == "Guest") {
                                                                                  /// Show popup
                                                                                  showDialog(
                                                                                      context: context,
                                                                                      barrierDismissible: true,
                                                                                      builder: (BuildContext context) {
                                                                                        return CustomDialogBox(
                                                                                          title: "Alert".tr,
                                                                                          descriptions: "Would you like to park immediately or reserve this spot for later?".tr,
                                                                                          img: Image.asset(
                                                                                            "assets/images/parking_icon.png",
                                                                                            height: 85,
                                                                                            width: 85,
                                                                                          ),
                                                                                          positiveString: "Park Now".tr,
                                                                                          negativeString: "Reserve Parking".tr,
                                                                                          positiveBgColor: AppThemData.success07,
                                                                                          positiveClick: () async {
                                                                                            if (parkingModel.userId == FireStoreUtils.getCurrentUid()) {
                                                                                              ShowToastDialog.showToast("You can't book your own parking.");
                                                                                            } else {
                                                                                              Get.back();

                                                                                              Constant.isGustUser = true;
                                                                                              showDialog(
                                                                                                  context: context,
                                                                                                  barrierDismissible: true,
                                                                                                  builder: (BuildContext context){
                                                                                                    return CustomDialogPayAsGuest(
                                                                                                      img: Image.asset("assets/images/parking_icon.png",height: 85,width: 85,),
                                                                                                      positiveString: "Login/Signup".tr,
                                                                                                      negativeString: "Pay as a guest".tr,
                                                                                                      positiveBgColor: AppThemData.success07,
                                                                                                      positiveClick: () async {
                                                                                                        Get.back();
                                                                                                        Constant.globalParkingModel.value = parkingModel;
                                                                                                        print("globalParkingModel.value Home :-- ${Constant.globalParkingModel.value}");
                                                                                                        Get.to(const LoginScreen());
                                                                                                      },
                                                                                                      negativeClick: () async {
                                                                                                        Get.back();
                                                                                                        Get.to(() => const BookingParkingDetailsScreen(), arguments: {"parkingModel": parkingModel});
                                                                                                      },
                                                                                                    );
                                                                                                  });

                                                                                                   //Get.to(() => const GetStartedScreen(),arguments: {"parkingModel":parkingModel} );

                                                                                            }
                                                                                          },
                                                                                          negativeClick: () async {
                                                                                            Get.back();
                                                                                          showDialog(
                                                                                              context: context,
                                                                                              barrierDismissible: true,
                                                                                              builder: (BuildContext context){
                                                                                                return CustomDialogBox(title: "Alert".tr,
                                                                                                  descriptions: "To reserve the parking you should log in first".tr,
                                                                                                  img: Image.asset("assets/images/parking_icon.png",height: 85,width: 85,),
                                                                                                  positiveString: "Continue".tr,
                                                                                                  negativeString: "Cancel".tr,
                                                                                                  positiveBgColor: AppThemData.success07,
                                                                                                  positiveClick: () async {
                                                                                                    Get.back();
                                                                                                    Constant.isGustUser = true;
                                                                                                    Constant.globalParkingModel.value = parkingModel;
                                                                                                    print("globalParkingModel.value Home2 :-- ${Constant.globalParkingModel.value}");
                                                                                                    Get.to(const LoginScreen());
                                                                                                  },
                                                                                                  negativeClick: () async {
                                                                                                    Get.back();

                                                                                                  },
                                                                                                );
                                                                                              });

                                                                                          },
                                                                                        );
                                                                                      });
                                                                                }
                                                                                else {
                                                                                  if (parkingModel.userId == FireStoreUtils.getCurrentUid()) {
                                                                                    ShowToastDialog.showToast("You can't book your own parking.");
                                                                                  } else {
                                                                                    Get.to(() => const BookingParkingDetailsScreen(), arguments: {
                                                                                      "parkingModel": parkingModel
                                                                                    });
                                                                                  }
                                                                                }*/
                                                                              },
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                            width:
                                                                                10,
                                                                          ),
                                                                          Expanded(
                                                                            child:
                                                                                RoundedButtonFill(
                                                                              title: "View Details".tr,
                                                                              radius: 10,
                                                                              height: 4.5,
                                                                              /* icon:
                                                                                  Icon(Icons.chevron_right, color: themeChange.getThem() ? AppThemData.white : AppThemData.grey11),*/
                                                                              color: themeChange.getThem() ? AppThemData.grey10 : AppThemData.grey10,
                                                                              textColor: themeChange.getThem() ? AppThemData.white : AppThemData.white,
                                                                              fontSizes: 12,
                                                                              isRight: true,
                                                                              onPress: () {
                                                                                Get.to(() => const ParkingDetailsScreen(), arguments: {
                                                                                  "parkingModel": parkingModel
                                                                                });
                                                                              },
                                                                            ),
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                  ],
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                          /* Positioned(
                                                            top: 10,
                                                            left: 10,
                                                            child: Container(
                                                              decoration:
                                                                  const BoxDecoration(
                                                                color: AppThemData
                                                                    .primary01,
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            20)),
                                                              ),
                                                              child: Padding(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          10,
                                                                      vertical:
                                                                          4),
                                                                  child: Row(
                                                                    children: [
                                                                      const Icon(
                                                                          Icons
                                                                              .star,
                                                                          size:
                                                                              16,
                                                                          color:
                                                                              AppThemData.primary07),
                                                                      const SizedBox(
                                                                          width:
                                                                              5),
                                                                      Text(
                                                                        Constant.calculateReview(
                                                                            reviewCount:
                                                                                parkingModel.reviewCount,
                                                                            reviewSum: parkingModel.reviewSum),
                                                                        style: const TextStyle(
                                                                            color:
                                                                                AppThemData.grey10,
                                                                            fontFamily: AppThemData.semiBold),
                                                                      ),
                                                                    ],
                                                                  )),
                                                            ),
                                                          ),*/
                                                          /* FutureBuilder<
                                                              dynamic>(
                                                            future: controller
                                                                .getData(
                                                                    parkingModel
                                                                            .id ??
                                                                        "",
                                                                    parkingModel
                                                                        .parkingSpace),
                                                            builder: (context,
                                                                snapshot) {
                                                              if (controller
                                                                  .parkingDataCache
                                                                  .containsKey(
                                                                      parkingModel
                                                                          .id)) {
                                                                return Positioned(
                                                                  top: 10,
                                                                  right: 10,
                                                                  child:
                                                                      Container(
                                                                    decoration:
                                                                         BoxDecoration(
                                                                      color: controller.getPercentColor(int.parse(controller.parkingDataCache[parkingModel.id].toString())),
                                                                      borderRadius:
                                                                          BorderRadius.all(
                                                                              Radius.circular(20)),
                                                                    ),
                                                                    child: Padding(
                                                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                                        child: Row(
                                                                          children: [
                                                                            Text(
                                                                              "${controller.parkingDataCache[parkingModel.id]}%",
                                                                              style: const TextStyle(color: AppThemData.white, fontFamily: AppThemData.bold),
                                                                            ),
                                                                            const SizedBox(width: 5),
                                                                            Text(
                                                                              "full".tr,
                                                                              style: const TextStyle(color: AppThemData.white, fontFamily: AppThemData.semiBold),
                                                                            ),
                                                                          ],
                                                                        )),
                                                                  ),
                                                                );
                                                              }

                                                              if (snapshot
                                                                      .connectionState ==
                                                                  ConnectionState
                                                                      .waiting) {
                                                                return SizedBox();
                                                              }
                                                              if (snapshot.hasData) {controller.parkingDataCache[parkingModel.id ?? ""] = snapshot.data;
                                                                return Positioned(
                                                                  top: 10,
                                                                  right: 10,
                                                                  child:
                                                                      Container(
                                                                      decoration: BoxDecoration(
                                                                      color: controller.getPercentColor(snapshot.data),
                                                                      borderRadius: BorderRadius.all(Radius.circular(20)),
                                                                    ),
                                                                    child: Padding(
                                                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                                        child: Row(
                                                                          children: [
                                                                            Text(
                                                                              "${snapshot.data ?? ''}%",
                                                                              style: const TextStyle(color: AppThemData.white, fontFamily: AppThemData.bold),
                                                                            ),
                                                                            const SizedBox(width: 5),
                                                                            Text(
                                                                              "full".tr,
                                                                              style: const TextStyle(color: AppThemData.white, fontFamily: AppThemData.semiBold),
                                                                            ),
                                                                          ],
                                                                        )),
                                                                  ),
                                                                );
                                                              }
                                                              return Positioned(
                                                                top: 10,
                                                                right: 10,
                                                                child:
                                                                    Container(
                                                                  decoration:
                                                                      const BoxDecoration(
                                                                    color: AppThemData
                                                                        .success07,
                                                                    borderRadius:
                                                                        BorderRadius.all(
                                                                            Radius.circular(20)),
                                                                  ),
                                                                  child:
                                                                      Padding(
                                                                          padding: const EdgeInsets
                                                                              .symmetric(
                                                                              horizontal:
                                                                                  10,
                                                                              vertical:
                                                                                  4),
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              Text(
                                                                                "0%",
                                                                                style: const TextStyle(color: AppThemData.white, fontFamily: AppThemData.bold),
                                                                              ),
                                                                              const SizedBox(width: 5),
                                                                              Text(
                                                                                "full".tr,
                                                                                style: const TextStyle(color: AppThemData.white, fontFamily: AppThemData.semiBold),
                                                                              ),
                                                                            ],
                                                                          )),
                                                                ),
                                                              );
                                                            },
                                                          ),*/
                                                          FutureBuilder<
                                                              dynamic>(
                                                            future: controller
                                                                .getData(
                                                              parkingModel.id ??
                                                                  "",
                                                              parkingModel
                                                                  .parkingSpace,
                                                            ),
                                                            builder: (context,
                                                                snapshot) {
                                                              if (controller
                                                                  .parkingDataCache
                                                                  .containsKey(
                                                                      parkingModel
                                                                          .id)) {
                                                                var data = controller
                                                                        .parkingDataCache[
                                                                    parkingModel
                                                                        .id];
                                                                int booked =
                                                                    data['bookedSlots'] ??
                                                                        0;
                                                                int total =
                                                                    data['totalSlots'] ??
                                                                        0;
                                                                int available =
                                                                    total -
                                                                        booked;

                                                                return Positioned(
                                                                  top: 42,
                                                                  left: index == 0 ? 9 : 9,
                                                                  child: Container(
                                                                    decoration: BoxDecoration(
                                                                      color: AppThemData.primary06,
                                                                      borderRadius: const BorderRadius.only(
                                                                          topRight: Radius.circular(15),
                                                                          bottomRight: Radius.circular(15)),
                                                                    ),
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          Text("$available of $total",style:
                                                                                const TextStyle(
                                                                              color: AppThemData.bookNowTextColor,
                                                                              fontFamily: AppThemData.robotoBold,
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                              width: 5),
                                                                          Text(
                                                                            "available",
                                                                            style:
                                                                                const TextStyle(
                                                                              color: AppThemData.grey10,
                                                                              fontFamily: AppThemData.robotoSemiBold,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                );
                                                              }

                                                              if (snapshot
                                                                      .connectionState ==
                                                                  ConnectionState
                                                                      .waiting) {
                                                                return const SizedBox();
                                                              }

                                                              if (snapshot
                                                                  .hasData) {
                                                                controller
                                                                        .parkingDataCache[
                                                                    parkingModel
                                                                            .id ??
                                                                        ""] = snapshot
                                                                    .data;
                                                                var data =
                                                                    snapshot
                                                                        .data;
                                                                int booked =
                                                                    data['bookedSlots'] ??
                                                                        0;
                                                                int total =
                                                                    data['totalSlots'] ??
                                                                        0;
                                                                int available =
                                                                    total -
                                                                        booked;

                                                                return Positioned(
                                                                  top: 42,
                                                                  left:
                                                                      index == 0
                                                                          ? 18
                                                                          : 9,
                                                                  child:
                                                                      Container(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: AppThemData
                                                                          .primary06,
                                                                      borderRadius: const BorderRadius
                                                                          .only(
                                                                          topRight: Radius.circular(
                                                                              15),
                                                                          bottomRight:
                                                                              Radius.circular(15)),
                                                                    ),
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              10,
                                                                          vertical:
                                                                              4),
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          Text(
                                                                            "$available of $total",
                                                                            style:
                                                                                const TextStyle(
                                                                              color: AppThemData.bookNowTextColor,
                                                                              fontFamily: AppThemData.robotoBold,
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                              width: 5),
                                                                          Text(
                                                                            "available",
                                                                            style:
                                                                                const TextStyle(
                                                                              color: AppThemData.grey10,
                                                                              fontFamily: AppThemData.robotoSemiBold,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                );
                                                              }

                                                              return const SizedBox();
                                                            },
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                          ],
                        );
            }),
      ),
    );
  }

  Widget searchField() {
    return Container(
      margin: const EdgeInsets.only(left: 15, bottom: 10, top: 10),
      height: 50,
      width: kIsWeb ? 300 : 0,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppThemData.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppThemData.grey07, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 15,
            height: 15,
            decoration: const BoxDecoration(
              color: AppThemData.grey10,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 15),
          Text(
            "Search".tr,
            style: TextStyle(
              fontSize: 14,
              color: AppThemData.grey10,
              fontWeight: FontWeight.w500,
              fontFamily: AppThemData.robotoMedium,
            ),
          ),
        ],
      ),
    );
  }
}
