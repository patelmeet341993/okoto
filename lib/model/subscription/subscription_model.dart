import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:okoto/utils/my_utils.dart';
import 'package:okoto/utils/parsing_helper.dart';

class SubscriptionModel {
  String id = "", name = "", image = "";
  double price = 0, discountedPrice = -1;
  List<String> gamesList = <String>[];
  bool enabled = true;
  int validityInDays = 28;
  Timestamp? createdTime;

  SubscriptionModel({
    required this.id,
    this.name = "",
    this.image = "",
    this.price = 0,
    this.discountedPrice = -1,
    List<String>? gamesList,
    this.enabled = true,
    this.validityInDays = 28,
    this.createdTime,
  }) {
    this.gamesList = gamesList ?? <String>[];
  }

  SubscriptionModel.fromMap(Map<String, dynamic> map) {
    _initializeFromMap(map);
  }

  void updateFromMap(Map<String, dynamic> map) {
    _initializeFromMap(map);
  }

  void _initializeFromMap(Map<String, dynamic> map) {
    id = ParsingHelper.parseStringMethod(map['id']);
    name = ParsingHelper.parseStringMethod(map['name']);
    image = ParsingHelper.parseStringMethod(map['image']);
    price = ParsingHelper.parseDoubleMethod(map['price']);
    discountedPrice = ParsingHelper.parseDoubleMethod(map['discountedPrice'], defaultValue: -1);
    gamesList = ParsingHelper.parseListMethod<dynamic, String>(map['gamesList']);
    enabled = ParsingHelper.parseBoolMethod(map['enabled'], defaultValue: true);
    validityInDays = ParsingHelper.parseIntMethod(map['validityInDays'], defaultValue: 28);
    createdTime = ParsingHelper.parseTimestampMethod(map['createdTime']);
  }

  Map<String, dynamic> orderModelToMap({bool toJson = false}) {
    return {
      "id" : id,
      "name" : name,
      "image" : image,
      "price" : price,
      "discountedPrice" : discountedPrice,
      "gamesList" : gamesList,
      "enabled" : enabled,
      "validityInDays" : validityInDays,
      "createdTime" : toJson ? createdTime?.millisecondsSinceEpoch : createdTime,
    };
  }

  Map<String, dynamic> userSubscriptionModelToMap({bool toJson = false}) {
    return {
      "id" : id,
      "name" : name,
      "image" : image,
      "price" : price,
      "discountedPrice" : discountedPrice,
      "gamesList" : gamesList,
      "enabled" : enabled,
      "validityInDays" : validityInDays,
      "createdTime" : toJson ? createdTime?.millisecondsSinceEpoch : createdTime,
    };
  }

  Map<String, dynamic> toMap({bool toJson = false}) {
    return {
      "id" : id,
      "name" : name,
      "image" : image,
      "price" : price,
      "discountedPrice" : discountedPrice,
      "gamesList" : gamesList,
      "enabled" : enabled,
      "validityInDays" : validityInDays,
      "createdTime" : toJson ? createdTime?.millisecondsSinceEpoch : createdTime,
    };
  }

  @override
  String toString({bool toJson = true}) {
    return toJson ? MyUtils.encodeJson(toMap(toJson: true)) : "SubscriptionModel(${toMap(toJson: false)})";
  }
}