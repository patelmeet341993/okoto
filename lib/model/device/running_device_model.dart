import 'package:cloud_firestore/cloud_firestore.dart';

import '../../utils/my_utils.dart';
import '../../utils/parsing_helper.dart';

class RunningDeviceModel {
  String id = "", note = "";
  bool statusOn = false;
  Timestamp? startedTime, lastUpdatedTime;

  RunningDeviceModel({
    required this.id,
    this.note = "",
    this.statusOn = false,
    this.startedTime,
    this.lastUpdatedTime,
  });

  RunningDeviceModel.fromMap(Map<String, dynamic> map) {
    _initializeFromMap(map);
  }

  void updateFromMap(Map<String, dynamic> map) {
    _initializeFromMap(map);
  }

  void _initializeFromMap(Map<String, dynamic> map) {
    id = ParsingHelper.parseStringMethod(map['id']);
    note = ParsingHelper.parseStringMethod(map['note']);
    statusOn = ParsingHelper.parseBoolMethod(map['isMultiUserAccessEnabled'], defaultValue: false);
    startedTime = ParsingHelper.parseTimestampMethod(map['startedTime']);
    lastUpdatedTime = ParsingHelper.parseTimestampMethod(map['lastUpdatedTime']);
  }

  Map<String, dynamic> toMap({bool toJson = false}) {
    return {
      "id" : id,
      "note" : note,
      "statusOn" : statusOn,
      "startedTime" : startedTime?.millisecondsSinceEpoch.toString(),
      "lastUpdatedTime" : lastUpdatedTime?.millisecondsSinceEpoch.toString(),
    };
  }

  @override
  String toString({bool toJson = true}) {
    return toJson ? MyUtils.encodeJson(toMap(toJson: true)) : "RunningDeviceModel(${toMap(toJson: false)})";
  }
}