import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:okoto/backend/device/device_provider.dart';
import 'package:okoto/backend/device/device_repository.dart';
import 'package:okoto/backend/user/user_controller.dart';
import 'package:okoto/backend/user/user_provider.dart';
import 'package:okoto/configs/constants.dart';
import 'package:okoto/configs/typedefs.dart';
import 'package:okoto/model/common/new_document_data_model.dart';
import 'package:okoto/model/device/device_model.dart';
import 'package:okoto/model/device/running_device_model.dart';
import 'package:okoto/utils/extensions.dart';
import 'package:okoto/utils/my_print.dart';
import 'package:okoto/utils/my_toast.dart';
import 'package:okoto/utils/my_utils.dart';
import 'package:okoto/utils/parsing_helper.dart';

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
    if (isRefresh || provider.userDevicesLength <= 0) {
      provider.setIsUserDevicesLoading(value: true, isNotify: isNotify);

      List<DeviceModel> devices = await repository.getUserDevicesList(userId: userId);
      MyPrint.printOnConsole("User Device Models length:${devices.length}", tag: tag);

      devices.removeWhere((DeviceModel deviceModel) {
        if (!deviceModel.accessibleUsers.contains(userId)) {
          return true;
        } else {
          if (!deviceModel.isMultiUserAccessEnabled && deviceModel.accessibleUsers.firstElement != userId) {
            return true;
          } else {
            return false;
          }
        }
      });

      provider.setUserDevices(devices: devices, isClear: true, isNotify: false);
      provider.setIsUserDevicesLoading(value: false, isNotify: true);
    }

    MyPrint.printOnConsole("DeviceController().getUserDevicesList() Finished", tag: tag);
  }

  Future<bool> registerDeviceForUserId({
    BuildContext? context,
    required String userId,
    required String deviceId,
    required UserProvider userProvider,
  }) async {
    bool isRegistered = false;

    if (userId.isEmpty || deviceId.isEmpty) {
      if (context?.mounted == true) {
        MyToast.showError(context: context!, msg: "User or Device data not available");
      }
      return isRegistered;
    }

    MyFirestoreDocumentSnapshot snapshot = await FirebaseNodes.deviceDocumentReference(deviceId: deviceId).get();

    if (!snapshot.exists || snapshot.data().checkEmpty) {
      if (context?.mounted == true) {
        MyToast.showError(context: context!, msg: "Device not registered or data not available");
      }
      return isRegistered;
    }

    DeviceModel deviceModel = DeviceModel.fromMap(snapshot.data()!);

    //Check if Device is Already registered for given userId
    if (deviceModel.accessibleUsers.contains(userId)) {
      if (context?.mounted == true) {
        MyToast.showError(context: context!, msg: "Device already Registered for your account");
      }
      return isRegistered;
    }

    //Check for Multiple Access Enabled or Not
    if (!deviceModel.isMultiUserAccessEnabled && deviceModel.accessibleUsers.isNotEmpty) {
      if (context?.mounted == true) {
        MyToast.showError(context: context!, msg: "Another user has already Registered Device, cannot register for your account");
      }
      return isRegistered;
    }

    bool isUpdated = await _deviceRepository.updateDeviceDataFromMap(
      deviceId: deviceId,
      data: {
        "accessibleUsers": FieldValue.arrayUnion([userId]),
      },
    );

    if (isUpdated) {
      UserController(userProvider: userProvider).addDeviceInDevicesList(deviceId: deviceId);

      if (context?.mounted == true) {
        MyToast.showSuccess(context: context!, msg: "Device Registered Successfully");
        AnalyticsController().fireEvent(analyticEvent: AnalyticsEvent.devicescreen_add_device);
      }

      isRegistered = true;
    } else {
      if (context?.mounted == true) {
        MyToast.showError(context: context!, msg: "Device couldn't registered");
      }
    }

    return isRegistered;
  }

  Future<bool> startPlayingGame({required String deviceId}) async {
    String tag = MyUtils.getUniqueIdFromUuid();
    MyPrint.printOnConsole("DeviceController().startPlayingGame() called with deviceId:'$deviceId'", tag: tag);

    if (deviceId.isEmpty) {
      MyPrint.printOnConsole("Returning from DeviceController().startPlayingGame() because deviceId is empty", tag: tag);
      return false;
    }

    await stopPlayingGame();

    deviceProvider.runningDeviceId.set(value: deviceId, isNotify: false);

    NewDocumentDataModel newDocumentDataModel = await MyUtils.getNewDocIdAndTimeStamp(isGetTimeStamp: true);
    bool isUpdated = await updateRunningDeviceData(
      deviceId: deviceId,
      statusOn: true,
      startedTime: newDocumentDataModel.timestamp.toDate().millisecondsSinceEpoch.toString(),
      lastUpdatedTime: newDocumentDataModel.timestamp.toDate().millisecondsSinceEpoch.toString(),
    );
    MyPrint.printOnConsole("New TimeStamp:${newDocumentDataModel.timestamp.toDate()}", tag: tag);
    MyPrint.printOnConsole("New TimeStamp Milliseconds:${newDocumentDataModel.timestamp.toDate().millisecondsSinceEpoch}", tag: tag);

    //region Start Syncing with Device node in Realtime Database
    MyPrint.printOnConsole("Starting Syncing", tag: tag);
    StreamSubscription<RunningDeviceModel?> subscription = FirebaseDatabase.instance.ref("devices/$deviceId").onValue.map((DatabaseEvent databaseEvent) {
      MyPrint.printOnConsole("Running Device Node Listening Called with value:${databaseEvent.snapshot.value}", tag: tag);

      Map<String, dynamic> map = ParsingHelper.parseMapMethod<dynamic, dynamic, String, dynamic>(databaseEvent.snapshot.value);
      MyPrint.printOnConsole("Final Device data map:'${MyUtils.encodeJson(map)}'", tag: tag);

      RunningDeviceModel? runningDeviceModel;
      if (map.isNotEmpty) {
        runningDeviceModel = RunningDeviceModel.fromMap(map);
      }

      return runningDeviceModel;
    }).listen((RunningDeviceModel? runningDeviceModel) {
      deviceProvider.runningDeviceModel.set(value: runningDeviceModel);
    });
    deviceProvider.runningDeviceStreamSubscription.set(value: subscription, isNotify: false);
    MyPrint.printOnConsole("Syncing Started Successfully", tag: tag);
    //endregion

    //region Start Timer to Update Time every 5 minutes in Device node in Realtime Database
    MyPrint.printOnConsole("Starting Timer", tag: tag);
    Timer timer = Timer.periodic(const Duration(minutes: 5), (Timer timer) async {
      MyPrint.printOnConsole("Update Running Device lastUpdatedTime Timer Called", tag: tag);

      NewDocumentDataModel newDocumentDataModel = await MyUtils.getNewDocIdAndTimeStamp(isGetTimeStamp: true);
      FirebaseDatabase.instance.ref("devices/$deviceId/lastUpdatedTime").set(newDocumentDataModel.timestamp.toDate().millisecondsSinceEpoch.toString());
    });
    deviceProvider.runningDeviceUpdationTimer.set(value: timer, isNotify: false);
    MyPrint.printOnConsole("Timer Started Successfully", tag: tag);
    //endregion

    return isUpdated;
  }

  Future<bool> stopPlayingGame() async {
    String tag = MyUtils.getUniqueIdFromUuid();
    MyPrint.printOnConsole("DeviceController().stopPlayingGame() called", tag: tag);

    String deviceId = deviceProvider.runningDeviceId.get();

    MyPrint.printOnConsole("deviceId:'$deviceId'", tag: tag);
    if (deviceId.isEmpty) {
      MyPrint.printOnConsole("Returning from DeviceController().stopPlayingGame() because deviceId is empty", tag: tag);
      deviceProvider.resetRunningDeviceData();
      return false;
    }

    bool isUpdated = await updateRunningDeviceData(
      deviceId: deviceId,
      statusOn: false,
      startedTime: "",
      lastUpdatedTime: "",
    );
    MyPrint.printOnConsole("isUpdated:'$isUpdated'", tag: tag);

    if (isUpdated) {
      MyPrint.printOnConsole("Resetting Running Device Data in DeviceProvider", tag: tag);

      deviceProvider.resetRunningDeviceData();
    }

    return isUpdated;
  }

  Future<bool> updateRunningDeviceData({
    required String deviceId,
    String? startedTime,
    String? lastUpdatedTime,
    bool? statusOn,
  }) async {
    String tag = MyUtils.getUniqueIdFromUuid();
    MyPrint.printOnConsole(
        "DeviceController().updateDeviceStatus() called with deviceId:'$deviceId', startedTime:'$startedTime', "
        "lastUpdatedTime:'$lastUpdatedTime' and statusOn:'$statusOn'",
        tag: tag);

    bool isUpdated = false;

    if (deviceId.isEmpty) {
      return isUpdated;
    }

    bool isUpdatedInRealtimeDatabase = false, isUpdatedInFirestore = false;

    try {
      List<Future> futures = [
        _deviceRepository
            .updateRunningDeviceDataInRealtimeDatabase(
          deviceId: deviceId,
          statusOn: statusOn,
          startedTime: startedTime,
          lastUpdatedTime: lastUpdatedTime,
        )
            .then((value) {
          isUpdatedInRealtimeDatabase = value;
        }),
      ];
      if (statusOn != null) {
        futures.add(_deviceRepository.updateDeviceDataFromMap(deviceId: deviceId, data: {
          "statusOn": statusOn,
        }).then((value) {
          isUpdatedInFirestore = value;
        }));
      }

      await Future.wait(futures);
    } catch (e, s) {
      MyPrint.printOnConsole("Error in Updating Device Status in DeviceController().updateDeviceStatus():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
    }

    MyPrint.printOnConsole("DeviceController().updateDeviceStatus() isUpdatedInRealtimeDatabase:$isUpdatedInRealtimeDatabase", tag: tag);
    MyPrint.printOnConsole("DeviceController().updateDeviceStatus() isUpdatedInFirestore:$isUpdatedInFirestore", tag: tag);

    isUpdated = isUpdatedInRealtimeDatabase && isUpdatedInFirestore;

    MyPrint.printOnConsole("DeviceController().updateDeviceStatusDataInRealtimeDatabase() isUpdated:$isUpdated", tag: tag);

    return isUpdated;
  }
}
