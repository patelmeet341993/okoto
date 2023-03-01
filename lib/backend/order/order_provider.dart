import 'package:okoto/backend/common/common_provider.dart';
import 'package:okoto/configs/typedefs.dart';
import 'package:okoto/model/order/order_model.dart';

class OrderProvider extends CommonProvider {
  //region All Orders
  //region All Order Models List
  final List<OrderModel> _orders = <OrderModel>[];

  List<OrderModel> getOrders({bool isNewInstance = true}) {
    if(isNewInstance) {
      return _orders.map((e) => OrderModel.fromMap(e.toMap())).toList();
    }
    else {
      return _orders;
    }
  }

  int get ordersLength => _orders.length;

  void setOrders({required List<OrderModel> orders, bool isClear = true, bool isNotify = true}) {
    if(isClear) {
      _orders.clear();
    }
    _orders.addAll(orders);
    notify(isNotify: isNotify);
  }
  //endregion

  //region Is Order Models First Time Loading
  bool _isOrdersFirstTimeLoading = false;

  bool get isOrdersFirstTimeLoading => _isOrdersFirstTimeLoading;

  void setIsOrdersFirstTimeLoading({required bool value, bool isNotify = true}) {
    _isOrdersFirstTimeLoading = value;
    notify(isNotify: isNotify);
  }
  //endregion

  //region Is Order Models Loading
  bool _isOrdersLoading = false;

  bool get isOrdersLoading => _isOrdersLoading;

  void setIsOrdersLoading({required bool value, bool isNotify = true}) {
    _isOrdersLoading = value;
    notify(isNotify: isNotify);
  }
  //endregion

  //region Has More Orders
  bool _hasMoreOrders = true;

  bool get hasMoreOrders => _hasMoreOrders;

  void setHasMoreOrders({required bool value, bool isNotify = true}) {
    _hasMoreOrders = value;
    notify(isNotify: isNotify);
  }
  //endregion

  //region Last Order Snapshot
  MyFirestoreDocumentSnapshot? _lastOrderDocumentSnapshot;

  MyFirestoreDocumentSnapshot? get lastOrderDocumentSnapshot => _lastOrderDocumentSnapshot;

  void setLastOrderDocumentSnapshot({required MyFirestoreDocumentSnapshot? snapshot, bool isNotify = true}) {
    _lastOrderDocumentSnapshot = snapshot;
    notify(isNotify: isNotify);
  }
  //endregion
  //endregion

  //region to show the list month wise
    final Map<String, String> _ordersMapWithMonthYear = {};

    void setOrdersMapWithMonthYear(Map<String, String> ordersMapWithMonthYear, {bool isClear = true, bool isNotify = true}){
      if(isClear) _ordersMapWithMonthYear.clear();
      _ordersMapWithMonthYear.addAll(ordersMapWithMonthYear);
      if(isNotify){
        notifyListeners();
      }
    }

    Map<String,String> get ordersMapWithMonthYear => _ordersMapWithMonthYear;
  //endregion
}