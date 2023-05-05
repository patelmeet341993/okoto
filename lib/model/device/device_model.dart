import 'package:cloud_firestore/cloud_firestore.dart';

import '../../utils/my_utils.dart';
import '../../utils/parsing_helper.dart';

class DeviceModel {
  String id = "", productId = "", productOrderId = "";
  bool adminEnabled = true, isMultiUserAccessEnabled = false, statusOn = false;
  List<String> accessibleUsers = <String>[];
  Timestamp? createdTime, updatedTime;

  DeviceModel({
    required this.id,
    this.productId = "",
    this.productOrderId = "",
    this.adminEnabled = true,
    this.isMultiUserAccessEnabled = false,
    this.statusOn = false,
    List<String>? accessibleUsers,
    this.createdTime,
    this.updatedTime,
  }) {
    this.accessibleUsers = accessibleUsers ?? <String>[];
  }

  DeviceModel.fromMap(Map<String, dynamic> map) {
    _initializeFromMap(map);
  }

  void updateFromMap(Map<String, dynamic> map) {
    _initializeFromMap(map);
  }

  void _initializeFromMap(Map<String, dynamic> map) {
    id = ParsingHelper.parseStringMethod(map['id']);
    productId = ParsingHelper.parseStringMethod(map['productId']);
    productOrderId = ParsingHelper.parseStringMethod(map['productOrderId']);
    adminEnabled = ParsingHelper.parseBoolMethod(map['adminEnabled'], defaultValue: true);
    isMultiUserAccessEnabled = ParsingHelper.parseBoolMethod(map['isMultiUserAccessEnabled'], defaultValue: false);
    statusOn = ParsingHelper.parseBoolMethod(map['isMultiUserAccessEnabled'], defaultValue: false);
    accessibleUsers = ParsingHelper.parseListMethod<dynamic, String>(map['accessibleUsers']);
    createdTime = ParsingHelper.parseTimestampMethod(map['createdTime']);
    updatedTime = ParsingHelper.parseTimestampMethod(map['updatedTime']);
  }

  Map<String, dynamic> toMap({bool toJson = false}) {
    return {
      "id" : id,
      "productId" : productId,
      "productOrderId" : productOrderId,
      "adminEnabled" : adminEnabled,
      "isMultiUserAccessEnabled" : isMultiUserAccessEnabled,
      "statusOn" : statusOn,
      "accessibleUsers" : accessibleUsers,
      "createdTime" : toJson ? createdTime?.millisecondsSinceEpoch : createdTime,
      "updatedTime" : toJson ? updatedTime?.millisecondsSinceEpoch : updatedTime,
    };
  }

  @override
  String toString({bool toJson = true}) {
    return toJson ? MyUtils.encodeJson(toMap(toJson: true)) : "DeviceModel(${toMap(toJson: false)})";
  }
}