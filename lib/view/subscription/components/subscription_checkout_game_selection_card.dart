import 'package:flutter/material.dart';
import 'package:okoto/view/common/components/common_button1.dart';
import 'package:okoto/view/common/components/common_submit_button.dart';
import 'package:readmore/readmore.dart';

import '../../../configs/dotted_line.dart';
import '../../../configs/styles.dart';
import '../../../model/game/game_model.dart';
import '../../common/components/common_cachednetwork_image.dart';
import '../../common/components/common_text.dart';

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


    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Card(
          color: Colors.transparent,
          elevation: 0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              getImageCardWidget(themeData: themeData),
              SizedBox(
                width: 18,
              ),
              Expanded(
                child: getGameDetailsWidget(),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 25,
        ),
        const DottedLine(
          dashColor: Colors.white,
        ),
      ],
    );
  }

  //region Image Widget
  Widget getImageCardWidget({required ThemeData themeData}) {
    return SizedBox(
      height: 118,
      width: 134,
      child: Container(
        color: Colors.transparent,
        child: Stack(
          clipBehavior: Clip.none,
          // alignment: Alignment.bottomCenter,
          // fit: StackFit.passthrough,

          // fit: StackFit.expand,
          children: [
            Card(
              elevation: 10,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: getGameImageWidget(),
              ),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              child: getSelectGameButton(themeData: themeData),
            ),
          ],
        ),
      ),
    );
  }

  Widget getGameImageWidget() {
    return CommonCachedNetworkImage(
      height: 106,
      width: 134,
      imageUrl: gameModel.thumbnailImage,
    );
  }

  Widget getSelectGameButton({required ThemeData themeData}) {
    if (!isShowGameSelectionButton) {
      return const SizedBox();
    }

    if (isGameAdded) {
      return CommonButton1(
        width: 80,
        text: "",
        rowWidget: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check,
              color: Styles.buttonPinkColor,
              size: 15,
            ),
            const SizedBox(
              width: 2,
            ),
            CommonText(
              text: "Added",
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Styles.buttonPinkColor,
            )
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 5),
        backgroundColor: Styles.buttonVioletColor,
        textColor: Styles.buttonPinkColor,
        onTap: () {
          if (onGameSelectedButtonTap != null) {
            onGameSelectedButtonTap!(gameModel);
          }
        },
      );
    } else {
      return CommonButton1(
        width: 80,
        rowWidget: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: Styles.discountTextColor, size: 15),
            const SizedBox(
              width: 2,
            ),
            CommonText(
              text: "Add",
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Styles.discountTextColor,
            )
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 5),
        borderColor: Styles.discountTextColor,
        backgroundColor: Styles.buttonPinkColor,
        textColor: Styles.discountTextColor,
        text: "Add",
        onTap: () {
          if (onGameNotSelectedButtonTap != null) {
            onGameNotSelectedButtonTap!(gameModel);
          }
        },
      );
    }
  }

  //endregion

  //region Game Details Widget
  Widget getGameDetailsWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CommonText(
          text: gameModel.name,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        SizedBox(
          height: 9,
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CommonText(
              text: "4",
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            Icon(
              Icons.star,
              color: Styles.starColor,
              size: 15,
            )
          ],
        ),
        SizedBox(
          height: 9,
        ),
        ReadMoreText(
          gameModel.description,
          style: TextStyle(fontWeight: FontWeight.w300, fontSize: 13, letterSpacing: 0.2, color: Styles.textWhiteColor, height: 1.27),
          textAlign: TextAlign.justify,
          trimMode: TrimMode.Line,
          trimLines: 3,
          trimCollapsedText: "Read More",
          trimExpandedText: "",
          moreStyle: TextStyle(color: Styles.readMoreTextColor, decoration: TextDecoration.underline),
        ),
      ],
    );
  }
//endregion
}
