import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_sdk/cloudinary_sdk.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:okoto/utils/cloudinary_manager.dart';
import 'package:okoto/utils/extensions.dart';
import 'package:okoto/view/profile_screen/components/choose_image_dialog.dart';
import 'package:provider/provider.dart';

import '../../../backend/navigation/navigation_controller.dart';
import '../../../backend/navigation/navigation_operation_parameters.dart';
import '../../../backend/navigation/navigation_type.dart';
import '../../../backend/notification/notification_provider.dart';
import '../../../backend/user/user_controller.dart';
import '../../../backend/user/user_provider.dart';
import '../../../configs/styles.dart';
import '../../../model/user/user_model.dart';
import '../../../utils/date_presentation.dart';
import '../../../utils/my_print.dart';
import '../../../utils/my_toast.dart';
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
  String? url;
  File? pickedImage;
  XFile? file;

  late UserProvider userProvider;
  late UserController userController;

  void initializeValuesFromProvider() {
    MyPrint.printOnConsole("initializeValuesFromProvider called");
    UserModel? userModel = userProvider.getUserModel();

    MyPrint.printOnConsole("userModel in Sign Up Screen:$userModel");
    if (userModel != null) {
      nameController.text = userModel.name;
      dateOfBirth = userModel.dateOfBirth?.toDate();
      gender = userModel.gender;
      userNameController.text = userModel.userName;
    }
  }

  ImagePicker imagePicker = ImagePicker();

  Future<void> pickImage(ImageSource imageSource) async {
    try {
      XFile? result = await imagePicker.pickImage(source: imageSource);

      if (result != null) {
        File file = File(result.path ?? "");
        pickedImage = file;
      } else {
        pickedImage = null;
      }
      setState(() {});
    } catch(e,s){
      MyPrint.printOnConsole("Error in picking up the image; $e");
      MyPrint.printOnConsole(s);
    }
  }

  Future<void> updateUserData() async {
    UserModel? existingUserModel = userProvider.getUserModel();
    if(existingUserModel != null) {
      isLoading = true;
      setState(() {});



      NotificationProvider notificationProvider = context.read<NotificationProvider>();

      UserModel newUserModel = UserModel.fromMap(existingUserModel.toMap());
      if(pickedImage != null){
          CloudinaryUploadResource cloudinaryUploadResource = CloudinaryUploadResource(
            fileBytes: pickedImage?.readAsBytesSync(),
            filePath: pickedImage?.path,
          );
          CloudinaryResponse? cloudinaryResponse = await CloudinaryManager().uploadResource(resourceToUpload: cloudinaryUploadResource);
          newUserModel.profileImageUrl = cloudinaryResponse?.secureUrl ?? "";
      }
      newUserModel.name = nameController.text;
      newUserModel.userName = userNameController.text;

      bool isUpdated = await UserController(userProvider: userProvider).updateUserData(userModel: newUserModel);
      MyPrint.printOnConsole("isUpdated:$isUpdated");

      isLoading = false;
      setState(() {});

      if(isUpdated) {
        MyToast.showSuccess(context: context, msg: "Updated Successfully");
        userProvider.setUserModel(userModel: newUserModel, isNotify: false);

        await userController.updateNotificationTokenForUserAndStoreInProvider(
          userId: newUserModel.id,
          notificationProvider: notificationProvider,
        );

        await userController.checkSubscriptionActivatedOrNot();

        // userController.startUserListening(
        //   userId: newUserModel.id,
        //   notificationProvider: notificationProvider,
        // );

        // if(context.mounted) {
        //   NavigationController.navigateToHomeScreen(navigationOperationParameters: NavigationOperationParameters(
        //     context: context,
        //     navigationType: NavigationType.pushNamedAndRemoveUntil,
        //   ));
        // }
      }
      else {
        if(context.mounted) {
          MyToast.showError(context: context, msg: "Some error occurred while updating data");
        }
      }
    }
    else {
      MyToast.showError(context: context, msg: "User Data not found");
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
                                const SizedBox(
                                  height: 50,
                                ),
                                getMyProfileAvatar(),
                                const SizedBox(
                                  height: 50,
                                ),
                                getBasicInfo(),
                                const SizedBox(
                                  height: 60,
                                ),
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
    return Stack(
      children: [
        pickedImage == null
            ? MyProfileAvatar(
                size: 110,
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image.file(
                  pickedImage!,
                  height: 110,
                  width: 110,
                  fit: BoxFit.cover,
                ),
              ),
        Positioned(
            bottom: 0,
            right: 0,
            child: InkWell(
              onTap: () async {
                String? result = await showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return ChooseImageDialog();
                  },
                );
                if (result != null) {
                  if (result == "camera") {
                    pickImage(ImageSource.camera);
                  } else {
                    pickImage(ImageSource.gallery);
                  }
                } else {
                  pickedImage = null;
                  setState(() {});
                }
              },
              child: Container(
                padding: EdgeInsets.all(5),
                margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.edit, color: Styles.myDarkVioletColor, size: 14),
              ),
            ))
      ],
    );
  }

  Widget getBasicInfo() {
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
            if (val == null || val.isEmpty) {
              return "Name cannot be empty";
            } else {
              return null;
            }
          },
        ),
        const SizedBox(
          height: 10,
        ),
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
            if (val == null || val.isEmpty) {
              return "Username cannot be empty";
            } else {
              return null;
            }
          },
        ),
        const SizedBox(
          height: 10,
        ),
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
        const SizedBox(
          height: 10,
        ),
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

  Widget submitButton() {
    return CommonSubmitButton(
        onTap: () async {
          if (_formKey.currentState!.validate()) {
            bool formValid = _formKey.currentState?.validate() ?? false;
            bool dobValid = dateOfBirth != null;
            bool genderValid = gender?.isNotEmpty ?? false;

            MyPrint.printOnConsole("formValid:$formValid, dobValid:$dobValid, genderValid:$genderValid");

            if (formValid && dobValid && genderValid) {
            } else if (!formValid) {
            } else if (!dobValid) {
              MyToast.showError(context: context, msg: "Date Of Birth is Mandatory");
            } else if (!genderValid) {
              MyToast.showError(context: context, msg: "Gender is Mandatory");
            } else {
            }
          }
          await updateUserData();
        },
        text: "Update Profile");
  }
}
