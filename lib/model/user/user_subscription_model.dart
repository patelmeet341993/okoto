import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:okoto/model/subscription/subscription_model.dart';
import 'package:okoto/utils/parsing_helper.dart';

import '../../utils/my_utils.dart';

class UserSubscriptionModel {
  SubscriptionModel? mySubscription, advancedSubscription;
  bool isActive = false;
  Timestamp? activatedDate, expiryDate;
  List<String> selectedGames = <String>[];

  UserSubscriptionModel({
    this.mySubscription,
    this.advancedSubscription,
    this.isActive = false,
    this.activatedDate,
    this.expiryDate,
    List<String>? selectedGames,
  }) {
    this.selectedGames = selectedGames ?? <String>[];
  }

  UserSubscriptionModel.fromMap(Map<String, dynamic> map) {
    _initializeFroMap(map);
  }

  void updateFromMap(Map<String, dynamic> map) {
    _initializeFroMap(map);
  }

  void _initializeFroMap(Map<String, dynamic> map) {
    Map<String, dynamic> mySubscriptionMap = ParsingHelper.parseMapMethod(map['mySubscription']).map<String, dynamic>((key, value) {
      return MapEntry(ParsingHelper.parseStringMethod(key), value);
    });
    if(mySubscriptionMap.isNotEmpty) {
      mySubscription = SubscriptionModel.fromMap(mySubscriptionMap);
    }

    Map<String, dynamic> advancedSubscriptionMap = ParsingHelper.parseMapMethod(map['advancedSubscription']).map<String, dynamic>((key, value) {
      return MapEntry(ParsingHelper.parseStringMethod(key), value);
    });
    if(advancedSubscriptionMap.isNotEmpty) {
      advancedSubscription = SubscriptionModel.fromMap(advancedSubscriptionMap);
    }

    isActive = ParsingHelper.parseBoolMethod(map['isActive'], defaultValue: false);
    activatedDate = ParsingHelper.parseTimestampMethod(map['activatedDate']);
    expiryDate = ParsingHelper.parseTimestampMethod(map['expiryDate']);

    selectedGames = ParsingHelper.parseListMethod<dynamic, String>(map['selectedGames']);
  }

  Map<String, dynamic> toMap({bool toJson = false}) {
    return <String, dynamic>{
      "mySubscription" : mySubscription?.userSubscriptionModelToMap(toJson: toJson),
      "advancedSubscription" : advancedSubscription?.userSubscriptionModelToMap(toJson: toJson),
      "isActive" : isActive,
      "activatedDate" : toJson ? activatedDate?.toDate().toIso8601String() : activatedDate,
      "expiryDate" : toJson ? expiryDate?.toDate().toIso8601String() : expiryDate,
      "selectedGames" : selectedGames,
    };
  }

  @override
  String toString({bool toJson = true}) {
    return toJson ? MyUtils.encodeJson(toMap(toJson: true)) : "UserSubscriptionModel(${toMap(toJson: false)})";
  }
}