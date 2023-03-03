import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:okoto/backend/user/user_provider.dart';
import 'package:okoto/model/user/user_model.dart';
import 'package:okoto/model/user/user_subscription_model.dart';
import 'package:okoto/utils/my_print.dart';
import 'package:provider/provider.dart';

import '../../backend/game/game_controller.dart';
import '../../backend/game/game_provider.dart';
import '../../configs/styles.dart';
import '../../model/game/game_model.dart';
import '../../utils/my_utils.dart';
import '../common/components/common_appbar.dart';
import '../common/components/common_cachednetwork_image.dart';
import '../common/components/common_loader.dart';
import '../common/components/common_text.dart';
import '../common/components/modal_progress_hud.dart';
import '../common/components/my_screen_background.dart';

class MyGameList extends StatefulWidget {
  static const String routeName = "/MyGameList";

  const MyGameList({Key? key}) : super(key: key);

  @override
  State<MyGameList> createState() => _MyGameListState();
}

class _MyGameListState extends State<MyGameList> {
  late GameProvider gameProvider;
  late GameController gameController;
  Future? getFutureData;
  List<GameModel> gameModels = [];
  bool isLoading = false;

  Future getGameData() async {
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.getUserModel() != null) {
      UserModel? userModel = UserModel.fromMap(userProvider.getUserModel()!.toMap());
      if (userModel.userSubscriptionModel != null) {
        UserSubscriptionModel? userSubscriptionModel = UserSubscriptionModel.fromMap(userModel.userSubscriptionModel!.toMap());
        List<String> gameId = userSubscriptionModel.selectedGames;
        MyPrint.logOnConsole("My Game List = ${userProvider.getUserModel()!.userSubscriptionModel!.toMap()}");
        if (gameId.isNotEmpty) {
          gameModels = await GameController(gameProvider: null).gameRepository.getGameModelsListFromIdsList(idsList: gameId);
        }
      }
    }
  }

  Future<void> getGameList() async {
    //await gameController.getAllGameList();
  }

  @override
  void initState() {
    super.initState();
    gameProvider = context.read<GameProvider>();
    gameController = GameController(gameProvider: gameProvider);
    getFutureData = getGameData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MyScreenBackground(
        child: ModalProgressHUD(
          inAsyncCall: isLoading,
          child: FutureBuilder(
              future: getFutureData,
              builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
                if (asyncSnapshot.connectionState == ConnectionState.done) {
                  return getMainWidget();
                } else {
                  return const Center(
                    child: CommonLoader(),
                  );
                }
              }),
        ),
      ),
    );
  }

  Widget getMainWidget() {
    return Column(
      children: [
        const CommonAppBar(
          text: 'My Games',
        ),
        const SizedBox(height: 10,),
        Expanded(child: myGameListWidget())
      ],
    );
  }

  Widget myGameListWidget() {
    if(gameModels.isEmpty){
      return const Center(
        child: Text("No game available"),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: gameModels.length,
      itemBuilder: (BuildContext context, int index) {
        GameModel gameModel = gameModels[index];
        return gameListData(gameModel, index);
      },
    );
  }

  //endregion
  Widget gameListData(GameModel gameModel, int index) {
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Styles.textWhiteColor))),
      padding: const EdgeInsets.only(bottom: 11, top: 11),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: index == 0 ? true : false,
          collapsedIconColor: Colors.white,
          iconColor: Colors.white,
          tilePadding: EdgeInsets.zero,
          title: Row(
            children: [
              getImage(url: gameModel.thumbnailImage, height: 65, width: 90, borderRadius: 0),
              const SizedBox(
                width: 20,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(text: gameModel.name, fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: .3),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        const CommonText(text: "4", fontSize: 13),
                        Icon(
                          Icons.star,
                          color: Styles.starColor,
                          size: 15,
                        )
                      ],
                    )
                  ],
                ),
              ),
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

  Widget getImage({String url = "", double borderRadius = 5.0, double height = 76, double width = 76}) {
    return CommonCachedNetworkImage(
      imageUrl: MyUtils().getSecureUrl(url),
      height: height,
      width: width,
      borderRadius: borderRadius,
    );
  }
//endregion
}
