import '../../utils/my_utils.dart';
import '../../utils/parsing_helper.dart';

class PropertyModel {
  String aboutDescription = "", contactNumber = "", whatsApp = "", termsAndConditionsUrl = "", privacyAndPolicyUrl = "";
  bool notificationsEnabled = false;

  PropertyModel({
    this.aboutDescription = "",
    this.contactNumber = "",
    this.whatsApp = "",
    this.termsAndConditionsUrl = "",
    this.privacyAndPolicyUrl = "",
    this.notificationsEnabled = false,
  });

  PropertyModel.fromMap(Map<String, dynamic> map) {
    aboutDescription = ParsingHelper.parseStringMethod(map['aboutDescription']);
    contactNumber = ParsingHelper.parseStringMethod(map['contactNumber']);
    whatsApp = ParsingHelper.parseStringMethod(map['whatsApp']);
    termsAndConditionsUrl = ParsingHelper.parseStringMethod(map['termsAndConditionsUrl']);
    privacyAndPolicyUrl = ParsingHelper.parseStringMethod(map['privacyAndPolicyUrl']);
    notificationsEnabled = ParsingHelper.parseBoolMethod(map['notificationsEnabled']);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "aboutDescription": aboutDescription,
      "contactNumber": contactNumber,
      "whatsApp": whatsApp,
      "termsAndConditionsUrl": termsAndConditionsUrl,
      "privacyAndPolicyUrl": privacyAndPolicyUrl,
      "notificationsEnabled": notificationsEnabled,
    };
  }

  @override
  String toString() {
    return MyUtils.encodeJson(toMap());
  }
}