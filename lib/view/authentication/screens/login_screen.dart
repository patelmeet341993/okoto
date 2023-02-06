import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:okoto/view/common/components/common_loader.dart';

import '../../../backend/navigation/navigation.dart';
import '../../../utils/my_print.dart';
import '../../common/components/common_primary_button.dart';
import '../../common/components/modal_progress_hud.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = "/LoginScreen";

  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late ThemeData themeData;

  bool isFirst = true, isLoading = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController? mobileController;

  void sendOtp() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // if all are valid then go to success screens

      NavigationController.navigateToOtpScreen(
        navigationOperationParameters: NavigationOperationParameters(
          context: context,
          navigationType: NavigationType.pushNamedAndRemoveUntil,
        ),
        arguments: OtpScreenNavigationArguments(mobileNumber: "+91${mobileController!.text}"),
      );
    }
  }

  @override
  void initState() {
    mobileController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    MyPrint.printOnConsole("LoginScreen called");
    themeData = Theme.of(context);

    return ModalProgressHUD(
      inAsyncCall: isLoading,
      color: Colors.black,
      progressIndicator: Container(
        padding: const EdgeInsets.all(100),
        child: Center(
          child: Container(
            height: 90,
            width: 90,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: const CommonLoader(),
          ),
        ),
      ),
      child: Scaffold(
        body: Container(
          padding: const EdgeInsets.only(top: 0),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Center(
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          getLogo(),
                          getLoginText(),
                          getLoginText2(),
                          getMobileTextField(),
                          getContinueButton(),
                          const SizedBox(height: 10,),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getLogo() {
    double width = MediaQuery.of(context).size.width * 0.7;

    return Container(
      // color: Colors.red,
      margin: const EdgeInsets.only(bottom: 34),
      width: width,
      height: width,
      child: Image.asset("assets/images/otp illustration.png"),
    );
  }

  Widget getLoginText() {
    return InkWell(
      onTap: ()async{

      },
      child: Container(
        margin: const EdgeInsets.only(left: 16, right: 16),
        child: Center(
          child: Text(
            "To access your account",
            style: themeData.textTheme.headlineSmall?.copyWith(
              // fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget getLoginText2() {
    return Container(
      margin: const EdgeInsets.only(left: 48, right: 48, top: 20),
      child: Text(
        "We will send  you a one time password to your registered mobile number",
        softWrap: true,
        style: themeData.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            height: 1.2,
            color: themeData.colorScheme.onBackground.withAlpha(200),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget getMobileTextField() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30).copyWith(top: 36),
      child: Column(
        children: [
          // const Text("Enter Mobile Number"),
          const SizedBox(height: 10,),
          TextFormField(
            controller: mobileController,
            style: themeData.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            // textAlign: TextAlign.center,
            decoration: InputDecoration(
              labelText: "Enter Mobile",
              labelStyle: themeData.textTheme.titleMedium?.copyWith(
                color: themeData.colorScheme.onPrimary.withOpacity(0.5),
              ),
              prefixText: "+91 ",
              prefixStyle: themeData.textTheme.titleMedium?.copyWith(
                // color: themeData.colorScheme.onPrimary.withOpacity(0.5),
              ),
              border: UnderlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(8.0),),
                borderSide: BorderSide(color: themeData.colorScheme.secondary),
                // borderSide: BorderSide(color: Styles.onBackground),
              ),
              enabledBorder: UnderlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(8.0),),
                borderSide: BorderSide(color: themeData.colorScheme.secondary),
              ),
              focusedBorder: UnderlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(8.0),),
                borderSide: BorderSide(color: themeData.colorScheme.secondary),
              ),
              prefixIcon: const Icon(
                Icons.phone,
                size: 22,
                // color: Styles.onBackground.withAlpha(200),
              ),
              isDense: false,
              contentPadding: const EdgeInsets.all(10),
            ),
            keyboardType: TextInputType.number,
            autofocus: false,
            textCapitalization: TextCapitalization.sentences,
            inputFormatters: [
              LengthLimitingTextInputFormatter(10),
              FilteringTextInputFormatter.digitsOnly,
            ],
            validator: (val) {
              if(val == null || val.isEmpty) {
                return "Mobile Number Cannot be empty";
              }
              else {
                if (RegExp(r"^\d{10}").hasMatch(val)) {
                  return null;
                }
                else {
                  return "Invalid Mobile Number";
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget getContinueButton() {
    return CommonPrimaryButton(
      onTap: () {
        sendOtp();
      },
      text: "Get OTP",
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20).copyWith(bottom: 10),
    );

    /*return Container(
      margin: const EdgeInsets.only(left: 24, right: 24, top: 24),
      decoration: const BoxDecoration(
        borderRadius:
        BorderRadius.all(Radius.circular(48)),
      ),
      child: FlatButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: themeData.primaryColor,
        highlightColor: themeData.primaryColor,
        splashColor: Colors.white.withAlpha(100),
        padding: const EdgeInsets.only(top: 16, bottom: 16),
        onPressed: sendOtp,
        child: Stack(
          //overflow: Overflow.visible,
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: <Widget>[
            const Align(
              alignment: Alignment.center,
              child: Text(
                "CONTINUE",
                style: TextStyle(
                    color: Colors.white,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Positioned(
              right: 16,
              child: ClipOval(
                child: Container(
                  color: Colors.white,
                  // button color
                  child: SizedBox(
                      width: 30,
                      height: 30,
                      child: Icon(
                        Icons.arrow_forward,
                        color: themeData.primaryColor,
                        size: 18,
                      )),
                ),
              ),
            ),
          ],
        ),
      ),
    );*/
  }
}
