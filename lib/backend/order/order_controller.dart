import 'package:okoto/configs/constants.dart';
import 'package:okoto/model/order/order_model.dart';
import 'package:okoto/model/product/product_model.dart';
import 'package:okoto/model/subscription/subscription_model.dart';
import 'package:okoto/utils/my_print.dart';
import 'package:okoto/utils/my_utils.dart';

import 'order_provider.dart';
import 'order_repository.dart';

class OrderController {
  late OrderProvider _orderProvider;
  late OrderRepository _orderRepository;

  OrderController({required OrderProvider? orderProvider, OrderRepository? orderRepository}) {
    _orderProvider = orderProvider ?? OrderProvider();
    _orderRepository = orderRepository ?? OrderRepository();
  }

  OrderProvider get orderProvider => _orderProvider;

  Future<bool> createOrderForSubscription({required SubscriptionModel subscriptionModel, required String paymentId, required String paymentMode,
    required String paymentStatus, required double amount}) async {
    String tag = MyUtils.getUniqueIdFromUuid();
    MyPrint.printOnConsole("OrderController().createOrderForSubscription() called with subscriptionModel:'$subscriptionModel', paymentId:'$paymentId', "
        "paymentMode:'$paymentMode', paymentStatus:'$paymentStatus', amount:'$amount'", tag: tag);

    bool isOrderForSubscriptionCreated = false;

    OrderModel orderModel = OrderModel(
      id: MyUtils.getUniqueIdFromUuid(),
      type: OrderType.subscription,
      paymentId: paymentId,
      paymentMode: paymentMode,
      paymentStatus: paymentStatus,
      amount: amount,
      subscriptionOrderDataModel: subscriptionModel,
    );

    isOrderForSubscriptionCreated = await _orderRepository.createOrderInFirestoreFromOrderModel(orderModel: orderModel);

    MyPrint.printOnConsole("isOrderForSubscriptionCreated:'$isOrderForSubscriptionCreated'", tag: tag);

    return isOrderForSubscriptionCreated;
  }

  Future<bool> createOrderForProduct({required ProductModel productModel, required String paymentId, required String paymentMode,
    required String paymentStatus, required double amount}) async {
    String tag = MyUtils.getUniqueIdFromUuid();
    MyPrint.printOnConsole("OrderController().createOrderForProduct() called with productModel:'$productModel', paymentId:'$paymentId', "
        "paymentMode:'$paymentMode', paymentStatus:'$paymentStatus', amount:'$amount'", tag: tag);

    bool isOrderForProductCreated = false;

    OrderModel orderModel = OrderModel(
      id: MyUtils.getUniqueIdFromUuid(),
      type: OrderType.product,
      paymentId: paymentId,
      paymentMode: paymentMode,
      paymentStatus: paymentStatus,
      amount: amount,
      productOrderDataModel: productModel,
    );

    isOrderForProductCreated = await _orderRepository.createOrderInFirestoreFromOrderModel(orderModel: orderModel);

    MyPrint.printOnConsole("isOrderForProductCreated:'$isOrderForProductCreated'", tag: tag);

    return isOrderForProductCreated;
  }
}