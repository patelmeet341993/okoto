import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:okoto/model/notification/notification_model.dart';

import '../../configs/constants.dart';
import '../../configs/typedefs.dart';
import '../../utils/my_print.dart';
import '../../utils/my_utils.dart';

class NotificationRepository {
  Future<bool> createNotification({required NotificationModel notificationModel}) async {
    String tag = MyUtils.getUniqueIdFromUuid();
    MyPrint.printOnConsole("NotificationRepository().createNotification() called for notificationModel:$notificationModel", tag: tag);

    bool isCreated = false;

    try {
      await FirebaseNodes.notificationDocumentReference(notificationId: notificationModel.id).set(notificationModel.toMap());
      isCreated = true;
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in Creating Notification in NotificationRepository().createNotification():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
    }

    MyPrint.printOnConsole("isCreated:$isCreated", tag: tag);

    return isCreated;
  }

  Future<List<NotificationModel>> getNotificationsList() async {
    String tag = MyUtils.getUniqueIdFromUuid();
    List<NotificationModel> notificationModelList = <NotificationModel>[];
    MyPrint.printOnConsole("NotificationRepository().createNotification() called for notificationModel:", tag: tag);

    bool isCreated = false;

    try{
      MyFirestoreQuerySnapshot querySnapshot = await FirebaseNodes.notificationsCollectionReference.get();
      if(querySnapshot.docs.isNotEmpty){
        for (MyFirestoreQueryDocumentSnapshot queryDocumentSnapshot in querySnapshot.docs) {
          if(queryDocumentSnapshot.data().isNotEmpty) {
            notificationModelList.add(NotificationModel.fromMap(queryDocumentSnapshot.data()));
          }
          else {
            MyPrint.printOnConsole("Game Document Empty for Document Id:${queryDocumentSnapshot.id}");
          }
        }
      }
    }
    catch(e,s){
      MyPrint.printOnConsole('Error in getAllGameModelsList in GameRepository $e');
      MyPrint.printOnConsole(s);
    }

    MyPrint.printOnConsole("isCreated:$isCreated", tag: tag);

    return notificationModelList;
  }

  Future<bool> updateNotificationValue({required String id,required String key, required dynamic value}) async {
    String tag = MyUtils.getUniqueIdFromUuid();
    MyPrint.printOnConsole("NotificationRepository().createNotification() called for notificationModel:$id", tag: tag);

    bool isCreated = false;

    try {
      await FirebaseNodes.notificationDocumentReference(notificationId: id).update({key:value});
      isCreated = true;
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in Creating Notification in NotificationRepository().createNotification():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
    }

    MyPrint.printOnConsole("isCreated:$isCreated", tag: tag);

    return isCreated;
  }

}