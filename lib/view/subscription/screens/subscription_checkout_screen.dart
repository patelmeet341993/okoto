import 'package:flutter/material.dart';
import 'package:okoto/backend/game/game_controller.dart';
import 'package:okoto/backend/navigation/navigation.dart';
import 'package:okoto/backend/order/order_controller.dart';
import 'package:okoto/backend/order/order_provider.dart';
import 'package:okoto/backend/subscription/subscription_controller.dart';
import 'package:okoto/model/game/game_model.dart';
import 'package:okoto/model/subscription/subscription_model.dart';
import 'package:okoto/view/common/components/common_appbar.dart';
import 'package:okoto/view/common/components/common_submit_button.dart';
import 'package:okoto/view/common/components/my_screen_background.dart';
import 'package:provider/provider.dart';

import '../../../backend/analytics/analytics_controller.dart';
import '../../../backend/analytics/analytics_event.dart';
import '../../../backend/user/user_provider.dart';
import '../../../configs/styles.dart';
import '../../../utils/my_toast.dart';
import '../../../utils/my_utils.dart';
import '../../common/components/common_cachednetwork_image.dart';
import '../../common/components/common_loader.dart';
import '../../common/components/common_text.dart';
import '../../common/components/modal_progress_hud.dart';
import '../components/subscription_checkout_game_selection_card.dart';

class SubscriptionCheckoutScreen extends StatefulWidget {
  static const String routeName = "/SubscriptionCheckoutScreen";

  final SubscriptionCheckoutScreenNavigationArguments arguments;

  const SubscriptionCheckoutScreen({
    Key? key,
    required this.arguments,
  }) : super(key: key);

  @override
  State<SubscriptionCheckoutScreen> createState() => _SubscriptionCheckoutScreenState();
}

class _SubscriptionCheckoutScreenState extends State<SubscriptionCheckoutScreen> {
  late ThemeData themeData;
  bool isLoading = false;
  late SubscriptionController subscriptionController;

  late UserProvider userProvider;

  String subscriptionId = "";
  SubscriptionModel? subscriptionModel;
  List<GameModel> gameModels = <GameModel>[];
  List<String> selectedGamesList = <String>[];
  bool isEnableGameSelection = true;

  late Future<void> future;

  void initialize() {
    subscriptionController = SubscriptionController(subscriptionProvider: null);

    userProvider = context.read<UserProvider>();

    subscriptionId = widget.arguments.subscriptionId;
    subscriptionModel = widget.arguments.subscriptionModel;

    future = getData();
  }

  Future<void> getData() async {
    subscriptionModel ??= await subscriptionController.subscriptionRepository.getSubscriptionModelFromId(subscriptionId: subscriptionId);

    if (subscriptionModel != null) {
      SubscriptionModel model = subscriptionModel!;

      int gamesLength = model.gamesList.length;
      if (gamesLength > 0 && model.requiredGamesCount == gamesLength) {
        selectedGamesList.addAll(model.gamesList);
        isEnableGameSelection = false;
      }

      gameModels = await GameController(gameProvider: null).gameRepository.getGameModelsListFromIdsList(idsList: model.gamesList);
    }
  }

  Future<void> buySubscription({required SubscriptionModel subscriptionModel}) async {
    String userId = userProvider.getUserId();

    if (userId.isEmpty) {
      MyToast.showError(context: context, msg: "User Data Not Available");
      return;
    }

    setState(() {
      isLoading = true;
    });
    AnalyticsController().fireEvent(analyticEvent: AnalyticsEvent.subscriptionscreen_payment_started,parameters: {AnalyticsParameters.event_value:subscriptionModel.name});
    bool isSubscriptionBuySuccessful = await subscriptionController.buySubscription(
      context: context,
      userId: userId,
      subscriptionModel: subscriptionModel,
      selectedGamesList: selectedGamesList,
      userProvider: userProvider,
    );

    if (context.mounted) {
      setState(() {
        isLoading = false;
      });

      if (isSubscriptionBuySuccessful) {
        OrderController(orderProvider: context.read<OrderProvider>()).getOrdersList(
          userId: userId,
          isRefresh: true,
          isNotify: true,
        );
        AnalyticsController().fireEvent(analyticEvent: AnalyticsEvent.subscriptionscreen_payment_success,parameters: {AnalyticsParameters.event_value:subscriptionModel.name});
        AnalyticsController().fireEvent(analyticEvent: AnalyticsEvent.subscriptionscreen_plan_purchased_success,parameters: {AnalyticsParameters.event_value:subscriptionModel.name});
        AnalyticsController().fireEvent(analyticEvent: AnalyticsEvent.subscriptionscreen_plan_purchased_success_gamelist,
            parameters: {AnalyticsParameters.event_value: '${subscriptionModel.name} : ${subscriptionModel.gamesList}'});

        if(subscriptionModel.gamesList.isNotEmpty){
          subscriptionModel.gamesList.forEach((game) {
            AnalyticsController().fireEvent(analyticEvent: AnalyticsEvent.subscriptionscreen_plan_added_games,
                parameters: {AnalyticsParameters.event_value: game});
          });
        }

        NavigationController.navigateToOrderListScreen(
          navigationOperationParameters: NavigationOperationParameters(
            context: context,
            navigationType: NavigationType.popAndPushNamed,
          ),
        );
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
    AnalyticsController().fireEvent(analyticEvent: AnalyticsEvent.user_any_screen_view,parameters: {AnalyticsParameters.event_value:AnalyticsParameterValue.check_out_screen});
    initialize();
  }

  @override
  Widget build(BuildContext context) {
    themeData = Theme.of(context);

    return ModalProgressHUD(
      inAsyncCall: isLoading,
      progressIndicator: const CommonLoader(),
      child: MyScreenBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: const CommonAppBar(
            text: "Checkout",
          ),
          body: SafeArea(
            child: FutureBuilder(
              future: future,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return getMainBody(
                    subscriptionModel: subscriptionModel,
                    games: gameModels,
                  );
                } else {
                  return const CommonLoader(
                    isCenter: true,
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget getMainBody({required SubscriptionModel? subscriptionModel, required List<GameModel> games}) {
    if (subscriptionModel == null) {
      return const Center(
        child: Text("Subscription Data Not Available"),
      );
    }

    return Column(
      children: [

        Padding(
          padding: const EdgeInsets.all(18.0),
          child: getSubscriptionCard(subscriptionModel: subscriptionModel),
        ),
        const SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: CommonText(text:
          "You can select ${subscriptionModel.requiredGamesCount} game(s). Click on '+ Add' Button to choose Games.",
          fontSize: 16,
          fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 25,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.0),
                child: CommonText(text: "Games", fontWeight: FontWeight.w600, fontSize: 18),
              ),
              const SizedBox(
                height: 0,
              ),
              Expanded(
                child: getGamesListView(
                  subscriptionModel: subscriptionModel,
                  games: games,
                ),
              ),
            ],
          ),
        ),
        getPriceAndCheckoutButtonWidget(
          subscriptionModel: subscriptionModel,
        ),
      ],
    );
  }

  Widget getSubscriptionCard({required SubscriptionModel subscriptionModel}) {
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
              CommonText(
                text: "Validity: ${subscriptionModel.validityInDays} Days",
                fontSize: 13,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
              const SizedBox(
                height: 5,
              ),
              CommonText(
                text: "You can select ${subscriptionModel.requiredGamesCount} game(s)",
                fontSize: 13,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
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

  Widget getGamesListView({required SubscriptionModel subscriptionModel, required List<GameModel> games}) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      itemCount: games.length,
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        GameModel gameModel = games[index];

        return Container(
          margin: const EdgeInsets.only(top: 25),
          child: SubscriptionCheckoutGameSelectionCard(
            gameModel: gameModel,
            isGameAdded: selectedGamesList.contains(gameModel.id),
            isShowGameSelectionButton: isEnableGameSelection,
            onGameNotSelectedButtonTap: (GameModel gameModel) {
              if (selectedGamesList.length < subscriptionModel.requiredGamesCount) {
                selectedGamesList.add(gameModel.id);
                setState(() {});
              } else {
                MyToast.showSuccess(context: context, msg: "You have already selected ${subscriptionModel.requiredGamesCount} game(s)");
              }
            },
            onGameSelectedButtonTap: (GameModel gameModel) {
              selectedGamesList.remove(gameModel.id);
              setState(() {});
            },
          ),
        );
      },
    );
  }

  Widget getPriceAndCheckoutButtonWidget({
    required SubscriptionModel subscriptionModel,
  }) {
    if (selectedGamesList.isEmpty) {
      return const SizedBox();
    }

    int remainingGamesLength = subscriptionModel.requiredGamesCount - selectedGamesList.length;
    bool isBuyValid = remainingGamesLength == 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(topRight: Radius.circular(10), topLeft: Radius.circular(10)),
        color: Styles.checkoutBottomPriceBackground,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CommonText(
            text: "Rs. ${subscriptionModel.price}",
            fontSize: 18,
            letterSpacing: 0.2,
          ),
          !isBuyValid
              ? Container(
                  padding: EdgeInsets.symmetric(horizontal: 35, vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Styles.moreLeftBackground,
                  ),
                  child: CommonText(
                    text: "$remainingGamesLength more left",
                    color: Styles.moreLeftTextColor,
                    letterSpacing: 0.2,
                    fontSize: 17,
                  ))
              : CommonSubmitButton(
                  elevation: 20,
                  horizontalPadding: 45,
                  fontSize: 17,
                  verticalPadding: 14,
                  onTap: () {
                    if (isBuyValid) {

                      buySubscription(subscriptionModel: subscriptionModel);
                    }
                  },
                  text: "Buy Now",
                )
        ],
      ),
    );
  }
}
