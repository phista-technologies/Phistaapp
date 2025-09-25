import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:phista/constant/show_toast_dialog.dart';
import 'package:phista/model/admin_commission.dart';
import 'package:phista/model/currency_model.dart';
import 'package:phista/model/language_model.dart';
import 'package:phista/model/location_lat_lng.dart';

import 'package:phista/model/tax_model.dart';
import 'package:phista/model/user_model.dart';
import 'package:phista/themes/app_them_data.dart';
import 'package:phista/utils/preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../model/map_model.dart';
import '../model/parking_model.dart';

class Constant {
  static const String phoneLoginType = "phone";
  static const String googleLoginType = "google";
  static const String appleLoginType = "apple";
  static const String roleTypeForCustomer = "customer";
  static const String roleTypeForOwner = "owner";
  static  bool isGustUser = false;
  static  bool isFormParking = false;
  static  bool isLanguagePopupShow = false;

  static String bookingTypeConst = "hourly";
  static bool isSubscriptionModelApplied =
      false; //Check SubscriptionModel is Active or Not in the Admin Panel.

  static String mapAPIKey = "AIzaSyBWpknhgETEcPdExDw13FsmKIbazhH-BpI";
  static String senderId = '';
  static String jsonNotificationFileURL = '';
  static String radius = "";
  static String distanceType = "";
  //static String termsAndConditions = "";
  //static String privacyPolicy = "";
   static String termsAndConditions = """<h1 style="text-align: center;"><b>Terms and Conditions</b></h1><p>Phista Technologies Inc. Terms and Conditions</p><p>Last Updated: September 18th, 2023</p><p>Please carefully read these Terms and Conditions (“the Terms”) before using the services of Phista Technologies Inc. (“Phista,” “we,” “our,” or “us”). The use of our services, including our iOS and Android mobile application and website, is subject to these Terms. By using our services, you agree to be bound by these Terms.</p><p>Use of Services You must be at least 18 years old to use our services. You agree to provide accurate and complete information when registering. You are responsible for maintaining the confidentiality of your account and login information. You agree not to use our services for any illegal or unauthorized purposes.</p><p>Reservation and Payment When you book a parking space through our services, you agree to abide by the rental conditions set by the space owner. Payments are processed in accordance with our payment policies, and you agree to pay the associated fees for your reservation.</p><p>User Responsibilities Users who offer parking spaces for rent are responsible for providing accurate information and maintaining space availability as agreed. Users who book spaces are required to adhere to the rental conditions and treat space owners with respect.</p><p>Cancellation Cancellation policies vary for each booking. You should review the specific cancellation terms for your reservation at the time of booking.</p><p>Changes and Interruptions to Services We reserve the right to modify, suspend, or discontinue our services at any time, with or without notice. We will not be liable for damages arising from such changes or interruptions.</p><p>Intellectual Property All intellectual property rights associated with our services, including trademarks, logos, text, and images, belong to Phista Technologies Inc. You may not copy, reproduce, or distribute our content without authorization.</p><p>Limitation of Liability We will not be liable for direct, indirect, special, consequential, or other damages resulting from the use of our services or the unavailability of these services. In particular, but without limitation, we are not responsible for:</p><p>– Any damage, breakage, or theft of vehicles that may occur during the use of our services.</p><p>– Financial losses, repairs, medical expenses, or any other harm suffered by users or third parties in connection with the rental or use of parking spaces available through our services.</p><p>Users are responsible for the safety of their vehicles and personal belongings. Any damage, theft, or incident should be reported directly to their insurance companies, and we disclaim all liability in this regard. Users are encouraged to obtain appropriate insurance coverage to address risks related to the use of our services.</p><p>This limitation of liability applies to the fullest extent permitted by applicable law, whether the liability is contractual, tortious, legal, or otherwise.</p><p>Changes to the Terms We may update these Terms from time to time. Changes will take effect upon publication on our website or application. It is your responsibility to regularly review these Terms.</p><p>Termination We reserve the right to terminate or suspend your account if you violate these Terms. You may terminate your account at any time by contacting us.</p><p>Applicable Law These Terms are governed by the laws of Quebec, Canada. Any dispute arising from these Terms shall be subject to the exclusive jurisdiction of the courts of Quebec.</p><p>If you have any questions or concerns regarding these Terms and Conditions, please contact us at the following address: support@phista.ca</p><p>By using our services, you agree to these Terms and commit to abide by them.</p>""";
   static String privacyPolicy = """ <h1 style="text-align: center;"><b>Privacy Policy</b></h1><p><b>Privacy Policy</b></p><p>Phista Technologies Inc. Privacy Policy</p><p>Last Updated: September 18th, 2023</p><p>Welcome to Phista Technologies Inc. (“Phista,” “we,” “our,” or “us”). At Phista Technologies Inc., we are committed to protecting your privacy...</p>""";
  static String supportURL = "";
  static String minimumAmountToDeposit = "0";
  static String minimumAmountToWithdrawal = "0";
  static String? referralAmount = "0";
  static String? mapType = "";
  static String selectedMapType = 'google';
  static String? locationUpdate = "20";

  static int forgotPassOTP = -1;
  static String currentAppVersion = "";

  static LocationLatLng? currentLocation =
      LocationLatLng(latitude: 23.0225, longitude: 72.5714);
  static List<TaxModel>? taxList;
  static String? country;
  static AdminCommission? adminCommission;

  static CurrencyModel? currencyModel;

  static const String placed = "placed";
  static const String onGoing = "onGoing";
  static const String completed = "completed";
  static const String canceled = "canceled";

  static const globalUrl = "https://admin.phista.ca/";

  /// This is Write New For Owner
  static const commissionSubscriptionID = "J0RwvxCWhZzQQD7Kc2Ll";



  /// end
  static var currentUserModel = Rxn<UserModel>();

  static var globalParkingModel = Rxn<ParkingModel?>();


  static String amountShow({required String? amount}) {
    if (amount != ""){
      if (Constant.currencyModel!.symbolAtRight == true) {
        return "${double.parse(amount.toString()).toStringAsFixed(Constant.currencyModel!.decimalDigits!)}${Constant.currencyModel!.symbol.toString()}";
      } else {
        return "${Constant.currencyModel!.symbol.toString()}${double.parse(amount.toString()).toStringAsFixed(Constant.currencyModel!.decimalDigits!)}";
      }
    }
    return "";

  }



  double calculateTax({String? amount, TaxModel? taxModel}) {
    double taxAmount = 0.0;
    if (taxModel != null && taxModel.enable == true) {
      if (taxModel.type == "fix") {
        taxAmount = double.parse(taxModel.tax.toString());
      } else {
        taxAmount = (double.parse(amount.toString()) *
                double.parse(taxModel.tax!.toString())) /
            100;
      }
    }
    return taxAmount;
  }

  static String calculateReview(
      {required String? reviewCount, required String? reviewSum}) {
    if (reviewCount == "0.0" && reviewSum == "0.0") {
      return "0.0";
    }
    return (double.parse(reviewSum.toString()) /
            double.parse(reviewCount.toString()))
        .toStringAsFixed(1);
  }

  static const userPlaceHolder = 'assets/images/user_placeholder.png';

  static String getUuid() {
    return const Uuid().v4();
  }

  static Widget loader() {
    return const Center(
      child: CircularProgressIndicator(color: AppThemData.primary09),
    );
  }

  static Widget showEmptyView({required String message}) {
    return Center(
      child: Text(message,
          style: const TextStyle(fontFamily: AppThemData.medium, fontSize: 18),textAlign: TextAlign.center,),
    );
  }

  static String getReferralCode() {
    var rng = math.Random();
    return (rng.nextInt(900000) + 100000).toString();
  }

  static LanguageModel getLanguage() {
    final String user = Preferences.getString(Preferences.languageCodeKey);
    Map<String, dynamic> userMap = jsonDecode(user);
    log(userMap.toString());
    return LanguageModel.fromJson(userMap);
  }

  String? validateRequired(String? value, String type) {
    if (value!.isEmpty) {
      return '$type required';
    }
    return null;
  }

  String? validateEmail(String? value) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = RegExp(pattern);
    if (value == null || value.isEmpty) {
      return "Email is Required";
    } else if (!regExp.hasMatch(value)) {
      return "Invalid Email";
    } else {
      return null;
    }
  }

  bool hasValidUrl(String value) {
    String pattern =
        r'(http|https)://[\w-]+(\.[\w-]+)+([\w.,@?^=%&amp;:/~+#-]*[\w@?^=%&amp;/~+#-])?';
    RegExp regExp = RegExp(pattern);
    if (value.isEmpty) {
      return false;
    } else if (!regExp.hasMatch(value)) {
      return false;
    }
    return true;
  }

  static Future<String> uploadUserImageToFireStorage(
      File image, String filePath, String fileName)
  async {
    Reference upload =
        FirebaseStorage.instance.ref().child('$filePath/$fileName');
    UploadTask uploadTask = upload.putFile(image);
    var downloadUrl =
        await (await uploadTask.whenComplete(() {})).ref.getDownloadURL();
    return downloadUrl.toString();
  }

  static Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  launchURL(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  static Future<MapModel?> getDurationDistance(
      LatLng departureLatLong, LatLng destinationLatLong)
  async {
    String url = 'https://maps.googleapis.com/maps/api/distancematrix/json';
    http.Response restaurantToCustomerTime = await http.get(Uri.parse(
        '$url?units=metric&origins=${departureLatLong.latitude},'
        '${departureLatLong.longitude}&destinations=${destinationLatLong.latitude},${destinationLatLong.longitude}&key=${Constant.mapAPIKey}'));

    log(restaurantToCustomerTime.body.toString());
    MapModel mapModel =
        MapModel.fromJson(jsonDecode(restaurantToCustomerTime.body));

    if (mapModel.status == 'OK' &&
        mapModel.rows!.first.elements!.first.status == "OK") {
      return mapModel;
    } else {
      ShowToastDialog.showToast(mapModel.errorMessage);
    }
    return null;
  }

  static Future<TimeOfDay?> selectTime(context,TimeOfDay? selectedTime) async {
    FocusScope.of(context).requestFocus(FocusNode()); //remove focus
    TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialEntryMode: TimePickerEntryMode.input,
      initialTime: selectedTime??TimeOfDay.now(),
    );
    if (newTime != null) {
      return newTime;
    }
    return null;
  }

  static Future<DateTime?> selectDate(context) async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppThemData.primary06, // header background color
                onPrimary: AppThemData.grey11, // header text color
                onSurface: AppThemData.grey11, // body text color
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: AppThemData.grey11, // button text color
                ),
              ),
            ),
            child: child!,
          );
        },
        initialDate: DateTime.now(),
        //get today's date
        firstDate: DateTime(1900),
        //DateTime.now() - not to allow to choose before today.
        lastDate: DateTime(2101));
    return pickedDate;
  }

  static String timestampToDate(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('MMM dd,yyyy').format(dateTime);
  }

  static String timestampToTime(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('HH:mm aa').format(dateTime);
  }

  static String timestampToTimeForChat(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd/MM/yyyy HH:mm aa').format(dateTime);
  }

  static String timestampToDateChat(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }

  static double calculateAdminCommission(
      {String? amount, AdminCommission? adminCommissionLocal}) {
    double taxAmount = 0.0;
    if (adminCommissionLocal != null && adminCommissionLocal.enable == true) {
      if (adminCommissionLocal.type == "fix") {
        taxAmount = double.parse(adminCommissionLocal.amount.toString());
      } else {
        if(double.parse(adminCommissionLocal.amount.toString())> 0.0){
          taxAmount = (double.parse(amount.toString()) *
              double.parse(adminCommissionLocal.amount!.toString())) / 100;
        }else{
          taxAmount = (double.parse(amount.toString()) *
              double.parse(adminCommission!.amount!.toString())) / 100;
        }

      }
    }
    return taxAmount;
  }

  static Future<Map<String, dynamic>> getDurationOsmDistance(
      LatLng departureLatLong, LatLng destinationLatLong)
  async {
    String url = 'http://router.project-osrm.org/route/v1/driving';
    String coordinates =
        '${departureLatLong.longitude},${departureLatLong.latitude};${destinationLatLong.longitude},${destinationLatLong.latitude}';

    http.Response response = await http
        .get(Uri.parse('$url/$coordinates?overview=false&steps=false'));

    log(response.body.toString());

    return jsonDecode(response.body);
  }

  static bool isValidUrl(String input) {
    log("input :: $input");
    final uri = Uri.tryParse(input);
    return uri != null &&
        uri.hasAbsolutePath &&
        (uri.isScheme("http") || uri.isScheme("https"));
  }

  /// This is Write New For Owner
  static String timestampToDateTime(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('MMM dd,yyyy hh:mm aa').format(dateTime);
  }
}

extension StringExtension on String {
  String capitalizeString() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
