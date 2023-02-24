import 'package:okoto/configs/constants.dart';

import '../../model/common/new_document_data_model.dart';
import '../../model/notification/notification_model.dart';
import '../../model/order/order_model.dart';
import '../../utils/my_print.dart';
import '../../utils/my_utils.dart';
import 'notification_provider.dart';
import 'notification_repository.dart';

class NotificationController {
  late NotificationProvider _notificationProvider;
  late NotificationRepository _notificationRepository;

  NotificationController({required NotificationProvider? notificationProvider, NotificationRepository? repository}){
    _notificationProvider = notificationProvider ?? NotificationProvider();
    _notificationRepository = repository ?? NotificationRepository();
  }

  NotificationProvider get notificationProvider => _notificationProvider;
  NotificationRepository get notificationRepository => _notificationRepository;

  Future<bool> createSubscriptionOrderNotification({required OrderModel orderModel, required String userId}) async {
    String tag = MyUtils.getUniqueIdFromUuid();
    MyPrint.printOnConsole("NotificationController().createSubscriptionOrderNotification() called for orderModel:$orderModel", tag: tag);

    bool isCreated = false;

    try {
      NewDocumentDataModel newDocumentDataModel = await MyUtils.getNewDocIdAndTimeStamp(isGetTimeStamp: true);

      NotificationModel notificationModel = NotificationModel(
        id: newDocumentDataModel.docId,
        title: "New Subscription Order Placed",
        description: "",
        type: NotificationType.subscriptionOrder,
        orderData: orderModel,
        target: NotificationTarget.admin,
        createdBy: userId,
        createdTime: newDocumentDataModel.timestamp,
      );

      bool isCreated = await notificationRepository.createNotification(notificationModel: notificationModel);

      MyPrint.printOnConsole("isCreated:$isCreated", tag: tag);
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in Creating Notification in NotificationController().createSubscriptionOrderNotification():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
    }

    return isCreated;
  }
}