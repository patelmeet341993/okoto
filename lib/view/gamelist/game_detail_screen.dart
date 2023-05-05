import 'package:flutter/material.dart';
import 'package:okoto/backend/navigation/navigation.dart';
import 'package:okoto/model/game/game_model.dart';
import 'package:okoto/view/common/components/common_text.dart';
import 'package:provider/provider.dart';

import '../../backend/game/game_controller.dart';
import '../../backend/game/game_provider.dart';
import '../../utils/my_utils.dart';
import '../common/components/common_appbar.dart';
import '../common/components/common_cachednetwork_image.dart';
import '../common/components/common_loader.dart';
import '../common/components/image_view_page.dart';
import '../common/components/modal_progress_hud.dart';
import '../common/components/my_screen_background.dart';

class GameDetailsScreen extends StatefulWidget {
  static const String routeName = "/GameDetailsScreen";
  GameDetailsScreenNavigationArguments arguments;

  GameDetailsScreen({required this.arguments});

  @override
  State<GameDetailsScreen> createState() => _GameDetailsScreenState();
}

class _GameDetailsScreenState extends State<GameDetailsScreen> {
  bool isLoading = false;
  late Future getFutureData;
  late GameProvider gameProvider;
  late GameController gameController;
  GameModel? gameModel;

  Future<void> getGameModel() async {
    if (widget.arguments.gameModel != null) {
      gameModel = widget.arguments.gameModel;
    } else {
      if (widget.arguments.gameId.isNotEmpty) {
        GameModel? methodGameModel;
        methodGameModel =  await gameController.getGameDetailsFromGameId(widget.arguments.gameId);
        if(methodGameModel != null){
          gameModel = methodGameModel;
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    gameProvider = context.read<GameProvider>();
    gameController = GameController(gameProvider: gameProvider);
    getFutureData = getGameModel();
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CommonAppBar(
          text: 'Game Details',
        ),
        gameModel != null
            ? Expanded(child: getGameDetail(gameModel!))
            : const Expanded(
                child: CommonText(
                  text: 'Game Details Not Available',
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  textAlign: TextAlign.center,
                ),
              )
      ],
    );
  }

  Widget getGameDetail(GameModel model) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 5,
            ),
            getGameTitleRow(model),
            getGameDescriptionView(model),

          ],
        ),
      ),
    );
  }

  Widget getGameTitleRow(GameModel model){
    return Row(
      children: [
        getImage(url: model.thumbnailImage, height: 65, width: 90, borderRadius: 5),
        const SizedBox(
          width: 20,
        ),
        Expanded(child: CommonText(text: model.name, fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: .3)),
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


  Widget getGameDescriptionView(GameModel gameModel) {
    return Container(
      child: CommonWidgetWithHeader(
        fontSize: 19,
        text: "Description",
        widget: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 5,
            ),
            CommonText(
              text: gameModel.description,
              letterSpacing: .2,
              textAlign: TextAlign.justify,
              fontSize: 14,
            ),
            const SizedBox(
              height: 25,
            ),
            Visibility(
                visible: gameModel.gameImages.isNotEmpty,
                child: CommonText(
                  text: "Game Images",
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                ),),
            Visibility(
                visible: gameModel.gameImages.isNotEmpty,
                child: gameImageSlider(gameModel.gameImages)
            )
          ],
        ),
      ),
    );
  }

  Widget gameImageSlider(List<String> gamesUrl) {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
        itemCount: gamesUrl.length,
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int index) {
          return Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: (){
                  showDialog(context: context, builder: (context){
                    return ImageViewPage(
                      isDialog: true,
                      images: [gamesUrl[index]],
                      initialIndex: 0,
                    );
                  });
                },
                child: getImage(
                    url: gamesUrl[index],
                    height: 170,
                    width: double.maxFinite,
                    borderRadius: 4),
              ));
        });
  }

  Widget CommonWidgetWithHeader({required String text, required Widget widget, double fontSize = 19}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 25,
        ),
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


}
