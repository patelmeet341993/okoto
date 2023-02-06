import 'package:cloud_firestore/cloud_firestore.dart';

import '../../utils/my_utils.dart';
import '../../utils/parsing_helper.dart';

class ProductModel {
  String id = "", name = "", thumbnailImage = "";
  List<String> productImages = <String>[];
  bool enabled = true;
  Timestamp? createdTime;

  ProductModel({
    required this.id,
    this.name = "",
    this.thumbnailImage = "",
    List<String>? productImages,
    this.enabled = true,
    this.createdTime,
  }) {
    this.productImages = productImages ?? <String>[];
  }

  ProductModel.fromMap(Map<String, dynamic> map) {
    _initializeFromMap(map);
  }

  void updateFromMap(Map<String, dynamic> map) {
    _initializeFromMap(map);
  }

  void _initializeFromMap(Map<String, dynamic> map) {
    id = ParsingHelper.parseStringMethod(map['id']);
    name = ParsingHelper.parseStringMethod(map['name']);
    thumbnailImage = ParsingHelper.parseStringMethod(map['thumbnailImage']);
    productImages = ParsingHelper.parseListMethod<dynamic, String>(map['productImages']);
    enabled = ParsingHelper.parseBoolMethod(map['enabled'], defaultValue: true);
    createdTime = ParsingHelper.parseTimestampMethod(map['createdTime']);
  }

  Map<String, dynamic> orderModelToMap({bool toJson = false}) {
    return {
      "id" : id,
      "name" : name,
      "thumbnailImage" : thumbnailImage,
      "productImages" : productImages,
      "enabled" : enabled,
      "createdTime" : toJson ? createdTime?.millisecondsSinceEpoch : createdTime,
    };
  }

  Map<String, dynamic> toMap({bool toJson = false}) {
    return {
      "id" : id,
      "name" : name,
      "thumbnailImage" : thumbnailImage,
      "productImages" : productImages,
      "enabled" : enabled,
      "createdTime" : toJson ? createdTime?.millisecondsSinceEpoch : createdTime,
    };
  }

  @override
  String toString({bool toJson = true}) {
    return toJson ? MyUtils.encodeJson(toMap(toJson: true)) : "ProductModel(${toMap(toJson: false)})";
  }
}