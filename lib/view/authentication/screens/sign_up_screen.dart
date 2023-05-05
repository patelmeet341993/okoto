import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:okoto/backend/notification/notification_provider.dart';
import 'package:okoto/utils/extensions.dart';
import 'package:okoto/utils/my_utils.dart';
import 'package:okoto/view/common/components/common_submit_button.dart';
import 'package:provider/provider.dart';

import '../../../backend/analytics/analytics_controller.dart';
import '../../../backend/analytics/analytics_event.dart';
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

      NotificationProvider notificationProvider = context.read<NotificationProvider>();

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

        await userController.updateNotificationTokenForUserAndStoreInProvider(
          userId: newUserModel.id,
          notificationProvider: notificationProvider,
        );

        await userController.checkSubscriptionActivatedOrNot();

        userController.startUserListening(
          userId: newUserModel.id,
          notificationProvider: notificationProvider,
        );

        if(context.mounted) {
          int myAge = 0;
          if(dateOfBirth != null){
            myAge =  MyUtils().getMyBirthDateFromTimeStamp(Timestamp.fromDate(dateOfBirth!));
          }
          AnalyticsController().fireEvent(analyticEvent: AnalyticsEvent.signup_success);
          AnalyticsController().fireEvent(analyticEvent: AnalyticsEvent.user_age,parameters: {AnalyticsParameters.event_value: myAge <=0 ? '' : '$myAge'});
          AnalyticsController().fireEvent(analyticEvent: AnalyticsEvent.user_gender,parameters: {AnalyticsParameters.event_value:gender ?? ""});
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
    AnalyticsController().fireEvent(analyticEvent: AnalyticsEvent.user_any_screen_view,parameters: {AnalyticsParameters.event_value:AnalyticsParameterValue.signup_screen});
    initializeValuesFromProvider();
  }

  @override
  Widget build(BuildContext context) {
    themeData = Theme.of(context);

    return WillPopScope(
      onWillPop: () async {
        await AuthenticationController(userProvider: userProvider).logout();
        return false;
      },
      child: ModalProgressHUD(
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
                            const SizedBox(height: 60,),
                            getTopDetails(),
                            const SizedBox(height: 80,),
                            getBasicInfo(),
                            const SizedBox(height: 80,),
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
      ),
    );
  }

  Widget getTopBar(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        InkWell(
          onTap: ()async{
           await AuthenticationController(userProvider: userProvider).logout();
          },
          child: Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
                color: Styles.myButtonBlack,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Styles.myVioletShade4)
            ),
            child: Icon(
              Icons.arrow_back_outlined,
              color: Styles.myVioletShade4,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget getTopDetails(){
    return  Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const CommonText(
          text: "Let us know you better,",
          fontSize: 27,
          textAlign: TextAlign.start,
          fontWeight: FontWeight.bold,
        ),
        const SizedBox(
          height: 9,
        ),
        const CommonText(
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
              margin: const EdgeInsets.symmetric(horizontal: 10.0),
              child: const Icon(
                Icons.cake,
                color: Colors.white,
                size: 23,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10,),
        InkWell(
          onTap: () async {
           bool? isMale = await showDialog(context: context,
                builder: (context){
                  return GenderSelectDialog(
                    isMale: gender == UserGender.male
                        ? true
                        : gender == UserGender.female ? false : null,
                  );
               }
            );

           if(isMale != null) {
             if(isMale){
               setState(() {
                 gender = UserGender.male;

               });
               MyPrint.printOnConsole('isthis male is');
             }else {
               setState(() {
                 gender = UserGender.female;
               });
               MyPrint.printOnConsole('isthis female is');
             }
           }
          },
          child: MyCommonTextField(
            //controller: userNameController,
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
        ),


      ],
    );
  }


  Widget letsPlayButton(){
    return CommonSubmitButton(
        onTap: (){
          if(_formKey.currentState!.validate()){
            /*if(!isAcceptedTerms) {
              MyToast.showError(context: context, msg: "Please accept T&C");
              return;
            }*/

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
        },
        text: "Let's Play"
    );
  }
















//region Garbage--------------------------------------------------------------------------------------------------------------------------------
//   Widget getDateOfBirthSelection() {
//     return GestureDetector(
//       onTap: () {
//         pickDate();
//       },
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 10),
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//         decoration: BoxDecoration(
//           border: Border.all(color: themeData.inputDecorationTheme.border?.borderSide.color ?? Colors.white70),
//           borderRadius: BorderRadius.circular(4),
//         ),
//         child: Row(
//           children: [
//             Icon(Icons.date_range, color: themeData.iconTheme.color?.withAlpha(150),),
//             const SizedBox(width: 13,),
//             Expanded(
//               child: Text.rich(
//                 TextSpan(
//                   text: dateOfBirth != null ? DatePresentation.ddMMyyyyFormatter(dateOfBirth!.millisecondsSinceEpoch.toString()) : "Select Date Of Birth",
//                   style: themeData.textTheme.titleSmall?.copyWith(
//                     color: themeData.textTheme.titleSmall!.color?.withAlpha(dateOfBirth != null ? 255 : 150),
//                   ),
//                   children: dateOfBirth == null ? [
//                     const TextSpan(
//                       text: ' *',
//                       style: TextStyle(color: Colors.red),
//                     ),
//                   ] : null,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   //region Gender Selection
//   Widget getGenderSelection() {
//     String? selectedGender;
//     List<String> gendersList = UserGender.values;
//     if(gendersList.isNotEmpty) {
//       if(!gendersList.contains(gender)) {
//         gender = null;
//       }
//       selectedGender = gender;
//     }
//
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 10),
//       child: Theme(
//         data: themeData.copyWith(
//           highlightColor: Colors.transparent,
//           // splashColor: Colors.transparent,
//         ),
//         child: DropdownButtonFormField<String>(
//           value: selectedGender,
//           onChanged: (String? value) {
//             gender = value;
//             setState(() {});
//           },
//           // hint: const Text("Select Gender"),
//           hint: Text.rich(
//             TextSpan(
//               text: "Select Gender",
//               style: themeData.textTheme.titleSmall?.copyWith(
//                 color: themeData.textTheme.titleSmall!.color?.withAlpha(150),
//               ),
//               children: const [
//                 TextSpan(
//                   text: ' *',
//                   style: TextStyle(color: Colors.red),
//                 ),
//               ],
//             ),
//           ),
//           style: themeData.textTheme.titleSmall,
//           dropdownColor: themeData.primaryColor,
//           // underline: const SizedBox(),
//           isExpanded: true,
//           decoration: InputDecoration(
//             prefixIcon: Icon(getGenderIconFromGenderString(gender: selectedGender)),
//             contentPadding: const EdgeInsets.all(5),
//           ),
//           items: gendersList.map((e) {
//             return DropdownMenuItem<String>(
//               value: e,
//               child: Text(e),
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }
//
//   IconData getGenderIconFromGenderString({required String? gender}) {
//     if(gender == UserGender.male) {
//       return Icons.male;
//     }
//     else if(gender == UserGender.female) {
//       return Icons.female;
//     }
//     else {
//       return Icons.transgender;
//     }
//   }
//   //endregion
//
//   Widget getTermsCondition() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Checkbox(
//           activeColor: themeData.primaryColor,
//           value: isAcceptedTerms,
//           onChanged: (bool? value) {
//             isAcceptedTerms = value!;
//             setState(() {});
//           },
//         ),
//         const CommonText(text:"Please accept ",fontSize: 14, ),
//         InkWell(
//           onTap: () {
//             DataController(dataProvider: Provider.of<DataProvider>(context, listen: false)).showTermsAndConditionBottomSheet(context: context);
//           },
//           child: Text(
//             "Terms and Conditions",
//             style: themeData.textTheme.labelLarge?.copyWith(
//               decoration: TextDecoration.underline,
//              ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget getSignUpButton() {
//     return CommonPrimaryButton(
//       text: "Submit",
//       onTap: () {
//         if(isAcceptedTerms) {
//           bool formValid = _formKey.currentState?.validate() ?? false;
//           bool dobValid = dateOfBirth != null;
//           bool genderValid = gender?.isNotEmpty ?? false;
//
//           MyPrint.printOnConsole("formValid:$formValid, dobValid:$dobValid, genderValid:$genderValid");
//
//           if(formValid && dobValid && genderValid) {
//             updateUserData();
//           }
//           else if(!formValid) {
//
//           }
//           else if(!dobValid) {
//             MyToast.showError(context: context, msg: "Date Of Birth is Mandatory");
//           }
//           else if(!genderValid) {
//             MyToast.showError(context: context, msg: "Gender is Mandatory");
//           }
//           else {
//
//           }
//         }
//         else {
//           MyToast.showError(context: context, msg: "Please accept T&C");
//         }
//       },
//       filled: true,
//     );
//   }
//
//   Widget getLoginWithAnotherAccountLink() {
//     return InkWell(
//       onTap: () {
//         AuthenticationController(userProvider: userProvider).logout();
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 3),
//         child: Text(
//           "Login With Another Account",
//           style: themeData.textTheme.labelLarge?.copyWith(
//             decoration: TextDecoration.underline,
//             color: themeData.textTheme.labelLarge!.color?.withOpacity(0.6),
//             fontSize: 12,
//           ),
//         ),
//       ),
//     );
//   }
 //endregion



}


// class GenderSelectDialog extends StatefulWidget {
//    bool? isMale;
//    GenderSelectDialog ({this.isMale});
//
//   @override
//   State<GenderSelectDialog> createState() => _GenderSelectDialogState();
// }

class GenderSelectDialog extends StatelessWidget {

  bool? isMale;
  GenderSelectDialog({this.isMale});

  @override
  Widget build(BuildContext context) {

    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: Container(
        padding: const EdgeInsets.symmetric(vertical: 20,horizontal: 20),
        decoration: BoxDecoration(
          color: Styles.myDialogBackground,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: getMaleAndFemaleView(context: context,isMale: true,isSelected:isMale == true  )),
            const SizedBox(width: 10,),
            Expanded(child: getMaleAndFemaleView(context: context,isMale: false,isSelected: isMale == false)),
          ],
        ),
      ),
    );
  }

  Widget getMaleAndFemaleView({required bool isMale, bool isSelected = false,required BuildContext context}){

    return InkWell(
      onTap: (){
        Navigator.pop(context,isMale);

      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Styles.myLightPinkShade1 : Colors.transparent,
            width: 2
          )
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(isMale?'assets/images/male.png':'assets/images/female.png',height: 55,width: 55,),
            const SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(isMale?Icons.male:Icons.female,size: 17,color: Colors.white,),
                const SizedBox(width: 5,),
                CommonText(text: isMale?'Male':'Female',fontSize: 15,),
              ],
            )
          ],
        ),
      ),
    );

  }


}
