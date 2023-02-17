import 'package:okoto/configs/typedefs.dart';
import 'package:okoto/model/order/order_model.dart';

class OrdersResponseModel {
  List<OrderModel> orders;
  MyFirestoreDocumentSnapshot? lastDocumentSnapshot;

  OrdersResponseModel({
    required this.orders,
    this.lastDocumentSnapshot,
  });
}