import 'package:okoto/backend/subscription/subscription_provider.dart';
import 'package:okoto/backend/subscription/subscription_repository.dart';
import 'package:okoto/model/subscription/subscription_model.dart';

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


}