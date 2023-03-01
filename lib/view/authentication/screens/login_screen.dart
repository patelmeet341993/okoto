import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:okoto/view/common/components/common_loader.dart';
import 'package:okoto/view/common/components/common_submit_button.dart';
import 'package:okoto/view/common/components/my_common_textfield.dart';

import '../../../backend/navigation/navigation.dart';
import '../../../configs/styles.dart';
import '../../../utils/my_print.dart';
import '../../common/components/common_text.dart';
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
          navigationType: NavigationType.pushNamed,
        ),
        arguments: OtpScreenNavigationArguments(
          mobileNumber: "+91${mobileController!.text}",
        ),
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
          decoration: BoxDecoration(
            gradient: LinearGradient(
            colors: [
              Styles.myDarkVioletColor,
              Styles.myDarkVioletShade1,
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            stops: const [0.8,.99 ,],

          ),),
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          getTopShapeAndIllustrate(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5).copyWith(top: 65),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(
                                  height: 20,
                                ),
                                getTopPageDetails(),
                                const SizedBox(
                                  height: 60,
                                ),
                                getMobileNumberTextField(),
                                const SizedBox(
                                  height: 60,
                                ),
                                CommonSubmitButton(
                                  text: 'Get OTP',
                                  onTap: () {
                                    sendOtp();
                                  },
                                )
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

  Widget getTopShapeAndIllustrate() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CustomPaint(
          size: const Size(double.maxFinite, 320),
          painter: TopCustomShape(),
        ),
        Positioned(
          bottom: -50,
          left: 0,
          right: 0,
          child: SizedBox(
            width: 280,
            height: 280,
            child: Image.asset(
              "assets/images/login_illu.png",
            ),
          ),
        ),
      ],
    );
  }

  Widget getTopPageDetails() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: const [
        CommonText(
          text: "Welcome  Gamer !",
          fontSize: 26,
          textAlign: TextAlign.center,
          fontWeight: FontWeight.bold,
        ),
        SizedBox(
          height: 10,
        ),
        CommonText(
          text: "Login/Signup to start your VR Gaming Journey",
          fontSize: 15.5,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget getMobileNumberTextField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          const CommonText(
            text: "Enter Mobile Number",
            fontSize: 14,
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 2,
          ),
          MyCommonTextField(
            controller: mobileController,
            prefixText: "+91    ",
            cursorColor: Colors.white,
            prefix: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Image.asset(
                "assets/images/indian_flag.png",
                height: 20,
                width: 26,
                fit: BoxFit.fill,
              ),
            ),
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
            textInputType: TextInputType.number,
            textInputFormatter: [
              LengthLimitingTextInputFormatter(10),
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
        ],
      ),
    );
  }

//region Garbage-----------------------------------------------------------------------------------------------------------------------------------------
/*
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
      onTap: () async {},
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
          const SizedBox(
            height: 10,
          ),
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
                borderRadius: const BorderRadius.all(
                  Radius.circular(8.0),
                ),
                borderSide: BorderSide(color: themeData.colorScheme.secondary),
                // borderSide: BorderSide(color: Styles.onBackground),
              ),
              enabledBorder: UnderlineInputBorder(
                borderRadius: const BorderRadius.all(
                  Radius.circular(8.0),
                ),
                borderSide: BorderSide(color: themeData.colorScheme.secondary),
              ),
              focusedBorder: UnderlineInputBorder(
                borderRadius: const BorderRadius.all(
                  Radius.circular(8.0),
                ),
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
              if (val == null || val.isEmpty) {
                return "Mobile Number Cannot be empty";
              } else {
                if (RegExp(r"^\d{10}").hasMatch(val)) {
                  return null;
                } else {
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
  }

  */
//endregion------------------------------------------------------------------------------------------------

}

class TopCustomShape extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = Styles.myVioletShade2;
    paint.shader = LinearGradient(
      colors: [
        Styles.myBlueColor.withAlpha(-85),
        Styles.myBorderVioletColor,
        //Styles.myVioletShade1,
        Styles.myVioletColor,
        Styles.myLightVioletShade1,
      ],
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      //stops: [0.0,0.2,0.8, 30,],
      stops: const [0.001,0.25,0.8,1,],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    paint.style = PaintingStyle.fill;
    paint.strokeWidth = 6.0;

    var path = Path();
    path.conicTo(0, size.height, size.width, size.height / 2, 180);
    path.moveTo(size.width, size.height / 2);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

