import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:okoto/backend/device/device_provider.dart';
import 'package:okoto/backend/device/device_repository.dart';
import 'package:okoto/backend/user/user_repository.dart';
import 'package:okoto/configs/constants.dart';
import 'package:okoto/configs/typedefs.dart';
import 'package:okoto/model/device/device_model.dart';
import 'package:okoto/utils/extensions.dart';
import 'package:okoto/utils/my_print.dart';
import 'package:okoto/utils/my_toast.dart';
import 'package:okoto/utils/my_utils.dart';

import '../analytics/analytics_controller.dart';
import '../analytics/analytics_event.dart';

class DeviceController {
  late DeviceProvider _deviceProvider;
  late DeviceRepository _deviceRepository;

  DeviceController({required DeviceProvider? deviceProvider, DeviceRepository? deviceRepository}) {
    _deviceProvider = deviceProvider ?? DeviceProvider();
    _deviceRepository = deviceRepository ?? DeviceRepository();
  }

  DeviceProvider get deviceProvider => _deviceProvider;

  Future<void> getUserDevicesList({required String userId, bool isRefresh = true, bool isNotify = true}) async {
    String tag = MyUtils.getUniqueIdFromUuid();
    MyPrint.printOnConsole("DeviceController().getUserDevicesList() called with userId:$userId, isRefresh:$isRefresh, isNotify:$isNotify", tag: tag);

    DeviceProvider provider = deviceProvider;
    DeviceRepository repository = _deviceRepository;

    MyPrint.printOnConsole("userDevicesLength in DeviceProvider:${provider.userDevicesLength}", tag: tag);
    if(isRefresh || provider.userDevicesLength <= 0) {
      provider.setIsUserDevicesLoading(value: true, isNotify: isNotify);

      List<DeviceModel> devices = await repository.getUserDevicesList(userId: userId);
      MyPrint.printOnConsole("User Device Models length:${devices.length}", tag: tag);

      devices.removeWhere((DeviceModel deviceModel) {
        if(!deviceModel.accessibleUsers.contains(userId)) {
          return true;
        }
        else {
          if(!deviceModel.isMultiUserAccessEnabled && deviceModel.accessibleUsers.firstElement != userId) {
            return true;
          }
          else {
            return false;
          }
        }
      });

      provider.setUserDevices(devices: devices, isClear: true, isNotify: false);
      provider.setIsUserDevicesLoading(value: false, isNotify: true);
    }

    MyPrint.printOnConsole("DeviceController().getUserDevicesList() Finished", tag: tag);
  }

  Future<bool> registerDeviceForUserId({BuildContext? context, required String userId, required String deviceId}) async {
    bool isRegistered = false;

    if(userId.isEmpty || deviceId.isEmpty) {
      if(context?.mounted == true) {
        MyToast.showError(context: context!, msg: "User or Device data not available");
      }
      return isRegistered;
    }

    MyFirestoreDocumentSnapshot snapshot = await FirebaseNodes.deviceDocumentReference(deviceId: deviceId).get();

    if(!snapshot.exists || snapshot.data().checkEmpty) {
      if(context?.mounted == true) {
        MyToast.showError(context: context!, msg: "Device not registered or data not available");
      }
      return isRegistered;
    }

    DeviceModel deviceModel = DeviceModel.fromMap(snapshot.data()!);

    //Check if Device is Already registered for given userId
    if(deviceModel.accessibleUsers.contains(userId)) {
      if(context?.mounted == true) {
        MyToast.showError(context: context!, msg: "Device already Registered for your account");
      }
      return isRegistered;
    }

    //Check for Multiple Access Enabled or Not
    if(!deviceModel.isMultiUserAccessEnabled && deviceModel.accessibleUsers.isNotEmpty) {
      if(context?.mounted == true) {
        MyToast.showError(context: context!, msg: "Another user has already Registered Device, cannot register for your account");
      }
      return isRegistered;
    }

    bool isUpdated = await _deviceRepository.updateDeviceDataFromMap(
      deviceId: deviceId,
      data: {
        "accessibleUsers" : FieldValue.arrayUnion([userId]),
      },
    );

    if(isUpdated) {
      UserRepository().updateUserDataFromMap(
        userId: userId,
        data: {
          "deviceIds" : FieldValue.arrayUnion([deviceId]),
        },
      );

      if(context?.mounted == true) {
        MyToast.showSuccess(context: context!, msg: "Device Registered Successfully");
        AnalyticsController().fireEvent(analyticEvent: AnalyticsEvent.devicescreen_add_device);

      }

      isRegistered = true;
    }
    else {
      if(context?.mounted == true) {
        MyToast.showError(context: context!, msg: "Device couldn't registered");
      }
    }

    return isRegistered;
  }

  Future<bool> updateDeviceStatus({required String deviceId, DeviceModel? deviceModel, required bool statusOn}) async {
    MyPrint.printOnConsole("DeviceController().updateDeviceStatus() called with deviceId:'$deviceId' and statusOn:'$statusOn'");

    bool isUpdated = false;

    if(deviceId.isEmpty) {
      return isUpdated;
    }

    bool isUpdatedInRealtimeDatabase = false, isUpdatedInFirestore = false;

    try {
      await Future.wait([
        _deviceRepository.updateDeviceStatusDataInRealtimeDatabase(deviceId: deviceId, statusOn: statusOn).then((value) {
          isUpdatedInRealtimeDatabase = value;
        }),
        _deviceRepository.updateDeviceDataFromMap(deviceId: deviceId, data: {
          "statusOn" : statusOn,
        }).then((value) {
          isUpdatedInFirestore = value;
        }),
      ]);
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in Updating Device Status in DeviceController().updateDeviceStatus():$e");
      MyPrint.printOnConsole(s);
    }

    MyPrint.printOnConsole("DeviceController().updateDeviceStatus() isUpdatedInRealtimeDatabase:$isUpdatedInRealtimeDatabase");
    MyPrint.printOnConsole("DeviceController().updateDeviceStatus() isUpdatedInFirestore:$isUpdatedInFirestore");

    isUpdated = isUpdatedInRealtimeDatabase && isUpdatedInFirestore;

    MyPrint.printOnConsole("DeviceController().updateDeviceStatusDataInRealtimeDatabase() isUpdated:$isUpdated");

    if(isUpdated) {
      deviceModel?.statusOn = statusOn;
    }

    return isUpdated;
  }
}