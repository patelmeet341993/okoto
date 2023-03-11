import 'package:flutter/material.dart';
import 'package:okoto/backend/user/user_provider.dart';
import 'package:okoto/model/game/game_model.dart';
import 'package:okoto/model/subscription/subscription_model.dart';
import 'package:okoto/utils/my_print.dart';
import 'package:okoto/view/common/components/common_loader.dart';
import 'package:okoto/view/common/components/common_submit_button.dart';
import 'package:okoto/view/common/components/my_screen_background.dart';
import 'package:provider/provider.dart';

import '../../../backend/game/game_controller.dart';
import '../../../backend/navigation/navigation_arguments.dart';
import '../../../backend/navigation/navigation_controller.dart';
import '../../../backend/navigation/navigation_operation_parameters.dart';
import '../../../backend/navigation/navigation_type.dart';
import '../../../configs/styles.dart';
import '../../../utils/my_utils.dart';
import '../../common/components/common_appbar.dart';
import '../../common/components/common_cachednetwork_image.dart';
import '../../common/components/common_text.dart';

class SubscriptionDetail extends StatefulWidget {
  static const String routeName = "/subscriptionDetail";
  final SubscriptionDetailScreenNavigationArguments arguments;

  const SubscriptionDetail({Key? key, required this.arguments}) : super(key: key);

  @override
  State<SubscriptionDetail> createState() => _SubscriptionDetailState();
}

class _SubscriptionDetailState extends State<SubscriptionDetail> {
  late SubscriptionModel subscriptionModel;
  List<GameModel> gameModels = [];
  Future? getFuture;

  int getDiscountPercentage(double netPrice, double salePrice) {
    double discountPercent = 0;
    discountPercent = ((netPrice - salePrice) / netPrice) * 100;
    return discountPercent.roundToDouble().toInt();
  }

  Future getGameData() async {
    subscriptionModel = widget.arguments.subscriptionModel ?? SubscriptionModel(id: widget.arguments.subscriptionId);

    if (subscriptionModel != null) {
      SubscriptionModel model = subscriptionModel;

      gameModels = await GameController(gameProvider: null).gameRepository.getGameModelsListFromIdsList(idsList: model.gamesList);
    }
  }

  @override
  void initState() {
    super.initState();
    getFuture = getGameData();
  }

  @override
  Widget build(BuildContext context) {
    return MyScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const CommonAppBar(
          text: "Plan Details",
        ),
        body: FutureBuilder(
          future: getFuture,
          builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
            if (asyncSnapshot.connectionState == ConnectionState.done) {
              MyPrint.printOnConsole('SubsCripModel : ${subscriptionModel.toMap()}');
              return getMainWidget();
            } else {
              return const Center(child: CommonLoader());
            }
          },
        ),
      ),
    );
  }

  Widget getMainWidget() {
    return Consumer(
      builder: (BuildContext context, UserProvider userProvider, _) {
        SubscriptionModel? activeSubscriptionModel = userProvider.getUserModel()?.userSubscriptionModel?.mySubscription;

        bool isActiveSubscription = false;
        if(activeSubscriptionModel != null){
          isActiveSubscription = activeSubscriptionModel!.id == subscriptionModel.id;
        }
        return Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0).copyWith(top: 32),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    getSubscriptionsNamesAndImage(),
                    const SizedBox(
                      height: 25,
                    ),
                    validityView(),
                    const SizedBox(
                      height: 25,
                    ),
                    getDescriptionView(),
                    const SizedBox(
                      height: 25,
                    ),
                    getGamesView(),
                    const SizedBox(
                      height: 50,
                    ),
                   /* Center(
                      child: Visibility(
                        visible: !isActiveSubscription,
                        child: CommonSubmitButton(
                            // height: 30,
                            horizontalPadding: 52,
                            verticalPadding: 10,
                            text: "Choose",
                            onTap: () async {
                              await NavigationController.navigateToSubscriptionCheckoutScreen(
                                navigationOperationParameters: NavigationOperationParameters(
                                  context: context,
                                  navigationType: NavigationType.pushNamed,
                                ),
                                arguments: SubscriptionCheckoutScreenNavigationArguments(
                                  subscriptionId: subscriptionModel.id,
                                  subscriptionModel: subscriptionModel,
                                ),
                              );
                            }),
                      ),
                    ),*/
                    const SizedBox(
                      height: 80,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: !isActiveSubscription?CommonSubmitButton(
                horizontalPadding: 52,
                verticalPadding: 18,
                borderRadius: 120,
                fontSize: 20,
                text: "Choose Plan",
                onTap: ()async {
                  await NavigationController.navigateToSubscriptionCheckoutScreen(
                    navigationOperationParameters: NavigationOperationParameters(
                      context: context,
                      navigationType: NavigationType.pushNamed,
                    ),
                    arguments: SubscriptionCheckoutScreenNavigationArguments(
                      subscriptionId: subscriptionModel.id,
                      subscriptionModel: subscriptionModel,
                    ),
                  );

                },
              ):SizedBox.shrink(),
            )
          ],
        );
      }
    );
  }

  //region subscriptionsNamesAndImageView
  Widget getSubscriptionsNamesAndImage() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(elevation: 8, child: getImage(url: subscriptionModel.image)),
        const SizedBox(
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
              const SizedBox(
                height: 5,
              ),
              Visibility(
                visible: subscriptionModel.discountedPrice == subscriptionModel.price,
                child: CommonText(text: "Rs. ${subscriptionModel.price}", letterSpacing: 0.5, fontWeight: FontWeight.w600),
              ),
              Visibility(
                visible: subscriptionModel.discountedPrice != subscriptionModel.price,
                child: Row(
                  children: [
                    CommonText(text: "Rs. ${subscriptionModel.discountedPrice}", letterSpacing: 0.5, fontWeight: FontWeight.w600),
                    const SizedBox(
                      width: 10,
                    ),
                    CommonText(
                      text: "Rs. ${subscriptionModel.price}",
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w400,
                      textDecoration: TextDecoration.lineThrough,
                      fontSize: 12,
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(color: Styles.discountCardColor, borderRadius: BorderRadius.circular(20)),
                      child: Center(
                        child: CommonText(
                          text: "${getDiscountPercentage(subscriptionModel.price, subscriptionModel.discountedPrice)}% OFF",
                          letterSpacing: 0.2,
                          fontWeight: FontWeight.w600,
                          fontSize: 9,
                          color: Styles.discountTextColor,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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

//endregion

  //region validityView
  Widget validityView() {
    return CommonWidgetWithHeader(
        text: "Validity",
        widget: CommonText(
          text: "${subscriptionModel.validityInDays} Days",
          letterSpacing: .2,
          fontSize: 15,
        ));
  }

//endregion

  //region descriptionView
  Widget getDescriptionView() {
    return CommonWidgetWithHeader(
        text: "Description",
        widget: CommonText(
          text: subscriptionModel.description,
          letterSpacing: .2,
          fontSize: 15,
        ));
  }

  //endregion

  //region gamesView
  Widget getGamesView() {
    return CommonWidgetWithHeader(text: "Games", widget: gameList());
  }

  Widget gameList() {
    return Container(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: gameModels.length,
        itemBuilder: (BuildContext context, int index) {
          return gameListData(gameModels[index]);
        },
      ),
    );
  }

  Widget gameListData(GameModel gameModel) {
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Styles.textWhiteColor))),
      padding: const EdgeInsets.only(bottom: 11, top: 11),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          collapsedIconColor: Colors.white,
          iconColor: Colors.white,
          tilePadding: EdgeInsets.zero,
          title: Row(
            children: [
              getImage(url: gameModel.thumbnailImage, height: 65, width: 90, borderRadius: 0),
              const SizedBox(
                width: 20,
              ),
              Expanded(child: CommonText(text: gameModel.name, fontSize: 17, fontWeight: FontWeight.w600, letterSpacing: .3)),
            ],
          ),
          children: [
            const SizedBox(
              height: 12,
            ),
            getGameChildrenView(gameModel),
          ],
        ),
      ),
    );
  }

  Widget getGameChildrenView(GameModel gameModel) {
    return Container(
      child: CommonWidgetWithHeader(
        fontSize: 14,
        text: "Description",
        widget: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: gameModel.gameImages.isNotEmpty ? 0 : 8.0),
              child: CommonText(
                text: gameModel.description,
                letterSpacing: .2,
                textAlign: TextAlign.justify,
                fontSize: 12,
              ),
            ),
            Visibility(visible: gameModel.gameImages.isNotEmpty, child: gameImageSlider(gameModel.gameImages))
          ],
        ),
      ),
    );
  }

  Widget gameImageSlider(List<String> gamesUrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18.0),
      child: SizedBox(
        height: 95,
        child: ListView.builder(
            itemCount: gamesUrl.length,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemBuilder: (BuildContext context, int index) {
              return Padding(padding: const EdgeInsets.only(right: 22), child: getImage(url: gamesUrl[index], width: 154, borderRadius: 0));
            }),
      ),
    );
  }

  //endregion

  //region CommonWidgetView with title
  Widget CommonWidgetWithHeader({required String text, required Widget widget, double fontSize = 19}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(
          text: text,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(
          height: 5,
        ),
        widget
      ],
    );
  }
//endregion
}
