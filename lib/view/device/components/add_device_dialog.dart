import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:okoto/backend/device/device_controller.dart';
import 'package:okoto/backend/user/user_provider.dart';
import 'package:okoto/utils/extensions.dart';
import 'package:okoto/utils/my_safe_state.dart';
import 'package:okoto/utils/my_toast.dart';
import 'package:okoto/utils/my_utils.dart';
import 'package:okoto/view/common/components/common_textfield.dart';
import 'package:provider/provider.dart';

import '../../common/components/common_text.dart';

class AddDeviceDialog extends StatefulWidget {
  const AddDeviceDialog({Key? key}) : super(key: key);

  @override
  State<AddDeviceDialog> createState() => _AddDeviceDialogState();
}

class _AddDeviceDialogState extends State<AddDeviceDialog> with MySafeState {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController deviceIdController = TextEditingController();

  bool isLoading = false;

  Future<void> addDevice({required String deviceId}) async {
    MyUtils.hideShowKeyboard(isHide: true);

    if(isLoading) {
      return;
    }

    UserProvider userProvider = context.read<UserProvider>();
    String userId = userProvider.getUserId();
    if(userId.isEmpty) {
      MyToast.showError(context: context, msg: "User Data not available");
      return;
    }

    isLoading = true;
    mySetState();

    bool isRegistered = await DeviceController(deviceProvider: null).registerDeviceForUserId(
      context: context,
      deviceId: deviceId,
      userId: userId,
    );

    isLoading = false;
    mySetState();

    if(isRegistered && context.mounted) {
      Navigator.pop(context, isRegistered);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return !isLoading;
      },
      child: AlertDialog(
        // contentPadding: const EdgeInsets.all(0),
        // insetPadding: const EdgeInsets.all(0),
        titlePadding: const EdgeInsets.all(0),
        title: getTitleWidget(),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              getDeviceIdTextField(),
              getAddDeviceButton(themeData: Theme.of(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget getTitleWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const IconButton(
          onPressed: null,
          icon: Icon(Icons.close, color: Colors.transparent,),
        ),
        const Text("Add Device"),
        IconButton(
          onPressed: () {
            if(!isLoading) Navigator.pop(context);
          },
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget getDeviceIdTextField() {
    return CommonTextField(
      textEditingController: deviceIdController,
      hint: "Enter Device Id",
      enabled: true,
      validator: (String? text) {
        if((text ?? "").trim().checkEmpty) {
          return "Device Id cannot be empty";
        }
        else {
          return null;
        }
      },
    );
  }

  Widget getAddDeviceButton({required ThemeData themeData}) {
    return InkWell(
      onTap: () {
        if(_formKey.currentState?.validate() ?? false) {
          addDevice(deviceId: deviceIdController.text.trim());
        }
      },
      focusColor: Colors.transparent,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 8),
          decoration: BoxDecoration(
            color: themeData.colorScheme.primary,
            borderRadius: BorderRadius.circular(4),
          ),
          child: isLoading
              ? SizedBox(
                  width: 30,
                  child: SpinKitDualRing(
                    color: themeData.colorScheme.onPrimary,
                    duration: const Duration(milliseconds: 500),
                    size: 18,
                    lineWidth: 1,
                  ),
                )
              : const CommonText(
                  text: "Add",
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
      ),
    );
  }
}
