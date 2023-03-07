import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:okoto/backend/navigation/navigation.dart';
import 'package:okoto/model/subscription/subscription_model.dart';
import 'package:okoto/utils/my_utils.dart';
import 'package:okoto/view/common/components/common_cachednetwork_image.dart';
import 'package:okoto/view/common/components/common_loader.dart';
import 'package:okoto/view/common/components/common_submit_button.dart';
import 'package:okoto/view/common/components/common_text.dart';

import '../../../backend/game/game_controller.dart';
import '../../../configs/styles.dart';
import '../../../model/game/game_model.dart';

class SubscriptionCard extends StatefulWidget {
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
  State<SubscriptionCard> createState() => _SubscriptionCardState();
}

class _SubscriptionCardState extends State<SubscriptionCard> {
  late SubscriptionModel subscriptionModel;
  List<GameModel> gameModels = [];
  Future? getFuture;

  int getDiscountPercentage(double netPrice, double salePrice) {
    double discountPercent = 0;
    discountPercent = ((netPrice - salePrice) / netPrice) * 100;
    return discountPercent.roundToDouble().toInt();
  }

  Future getGameData() async {
    subscriptionModel = widget.subscriptionModel;

    SubscriptionModel model = subscriptionModel;

    gameModels = await GameController(gameProvider: null).gameRepository.getGameModelsListFromIdsList(idsList: model.gamesList);
  }

  @override
  void initState() {
    super.initState();
    getFuture = getGameData();
  }

  @override
  Widget build(BuildContext context) {
    Widget mainWidget = getMainBody(context);

    if (widget.isActiveSubscription) {
      mainWidget = ClipRRect(
        child: Banner(
          message: 'Active',
          location: BannerLocation.topEnd,
          color: Colors.green,
          child: getMainBody(context),
        ),
      );
    }

    mainWidget = Container(margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20), child: mainWidget);

    return mainWidget;
  }

  Widget getMainBody(context) {
    return InkWell(
      onTap: () async {
        await NavigationController.navigateToSubscriptionDetailScreen(
          navigationOperationParameters: NavigationOperationParameters(
            context: context,
            navigationType: NavigationType.pushNamed,
          ),
          arguments: SubscriptionDetailScreenNavigationArguments(
            subscriptionId: widget.subscriptionModel.id,
            subscriptionModel: widget.subscriptionModel,
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20).copyWith(bottom: 15),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(elevation: 8, child: getImage(url: widget.subscriptionModel.image)),
                SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CommonText(
                        text: widget.subscriptionModel.name,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      CommonText(
                        text: "Validity: ${widget.subscriptionModel.validityInDays} Days",
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Visibility(
                        visible: widget.subscriptionModel.discountedPrice == widget.subscriptionModel.price,
                        child: CommonText(text: "Rs. ${widget.subscriptionModel.price}", letterSpacing: 0.5, fontWeight: FontWeight.w600),
                      ),
                      Visibility(
                        visible: widget.subscriptionModel.discountedPrice != widget.subscriptionModel.price,
                        child: Row(
                          children: [
                            CommonText(text: "Rs. ${widget.subscriptionModel.discountedPrice}", letterSpacing: 0.5, fontWeight: FontWeight.w600),
                            SizedBox(
                              width: 10,
                            ),
                            CommonText(
                              text: "Rs. ${widget.subscriptionModel.price}",
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
                                  text: "${getDiscountPercentage(widget.subscriptionModel.price, widget.subscriptionModel.discountedPrice)}% OFF",
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
              height: widget.showBuyButton ? 10 : 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                FutureBuilder(
                  future: getFuture,
                  builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
                    if (asyncSnapshot.connectionState == ConnectionState.done) {
                      return Expanded(child: getGameListWidget());
                    } else {
                      return SpinKitCircle(color: Colors.white,size: 20,);
                    }
                  },
                ),
                if (widget.showBuyButton)
                  CommonSubmitButton(
                    onTap: () async {
                      if (widget.buySubscriptionCallback != null) {
                        await widget.buySubscriptionCallback!(subscriptionModel: widget.subscriptionModel);
                      }
                    },
                    text: "Choose",
                    elevation: 20,
                    height: 30,
                    fontSize: 12,
                    verticalPadding: 8,
                    horizontalPadding: 20,
                    borderRadius: 5,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget getGameListWidget() {
    return gameModels.length <= 3
        ? Row(
            children: List.generate(
              gameModels.length,
              (index) {
                GameModel gameModel = gameModels[index];
                return Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: Colors.white, width: 0.5),
                    ),
                    child: getImage(url: gameModel.thumbnailImage, borderRadius: 50, height: 20, width: 20),
                  ),
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
                    GameModel gameModel = gameModels[index];
                    return Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: getImage(url: gameModel.thumbnailImage, borderRadius: 50, height: 20, width: 20),
                    );
                  },
                  scrollDirection: Axis.horizontal,
                ),
              ),
              SizedBox(
                width: 6,
              ),
              CommonText(
                text: "+${gameModels.length - 3} more",
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
