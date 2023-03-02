import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:okoto/model/order/order_model.dart';

import '../../configs/constants.dart';
import '../../utils/my_utils.dart';
import '../../utils/parsing_helper.dart';

/// type will contain value from [NotificationType]
/// target will contain value from [NotificationTarget] or any other id

class NotificationModel {
  String id = "", title = "", description = "", type = "", target = "", createdBy = "",image = "";
  bool isOpened = false;
  Timestamp? createdTime;
  OrderModel? orderData;

  NotificationModel({
    this.id = "",
    this.title = "",
    this.description = "",
    this.image = "",
    this.type = "",
    this.target = "",
    this.createdBy = "",
    this.isOpened = false,
    this.createdTime,
    this.orderData,
  });

  NotificationModel.fromMap(Map<String, dynamic> map) {
    id = ParsingHelper.parseStringMethod(map['id']);
    title = ParsingHelper.parseStringMethod(map['title']);
    image = ParsingHelper.parseStringMethod(map['image']);
    description = ParsingHelper.parseStringMethod(map['description']);
    type = ParsingHelper.parseStringMethod(map['type']);
    target = ParsingHelper.parseStringMethod(map['target']);
    createdBy = ParsingHelper.parseStringMethod(map['createdBy']);
    isOpened = ParsingHelper.parseBoolMethod(map['isOpened']);
    createdTime = ParsingHelper.parseTimestampMethod(map['createdTime']);

    if(type == NotificationType.subscriptionOrder) {
      Map<String, dynamic> orderMap = ParsingHelper.parseMapMethod<dynamic, dynamic, String, dynamic>(map['data']);
      if(orderMap.isNotEmpty) {
        orderData = OrderModel.fromMap(orderMap);
      }
    }
  }

  Map<String, dynamic> toMap({bool toJson = true}) {
    return {
      "id" : id,
      "title" : title,
      "description" : description,
      "type" : type,
      "image" : image,
      "target" : target,
      "createdBy" : createdBy,
      "isOpened" : isOpened,
      "createdTime" : toJson ? createdTime?.millisecondsSinceEpoch : createdTime,
      "orderData" : orderData?.toMap(toJson: toJson),
    };
  }

  @override
  String toString({bool toJson = true}) {
    return toJson ? MyUtils.encodeJson(toMap(toJson: true)) : "NotificationModel(${toMap(toJson: false)})";
  }
}