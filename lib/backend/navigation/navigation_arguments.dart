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
