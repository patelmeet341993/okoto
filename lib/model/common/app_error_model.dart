import '../../configs/error_codes_and_messages.dart';

class AppErrorModel {
  String message;
  Object? exception;
  StackTrace? stackTrace;
  String code;

  AppErrorModel({
    this.message = AppErrorMessages.error,
    this.exception,
    this.stackTrace,
    this.code = AppErrorCodes.error,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "message" : message,
      "exception" : exception,
      "stackTrace" : stackTrace,
      "code" : code,
    };
  }

  @override
  String toString() {
    return "AppErrorModel(${toMap()})";
  }
}