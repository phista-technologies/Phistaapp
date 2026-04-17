import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:provider/provider.dart';

import '../../../constant/constant.dart';
import '../../../controller/driver_controller/location_controller.dart';
import '../../../themes/app_them_data.dart';
import '../../../utils/dark_theme_provider.dart';

class LocationSearchMapScreen extends StatelessWidget {
  LocationSearchMapScreen({super.key});

  final controller = Get.put(LocationMapController());

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Scaffold(
      body: Stack(
        children: [

          /// 🗺️ MAP
          Obx(() => GoogleMap(
            initialCameraPosition: CameraPosition(
              target: controller.currentLatLng.value,
              zoom: 14,
            ),

            onMapCreated: (mapCtrl) {
              controller.mapController = mapCtrl;
            },

            onCameraMove: (position) {
              controller.currentLatLng.value = position.target;
            },

            onCameraIdle: () {
              controller.updateAddress();
            },
          )),

          Positioned(
              top: 63,
              left: 10,
              child: InkWell(
              onTap: () => Get.back(),
              child: Icon(Icons.arrow_back_sharp,
                  color: themeChange.getThem()
                      ? AppThemData.grey02
                      : AppThemData.grey08))),

          /// 🔍 SEARCH BAR
          Positioned(
            top: 50,
            left: 50,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 5),
                ],
              ),
              child: GooglePlaceAutoCompleteTextField(
                textEditingController: TextEditingController(),
                googleAPIKey: Constant.mapAPIKey,
                boxDecoration: const BoxDecoration(),
                inputDecoration: const InputDecoration(
                  hintText: "Search location",
                  border: InputBorder.none,
                ),
                countries: const ["us", "ca"],
                isLatLngRequired: true,

                getPlaceDetailWithLatLng: (prediction) {
                  double lat = double.parse(prediction.lat!);
                  double lng = double.parse(prediction.lng!);

                  controller.moveCamera(lat, lng);
                },
                  itemClick: (prediction) {
                    controller.address.value = prediction.description ?? "";
                  }
              ),
            ),
          ),

          /// 📍 CENTER PIN
          const Center(
            child: Icon(Icons.location_pin,
                size: 40, color: Colors.red),
          ),

          /// 📦 BOTTOM CARD
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Obx(() => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(controller.address.value),

                    const SizedBox(height: 10),

                    IconButton(onPressed: (){
                      Get.back(result: {
                        "address": controller.address.value,
                        "lat": controller
                            .currentLatLng.value.latitude,
                        "lng": controller
                            .currentLatLng.value.longitude,
                      });
                    }, icon: Icon(Icons.check)),

                  /*  ElevatedButton(
                      onPressed: () {
                        Get.back(result: {
                          "address": controller.address.value,
                          "lat": controller
                              .currentLatLng.value.latitude,
                          "lng": controller
                              .currentLatLng.value.longitude,
                        });
                      },
                      child: const Text("Confirm Location"),
                    ),*/
                  ],
                ),
              ),
            )),
          ),
        ],
      ),
    );
  }
}