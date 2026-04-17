
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:phista/controller/driver_controller/home_controller.dart';
import 'package:phista/themes/app_them_data.dart';

void main() {
  late HomeController controller;

  setUp(() {
    controller = HomeController();
  });

  ///  Initial State Test
  test("Initial values should be correct", () {
    expect(controller.isLoading.value, true);
    expect(controller.parkingList.isEmpty, true);
    expect(controller.permissionDenied.value, false);
  });

  ///  Percent Color Logic Test
  test("getPercentColor should return correct color", () {
    expect(controller.getPercentColor(50), AppThemData.success07);
    expect(controller.getPercentColor(80), AppThemData.primary05);
    expect(controller.getPercentColor(100), AppThemData.error07);
  });

  ///  Descriptor Function Test
  test("descriptorFun should return correct marker", () {
    controller.parkingGreenMarker = BitmapDescriptor.defaultMarker;
    controller.parkingYellowMarker = BitmapDescriptor.defaultMarkerWithHue(
      BitmapDescriptor.hueYellow,
    );
    controller.parkingRedMarker = BitmapDescriptor.defaultMarkerWithHue(
      BitmapDescriptor.hueRed,
    );

    expect(controller.descriptorFun(50), controller.parkingGreenMarker);
    expect(controller.descriptorFun(80), controller.parkingYellowMarker);
    expect(controller.descriptorFun(100), controller.parkingRedMarker);
  });

  ///  Add Marker Test
  test("addMarker should add marker to markers map", () {
    controller.parkingGreenMarker = BitmapDescriptor.defaultMarker;

    controller.addMarker(
      latitude: 20,
      longitude: 30,
      id: "test_marker",
      percent: 50,
    );

    expect(controller.markers.length, 1);
  });

  ///  Parking Cache Test
  test("getData should return cached data if available", () async {
    controller.parkingDataCache["parking1"] = {"percent": 40};

    final result = await controller.getData("parking1", "10");

    expect(result["percent"], 40);
  });

  ///  Parking List Update Test
  test("parkingList should update correctly", () {
    controller.parkingList.addAll([]);

    expect(controller.parkingList.length, 0);
  });

  ///  Permission State Test
  test("permissionDenied should change value", () {
    controller.permissionDenied.value = true;

    expect(controller.permissionDenied.value, true);
  });

  ///  Marker Show Map Test
  test("markerShowMap should start empty", () {
    expect(controller.markerShowMap.isEmpty, true);
  });
}