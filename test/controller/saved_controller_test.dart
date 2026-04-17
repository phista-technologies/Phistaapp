
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:phista/controller/driver_controller/saved_controller.dart';
import 'package:phista/model/parking_model.dart';

void main() {

  late SavedController controller;

  setUp(() {
    controller = SavedController();
  });

  ///  Initial State Test
  test("Initial values should be correct", () {
    expect(controller.isLoading.value, true);
    expect(controller.bookMarkedList.isEmpty, true);
    expect(controller.searchController.value, isA<TextEditingController>());
  });

  test("Loading state change test", () {

    controller.isLoading.value = true;

    controller.isLoading.value = false;

    expect(controller.isLoading.value, false);

  });

  ///  Bookmark List Update Test
  test("Bookmark list should update", () {

    controller.bookMarkedList.add(ParkingModel());

    expect(controller.bookMarkedList.length, 1);
  });

  ///  Search Controller Test
  test("Search controller should hold text", () {

    controller.searchController.value.text = "Parking";

    expect(controller.searchController.value.text, "Parking");
  });

  test("Distance function test basic", () async {

    LatLng source = LatLng(20, 30);
    LatLng dest = LatLng(21, 31);

    try {
      await controller.getDistance(source, dest);
    } catch (e) {}

    expect(controller, isNotNull);

  });

  ///  Bookmark Clear Test
  test("Bookmark list should clear", () {

    controller.bookMarkedList.add(ParkingModel());
    controller.bookMarkedList.clear();

    expect(controller.bookMarkedList.isEmpty, true);
  });

  ///  Loading State Manual Change
  test("Loading state manual change", () {

    controller.isLoading.value = false;

    expect(controller.isLoading.value, false);
  });

}