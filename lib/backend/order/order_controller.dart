import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:okoto/configs/constants.dart';
import 'package:okoto/model/order/order_model.dart';
import 'package:okoto/model/order/orders_response_model.dart';
import 'package:okoto/model/order/subscription_order_data_model.dart';
import 'package:okoto/model/product/product_model.dart';
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

  Future<void> getOrdersList({bool isRefresh = true, required String userId, bool isNotify = true}) async {
    String tag = MyUtils.getUniqueIdFromUuid();
    MyPrint.printOnConsole("OrderController().getOrdersList() called with, isRefresh:$isRefresh, userId:'$userId', isNotify:$isNotify", tag: tag);

    OrderProvider provider = orderProvider;
    OrderRepository repository = _orderRepository;

    try {
      if (isRefresh) {
        provider.setOrders(orders: [], isClear: true, isNotify: false);
        provider.setIsOrdersFirstTimeLoading(value: true, isNotify: false);
        provider.setIsOrdersLoading(value: false, isNotify: false);
        provider.setHasMoreOrders(value: true, isNotify: false);
        provider.setLastOrderDocumentSnapshot(snapshot: null, isNotify: isNotify);
        provider.setOrdersMapWithMonthYear({}, isClear: true,isNotify: true);

      }

      if (userId.isEmpty) {
        MyPrint.printOnConsole("User Id is empty");
        return;
      }

      MyPrint.printOnConsole("isOrdersLoading:${orderProvider.isOrdersLoading}");
      MyPrint.printOnConsole("hasMoreOrders:${orderProvider.hasMoreOrders}");

      if (provider.isOrdersLoading || !provider.hasMoreOrders) {
        return;
      }

      MyPrint.printOnConsole("ordersLength in orderProvider:${provider.ordersLength}", tag: tag);

      provider.setIsOrdersLoading(value: true, isNotify: isNotify);

      // await Future.delayed(const Duration(seconds: 4));

      OrdersResponseModel ordersResponseModel = await repository.getPaginatedOrdersListUserwise(
        userId: userId,
        lastDocumentSnapshot: provider.lastOrderDocumentSnapshot,
        documentLimit: AppConfigurations.ordersDocumentLimit,
      );
      List<OrderModel> orders = ordersResponseModel.orders;
      MyPrint.printOnConsole("order Models length:${orders.length}", tag: tag);

      provider.setHasMoreOrders(value: orders.length == AppConfigurations.ordersDocumentLimit, isNotify: false);
      provider.setLastOrderDocumentSnapshot(snapshot: ordersResponseModel.lastDocumentSnapshot, isNotify: false);

      provider.setOrders(orders: orders, isClear: false, isNotify: false);
      provider.setIsOrdersFirstTimeLoading(value: false, isNotify: true);
      provider.setIsOrdersLoading(value: false, isNotify: true);

      Map<String, String> orderMapWithYearMonth = getMapOfMonthYearFromList(provider.getOrders(isNewInstance: true));
      provider.setOrdersMapWithMonthYear(orderMapWithYearMonth, isClear: true, isNotify: true);
    } catch (e, s) {
      MyPrint.printOnConsole("Error in OrderController().getOrdersList():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);

      provider.setHasMoreOrders(value: true, isNotify: false);
      provider.setLastOrderDocumentSnapshot(snapshot: null, isNotify: false);
      provider.setOrders(orders: <OrderModel>[], isClear: true, isNotify: false);
      provider.setIsOrdersFirstTimeLoading(value: false, isNotify: true);
      provider.setIsOrdersLoading(value: false, isNotify: true);
      provider.setOrdersMapWithMonthYear({}, isClear: true,isNotify: true);
    }

    MyPrint.printOnConsole("OrderController().getOrdersList() Finished", tag: tag);
  }

  Map<String, String> getMapOfMonthYearFromList(List<OrderModel> orders){
    Map<String, String> orderMapWithYearMonth = {};
    for (OrderModel item in orders) {
      if (item.createdTime != null) {
        String key = "${item.createdTime!.toDate().month}${item.createdTime!.toDate().year}";
        if(!orderMapWithYearMonth.containsKey(key)) {
          orderMapWithYearMonth[key] = item.id;
        }
      }
    }
    return orderMapWithYearMonth;
  }

  Future<bool> createOrderForSubscription({
    required SubscriptionOrderDataModel subscriptionOrderDataModel,
    required String userId,
    required String paymentId,
    required String paymentMode,
    required String paymentStatus,
    required double amount,
    Timestamp? createdTime,
  }) async {
    String tag = MyUtils.getUniqueIdFromUuid();
    MyPrint.printOnConsole(
        "OrderController().createOrderForSubscription() called with subscriptionOrderDataModel:'$subscriptionOrderDataModel', paymentId:'$paymentId', "
        "paymentMode:'$paymentMode', paymentStatus:'$paymentStatus', amount:'$amount'",
        tag: tag);

    bool isOrderForSubscriptionCreated = false;

    OrderModel orderModel = OrderModel(
      id: MyUtils.getUniqueIdFromUuid(),
      type: OrderType.subscription,
      paymentId: paymentId,
      paymentMode: paymentMode,
      paymentStatus: paymentStatus,
      amount: amount,
      subscriptionOrderDataModel: subscriptionOrderDataModel,
      userId: userId,
      createdTime: createdTime,
    );

    isOrderForSubscriptionCreated = await _orderRepository.createOrderInFirestoreFromOrderModel(orderModel: orderModel);

    MyPrint.printOnConsole("isOrderForSubscriptionCreated:'$isOrderForSubscriptionCreated'", tag: tag);

    return isOrderForSubscriptionCreated;
  }

  Future<bool> createOrderForProduct({
    required ProductModel productModel,
    required String userId,
    required String paymentId,
    required String paymentMode,
    required String paymentStatus,
    required double amount,
  }) async {
    String tag = MyUtils.getUniqueIdFromUuid();
    MyPrint.printOnConsole(
        "OrderController().createOrderForProduct() called with productModel:'$productModel', paymentId:'$paymentId', "
        "paymentMode:'$paymentMode', paymentStatus:'$paymentStatus', amount:'$amount'",
        tag: tag);

    bool isOrderForProductCreated = false;

    OrderModel orderModel = OrderModel(
      id: MyUtils.getUniqueIdFromUuid(),
      type: OrderType.product,
      paymentId: paymentId,
      paymentMode: paymentMode,
      paymentStatus: paymentStatus,
      amount: amount,
      productOrderDataModel: productModel,
      userId: userId,
    );

    isOrderForProductCreated = await _orderRepository.createOrderInFirestoreFromOrderModel(orderModel: orderModel);

    MyPrint.printOnConsole("isOrderForProductCreated:'$isOrderForProductCreated'", tag: tag);

    return isOrderForProductCreated;
  }
}
