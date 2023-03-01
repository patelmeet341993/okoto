import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:okoto/backend/navigation/navigation.dart';
import 'package:okoto/model/order/order_model.dart';
import 'package:okoto/model/product/product_model.dart';
import 'package:okoto/utils/date_presentation.dart';
import 'package:okoto/view/common/components/common_button1.dart';
import 'package:okoto/view/common/components/common_text.dart';

import '../../../backend/navigation/navigation_controller.dart';
import '../../../backend/navigation/navigation_operation_parameters.dart';
import '../../../backend/navigation/navigation_type.dart';
import '../../../configs/styles.dart';
import '../../../model/order/subscription_order_data_model.dart';

class OrderCard extends StatelessWidget {
  final OrderModel orderModel;
  final Map<int, List<OrderModel>> orderMap;

  const OrderCard({Key? key, required this.orderModel, this.orderMap = const {}}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () async {
        await NavigationController.navigateToPaymentDetailScreen(
          navigationOperationParameters: NavigationOperationParameters(
            context: context,
            navigationType: NavigationType.pushNamed,
          ),
          arguments: PaymentDetailScreenNavigationArguments(
            orderId: orderModel.id,
            orderModel: orderModel,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 18,
        ).copyWith(top: 25),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          child: Container(
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              child: Column(
                children: [
                  getSubscriptionWidget(subscriptionOrderDataModel: orderModel.subscriptionOrderDataModel, orderModel: orderModel),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CommonText(
                          text: "By: ${orderModel.paymentMode}",
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          letterSpacing: .2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      statusButton(orderModel)
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget statusButton(OrderModel orderModel) {
    bool status = orderModel.paymentStatus == "Completed";
    return CommonButton1(
      text: orderModel.paymentStatus,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      backgroundColor: status ? Styles.successStatusBackGround : Styles.failedStatusBackGround,
      textColor: status ? Styles.successStatusText : Styles.failedStatusText,
      textSize: 11,
    );
  }

  Widget getSubscriptionWidget({required SubscriptionOrderDataModel? subscriptionOrderDataModel, OrderModel? orderModel}) {
    if (subscriptionOrderDataModel?.subscriptionModel == null) {
      return const SizedBox();
    }

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonText(
                text: subscriptionOrderDataModel?.subscriptionModel?.name ?? "",
                fontSize: 16,
                letterSpacing: .2,
                fontWeight: FontWeight.w700,
              ),
              const SizedBox(height: 4,),
              CommonText(
                text: DatePresentation.ddMMyyyySlashFormatter(orderModel!.createdTime!),
                fontSize: 14,
                letterSpacing: .2,
                fontWeight: FontWeight.w500,
              )
            ],
          ),
        ),
        CommonText(
          text: subscriptionOrderDataModel?.subscriptionModel?.discountedPrice == 0
              ? "Rs. ${subscriptionOrderDataModel?.subscriptionModel?.price}"
              : "Rs. ${subscriptionOrderDataModel?.subscriptionModel?.discountedPrice}",
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ],
    );
  }

  Widget getProductWidget({required ProductModel? productModel}) {
    if (productModel == null) {
      return const SizedBox();
    }

    return Text("Product:${productModel.name}");
  }



}
