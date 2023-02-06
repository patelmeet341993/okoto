import 'package:flutter/material.dart';
import 'package:okoto/backend/device/device_controller.dart';
import 'package:okoto/backend/user/user_provider.dart';
import 'package:okoto/model/device/device_model.dart';
import 'package:okoto/view/common/components/common_loader.dart';
import 'package:okoto/view/device/components/add_device_dialog.dart';
import 'package:provider/provider.dart';

import '../../../backend/device/device_provider.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({Key? key}) : super(key: key);

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  late ThemeData themeData;

  late DeviceProvider deviceProvider;
  late DeviceController deviceController;

  late UserProvider userProvider;

  Future<void> getDevices({bool isRefresh = true, bool isNotify = true,}) async {
    await deviceController.getUserDevicesList(userId: userProvider.getUserId(), isRefresh: isRefresh, isNotify: isNotify);
  }

  Future<void> addDevice() async {
    dynamic value = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AddDeviceDialog();
      },
    );

    if(value == true) {
      getDevices(isRefresh: true, isNotify: true);
    }
  }

  @override
  void initState() {
    super.initState();
    deviceProvider = context.read<DeviceProvider>();
    deviceController = DeviceController(deviceProvider: deviceProvider);

    userProvider = context.read<UserProvider>();

    getDevices(isRefresh: false, isNotify: false);
  }

  @override
  Widget build(BuildContext context) {
    themeData = Theme.of(context);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<DeviceProvider>.value(value: deviceProvider),
        ChangeNotifierProvider<UserProvider>.value(value: userProvider),
      ],
      child: Consumer2<DeviceProvider, UserProvider>(
        builder: (BuildContext context, DeviceProvider deviceProvider, UserProvider userProvider, Widget? child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                "Devices",
                style: TextStyle(
                  // fontSize: 16,
                ),
              ),
            ),
            floatingActionButton: getAddDeviceFloatingActionButton(),
            body: SafeArea(
              child: getMainBody(deviceProvider: deviceProvider),
            ),
          );
        },
      ),
    );
  }

  FloatingActionButton getAddDeviceFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        addDevice();
      },
      child: const Icon(Icons.add),
    );
  }

  Widget getMainBody({required DeviceProvider deviceProvider}) {
    if(deviceProvider.isUserDevicesLoading) {
      return const Center(
        child: CommonLoader(isCenter: true),
      );
    }

    if(deviceProvider.userDevicesLength <= 0) {
      return RefreshIndicator(
        onRefresh: () async {
          await getDevices(isRefresh: true, isNotify: true);
        },
        child: ListView(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.4,),
            const Center(child: Text("No Device")),
          ],
        ),
      );
    }

    List<DeviceModel> devices = deviceProvider.getUserDevices(isNewInstance: false);

    return RefreshIndicator(
      onRefresh: () async {
        await getDevices(isRefresh: true, isNotify: true);
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        itemCount: devices.length,
        itemBuilder: (BuildContext context, int index) {
          DeviceModel deviceModel = devices[index];

          return Card(
            child: Text(deviceModel.id),
          );
        },
      ),
    );
  }
}
