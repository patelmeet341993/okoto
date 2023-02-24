import 'package:okoto/model/notification/notification_model.dart';

import '../../configs/constants.dart';
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
}