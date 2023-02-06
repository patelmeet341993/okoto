import 'package:cloud_firestore/cloud_firestore.dart';

import '../../utils/my_utils.dart';
import '../../utils/parsing_helper.dart';
import 'user_subscription_model.dart';

class UserModel {
  String id = "", name = "", userName = "", gender = "", mobileNumber = "";
  Timestamp? createdDate, dateOfBirth;
  bool adminEnabled = true;
  UserSubscriptionModel? userSubscriptionModel;
  List<String> deviceIds = <String>[];

  UserModel({
    this.id = "",
    this.name = "",
    this.userName = "",
    this.gender = "",
    this.mobileNumber = "",
    this.createdDate,
    this.dateOfBirth,
    this.adminEnabled = true,
    List<String>? deviceIds,
  }) {
    this.deviceIds = deviceIds ?? <String>[];
  }

  UserModel.fromMap(Map<String, dynamic> map) {
    _initializeFroMap(map);
  }

  void updateFromMap(Map<String, dynamic> map) {
    _initializeFroMap(map);
  }

  void _initializeFroMap(Map<String, dynamic> map) {
    id = ParsingHelper.parseStringMethod(map['id']);
    name = ParsingHelper.parseStringMethod(map['name']);
    userName = ParsingHelper.parseStringMethod(map['userName']);
    gender = ParsingHelper.parseStringMethod(map['gender']);
    mobileNumber = ParsingHelper.parseStringMethod(map['mobileNumber']);
    createdDate = ParsingHelper.parseTimestampMethod(map['createdDate']);
    dateOfBirth = ParsingHelper.parseTimestampMethod(map['dateOfBirth']);
    adminEnabled = ParsingHelper.parseBoolMethod(map['adminEnabled']);

    Map<String, dynamic> userSubscriptionModelMap = ParsingHelper.parseMapMethod(map['userSubscriptionModel']).map<String, dynamic>((key, value) {
      return MapEntry(ParsingHelper.parseStringMethod(key), value);
    });
    if(userSubscriptionModelMap.isNotEmpty) {
      userSubscriptionModel = UserSubscriptionModel.fromMap(userSubscriptionModelMap);
    }

    List<String> deviceIdsList = ParsingHelper.parseListMethod(map['deviceIds']).map((value) {
      return ParsingHelper.parseStringMethod(value);
    }).toSet().toList();
    deviceIdsList.removeWhere((element) => element.isEmpty);
    if(deviceIdsList.isNotEmpty) {
      deviceIds = deviceIdsList;
    }
  }

  bool isHavingNecessaryInformation() {
    bool nameValid = name.isNotEmpty;
    bool userNameValid = userName.isNotEmpty;
    bool dobValid = dateOfBirth != null;
    bool genderValid = gender.isNotEmpty;

    return nameValid && userNameValid && dobValid && genderValid;
  }

  Map<String, dynamic> toMap({bool toJson = false}) {
    return <String, dynamic>{
      "id" : id,
      "name" : name,
      "userName" : userName,
      "gender" : gender,
      "mobileNumber" : mobileNumber,
      "createdDate" : toJson ? createdDate?.toDate().toIso8601String() : createdDate,
      "dateOfBirth" : toJson ? dateOfBirth?.toDate().toIso8601String() : dateOfBirth,
      "adminEnabled" : adminEnabled,
      "deviceIds" : deviceIds,
    };
  }

  @override
  String toString({bool toJson = true}) {
    return toJson ? MyUtils.encodeJson(toMap(toJson: true)) : "UserModel(${toMap(toJson: false)})";
  }
}
