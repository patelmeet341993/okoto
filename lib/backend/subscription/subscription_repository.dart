import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:okoto/model/subscription/subscription_model.dart';

import '../../configs/constants.dart';
import '../../configs/typedefs.dart';
import '../../model/common/new_document_data_model.dart';
import '../../utils/my_print.dart';
import '../../utils/my_utils.dart';
import '../user/user_repository.dart';

class SubscriptionRepository {
  Future<List<SubscriptionModel>> getAllSubscriptionsList() async {
    String tag = MyUtils.getUniqueIdFromUuid();
    MyPrint.printOnConsole('SubscriptionRepository().getAllSubscriptionsList() called', tag: tag);

    List<SubscriptionModel> subscriptions = <SubscriptionModel>[];

    try {
      MyFirestoreQuerySnapshot querySnapshot = await FirebaseNodes.subscriptionsCollectionReference
          .where("enabled", isEqualTo: true)
          .get();
      MyPrint.printOnConsole("Subscriptions querySnapshot length:${querySnapshot.size}", tag: tag);

      if(querySnapshot.docs.isNotEmpty) {
        for (MyFirestoreQueryDocumentSnapshot queryDocumentSnapshot in querySnapshot.docs) {
          if(queryDocumentSnapshot.data().isNotEmpty) {
            subscriptions.add(SubscriptionModel.fromMap(queryDocumentSnapshot.data()));
          }
          else {
            MyPrint.printOnConsole("Subscriptions Document Empty for Document Id:${queryDocumentSnapshot.id}", tag: tag);
          }
        }
      }
      MyPrint.printOnConsole("Final Subscriptions length:${subscriptions.length}", tag: tag);
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in SubscriptionRepository().getAllSubscriptionsList():$e", tag: tag);
      MyPrint.printOnConsole(s);
    }

    return subscriptions;
  }

  Future<bool> activateSubscriptionForUser({required SubscriptionModel subscriptionModel, required String userId, bool isAdvanced = false}) async {
    String tag = MyUtils.getUniqueIdFromUuid();
    MyPrint.printOnConsole("SubscriptionRepository().activateSubscriptionForUser() called with subscription id:${subscriptionModel.id}, userId:$userId, isAdvanced:$isAdvanced", tag: tag);

    bool isActivated = false;

    if(subscriptionModel.id.isEmpty || userId.isEmpty) {
      return isActivated;
    }

    NewDocumentDataModel newDocumentDataModel = await MyUtils.getNewDocIdAndTimeStamp(isGetTimeStamp: true);
    MyPrint.printOnConsole("Timestamp:${newDocumentDataModel.timestamp.toDate().toIso8601String()}", tag: tag);

    Map<String, dynamic> data = <String, dynamic>{};

    if(isAdvanced) {
      data.addAll({
        "userSubscriptionModel.advancedSubscription" : subscriptionModel.userSubscriptionModelToMap(),
      });
    }
    else {
      data.addAll({
        "userSubscriptionModel.mySubscription" : subscriptionModel.userSubscriptionModelToMap(),
        "userSubscriptionModel.isActive" : true,
        "userSubscriptionModel.activatedDate" : newDocumentDataModel.timestamp,
        "userSubscriptionModel.expiryDate" : Timestamp.fromDate(newDocumentDataModel.timestamp.toDate().add(Duration(days: subscriptionModel.validityInDays))),
      });
    }

    isActivated = await UserRepository().updateUserDataFromMap(userId: userId, data: data);
    MyPrint.printOnConsole("isActivated:$isActivated", tag: tag);

    return isActivated;
  }

  Future<bool> createSubscriptionInFirestoreFromModel({required SubscriptionModel subscriptionModel}) async {
    String tag = MyUtils.getUniqueIdFromUuid();
    MyPrint.printOnConsole("SubscriptionRepository().createSubscriptionInFirestoreFromModel() called with subscriptionModel:'$subscriptionModel'", tag: tag);

    bool isSubscriptionCreated = false;

    try {
      await FirebaseNodes.subscriptionDocumentReference(subscriptionId: subscriptionModel.id).set(subscriptionModel.toMap());
      isSubscriptionCreated = true;
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in SubscriptionRepository().createSubscriptionInFirestoreFromModel():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
    }

    MyPrint.printOnConsole("isSubscriptionCreated:$isSubscriptionCreated", tag: tag);

    return isSubscriptionCreated;
  }
}