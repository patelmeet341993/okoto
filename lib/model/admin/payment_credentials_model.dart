import 'package:okoto/utils/my_utils.dart';

import '../../utils/parsing_helper.dart';

class PaymentCredentialsModel {
  String key = "", secret = "";
  String liveKey = "", liveSecret = "";
  String testKey = "", testSecret = "";

  PaymentCredentialsModel({
    this.key = "",
    this.secret = "",
    this.liveKey = "",
    this.liveSecret = "",
    this.testKey = "",
    this.testSecret = "",
  });

  PaymentCredentialsModel.fromMap(Map<String, dynamic> map) {
    key = ParsingHelper.parseStringMethod(map['key']);
    secret = ParsingHelper.parseStringMethod(map['secret']);
    liveKey = ParsingHelper.parseStringMethod(map['liveKey']);
    liveSecret = ParsingHelper.parseStringMethod(map['liveSecret']);
    testKey = ParsingHelper.parseStringMethod(map['testKey']);
    testSecret = ParsingHelper.parseStringMethod(map['testSecret']);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "key" : key,
      "secret" : secret,
      "liveKey" : liveKey,
      "liveSecret" : liveSecret,
      "testKey" : testKey,
      "testSecret" : testSecret,
    };
  }

  @override
  String toString() {
    return MyUtils.encodeJson(toMap());
  }
}