import 'package:okoto/backend/common/common_provider.dart';

import '../../model/notification/notification_model.dart';

class NotificationProvider extends CommonProvider {
  NotificationProvider() {
    _initializeFields();
  }

  void _initializeFields() {
    notificationToken = CommonProviderPrimitiveParameter<String?>(
      value: null,
      notify: notify,
    );
  }

  late final CommonProviderPrimitiveParameter<String?> notificationToken;

  void resetAllData() {}

  List<NotificationModel> _notificationModelList = <NotificationModel>[];

  void setNotificationModelList(List<NotificationModel> notificationModelList, {bool isNotify = true}) {
    if (notificationModelList.isNotEmpty) {
      _notificationModelList = notificationModelList;
    }
    if (isNotify) {
      notifyListeners();
    }
  }

  List<NotificationModel> get getNotificationModelList => _notificationModelList;

  //region to show the list month wise
  final Map<String, String> _notificationsMapWithMonthYear = {};

  void setOrdersMapWithMonthYear(Map<String, String> notificationsMapWithMonthYear, {bool isClear = true, bool isNotify = true}) {
    if (isClear) _notificationsMapWithMonthYear.clear();
    _notificationsMapWithMonthYear.addAll(notificationsMapWithMonthYear);
    if (isNotify) {
      notifyListeners();
    }
  }

  Map<String, String> get notificationsMapWithMonthYear => _notificationsMapWithMonthYear;
//endregion
}
