import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:okoto/backend/device/device_controller.dart';
import 'package:okoto/backend/user/user_provider.dart';
import 'package:okoto/utils/extensions.dart';
import 'package:okoto/utils/my_safe_state.dart';
import 'package:okoto/utils/my_toast.dart';
import 'package:okoto/utils/my_utils.dart';
import 'package:okoto/view/common/components/common_textfield.dart';
import 'package:okoto/view/profile_screen/components/line_dashed_separator.dart';
import 'package:provider/provider.dart';

import '../../../configs/styles.dart';
import '../../common/components/common_submit_button.dart';
import '../../common/components/common_text.dart';
import '../../common/components/my_common_textfield.dart';

class ChooseImageDialog extends StatefulWidget {
  const ChooseImageDialog({Key? key}) : super(key: key);

  @override
  State<ChooseImageDialog> createState() => _ChooseImageDialogState();
}

class _ChooseImageDialogState extends State<ChooseImageDialog> with MySafeState {

   bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return !isLoading;
      },
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        backgroundColor: Styles.floatingButton,
        titlePadding: EdgeInsets.zero,
        contentPadding: EdgeInsets.zero,
        content: Container(
          padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
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
              SizedBox(height: 5,),

              getChooseOption(Icons.photo_camera,'Take from Camera', "camera"),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 5),
                  width: double.maxFinite,
                  height: 5,
                  child: MySeparator(
                    color: Colors.white,
                  )),
              getChooseOption(MdiIcons.trayArrowUp,'Upload from device', "gallery"),
              SizedBox(height: 10,),

            ],
          ),
        ),
      ),
    );
  }

  Widget getChooseOption(IconData icon,String text, String popString){
    return InkWell(
      onTap: (){
        Navigator.pop(context, popString);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12,horizontal: 5),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 25,
            ),
            SizedBox(width: 10,),
            CommonText(text: text,fontSize: 17,)

          ],
        ),
      ),
    );
  }

}
