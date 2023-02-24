import 'package:flutter/material.dart';
import 'package:okoto/backend/game/game_controller.dart';
import 'package:okoto/backend/navigation/navigation.dart';
import 'package:okoto/backend/subscription/subscription_controller.dart';
import 'package:okoto/model/game/game_model.dart';
import 'package:okoto/model/subscription/subscription_model.dart';
import 'package:okoto/view/common/components/common_primary_button.dart';
import 'package:provider/provider.dart';

import '../../../backend/user/user_provider.dart';
import '../../../utils/my_toast.dart';
import '../../common/components/common_loader.dart';
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

    if(subscriptionModel != null) {
      SubscriptionModel model = subscriptionModel!;

      int gamesLength = model.gamesList.length;
      if(gamesLength > 0 && model.requiredGamesCount == gamesLength) {
        selectedGamesList.addAll(model.gamesList);
        isEnableGameSelection = false;
      }

      gameModels = await GameController(gameProvider: null).gameRepository.getGameModelsListFromIdsList(idsList: model.gamesList);
    }
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
      selectedGamesList: selectedGamesList,
      userProvider: userProvider,
    );

    if(context.mounted) {
      setState(() {
        isLoading = false;
      });

      if(isSubscriptionBuySuccessful) {
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
    initialize();
  }

  @override
  Widget build(BuildContext context) {
    themeData = Theme.of(context);

    return ModalProgressHUD(
      inAsyncCall: isLoading,
      progressIndicator: const CommonLoader(),
      child: Scaffold(
        appBar: getAPpBar(),
        body: SafeArea(
          child: FutureBuilder(
            future: future,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if(snapshot.connectionState == ConnectionState.done) {
                return getMainBody(
                  subscriptionModel: subscriptionModel,
                  games: gameModels,
                );
              }
              else {
                return const CommonLoader(isCenter: true,);
              }
            },
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget getAPpBar() {
    return AppBar(
      title: const Text(
        "Subscriptions",
        style: TextStyle(
          // fontSize: 16,
        ),
      ),
    );
  }

  Widget getMainBody({required SubscriptionModel? subscriptionModel, required List<GameModel> games}) {
    if(subscriptionModel == null) {
      return const Center(
        child: Text("Subscription Data Not Available"),
      );
    }

    return Column(
      children: [
        getSubscriptionCard(subscriptionModel: subscriptionModel),
        Expanded(
          child: getGamesListView(
            subscriptionModel: subscriptionModel,
            games: games,
          ),
        ),
        getPriceAndCheckoutButtonWidget(
          subscriptionModel: subscriptionModel,
        ),
      ],
    );
  }

  Widget getSubscriptionCard({required SubscriptionModel subscriptionModel}) {
    return Card(
      child: Center(
        child: Text("Subscription Data:${subscriptionModel.name}"),
      ),
    );
  }

  Widget getGamesListView({required SubscriptionModel subscriptionModel, required List<GameModel> games}) {
    return ListView.builder(
      itemCount: games.length,
      itemBuilder: (BuildContext context, int index) {
        GameModel gameModel = games[index];

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: SubscriptionCheckoutGameSelectionCard(
            gameModel: gameModel,
            isGameAdded: selectedGamesList.contains(gameModel.id),
            isShowGameSelectionButton: isEnableGameSelection,
            onGameNotSelectedButtonTap: (GameModel gameModel) {
              if(selectedGamesList.length < subscriptionModel.requiredGamesCount) {
                selectedGamesList.add(gameModel.id);
                setState(() {});
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
    if(selectedGamesList.isEmpty) {
      return const SizedBox();
    }

    int remainingGamesLength = subscriptionModel.requiredGamesCount - selectedGamesList.length;
    bool isBuyValid = remainingGamesLength == 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: themeData.primaryColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Rs. ${subscriptionModel.price}"),
          CommonPrimaryButton(
            onTap: () {
              if(isBuyValid) {
                buySubscription(subscriptionModel: subscriptionModel);
              }
            },
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            text: isBuyValid ? "Buy Now" : "$remainingGamesLength more left",
            filled: isBuyValid,
          ),
        ],
      ),
    );
  }
}
