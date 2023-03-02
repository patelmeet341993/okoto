import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:okoto/utils/extensions.dart';
import 'package:okoto/view/profile_screen/components/choose_image_dialog.dart';
import 'package:provider/provider.dart';

import '../../../backend/user/user_controller.dart';
import '../../../backend/user/user_provider.dart';
import '../../../configs/styles.dart';
import '../../../model/user/user_model.dart';
import '../../../utils/date_presentation.dart';
import '../../../utils/my_print.dart';
import '../../../utils/my_toast.dart';
import '../../authentication/screens/sign_up_screen.dart';
import '../../common/components/common_appbar.dart';
import '../../common/components/common_loader.dart';
import '../../common/components/common_submit_button.dart';
import '../../common/components/modal_progress_hud.dart';
import '../../common/components/my_common_textfield.dart';
import '../../common/components/my_profile_avatar.dart';
import '../../common/components/my_screen_background.dart';

class EditProfileScreen extends StatefulWidget {
  static const String routeName = "/EditProfileScreen";
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {


  bool isLoading = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();

  DateTime? dateOfBirth;
  String? gender;

  late UserProvider userProvider;
  late UserController userController;

  void initializeValuesFromProvider() {
    MyPrint.printOnConsole("initializeValuesFromProvider called");
    UserModel? userModel = userProvider.getUserModel();

    MyPrint.printOnConsole("userModel in Sign Up Screen:$userModel");
    if(userModel != null) {
      nameController.text = userModel.name;
      dateOfBirth = userModel.dateOfBirth?.toDate();
      gender = userModel.gender;
      userNameController.text = userModel.userName;
    }
  }

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    userController = UserController(userProvider: userProvider);
    initializeValuesFromProvider();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      progressIndicator: const CommonLoader(),
      child: Scaffold(
        body: MyScreenBackground(
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CommonAppBar(text: 'Edit Profile'),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(height: 50,),
                                getMyProfileAvatar(),
                                const SizedBox(height: 50,),
                                getBasicInfo(),
                                const SizedBox(height: 60,),
                                submitButton(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getMyProfileAvatar() {
    return  Stack(
      children: [
        MyProfileAvatar(
          size: 110,
        ),
        Positioned(
          bottom: 0,
            right: 0,
            child: InkWell(
              onTap: (){
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return  ChooseImageDialog();
                  },
                );
              },
              child: Container(
                padding: EdgeInsets.all(5),
                margin: EdgeInsets.symmetric(horizontal: 5,vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.edit,color: Styles.myDarkVioletColor,size: 14),
              ),
            )
        )
      ],
    );
  }

  Widget getBasicInfo(){
    return Column(
      children: [
        MyCommonTextField(
          controller: nameController,
          labelText: 'Full Name',
          cursorColor: Colors.white,
          prefix: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10.0),
            child: const Icon(
              Icons.person_outline,
              color: Colors.white,
              size: 20,
            ),
          ),
          validator: (val) {
            if(val == null || val.isEmpty) {
              return "Name cannot be empty";
            }
            else {
              return null;
            }
          },
        ),
        const SizedBox(height: 10,),
        MyCommonTextField(
          controller: userNameController,
          labelText: 'Username',
          cursorColor: Colors.white,
          prefix: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10.0),
            child: const Icon(
              Icons.sports_esports_outlined,
              color: Colors.white,
              size: 23,
            ),
          ),
          validator: (val) {
            if(val == null || val.isEmpty) {
              return "Username cannot be empty";
            }
            else {
              return null;
            }
          },
        ),
        const SizedBox(height: 10,),
        MyCommonTextField(
          labelText: dateOfBirth != null ? DatePresentation.ddMMyyyyFormatter(dateOfBirth!.millisecondsSinceEpoch.toString()) : 'Date of Birth',
          enabled: false,
          cursorColor: Colors.white,
          prefix: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10.0),
            child: const Icon(
              Icons.cake,
              color: Colors.white,
              size: 23,
            ),
          ),
        ),
        const SizedBox(height: 10,),
        MyCommonTextField(
          labelText: gender.checkNotEmpty ? gender : 'Gender',
          enabled: false,
          cursorColor: Colors.white,
          prefix: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10.0),
            child: const Icon(
              MdiIcons.genderMaleFemale,
              color: Colors.white,
              size: 23,
            ),
          ),
        ),
      ],
    );
  }

  Widget submitButton(){
    return CommonSubmitButton(
        onTap: (){
          if(_formKey.currentState!.validate()){

            bool formValid = _formKey.currentState?.validate() ?? false;
            bool dobValid = dateOfBirth != null;
            bool genderValid = gender?.isNotEmpty ?? false;

            MyPrint.printOnConsole("formValid:$formValid, dobValid:$dobValid, genderValid:$genderValid");

            if(formValid && dobValid && genderValid) {

            }
            else if(!formValid) {

            }
            else if(!dobValid) {
              MyToast.showError(context: context, msg: "Date Of Birth is Mandatory");
            }
            else if(!genderValid) {
              MyToast.showError(context: context, msg: "Gender is Mandatory");
            }
            else {

            }
          }
        },
        text: "Update Profile"
    );
  }

}
