import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:okoto/utils/parsing_helper.dart';

import '../../utils/my_utils.dart';
import '../subscription/subscription_model.dart';

class SubscriptionOrderDataModel {
  SubscriptionModel? subscriptionModel;
  List<String> selectedGamesList = <String>[];
  Timestamp? activatedDate, expiryDate;

  SubscriptionOrderDataModel({
    required this.subscriptionModel,
    List<String>? selectedGamesList,
    this.activatedDate,
    this.expiryDate,
  }) {
    this.selectedGamesList = selectedGamesList ?? <String>[];
  }

  SubscriptionOrderDataModel.fromMap(Map<String, dynamic> map) {
    _initializeFromMap(map);
  }

  void updateFromMap(Map<String, dynamic> map) {
    _initializeFromMap(map);
  }

  void _initializeFromMap(Map<String, dynamic> map) {
    Map<String, dynamic> subscriptionModelMap = ParsingHelper.parseMapMethod<dynamic, dynamic, String, dynamic>(map['subscriptionModel']);
    if(subscriptionModelMap.isNotEmpty) {
      subscriptionModel = SubscriptionModel.fromMap(subscriptionModelMap);
    }

    selectedGamesList = ParsingHelper.parseListMethod<dynamic, String>(map['selectedGamesList']);

    activatedDate = ParsingHelper.parseTimestampMethod(map['activatedDate']);
    expiryDate = ParsingHelper.parseTimestampMethod(map['expiryDate']);
  }

  Map<String, dynamic> toMap({bool toJson = false}) {
    return {
      "subscriptionModel" : subscriptionModel?.orderModelToMap(toJson: toJson),
      "selectedGamesList" : selectedGamesList,
      "activatedDate" : toJson ? activatedDate?.toDate().toIso8601String() : activatedDate,
      "expiryDate" : toJson ? expiryDate?.toDate().toIso8601String() : expiryDate,
    };
  }

  @override
  String toString({bool toJson = true}) {
    return toJson ? MyUtils.encodeJson(toMap(toJson: true)) : "SubscriptionOrderDataModel(${toMap(toJson: false)})";
  }
}