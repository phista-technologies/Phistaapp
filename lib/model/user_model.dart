import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:phista/model/admin_commission.dart';
import 'package:phista/model/subscription_plan_model.dart';

class UserModel {
  String? fullName;
  String? id;
  String? stripeCustomerId;
  String? email;
  String? loginType;
  String? profilePic;
  String? dateOfBirth;
  String? fcmToken;
  String? countryCode;
  String? phoneNumber;
  String? walletAmount;
  bool? isActive;
  Timestamp? createdAt;
  String? role;
  String? lastLoginType;
  String? ownerId;
  String? parkingId;
  String? salary;
  String? password;
  String? subscriptionPlanId;
  String? subscriptionTotalOrders;
  Timestamp? subscriptionExpiryDate;
  SubscriptionPlanModel? subscriptionPlan;
  AdminCommission? adminCommission;


  UserModel({
      this.fullName,
      this.id,
      this.stripeCustomerId,
      this.isActive,
      this.dateOfBirth,
      this.email,
      this.loginType,
      this.profilePic,
      this.fcmToken,
      this.countryCode,
      this.phoneNumber,
      this.walletAmount,
      this.createdAt,
      this.role,
      this.lastLoginType,
      this.ownerId,
      this.parkingId,
      this.salary,
      this.password,
      this.subscriptionPlanId,
      this.subscriptionTotalOrders,
      this.subscriptionExpiryDate,
      this.subscriptionPlan,
      this.adminCommission
      });



        UserModel.fromJson(Map<String, dynamic> json) {
    fullName = json['fullName'];
    id = json['id'];
    stripeCustomerId = json['stripeCustomerId'];
    email = json['email'];
    loginType = json['loginType'];
    profilePic = json['profilePic'];
    fcmToken = json['fcmToken'];
    countryCode = json['countryCode'];
    phoneNumber = json['phoneNumber'];
    walletAmount = json['walletAmount'] ?? "0";
    createdAt = json['createdAt'];
    dateOfBirth = json['dateOfBirth'] ?? '';
    isActive = json['isActive'];
    role = json['role'];
    lastLoginType = json['lastLoginType'];
    ownerId = json['ownerId'];
    parkingId = json['parkingId'];
    salary = json['salary'] ?? "0";
    password = json['password'];
    subscriptionPlanId = json['subscriptionPlanId'];
    subscriptionTotalOrders = json['subscriptionTotalOrders'];
    subscriptionExpiryDate = json['subscriptionExpiryDate'];
    adminCommission = json['adminCommission'] != null
        ? AdminCommission.fromJson(json['adminCommission'])
        : null;
    subscriptionPlan = json['subscription_plan'] != null
        ? SubscriptionPlanModel.fromJson(json['subscription_plan'])
        : null;
  }

        Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['fullName'] = fullName;
    data['id'] = id;
    data['stripeCustomerId'] = stripeCustomerId;
    data['email'] = email;
    data['loginType'] = loginType;
    data['profilePic'] = profilePic;
    data['fcmToken'] = fcmToken;
    data['countryCode'] = countryCode;
    data['phoneNumber'] = phoneNumber;
    data['walletAmount'] = walletAmount;
    data['createdAt'] = createdAt;
    data['dateOfBirth'] = dateOfBirth;
    data['isActive'] = isActive;
    data['role'] = role;
    data['lastLoginType'] = lastLoginType;
    data['ownerId'] = ownerId;
    data['parkingId'] = parkingId;
    data['salary'] = salary;
    data['password'] = password;
    data['subscriptionPlanId'] = subscriptionPlanId;
    data['subscriptionTotalOrders'] = subscriptionTotalOrders;
    data['subscriptionExpiryDate'] = subscriptionExpiryDate;
    if (subscriptionPlan != null) {
      data['subscription_plan'] = subscriptionPlan?.toJson();
    }
    if (adminCommission != null) {
      data['adminCommission'] = adminCommission!.toJson();
    }
    return data;
  }


}
