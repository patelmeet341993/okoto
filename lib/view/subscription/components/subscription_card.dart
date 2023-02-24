import 'package:flutter/material.dart';
import 'package:okoto/model/subscription/subscription_model.dart';

import '../../common/components/common_button1.dart';

class SubscriptionCard extends StatelessWidget {
  final SubscriptionModel subscriptionModel;
  final bool showBuyButton, isActiveSubscription;
  final Future<void> Function({required SubscriptionModel subscriptionModel})? buySubscriptionCallback;

  const SubscriptionCard({
    Key? key,
    required this.subscriptionModel,
    this.showBuyButton = true,
    this.isActiveSubscription = false,
    this.buySubscriptionCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget widget = getMainBody();

    if(isActiveSubscription) {
      widget = ClipRRect(
        child: Banner(
          message: 'Active',
          location: BannerLocation.topEnd,
          color: Colors.green,
          child: getMainBody(),
        ),
      );
    }

    widget = Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: widget,
    );

    return widget;
  }

  Widget getMainBody() {
    return Card(
      child: Column(
        children: [
          Text(subscriptionModel.id),
          Text(subscriptionModel.name),
          Text("Price: \$${subscriptionModel.price}"),
          Text("Validity: ${subscriptionModel.validityInDays} Days"),
          Text("Games: ${subscriptionModel.gamesList}"),
          const SizedBox(height: 10,),
          if(showBuyButton) Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: CommonButton1(
              onTap: () async {
                if(buySubscriptionCallback != null) {
                  await buySubscriptionCallback!(subscriptionModel: subscriptionModel);
                }
              },
              text: "Choose",
            ),
          ),
        ],
      ),
    );
  }
}
