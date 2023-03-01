import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:okoto/backend/navigation/navigation.dart';
import 'package:okoto/backend/order/order_controller.dart';
import 'package:okoto/configs/dotted_line.dart';
import 'package:okoto/model/game/game_model.dart';
import 'package:okoto/model/order/order_model.dart';
import 'package:okoto/model/order/subscription_order_data_model.dart';
import 'package:okoto/model/subscription/subscription_model.dart';
import 'package:okoto/utils/date_presentation.dart';
import 'package:okoto/view/common/components/common_appbar.dart';
import 'package:okoto/view/common/components/my_screen_background.dart';

import '../../../backend/game/game_controller.dart';
import '../../../configs/styles.dart';
import '../../../utils/my_utils.dart';
import '../../common/components/common_cachednetwork_image.dart';
import '../../common/components/common_text.dart';

class OrderDetailScreen extends StatefulWidget {
  static const String routeName = "/orderDetailScreen";
  PaymentDetailScreenNavigationArguments arguments;

  OrderDetailScreen({Key? key, required this.arguments}) : super(key: key);

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late OrderModel orderModel;
  List<GameModel> gameModels = [];
  List<String> selectedGamesList = <String>[];

  Future? getFuture;

  Future<void> getData() async {
    orderModel = widget.arguments.orderModel!;
    // orderModel.subscriptionModel ??= await subscriptionController.subscriptionRepository.getSubscriptionModelFromId(subscriptionId: subscriptionId);

    if (orderModel != null) {
      SubscriptionOrderDataModel model = orderModel.subscriptionOrderDataModel!;

      int gamesLength = model.selectedGamesList.length;
      if (gamesLength > 0 && model.subscriptionModel!.requiredGamesCount == gamesLength) {
        selectedGamesList.addAll(model.selectedGamesList);
        // isEnableGameSelection = false;
      }

      gameModels = await GameController(gameProvider: null).gameRepository.getGameModelsListFromIdsList(idsList: model.selectedGamesList);
    }
  }

  double getDiscountedValue(double discountedPrice, double originalPrice) {
    double discountedValue = originalPrice - discountedPrice;
    return discountedValue;
  }

  @override
  void initState() {
    super.initState();
    orderModel = widget.arguments.orderModel!;
    getFuture = getData();
  }

  @override
  Widget build(BuildContext context) {
    return MyScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const CommonAppBar(text: "Payment Details"),
        body: mainBodyWidget(),
      ),
    );
  }

  Widget mainBodyWidget() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: Column(
          children: [
            SizedBox(height: 25,),
            getNameTransactionWidget(orderModel.subscriptionOrderDataModel!, orderModel),
            SizedBox(height: 25,),
            transactionStatusAndDoneByWidget(orderModel),
            SizedBox(height: 25,),
            getGameAddedWidget(),
            SizedBox(height: 40,),
            getSubTotalWidget()
          ],
        ),
      ),
    );
  }

  Widget getNameTransactionWidget(SubscriptionOrderDataModel subscriptionModel, OrderModel orderModel) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Card(elevation: 8, child: getImage(url: subscriptionModel.subscriptionModel?.image ?? "")),
        const SizedBox(
          width: 20,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CommonText(
                text: subscriptionModel.subscriptionModel?.name ?? "",
                fontWeight: FontWeight.w700,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
              const SizedBox(
                height: 10,
              ),
              CommonText(
                text: "Transaction Date: ${DatePresentation.ddMMyyyySlashFormatter(orderModel.createdTime!)}",
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              )
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

  //region transactionStatusAndDoneByWidget
  Widget transactionStatusAndDoneByWidget(OrderModel orderModel) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          getHeaderWithValue(headerText: "Transaction done by:", value: orderModel.paymentMode),
          getHeaderWithValue(headerText: "Transaction Status:", value: orderModel.paymentStatus)
        ],
      ),
    );
  }

  Widget getHeaderWithValue({required String headerText, required String value}) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: headerText,
        style: const TextStyle(fontStyle: FontStyle.normal, height: 1.5),
        children: [
          TextSpan(
            text: "\n$value",
            style: TextStyle(
              color: Styles.textWhiteColor,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  //endregion

  //region gameAddedWidget
  Widget getGameAddedWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        getDottedTitleWidget("Games Added"),
        const SizedBox(height: 23),
        getGameListBuilder(),
      ],
    );
  }

  Widget getDottedTitleWidget(String title) {
    return Container(
      child: Row(
        children: [
          const Expanded(
              child: DottedLine(
            dashColor: Colors.white,
            dashGapLength: 2.5,
          )),
          CommonText(
            text: " $title ",
            letterSpacing: .2,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
          const Expanded(
              child: DottedLine(
            dashColor: Colors.white,
            dashGapLength: 2.5,
          )),
        ],
      ),
    );
  }

  Widget getGameListBuilder() {
    return FutureBuilder(
        future: getFuture,
        builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
          if (asyncSnapshot.connectionState == ConnectionState.done) {
            return SizedBox(
              height: 144,
              child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: gameModels.length,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (BuildContext context, int index) {
                    return getGameListComponent(gameModels[index]);
                  }),
            );
          } else {
            return const SpinKitCircle(
              color: Colors.white,
            );
          }
        });
  }

  Widget getGameListComponent(GameModel gameModel) {
    return Container(
      width: 134,
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(right: 32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
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
          getImage(url: gameModel.thumbnailImage, height: 76, width: 134),
          const SizedBox(
            height: 9,
          ),
          CommonText(
            text: gameModel.name,
            maxLines: 1,
            textOverFlow: TextOverflow.ellipsis,
            fontSize: 12,
            letterSpacing: .2,
            fontWeight: FontWeight.w600,
          ),
          const SizedBox(
            height: 9,
          ),
          Row(
            children: [
              const CommonText(text: "4", fontSize: 11),
              Icon(
                Icons.star,
                color: Styles.starColor,
                size: 11,
              )
            ],
          )
        ],
      ),
    );
  }

//endregion

//region subTotalWidget
  Widget getSubTotalWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        getDottedTitleWidget("Subtotal"),
        const SizedBox(height: 26,),
        getKeyValueInRowWidget(key: "Price", value: "Rs ${orderModel.subscriptionOrderDataModel!.subscriptionModel!.price}"),
        const SizedBox(height: 20,),

        getKeyValueInRowWidget(
            key: "Discount",
            value:
                "- Rs ${getDiscountedValue(orderModel.subscriptionOrderDataModel!.subscriptionModel!.discountedPrice, orderModel.subscriptionOrderDataModel!.subscriptionModel!.price)}"),
        const SizedBox(height: 20,),
        const DottedLine(dashColor: Colors.white, dashGapLength: 2),
        const SizedBox(height: 20,),
        getKeyValueInRowWidget(key: "Total Amount", value: "Rs ${orderModel.subscriptionOrderDataModel!.subscriptionModel!.discountedPrice}"),
        const SizedBox(height: 20,),
        const DottedLine(
          dashColor: Colors.white,
          dashGapLength: 0,
        ),
        const SizedBox(height: 20,),
        CommonText(
          text:
              "You saved Rs ${getDiscountedValue(orderModel.subscriptionOrderDataModel!.subscriptionModel!.discountedPrice, orderModel.subscriptionOrderDataModel!.subscriptionModel!.price)} on this order",
          fontStyle: FontStyle.italic,
          letterSpacing: .2,
          fontSize: 12,
        )
      ],
    );
  }

  Widget getKeyValueInRowWidget({String key = "", String value = ""}) {
    return Row(
      children: [
        Expanded(
            child: CommonText(
          text: key,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        )),
        CommonText(
          text: value,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ],
    );
  }
//endregion
}
