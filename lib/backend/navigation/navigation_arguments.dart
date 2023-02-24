import '../../model/subscription/subscription_model.dart';

class NavigationArguments {
  const NavigationArguments();
}

class OtpScreenNavigationArguments extends NavigationArguments {
  final String mobileNumber;

  const OtpScreenNavigationArguments({
    required this.mobileNumber,
  });
}

class TermsAndConditionsScreenNavigationArguments extends NavigationArguments {
  final String termsAndConditionsUrl;

  const TermsAndConditionsScreenNavigationArguments({
    required this.termsAndConditionsUrl,
  });
}

class AboutAppScreenNavigationArguments extends NavigationArguments {
  final String aboutDescription, contact, whatsapp;

  const AboutAppScreenNavigationArguments({
    required this.aboutDescription,
    required this.contact,
    required this.whatsapp,
  });
}

class SubscriptionCheckoutScreenNavigationArguments extends NavigationArguments {
  final String subscriptionId;
  final SubscriptionModel? subscriptionModel;

  const SubscriptionCheckoutScreenNavigationArguments({
    required this.subscriptionId,
    this.subscriptionModel,
  });
}
