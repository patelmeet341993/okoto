import 'dart:async';

import 'package:okoto/backend/common/common_provider.dart';
import 'package:okoto/model/device/device_model.dart';

import '../../model/device/running_device_model.dart';

class DeviceProvider extends CommonProvider {
  DeviceProvider() {
    runningDeviceId = CommonProviderPrimitiveParameter<String>(
      value: "",
      notify: notify,
    );
    runningDeviceModel = CommonProviderPrimitiveParameter<RunningDeviceModel?>(
      value: null,
      notify: notify,
    );
    runningDeviceStreamSubscription = CommonProviderPrimitiveParameter<StreamSubscription<RunningDeviceModel?>?>(
      value: null,
      notify: notify,
    );
    runningDeviceUpdationTimer = CommonProviderPrimitiveParameter<Timer?>(
      value: null,
      notify: notify,
    );
  }

  //region User Devices
  //region User Device Models List
  final List<DeviceModel> _userDevices = <DeviceModel>[];

  List<DeviceModel> getUserDevices({bool isNewInstance = true}) {
    if(isNewInstance) {
      return _userDevices.map((e) => DeviceModel.fromMap(e.toMap())).toList();
    }
    else {
      return _userDevices;
    }
  }

  int get userDevicesLength => _userDevices.length;

  void setUserDevices({required List<DeviceModel> devices, bool isClear = true, bool isNotify = true}) {
    if(isClear) {
      _userDevices.clear();
    }
    _userDevices.addAll(devices);
    notify(isNotify: isNotify);
  }
  //endregion

  //region Is User Device Models Loading
  bool _isUserDevicesLoading = false;

  bool get isUserDevicesLoading => _isUserDevicesLoading;

  void setIsUserDevicesLoading({required bool value, bool isNotify = true}) {
    _isUserDevicesLoading = value;
    notify(isNotify: isNotify);
  }
  //endregion
  //endregion

  late CommonProviderPrimitiveParameter<String> runningDeviceId;
  late CommonProviderPrimitiveParameter<RunningDeviceModel?> runningDeviceModel;
  late CommonProviderPrimitiveParameter<StreamSubscription<RunningDeviceModel?>?> runningDeviceStreamSubscription;
  late CommonProviderPrimitiveParameter<Timer?> runningDeviceUpdationTimer;

  void resetRunningDeviceData() {
    runningDeviceId.set(value: "", isNotify: false);
    runningDeviceModel.set(value: null, isNotify: false);

    runningDeviceStreamSubscription.get()?.cancel();
    runningDeviceStreamSubscription.set(value: null, isNotify: false);

    runningDeviceUpdationTimer.get()?.cancel();
    runningDeviceUpdationTimer.set(value: null, isNotify: false);
  }

  void resetAllData() {
    setUserDevices(devices: [], isNotify: false);
    setIsUserDevicesLoading(value: false, isNotify: false);

    resetRunningDeviceData();
  }
}