import 'package:flutter/material.dart';
import 'package:okoto/view/home/screens/devices_screen.dart';
import 'package:okoto/view/profile_screen/screens/profile_screen.dart';

import '../../../utils/my_print.dart';
import '../../common/components/common_loader.dart';
import '../../common/components/common_text.dart';
import '../../common/components/modal_progress_hud.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = "/HomeScreen";
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ThemeData themeData;
  int screenSelected = 0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    themeData = Theme.of(context);
    MyPrint.printOnConsole("HomeScreen Build Called");
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      progressIndicator: const CommonLoader(),
      child: Scaffold(
        body: getMainBody(screenSelected),
        bottomNavigationBar: getBottomNavigationBar()
      ),
    );
  }

  AppBar getAppBar() {
    return AppBar(
      title: const Text("Boards"),
    );
  }

  Widget getMainBody(int myIndex){
    switch (myIndex) {
      case 0:{
        return const DevicesScreen();
      }
      case 1:{
        return const ProfileScreen();
      }
      default:{
        return const DevicesScreen();
      }
    }
  }

  Widget getBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: themeData.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight:Radius.circular(10),
        ),
        boxShadow: [
          BoxShadow(
            color: themeData.colorScheme.surface.withAlpha(100),
            blurRadius: 5,
            spreadRadius:1,
            offset: const Offset(0,1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          getBottomBarIcon(title: 'Devices',icon: Icons.house_outlined,index: 0,),
          getBottomBarIcon(title: 'Profile',icon: Icons.person_outline_rounded,index: 1,),
        ],
      ),
    );
  }

  Widget getBottomBarIcon({required IconData icon,required String title,Function()? onTap,required int index}) {
    return InkWell(
      onTap: (){
        screenSelected = index;
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,size: 23,color: screenSelected == index ? themeData.colorScheme.secondary : Colors.white),
            const SizedBox(height: 2,),
            CommonText(
              text: title,
              fontSize: 11,
              color: screenSelected == index ? themeData.colorScheme.secondary : Colors.white,
              fontWeight: screenSelected == index ? FontWeight.w900 : FontWeight.normal,
            )
          ],
        ),
      ),
    );
  }
}
