import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:okoto/backend/order/order_controller.dart';
import 'package:okoto/backend/subscription/subscription_provider.dart';
import 'package:okoto/backend/subscription/subscription_repository.dart';
import 'package:okoto/backend/user/user_controller.dart';
import 'package:okoto/backend/user/user_provider.dart';
import 'package:okoto/model/subscription/subscription_model.dart';
import 'package:okoto/utils/my_toast.dart';

import '../../utils/my_print.dart';
import '../../utils/my_utils.dart';

class SubscriptionController {
  late SubscriptionProvider _subscriptionProvider;
  late SubscriptionRepository _subscriptionRepository;

  SubscriptionController({required SubscriptionProvider? subscriptionProvider, SubscriptionRepository? subscriptionRepository}) {
    _subscriptionProvider = subscriptionProvider ?? SubscriptionProvider();
    _subscriptionRepository = subscriptionRepository ?? SubscriptionRepository();
  }

  SubscriptionProvider get subscriptionProvider => _subscriptionProvider;

  Future<void> getAllSubscriptionsList({bool isRefresh = true, bool isNotify = true}) async {
    String tag = MyUtils.getUniqueIdFromUuid();
    MyPrint.printOnConsole("SubscriptionController().getAllSubscriptionsList() called with, isRefresh:$isRefresh, isNotify:$isNotify", tag: tag);

    SubscriptionProvider provider = subscriptionProvider;
    SubscriptionRepository repository = _subscriptionRepository;

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

  Future<bool> buySubscription({required BuildContext context, required SubscriptionModel subscriptionModel, required String userId,
    required UserProvider userProvider}) async {
    bool isBuySuccessful = false;

    if(userId.isEmpty) {
      return isBuySuccessful;
    }

    bool isPaymentSuccess = false;
    String paymentId = "";

    double amount = subscriptionModel.price;

    //region TODO: Comment Below Code. This is only for testing
    paymentId = paymentId;
    isPaymentSuccess = true;
    await Future.delayed(const Duration(seconds: 3));
    if(context.mounted) MyToast.showSuccess(context: context, msg: "Payment Success");
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

    if(isPaymentSuccess == true) {
      bool isOrderCreated = await OrderController(orderProvider: null).createOrderForSubscription(
        subscriptionModel: subscriptionModel,
        paymentId: paymentId,
        paymentMode: "Razorpay",
        paymentStatus: "Completed",
        amount: amount,
      );

      if(!isOrderCreated) {
        if(context.mounted) {
          MyToast.showError(context: context, msg: "Couldn't Place Order for Subscription");
        }
        return isBuySuccessful;
      }

      bool isSubscriptionActivated = await _subscriptionRepository.activateSubscriptionForUser(subscriptionModel: subscriptionModel, userId: userId);

      if(isSubscriptionActivated) {
        isBuySuccessful = true;

        await UserController(userProvider: userProvider).getUserDataAndStoreInProvider(userId: userId);

        if(context.mounted) {
          MyToast.showSuccess(context: context, msg: "Subscription Activated Successfully");
        }
      }
      else {
        if(context.mounted) {
          MyToast.showError(context: context, msg: "Couldn't Place Order for Subscription");
        }
      }
    }

    return isBuySuccessful;
  }

  Future<void> checkSubscriptionActive() async {

  }



  Future<bool> addDummySubscription() async {
    String tag = MyUtils.getUniqueIdFromUuid();
    MyPrint.printOnConsole("SubscriptionController().addDummySubscription() called", tag: tag);

    bool isSubscriptionAdded = false;

    isSubscriptionAdded = await _subscriptionRepository.createSubscriptionInFirestoreFromModel(subscriptionModel: SubscriptionModel(
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