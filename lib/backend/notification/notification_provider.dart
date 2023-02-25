import 'package:okoto/backend/common/common_provider.dart';

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

  void resetAllData() {

  }
}