import 'package:flutter/material.dart';
import 'package:okoto/model/order/order_model.dart';
import 'package:okoto/model/product/product_model.dart';
import 'package:okoto/model/subscription/subscription_model.dart';

class OrderCard extends StatelessWidget {
  final OrderModel orderModel;

  const OrderCard({Key? key, required this.orderModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Card(
        child: Column(
          children: [
            Text(orderModel.id),
            Text(orderModel.userId),
            Text("Price: \$${orderModel.amount}"),
            Text("type: ${orderModel.type}"),
            Text("Date: ${orderModel.createdTime?.toDate().toString()}"),
            Text("paymentStatus: ${orderModel.paymentStatus}"),
            Text("paymentMode: ${orderModel.paymentMode}"),
            Text("paymentId: ${orderModel.paymentId}"),
            getSubscriptionWidget(subscriptionModel: orderModel.subscriptionOrderDataModel),
            getProductWidget(productModel: orderModel.productOrderDataModel),
          ],
        ),
      ),
    );
  }

  Widget getSubscriptionWidget({required SubscriptionModel? subscriptionModel}) {
    if(subscriptionModel == null) {
      return const SizedBox();
    }

    return Text("Subscription:${subscriptionModel.name}");
  }

  Widget getProductWidget({required ProductModel? productModel}) {
    if(productModel == null) {
      return const SizedBox();
    }

    return Text("Product:${productModel.name}");
  }
}
