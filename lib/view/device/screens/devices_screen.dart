import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:okoto/backend/device/device_controller.dart';
import 'package:okoto/backend/user/user_provider.dart';
import 'package:okoto/model/device/device_model.dart';
import 'package:okoto/view/common/components/common_appbar.dart';
import 'package:okoto/view/common/components/common_loader.dart';
import 'package:okoto/view/device/components/add_device_dialog.dart';
import 'package:provider/provider.dart';

import '../../../backend/device/device_provider.dart';
import '../../../configs/styles.dart';
import '../../common/components/common_text.dart';
import '../../common/components/my_screen_background.dart';

class DevicesScreen extends StatefulWidget {
  static const String routeName = '/DevicesScreen';
  const DevicesScreen({Key? key}) : super(key: key);

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  late ThemeData themeData;

  late DeviceProvider deviceProvider;
  late DeviceController deviceController;

  late UserProvider userProvider;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
            floatingActionButton: getAddDeviceFloatingActionButton(),
            body: MyScreenBackground(
              child: SafeArea(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonAppBar(text: 'Devices'),
                      const SizedBox(height: 40,),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CommonText(text: 'Linked Devices', fontSize: 19, fontWeight: FontWeight.bold),
                              Expanded(child: getMainBody(deviceProvider: deviceProvider)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 80,),
                      //letsPlayButton(),
                    ],
                  ),
                ),
              ),
            ),
          );
            Scaffold(
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

  Widget getAddDeviceFloatingActionButton() {
    return InkWell(
      onTap: (){
        addDevice();
      },
      child: Container(
        padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Styles.floatingButton,
        shape: BoxShape.circle,
      ),
        child: Icon(Icons.add,color: Colors.white,size: 32),
      ),
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
            SizedBox(height: MediaQuery.of(context).size.height * 0.35,),
             Center(child: Column(
              children: [
                CommonText(text:"No Device Added",fontSize: 19,fontWeight: FontWeight.bold),
                SizedBox(height: 4,),
                CommonText(text:"Press '+' to add a device",fontSize: 14,color: Colors.white.withOpacity(.6),),
              ],
            )),
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
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 25),
        itemCount: devices.length,
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          DeviceModel deviceModel = devices[index];

          return getMySingleDeviceCard(deviceModel);
        },
      ),
    );
  }

  Widget getMySingleDeviceCard(DeviceModel deviceModel) {
    return Row(
      children: [
        Image.asset(
          "assets/images/vr_icon.png",
          height: 25,
          width: 30,
          fit: BoxFit.fill,
        ),
        SizedBox(width: 15,),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonText(text: deviceModel.id,fontSize: 14,),
              SizedBox(height: 2,),
              CommonText(
                text: deviceModel.createdTime == null ? '-' : DateFormat("dd MMM yyyy").format(deviceModel.createdTime!.toDate()),
              fontSize: 12,
                color: Colors.white.withOpacity(.9),
              )
            ],
          ),
        ),
        Icon(
          Icons.info_outline,
        )
      ],
    );
  }


}
