import 'dart:convert';
import 'dart:math';

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
import 'package:phista/ui/parking_details_screen/parking_details_screen.dart';
import 'package:phista/utils/fire_store_utils.dart';
import 'package:phista/utils/utils.dart';

import '../constant/version_checker.dart';
import '../themes/custom_dialog_box.dart';
import 'package:http/http.dart' as http;

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


  @override
  void onInit() {

    getLocation();
    super.onInit();
      getCurrentUser();



  }

  void getCurrentUser()async{
    await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid()).then((value) {
      Constant.currentUserModel.value = value;
    },);

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
    FireStoreUtils()
        .getParkingNearest(
        latitude: Constant.currentLocation!.latitude,
        longLatitude: Constant.currentLocation!.longitude)
        .listen((event) {
      parkingList.value = [];
      parkingList.value = event;
      for (var element in parkingList) {
        addMarker(
            latitude: element.location!.latitude,
            longitude: element.location!.longitude,
            id: element.id.toString(),
            descriptor: parkingMarker!,
            descriptorOSM: parkingMarkerOSM!,
            rotation: 0);
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
    Widget? descriptorOSM,
    BitmapDescriptor? descriptor,
    double? rotation,
  }) {
    if (Constant.selectedMapType == 'osm') {
      Future.delayed(const Duration(seconds: 3), () {
        mapOsmController
            .addMarker(GeoPoint(latitude: latitude!, longitude: longitude!),
            markerIcon: MarkerIcon(
              iconWidget: descriptorOSM!,
            ),
            angle: pi / 3,
            iconAnchor: IconAnchor(
              anchor: Anchor.top,
            ))
            .then((value) {
          osmMarkers[id] = GeoPoint(latitude: latitude, longitude: longitude);
        });
      });

      update();
    } else {
      MarkerId markerId = MarkerId(id);
      Marker marker = Marker(
        markerId: markerId,
        icon: descriptor!,
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


  @override
  void dispose() {
    FireStoreUtils().getNearestOrderRequestController!.close();
    super.dispose();
  }
}