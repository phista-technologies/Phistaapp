import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:phista/model/location_lat_lng.dart';
import 'package:phista/model/parking_facilities_model.dart';
import 'package:phista/model/positions_model.dart';
import 'package:phista/model/subscription_plan_model.dart';

import 'AvailabilityWeekModel.dart';

class ParkingModel {
  String? id;
  String? userId;
  bool? isEnable;
  LocationLatLng? location;
  Positions? position;
  String? address;
  String? name;
  String? description;
  String? image;
  String? parkingSpace;
  String? perHrPrice;
  String? dailyPrice;
  String? monthlyPrice;
  String? reviewCount;
  String? reviewSum;
  String? parkingType;
  List<ParkingFacilitiesModel>? facilities;
  List<AvailabilityWeekModel>? availabilityList;
  List<dynamic>? bookmarkedUser;
  Timestamp? createdAt;
  String? subscriptionTotalOrders;
  String? subscriptionPlanId;
  Timestamp? subscriptionExpiryDate;
  SubscriptionPlanModel? subscriptionPlan;

  ParkingModel(
      {this.id,
        this.userId,
        this.isEnable,
        this.location,
        this.position,
        this.address,
        this.name,
        this.description,
        this.image,
        this.facilities,
        this.availabilityList,
        this.bookmarkedUser,
        this.perHrPrice,
        this.dailyPrice,
        this.monthlyPrice,
        this.parkingSpace,
        this.reviewCount,
        this.reviewSum,
        this.parkingType,
        this.createdAt,
        this.subscriptionTotalOrders ,this.subscriptionPlanId,
        this.subscriptionExpiryDate,
        this.subscriptionPlan});

  ParkingModel.fromJson(Map<String, dynamic> json) {
    if (json['facilities'] != null) {
      facilities = <ParkingFacilitiesModel>[];
      json['facilities'].forEach((v) {
        facilities!.add(ParkingFacilitiesModel.fromJson(v));
      });
    }
    if (json['availabilityList'] != null) {
      availabilityList = <AvailabilityWeekModel>[];
      json['availabilityList'].forEach((v) {
        availabilityList!.add(AvailabilityWeekModel.fromJson(v));
      });
    }
    id = json['id'];
    name = json['name'] ?? '';
    description = json['description'] ?? '';
    userId = json['userId'];
    address = json['address'] ?? '';
    isEnable = json['isEnable'] ?? false;
    image = json['image'] ?? '';
    bookmarkedUser = json['bookmarkedUser'] ?? [];
    perHrPrice = json['perHrPrice'] ?? "";
    dailyPrice = json['dailyPrice'] ?? "";
    monthlyPrice = json['monthlyPrice'] ?? "";
    parkingSpace = json['parkingSpace'] ?? "";
    reviewCount = json['reviewCount'] ?? "0.0";
    reviewSum = json['reviewSum'] ?? "0.0";
    parkingType = json['parkingType'] ?? "2";
    subscriptionTotalOrders = json['subscriptionTotalOrders'] ?? "0.0";
    createdAt = json['createdAt'] ?? Timestamp.now();
    location = json['location'] != null ? LocationLatLng.fromJson(json['location']) : LocationLatLng();
    position = json['position'] != null ? Positions.fromJson(json['position']) : Positions();
    subscriptionPlanId = json['subscriptionPlanId'];
    subscriptionExpiryDate = json['subscriptionExpiryDate'];
    subscriptionPlan = json['subscription_plan'] != null ? SubscriptionPlanModel.fromJson(json['subscription_plan']) : null;

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (facilities != null) {
      data['facilities'] = facilities!.map((v) => v.toJson()).toList();
    }
    if (availabilityList != null) {
      data['availabilityList'] = availabilityList!.map((v) => v.toJson()).toList();
    }
    data['id'] = id;
    data['userId'] = userId;
    data['name'] = name;
    data['description'] = description;
    data['address'] = address;
    data['isEnable'] = isEnable;
    data['image'] = image;
    data['bookmarkedUser'] = bookmarkedUser;
    data['perHrPrice'] = perHrPrice;
    data['dailyPrice'] = dailyPrice;
    data['monthlyPrice'] = monthlyPrice;
    data['parkingSpace'] = parkingSpace;
    data['reviewCount'] = reviewCount;
    data['reviewSum'] = reviewSum;
    data['parkingType'] = parkingType;
    data['subscriptionTotalOrders'] = subscriptionTotalOrders;
    data['createdAt'] = createdAt ?? Timestamp.now();
    if (location != null) {
      data['location'] = location!.toJson();
    }
    if (position != null) {
      data['position'] = position!.toJson();
    }
    data['subscriptionPlanId'] = subscriptionPlanId;
    data['subscriptionExpiryDate'] = subscriptionExpiryDate;
    if (subscriptionPlan != null) {
      data['subscription_plan'] = subscriptionPlan?.toJson();
    }
    return data;
  }
}

// class Slot {
//   String? day;
//   List<Timeslot>? timeslot;
//
//   Slot({
//     this.day,
//     this.timeslot,
//   });
//
//   Slot.fromJson(Map<String, dynamic> json) {
//     day = json['day'];
//     if (json['timeslot'] != null) {
//       timeslot = <Timeslot>[];
//       json['timeslot'].forEach((v) {
//         timeslot!.add(Timeslot.fromJson(v));
//       });
//     }
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['day'] = day;
//     if (timeslot != null) {
//       data['timeslot'] = timeslot!.map((v) => v.toJson()).toList();
//     }
//
//     return data;
//   }
// }

// class Timeslot {
//   String? id;
//   String? from;
//   String? to;
//   String? price;
//   VehicleModel? vehicle;
//   String? duration;
//
//   Timeslot({
//     this.id,
//     this.from,
//     this.to,
//     this.price,
//     this.vehicle,
//     this.duration,
//   });
//
//   Timeslot.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     from = json['from'];
//     to = json['to'];
//     price = json['price'];
//     duration = json['duration'];
//     vehicle = json['vehicle'] != null ? VehicleModel.fromJson(json['vehicle']) : null;
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['id'] = id;
//     data['from'] = from;
//     data['to'] = to;
//     data['price'] = price;
//     data['duration'] = duration;
//     if (vehicle != null) {
//       data['vehicle'] = vehicle!.toJson();
//     }
//     return data;
//   }
// }
