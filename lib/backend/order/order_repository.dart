import 'package:okoto/configs/constants.dart';
import 'package:okoto/model/common/new_document_data_model.dart';
import 'package:okoto/model/order/order_model.dart';
import 'package:okoto/utils/extensions.dart';
import 'package:okoto/utils/my_print.dart';
import 'package:okoto/utils/my_utils.dart';

import '../../configs/typedefs.dart';
import '../../model/order/orders_response_model.dart';

class OrderRepository {
  Future<OrdersResponseModel> getPaginatedOrdersListUserwise({
    required String userId,
    required MyFirestoreDocumentSnapshot? lastDocumentSnapshot,
    required int documentLimit,
  }) async {
    String tag = MyUtils.getUniqueIdFromUuid();
    MyPrint.printOnConsole("OrderRepository().getOrdersListUserwise() called with userId:'$userId'", tag: tag);

    List<OrderModel> orders = <OrderModel>[];
    MyFirestoreDocumentSnapshot? newLastDocumentSnapshot;

    if(userId.isEmpty) {
      return OrdersResponseModel(
        orders: orders,
        lastDocumentSnapshot: newLastDocumentSnapshot,
      );
    }

    try {

      MyFirestoreQuery query = FirebaseNodes.ordersCollectionReference
          .where("userId", isEqualTo: userId)
          .orderBy("createdTime", descending: true)
          .limit(documentLimit);

      if(lastDocumentSnapshot != null) {
        query = query.startAfterDocument(lastDocumentSnapshot);
      }

      MyFirestoreQuerySnapshot querySnapshot = await query.get();
      MyPrint.printOnConsole("Orders querySnapshot length:${querySnapshot.size}", tag: tag);

      newLastDocumentSnapshot = querySnapshot.docs.lastElement;

      if(querySnapshot.docs.isNotEmpty) {
        for (MyFirestoreQueryDocumentSnapshot queryDocumentSnapshot in querySnapshot.docs) {
          if(queryDocumentSnapshot.data().isNotEmpty) {
            orders.add(OrderModel.fromMap(queryDocumentSnapshot.data()));
          }
          else {
            MyPrint.printOnConsole("Subscriptions Document Empty for Document Id:${queryDocumentSnapshot.id}", tag: tag);
          }
        }
      }
      MyPrint.printOnConsole("Final Orders length:${orders.length}", tag: tag);
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in OrderRepository().getAllSubscriptionsList():$e", tag: tag);
      MyPrint.printOnConsole(s);
    }

    OrdersResponseModel ordersResponseModel = OrdersResponseModel(
      orders: orders,
      lastDocumentSnapshot: newLastDocumentSnapshot,
    );

    return ordersResponseModel;
  }

  Future<bool> createOrderInFirestoreFromOrderModel({required OrderModel orderModel}) async {
    String tag = MyUtils.getUniqueIdFromUuid();
    MyPrint.printOnConsole("OrderRepository().createOrderInFirestoreFromOrderModel() called with orderModel:'$orderModel'", tag: tag);

    bool isCreated = false;

    if(orderModel.id.isEmpty) {
      return isCreated;
    }

    try {
      if(orderModel.createdTime == null) {
        NewDocumentDataModel newDocumentDataModel = await MyUtils.getNewDocIdAndTimeStamp(isGetTimeStamp: true);
        orderModel.createdTime = newDocumentDataModel.timestamp;
      }

      await FirebaseNodes.orderDocumentReference(orderId: orderModel.id).set(orderModel.toMap());
      isCreated = true;
      MyPrint.printOnConsole("Order Created", tag: tag);
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in Creating Order in OrderRepository().createOrderInFirestoreFromOrderModel():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
    }

    MyPrint.printOnConsole("isCreated:$isCreated", tag: tag);

    return isCreated;
  }
}