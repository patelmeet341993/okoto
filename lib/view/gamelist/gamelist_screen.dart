import 'package:flutter/material.dart';
import 'package:okoto/view/common/components/common_appbar.dart';
import 'package:okoto/view/common/components/modal_progress_hud.dart';
import 'package:okoto/view/common/components/my_screen_background.dart';

class GameListScreen extends StatefulWidget {
  static const String routeName = "/gameListScreen";
  const GameListScreen({Key? key}) : super(key: key);

  @override
  State<GameListScreen> createState() => _GameListScreenState();
}

class _GameListScreenState extends State<GameListScreen> {
  bool isLoading = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MyScreenBackground(
        child: ModalProgressHUD(
          inAsyncCall: isLoading,
          child: Column(
            children: [
              CommonAppBar(text: 'All Games',),
              SizedBox(height: 20,),



            ],
          ),
        ),
      ),
    );
  }





}
