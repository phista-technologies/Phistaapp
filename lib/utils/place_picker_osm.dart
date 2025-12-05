/*
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:get/get.dart';
import 'package:osm_nominatim/osm_nominatim.dart';
import 'package:phista/themes/app_them_data.dart';
import 'package:phista/utils/dark_theme_provider.dart';
import 'package:phista/utils/osm_map_search_place.dart';
import 'package:phista/utils/utils.dart';
import 'package:provider/provider.dart';

class LocationPicker extends StatefulWidget {
  const LocationPicker({super.key});
  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  GeoPoint? selectedLocation;
  late MapController mapController;
  Place? place;
  TextEditingController textController = TextEditingController();
  final List<GeoPoint> _markers = [];
  @override
  void initState() {
    super.initState();
    mapController = MapController(
      initMapWithUserPosition:
          const UserTrackingOption(enableTracking: false, unFollowUser: true),
    );
  }

  _listerTapPosition() async {
    mapController.listenerMapSingleTapping.addListener(() async {
      if (mapController.listenerMapSingleTapping.value != null) {
        GeoPoint position = mapController.listenerMapSingleTapping.value!;
        addMarker(position);
        place = await Nominatim.reverseSearch(
          lat: position.latitude,
          lon: position.longitude,
          zoom: 14,
          addressDetails: true,
          extraTags: true,
          nameDetails: true,
        );
      }
    });
  }

  addMarker(GeoPoint? position) async {
    if (position != null) {
      for (var marker in _markers) {
        await mapController.removeMarker(marker);
      }
      setState(() {
        _markers.clear();
      });
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await mapController
            .addMarker(position,
                markerIcon: const MarkerIcon(
                  icon: Icon(
                    Icons.location_on,
                    size: 26,
                    color: Colors.blue,
                  ),
                ))
            .then((v) {
          _markers.add(position);
        });

        place = await Nominatim.reverseSearch(
          lat: position.latitude,
          lon: position.longitude,
          zoom: 14,
          addressDetails: true,
          extraTags: true,
          nameDetails: true,
        );
        setState(() {});
        mapController.moveTo(position, animate: true);
      });
    }
  }

  Future<void> _setUserLocation() async {
    try {
      final locationData = await Utils.getCurrentLocation();
      setState(() async {
        selectedLocation = GeoPoint(
          latitude: locationData!.latitude,
          longitude: locationData.longitude,
        );
        await addMarker(selectedLocation!);
        mapController.moveTo(selectedLocation!, animate: true);
        place = await Nominatim.reverseSearch(
          lat: selectedLocation!.latitude,
          lon: selectedLocation!.longitude,
          zoom: 14,
          addressDetails: true,
          extraTags: true,
          nameDetails: true,
        );
      });
    } catch (e) {
      print("Error getting location: $e");
      // Handle error (e.g., show a snackbar to the user)
    }
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: InkWell(
          onTap: () {
            Get.back();
          },
          child: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        title: const Text(
          'Location Picker',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          OSMFlutter(
            controller: mapController,
            mapIsLoading: const Center(child: CircularProgressIndicator()),
            osmOption: OSMOption(
              userLocationMarker: UserLocationMaker(
                  personMarker: MarkerIcon(iconWidget: Image.asset("assets/icon/ic_parking_icon.png")),
                  directionArrowMarker: MarkerIcon(iconWidget: Image.asset("assets/icon/ic_parking_icon.png"))),
              zoomOption: const ZoomOption(initZoom: 14),
            ),
            onMapIsReady: (active) {
              if (active) {
                _setUserLocation();
                _listerTapPosition();
              }
            },
          ),

         */
/* Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 00),
                  child: InkWell(
                    onTap: () async {
                      Get.to(const OsmSearchPlacesApi())?.then((value) async {
                        if (value != null) {
                          SearchInfo place = value;
                          textController = TextEditingController(text: place.address.toString());
                          await addMarker(place.point);
                          print("Search :: ${place.point.toString()}");
                        }
                      });
                    },
                    child: IgnorePointer(
                      ignoring: false,
                      child: buildTextField(
                        title: "Search Address".tr,
                        textController: textController,
                      ),
                    ),
                  ),
                )),
          ),*/
/*


          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: buildTextField(
              title: "Search Address",
              textController: textController,
              onTap: () async {
                Get.to(const OsmSearchPlacesApi())?.then((value) async {
                  if (value != null) {
                    SearchInfo place = value;
                    textController.text = place.address.toString();
                    await addMarker(place.point);
                  }
                });
              },
            ),
          ),

          if (place?.displayName != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.only(bottom: 100, left: 40, right: 40),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        place?.displayName ?? '',
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          Get.back(result: place);
                        },
                        icon: const Icon(
                          Icons.check_circle,
                          size: 40,
                        ))
                  ],
                ),
              ),
            ),

        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _setUserLocation,
        backgroundColor: Colors.blue,
        child: Icon(Icons.my_location,
            color: themeChange.getThem()
                ? AppThemData.primary01
                : AppThemData.primary03),
      ),
    );
  }

  Widget buildTextField(
      {required title, required TextEditingController textController,VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: TextField(
        controller: textController,
        textInputAction: TextInputAction.done,
        readOnly: true,
        onTap: onTap,
        style: const TextStyle(color: AppThemData.grey09),
        decoration: InputDecoration(
          prefixIcon: IconButton(
            icon: const Icon(
              Icons.location_on,
              color: AppThemData.grey08,
            ),
            onPressed: () {},
          ),
          fillColor: Colors.white,
          filled: true,
          hintText: title,
          hintStyle: const TextStyle(color: AppThemData.grey08),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          enabled: true,
        ),

      ),
    );
  }
}
*/


// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:get/get.dart';
// import 'google_place_search_screen.dart';
//
// class LocationPicker extends StatefulWidget {
//   const LocationPicker({super.key});
//
//   @override
//   State<LocationPicker> createState() => _LocationPickerState();
// }
//
// class _LocationPickerState extends State<LocationPicker> {
//   GoogleMapController? mapController;
//   LatLng? selectedPosition;
//   String? selectedAddress;
//   final TextEditingController textController = TextEditingController();
//   final Set<Marker> markers = {};
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Location Picker"),
//         backgroundColor: Colors.blue,
//       ),
//       body: Stack(
//         children: [
//           GoogleMap(
//             onMapCreated: (controller) => mapController = controller,
//             initialCameraPosition: const CameraPosition(
//               target: LatLng(22.7196, 75.8577),
//               zoom: 14,
//             ),
//             markers: markers,
//             onTap: (pos) {
//               _updateMarker(pos);
//             },
//           ),
//
//           /// Search bar
//           Positioned(
//             top: 10,
//             left: 10,
//             right: 10,
//             child: buildTextField(
//               title: "Search Address",
//               textController: textController,
//               onTap: () async {
//                 var result = await Get.to(const GooglePlaceSearchScreen());
//
//                 if (result != null) {
//                   double lat = result["lat"];
//                   double lng = result["lng"];
//                   String address = result["address"];
//
//                   textController.text = address;
//
//                   _updateMarker(LatLng(lat, lng));
//                 }
//               },
//             ),
//           ),
//
//           /// Bottom address card
//           if (selectedAddress != null)
//             Align(
//               alignment: Alignment.bottomCenter,
//               child: Container(
//                 margin: const EdgeInsets.only(bottom: 120, left: 40, right: 40),
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Row(
//                   children: [
//                     Expanded(child: Text(selectedAddress ?? "")),
//                     IconButton(
//                       icon: const Icon(Icons.check_circle, size: 40),
//                       onPressed: () {
//                         Get.back(result: {
//                           "lat": selectedPosition!.latitude,
//                           "lng": selectedPosition!.longitude,
//                           "address": selectedAddress
//                         });
//                       },
//                     )
//                   ],
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   _updateMarker(LatLng pos) {
//     markers.clear();
//     markers.add(
//       Marker(markerId: const MarkerId("selected"), position: pos),
//     );
//
//     setState(() {
//       selectedPosition = pos;
//       selectedAddress = "${pos.latitude}, ${pos.longitude}";
//     });
//
//     mapController?.animateCamera(CameraUpdate.newLatLng(pos));
//   }
//
//   Widget buildTextField({
//     required String title,
//     required TextEditingController textController,
//     VoidCallback? onTap,
//   }) {
//     return TextField(
//       controller: textController,
//       readOnly: true,
//       onTap: onTap,
//       decoration: InputDecoration(
//         prefixIcon: const Icon(Icons.location_on),
//         filled: true,
//         fillColor: Colors.white,
//         hintText: title,
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//     );
//   }
// }


/*import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:geocoding/geocoding.dart' as geo;

import '../constant/constant.dart';

class LocationPicker extends StatefulWidget {
  const LocationPicker({super.key});

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  final TextEditingController searchController = TextEditingController();
  final FlutterGooglePlacesSdk _places =
  FlutterGooglePlacesSdk(Constant.mapAPIKey);

  gmap.GoogleMapController? mapController;

  List<AutocompletePrediction> suggestions = [];

  gmap.LatLng currentLatLng = const gmap.LatLng(22.7196, 75.8577); // Default Indore
  String selectedAddress = "";

  // ✅ Search Autocomplete
  Future<void> searchPlaces(String query) async {
    if (query.isEmpty) {
      setState(() => suggestions.clear());
      return;
    }

    final result = await _places.findAutocompletePredictions(query);

    setState(() {
      suggestions = result.predictions ?? [];
    });
  }

  // ✅ Move map to selected place from autocomplete
  Future<void> moveToPlace(String placeId, String description) async {
    final detail = await _places.fetchPlace(placeId, fields: []);

    final loc = detail.place?.latLng;
    if (loc == null) return;

    final selected = gmap.LatLng(loc.lat, loc.lng);

    mapController?.animateCamera(
      gmap.CameraUpdate.newLatLngZoom(selected, 16),
    );

    // fetch address
    await fetchAddressFromCords(selected);

    setState(() {
      currentLatLng = selected;
      searchController.text = description;
      suggestions.clear();
    });
  }

  // ✅ Reverse geocode using geocoding package
  Future<void> fetchAddressFromCords(gmap.LatLng latLng) async {
    final placemarks =
    await geo.placemarkFromCoordinates(latLng.latitude, latLng.longitude);

    if (placemarks.isNotEmpty) {
      final p = placemarks.first;

      setState(() {
        selectedAddress =
        "${p.name}, ${p.locality}, ${p.administrativeArea}, ${p.country}";
      });
    }
  }

  // ✅ When map is dragged
  void onCameraIdle() async {
    await fetchAddressFromCords(currentLatLng);
  }

  void onCameraMove(gmap.CameraPosition pos) {
    setState(() {
      currentLatLng = pos.target;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ✅ Google Map
          gmap.GoogleMap(
            initialCameraPosition: gmap.CameraPosition(
              target: currentLatLng,
              zoom: 14,
            ),
            onMapCreated: (controller) => mapController = controller,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            onCameraIdle: onCameraIdle,
            onCameraMove: onCameraMove,
          ),

          // ✅ Pin icon
          const Center(
            child: Icon(Icons.location_pin, size: 50, color: Colors.red),
          ),

          // ✅ Search Bar
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Material(
                  elevation: 5,
                  borderRadius: BorderRadius.circular(10),
                  child: TextField(
                    controller: searchController,
                    onChanged: searchPlaces,
                    decoration: InputDecoration(
                      hintText: "Search places",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                // ✅ Autocomplete suggestions
                if (suggestions.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 5)
                      ],
                    ),
                    child: ListView.builder(
                      itemCount: suggestions.length,
                      shrinkWrap: true,
                      itemBuilder: (_, index) {
                        final item = suggestions[index];
                        return ListTile(
                          leading: const Icon(Icons.location_on),
                          title: Text(item.fullText ?? ""),
                          onTap: () {
                            moveToPlace(item.placeId!, item.fullText!);
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // ✅ Display selected address
          Positioned(
            bottom: 120,
            left: 20,
            right: 20,
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  selectedAddress.isEmpty
                      ? "Fetching address..."
                      : selectedAddress,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),

          // ✅ Confirm Button
          Positioned(
            bottom: 40,
            left: 40,
            right: 40,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  "lat": currentLatLng.latitude,
                  "lng": currentLatLng.longitude,
                  "address": selectedAddress,
                });
              },
              child: const Text("Confirm Location"),
            ),
          ),
        ],
      ),
    );
  }
}*/












import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart'
as places;
import 'package:geocoding/geocoding.dart' as geocoder;
import 'package:http/http.dart' as http;
import 'package:phista/constant/constant.dart';

import '../themes/app_them_data.dart';

class LocationPicker extends StatefulWidget {
  final gmap.LatLng initialPosition;

  const LocationPicker({
    super.key,
    required this.initialPosition,
  });

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  late places.FlutterGooglePlacesSdk _places;
  Completer<gmap.GoogleMapController> _mapController = Completer();

  TextEditingController searchController = TextEditingController();

  List<places.AutocompletePrediction> suggestions = [];

  gmap.LatLng selectedPosition = const gmap.LatLng(0, 0);
  String selectedAddress = "Searching address…";
  bool isLoadingAddress = false;

  @override
  void initState() {
    super.initState();

    selectedPosition = widget.initialPosition;

    _places = places.FlutterGooglePlacesSdk(Constant.mapAPIKey);

    _reverseGeocode(selectedPosition);
  }

  // ✅ Reverse geocode using geocoding plugin

  // ✅ Reverse Geocode for Web + Mobile
  Future<void> _reverseGeocode(gmap.LatLng pos) async {
    setState(() => isLoadingAddress = true);

    try {
      if (kIsWeb) {
        // ✅ Web: Use Google Geocode API
        final url =
            "https://maps.googleapis.com/maps/api/geocode/json?latlng=${pos.latitude},${pos.longitude}&key=${Constant.mapAPIKey}";

        final res = await http.get(Uri.parse(url));
        final data = json.decode(res.body);

        if (data["results"] != null && data["results"].length > 0) {
          selectedAddress = data["results"][0]["formatted_address"];
        } else {
          selectedAddress = "Unable to fetch address";
        }
      } else {
        final placemarks = await geocoder.placemarkFromCoordinates(
          pos.latitude,
          pos.longitude,
        );

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          selectedAddress = "${place.name}, ${place.locality}, ${place.administrativeArea}";
        }

      }
    } catch (e) {
      selectedAddress = "Unable to fetch address";
    }

    setState(() => isLoadingAddress = false);
  }

  // ✅ Search autocomplete
  Future<void> searchPlaces(String input) async {
    if (input.isEmpty) {
      setState(() => suggestions = []);
      return;
    }

    final result = await _places.findAutocompletePredictions(
      input,
      countries: ["CA"],
    );

    setState(() {
      suggestions = result.predictions;
    });
  }

  // ✅ When user taps suggestion → get place details & move camera
  Future<void> selectSuggestion(places.AutocompletePrediction p) async {
    final detail = await _places.fetchPlace(
      p.placeId,
      fields: [
        places.PlaceField.Location,
        places.PlaceField.Address,
      ],
    );

    final loc = detail.place!.latLng!;
    final newPos = gmap.LatLng(loc.lat, loc.lng);

    final controller = await _mapController.future;
    controller.animateCamera(
      gmap.CameraUpdate.newLatLng(newPos),
    );

    setState(() {
      selectedPosition = newPos;
      selectedAddress = detail.place!.address ?? "";
      suggestions = [];
      searchController.text = detail.place!.address ?? "";
    });
  }

  // ✅ Return data to previous screen
  void _selectAndReturn() {
    Navigator.pop(context, {
      "lat": selectedPosition.latitude,
      "lng": selectedPosition.longitude,
      "address": selectedAddress,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // ✅ Google Map
          gmap.GoogleMap(
            initialCameraPosition: gmap.CameraPosition(
              target: widget.initialPosition,
              zoom: 16,
            ),
            onMapCreated: (gmap.GoogleMapController controller) {
              _mapController.complete(controller);
            },
            onCameraMove: (pos) {
              selectedPosition = pos.target;
            },
            onCameraIdle: () {
              _reverseGeocode(selectedPosition);
            },
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),

          // ✅ Map pin centered
          Center(
            child: IgnorePointer(
              child: Icon(
                Icons.location_pin,
                size: 50,
                color: Colors.red,
              ),
            ),
          ),

          // ✅ Search bar
          Positioned(
            top: 40,
            left: 15,
            right: 15,
            child: Column(
              children: [
                Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(12),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Search place...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: searchPlaces,
                  ),
                ),

                // ✅ Place suggestions list
                if (suggestions.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 5,
                          color: Colors.black26,
                        )
                      ],
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: suggestions.length,
                      itemBuilder: (context, index) {
                        final s = suggestions[index];
                        return ListTile(
                          title: Text(s.fullText, style: TextStyle(
                            color: AppThemData.grey10,
                            fontSize: 24,
                            fontFamily: AppThemData.semiBold,
                            fontWeight: FontWeight.w400,
                          )),
                          onTap: () => selectSuggestion(s),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // ✅ Selected Address Display + Confirm Button
          if (selectedAddress != "")
          Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.only(bottom: 100, left: 40, right: 40),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                         selectedAddress ?? '',
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                    IconButton(
                        onPressed: _selectAndReturn,
                        icon: const Icon(
                          Icons.check_circle,
                          size: 40,
                        ))
                  ],
                ),
              ),
            ),
          /*Positioned(
            bottom: 20,
            left: 15,
            right: 15,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: _selectAndReturn,
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.place),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              selectedAddress,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isLoadingAddress)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),*/
        ],
      ),
    );
  }
}





