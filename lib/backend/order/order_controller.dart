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


}