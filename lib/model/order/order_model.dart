import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:okoto/configs/constants.dart';
import 'package:okoto/model/product/product_model.dart';
import 'package:okoto/model/subscription/subscription_model.dart';

import '../../utils/my_utils.dart';
import '../../utils/parsing_helper.dart';

/// types of Order are defined in [OrderType]

class OrderModel {
  String id = "", type = "", paymentMode = "", paymentId = "", paymentStatus = "", userId = "";
  double amount = 0;
  Timestamp? createdTime;
  SubscriptionModel? subscriptionOrderDataModel;
  ProductModel? productOrderDataModel;

  OrderModel({
    required this.id,
    this.type = "",
    this.paymentMode = "",
    this.paymentId = "",
    this.paymentStatus = "",
    this.userId = "",
    this.amount = 0,
    this.createdTime,
    this.subscriptionOrderDataModel,
    this.productOrderDataModel,
  });

  OrderModel.fromMap(Map<String, dynamic> map) {
    _initializeFromMap(map);
  }

  void updateFromMap(Map<String, dynamic> map) {
    _initializeFromMap(map);
  }

  void _initializeFromMap(Map<String, dynamic> map) {
    id = ParsingHelper.parseStringMethod(map['id']);
    type = ParsingHelper.parseStringMethod(map['type']);
    paymentMode = ParsingHelper.parseStringMethod(map['paymentMode']);
    paymentId = ParsingHelper.parseStringMethod(map['paymentId']);
    paymentStatus = ParsingHelper.parseStringMethod(map['paymentStatus']);
    userId = ParsingHelper.parseStringMethod(map['userId']);
    amount = ParsingHelper.parseDoubleMethod(map['amount']);
    createdTime = ParsingHelper.parseTimestampMethod(map['createdTime']);

    Map<String, dynamic> subscriptionOrderDataModelMap = ParsingHelper.parseMapMethod(map['subscriptionOrderDataModel']).map<String, dynamic>((key, value) {
      return MapEntry(ParsingHelper.parseStringMethod(key), value);
    });
    if(subscriptionOrderDataModelMap.isNotEmpty) {
      subscriptionOrderDataModel = SubscriptionModel.fromMap(subscriptionOrderDataModelMap);
    }

    Map<String, dynamic> productOrderDataModelMap = ParsingHelper.parseMapMethod(map['productOrderDataModel']).map<String, dynamic>((key, value) {
      return MapEntry(ParsingHelper.parseStringMethod(key), value);
    });
    if(productOrderDataModelMap.isNotEmpty) {
      productOrderDataModel = ProductModel.fromMap(productOrderDataModelMap);
    }
  }

  Map<String, dynamic> toMap({bool toJson = false}) {
    return {
      "id" : id,
      "type" : type,
      "paymentMode" : paymentMode,
      "paymentId" : paymentId,
      "paymentStatus" : paymentStatus,
      "userId" : userId,
      "amount" : amount,
      "createdTime" : toJson ? createdTime?.millisecondsSinceEpoch : createdTime,
      "subscriptionOrderDataModel" : subscriptionOrderDataModel?.orderModelToMap(toJson: toJson),
      "productOrderDataModel" : productOrderDataModel?.orderModelToMap(toJson: toJson),
    };
  }

  @override
  String toString({bool toJson = true}) {
    return toJson ? MyUtils.encodeJson(toMap(toJson: true)) : "OrderModel(${toMap(toJson: false)})";
  }
}