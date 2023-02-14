import 'package:okoto/configs/constants.dart';
import 'package:okoto/model/common/new_document_data_model.dart';
import 'package:okoto/model/order/order_model.dart';
import 'package:okoto/utils/my_print.dart';
import 'package:okoto/utils/my_utils.dart';

class OrderRepository {
  Future<bool> createOrderInFirestoreFromOrderModel({required OrderModel orderModel}) async {
    String tag = MyUtils.getUniqueIdFromUuid();
    MyPrint.printOnConsole("OrderRepository().createOrderInFirestoreFromOrderModel() called with orderModel:'$orderModel'", tag: tag);

    bool isCreated = false;

    if(orderModel.id.isEmpty) {
      return isCreated;
    }

    try {
      NewDocumentDataModel newDocumentDataModel = await MyUtils.getNewDocIdAndTimeStamp(isGetTimeStamp: true);
      orderModel.createdTime = newDocumentDataModel.timestamp;

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