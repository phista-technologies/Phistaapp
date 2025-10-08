import 'dart:async';
import 'dart:developer';
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:phista/constant/collection_name.dart';
import 'package:phista/constant/constant.dart';
import 'package:phista/model/admin_commission.dart';
import 'package:phista/model/bank_details_model.dart';
import 'package:phista/model/coupon_model.dart';
import 'package:phista/model/faq_model.dart';
import 'package:phista/model/language_model.dart';
import 'package:phista/model/on_boarding_model.dart';
import 'package:phista/model/order_model.dart';
import 'package:phista/model/parking_model.dart';
import 'package:phista/model/payment_method_model.dart';
import 'package:phista/model/referral_model.dart';
import 'package:phista/model/review_model.dart';
import 'package:phista/model/tax_model.dart';
import 'package:phista/model/user_model.dart';
import 'package:phista/model/user_vehicle_model.dart';
import 'package:phista/model/vehicle_brand_model.dart';
import 'package:phista/model/vehicle_model.dart';
import 'package:phista/model/wallet_transaction_model.dart';
import 'package:phista/model/withdraw_model.dart';
import 'package:phista/utils/utils.dart';
import 'package:phista/widgets/geoflutterfire/src/geoflutterfire.dart';

import '../model/model_owner/subscription_history.dart';
import '../model/parking_facilities_model.dart';
import '../model/payment/AppleUserDataModel.dart';
import '../model/subscription_plan_model.dart';
import '../widgets/geoflutterfire/src/models/point.dart';

class FireStoreUtils {
  static FirebaseFirestore fireStore = FirebaseFirestore.instance;

  static String getCurrentUid() {
    return FirebaseAuth.instance.currentUser!.uid;
  }

  static Future<bool> isLogin() async {
    bool isLogin = false;
    if (FirebaseAuth.instance.currentUser != null) {
      isLogin = await userExistOrNot(FirebaseAuth.instance.currentUser!.uid);
    } else {
      isLogin = false;
    }
    return isLogin;
  }

  static Future<String>getUserLastLoginType() async{
    String userLastLoginType = "";
    await FireStoreUtils.getUserProfile(FirebaseAuth.instance.currentUser!.uid).then((value) {
      print("value:-->$value");

      if (value != null) {
        userLastLoginType = value.lastLoginType.toString() ?? "";
      }
    });
    print(userLastLoginType);
    return userLastLoginType;

  }

  static Future<bool> userExistOrNot(String uid) async {
    bool isExist = false;
    await fireStore.collection(CollectionName.users).doc(uid).get().then(
      (value) {
        if (value.exists) {
          isExist = true;
        } else {
          isExist = false;
        }
      },
    ).catchError((error) {
      log("Failed to check user exist: $error");
      isExist = false;
    });
    return isExist;
  }

  static Future<List<OnBoardingModel>> getOnBoardingList() async {
    List<OnBoardingModel> onBoardingModel = [];
    await fireStore.collection(CollectionName.onBoarding).get().then((value) {
      for (var element in value.docs) {
        OnBoardingModel documentModel =
            OnBoardingModel.fromJson(element.data());
        onBoardingModel.add(documentModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return onBoardingModel;
  }

  static Future<List<ParkingModel>?> getMyParkingList(String userId) async {
    List<ParkingModel> parkingList = [];
    await fireStore
        .collection(CollectionName.parking)
        .where("userId", isEqualTo: userId)
        .get()
        .then((value) async {
      for (var element in value.docs) {
        ParkingModel facilitiesModel = ParkingModel.fromJson(element.data());
        parkingList.add(facilitiesModel);
      }
    });
    return parkingList;
  }

  Future<List<TaxModel>?> getTaxList() async {
    List<TaxModel> taxList = [];

    await fireStore
        .collection(CollectionName.tax)
        .where('country', isEqualTo: Constant.country)
        .where('enable', isEqualTo: true)
        .get()
        .then((value) {
      for (var element in value.docs) {
        TaxModel taxModel = TaxModel.fromJson(element.data());
        taxList.add(taxModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return taxList;
  }

  static Future<bool?> checkReferralCodeValidOrNot(String referralCode) async {
    bool? isExit;
    try {
      await fireStore
          .collection(CollectionName.referral)
          .where("referralCode", isEqualTo: referralCode)
          .get()
          .then((value) {
        if (value.size > 0) {
          isExit = true;
        } else {
          isExit = false;
        }
      });
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return false;
    }
    return isExit;
  }

  static Future<ReferralModel?> getReferralUserByCode(
      String referralCode)
  async {
    ReferralModel? referralModel;
    try {
      await fireStore
          .collection(CollectionName.referral)
          .where("referralCode", isEqualTo: referralCode)
          .get()
          .then((value) {
        referralModel = ReferralModel.fromJson(value.docs.first.data());
      });
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return referralModel;
  }

  static Future<String?> referralAdd(ReferralModel ratingModel) async {
    try {
      await fireStore
          .collection(CollectionName.referral)
          .doc(ratingModel.id)
          .set(ratingModel.toJson());
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return null;
  }

  static Future<bool> updateUser(UserModel userModel) async {
    bool isUpdate = false;
    await fireStore
        .collection(CollectionName.users)
        .doc(userModel.id)
        .set(userModel.toJson())
        .whenComplete(() {
      isUpdate = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isUpdate = false;
    });
    return isUpdate;
  }

  static Future<bool> getUserEmailExist(String email) async {
    bool isExist = true;
    await fireStore
        .collection(CollectionName.users)
        .where('email', isEqualTo: email.toLowerCase())
        .get()
        .then((value) {
      log("value.docs :: ${value.docs.length}");
      if (value.docs.isNotEmpty) {
        isExist = true;
      } else {
        isExist = false;
      }
    }).catchError((error) {
      log("Failed to update user: $error");
      isExist = false;
    });
    return isExist;
  }

  static Future<bool> getUserPhoneExist(String phone) async {
    bool isExist = true;
    await fireStore
        .collection(CollectionName.users)
        .where('phoneNumber', isEqualTo: phone)
        .get()
        .then((value) {
      log("value.docs :: ${value.docs.length}");
      if (value.docs.isNotEmpty) {
        isExist = true;
      } else {
        isExist = false;
      }
    }).catchError((error) {
      log("Failed to update user: $error");
      isExist = false;
    });
    return isExist;
  }

  static Future<UserModel?> getUserProfile(String uuid) async {
    UserModel? userModel;
    await fireStore
        .collection(CollectionName.users)
        .doc(uuid)
        .get()
        .then((value) {
      if (value.exists) {
        userModel = UserModel.fromJson(value.data()!);
      }
    }).catchError((error) {
      log("Failed to update user: $error");
      userModel = null;
    });
    return userModel;
  }

  static Future<UserModel?> getWatchman(
      String parkingId, String ownerId) async
  {
    UserModel? userModel;
    await fireStore
        .collection(CollectionName.users)
        .where("role", isEqualTo: "security")
        .where("parkingId", isEqualTo: parkingId)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        userModel = UserModel.fromJson(value.docs.first.data());
      }
    }).catchError((error) {
      log("Failed to update user: $error");
      userModel = null;
    });
    return userModel;
  }

  // Future<CurrencyModel?> getCurrency() async {
  //   CurrencyModel? currencyModel;
  //   await fireStore.collection(CollectionName.currency).where("enable", isEqualTo: true).get().then((value) {
  //     if (value.docs.isNotEmpty) {
  //       currencyModel = CurrencyModel.fromJson(value.docs.first.data());
  //     }
  //   });
  //   return currencyModel;
  // }

  static Future<List<LanguageModel>?> getLanguage() async {
    List<LanguageModel> languageList = [];

    await fireStore.collection(CollectionName.languages).get().then((value) {
      for (var element in value.docs) {
        LanguageModel taxModel = LanguageModel.fromJson(element.data());
        languageList.add(taxModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return languageList;
  }

  static Future<List<VehicleBrandModel>?> gerBrand() async {
    List<VehicleBrandModel> brandList = [];

    await fireStore
        .collection(CollectionName.brand)
        .where("enable", isEqualTo: true)
        .get()
        .then((value) {
      for (var element in value.docs) {
        VehicleBrandModel taxModel = VehicleBrandModel.fromJson(element.data());
        brandList.add(taxModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return brandList;
  }

  static Future<List<VehicleModel>?> getVehicleModel(String id) async {
    List<VehicleModel> vehicleModel = [];

    await fireStore
        .collection(CollectionName.model)
        .where("brandId", isEqualTo: id)
        .where("enable", isEqualTo: true)
        .get()
        .then((value) {
      for (var element in value.docs) {
        VehicleModel taxModel = VehicleModel.fromJson(element.data());
        vehicleModel.add(taxModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return vehicleModel;
  }

  static Future<bool?> deleteUser() async {
    bool? isDelete;
    try {
      await fireStore
          .collection(CollectionName.users)
          .doc(FireStoreUtils.getCurrentUid())
          .delete();

      // delete user  from firebase auth
      await FirebaseAuth.instance.currentUser!.delete().then((value) {
        isDelete = true;
      });
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return false;
    }
    return isDelete;
  }

  static Future<Map<String, String>?> getUserPasswordByEmail(String email) async {
    try {
      log("Searching for email: ${email.trim().toLowerCase()}");

      final querySnapshot = await fireStore
          .collection(CollectionName.users)
          .where('email', isEqualTo: email.trim().toLowerCase())
          .get();

      log("Documents found: ${querySnapshot.docs.length}");

      if (querySnapshot.docs.isNotEmpty) {
        final userData = querySnapshot.docs.first.data();
        final password = userData['password'] ?? '';
        final phoneNumber = userData['phoneNumber'] ?? '';
        log("Password fetched: $password, Phone: $phoneNumber");

        return {
          'password': password,
          'phoneNumber': phoneNumber,
        };
      } else {
        log("No user found with this email");
        return null;
      }
    } catch (error) {
      log("Failed to get user password: $error");
      return null;
    }
  }

  getSettings() async {
    fireStore
        .collection(CollectionName.settings)
        .doc("globalKey")
        .snapshots()
        .listen((event) {
      if (event.exists) {
        Constant.mapAPIKey = event.data()!["googleMapKey"];
        Constant.radius = event.data()!["radius"];
        Constant.distanceType = event.data()!["distanceType"];
        Constant.isSubscriptionModelApplied =
            event.data()!['subscription_model'];
      }
    });

    await fireStore
        .collection(CollectionName.settings)
        .doc("adminCommission")
        .get()
        .then((value) {
      Constant.adminCommission = AdminCommission.fromJson(value.data()!);
    });

    await fireStore
        .collection(CollectionName.settings)
        .doc("notification_setting")
        .get()
        .then((value) {
      if (value.exists) {
        Constant.senderId = value.data()!['senderId'].toString();
        Constant.jsonNotificationFileURL =
            value.data()!['serviceJson'].toString();
      }
    });

    await fireStore
        .collection(CollectionName.settings)
        .doc("global")
        .get()
        .then((value) {
      if (value.exists) {
        Constant.termsAndConditions = value.data()!["termsAndConditions"];
        Constant.privacyPolicy = value.data()!["privacyPolicy"];
        Constant.minimumAmountToDeposit =
            value.data()!["minimumAmountToDeposit"];
        Constant.minimumAmountToWithdrawal =
            value.data()!["minimumAmountToWithdrawal"];
        Constant.mapType = value.data()!["mapType"];
        Constant.selectedMapType = value.data()!["selectedMapType"];
        Constant.locationUpdate = value.data()!["locationUpdate"];
      }
    });

    await fireStore
        .collection(CollectionName.settings)
        .doc("referral")
        .get()
        .then((value) {
      if (value.exists) {
        Constant.referralAmount = value.data()!["referralAmount"];
      }
    });

    await fireStore
        .collection(CollectionName.settings)
        .doc("contact_us")
        .get()
        .then((value) {
      if (value.exists) {
        Constant.supportURL = value.data()!["supportURL"];
      }
    });
  }


  // static Future<ParkingModel?> getUserParkingDetails(String id) async {
  //   ParkingModel? parkingModel;
  //   await fireStore
  //       .collection(CollectionName.parking)
  //       .doc(id)
  //       .get()
  //       .then((value) {
  //     parkingModel = ParkingModel.fromJson(value.data()!);
  //   });
  //   return parkingModel;
  // }

  static Future<String?> saveParkingDetails(ParkingModel createSlotModel) async {
    try {
      await fireStore
          .collection(CollectionName.parking)
          .doc(createSlotModel.id)
          .set(createSlotModel.toJson());
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return null;
  }




  // static Future<String?> deleteParking(ParkingModel parkingModel) async {
  //   try {
  //     await fireStore
  //         .collection(CollectionName.parking)
  //         .doc(parkingModel.id)
  //         .delete();
  //   } catch (e, s) {
  //     log('FireStoreUtils.firebaseCreateNewUser $e $s');
  //     return null;
  //   }
  //   return null;
  // }

  Future<PaymentModel?> getPayment() async {
    PaymentModel? paymentModel;
    await fireStore
        .collection(CollectionName.settings)
        .doc("payment")
        .get()
        .then((value) {
      paymentModel = PaymentModel.fromJson(value.data()!);
    });
    return paymentModel;
  }

  // static Future<List<ParkingFacilitiesModel>> getParkingFacilities() async {
  //   List<ParkingFacilitiesModel> facilitiesModelList = [];
  //   await fireStore
  //       .collection(CollectionName.facilities)
  //       .where('isEnable', isEqualTo: true)
  //       .get()
  //       .then((value) async {
  //     for (var element in value.docs) {
  //       ParkingFacilitiesModel facilitiesModel =
  //           ParkingFacilitiesModel.fromJson(element.data());
  //       facilitiesModelList.add(facilitiesModel);
  //     }
  //   });
  //   return facilitiesModelList;
  // }
  final geo = Geoflutterfire();
  StreamController<List<ParkingModel>>? getNearestOrderRequestController;

  Stream<List<ParkingModel>> getParkingNearest({
    double? latitude,
    double? longLatitude,
  })
  async* {
    // Close previous controller if already opened
    getNearestOrderRequestController?.close();

    getNearestOrderRequestController =
        StreamController<List<ParkingModel>>.broadcast();
    List<ParkingModel> latestEmittedList = [];

    var query = fireStore
        .collection(CollectionName.parking)
        .where("isEnable", isEqualTo: true);

    GeoFirePoint center = geo.point(
      latitude: latitude ?? 0.0,
      longitude: longLatitude ?? 0.0,
    );

    Stream<List<DocumentSnapshot>> stream =
        geo.collection(collectionRef: query).within(
              center: center,
              radius: double.parse(Constant.radius),
              field: 'position',
              strictMode: true,
            );

    stream.listen((List<DocumentSnapshot> documentList) async {
      final Set<String> seenIds = {};
      final List<ParkingModel> ordersList = [];

      for (var document in documentList) {
        final data = document.data() as Map<String, dynamic>;
        final ParkingModel orderModel = ParkingModel.fromJson(data);

        final id = orderModel.id;
        if (id == null || seenIds.contains(id)) continue;

        bool shouldAdd = false;

        if (!Constant.isSubscriptionModelApplied &&
            Constant.adminCommission?.enable == false) {
          shouldAdd = true;
        } else if ((Constant.isSubscriptionModelApplied ||
                Constant.adminCommission?.enable == true) &&
            orderModel.subscriptionPlan != null) {
          if (orderModel.subscriptionTotalOrders == "-1") {
            shouldAdd = true;
          } else if ((orderModel.subscriptionExpiryDate != null &&
                  orderModel.subscriptionExpiryDate!
                      .toDate()
                      .isAfter(DateTime.now())) ||
              orderModel.subscriptionPlan?.expiryDay == "-1") {
            if (orderModel.subscriptionTotalOrders != '0') {
              shouldAdd = true;
            }
          }
        }

        if (shouldAdd) {
          seenIds.add(id);
          ordersList.add(orderModel);
        }
      }

      // Emit only if changed (compare by ID list)
      final currentIds = latestEmittedList.map((e) => e.id).toSet();
      final newIds = ordersList.map((e) => e.id).toSet();

      if (!setEquals(currentIds, newIds)) {
        latestEmittedList = List.from(ordersList);
        getNearestOrderRequestController!.sink.add(latestEmittedList);
      }
    });

    yield* getNearestOrderRequestController!.stream;
  }



  static Future<double> getParkingBookingPercentage(String parkingId, String parkingSpace)async{
    List<String> isParkingBookedOnList = [];

   await fireStore.collection(CollectionName.bookedParkingOrder)
       .where('parkingId', isEqualTo: parkingId,)
       .where('status', whereIn: [Constant.placed, Constant.onGoing])
   .get()
   .then((value) {
     print("getParkingBookingPercentage :-- ${value.docs.length}");
     for (var element in value.docs) {
       final data = element.data();
       final bookingDateString = data['bookingDate'] ?? '';
       final bookingType = data['bookingType'] ?? '';
       final parkingName = data['parkingDetails']['name'] ?? '';

       print("parkingName :- $parkingName");
       if(bookingType == "1"){

         final bookingStartTimeFireStore = data['bookingStartTime'] ?? '';
         final bookingEndTimeFireStore = data['bookingEndTime'] ?? '';

         var isCurrentDate = isBookingToday(bookingDateString);

         print("isCurrentDate :- $isCurrentDate");

         if(isCurrentDate){
           bool result = isCurrentTimeBetween(bookingStartTimeFireStore, bookingEndTimeFireStore);

           print("isCurrentTimeBetween :- $result");

           if(result){
             isParkingBookedOnList.add(bookingDateString.toString());
           }
         }

       }
       else if(bookingType == "3"){
         final List<dynamic> bookingDates = bookingDateString
             .split(',')
             .map((e) => e.trim())
             .toList();

         print("bookingDates :-- $bookingDates");

         if (bookingDates.length == 2) {

           DateTime bookingStart = Utils.stringToTimeStamp(bookingDates[0]).toDate();
           DateTime bookingEnd = Utils.stringToTimeStamp(bookingDates[1]).toDate();

          String currentDate =  Utils.formatTimestampToIST(
               Timestamp.fromDate(DateTime(
                   DateTime.now().year,
                   DateTime.now().month,
                   DateTime.now().day)));

         DateTime now =  Utils.stringToTimeStamp(currentDate.trim()).toDate();

           bool isWithinRange =
               (now.isAtSameMomentAs(bookingStart) || now.isAfter(bookingStart)) &&
                   (now.isAtSameMomentAs(bookingEnd) || now.isBefore(bookingEnd));

           print("isWithinRange :-- $isWithinRange");

           if (isWithinRange) {
             isParkingBookedOnList.add(bookingDateString.toString());
           }
         }
       }

     }
   },);

    int totalSlots = int.tryParse(parkingSpace) ?? 0;
    int bookedSlots = isParkingBookedOnList.length;

    double percentage = totalSlots > 0 ? (bookedSlots / totalSlots) * 100 : 0.0;

    print("parking space :-- $parkingSpace");
    print("active booked slots :-- $bookedSlots");
    print("Booking percentage :-- $percentage");

    return percentage;

  }

 static bool isBookingToday(String bookingDateStr) {
    DateTime bookingDate = DateFormat("d MMMM yyyy 'at' HH:mm:ss 'UTC+5:30'")
        .parse(bookingDateStr, true)
        .toLocal();

    DateTime now = DateTime.now();
    return bookingDate.year == now.year &&
        bookingDate.month == now.month &&
        bookingDate.day == now.day;
  }

 static bool isCurrentTimeBetween(Timestamp startTimeStamp, Timestamp endTimeStamp) {
   DateTime startTime = startTimeStamp.toDate().toLocal();
   DateTime endTime = endTimeStamp.toDate().toLocal();
   DateTime currentTime = DateTime.now();
   return currentTime.isAfter(startTime) && currentTime.isBefore(endTime);
  }

  // Stream<List<ParkingModel>> getParkingNearest(
  //     {double? latitude, double? longLatitude}) async* {
  //   getNearestOrderRequestController =
  //       StreamController<List<ParkingModel>>.broadcast();
  //   List<ParkingModel> ordersList = [];
  //   var query = fireStore
  //       .collection(CollectionName.parking)
  //       .where("isEnable", isEqualTo: true);

  //   GeoFirePoint center =
  //       geo.point(latitude: latitude ?? 0.0, longitude: longLatitude ?? 0.0);
  //   Stream<List<DocumentSnapshot>> stream = geo
  //       .collection(collectionRef: query)
  //       .within(
  //           center: center,
  //           radius: double.parse(Constant.radius),
  //           field: 'position',
  //           strictMode: true);

  //   stream.listen((List<DocumentSnapshot> documentList) async {
  //     ordersList.clear();
  //     for (var document in documentList) {
  //       final data = document.data() as Map<String, dynamic>;
  //       ParkingModel orderModel = ParkingModel.fromJson(data);

  //       if (Constant.isSubscriptionModelApplied == false &&
  //           Constant.adminCommission?.enable == false) {
  //         ordersList.add(orderModel);
  //       } else {
  //         log("======>");
  //         log(orderModel.toJson().toString());
  //         if ((Constant.isSubscriptionModelApplied == true ||
  //                 Constant.adminCommission?.enable == true) &&
  //             orderModel.subscriptionPlan != null) {
  //           if (orderModel.subscriptionTotalOrders == "-1") {
  //             ordersList.add(orderModel);
  //           } else {
  //             if ((orderModel.subscriptionExpiryDate != null &&
  //                     orderModel.subscriptionExpiryDate!
  //                             .toDate()
  //                             .isBefore(DateTime.now()) ==
  //                         false) ||
  //                 orderModel.subscriptionPlan?.expiryDay == "-1") {
  //               if (orderModel.subscriptionTotalOrders != '0') {
  //                 ordersList.add(orderModel);
  //               }
  //             }
  //           }
  //         }
  //       }
  //     }
  //     getNearestOrderRequestController!.sink.add(ordersList);
  //   });

  //   yield* getNearestOrderRequestController!.stream;
  // }

  Future<List<ParkingModel>> getParkingNearestFuture(
      {double? latitude, double? longLatitude})
  async {
    List<ParkingModel> ordersList = [];
    var query = fireStore
        .collection(CollectionName.parking)
        .where("isEnable", isEqualTo: true);

    GeoFirePoint center =
        geo.point(latitude: latitude ?? 0.0, longitude: longLatitude ?? 0.0);
    Stream<List<DocumentSnapshot>> stream = geo
        .collection(collectionRef: query)
        .within(
            center: center,
            radius: double.parse(Constant.radius),
            field: 'position',
            strictMode: true);

    // Get the first list of documents emitted by the stream
    List<DocumentSnapshot> documentList = await stream.first;

    for (var document in documentList) {
      final data = document.data() as Map<String, dynamic>;
      ParkingModel orderModel = ParkingModel.fromJson(data);

      if (Constant.isSubscriptionModelApplied == false &&
          Constant.adminCommission?.enable == false) {
        ordersList.add(orderModel);
      } else {
        if ((Constant.isSubscriptionModelApplied == true ||
                Constant.adminCommission?.enable == true) &&
            orderModel.subscriptionPlan != null) {
          if (orderModel.subscriptionTotalOrders == "-1") {
            ordersList.add(orderModel);
          } else {
            if ((orderModel.subscriptionExpiryDate != null &&
                    orderModel.subscriptionExpiryDate!
                        .toDate()
                        .isAfter(DateTime.now())) ||
                orderModel.subscriptionPlan?.expiryDay == "-1") {
              if (orderModel.subscriptionTotalOrders != '0') {
                ordersList.add(orderModel);
              }
            }
          }
        }
      }
    }

    return ordersList;
  }

  StreamController<List<ParkingModel>>? getNearestFilterParking;

  Stream<List<ParkingModel>> getFilterParking(
      {double? latitude,
      double? longLatitude,
      String? parkingType,
      String? distance})
  async* {
    getNearestFilterParking = StreamController<List<ParkingModel>>.broadcast();
    List<ParkingModel> ordersList = [];

    var query = fireStore
        .collection(CollectionName.parking)
        .where("parkingType", isEqualTo: parkingType)
        .where("isEnable", isEqualTo: true);

    GeoFirePoint center =
        geo.point(latitude: latitude ?? 0.0, longitude: longLatitude ?? 0.0);
    Stream<List<DocumentSnapshot>> stream = geo
        .collection(collectionRef: query)
        .within(
            center: center,
            radius: double.parse(distance.toString()),
            field: 'position',
            strictMode: true);
    stream.listen((List<DocumentSnapshot> documentList) {
      ordersList.clear();
      for (var document in documentList) {
        final data = document.data() as Map<String, dynamic>;
        ParkingModel orderModel = ParkingModel.fromJson(data);

        ordersList.add(orderModel);
      }
      getNearestFilterParking!.sink.add(ordersList);
    });

    yield* getNearestFilterParking!.stream;
  }

  static Future<ParkingModel?> getParkingDetails(String uuid) async {
    ParkingModel? slotModel;
    await fireStore
        .collection(CollectionName.parking)
        .doc(uuid)
        .get()
        .then((value){
      if (value.exists) {
        slotModel = ParkingModel.fromJson(value.data()!);
      }
    }).catchError((error) {
      log("Failed to update user: $error");
      slotModel = null;
    });
    return slotModel;
  }

  static Future<OrderModel?> getSingleOrder(String orderId) async {
    OrderModel? orderModel;
    await fireStore
        .collection(CollectionName.bookedParkingOrder)
        .doc(orderId)
        .get()
        .then((value) {
      if (value.exists) {
        orderModel = OrderModel.fromJson(value.data()!);
      }
    }).catchError((error) {
      log("Failed to update user: $error");
      orderModel = null;
    });
    return orderModel;
  }

  // static Future<List<ParkingModel>?> getMyParkingList() async {
  //   List<ParkingModel> parkingList = [];
  //   await fireStore
  //       .collection(CollectionName.parking)
  //       .where("userId", isEqualTo: getCurrentUid())
  //       .get()
  //       .then((value) async {
  //     for (var element in value.docs) {
  //       ParkingModel facilitiesModel = ParkingModel.fromJson(element.data());
  //       parkingList.add(facilitiesModel);
  //     }
  //   });
  //   return parkingList;
  // }

  static Future<bool?> bookMarked(ParkingModel parkingModel) async {
    try {
      if (parkingModel.bookmarkedUser == null) {
        parkingModel.bookmarkedUser = [];
        parkingModel.bookmarkedUser!.add(getCurrentUid());
      } else {
        parkingModel.bookmarkedUser!.add(getCurrentUid());
      }
      await fireStore
          .collection(CollectionName.parking)
          .doc(parkingModel.id)
          .set(parkingModel.toJson());
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return null;
  }

  static Future<bool?> removeBookMarked(ParkingModel parkingModel) async {
    try {
      parkingModel.bookmarkedUser!.remove(getCurrentUid());

      await fireStore
          .collection(CollectionName.parking)
          .doc(parkingModel.id)
          .set(parkingModel.toJson());
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return null;
  }

  static Future<List<ParkingModel>?> getBookMarkedList() async {
    List<ParkingModel> parkingList = [];
    await fireStore
        .collection(CollectionName.parking)
        .where("bookmarkedUser", arrayContains: getCurrentUid())
        .get()
        .then((value) async {
      for (var element in value.docs) {
        ParkingModel facilitiesModel = ParkingModel.fromJson(element.data());
        parkingList.add(facilitiesModel);
      }
    });
    return parkingList;
  }

  static Future<bool> updateUserVehicle(
      UserVehicleModel userVehicleModel)
  async {
    bool isUpdate = false;
    await fireStore
        .collection(CollectionName.userVehicles)
        .doc(userVehicleModel.id)
        .set(userVehicleModel.toJson())
        .whenComplete(() {
      isUpdate = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isUpdate = false;
    });
    return isUpdate;
  }

  static Future<List<UserVehicleModel>?> getUserVehicle() async {
    List<UserVehicleModel> userVehicleList = [];
    await fireStore
        .collection(CollectionName.userVehicles)
        .where("userId", isEqualTo: getCurrentUid())
        .get()
        .then((value) async {
      for (var element in value.docs) {
        UserVehicleModel facilitiesModel =
            UserVehicleModel.fromJson(element.data());
        userVehicleList.add(facilitiesModel);
      }
    });
    return userVehicleList;
  }

  static Future<bool?> setOrder(OrderModel orderModel) async {
    bool isAdded = false;
    await fireStore
        .collection(CollectionName.bookedParkingOrder)
        .doc(orderModel.id)
        .set(orderModel.toJson())
        .then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<List<OrderModel>?> getOrder(Timestamp date, Timestamp startTime,
      Timestamp endTime, String parkingId,String type)
  async {
    List<OrderModel> orderList = [];
   try{

     await fireStore
         .collection(CollectionName.bookedParkingOrder)
         .where('parkingId', isEqualTo: parkingId,)
         .where('status', whereIn: [Constant.placed, Constant.onGoing])
         .get()
         .then((value) async {
           print("getOrder :-- ${value.docs.length}");
       for (var element in value.docs) {
         final data = element.data();
         final bookingDateString = data['bookingDate'] ?? '';
         final bookingType = data['bookingType'] ?? '';

         if(type == "hourly"){ // for hourly OR daily
           if(bookingType.toString() == "1"){
             final List<dynamic> bookingDates = bookingDateString.split(',').map((e) => e.trim()).toList();

             print("bookingDates :-- $bookingDates ,,, data :- ${date}");

             bool contains = checkDateContains(bookingDates,date);
             print("isContains :- $contains");

            if(contains){
              OrderModel orderModel = OrderModel.fromJson(data);
              orderList.add(orderModel);
            }


           }else{

             OrderModel orderModel = OrderModel.fromJson(data);
             orderList.add(orderModel);
           }

         }
         else if(type == "monthly"){ // for month
           OrderModel orderModel = OrderModel.fromJson(data);
           orderList.add(orderModel);
         }

       }
     });

   }catch(e){
     print("Exception :-- e");
   }
    return orderList;
  }

  static Future<bool?> setWalletTransaction(
      WalletTransactionModel walletTransactionModel)
  async {
    bool isAdded = false;
    await fireStore
        .collection(CollectionName.walletTransaction)
        .doc(walletTransactionModel.id)
        .set(walletTransactionModel.toJson())
        .then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<bool?> updateUserWallet({required String amount}) async {
    bool isAdded = false;
    await getUserProfile(FireStoreUtils.getCurrentUid()).then((value) async {
      if (value != null) {
        UserModel userModel = value;
        userModel.walletAmount =
            (double.parse(userModel.walletAmount.toString()) +
                    double.parse(amount))
                .toString();
        await FireStoreUtils.updateUser(userModel).then((value) {
          isAdded = value;
        });
      }
    });
    return isAdded;
  }

  static Future<bool?> updateOtherUserWallet(
      {required String amount, required String id})
  async {
    bool isAdded = false;
    await getUserProfile(id).then((value) async {
      if (value != null) {
        UserModel userModel = value;
        userModel.walletAmount =
            (double.parse(userModel.walletAmount.toString()) +
                    double.parse(amount))
                .toString();
        await FireStoreUtils.updateUser(userModel).then((value) {
          isAdded = value;
        });
      }
    });
    return isAdded;
  }

  static Future<List<WalletTransactionModel>?> getWalletTransaction() async {
    List<WalletTransactionModel> walletTransactionModel = [];

    await fireStore
        .collection(CollectionName.walletTransaction)
        .where('userId', isEqualTo: FireStoreUtils.getCurrentUid())
        .orderBy('createdDate', descending: true)
        .get()
        .then((value) {
      for (var element in value.docs) {
        WalletTransactionModel taxModel =
            WalletTransactionModel.fromJson(element.data());
        walletTransactionModel.add(taxModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return walletTransactionModel;
  }

  static Future<List<FaqModel>> getFaq() async {
    List<FaqModel> faqModel = [];
    await fireStore
        .collection(CollectionName.faq)
        .where('enable', isEqualTo: true)
        .get()
        .then((value) {
      for (var element in value.docs) {
        FaqModel documentModel = FaqModel.fromJson(element.data());
        faqModel.add(documentModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return faqModel;
  }

  static Future<ReviewModel?> getReview(String orderId) async {
    ReviewModel? reviewModel;
    await fireStore
        .collection(CollectionName.review)
        .doc(orderId)
        .get()
        .then((value) {
      if (value.data() != null) {
        reviewModel = ReviewModel.fromJson(value.data()!);
      }
    });
    return reviewModel;
  }

  static Future<bool?> setReview(ReviewModel reviewModel) async {
    bool isAdded = false;
    await fireStore
        .collection(CollectionName.review)
        .doc(reviewModel.id)
        .set(reviewModel.toJson())
        .then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<List<WithdrawModel>> getWithDrawRequest() async {
    List<WithdrawModel> withdrawalList = [];
    await fireStore
        .collection(CollectionName.withdrawalHistory)
        .where('userId', isEqualTo: getCurrentUid())
        .orderBy('createdDate', descending: true)
        .get()
        .then((value) {
      for (var element in value.docs) {
        WithdrawModel documentModel = WithdrawModel.fromJson(element.data());
        withdrawalList.add(documentModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return withdrawalList;
  }

  static Future<BankDetailsModel?> getBankDetails() async {
    BankDetailsModel? bankDetailsModel;
    await fireStore
        .collection(CollectionName.bankDetails)
        .doc(FireStoreUtils.getCurrentUid())
        .get()
        .then((value) {
      if (value.data() != null) {
        bankDetailsModel = BankDetailsModel.fromJson(value.data()!);
      }
    });
    return bankDetailsModel;
  }

  static Future<bool?> updateBankDetails(
      BankDetailsModel bankDetailsModel)
  async {
    bool isAdded = false;
    await fireStore
        .collection(CollectionName.bankDetails)
        .doc(bankDetailsModel.userId)
        .set(bankDetailsModel.toJson())
        .then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<bool?> bankDetailsIsAvailable() async {
    bool isAdded = false;
    await fireStore
        .collection(CollectionName.bankDetails)
        .doc(FireStoreUtils.getCurrentUid())
        .get()
        .then((value) {
      if (value.exists) {
        isAdded = true;
      } else {
        isAdded = false;
      }
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<bool?> setWithdrawRequest(WithdrawModel withdrawModel) async {
    bool isAdded = false;
    await fireStore
        .collection(CollectionName.withdrawalHistory)
        .doc(withdrawModel.id)
        .set(withdrawModel.toJson())
        .then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  /*static Future<ReferralModel?> getReferral() async {
    ReferralModel? referralModel;
    await fireStore
        .collection(CollectionName.referral)
        .doc(FireStoreUtils.getCurrentUid())
        .get()
        .then((value) {
      if (value.exists) {
        referralModel = ReferralModel.fromJson(value.data()!);
      }
    }).catchError((error) {
      log("Failed to update user: $error");
      referralModel = null;
    });
    return referralModel;
  }*/

  static Future<ReferralModel?> getReferral() async {
    try {
      final uid = FireStoreUtils.getCurrentUid();
      log("Fetching referral for UID: $uid");

      final snapshot = await fireStore
          .collection(CollectionName.referral)
          .doc(uid)
          .get();

      if (snapshot.exists && snapshot.data() != null) {
        log("Referral data found: ${snapshot.data()}");
        return ReferralModel.fromJson(snapshot.data()!);
      } else {
        log("Referral document does not exist. Creating one...");

        // Create a new referral document
        final referralModel = ReferralModel(
          id: uid,
          referralBy: "",
          referralCode: Constant.getReferralCode(),
        );

        // Save to Firestore
        await FireStoreUtils.referralAdd(referralModel);
        log("Referral document created: ${referralModel.referralCode}");

        return referralModel;
      }
    } catch (error) {
      log("Error while fetching or creating referral: $error");
      return null;
    }
  }

  static Future<bool> getFirstOrderOrNOt(OrderModel orderModel) async {
    bool isFirst = true;
    await fireStore
        .collection(CollectionName.bookedParkingOrder)
        .where('userId', isEqualTo: orderModel.userId)
        .get()
        .then((value) {
      if (value.size == 1) {
        isFirst = true;
      } else {
        isFirst = false;
      }
    });
    return isFirst;
  }

  static Future updateReferralAmount(OrderModel orderModel) async {
    ReferralModel? referralModel;
    await fireStore
        .collection(CollectionName.referral)
        .doc(orderModel.userId)
        .get()
        .then((value) {
      if (value.data() != null) {
        referralModel = ReferralModel.fromJson(value.data()!);
      } else {
        return;
      }
    });
    if (referralModel != null) {
      if (referralModel!.referralBy != null &&
          referralModel!.referralBy!.isNotEmpty) {
        await fireStore
            .collection(CollectionName.users)
            .doc(referralModel!.referralBy)
            .get()
            .then((value) async {
          DocumentSnapshot<Map<String, dynamic>> userDocument = value;
          if (userDocument.data() != null && userDocument.exists) {
            try {
              log(userDocument.data().toString());
              UserModel user = UserModel.fromJson(userDocument.data()!);
              user.walletAmount = (double.parse(user.walletAmount.toString()) +
                      double.parse(Constant.referralAmount.toString()))
                  .toString();
              updateUser(user);

              WalletTransactionModel transactionModel = WalletTransactionModel(
                  id: Constant.getUuid(),
                  amount: Constant.referralAmount.toString(),
                  createdDate: Timestamp.now(),
                  paymentType: "Wallet",
                  transactionId: orderModel.id,
                  userId: user.id.toString(),
                  note: "Referral Amount");

              await FireStoreUtils.setWalletTransaction(transactionModel);
            } catch (error) {
              print(error);
            }
          }
        });
      } else {
        return;
      }
    }
  }

  Future<List<CouponModel>?> getCoupon() async {
    List<CouponModel> couponModel = [];

    await fireStore
        .collection(CollectionName.coupon)
        .where('enable', isEqualTo: true)
        .where("isPublic", isEqualTo: true)
        .where('validity', isGreaterThanOrEqualTo: Timestamp.now())
        .get()
        .then((value) {
      for (var element in value.docs) {
        CouponModel taxModel = CouponModel.fromJson(element.data());
        couponModel.add(taxModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return couponModel;
  }


  static Future<bool> updateUserPassword(String userEmail, String password) async {
    try {
      log("Searching for email: ${userEmail.trim().toLowerCase()}");

      final querySnapshot = await fireStore
          .collection(CollectionName.users)
          .where('email', isEqualTo: userEmail.trim().toLowerCase())
          .get();

      log("Documents found: ${querySnapshot.docs.length}");

      if (querySnapshot.docs.isNotEmpty) {
        final userData = querySnapshot.docs.first.data();
        final userId = userData['id'] ?? '';

        try {
          await fireStore
              .collection(CollectionName.users)
              .doc(userId)
              .update({'password': password});
          print("Password updated");
          return true;
        } catch (error) {
          print('Update failed: $error');
          return false;
        }
      } else {
        log("No user found with this email");
        return false;
      }
    } catch (error) {
      log("Failed to get user password: $error");
      return false;
    }
  }

  static Future<bool> appleUserData(AppleUserDataModel appleUserDataModel) async {
    bool isDataSaved = false;
    await fireStore.collection(CollectionName.appleUserData).doc(appleUserDataModel.userIdentifier).set(appleUserDataModel.toJson()).whenComplete(() {
      isDataSaved = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isDataSaved = false;
    });
    return isDataSaved;
  }

  static Future<AppleUserDataModel?> getAppleUserData(String appleSocialId) async {
    print("appleSocialId:---$appleSocialId");
    AppleUserDataModel? appleUserDataModel ;
    await fireStore.collection(CollectionName.appleUserData)
        .where('userIdentifier', isEqualTo: appleSocialId.toLowerCase())
        .get().then((value) {

      print("getAppleUserData :-- $value");
      for (var element in value.docs) {
        appleUserDataModel = AppleUserDataModel.fromJson(element.data());
      }
    }).catchError((error) {
      log(error.toString());
    });
    return appleUserDataModel;
  }

  static bool isBookingActive(String bookingDateString, Timestamp bookingEndTime) {
    try {
      bookingDateString = bookingDateString.replaceAll(" at", "");
      DateFormat format = DateFormat("d MMMM yyyy HH:mm:ss");
      DateTime bookingStart = format.parse(bookingDateString, true);
      print("Original DateTime: $bookingStart");
      DateTime bookingEnd = bookingEndTime.toDate().toUtc();
      DateTime now = DateTime.now().toUtc();
      return now.isAfter(bookingStart) && now.isBefore(bookingEnd);
    } catch (e) {
      print("Error parsing date: $e");
      return false;
    }
  }


  /*static Future<void> deleteGuestUsersIfAllBookingsCompleted() async {
    try {
      final userSnapshot = await fireStore
          .collection('users')
          .where('role', isEqualTo: 'Guest')
          .get();
      if (userSnapshot.docs.isEmpty) {
        print("No guest users found.");
        return;
      }
      for (var userDoc in userSnapshot.docs) {
        final userId = userDoc.id;
        final bookingSnapshot = await fireStore
            .collection(CollectionName.bookedParkingOrder)
            .where('userId', isEqualTo: userId)
            .get();
        bool allCompleted = bookingSnapshot.docs.every(
              (doc) => doc.data()['status']?.toString() == Constant.completed,
        );
        if (allCompleted) {
          await fireStore.collection('users').doc(userId).delete();
          print("Deleted guest user with ID: $userId");
        } else {
          print("User $userId has incomplete bookings,skipping delete.");
        }
      }
      print("Finished checking all guest users.");
    } catch (e, s) {
      print("Error deleting guest users: $e");
      log("StackTrace: $s");
    }
  }*/


  static Future<void> deleteGuestUsersIfAllBookingsCompleted() async {
    try {
      // 1️⃣ Get all users with role 'Guest'
      final userSnapshot = await fireStore
          .collection('users')
          .where('role', isEqualTo: 'Guest')
          .get();
      if (userSnapshot.docs.isEmpty) {
        print("No guest users found.");
        return;
      }
      // Initialize Firebase Admin if not done
      final admin = FirebaseAuth.instance;
      for (var userDoc in userSnapshot.docs) {
        final userId = userDoc.id;

        final bookingSnapshot = await fireStore
            .collection(CollectionName.bookedParkingOrder)
            .where('userId', isEqualTo: userId)
            .get();

        bool allCompleted = bookingSnapshot.docs.every(
              (doc) => doc.data()['status']?.toString() == Constant.completed,
        );
        if (allCompleted) {
          await fireStore.collection('users').doc(userId).delete();
          print("Deleted guest user document with ID: $userId");
          try {
            await admin.currentUser!.delete();
            print("Deleted guest user from Auth with ID: $userId");
          } catch (authError) {
            print("Failed to delete user from Auth: $authError");
          }
        } else {
          print("User $userId has incomplete bookings, skipping delete.");
        }
      }
      print("Finished checking all guest users.");
    } catch (e, s) {
      print("Error deleting guest users: $e");
      log("StackTrace: $s");
    }
  }






  /// This Is Write New For Owner

  static Future<bool> parkingBookedOrNot(dynamic parkingId) async {
    try {
      final value = await fireStore
          .collection(CollectionName.bookedParkingOrder)
          .where("parkingId", isEqualTo: parkingId)
          .get();

      for (var element in value.docs) {
        print("value.element :- ${element.data()["status"].toString()}");
        if (element.data()["status"].toString() != "completed") {
          return true;
        }
      }
      return false;
    } catch (e, s) {
      log('parkingBookedOrNot error: $e\n$s');
      return false;
    }
  }

  static Future<ParkingModel?> getUserParkingDetails(String id) async {
    ParkingModel? parkingModel;
    await fireStore.collection(CollectionName.parking).doc(id).get().then((value) {
      parkingModel = ParkingModel.fromJson(value.data()!);
    });
    return parkingModel;
  }

  static Future<List<ParkingFacilitiesModel>> getParkingFacilities() async {
    List<ParkingFacilitiesModel> facilitiesModelList = [];
    await fireStore.collection(CollectionName.facilities).where('isEnable', isEqualTo: true).get().then((value) async {
      for (var element in value.docs) {
        ParkingFacilitiesModel facilitiesModel = ParkingFacilitiesModel.fromJson(element.data());
        facilitiesModelList.add(facilitiesModel);
      }
    });
    return facilitiesModelList;
  }

  static Future<UserModel?> getWatchMen(String uuid) async {
    UserModel? userModel;
    await fireStore.collection(CollectionName.users).doc(uuid).get().then((value) {
      if (value.exists) {
        userModel = UserModel.fromJson(value.data()!);
      }
    }).catchError((error) {
      log("Failed to update user: $error");
      userModel = null;
    });
    return userModel;
  }

  static Future<List<ParkingModel>?> getMyParkingListOwner() async {
    List<ParkingModel> parkingList = [];
    await fireStore.collection(CollectionName.parking).where("userId", isEqualTo: getCurrentUid()).get()
        .then((value) async {
      for (var element in value.docs) {
        ParkingModel facilitiesModel = ParkingModel.fromJson(element.data());
        parkingList.add(facilitiesModel);

      }
    });
    return parkingList;
  }

  static Future<List<UserModel>?> getWatchmenList() async {
    List<UserModel> watchmenList = [];
    await fireStore.collection(CollectionName.users).where("ownerId", isEqualTo: getCurrentUid()).get().then((value) async {
      for (var element in value.docs) {
        UserModel facilitiesModel = UserModel.fromJson(element.data());
        watchmenList.add(facilitiesModel);
      }
    });
    return watchmenList;
  }

  static Future<bool> updateWatchmen(UserModel watchModel) async {
    bool isUpdate = false;
    await fireStore.collection(CollectionName.users).doc(watchModel.id).set(watchModel.toJson()).whenComplete(() {
      isUpdate = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isUpdate = false;
    });
    return isUpdate;
  }

  static Future<bool?> deleteParking(dynamic parkingId) async {
    bool? isDelete;
    try {
      await fireStore.collection(CollectionName.parking).doc(parkingId).delete().then((value) {
        isDelete = true;
      },);

    } catch (e, s) {
      log('deleteParking exception $e $s');
      return false;
    }
    return isDelete;
  }

  static Future<bool> parkingAssignCheck(String parkingID, String watchmanId) async {
    bool isAssign = false;
    await fireStore.collection(CollectionName.users).where("parkingId", isEqualTo: parkingID).get().then((value) async {
      if (value.docs.isNotEmpty) {
        if (value.docs.first.id != watchmanId) {
          isAssign = true;
        } else {
          isAssign = false;
        }
      } else {
        isAssign = false;
      }
    });
    return isAssign;
  }

  static Future<ParkingModel?> getParking(String uuid) async {
    ParkingModel? parkingModel;
    await fireStore.collection(CollectionName.parking).doc(uuid).get().then((value) {
      if (value.exists) {
        parkingModel = ParkingModel.fromJson(value.data()!);
      }
    }).catchError((error) {
      log("Failed to update user: $error");
      parkingModel = null;
    });
    return parkingModel;
  }

  static Future<SubscriptionPlanModel?> getSubscriptionPlanById({required String planId}) async {
    SubscriptionPlanModel? subscriptionPlanModel = SubscriptionPlanModel();
    if (planId.isNotEmpty) {
      await fireStore.collection(CollectionName.subscriptionPlans).doc(planId).get().then((value) async {
        if (value.exists) {
          subscriptionPlanModel = SubscriptionPlanModel.fromJson(value.data() as Map<String, dynamic>);
        }
      });
    }
    return subscriptionPlanModel;
  }

  static Future<List<SubscriptionPlanModel>> getAllSubscriptionPlans() async {
    List<SubscriptionPlanModel> subscriptionPlanModels = [];
    await fireStore.collection(CollectionName.subscriptionPlans).where('isEnable', isEqualTo: true).orderBy('place', descending: false).get().then((value) async {
      if (value.docs.isNotEmpty) {
        for (var element in value.docs) {
          SubscriptionPlanModel subscriptionPlanModel = SubscriptionPlanModel.fromJson(element.data());
          if (subscriptionPlanModel.id != Constant.commissionSubscriptionID) {
            subscriptionPlanModels.add(subscriptionPlanModel);
          }
        }
      }
    });
    return subscriptionPlanModels;
  }

  static Future<bool?> setSubscriptionTransaction(SubscriptionHistoryModel subscriptionPlan) async {
    bool isAdded = false;
    await fireStore.collection(CollectionName.subscriptionHistory).doc(subscriptionPlan.id).set(subscriptionPlan.toJson()).then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }


  static Future<List<SubscriptionHistoryModel>> getSubscriptionHistory() async {
    List<SubscriptionHistoryModel> subscriptionHistoryList = [];
    await fireStore.collection(CollectionName.subscriptionHistory).where('user_id', isEqualTo: getCurrentUid()).orderBy('createdAt', descending: true).get().then((value) async {
      if (value.docs.isNotEmpty) {
        for (var element in value.docs) {
          SubscriptionHistoryModel subscriptionHistoryModel = SubscriptionHistoryModel.fromJson(element.data());
          subscriptionHistoryList.add(subscriptionHistoryModel);
        }
      }
    });
    return subscriptionHistoryList;
  }



 static bool checkDateContains(List<dynamic> localDates, Timestamp timestampUtc) {
    for (String dateStr in localDates) {
      // Compare UTC times
      if (Utils.stringToTimeStamp(dateStr) == timestampUtc) {
        return true; // match found
      }
    }
    return false; // no match
  }

}
