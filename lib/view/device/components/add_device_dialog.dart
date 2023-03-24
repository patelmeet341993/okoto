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

import '../../../configs/styles.dart';
import '../../common/components/common_submit_button.dart';
import '../../common/components/common_text.dart';
import '../../common/components/my_common_textfield.dart';

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
        backgroundColor: Styles.floatingButton,
        titlePadding: EdgeInsets.zero,
        contentPadding: EdgeInsets.zero,
        content: Form(
          key: _formKey,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                 Row(
                   crossAxisAlignment: CrossAxisAlignment.end,
                   mainAxisAlignment: MainAxisAlignment.end,
                   children: [
                     InkWell(
                         onTap: (){
                           if(!isLoading) Navigator.pop(context);
                         },
                         child: Container(
                             padding: EdgeInsets.symmetric(horizontal: 10,).copyWith(top: 5),
                             child: Icon(Icons.close, color: Colors.white,size: 20,)))
                   ],
                 ),
                //SizedBox(height: 15,),
                getDeviceIdTextField(),
                SizedBox(height: 20,),
                CommonSubmitButton(
                  text: 'Add Device',
                  elevation: 20,
                  height: 30,
                  fontSize: 13,
                  verticalPadding: 8,
                  horizontalPadding: 20,
                  borderRadius: 5,
                  icon: Icon(Icons.add,color: Colors.white,size: 18),
                  onTap: () {
                    if(_formKey.currentState?.validate() ?? false) {

                      addDevice(deviceId: deviceIdController.text.trim());
                    }
                  },
                ),
                SizedBox(height: 10,),

              ],
            ),
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
    return   MyCommonTextField(
      controller: deviceIdController,
      labelText: 'Enter Device Id',
      cursorColor: Colors.white,
      prefix: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Image.asset(
          "assets/images/vr_icon.png",
          height: 20,
          width: 26,
          fit: BoxFit.fill,
        ),
      ),
      validator: (val) {
        if(val == null || val.isEmpty) {
          return "Device Id cannot be empty";
        }
        else {
          return null;
        }
      },
    );

  }
}
