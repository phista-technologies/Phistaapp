import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as MATH;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:location/location.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:phista/constant/constant.dart';
import 'package:phista/constant/show_toast_dialog.dart';
import 'package:http/http.dart' as http;

import '../env.dart';
import '../model/payment_method_model.dart';
import '../model/user_model.dart';
import 'fire_store_utils.dart';

class Utils {


  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      await Location().requestService();
      return null;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  static redirectMap({required String name, required double latitude, required double longLatitude}) async {
    if (Constant.mapType == "google") {
      bool? isAvailable = await MapLauncher.isMapAvailable(MapType.google);
      if (isAvailable == true) {
        await MapLauncher.showDirections(
          mapType: MapType.google,
          directionsMode: DirectionsMode.driving,
          destinationTitle: name,
          destination: Coords(latitude, longLatitude),
        );
      } else {
        ShowToastDialog.showToast("Google map is not installed");
      }
    } else if (Constant.mapType == "googleGo") {
      bool? isAvailable = await MapLauncher.isMapAvailable(MapType.googleGo);
      if (isAvailable == true) {
        await MapLauncher.showDirections(
          mapType: MapType.googleGo,
          directionsMode: DirectionsMode.driving,
          destinationTitle: name,
          destination: Coords(latitude, longLatitude),
        );
      } else {
        ShowToastDialog.showToast("Google Go map is not installed");
      }
    } else if (Constant.mapType == "waze") {
      bool? isAvailable = await MapLauncher.isMapAvailable(MapType.waze);
      if (isAvailable == true) {
        await MapLauncher.showDirections(
          mapType: MapType.waze,
          directionsMode: DirectionsMode.driving,
          destinationTitle: name,
          destination: Coords(latitude, longLatitude),
        );
      } else {
        ShowToastDialog.showToast("Waze is not installed");
      }
    } else if (Constant.mapType == "mapswithme") {
      bool? isAvailable = await MapLauncher.isMapAvailable(MapType.mapswithme);
      if (isAvailable == true) {
        await MapLauncher.showDirections(
          mapType: MapType.mapswithme,
          directionsMode: DirectionsMode.driving,
          destinationTitle: name,
          destination: Coords(latitude, longLatitude),
        );
      } else {
        ShowToastDialog.showToast("Mapswithme is not installed");
      }
    } else if (Constant.mapType == "yandexNavi") {
      bool? isAvailable = await MapLauncher.isMapAvailable(MapType.yandexNavi);
      if (isAvailable == true) {
        await MapLauncher.showDirections(
          mapType: MapType.yandexNavi,
          directionsMode: DirectionsMode.driving,
          destinationTitle: name,
          destination: Coords(latitude, longLatitude),
        );
      } else {
        ShowToastDialog.showToast("YandexNavi is not installed");
      }
    } else if (Constant.mapType == "yandexMaps") {
      bool? isAvailable = await MapLauncher.isMapAvailable(MapType.yandexMaps);
      if (isAvailable == true) {
        await MapLauncher.showDirections(
          mapType: MapType.yandexMaps,
          directionsMode: DirectionsMode.driving,
          destinationTitle: name,
          destination: Coords(latitude, longLatitude),
        );
      } else {
        ShowToastDialog.showToast("yandexMaps map is not installed");
      }
    }
  }


  static Timestamp stringToTimeStamp(String dateTime){
    print("stringToTimeStamp:-  $dateTime");
    String dateString = dateTime;
    String formattedString = dateString.replaceAll(" at ", " ");
    DateFormat dateFormat = DateFormat("d MMMM yyyy HH:mm:ss");

    DateTime parsedDate = dateFormat.parse(formattedString);

    Timestamp timestamp = Timestamp.fromDate(parsedDate);

    print("Parsed DateTime: $parsedDate");
    print("Firestore Timestamp: $timestamp");

    return timestamp;
  }

  static String formatTimestampToIST(Timestamp timestamp) {
    DateTime utcDateTime = timestamp.toDate().toUtc();
    DateTime istDateTime = utcDateTime.add(const Duration(hours: 5, minutes: 30));
    String formatted = DateFormat("d MMMM yyyy 'at' HH:mm:ss").format(istDateTime);
    return "$formatted UTC+5:30";
  }


  //For validate number
  static Future<bool> getPhoneNumberValidation(String phoneNumber, isoCode, countryCode)
  async {
    try {
      log("ISO Code :-- ", error: isoCode);
      log("country_code :-- ", error: countryCode);
      log("phone_number :-- ", error: phoneNumber.replaceAll(" ", ""));
      var phoneNumberValid = PhoneNumber(
          countryISOCode: isoCode,
          countryCode: countryCode,
          number: phoneNumber.replaceAll(" ", ""));
      bool? isValid = phoneNumberValid.isValidNumber();
      log("isValid :-- ", error: isValid);
      return isValid!;
    } catch (e) {
      log("getPhoneNumberValidation Exception :- ", error: e.toString());
      return false;
    }
  }

  static int generateSixDigitCode() {
    final random = MATH.Random();
    return 100000 + random.nextInt(900000); // Range: 100000 to 999999
  }

  static Future<void> sendEmailWithTemplate({
    required String toEmail,
    required String templateId,
    required Map<String,dynamic> dynamicTemplateData,
    File? attachmentFile, // Optional PDF file to attach
  })
  async {
    final url = Uri.parse('https://api.sendgrid.com/v3/mail/send');


    Map<String, dynamic> body = {
      "personalizations": [
        {
          "to": [
            {"email":toEmail}
              //projects.mindiii@gmail.com
          ],
          "dynamic_template_data": dynamicTemplateData,
        }
      ],
      "from": {"email": "support@phista.ca"},
      "template_id": templateId,
    };

    // 🔗 Attach PDF if provided
    if (attachmentFile != null && await attachmentFile.exists()) {
      final bytes = await attachmentFile.readAsBytes();
      final base64Pdf = base64Encode(bytes);

      body["attachments"] = [
        {
          "content": base64Pdf,
          //"filename": "ParkingInfo.pdf",
          "filename": "Invoice.pdf",
          "type": "application/pdf",
          "disposition": "attachment",
        }
      ];
    }

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer ${ENV.sandGridApiKey}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 202) {
      print("Email sent with template!");
    } else {
      print("Failed to send email: ${response.statusCode}\n${response.body}");
    }
  }

  static Future<void> sendRemainderEmailWithTemplate({
    required String toEmail,
    required String templateId,
    required Map<String,dynamic> dynamicTemplateData,
    File? attachmentFile, // Optional PDF file to attach
    int? numberOfDays,
    int? mintSend,
  })
  async {
    final url = Uri.parse('https://api.sendgrid.com/v3/mail/send');

    // Current time
    DateTime now = DateTime.now();
    int timestamp = -1;

    if(numberOfDays != null){
      DateTime numberOfDaysLater = now.add(Duration(days: 10));
      // Convert to Unix timestamp (in seconds)
       timestamp = numberOfDaysLater.millisecondsSinceEpoch ~/ 1000;
    }else{
      // Add 5 minutes
      DateTime fiveMinutesLater = now.add(Duration(minutes:mintSend??0));
      // Convert to Unix timestamp (in seconds)
      timestamp = fiveMinutesLater.millisecondsSinceEpoch ~/ 1000;
    }

    print("Unix Timestamp after 5 minutes: $timestamp");


    Map<String, dynamic> body = {
      "personalizations": [
        {
          "to": [
            {"email":toEmail}
            //projects.mindiii@gmail.com
          ],
          "dynamic_template_data": dynamicTemplateData,
        }
      ],
      "from": {"email": "support@phista.ca"},
      "template_id": templateId,
      "send_at": timestamp
    };

    // 🔗 Attach PDF if provided
    if (attachmentFile != null && await attachmentFile.exists()) {
      final bytes = await attachmentFile.readAsBytes();
      final base64Pdf = base64Encode(bytes);

      body["attachments"] = [
        {
          "content": base64Pdf,
          //"filename": "ParkingInfo.pdf",
          "filename": "Invoice.pdf",
          "type": "application/pdf",
          "disposition": "attachment",
        }
      ];
    }

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer ${ENV.sandGridApiKey}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 202) {
      print("Email sent with template!");
    } else {
      print("Failed to send email: ${response.statusCode}\n${response.body}");
    }
  }





  /// new setup for send email with template with all platforms (android,ios,web)  Devendra 30 Oct 2025
  static Future<void> sendEmailWithTemplateWithAllPlatForms({
    required String toEmail,
    required String templateId,
    required Map<String, dynamic> dynamicTemplateData,
    File? attachmentFile, // Optional PDF file to attach
  })
  async {
    final url = Uri.parse("https://us-central1-phista-81bf8.cloudfunctions.net/sendEmail");

    final Map<String, dynamic> body = {
      "to": toEmail,
      "templateId": templateId,
      "dynamicTemplateData": dynamicTemplateData,
    };

    // 🔗 Attach PDF if provided
    if (attachmentFile != null && await attachmentFile.exists()) {
      final bytes = await attachmentFile.readAsBytes();
      final base64Pdf = base64Encode(bytes);
      body["attachments"] = [
        {
          "content": base64Pdf,
          "filename": "Invoice.pdf",
          "type": "application/pdf",
          "disposition": "attachment",
        }
      ];
    }

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      print("Email sent with template!");
    } else {
      print("Failed to send email: ${response.statusCode}\n${response.body}");
    }
  }


  /// new setup for send email with template with all platforms (android,ios,web)  Devendra 30 Oct 2025
  static Future<void> sendRemainderEmailWithTemplateWithAllPlateForm({
    required String toEmail,
    required String templateId,
    required Map<String, dynamic> dynamicTemplateData,
    File? attachmentFile, // Optional PDF file to attach
    int? numberOfDays,
    int? mintSend,
  })
  async {
    final url = Uri.parse(
        "https://us-central1-phista-81bf8.cloudfunctions.net/sendEmail");

    // Current time
    DateTime now = DateTime.now();
    int timestamp = -1;

    if (numberOfDays != null) {
      DateTime numberOfDaysLater = now.add(Duration(days: 10));
      // Convert to Unix timestamp (in seconds)
      timestamp = numberOfDaysLater.millisecondsSinceEpoch ~/ 1000;
    } else {
      // Add 5 minutes
      DateTime fiveMinutesLater = now.add(Duration(minutes: mintSend ?? 0));
      // Convert to Unix timestamp (in seconds)
      timestamp = fiveMinutesLater.millisecondsSinceEpoch ~/ 1000;
    }

    print("Unix Timestamp after 5 minutes: $timestamp");

    Map<String, dynamic> body = {
      "to": toEmail,
      "templateId": templateId,
      "dynamicTemplateData": dynamicTemplateData,
      "send_at": timestamp
    };

    // 🔗 Attach PDF if provided
    if (attachmentFile != null && await attachmentFile.exists()) {
      final bytes = await attachmentFile.readAsBytes();
      final base64Pdf = base64Encode(bytes);

      body["attachments"] = [
        {
          "content": base64Pdf,
          "filename": "Invoice.pdf",
          "type": "application/pdf",
          "disposition": "attachment",
        }
      ];
    }

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      print("Email sent with template!");
    } else {
      print("Failed to send email: ${response.statusCode}\n${response.body}");
    }
  }


  static String utcToLocalTime(String utcTimeStr){
    DateTime utcTime = DateTime.parse(utcTimeStr);
    DateTime localTime = utcTime.toLocal();

    // Format as desired
    String formatted = DateFormat('yyyy-MM-dd HH:mm:ss').format(localTime);
    print("Formatted Local Time: $formatted");
    return formatted;
  }

  static Future<String?> createStripeCustomerIfNotExists(UserModel user) async {
    try {
      // Fetch Stripe Keys from Firestore
      PaymentModel? paymentModel = await FireStoreUtils().getPayment();
      if (paymentModel == null || paymentModel.strip == null) {
        print("Error: Stripe keys not found in Firestore.");
        return null;
      }

      String stripeSecret = paymentModel.strip!.stripeSecret ?? ""; //ENV.skTestSecretKey;
      if (stripeSecret.isEmpty) {
        print("Error: Stripe secret key is empty.");
        return null;
      }

      // If customer already exists → return it
      if (user.stripeCustomerId != null && user.stripeCustomerId!.isNotEmpty) {
        return user.stripeCustomerId;
      }

      // Create Stripe Customer
      var response = await http.post(
        Uri.parse("https://api.stripe.com/v1/customers"),
        headers: {
          "Authorization": "Bearer $stripeSecret",
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          "name": user.fullName ?? "",
          "email": user.email ?? "",
        },
      );

      var data = jsonDecode(response.body);

      if (data["id"] != null) {
        String customerId = data["id"];
        print("Stripe Customer Created: $customerId");
        return customerId;
      } else {
        print("Stripe Error Response: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Stripe Error: $e");
      return null;
    }
  }




}
