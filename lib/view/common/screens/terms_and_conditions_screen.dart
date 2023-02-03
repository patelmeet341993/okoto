import 'package:flutter/material.dart';
import 'package:okoto/utils/my_print.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../components/common_text.dart';

class TermsAndConditionsScreen extends StatefulWidget {
  static const String routeName = "/TermsAndConditionsScreen";

  final String termsAndConditionsUrl;

  const TermsAndConditionsScreen({Key? key, required this.termsAndConditionsUrl}) : super(key: key);

  @override
  State<TermsAndConditionsScreen> createState() => _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState extends State<TermsAndConditionsScreen> {
  late WebViewController webViewController;

  @override
  void initState() {
    super.initState();

    webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted);

    MyPrint.printOnConsole("termsAndConditionsUrl:'${widget.termsAndConditionsUrl}'");
    if(widget.termsAndConditionsUrl.isNotEmpty) {
      webViewController.loadRequest(Uri.parse(widget.termsAndConditionsUrl,));
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: getMainBody(context: context, themeData: themeData)),
    );
  }

  Widget getMainBody({required BuildContext context, required ThemeData themeData}) {
    return Container(
      // height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15,),
          topRight: Radius.circular(15),
        ),
      ),
      // padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          getAppBar(context: context, title: "Terms And Conditions", themeData: themeData),
          Expanded(
            child: WebViewWidget(
              controller: webViewController,
            ),
          ),
        ],
      ),
    );
  }

  Widget getAppBar({required BuildContext context, required String title, required ThemeData themeData}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          InkWell(
            onTap: (){
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back,
              color: themeData.colorScheme.background,
            ),
          ),
          //SizedBox(height: 20,),
          Expanded(
            child: CommonText(
              text: title,
              fontSize: 20,
              textAlign: TextAlign.center,
              maxLines: 1,
              textOverFlow: TextOverflow.ellipsis,
              color: themeData.colorScheme.background,
            ),
          ),
          InkWell(
            onTap: (){

            },
            child: const Icon(
              Icons.arrow_back,
              color: Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
}
