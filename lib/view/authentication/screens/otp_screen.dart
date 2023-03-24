import 'dart:async';

import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:okoto/backend/analytics/analytics_event.dart';
import 'package:okoto/view/common/components/common_back_button.dart';
import 'package:provider/provider.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:timer_count_down/timer_count_down.dart';

import '../../../backend/analytics/analytics_controller.dart';
import '../../../backend/navigation/navigation.dart';
import '../../../backend/notification/notification_provider.dart';
import '../../../backend/user/user_controller.dart';
import '../../../backend/user/user_provider.dart';
import '../../../configs/styles.dart';
import '../../../utils/my_print.dart';
import '../../../utils/my_toast.dart';
import '../../../utils/parsing_helper.dart';
import '../../common/components/common_loader.dart';
import '../../common/components/common_primary_button.dart';
import '../../common/components/common_submit_button.dart';
import '../../common/components/common_text.dart';
import '../../common/components/modal_progress_hud.dart';
import '../../common/components/pin_put.dart';
import 'login_screen.dart';

class OtpScreen extends StatefulWidget {
  static const String routeName = "/OtpScreen";
  final String mobile;

  const OtpScreen({Key? key, required this.mobile}) : super(key: key);

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  late ThemeData themeData;
  
  TextEditingController? _otpController;
  FocusNode? _otpFocusNode;
  CountDownController? controller;

  bool isInVerification = false;
  String msg = "", otpErrorMsg = "";
  bool msgshow = false,
      isShowOtpErrorMsg = false,
      isOTPTimeout = false,
      isShowResendOtp = false,
      isLoading = false,
      isOTPSent = false,
      isOtpEnabled = false,
      isTimerOn = false,
      isOtpSending = false;
  String? verificationId;

  double otpDuration = 120.0;

  Future registerUser(String mobile) async {
    MyPrint.printOnConsole("Register User Called for mobile:$mobile");

    try {} catch (e) {
      //_controller.restart();
    }

    changeMsg("Please wait ! \nOTP is on the way.");

    FirebaseAuth auth = FirebaseAuth.instance;
    // String otp = "";

    isOTPTimeout = false;
    isOTPSent = false;
    isOtpEnabled = false;
    isOtpSending = true;
    _otpController!.text = "";
    isTimerOn = false;
    if (mounted) setState(() {});

    await auth.verifyPhoneNumber(
      phoneNumber: mobile,
      timeout: Duration(seconds: otpDuration.toInt()),
      verificationCompleted: (AuthCredential credential) {
        MyPrint.printOnConsole("Automatic Verification Completed");

        verificationId = null;
        isOTPSent = false;
        isShowResendOtp = false;
        isOtpEnabled = false;
        otpErrorMsg = "";
        if (mounted) setState(() {});
        changeMsg("Now, OTP received.\nSystem is preparing to login.");
        auth
            .signInWithCredential(credential)
            .then((UserCredential credential) async {
          await onSuccess(credential.user!);
        }).catchError((e) {
          MyPrint.printOnConsole(e);
        });
      },
      verificationFailed: (FirebaseAuthException e) {
        MyPrint.printOnConsole("Error in Automatic OTP Verification:${e.message!}");
        verificationId = null;
        changeMsg("Error in Automatic OTP Verification:${e.code}");
        isShowResendOtp = true;
        isOTPTimeout = true;
        isOtpEnabled = false;
        isOtpSending = false;
        otpErrorMsg = "";
        isTimerOn = false;

        //_otpController?.text = "";
        if (mounted) setState(() {});
        MyToast.showError(context: context, msg: "Try Again");
        //_otpController?.text = "";
      },
      codeSent: (verificationId, [forceResendingToken]) {
        AnalyticsController().fireEvent(analyticEvent: AnalyticsEvent.otp_sending_success);
        MyPrint.printOnConsole("OTP Sent");
        MyToast.showSuccess(context: context, msg: "Otp Sent");
        //MyToast.showSuccess("OTP sent to your mobile", context);
        this.verificationId = verificationId;
        // istimer = true;
        //_otpController?.text = "";
        otpErrorMsg = "";

        isOTPSent = true;
        isShowResendOtp = true;
        isOtpEnabled = true;
        isOtpSending = false;
        isTimerOn = true;
        if (mounted) setState(() {});

        //startTimer();

        // _otpFocusNode?.requestFocus();

        //_smsReceiver.startListening();

        changeMsg("OTP Sent!");
      },
      codeAutoRetrievalTimeout: (val) {
        MyPrint.printOnConsole("Automatic Verification Timeout");
        verificationId = null;
        //_otpController?.text = "";
        isOTPTimeout = true;
        isShowResendOtp = true;
        msg = "Timeout";
        isOtpEnabled = false;
        otpErrorMsg = "";
        isTimerOn = false;
        if(context.mounted) {
          setState(() {});
          MyToast.showError(context: context, msg: "Try Again");
        }
      },
    );

    MyPrint.printOnConsole("Registration Finished");
  }

  //Here otp is the code recieved in text message
  //verificationId is code we get in codeSent method of _auth.verifyPhoneNumber()
  //Method prints String "Verification Successful" if otp verified successfully
  //Method prints String "Verification Failed" if otp verification fails
  Future<bool> verifyOTP({@required String? otp, @required String? verificationId}) async {
    MyPrint.printOnConsole("Verify OTP Called");

    setState(() {
      isLoading = true;
    });

    try {
      MyPrint.printOnConsole("OTP Entered To Verify:${otp!}");
      //MyPrint.printOnConsole("VerificationId:"+verificationId);
      FirebaseAuth auth = FirebaseAuth.instance;

      AuthCredential authCredential = PhoneAuthProvider.credential(
          verificationId: verificationId!, smsCode: otp);
      UserCredential userCredential =
          await auth.signInWithCredential(authCredential);

      changeMsg("OTP Verified!\nTaking to homepage.");
      await onSuccess(userCredential.user!);

      setState(() {
        isShowOtpErrorMsg = false;
        isLoading = false;
      });

      return true;
    } on FirebaseAuthException catch (e) {
      MyPrint.printOnConsole("Error in Verifying OTP in Auth_Service:${e.code}");

      if (e.code == "invalid-verification-code") {
        MyToast.showError(context: context, msg: "Wrong OTP");
      }

      setState(() {
        otpErrorMsg = e.message!;
        isShowOtpErrorMsg = true;
      });

      setState(() {
        isLoading = false;
      });

      return false;
    }
  }

  Future onSuccess(User user) async {
    AnalyticsController().fireEvent(analyticEvent: AnalyticsEvent.otp_filing_success);
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    UserController userController = UserController(userProvider: userProvider);

    NotificationProvider notificationProvider = Provider.of<NotificationProvider>(context, listen: false);

    userProvider.setUserId(userId: user.uid, isNotify: false);
    userProvider.setFirebaseUser(user: user, isNotify: false);

    MyPrint.printOnConsole("Email:${user.email}");
    MyPrint.printOnConsole("Mobile:${user.phoneNumber}");


    bool isExist = await userController.checkUserWithIdExistOrNotAndIfNotExistThenCreate(
      userId: user.uid,
    );
    MyPrint.printOnConsole("isExist:$isExist");

    if (isExist && (userProvider.getUserModel()?.isHavingNecessaryInformation() ?? false)) {
      MyPrint.printOnConsole("User Exist");

      await userController.updateNotificationTokenForUserAndStoreInProvider(
        userId: user.uid,
        notificationProvider: notificationProvider,
      );

      await userController.checkSubscriptionActivatedOrNot();

      userController.startUserListening(
        userId: user.uid,
        notificationProvider: notificationProvider,
      );

      if(context.mounted) {
        // NavigationController.navigateToHomeTempScreen(navigationOperationParameters: NavigationOperationParameters(
        //   context: context,
        //   navigationType: NavigationType.pushNamedAndRemoveUntil,
        // ));
        AnalyticsController().fireEvent(analyticEvent: AnalyticsEvent.login_success);
        NavigationController.navigateToHomeScreen(navigationOperationParameters: NavigationOperationParameters(
          context: context,
          navigationType: NavigationType.pushNamedAndRemoveUntil,
        ));
      }
    }
    else {
      MyPrint.printOnConsole("User Not Exist");
      MyPrint.logOnConsole("Created:${userProvider.getUserModel()}");
      if(context.mounted) {
        AnalyticsController().fireEvent(analyticEvent: AnalyticsEvent.signup_started);
        NavigationController.navigateToSignUpScreen(navigationOperationParameters: NavigationOperationParameters(
          context: context,
          navigationType: NavigationType.pushNamed,
        ));
      }
    }
  }

  void changeMsg(String m) async {
    msg = m;
    msgshow = true;
    if (mounted) setState(() {});
    /*await Future.delayed(Duration(seconds: 5));
    setState(() {
      msgshow = false;
    });*/
  }

  bool checkEnabledVerifyButton() {
    if (_otpController?.text.length == 6) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
    _otpFocusNode = FocusNode();
    AnalyticsController().fireEvent(analyticEvent: AnalyticsEvent.user_any_screen_view,parameters: {AnalyticsParameters.event_value:AnalyticsParameterValue.otp_screen});
    // _otpFocusNode!.requestFocus();
    controller = CountDownController();
    registerUser(widget.mobile);
  }

  @override
  void dispose() {
    try {
      _otpController!.dispose();
      _otpFocusNode!.dispose();
    } catch (e, s) {
      MyPrint.printOnConsole("Error in Disposing _otpController and _otpFocusNode in OtpScreen.dispose:$e");
      MyPrint.printOnConsole(s);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    themeData = Theme.of(context);
    // double size = 80;
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      // progressIndicator: const SpinKitFadingCircle(color: Colors.blue,),
      progressIndicator: CommonLoader(),
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
              stops: [0.8,.99],
            ),),
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child:Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        getTopShapeAndIllustrate(),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5).copyWith(top: 65),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              getTopPageDetails(),
                              SizedBox(height: 35,),
                              getOTPFillTextField(),
                              getSendingOTP(),
                              getRemainTime(),
                              getResendCode(),
                              SizedBox(height: 40,),
                              submitButton(),
                            ],
                          ),
                        ),
                      ],
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
          size: Size(double.maxFinite, 320),
          painter: TopCustomShape(),
        ),
        Positioned(
          bottom: -50,
          left: 0,
          right: 0,
          child: Container(
            width: 280,
            height: 280,
            child: Image.asset(
              "assets/images/login_illu.png",
            ),
          ),
        ),
        Positioned(
          top: 60,
          left: 25,
          child: CommonBackButton(),
        )
      ],
    );
  }

  Widget getTopPageDetails() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        CommonText(
          text: "Enter the OTP",
          fontSize: 26,
          textAlign: TextAlign.center,
          fontWeight: FontWeight.bold,
        ),
        SizedBox(
          height: 10,
        ),
        CommonText(
          text: "Enter the OTP code we just sent you on your given Phone Number",
          fontSize: 15.5,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget getOTPFillTextField(){
    BoxDecoration generalDecoration = BoxDecoration(
      border: Border(bottom: BorderSide(color: Styles.myLightVioletShade3,width: 1.8),),
    );
    BoxDecoration selectedFieldDecoration = BoxDecoration(
      border: Border(bottom: BorderSide(color: Styles.myLightPinkShade,width: 1.8),),
    );
    return PinPut(
      fieldsCount: 6,
      onSubmit: (String pin) {
        MyPrint.printOnConsole("Submitted:$pin");
        _otpFocusNode!.unfocus();
      },
      checkClipboard: true,
      onClipboardFound: (String? string) {
        _otpController!.text = string ?? "";
      },
      enabled: true,
      focusNode: _otpFocusNode,
      controller: _otpController,
      eachFieldWidth: 45,
     // eachFieldHeight: 50,
      inputDecoration: const InputDecoration(
        contentPadding: EdgeInsets.zero,
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        counterText: '',
      ),
      submittedFieldDecoration:generalDecoration,
      selectedFieldDecoration: selectedFieldDecoration,
      followingFieldDecoration:generalDecoration,
      textStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget getRemainTime(){
    if (!isTimerOn) return const SizedBox.shrink();
    formatedTime({required double timeInSecond}) {
      int time = ParsingHelper.parseIntMethod(timeInSecond);
      int sec = time % 60;
      int min = (time / 60).floor();
      String minute = min.toString().length <= 1 ? "0$min" : "$min";
      String second = sec.toString().length <= 1 ? "0$sec" : "$sec";
      return "$minute:$second";
    }
    return Padding(
      padding:  EdgeInsets.only(top: 40.0,bottom: 0),
      child: Row(
         children: [
           Countdown(
             // controller: _controller,
             seconds: otpDuration.toInt(),
             build: (_, double time) =>
                 GradientText(
                   formatedTime(timeInSecond: time),
                   textAlign: TextAlign.start,
                   style: TextStyle(

                     fontWeight: FontWeight.w700,
                     letterSpacing: 1.1,
                     fontSize: 19,
                     // decoration: TextDecoration.underline,

                   ),
                   gradientDirection: GradientDirection.ttb,
                   colors: [
                     //Styles.myLightVioletShade3,
                     Styles.myLightVioletShade3,
                     Styles.myLightPinkShade,
                   ],
                 ),
             //     CommonText(
             //  text: formatedTime(timeInSecond: time),
             //   //color: Styles.myLightVioletShade3,
             //   color: Styles.myLightPinkShade,
             //   fontSize: 19,
             //   fontWeight: FontWeight.w700,
             // ),
             interval: Duration(seconds: 1),
             onFinished: () {

               },
           ),
         ],
       ),
    );
  }

  Widget getSendingOTP() {
    if(!isOtpSending) return const SizedBox();
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20).copyWith(top: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SpinKitDualRing(
            color: Styles.myLightPinkShade,
            duration: const Duration(milliseconds: 500),
            size: 25,
            lineWidth: 1,
          ),
          SizedBox(height: 10,),
          CommonText(
            text: 'Sending OTP....',
           // color: Styles.myLightVioletShade3,
            color: Styles.myLightPinkShade,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ],
      ),
    );
  }

  Widget getResendCode(){
  //  if (!isOTPTimeout) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          GradientText(
            "Didn't receive code? ",
            textAlign: TextAlign.start,
            style: TextStyle(

              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
              fontSize: 17,
              // decoration: TextDecoration.underline,

            ),
            gradientDirection: GradientDirection.ttb,
            colors: [
              Styles.myLightVioletShade3,
              Styles.myLightVioletShade3,
              Styles.myLightPinkShade,
            ],
          ),
          InkWell(
            onTap: (){
              AnalyticsController().fireEvent(analyticEvent: AnalyticsEvent.resend_otp);
              registerUser(widget.mobile);
            },
            child: GradientText(
              "Resend",
              textAlign: TextAlign.start,
              style: TextStyle(

                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
                fontSize: 17,
                decoration: TextDecoration.underline,
                decorationThickness: 1.5

              ),
              gradientDirection: GradientDirection.ttb,
              colors: [
                Styles.myLightVioletShade3,
                Styles.myLightVioletShade3,
                Styles.myLightPinkShade,
            ],
            ),
          ),
        ],
      ),
    );
  }

  Widget submitButton(){
    return  CommonSubmitButton(
      text: 'Submit',
      onTap: () async {
        FocusScope.of(context).requestFocus(FocusNode());

        if (isOTPSent) {
          if (!checkEnabledVerifyButton()) {
            MyPrint.printOnConsole("Invalid Otp");
            setState(() {
              isShowOtpErrorMsg = true;
              otpErrorMsg = "OTP should be of 6 digits";
            });
          }
          else {
            MyPrint.printOnConsole("Valid OTP");
            setState(() {
              isShowOtpErrorMsg = false;
              otpErrorMsg = "";
            });

            if (verificationId != null) {
              String? otp = _otpController?.text;

              /*bool result = */await verifyOTP(otp: otp, verificationId: verificationId);
            }
            else {
              MyToast.showError(context: context, msg: "OTP Expired, Please Resend");
            }
          }
        }
        else {
          MyPrint.printOnConsole("Otp Not Sent");
          MyToast.showError(context: context, msg: 'OTP not found');
        }
      },
    );
  }

}


