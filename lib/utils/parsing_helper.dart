// For Parsing Dynamic Values To Specific Type

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'my_print.dart';

class ParsingHelper {
  static String parseStringMethod(dynamic value, {String defaultValue = ""}) {
    return value?.toString() ?? defaultValue;
  }

  static int parseIntMethod(dynamic value, {int defaultValue = 0}) {
    if(value == null) {
      return defaultValue;
    }
    else if(value is int) {
      return value;
    }
    else if(value is double) {
      return value.toInt();
    }
    else if(value is String) {
      return int.tryParse(value) ?? defaultValue;
    }
    else {
      return defaultValue;
    }
  }

  static double parseDoubleMethod(dynamic value, {double defaultValue = 0}) {
    if(value == null) {
      return defaultValue;
    }
    else if(value is int) {
      return value.toDouble();
    }
    else if(value is double) {
      return value;
    }
    else if(value is String) {
      return double.tryParse(value) ?? defaultValue;
    }
    else {
      return defaultValue;
    }
  }

  static bool parseBoolMethod(dynamic value, {bool defaultValue = false}) {
    if(value == null) {
      return defaultValue;
    }
    else if(value is bool) {
      return value;
    }
    else if(value is String) {
      if(value.toLowerCase() == "true") {
        return true;
      }
      else if(value.toLowerCase() == "false") {
        return false;
      }
      else {
        return defaultValue;
      }
    }
    else {
      return defaultValue;
    }
  }

  static List<T2> parseListMethod<T1, T2>(dynamic value, {List<T2>? defaultValue}) {
    defaultValue ??= <T2>[];

    if(value == null) {
      return defaultValue;
    }
    else if(value is List<T1>) {
      try {
        List<T2> newList = List.castFrom<T1, T2>(value);
        return newList;
      }
      catch(e) {
        return defaultValue;
      }
    }
    else if(value is List<dynamic>) {
      try {
        List<T2> newList = List.castFrom<dynamic, T2>(value);
        return newList;
      }
      catch(e) {
        return defaultValue;
      }
    }
    else {
      return defaultValue;
    }
  }

  static Map<K2, V2> parseMapMethod<K1, V1, K2, V2>(dynamic value, {Map<K2, V2>? defaultValue}) {
    defaultValue ??= <K2, V2>{};

    if(value == null) {
      return defaultValue;
    }
    else if(value is Map) {
      try {
        Map<K1, V1> newMap = Map.castFrom<dynamic, dynamic, K1, V1>(value);
        Map<K2, V2> newMap2 = Map.castFrom<K1, V1, K2, V2>(newMap);
        return newMap2;
      }
      catch(e) {
        return defaultValue;
      }
    }
    else {
      return defaultValue;
    }
  }

  static Timestamp? parseTimestampMethod(dynamic value, {DateTime? defaultValue, String dateFormat = ""}) {
    DateTime? dateTime = parseDateTimeMethod(value, defaultValue: defaultValue, dateFormat: dateFormat);

    if(dateTime != null) {
      return Timestamp.fromDate(dateTime);
    }
    else {
      return null;
    }
  }

  static DateTime? parseDateTimeMethod(dynamic value, {DateTime? defaultValue, String dateFormat = ""}) {
    if(value is DateTime) {
      return value;
    }
    else if(value is Timestamp) {
      return value.toDate();
    }
    else if(value is String) {
      DateTime? dateTime;
      MyPrint.printOnConsole("DateTime Value:$value");
      if(dateFormat.isNotEmpty) {
        try {
          dateTime = DateFormat(dateFormat).parse(value);
        }
        catch(e, s) {
          MyPrint.printOnConsole("Error in Converting from String to DateTime with Format '$dateFormat':$e");
          MyPrint.printOnConsole(s);
        }
      }

      if(dateTime == null) {
        int? intValue = int.tryParse(value);
        if(intValue != null) {
          try {
            dateTime = DateTime.fromMillisecondsSinceEpoch(intValue);
          }
          catch(e, s) {
            MyPrint.printOnConsole("Error in Converting from String(int) to DateTime:$e");
            MyPrint.printOnConsole(s);
          }
        }
      }

      dateTime ??= DateTime.tryParse(value);

      return dateTime ?? defaultValue;
    }
    else if(value is int) {
      DateTime? dateTime;

      try {
        dateTime = DateTime.fromMillisecondsSinceEpoch(value);
      }
      catch(e, s) {
        MyPrint.printOnConsole("Error in Converting from int to DateTime:$e");
        MyPrint.printOnConsole(s);
      }

      return dateTime ?? defaultValue;
    }
    else {
      return defaultValue;
    }
  }
}