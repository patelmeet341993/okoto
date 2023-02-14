import 'package:flutter/material.dart';
import 'package:okoto/backend/subscription/subscription_controller.dart';
import 'package:okoto/backend/user/user_provider.dart';
import 'package:okoto/model/subscription/subscription_model.dart';
import 'package:okoto/utils/my_toast.dart';
import 'package:okoto/view/common/components/common_loader.dart';
import 'package:okoto/view/common/components/modal_progress_hud.dart';
import 'package:provider/provider.dart';

import '../../../backend/subscription/subscription_provider.dart';
import '../components/subscription_card.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  late ThemeData themeData;
  bool isLoading = false;

  late SubscriptionProvider subscriptionProvider;
  late SubscriptionController subscriptionController;

  late UserProvider userProvider;

  Future<void> getSubscriptions({bool isRefresh = true, bool isNotify = true,}) async {
    await subscriptionController.getAllSubscriptionsList(isRefresh: isRefresh, isNotify: isNotify);
  }

  Future<void> buySubscription({required SubscriptionModel subscriptionModel}) async {
    String userId = userProvider.getUserId();

    if(userId.isEmpty) {
      MyToast.showError(context: context, msg: "User Data Not Available");
      return;
    }

    setState(() {
      isLoading = true;
    });

    bool isSubscriptionBuySuccessful = await subscriptionController.buySubscription(
      context: context,
      userId: userId,
      subscriptionModel: subscriptionModel,
      userProvider: userProvider,
    );

    if(context.mounted) {
      setState(() {
        isLoading = false;
      });

      if(isSubscriptionBuySuccessful) {
        // MyToast.showSuccess(context: context, msg: "New Subscription Activated");
      }
      /*else {
        MyToast.showError(context: context, msg: "Couldn't Buy Subscription");
      }*/
    }
  }

  @override
  void initState() {
    super.initState();
    subscriptionProvider = context.read<SubscriptionProvider>();
    subscriptionController = SubscriptionController(subscriptionProvider: subscriptionProvider);

    userProvider = context.read<UserProvider>();

    getSubscriptions(isRefresh: false, isNotify: false);
  }

  @override
  Widget build(BuildContext context) {
    themeData = Theme.of(context);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SubscriptionProvider>.value(value: subscriptionProvider),
        ChangeNotifierProvider<UserProvider>.value(value: userProvider),
      ],
      child: Consumer2<SubscriptionProvider, UserProvider>(
        builder: (BuildContext context, SubscriptionProvider subscriptionProvider, UserProvider userProvider, Widget? child) {
          return ModalProgressHUD(
            inAsyncCall: isLoading,
            progressIndicator: const CommonLoader(),
            child: Scaffold(
              appBar: AppBar(
                title: const Text(
                  "Subscriptions",
                  style: TextStyle(
                    // fontSize: 16,
                  ),
                ),
              ),
              body: SafeArea(
                child: getMainBody(
                  subscriptionProvider: subscriptionProvider,
                  userProvider: userProvider,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget getMainBody({required SubscriptionProvider subscriptionProvider, required UserProvider userProvider}) {
    SubscriptionModel? activeSubscriptionModel = userProvider.getUserModel()?.userSubscriptionModel?.mySubscription;

    return Column(
      children: [
        // getActiveSubscriptionWidget(activeSubscriptionModel: activeSubscriptionModel),
        Expanded(
          child: getSubscriptionsListView(
            subscriptionProvider: subscriptionProvider,
            activeSubscriptionModel: activeSubscriptionModel,
          ),
        ),
      ],
    );
  }

  Widget getActiveSubscriptionWidget({required SubscriptionModel? activeSubscriptionModel,}) {
    if(activeSubscriptionModel == null) {
      return const SizedBox();
    }

    return Container(
      decoration: const BoxDecoration(

      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Active Subscription"),
          const SizedBox(height: 10,),
          SubscriptionCard(subscriptionModel: activeSubscriptionModel, showBuyButton: false),
        ],
      ),
    );
  }

  Widget getSubscriptionsListView({required SubscriptionProvider subscriptionProvider, required SubscriptionModel? activeSubscriptionModel,}) {
    if(subscriptionProvider.isAllSubscriptionsLoading) {
      return const Center(
        child: CommonLoader(isCenter: true),
      );
    }

    if(subscriptionProvider.allSubscriptionsLength <= 0) {
      return RefreshIndicator(
        onRefresh: () async {
          await getSubscriptions(isRefresh: true, isNotify: true);
        },
        child: ListView(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.4,),
            const Center(child: Text("No Subscription")),
          ],
        ),
      );
    }

    List<SubscriptionModel> subscriptions = subscriptionProvider.getAllSubscriptions(isNewInstance: false);

    return RefreshIndicator(
      onRefresh: () async {
        await getSubscriptions(isRefresh: true, isNotify: true);
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        itemCount: subscriptions.length,
        itemBuilder: (BuildContext context, int index) {
          SubscriptionModel subscriptionModel = subscriptions[index];

          bool isActiveSubscription = activeSubscriptionModel?.id == subscriptionModel.id;

          // return getSubscriptionCard(subscriptionModel: subscriptionModel);
          return SubscriptionCard(
            subscriptionModel: subscriptionModel,
            showBuyButton: !isActiveSubscription,
            isActiveSubscription: isActiveSubscription,
            buySubscriptionCallback: buySubscription,
          );
        },
      ),
    );
  }
}
