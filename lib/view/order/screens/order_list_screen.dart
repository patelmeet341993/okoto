import 'package:flutter/material.dart';
import 'package:okoto/backend/order/order_controller.dart';
import 'package:okoto/backend/order/order_provider.dart';
import 'package:okoto/backend/user/user_provider.dart';
import 'package:okoto/configs/constants.dart';
import 'package:okoto/model/order/order_model.dart';
import 'package:okoto/utils/date_presentation.dart';
import 'package:okoto/view/common/components/common_appbar.dart';
import 'package:okoto/view/common/components/common_loader.dart';
import 'package:okoto/view/common/components/my_screen_background.dart';
import 'package:okoto/view/order/components/order_card.dart';
import 'package:provider/provider.dart';

import '../../../utils/my_print.dart';
import '../../common/components/common_text.dart';
import '../../common/components/modal_progress_hud.dart';

class OrderListScreen extends StatefulWidget {
  static const String routeName = "/OrderListScreen";

  const OrderListScreen({Key? key}) : super(key: key);

  @override
  State<OrderListScreen> createState() => _OrderListSceenState();
}

class _OrderListSceenState extends State<OrderListScreen> {
  late ThemeData themeData;

  bool isLoading = false;

  String userId = "";

  late OrderProvider orderProvider;
  late OrderController orderController;

  Future<void> getData({bool isRefresh = true, bool isNotify = true}) async {
    await orderController.getOrdersList(
      userId: userId,
      isRefresh: isRefresh,
      isNotify: isNotify,
    );
  }

  @override
  void initState() {
    super.initState();

    userId = context.read<UserProvider>().getUserId();

    orderProvider = context.read<OrderProvider>();
    orderController = OrderController(orderProvider: orderProvider);

    getData(
      isRefresh: false,
      isNotify: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    themeData = Theme.of(context);

    return MyScreenBackground(
      child: ChangeNotifierProvider<OrderProvider>.value(
        value: orderProvider,
        child: Consumer<OrderProvider>(
          builder: (BuildContext context, OrderProvider orderProvider, Widget? child) {
            return ModalProgressHUD(
              inAsyncCall: isLoading,
              child: Scaffold(
                backgroundColor: Colors.transparent,
                appBar: const CommonAppBar(text: "Payment History"),
                body: getMainBody(orderProvider: orderProvider),
              ),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget getAppBar() {
    return AppBar(
      title: const Text("Orders"),
    );
  }

  Widget getMainBody({required OrderProvider orderProvider}) {
    if (orderProvider.isOrdersFirstTimeLoading) {
      return const CommonLoader(
        isCenter: true,
      );
    }

    if (!orderProvider.isOrdersLoading && orderProvider.ordersLength == 0) {
      return RefreshIndicator(
        onRefresh: () async {
          getData(
            isRefresh: true,
            isNotify: true,
          );
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
            ),
            const Center(
              child: Text("No Orders"),
            ),
          ],
        ),
      );
    }

    List<OrderModel> orders = orderProvider.getOrders(isNewInstance: false);
    int ordersLength = orders.length + 1;
    return RefreshIndicator(
      onRefresh: () async {
        getData(
          isRefresh: true,
          isNotify: true,
        );
      },
      color: themeData.primaryColor,
      backgroundColor: themeData.scaffoldBackgroundColor,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: ordersLength,
        itemBuilder: (BuildContext context, int index) {
          if (ordersLength == 0 || index == ordersLength - 1) {
            if (orderProvider.isOrdersLoading) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: const CommonLoader(
                  isCenter: true,
                  size: 50,
                ),
              );
            } else {
              return null;
            }
          }

          OrderModel orderModel = orders[index];

          if (index >= (ordersLength - AppConfigurations.ordersRefreshLimit) && (!orderProvider.isOrdersLoading && orderProvider.hasMoreOrders)) {
            getData(isRefresh: false, isNotify: false);
          }

          String key = "${orderModel.createdTime!.toDate().month}${orderModel.createdTime!.toDate().year}";
          MyPrint.printOnConsole("$key ${orderProvider.ordersMapWithMonthYear[key] == orderModel.id}");
          String month = orderModel.createdTime!.toDate().month == DateTime.now().month ? "This" : DatePresentation.MMyyyy(orderModel.createdTime!);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              orderProvider.ordersMapWithMonthYear[key] == orderModel.id
                  ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10),
                child: CommonText(
                        text: month,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        letterSpacing: .2,
                      ),
                  )
                  : const Text(""),
              OrderCard(orderModel: orderModel)
            ],
          );
        },
      ),
    );
  }
}
