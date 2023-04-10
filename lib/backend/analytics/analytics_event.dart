

class AnalyticsEvent{

  static const String demo_call_dummy = "demo_call_dummy";


  //region login/signup events
  static const String signup_started = "signup_started";
  static const String phone_number_added_success = "phone_number_added_success";
  static const String signup_success = "signup_success";
  static const String login_success = "login_success";
  static const String user_gender = "user_gender";
  static const String user_age = "user_age";
  static const String user_logout = "user_logout";
  static const String otp_sending_success = "otp_sending_success";
  static const String otp_filing_success = "otp_filing_success";
  static const String resend_otp = "resend_otp";
  //endregion

  //region HomeScreen events
  static const String homescreen_screen_click = "homescreen_screen_click";
  static const String homescreen_playgame_slider = "homescreen_playgame_slider";
  //endregion

  //region OtherScreens events
  static const String user_any_screen_view = "user_any_screen_view";
  static const String devicescreen_add_device = "devicescreen_add_device";
  static const String devicescreen_select_device = "devicescreen_select_device";
  static const String notificationscreen_notification_click = "notificationscreen_notification_click";
  //endregion

  //region ProfileScreen events
  static const String profile_screen_update_profile = "profile_screen_update_profile";
  static const String profile_screen_about_the_company = "profile_screen_about_the_company";
  static const String profile_screen_privacy_policy = "profile_screen_privacy_policy";
  //endregion

  //region General events
  static const String user_area_detail = "user_area_detail";
  static const String user_gameplay_detail = "user_gameplay_detail";
  static const String user_most_played_game = "user_most_played_game";
  static const String user_played_gametime = "user_played_gametime";
  //endregion

  //region Subscription events
  static const String subscriptionscreen_plan_view = "subscriptionscreen_plan_view";
  static const String subscriptionscreen_plan_expiry_alert = "subscriptionscreen_plan_expiry_alert";
  static const String subscriptionscreen_payment_started = "subscriptionscreen_payment_started";
  static const String subscriptionscreen_payment_success = "subscriptionscreen_payment_success";
  static const String subscriptionplan_purchased_success = "subscriptionplan_purchased_success";
  static const String subscriptionscreen_plan_purchased_success_gamelist = "subscriptionscreen_plan_purchased_success_gamelist";
  static const String subscriptionscreen_plan_added_games = "subscriptionscreen_plan_added_games";
  //endregion

}

class AnalyticsParameterValue{
  static String  notification_screen ="notification_screen";
  static String  device_list_screen ="device_list_screen";
  static String  subscription_plans_list_screen ="subscription_plans_list_screen";
  static String  subscription_plan_details_screen ="subscription_plan_details_screen";
  static String  payment_history_screen ="payment_history_screen";
  static String  games_list_screen ="games_list_screen";
  static String  my_games_screen ="my_games_screen";
  static String  recommended_plans_screen ="recommended_plans_screen";
  static String  profile_screen ="profile_screen";
  static String  profile_update_screen ="profile_update_screen";
  static String  check_out_screen ="check_out_screen";
  static String  signup_screen ="signup_screen";
  static String  otp_screen ="otp_screen";
  static String  mobile_number_login_screen ="mobile_number_login_screen";
}

class AnalyticsParameters {
  static String  event_value ="event_value";
}