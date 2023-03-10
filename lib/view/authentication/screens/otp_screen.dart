import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../backend/navigation/navigation.dart';
import '../../../backend/user/user_controller.dart';
import '../../../backend/user/user_provider.dart';
import '../../../utils/my_print.dart';
import '../../../utils/my_toast.dart';
import '../../common/components/common_loader.dart';
import '../../common/components/common_primary_button.dart';
import '../../common/components/modal_progress_hud.dart';
import '../../common/components/pin_put.dart';

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
    userProvider.setUserId(userId: user.uid, isNotify: false);
    userProvider.setFirebaseUser(user: user, isNotify: false);

    MyPrint.printOnConsole("Email:${user.email}");
    MyPrint.printOnConsole("Mobile:${user.phoneNumber}");

    bool isExist = await UserController(userProvider: userProvider).checkUserWithIdExistOrNotAndIfNotExistThenCreate(userId: user.uid);
    MyPrint.printOnConsole("isExist:$isExist");

    if (isExist && (userProvider.getUserModel()?.isHavingNecessaryInformation() ?? false)) {
      MyPrint.printOnConsole("User Exist");

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
          navigationType: NavigationType.pushNamedAndRemoveUntil,
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
    
    return Container(
      color: themeData.colorScheme.background,
      child: SafeArea(
        child: Scaffold(
          body: ModalProgressHUD(
            inAsyncCall: isLoading,
            // progressIndicator: const SpinKitFadingCircle(color: Colors.blue,),
            progressIndicator: const CommonLoader(),
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    getAppBar(),
                    const SizedBox(
                      height: 40,
                    ),
                    getLogo(),
                    getOTPVerificationText(),
                    getLoginText2(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        getOtpWidget(),
                        const SizedBox(
                          height: 20,
                        ),
                        getResendLinkWidget(),
                      ],
                    ),
                    /*SizedBox(
                      height: 40!,
                    ),
                    getMessageText(msg),*/
                    getOtpSendingWidget(),
                    getTimer(),
                    const SizedBox(
                      height: 40,
                    ),
                    getSubmitButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

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

    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: CircularCountDownTimer(
        controller: controller,
        width: 100,
        height: 100,
        duration: otpDuration.toInt(),
        initialDuration: 0,
        ringColor: isTimerOn ? themeData.primaryColor.withAlpha(100) : Colors.white,
        fillColor: themeData.primaryColor,
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
      ),
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

  Widget getOtp1Widget() {
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: Colors.transparent,
      child: TextFormField(
        /*controller: _otpController,
        focusNode: _otpFocusNode,
        onChanged: (val) {
          if(val.length == 6) _otpFocusNode?.unfocus(disposition: UnfocusDisposition.scope);
        },*/
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
}
