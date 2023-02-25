import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:okoto/model/subscription/subscription_model.dart';
import 'package:okoto/utils/my_utils.dart';
import 'package:okoto/view/common/components/common_cachednetwork_image.dart';
import 'package:okoto/view/common/components/common_submit_button.dart';
import 'package:okoto/view/common/components/common_text.dart';

import '../../../configs/styles.dart';
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

  int getDiscountPercentage(double netPrice, double salePrice) {
    double discountPercent = 0;
    discountPercent = ((netPrice - salePrice) / netPrice) * 100;
    return discountPercent.roundToDouble().toInt();
  }

  @override
  Widget build(BuildContext context) {
    Widget widget = getMainBody();

    if (isActiveSubscription) {
      widget = ClipRRect(
        child: Banner(
          message: 'Active',
          location: BannerLocation.topEnd,
          color: Colors.green,
          child: getMainBody(),
        ),
      );
    }

    widget = Container(margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 18), child: widget);

    return widget;
  }

  Widget getMainBody() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20).copyWith(bottom: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: [
            Styles.cardGradient1,
            Styles.cardGradient2,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(elevation: 8, child: getImage(url: subscriptionModel.image)),
              SizedBox(
                width: 20,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CommonText(
                      text: subscriptionModel.name,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    CommonText(
                      text: "Validity: ${subscriptionModel.validityInDays} Days",
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Visibility(
                      visible: subscriptionModel.discountedPrice == 0,
                      child: CommonText(text: "Rs. ${subscriptionModel.price}", letterSpacing: 0.5, fontWeight: FontWeight.w600),
                    ),
                    Visibility(
                      visible: subscriptionModel.discountedPrice != 0,
                      child: Row(
                        children: [
                          CommonText(text: "Rs. ${subscriptionModel.discountedPrice}", letterSpacing: 0.5, fontWeight: FontWeight.w600),
                          SizedBox(
                            width: 10,
                          ),
                          CommonText(
                            text: "Rs. ${subscriptionModel.price}",
                            letterSpacing: 0.5,
                            fontWeight: FontWeight.w400,
                            textDecoration: TextDecoration.lineThrough,
                            fontSize: 12,
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Container(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(color: Styles.discountCardColor, borderRadius: BorderRadius.circular(20)),
                              child: Center(
                                  child: CommonText(
                                text: "${getDiscountPercentage(subscriptionModel.price, subscriptionModel.discountedPrice)}% OFF",
                                letterSpacing: 0.2,
                                fontWeight: FontWeight.w600,
                                fontSize: 9,
                                color: Styles.discountTextColor,
                                textAlign: TextAlign.center,
                              ))),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          SizedBox(
            height: showBuyButton ? 10:20,
          ),
          Row(
            children: [
              Expanded(child: getGameListWidget()),
              if (showBuyButton)
                CommonSubmitButton(
                  onTap: () async {
                    if (buySubscriptionCallback != null) {
                      await buySubscriptionCallback!(subscriptionModel: subscriptionModel);
                    }
                  },
                  text: "Choose",
                  fontSize: 12,
                  verticalPadding: 6,
                  horizontalPadding: 15,
                  borderRadius: 5,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget getGameListWidget() {
    return subscriptionModel.gamesList.length <= 3
        ? Row(
            children: List.generate(
              subscriptionModel.gamesList.length,
              (index) {
                return Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: getImage(url: subscriptionModel.gamesList[index], borderRadius: 50, height: 20, width: 20),
                );
              },
            ),
          )
        : Row(
            children: [
              Container(
                height: 20,
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: 3,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: getImage(url: subscriptionModel.gamesList[index], borderRadius: 50, height: 20, width: 20),
                    );
                  },
                  scrollDirection: Axis.horizontal,
                ),
              ),
              SizedBox(
                width: 6,
              ),
              CommonText(
                text: "+${subscriptionModel.gamesList.length - 3} more",
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              )
            ],
          );
  }

  Widget getImage({String url = "", double borderRadius = 5.0, double height = 76, double width = 76}) {
    return CommonCachedNetworkImage(
      imageUrl: MyUtils().getSecureUrl(url),
      height: height,
      width: width,
      borderRadius: borderRadius,
    );
  }
}
