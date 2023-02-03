import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../utils/my_print.dart';
import '../../../utils/my_utils.dart';

class AboutAppScreen extends StatelessWidget {
  static const String routeName = "/AboutAppScreen";

  final String aboutDescription, contact, whatsapp;

  const AboutAppScreen({
    Key? key,
    required this.aboutDescription,
    required this.contact,
    required this.whatsapp,
  }) : super(key: key);

  /*final String description = "   Mrs Amita Patel , founder and designer of vulcal established the studio in 1993 , intending to provide beautiful , high-quality "
        "fashion in Vadodara. As a student of fine arts, she always had an eye for colours, patterns, textures and so on. Moreover, with some basic "
        "knowledge about textiles, she started Vulcal. \n\n   Vulcal is a prominent name when it comes to traditional Indian chaniya choli. Thus, after so many "
        "years of hard work in the same field, Amita Patel aims to provide the high quality fashion for the customer. It is noteworthy to mention that as "
        "per Amita the utmost crucial aspect while working with constantly changing trends of the present time is the maintenance of quality. We work with "
        "the finest details to make our outfit standout. Furthermore, we believe in holding the ground of tradition when it comes to fashion. Also, we are "
        "delighted to share that we have entered the 30th glorious year of our fashion studio.\n\n   \"It's a  journey from a thought process moulded into reality "
        "with persistent efforts of our team\", says Amita Patel. Here at Vulcal, we suppose that every outfit has its own story, an inspiration, a motivation,"
        "a memory and an emotion attached to it. We try our best to bring the touch of those facts in our designs more particularly in a way that captures "
        "the heart of the wearer. \n\n   Preferentially, we not only give our 100% to make a  beautiful outfit but also to make a beautiful memory for the wearer."
        " Vulcal studio offers a wide range of women’s wear from casual Indian dresses, to bridal lehangas. Additionally, customized clothing for both bride "
        "and groom as well as other family members is available.";*/

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Scaffold(
      appBar: getAppBar(themeData: themeData),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      getAppLogo(),
                      const SizedBox(height: 0,),
                      getDescription(themeData: themeData, description: aboutDescription),
                      const SizedBox(height: 40,),
                      getButtonsPanel(themeData: themeData, whatsapp: whatsapp, contact: contact),
                      const SizedBox(height: 20,),
                    ],
                  ),
                ),
              ),
            ),
            getDevelopedBy(themeData: themeData),
          ],
        ),
      ),
    );
  }

  AppBar getAppBar({required ThemeData themeData}) {
    return AppBar(
      title: Text(
        "About",
        style: themeData.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: false,
    );
  }

  Widget getAppLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Image.asset("assets/images/logo.png", height: 250, width: 250,),
      ],
    );
  }

  Widget getDescription({required ThemeData themeData, required String description}) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      child: Text(
        description,
        style: themeData.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: themeData.colorScheme.onBackground,
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget getButtonsPanel({required ThemeData themeData, String contact = "", String whatsapp = ""}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        GestureDetector(
          onTap: () {
            MyPrint.printOnConsole("contact:'$contact'");
            MyUtils.launchWhatsAppChat(mobileNumber: whatsapp);
          },
          child: Container(
            width: 130,
            height: 40,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              color: Colors.green,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(MdiIcons.whatsapp, size: 20,),
                SizedBox(width: 5,),
                Text("Whatsapp",style: TextStyle(color: Colors.white),),
              ],
            ),
          ),
        ),

        GestureDetector(
          onTap: () {
            MyUtils.launchCallMobileNumber(mobileNumber: contact);
          },
          child: Container(
            width: 130,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              color: themeData.colorScheme.primary,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.call, color: Colors.white, size: 20,),
                SizedBox(width: 10,),
                Text("Call Us",style: TextStyle(color: Colors.white),),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget getDevelopedBy({required ThemeData themeData}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Text.rich(
          TextSpan(
            text: "Developed by ",
            style: themeData.textTheme.bodySmall?.copyWith(
              color: themeData.colorScheme.onPrimary,
              fontWeight: FontWeight.w500,
            ),
            children: [
              TextSpan(
                text: "Friendly It Solution",
                style: themeData.textTheme.bodySmall?.copyWith(
                  color: themeData.colorScheme.primaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ]
          )
        ),
      ),
    );
  }
}
