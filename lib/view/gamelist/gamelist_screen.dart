import 'package:flutter/material.dart';
import 'package:okoto/backend/game/game_controller.dart';
import 'package:okoto/backend/game/game_provider.dart';
import 'package:okoto/view/common/components/common_appbar.dart';
import 'package:okoto/view/common/components/common_loader.dart';
import 'package:okoto/view/common/components/modal_progress_hud.dart';
import 'package:okoto/view/common/components/my_screen_background.dart';
import 'package:provider/provider.dart';

import '../../configs/styles.dart';
import '../../model/game/game_model.dart';
import '../../utils/my_utils.dart';
import '../common/components/common_cachednetwork_image.dart';
import '../common/components/common_text.dart';

class GameListScreen extends StatefulWidget {
  static const String routeName = "/gameListScreen";
  const GameListScreen({Key? key}) : super(key: key);

  @override
  State<GameListScreen> createState() => _GameListScreenState();
}

class _GameListScreenState extends State<GameListScreen> {
  late GameProvider gameProvider;
  late GameController gameController;
  Future? getFutureData;

  bool isLoading = false;

  Future<void> getGameList() async {
    await gameController.getAllGameList();
  }


  @override
  void initState() {
    super.initState();
    gameProvider = context.read<GameProvider>();
    gameController = GameController(gameProvider: gameProvider);
    getFutureData = getGameList();
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
              if(asyncSnapshot.connectionState == ConnectionState.done){
                return getMainWidget();
              }
               else {
                 return Center(child: CommonLoader(),);
              }
            }
          ),
        ),
      ),
    );
  }

  Widget getMainWidget(){
    return Column(
      children: [
        const CommonAppBar(text: 'All Games',),
        // const SizedBox(height: 10,),
        Expanded(child: getGameListWidget())
      ],
    );
  }


  //region gameListBuilder
  Widget getGameListWidget(){
    return Consumer(
      builder: (BuildContext context, GameProvider gameProvider, _) {
        List<GameModel> gameList = gameProvider.gameModelList.getList();
        return ListView.builder(
          padding: EdgeInsets.all(20),
            itemCount: gameList.length,
            itemBuilder: (BuildContext context, int index){
            GameModel gameModel = gameList[index];
            return gameListData(gameModel, index);
        });
      }
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
