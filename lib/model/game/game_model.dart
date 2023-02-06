import 'package:cloud_firestore/cloud_firestore.dart';

import '../../utils/my_utils.dart';
import '../../utils/parsing_helper.dart';

class GameModel {
  String id = "", name = "", thumbnailImage = "";
  List<String> gameImages = <String>[];
  bool enabled = true;
  Timestamp? createdTime;

  GameModel({
    required this.id,
    this.name = "",
    this.thumbnailImage = "",
    List<String>? gameImages,
    this.enabled = true,
    this.createdTime,
  }) {
    this.gameImages = gameImages ?? <String>[];
  }

  GameModel.fromMap(Map<String, dynamic> map) {
    _initializeFromMap(map);
  }

  void updateFromMap(Map<String, dynamic> map) {
    _initializeFromMap(map);
  }

  void _initializeFromMap(Map<String, dynamic> map) {
    id = ParsingHelper.parseStringMethod(map['id']);
    name = ParsingHelper.parseStringMethod(map['name']);
    thumbnailImage = ParsingHelper.parseStringMethod(map['thumbnailImage']);
    gameImages = ParsingHelper.parseListMethod<dynamic, String>(map['gameImages']);
    enabled = ParsingHelper.parseBoolMethod(map['enabled'], defaultValue: true);
    createdTime = ParsingHelper.parseTimestampMethod(map['createdTime']);
  }

  Map<String, dynamic> toMap({bool toJson = false}) {
    return {
      "id" : id,
      "name" : name,
      "thumbnailImage" : thumbnailImage,
      "gameImages" : gameImages,
      "enabled" : enabled,
      "createdTime" : toJson ? createdTime?.millisecondsSinceEpoch : createdTime,
    };
  }

  @override
  String toString({bool toJson = true}) {
    return toJson ? MyUtils.encodeJson(toMap(toJson: true)) : "GameModel(${toMap(toJson: false)})";
  }
}