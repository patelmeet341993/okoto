import 'package:flutter/material.dart';
import 'package:okoto/configs/typedefs.dart';

import '../../configs/constants.dart';
import '../../model/admin/payment_credentials_model.dart';
import '../../model/admin/property_model.dart';
import '../../utils/my_print.dart';
import '../../utils/my_utils.dart';
import '../navigation/navigation.dart';
import 'data_provider.dart';

class DataController {
  final DataProvider dataProvider;

  const DataController({required this.dataProvider});

  Future<PropertyModel> getPropertyData({bool isRefresh = true}) async {
    String tag = MyUtils.getUniqueIdFromUuid();

    MyPrint.printOnConsole("DataController().getPropertyData() called", tag: tag);

    // PropertyModel propertyModel = dataProvider.propertyModel;
    if(isRefresh) {
      /*await FirebaseNodes.adminPropertyDocumentReference.set({
        "aboutDescription" : "",
        "contactNumber" : "+919725202571",
        "notificationsEnabled" : true,
        "privacyAndPolicyUrl" : "https://www.freeprivacypolicy.com/live/b0dcdff2-8e8c-43f1-bbda-6e394a553596",
        "termsAndConditionsUrl" : "https://www.freeprivacypolicy.com/live/b0dcdff2-8e8c-43f1-bbda-6e394a553596",
        "whatsApp" : "+919725202571",
      });*/

      MyFirestoreDocumentSnapshot propertySnapshot = await FirebaseNodes.adminPropertyDocumentReference.get();
      MyPrint.printOnConsole("propertySnapshot.exists:${propertySnapshot.exists}", tag: tag);
      MyPrint.printOnConsole("propertySnapshot.data():${propertySnapshot.data()}", tag: tag);

      if(propertySnapshot.data()?.isNotEmpty ?? false) {
        dataProvider.setPropertyModel(model: PropertyModel.fromMap(propertySnapshot.data()!));
        MyPrint.printOnConsole("propertyModel after setting in provider:${dataProvider.propertyModel}", tag: tag);
      }
    }

    MyPrint.printOnConsole("Final propertyModel:${dataProvider.propertyModel}", tag: tag);

    return dataProvider.propertyModel;
  }

  static Future<PaymentCredentialsModel?> getPaymentCredentialsData() async {
    String tag = MyUtils.getUniqueIdFromUuid();
    MyPrint.printOnConsole("DataController.getPaymentCredentialsData() called", tag: tag);

    PaymentCredentialsModel? paymentCredentialsModel;

    try {
      MyFirestoreDocumentSnapshot snapshot = await FirebaseNodes.adminPaymentDocumentReference.get();
      MyPrint.printOnConsole("Payment Snapshot Data:'${snapshot.data()}'", tag: tag);

      if(snapshot.data()?.isNotEmpty ?? false) {
        paymentCredentialsModel = PaymentCredentialsModel.fromMap(snapshot.data()!);
      }
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in Getting PaymentCredentials Data in AdminController.getPaymentCredentialsData():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
    }

    MyPrint.printOnConsole("Final paymentCredentialsModel:$paymentCredentialsModel");

    return paymentCredentialsModel;
  }

  void showTermsAndConditionBottomSheet({required BuildContext context}){
    String termsAndConditionsUrl = dataProvider.propertyModel.termsAndConditionsUrl;

    NavigationController.navigateToTermsAndConditionsScreen(
      navigationOperationParameters: NavigationOperationParameters(
        context: context,
        navigationType: NavigationType.pushNamed,
      ),
      arguments: TermsAndConditionsScreenNavigationArguments(termsAndConditionsUrl: termsAndConditionsUrl),
    );
  }

  void goToAboutAppScreen({required BuildContext context}) {
    NavigationController.navigateToAboutAppScreen(
      navigationOperationParameters: NavigationOperationParameters(
        context: context,
        navigationType: NavigationType.pushNamed,
      ),
      arguments: AboutAppScreenNavigationArguments(
        aboutDescription: dataProvider.propertyModel.aboutDescription,
        contact: dataProvider.propertyModel.contactNumber,
        whatsapp: dataProvider.propertyModel.whatsApp,
      ),
    );
  }

  Future<void> callAdmin() async {
    String mobileNumber = dataProvider.propertyModel.contactNumber;

    MyUtils.launchCallMobileNumber(mobileNumber: mobileNumber);
  }

  Future<void> contactUs() async {
    String mobileNumber = dataProvider.propertyModel.contactNumber;

    await MyUtils.launchWhatsAppChat(mobileNumber: mobileNumber, message: "Hello, I want to contact you");
  }
}