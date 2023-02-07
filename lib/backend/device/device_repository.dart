import 'package:okoto/configs/constants.dart';
import 'package:okoto/configs/typedefs.dart';
import 'package:okoto/model/device/device_model.dart';
import 'package:okoto/utils/my_print.dart';
import 'package:okoto/utils/my_utils.dart';

class DeviceRepository {
  Future<List<DeviceModel>> getUserDevicesList({required String userId}) async {
    String tag = MyUtils.getUniqueIdFromUuid();
    MyPrint.printOnConsole('DeviceRepository().getUserDevicesList() called with userId:$userId', tag: tag);

    List<DeviceModel> devices = <DeviceModel>[];

    if(userId.isEmpty) {
      return devices;
    }

    try {
      MyFirestoreQuerySnapshot querySnapshot = await FirebaseNodes.devicesCollectionReference
        .where("accessibleUsers", arrayContains: userId)
        .where("adminEnabled", isEqualTo: true)
        .get();
      MyPrint.printOnConsole("Devices querySnapshot length:${querySnapshot.size}", tag: tag);

      if(querySnapshot.docs.isNotEmpty) {
        for (MyFirestoreQueryDocumentSnapshot queryDocumentSnapshot in querySnapshot.docs) {
          if(queryDocumentSnapshot.data().isNotEmpty) {
            devices.add(DeviceModel.fromMap(queryDocumentSnapshot.data()));
          }
          else {
            MyPrint.printOnConsole("Device Document Empty for Document Id:${queryDocumentSnapshot.id}", tag: tag);
          }
        }
      }
      MyPrint.printOnConsole("Final Devices length:${devices.length}", tag: tag);
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in DeviceRepository().getUserDevicesList():$e", tag: tag);
      MyPrint.printOnConsole(s);
    }

    return devices;
  }

  Future<bool> updateDeviceDataFromMap({required String deviceId, required Map<String, dynamic> data}) async {
    String tag = MyUtils.getUniqueIdFromUuid();
    MyPrint.printOnConsole('DeviceRepository().updateDeviceDataFromMap() called with deviceId:$deviceId', tag: tag);

    bool isUpdated = false;

    try {
      await FirebaseNodes.deviceDocumentReference(deviceId: deviceId).update(data);

      MyPrint.printOnConsole("Device Data Updated", tag: tag);
      isUpdated = true;
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in Updating Device Data From Map in DeviceRepository().updateDeviceDataFromMap():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
    }

    MyPrint.printOnConsole("Value of isUpdated:$isUpdated", tag: tag);

    return isUpdated;
  }
}