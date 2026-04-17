import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationMapController extends GetxController {
  GoogleMapController? mapController;

  var currentLatLng = const LatLng(37.7749, -122.4194).obs;
  var address = "".obs;

  @override
  void onInit() {
    getCurrentLocation();
    super.onInit();
  }


  /// Move camera
  // void moveCamera(double lat, double lng) {
  //   currentLatLng.value = LatLng(lat, lng);
  //
  //   mapController?.animateCamera(
  //     CameraUpdate.newLatLng(currentLatLng.value),
  //   );
  // }

  void moveCamera(double lat, double lng) {
    currentLatLng.value = LatLng(lat, lng);

    mapController?.animateCamera(
      CameraUpdate.newLatLng(currentLatLng.value),
    );

    updateAddress(); // 🔥 always update address
  }

  /// Reverse geocoding
  Future<void> updateAddress() async {
    final lat = currentLatLng.value.latitude;
    final lng = currentLatLng.value.longitude;

    List<Placemark> placemarks =
    await placemarkFromCoordinates(lat, lng);

    if (placemarks.isNotEmpty) {
      final p = placemarks.first;

      address.value =
      "${p.street}, ${p.locality}, ${p.country}";
    }
  }

  Future<void> getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    currentLatLng.value = LatLng(position.latitude, position.longitude);

    // move camera
    mapController?.animateCamera(
      CameraUpdate.newLatLng(currentLatLng.value),
    );

    await updateAddress();
  }
}