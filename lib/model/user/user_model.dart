import 'package:cloud_firestore/cloud_firestore.dart';

import '../../utils/parsing_helper.dart';

class UserModel {
  String id = "", name = "", userName = "", gender = "", mobileNumber = "";
  Timestamp? createdDate, dateOfBirth;

  UserModel({
    this.id = "",
    this.name = "",
    this.userName = "",
    this.gender = "",
    this.mobileNumber = "",
    this.createdDate,
    this.dateOfBirth,
  });

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
    };
  }

  @override
  String toString() {
    return "UserModel(${toMap()})";
  }
}
