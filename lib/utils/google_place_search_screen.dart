import 'package:flutter/material.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:phista/constant/constant.dart';

class GooglePlaceSearchScreen extends StatefulWidget {
  const GooglePlaceSearchScreen({super.key});

  @override
  State<GooglePlaceSearchScreen> createState() =>
      _GooglePlaceSearchScreenState();
}

class _GooglePlaceSearchScreenState extends State<GooglePlaceSearchScreen> {
  late final FlutterGooglePlacesSdk places;
  List<AutocompletePrediction> predictions = [];

  @override
  void initState() {
    super.initState();
    places = FlutterGooglePlacesSdk(Constant.mapAPIKey);
  }

  void onSearch(String value) async {
    if (value.isEmpty) {
      setState(() => predictions = []);
      return;
    }

    final res = await places.findAutocompletePredictions(value);

    setState(() {
      predictions = res.predictions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search Address")),
      body: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: "Search address...",
            ),
            onChanged: onSearch,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: predictions.length,
              itemBuilder: (_, index) {
                final item = predictions[index];
                return ListTile(
                  title: Text(item.fullText),
                  onTap: () async {
                    final detail = await places.fetchPlace(
                      item.placeId,
                      fields: [PlaceField.Location, PlaceField.AddressComponents],
                    );
                    final loc = detail.place?.latLng;
                    Navigator.pop(context, {
                      "lat": loc?.lat,
                      "lng": loc?.lng,
                      "address": item.fullText,
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
