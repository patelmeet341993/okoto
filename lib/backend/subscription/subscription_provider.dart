import 'package:okoto/backend/common/common_provider.dart';
import 'package:okoto/model/subscription/subscription_model.dart';

class SubscriptionProvider extends CommonProvider {
  //region All Subscriptions
  //region All Subscription Models List
  final List<SubscriptionModel> _allSubscriptions = <SubscriptionModel>[];

  List<SubscriptionModel> getAllSubscriptions({bool isNewInstance = true}) {
    if(isNewInstance) {
      return _allSubscriptions.map((e) => SubscriptionModel.fromMap(e.toMap())).toList();
    }
    else {
      return _allSubscriptions;
    }
  }

  int get allSubscriptionsLength => _allSubscriptions.length;

  void setAllSubscriptions({required List<SubscriptionModel> subscriptions, bool isClear = true, bool isNotify = true}) {
    if(isClear) {
      _allSubscriptions.clear();
    }
    _allSubscriptions.addAll(subscriptions);
    notify(isNotify: isNotify);
  }
  //endregion

  //region Is All Subscription Models Loading
  bool _isAllSubscriptionsLoading = false;

  bool get isAllSubscriptionsLoading => _isAllSubscriptionsLoading;

  void setIsAllSubscriptionsLoading({required bool value, bool isNotify = true}) {
    _isAllSubscriptionsLoading = value;
    notify(isNotify: isNotify);
  }
  //endregion
  //endregion

  void resetAllData() {
    setAllSubscriptions(subscriptions: [], isNotify: false);
    setIsAllSubscriptionsLoading(value: false, isNotify: false);
  }
}