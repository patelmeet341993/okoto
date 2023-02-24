import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:okoto/view/common/components/common_back_button.dart';
import 'package:okoto/view/common/components/common_submit_button.dart';
import 'package:provider/provider.dart';

import '../../../backend/authentication/authentication_controller.dart';
import '../../../backend/data/data_controller.dart';
import '../../../backend/data/data_provider.dart';
import '../../../backend/navigation/navigation_controller.dart';
import '../../../backend/navigation/navigation_operation_parameters.dart';
import '../../../backend/navigation/navigation_type.dart';
import '../../../backend/user/user_controller.dart';
import '../../../backend/user/user_provider.dart';
import '../../../configs/constants.dart';
import '../../../configs/styles.dart';
import '../../../model/user/user_model.dart';
import '../../../utils/date_presentation.dart';
import '../../../utils/my_print.dart';
import '../../../utils/my_toast.dart';
import '../../common/components/common_loader.dart';
import '../../common/components/common_primary_button.dart';
import '../../common/components/common_text.dart';
import '../../common/components/modal_progress_hud.dart';
import '../../common/components/my_common_textfield.dart';
import '../../common/components/my_screen_background.dart';

class SignUpScreen extends StatefulWidget {
  static const String routeName = "/SignUpScreen";

  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late ThemeData themeData;

  bool isLoading = false, isAcceptedTerms = false;

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

  Future<void> pickDate() async {
    DateTime? dateTime = await showDatePicker(
      context: context,
      initialDate: dateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1960),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: themeData.copyWith(
            colorScheme: ColorScheme.dark(
              primary: Styles.myVioletShade2, // header background color
              onPrimary: Colors.white, // headebody text color
              surface: Styles.myVioletShade3,
            ),
          ),
          child: child ?? const SizedBox(),
        );
      },
    );

    dateOfBirth = dateTime ?? dateOfBirth;
    setState(() {});
  }

  Future<void> updateUserData() async {
    UserModel? existingUserModel = userProvider.getUserModel();
    if(existingUserModel != null) {
      isLoading = true;
      setState(() {});

      UserModel newUserModel = UserModel.fromMap(existingUserModel.toMap());

      newUserModel.name = nameController.text;
      newUserModel.userName = userNameController.text;
      newUserModel.dateOfBirth = dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null;
      newUserModel.gender = gender ?? "";

      bool isUpdated = await UserController(userProvider: userProvider).updateUserData(userModel: newUserModel);
      MyPrint.printOnConsole("isUpdated:$isUpdated");

      isLoading = false;
      setState(() {});

      if(isUpdated) {
        userProvider.setUserModel(userModel: newUserModel, isNotify: false);

        await userController.checkSubscriptionActivatedOrNot();

        if(context.mounted) {
          NavigationController.navigateToHomeScreen(navigationOperationParameters: NavigationOperationParameters(
            context: context,
            navigationType: NavigationType.pushNamedAndRemoveUntil,
          ));
        }
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
    themeData = Theme.of(context);

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
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10).copyWith(top: 60),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          getTopBar(),
                          SizedBox(height: 60,),
                          getTopDetails(),
                          SizedBox(height: 80,),
                          getBasicInfo(),
                          SizedBox(height: 80,),
                          letsPlayButton(),
                        ],
                      ),
                      /* Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 30),
                            child: Image.asset(
                              "assets/images/logo.png",
                              width: 60,
                            ),
                          ),
                          CommonTextField(
                            hint: "Name",
                            textEditingController: nameController,
                            isRequired: true,
                            prefixIcon: Icons.person,
                            validator: (String? text) {
                              if(text?.isEmpty ?? true) {
                                return "Name Cannot be empty";
                              }
                              else {
                                return null;
                              }
                            },
                          ),
                          CommonTextField(
                            hint: "Username",
                            textEditingController: userNameController,
                            isRequired: true,
                            prefixIcon: Icons.person_pin,
                            validator: (String? text) {
                              if(text?.isEmpty ?? true) {
                                return "Username Cannot be empty";
                              }
                              else {
                                return null;
                              }
                            },
                          ),
                          getDateOfBirthSelection(),
                          getGenderSelection(),
                          getTermsCondition(),
                          getSignUpButton(),
                          getLoginWithAnotherAccountLink(),
                        ],
                      ),*/
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

  Widget getTopBar(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CommonBackButton(),
      ],
    );
  }

  Widget getTopDetails(){
    return  Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CommonText(
          text: "Let us know you better,",
          fontSize: 27,
          textAlign: TextAlign.start,
          fontWeight: FontWeight.bold,
        ),
        SizedBox(
          height: 9,
        ),
        CommonText(
          text: "Please provide some information of you",
          fontSize: 17,
          textAlign: TextAlign.start,
        ),
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
            margin: EdgeInsets.symmetric(horizontal: 10.0),
            child: Icon(
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
        SizedBox(height: 10,),
        MyCommonTextField(
          controller: userNameController,
          labelText: 'Username',
          cursorColor: Colors.white,
          prefix: Container(
            margin: EdgeInsets.symmetric(horizontal: 10.0),
            child: Icon(
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
        SizedBox(height: 10,),
        InkWell(
          onTap: (){
            pickDate();
          },
          child: MyCommonTextField(
            //controller: userNameController,
            labelText: dateOfBirth != null ? DatePresentation.ddMMyyyyFormatter(dateOfBirth!.millisecondsSinceEpoch.toString()) : 'Date of Birth',
            enabled: false,
            onTap: (){
              pickDate();
            },
            cursorColor: Colors.white,
            prefix: Container(
              margin: EdgeInsets.symmetric(horizontal: 10.0),
              child: Icon(
                Icons.cake,
                color: Colors.white,
                size: 23,
              ),
            ),
          ),
        ),
        SizedBox(height: 10,),
        MyCommonTextField(
          //controller: userNameController,
          labelText: 'Gender',
          enabled: false,
          cursorColor: Colors.white,
          prefix: Container(
            margin: EdgeInsets.symmetric(horizontal: 10.0),
            child: Icon(
              MdiIcons.genderMaleFemale,
              color: Colors.white,
              size: 23,
            ),
          ),
        ),


      ],
    );
  }


  Widget letsPlayButton(){
    return CommonSubmitButton(
        onTap: (){
          if(_formKey.currentState!.validate()){
            if(isAcceptedTerms) {
              bool formValid = _formKey.currentState?.validate() ?? false;
              bool dobValid = dateOfBirth != null;
              bool genderValid = gender?.isNotEmpty ?? false;

              MyPrint.printOnConsole("formValid:$formValid, dobValid:$dobValid, genderValid:$genderValid");

              if(formValid && dobValid && genderValid) {
                updateUserData();
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
            else {
              MyToast.showError(context: context, msg: "Please accept T&C");
            }
          }
        },
        text: "Let's Play"
    );
  }
















//region Garbage--------------------------------------------------------------------------------------------------------------------------------
  Widget getDateOfBirthSelection() {
    return GestureDetector(
      onTap: () {
        pickDate();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: themeData.inputDecorationTheme.border?.borderSide.color ?? Colors.white70),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Icon(Icons.date_range, color: themeData.iconTheme.color?.withAlpha(150),),
            const SizedBox(width: 13,),
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: dateOfBirth != null ? DatePresentation.ddMMyyyyFormatter(dateOfBirth!.millisecondsSinceEpoch.toString()) : "Select Date Of Birth",
                  style: themeData.textTheme.titleSmall?.copyWith(
                    color: themeData.textTheme.titleSmall!.color?.withAlpha(dateOfBirth != null ? 255 : 150),
                  ),
                  children: dateOfBirth == null ? [
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(color: Colors.red),
                    ),
                  ] : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //region Gender Selection
  Widget getGenderSelection() {
    String? selectedGender;
    List<String> gendersList = UserGender.values;
    if(gendersList.isNotEmpty) {
      if(!gendersList.contains(gender)) {
        gender = null;
      }
      selectedGender = gender;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Theme(
        data: themeData.copyWith(
          highlightColor: Colors.transparent,
          // splashColor: Colors.transparent,
        ),
        child: DropdownButtonFormField<String>(
          value: selectedGender,
          onChanged: (String? value) {
            gender = value;
            setState(() {});
          },
          // hint: const Text("Select Gender"),
          hint: Text.rich(
            TextSpan(
              text: "Select Gender",
              style: themeData.textTheme.titleSmall?.copyWith(
                color: themeData.textTheme.titleSmall!.color?.withAlpha(150),
              ),
              children: const [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
          style: themeData.textTheme.titleSmall,
          dropdownColor: themeData.primaryColor,
          // underline: const SizedBox(),
          isExpanded: true,
          decoration: InputDecoration(
            prefixIcon: Icon(getGenderIconFromGenderString(gender: selectedGender)),
            contentPadding: const EdgeInsets.all(5),
          ),
          items: gendersList.map((e) {
            return DropdownMenuItem<String>(
              value: e,
              child: Text(e),
            );
          }).toList(),
        ),
      ),
    );
  }

  IconData getGenderIconFromGenderString({required String? gender}) {
    if(gender == UserGender.male) {
      return Icons.male;
    }
    else if(gender == UserGender.female) {
      return Icons.female;
    }
    else {
      return Icons.transgender;
    }
  }
  //endregion

  Widget getTermsCondition() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Checkbox(
          activeColor: themeData.primaryColor,
          value: isAcceptedTerms,
          onChanged: (bool? value) {
            isAcceptedTerms = value!;
            setState(() {});
          },
        ),
        const CommonText(text:"Please accept ",fontSize: 14, ),
        InkWell(
          onTap: () {
            DataController(dataProvider: Provider.of<DataProvider>(context, listen: false)).showTermsAndConditionBottomSheet(context: context);
          },
          child: Text(
            "Terms and Conditions",
            style: themeData.textTheme.labelLarge?.copyWith(
              decoration: TextDecoration.underline,
             ),
          ),
        ),
      ],
    );
  }

  Widget getSignUpButton() {
    return CommonPrimaryButton(
      text: "Submit",
      onTap: () {
        if(isAcceptedTerms) {
          bool formValid = _formKey.currentState?.validate() ?? false;
          bool dobValid = dateOfBirth != null;
          bool genderValid = gender?.isNotEmpty ?? false;

          MyPrint.printOnConsole("formValid:$formValid, dobValid:$dobValid, genderValid:$genderValid");

          if(formValid && dobValid && genderValid) {
            updateUserData();
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
        else {
          MyToast.showError(context: context, msg: "Please accept T&C");
        }
      },
      filled: true,
    );
  }

  Widget getLoginWithAnotherAccountLink() {
    return InkWell(
      onTap: () {
        AuthenticationController(userProvider: userProvider).logout();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Text(
          "Login With Another Account",
          style: themeData.textTheme.labelLarge?.copyWith(
            decoration: TextDecoration.underline,
            color: themeData.textTheme.labelLarge!.color?.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
      ),
    );
  }
//endregion

}
