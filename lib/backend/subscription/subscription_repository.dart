import 'package:okoto/model/subscription/subscription_model.dart';

import '../../configs/constants.dart';
import '../../configs/typedefs.dart';
import '../../utils/my_print.dart';
import '../../utils/my_utils.dart';

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
}