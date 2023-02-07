import 'package:okoto/backend/common/common_provider.dart';
import 'package:okoto/model/device/device_model.dart';

class DeviceProvider extends CommonProvider {
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
}