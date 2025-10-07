import 'dart:convert';
import 'dart:developer';
import 'dart:math' as MATH;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:phista/constant/constant.dart';
import 'package:phista/constant/show_toast_dialog.dart';
import 'package:phista/env.dart';
import 'package:phista/model/location_lat_lng.dart';
import 'package:phista/model/parking_model.dart';
import 'package:phista/utils/fire_store_utils.dart';
import 'package:phista/utils/utils.dart';
import '../../constant/version_checker.dart';
import '../../themes/app_them_data.dart';
import '../../themes/custom_dialog_box.dart';
import 'package:http/http.dart' as http;

import '../../ui/driver/booking_process/booking_parking_details_screen.dart';
import '../../ui/driver/parking_details_screen/parking_details_screen.dart';


class HomeController extends GetxController {
  RxBool isLoading = true.obs;

  GoogleMapController? mapController;
  BitmapDescriptor? parkingMarker;
  BitmapDescriptor? currentLocationMarker;
  //OSM
  late MapController mapOsmController;
  Map<String, GeoPoint> osmMarkers = <String, GeoPoint>{};
  Image? currentLocationMarkerOSM; //OSM
  Image? parkingMarkerOSM; //OSM
  Rx<TextEditingController> otpController = TextEditingController().obs;
  BitmapDescriptor? parkingRedMarker;
  Image? parkingRedMarkerOSM; //OSM
  BitmapDescriptor? parkingYellowMarker;
  Image? parkingYellowMarkerOSM; //OSM
  BitmapDescriptor? parkingGreenMarker;
  Image? parkingGreenMarkerOSM; //OSM
   var markerShowMap = <Marker>{}.obs;
  Map<String, dynamic> parkingDataCache = {};




@override
  void onReady() {
    super.onReady();

    Constant.isFromParkNow = false;
    log("globalParkingModel.value >> :-- ${Constant.globalParkingModel.value}");

    Future.delayed(Duration.zero,() {
      if( Constant.globalParkingModel.value != null){
        Get.to(() => const BookingParkingDetailsScreen(), arguments: {"parkingModel": Constant.globalParkingModel.value});
      }
        getLocation();
        getCurrentUser();

    },);

  }

  void getCurrentUser()async{
    await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid()).then((value) {
      Constant.currentUserModel.value = value;
    },);
    markerInit();
    //getParking();
  }

  getLocation() async {
    await addMarkerSetup();
    await Utils.getCurrentLocation().then((value) {
      print(value);
      if (value != null) {
        permissionDenied.value = false;
        mapOsmController = MapController(
            initPosition:
            GeoPoint(latitude: value.latitude, longitude: value.longitude),
            useExternalTracking: false); //OSM

        Constant.currentLocation = LocationLatLng(
            latitude: value.latitude, longitude: value.longitude);
      } else {
        isLoading.value = false;
        permissionDenied.value = true;
        mapOsmController = MapController(
            initPosition: GeoPoint(
                latitude: Constant.currentLocation != null
                    ? Constant.currentLocation!.latitude!
                    : 45.521563,
                longitude: Constant.currentLocation != null
                    ? Constant.currentLocation!.longitude!
                    : -122.677433),
            useExternalTracking: false); //OSM
      }
    });
    List<Placemark> placeMarks = await placemarkFromCoordinates(
        Constant.currentLocation!.latitude!,
        Constant.currentLocation!.longitude!);
    Constant.country = placeMarks.first.country;
    getTax();
    getParking();
    isLoading.value = false;
  }

  RxBool permissionDenied = false.obs;

  getTax() async {
    await FireStoreUtils().getTaxList().then((value) {
      if (value != null) {
        Constant.taxList = value;
      }
    });
  }

  RxList<ParkingModel> parkingList = <ParkingModel>[].obs;

  getParking() {
    FireStoreUtils().getParkingNearest(
        latitude: Constant.currentLocation!.latitude,
        longLatitude: Constant.currentLocation!.longitude)
        .listen((event) async {
      parkingList.value = [];
      parkingList.value = event;
      markerShowMap.clear();
      for (var element in parkingList) {
      var bookingPercentage =  await FireStoreUtils.getParkingBookingPercentage(element.id??"", element.parkingSpace??"");

        print("name :-- ${element.name} , bookingPercentage :- $bookingPercentage");

        addMarker(
            latitude: element.location!.latitude,
            longitude: element.location!.longitude,
            id: element.id.toString(),
            rotation: 0,
        percent: bookingPercentage);
      }

    });
  }

  addMarkerSetup() async {
    currentLocationMarkerOSM = Image.asset("assets/icon/ic_current_user.png",
        width: 30, height: 30); //OSM
    parkingMarkerOSM = Image.asset("assets/icon/ic_parking_icon.png",
        width: 30, height: 30); //OSM

    final Uint8List parking = await Constant()
        .getBytesFromAsset("assets/icon/ic_parking_icon.png", 100);
    parkingMarker = BitmapDescriptor.fromBytes(parking);

    final Uint8List currentLocation = await Constant()
        .getBytesFromAsset("assets/icon/ic_current_user.png", 100);
    currentLocationMarker = BitmapDescriptor.fromBytes(currentLocation);
  }

  RxMap<MarkerId, Marker> markers = <MarkerId, Marker>{}.obs;

  addMarker({
    required double? latitude,
    required double? longitude,
    required String id,
    double? rotation,
    double? percent
  })
  {

    if (Constant.selectedMapType == 'osm') {
      Future.delayed(const Duration(seconds: 3), () {
        mapOsmController
            .addMarker(GeoPoint(latitude: latitude!, longitude: longitude!),
            markerIcon: MarkerIcon(
              iconWidget:descriptorOSMFun(percent??0.0), //descriptorOSM!,
            ),
            angle: MATH.pi / 3,
            iconAnchor: IconAnchor(
              anchor: Anchor.top,
            ))
            .then((value) {
          osmMarkers[id] = GeoPoint(latitude: latitude, longitude: longitude);
        });
      });

      update();
    }
    else {
      MarkerId markerId = MarkerId(id);
      Marker marker = Marker(
        markerId: markerId,
        icon: descriptorFun(percent??0.0)!,
        position: LatLng(latitude ?? 0.0, longitude ?? 0.0),
        rotation: rotation ?? 0.0,
        onTap: () {
          redirect(id);
        },
      );
      markers[markerId] = marker;
    }
  }

  redirect(String id) async {
    ShowToastDialog.showLoader("Please wait..");
    await FireStoreUtils.getParkingDetails(id).then((value) {
      ShowToastDialog.closeLoader();
      Get.to(() => const ParkingDetailsScreen(),
          arguments: {"parkingModel": value!});
    });
  }



  Future<void> sendEmailWithTemplate({
    required String toEmail,
    required String templateId,
    required Map<String, dynamic> dynamicTemplateData,
  })
  async {
    final url = Uri.parse('https://api.sendgrid.com/v3/mail/send');



    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer ${ENV.sandGridApiKey}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "personalizations": [
          {
            "to": [
              {"email": toEmail}
            ],
            "dynamic_template_data": dynamicTemplateData,
          }
        ],
        "from": {"email": "support@phista.ca"},
        "template_id": templateId,
      }),
    );

    if (response.statusCode == 202) {
      print("✅ Email sent with template!");
    } else {
      print("❌ Failed to send email: ${response.statusCode}\n${response.body}");
    }
  }


  Future<void> sendEmailWithSendGrid({
    required String toEmail,
    required String subject,
    required String content,
  })
  async {
    final url = Uri.parse('https://api.sendgrid.com/v3/mail/send');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer ${ENV.sandGridApiKey}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "personalizations": [
          {
            "to": [
              {"email": toEmail}
            ],
            "subject": subject,
          }
        ],
        "from": {"email": "support@phista.ca"}, // must be verified
        "content": [
          {
            "type": "text/plain",
            "value": content,
          }
        ],
      }),
    );

    if (response.statusCode == 202) {
      print("Email sent!");
    } else {
      print("Failed to send email: ${response.body}");
    }
  }


  void markerInit()async{
    parkingGreenMarkerOSM = Image.asset("assets/icon/ic_parking_icon_green.png",
        width: 30, height: 30);
    final Uint8List parking = await Constant()
        .getBytesFromAsset("assets/icon/ic_parking_icon_green.png", 100);
    parkingGreenMarker = BitmapDescriptor.fromBytes(parking);

    parkingYellowMarkerOSM = Image.asset("assets/icon/ic_parking_icon.png",
        width: 30, height: 30);
    final Uint8List parking1 = await Constant()
        .getBytesFromAsset("assets/icon/ic_parking_icon.png", 100);
    parkingYellowMarker = BitmapDescriptor.fromBytes(parking1);


    parkingRedMarkerOSM = Image.asset("assets/icon/ic_parking_icon_red.png",
        width: 30, height: 30);
    final Uint8List parking2 = await Constant()
        .getBytesFromAsset("assets/icon/ic_parking_icon_red.png", 100);
    parkingRedMarker = BitmapDescriptor.fromBytes(parking2);


    print("latitude :-- ${Constant.currentLocation!.latitude} longitude :-- ${Constant.currentLocation!.longitude}");


  }


  Image? descriptorOSMFun(double percent){
    if(percent < 75 ){
      return parkingGreenMarkerOSM;
    }else if(percent < 100){
     return parkingYellowMarkerOSM;
    }else{
      return parkingRedMarkerOSM;
    }

  }

  BitmapDescriptor? descriptorFun(double percent){
    if(percent < 75){
      return parkingGreenMarker;
    }else if(percent < 100){
      return parkingYellowMarker;
    }else {
      return parkingRedMarker;
    }
  }


  getData(String parkingId,parkingSpace)async{
    if (parkingDataCache.containsKey(parkingId)) {
      return parkingDataCache[parkingId];
    }
    double value = await FireStoreUtils.getParkingBookingPercentage(parkingId??"",
        parkingSpace??"");
    return value.round() ;
  }



  Color getPercentColor(int percent){
    if(percent < 75){
      return AppThemData.success07;
    }else if(percent < 100){
      return AppThemData.primary05;
    }else {
      return AppThemData.error07;
    }
  }

  @override
  void dispose() {
    FireStoreUtils().getNearestOrderRequestController!.close();
    super.dispose();
  }
}