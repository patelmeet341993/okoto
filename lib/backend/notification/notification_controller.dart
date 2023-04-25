import 'package:firebase_messaging/firebase_messaging.dart';
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

  NotificationController({required NotificationProvider? notificationProvider, NotificationRepository? repository}) {
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
    } catch (e, s) {
      MyPrint.printOnConsole("Error in Creating Notification in NotificationController().createSubscriptionOrderNotification():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
    }

    return isCreated;
  }

  Future<String?> getToken({bool isRefresh = false}) async {
    NotificationProvider provider = notificationProvider;

    String? notificationToken = provider.notificationToken.get();

    if (isRefresh) {
      await FirebaseMessaging.instance.deleteToken();

      provider.notificationToken.set(value: null, isNotify: false);
    }

    try {
      notificationToken ??= await FirebaseMessaging.instance.getToken();
    } catch (e, s) {
      MyPrint.printOnConsole("Error getting token: $e");
      MyPrint.printOnConsole(s);
    }
    MyPrint.printOnConsole("Messaging Token:$notificationToken");

    provider.notificationToken.set(value: notificationToken, isNotify: false);

    return notificationToken;
  }

  Future<bool> getNotificationList({required String userId}) async {
    bool isFetched = false;
    List<NotificationModel> notificationList = <NotificationModel>[];
    try {
      notificationList = await notificationRepository.getNotificationsList(userId: userId);
      notificationProvider.setNotificationModelList(notificationList);
      Map<String, String> notificationsMapWithMonthYear = getMapOfMonthYearFromList(notificationList);
      notificationProvider.setOrdersMapWithMonthYear(notificationsMapWithMonthYear, isClear: true, isNotify: true);
    } catch (e, s) {
      MyPrint.printOnConsole("Error in notificationController.getNotificationList: $e");
      MyPrint.printOnConsole(s);
    }
    return isFetched;
  }

  Map<String, String> getMapOfMonthYearFromList(List<NotificationModel> notificationModel) {
    Map<String, String> notificationsMapWithMonthYear = {};
    for (NotificationModel item in notificationModel) {
      if (item.createdTime != null) {
        String key = "${item.createdTime!.toDate().month}${item.createdTime!.toDate().year}";
        if (!notificationsMapWithMonthYear.containsKey(key)) {
          notificationsMapWithMonthYear[key] = item.id;
        }
      }
    }
    return notificationsMapWithMonthYear;
  }

  Future<bool> updateNotificationIsNotificationOpen({required NotificationModel model, required String loggedInUserId, required bool value}) async {
    bool isUpdated = false;

    try {
      isUpdated = await notificationRepository.updateNotificationValue(id: model.id, key: "isOpened", value: value);
      // notificationProvider.
      getNotificationList(userId: loggedInUserId);
    } catch (e, s) {
      MyPrint.printOnConsole("Error in updateNotificationIsNotificationOpen $e");
      MyPrint.printOnConsole(s);
    }
    return isUpdated;
  }
}
