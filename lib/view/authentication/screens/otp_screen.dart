import 'dart:async';

import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:okoto/view/common/components/common_back_button.dart';
import 'package:provider/provider.dart';
import 'package:timer_count_down/timer_count_down.dart';

import '../../../backend/navigation/navigation.dart';
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

        _otpFocusNode?.requestFocus();

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
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    UserController userController = UserController(userProvider: userProvider);

    userProvider.setUserId(userId: user.uid, isNotify: false);
    userProvider.setFirebaseUser(user: user, isNotify: false);

    MyPrint.printOnConsole("Email:${user.email}");
    MyPrint.printOnConsole("Mobile:${user.phoneNumber}");

    bool isExist = await userController.checkUserWithIdExistOrNotAndIfNotExistThenCreate(userId: user.uid);
    MyPrint.printOnConsole("isExist:$isExist");

    if (isExist && (userProvider.getUserModel()?.isHavingNecessaryInformation() ?? false)) {
      MyPrint.printOnConsole("User Exist");

      await userController.checkSubscriptionActivatedOrNot();

      if(context.mounted) {
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
             build: (_, double time) => CommonText(
              text: formatedTime(timeInSecond: time),
               //color: Styles.myLightVioletShade3,
               color: Styles.myLightPinkShade,
               fontSize: 19,
               fontWeight: FontWeight.w700,
             ),
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
          InkWell(
            onTap: (){
              registerUser(widget.mobile);
            },
            child: Text(
              "Didn't receive code? Resend",
              textAlign: TextAlign.start,
              style: TextStyle(
                color: Styles.myLightVioletShade3,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
                fontSize: 18,
                decoration: TextDecoration.underline,

              ),
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


//region Garbage--------------------------------------------------------------------------------------------------------------------------------------------

  Widget getAppBar() {
    return Row(
      children: [
        InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          splashColor: Colors.red,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.arrow_back_ios,
              color: Colors.blue,
            ),
          ),
        ),
      ],
    );
  }

  Widget getLogo() {
    double width = MediaQuery.of(context).size.width * 0.6;

    return Container(
      // color: Colors.red,
      margin: const EdgeInsets.only(bottom: 34),
      width: width,
      height: width,
      child: Image.asset("assets/images/otp illustration.png"),
    );
  }

  Widget getOTPVerificationText() {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16),
      child: Center(
        child: Text(
          "OTP Verification",
          style: themeData.textTheme.headlineSmall?.copyWith(
            // fontSize: 26,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget getLoginText2() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Text.rich(
        TextSpan(
          text: "Enter the OTP sent to ",
          style: themeData.textTheme.titleSmall?.copyWith(
            color: themeData.colorScheme.onBackground.withAlpha(150),
              /*fontWeight: FontWeight.w500,
              height: 1.2,
              color: themeData.colorScheme.onBackground.withAlpha(200),*/
          ),
          children: [
            TextSpan(
              text: widget.mobile,
              style: themeData.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  /*height: 1.2,
                  color: themeData.colorScheme.onBackground.withAlpha(200),*/
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget getOtpWidget() {
    BoxDecoration pinPutDecoration = BoxDecoration(
      color: themeData.colorScheme.secondary,
      // border: Border.all(color: Colors.blue),
      // border: Border.all(color: themeData.backgroundColor),
      border: Border.all(color: Colors.transparent),
      borderRadius: BorderRadius.circular(5),
    );

    /*BoxDecoration disabledPinPutDecoration = BoxDecoration(
      border: Border.all(color: Colors.blue),
      borderRadius: BorderRadius.circular(5),
    );*/

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      //color: Colors.red,
      child: PinPut(
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
        eachFieldWidth: 50,
        eachFieldHeight: 50,
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
        submittedFieldDecoration: pinPutDecoration.copyWith(
          color: themeData.colorScheme.primary,
        ),
        selectedFieldDecoration: pinPutDecoration.copyWith(
          color: themeData.colorScheme.primary,
        ),
        disabledDecoration: pinPutDecoration,
        followingFieldDecoration: pinPutDecoration.copyWith(
          borderRadius: BorderRadius.circular(5.0),
          border: Border.all(
            // color: themeData.backgroundColor,
            color: Colors.transparent,
          ),
        ),
        //disabledDecoration: _pinPutDecoration,
        textStyle: const TextStyle(
          // color: ,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          // fontFamily: Styles.SulSans_Regular,
        ),
      ),
    );

    /*return Container(
      child: Row(
        children: [
          getSingleOtpField(controller: _otp1Controller!, focusNode: _otp1FocusNode!),
          SizedBox(width: 20!,),
          getSingleOtpField(controller: _otp2Controller!, focusNode: _otp2FocusNode!),
          SizedBox(width: 20!,),
          getSingleOtpField(controller: _otp3Controller!, focusNode: _otp3FocusNode!),
          SizedBox(width: 20!,),
          getSingleOtpField(controller: _otp4Controller!, focusNode: _otp4FocusNode!),
        ],
      ),
    );*/
  }

  Widget getResendLinkWidget() {
    if (!isOTPTimeout) return const SizedBox.shrink();

    return InkWell(
      onTap: () {
        registerUser(widget.mobile);
      },
      child: const Text(
        "Resend",
        style: TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.w800,
          fontSize: 18,
          // fontFamily: Styles.SulSans_Regular,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget getSubmitButton() {
    return CommonPrimaryButton(
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
              MyToast.showError(context: context, msg: "OTP Expired, Plase Resend");
            }
          }
        }
        else {
          MyPrint.printOnConsole("Otp Not Sent");
        }
      },
      text: "Verify",
    );
  }

  Widget getMessageText(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Visibility(
        visible: msgshow,
        child: Text(
          text,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget getOtpSendingWidget() {
    if(!isOtpSending) return const SizedBox();

    return Center(
      child: Column(
        children: const [
          CommonLoader(),
          SizedBox(height: 10,),
          Text("Sending OTP...")
        ],
      ),
    );
  }

  Widget getTimer() {
    if (!isTimerOn) return const SizedBox.shrink();

    return CircularCountDownTimer(
      controller: controller,
      width: 100,
      height: 100,
      duration: otpDuration.toInt(),
      initialDuration: 0,
      //ringColor: isTimerOn ? themeData.primaryColor.withAlpha(100) : Colors.white,
      ringColor: Colors.transparent,
      //fillColor: themeData.primaryColor,
      fillColor: Colors.transparent,
      isReverse: true,
      isReverseAnimation: true,
      textStyle: const TextStyle(
        color: Colors.blue,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        // fontFamily: Styles.SulSans_Bold,
      ),
      strokeWidth: 5,
      textFormat: "mm:ss",
      strokeCap: StrokeCap.round,
      onComplete: () {
        /*isTimerOn = false;
        if (mounted) setState(() {});*/
      },
    );
  }

  Widget getOtpErrorMessageText(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Visibility(
        visible: isShowOtpErrorMsg,
        child: Text(
          text,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget getMobileNumberText(String mobile) {
    return Text(
      "+91-$mobile",
      style: const TextStyle(
        fontWeight: FontWeight.w500,
        color: Colors.red,
      ),
    );
  }

  Widget getLoadingWidget(bool isLoading) {
    return Column(
      children: [
        Visibility(
          visible: isLoading,
          child: const CircularProgressIndicator(
            color: Colors.red,
            strokeWidth: 4,
          ),
        ),
        Visibility(
          visible: isLoading,
          child: const SizedBox(
            height: 30,
          ),
        )
      ],
    );
  }

  Widget getOtp1Widget() {
    return Container(
        height: 48,
        margin: const EdgeInsets.symmetric(horizontal: 4),
    color: Colors.transparent,
    child: TextFormField(
    controller: _otpController,
        focusNode: _otpFocusNode,
        onChanged: (val) {
          if(val.length == 6) _otpFocusNode?.unfocus(disposition: UnfocusDisposition.scope);
        },
        enabled: isOtpEnabled,
        textAlign: TextAlign.center,
        decoration: const InputDecoration(
          helperText: "",
        ),
        inputFormatters: [
          LengthLimitingTextInputFormatter(6),
          FilteringTextInputFormatter.digitsOnly,
        ],
        keyboardType: TextInputType.number,
        maxLines: 1,
        style: const TextStyle(letterSpacing: 3),
      ),
    );
  }

  Widget getResendButtonAndTimer() {
    if (isShowResendOtp) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          isOTPTimeout
              //Resend Button
              ? Visibility(
                  visible: isOTPTimeout,
                  child: MaterialButton(
                    onPressed: () {
                      registerUser(widget.mobile);
                    },
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 32),
                    color: Colors.transparent,
                    splashColor: Colors.white,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.green,
                          style: BorderStyle.solid,
                          width: 1,
                        ),
                      ),
                      child: const Text(
                        "Resend OTP",
                      ),
                    ),
                  ),
                )
              //Timer
              : Visibility(
                  visible: !isOTPTimeout,
                  child: Row(
                    children: [
                      const Text(
                        "Resend in ",
                      ),
                      TweenAnimationBuilder(
                        tween: Tween(begin: otpDuration, end: 0.0),
                        duration: Duration(seconds: otpDuration.toInt()),
                        builder: (BuildContext context, double value,
                            Widget? child) {
                          int minutes =
                              Duration(seconds: value.toInt()).inMinutes;
                          int remainingSeconds = value.toInt() - (minutes * 60);

                          // NumberFormat numberFormat = NumberFormat("##");

                          return Text(
                            "$minutes : $remainingSeconds",
                          );
                        },
                      ),
                    ],
                  ),
                ),
        ],
      );
    } else {
      return const Spacer();
    }
  }

  Widget getVerifyButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withAlpha(24),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: InkWell(
        onTap: () async {
          if(isOTPSent) {
            if (!checkEnabledVerifyButton()) {
              MyPrint.printOnConsole("Invalid Otp");
              setState(() {
                isShowOtpErrorMsg = true;
                otpErrorMsg = "OTP should be of 6 digits";
              });
            } else {
              MyPrint.printOnConsole("Valid OTP");
              setState(() {
                isShowOtpErrorMsg = false;
                otpErrorMsg = "";
              });

              if (verificationId != null) {
                String? otp = ""; //_otpController?.text;

                /*bool result = */await verifyOTP(otp: otp, verificationId: verificationId);
              }
            }
          }
        },
        splashColor: Colors.white.withAlpha(150),
        highlightColor: Colors.red,
        child: Container(
          padding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 32,
        ),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            "Verify",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

//endregion

}


