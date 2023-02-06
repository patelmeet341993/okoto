import 'package:flutter/foundation.dart';

import 'app_error_model.dart';

@immutable
class DataResponseModel<T> {
  final T? data;
  final AppErrorModel? appErrorModel;

  const DataResponseModel({
    this.data,
    this.appErrorModel,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "data" : data,
      "appErrorModel" : appErrorModel,
    };
  }

  @override
  String toString() {
    return "DataResponseModel(${toMap()})";
  }
}