import 'package:flutter/material.dart';

import '../../../model/game/game_model.dart';
import '../../common/components/common_cachednetwork_image.dart';

class SubscriptionCheckoutGameSelectionCard extends StatelessWidget {
  final GameModel gameModel;
  final bool isGameAdded;
  final bool isShowGameSelectionButton;
  final void Function(GameModel gameModel)? onGameNotSelectedButtonTap;
  final void Function(GameModel gameModel)? onGameSelectedButtonTap;

  const SubscriptionCheckoutGameSelectionCard({
    Key? key,
    required this.gameModel,
    required this.isGameAdded,
    required this.isShowGameSelectionButton,
    this.onGameNotSelectedButtonTap,
    this.onGameSelectedButtonTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Row(
          children: [
            getImageCardWidget(themeData: themeData),
            Expanded(
              child: getGameDetailsWidget(),
            ),
          ],
        ),
      ),
    );
  }

  //region Image Widget
  Widget getImageCardWidget({required ThemeData themeData}) {
    return SizedBox(
      height: 150,
      width: 200,
      // color: Colors.red,
      child: Stack(
        // fit: StackFit.expand,
        children: [
          AspectRatio(
            aspectRatio: 14/9,
            child: getGameImageWidget(),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: getSelectGameButton(themeData: themeData),
          ),
        ],
      ),
    );
  }

  Widget getGameImageWidget() {
    return CommonCachedNetworkImage(
      imageUrl: gameModel.thumbnailImage,
    );
  }

  Widget getSelectGameButton({required ThemeData themeData}) {
    if(!isShowGameSelectionButton) {
      return const SizedBox();
    }

    if(isGameAdded) {
      return InkWell(
        onTap: () {
          if(onGameSelectedButtonTap != null) {
            onGameSelectedButtonTap!(gameModel);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: themeData.colorScheme.onBackground,
            border: Border.all(color: themeData.primaryColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.remove,
                color: themeData.colorScheme.background,
              ),
              Text(
                "Added",
                style: themeData.textTheme.bodyMedium?.copyWith(
                  color: themeData.colorScheme.background,
                ),
              ),
            ],
          ),
        ),
      );
    }
    else {
      return InkWell(
        onTap: () {
          if(onGameNotSelectedButtonTap != null) {
            onGameNotSelectedButtonTap!(gameModel);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: themeData.colorScheme.onBackground,
            border: Border.all(color: themeData.primaryColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add,
                color: themeData.colorScheme.background,
              ),
              Text(
                "Add",
                style: themeData.textTheme.bodyMedium?.copyWith(
                  color: themeData.colorScheme.background,
                ),
              ),
            ],
          ),
        ),
      );
    }

  }
  //endregion

  //region Game Details Widget
  Widget getGameDetailsWidget() {
    return Column(
      children: [
        Text(gameModel.name),
      ],
    );
  }
  //endregion
}
