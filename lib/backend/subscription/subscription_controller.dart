import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:okoto/backend/order/order_controller.dart';
import 'package:okoto/backend/subscription/subscription_provider.dart';
import 'package:okoto/backend/subscription/subscription_repository.dart';
import 'package:okoto/backend/user/user_controller.dart';
import 'package:okoto/backend/user/user_provider.dart';
import 'package:okoto/model/order/subscription_order_data_model.dart';
import 'package:okoto/model/subscription/subscription_model.dart';
import 'package:okoto/utils/my_toast.dart';
import 'package:okoto/view/common/components/common_popup.dart';

import '../../model/common/new_document_data_model.dart';
import '../../utils/my_print.dart';
import '../../utils/my_utils.dart';
import '../analytics/analytics_controller.dart';
import '../analytics/analytics_event.dart';

class SubscriptionController {
  late SubscriptionProvider _subscriptionProvider;
  late SubscriptionRepository _subscriptionRepository;

  SubscriptionController({required SubscriptionProvider? subscriptionProvider, SubscriptionRepository? subscriptionRepository}) {
    _subscriptionProvider = subscriptionProvider ?? SubscriptionProvider();
    _subscriptionRepository = subscriptionRepository ?? SubscriptionRepository();
  }

  SubscriptionProvider get subscriptionProvider => _subscriptionProvider;
  SubscriptionRepository get subscriptionRepository => _subscriptionRepository;

  Future<void> getAllSubscriptionsList({bool isRefresh = true, bool isNotify = true}) async {
    String tag = MyUtils.getUniqueIdFromUuid();
    MyPrint.printOnConsole("SubscriptionController().getAllSubscriptionsList() called with, isRefresh:$isRefresh, isNotify:$isNotify", tag: tag);

    SubscriptionProvider provider = subscriptionProvider;
    SubscriptionRepository repository = subscriptionRepository;

    MyPrint.printOnConsole("allSubscriptionsLength in SubscriptionProvider:${provider.allSubscriptionsLength}", tag: tag);
    if(isRefresh || provider.allSubscriptionsLength <= 0) {
      provider.setIsAllSubscriptionsLoading(value: true, isNotify: isNotify);

      List<SubscriptionModel> allSubscriptions = await repository.getAllSubscriptionsList();
      MyPrint.printOnConsole("AllSubscription Models length:${allSubscriptions.length}", tag: tag);

      allSubscriptions.removeWhere((SubscriptionModel subscriptionModel) {
        if(!subscriptionModel.enabled) {
          return true;
        }
        else {
          return false;
        }
      });

      provider.setAllSubscriptions(subscriptions: allSubscriptions, isClear: true, isNotify: false);
      provider.setIsAllSubscriptionsLoading(value: false, isNotify: true);
    }

    MyPrint.printOnConsole("SubscriptionController().getAllSubscriptionsList() Finished", tag: tag);
  }

  Future<bool> buySubscription({
    required BuildContext context,
    required SubscriptionModel subscriptionModel,
    required List<String> selectedGamesList,
    required String userId,
    required UserProvider userProvider,
  }) async {
    String tag = MyUtils.getUniqueIdFromUuid();
    MyPrint.printOnConsole("SubscriptionController().buySubscription() called with context:$context, subscriptionModel:$subscriptionModel, userId:$userId", tag: tag);

    bool isBuySuccessful = false;

    if(userId.isEmpty) {
      MyPrint.printOnConsole("Returning from buySubscription because userId is empty", tag: tag);
      return isBuySuccessful;
    }

    bool isUserHavingDevices = await UserController(userProvider: null).checkUserHavingDevices(userId: userId);
    MyPrint.printOnConsole("isUserHavingDevices:$isUserHavingDevices", tag: tag);

    if(!isUserHavingDevices) {
      MyPrint.printOnConsole("Returning from buySubscription because user is not having any device.", tag: tag);
      if(context.mounted) MyToast.showError(context: context, msg: "You don't have any devices. Please Add a device first.");
      return isBuySuccessful;
    }

    bool isPaymentSuccess = false;
    String paymentId = "";

    double amount = subscriptionModel.price;

    //region TODO: Comment Below Code. This is only for testing
    paymentId = paymentId;
    isPaymentSuccess = true;
    await Future.delayed(const Duration(seconds: 3));
    // if(context.mounted) MyToast.showSuccess(context: context, msg: "Payment Success");
    //endregion

    //region TODO: Uncomment Below Code. This is real payment code
    /*await PaymentController().createPayment(
      amount: amount,
      handleSuccess: (String paymentId, String orderId, String paymentSignature) async {
        paymentId = paymentId;
        isPaymentSuccess = true;

        MyToast.showSuccess(context: context, msg: "Payment Success");
      },
      handleCancel: (String message) {
        isPaymentSuccess = false;
        MyPrint.printOnConsole("Payment Canceled Message:$message");
        MyToast.showError(context: context, msg: "Payment Cancelled");
      },
      handleFailure: () {
        isPaymentSuccess = false;
        MyToast.showError(context: context, msg: "Payment Failed");
      },
    );*/
    //endregion

    MyPrint.printOnConsole("isPaymentSuccess:$isPaymentSuccess", tag: tag);
    MyPrint.printOnConsole("paymentId:$paymentId", tag: tag);

    NewDocumentDataModel newDocumentDataModel = await MyUtils.getNewDocIdAndTimeStamp(isGetTimeStamp: true);
    MyPrint.printOnConsole("Timestamp:${newDocumentDataModel.timestamp.toDate().toIso8601String()}", tag: tag);

    Timestamp subscriptionActivatedDate = newDocumentDataModel.timestamp;
    Timestamp subscriptionExpiryDate = Timestamp.fromDate(subscriptionActivatedDate.toDate().add(Duration(days: subscriptionModel.validityInDays)));

    if(isPaymentSuccess == true) {
      bool isOrderCreated = await OrderController(orderProvider: null).createOrderForSubscription(
        subscriptionOrderDataModel: SubscriptionOrderDataModel(
          subscriptionModel: subscriptionModel,
          selectedGamesList: selectedGamesList,
          activatedDate: subscriptionActivatedDate,
          expiryDate: Timestamp.fromDate(newDocumentDataModel.timestamp.toDate().add(Duration(days: subscriptionModel.validityInDays))),
        ),
        userId: userId,
        paymentId: paymentId,
        paymentMode: "Razorpay",
        paymentStatus: "Completed",
        amount: amount,
        createdTime: newDocumentDataModel.timestamp,
      );
      MyPrint.printOnConsole("isOrderCreated:$isOrderCreated", tag: tag);

      if(!isOrderCreated) {
        MyPrint.printOnConsole("Returning from buySubscription because Order Couldn't create in Firestore", tag: tag);
        if(context.mounted) {
          MyToast.showError(context: context, msg: "Couldn't Place Order for Subscription");
        }
        return isBuySuccessful;
      }

      bool isSubscriptionActivated = await subscriptionRepository.activateSubscriptionForUser(
        subscriptionModel: subscriptionModel,
        userId: userId,
        selectedGamesList: selectedGamesList,
        activatedDate: subscriptionActivatedDate,
        expiryDate: subscriptionExpiryDate,
      );
      MyPrint.printOnConsole("isSubscriptionActivated:$isSubscriptionActivated", tag: tag);

      if(isSubscriptionActivated) {
        isBuySuccessful = true;

        await UserController(userProvider: userProvider).getUserDataAndStoreInProvider(userId: userId);

        if(context.mounted) {
          MyToast.showSuccess(context: context, msg: "Subscription Activated Successfully");
        }

        if(!kIsWeb) {
          if(context.mounted) {
            dynamic value = await showDialog(
              context: context,
              builder: (BuildContext context) {
                return CommonPopUp(
                  text: "Do you want to add alert for Expiry of Subscription in your calender?",
                  rightText: "Yes",
                  leftText: "No",
                  rightOnTap: () {
                    AnalyticsController().fireEvent(analyticEvent: AnalyticsEvent.subscriptionscreen_plan_expiry_alert,parameters: {AnalyticsParameters.event_value:'Yes'});
                    Navigator.pop(context, true);
                  },
                  leftOnTap: () {
                    AnalyticsController().fireEvent(analyticEvent: AnalyticsEvent.subscriptionscreen_plan_expiry_alert,parameters: {AnalyticsParameters.event_value:'No'});
                    Navigator.pop(context, false);
                  },
                );
              },
            );

            if(value == true) {
              MyPrint.printOnConsole("Adding Event For Date:${subscriptionExpiryDate.toDate().toString()}");

              final Event event = Event(
                title: 'Okoto Subscription Expiry',
                description: 'Your subscription in OKOTO is Going to be expire today',
                // location: 'Event location',
                startDate: subscriptionExpiryDate.toDate(),
                endDate: subscriptionExpiryDate.toDate(),
                allDay: true,
                iosParams: const IOSParams(
                  reminder: Duration(hours: 10),
                  url: 'https://www.google.com',
                ),
                androidParams: const AndroidParams(
                  emailInvites: [],
                ),
              );
              Add2Calendar.addEvent2Cal(event);
            }
          }
        }
      }
      else {
        MyPrint.printOnConsole("Couldn't Activate Subscription for user", tag: tag);
        if(context.mounted) {
          MyToast.showError(context: context, msg: "Couldn't Activate Subscription");
        }
      }
    }

    MyPrint.printOnConsole("isBuySuccessful:$isBuySuccessful", tag: tag);

    return isBuySuccessful;
  }

  Future<void> checkSubscriptionActive() async {

  }

  Future<bool> addDummySubscription() async {
    String tag = MyUtils.getUniqueIdFromUuid();
    MyPrint.printOnConsole("SubscriptionController().addDummySubscription() called", tag: tag);

    bool isSubscriptionAdded = false;

    isSubscriptionAdded = await subscriptionRepository.createSubscriptionInFirestoreFromModel(subscriptionModel: SubscriptionModel(
      id: MyUtils.getUniqueIdFromUuid(),
      name: "Plan 3",
      createdTime: Timestamp.now(),
      discountedPrice: -1,
      price: 250,
      enabled: true,
      gamesList: [
        "qKSXQtym6CcUNTwGv0hQ"
      ],
      validityInDays: 28,
    ));

    MyPrint.printOnConsole("isSubscriptionAdded:'$isSubscriptionAdded'", tag: tag);

    return isSubscriptionAdded;
  }
}