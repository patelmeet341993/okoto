

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../backend/game/game_controller.dart';
import '../../backend/game/game_provider.dart';
import '../common/components/common_appbar.dart';
import '../common/components/common_loader.dart';
import '../common/components/modal_progress_hud.dart';
import '../common/components/my_screen_background.dart';

class MyGameList extends StatefulWidget {
  static const String routeName = "/MyGameList";

  const MyGameList({Key? key}) : super(key: key);

  @override
  State<MyGameList> createState() => _MyGameListState();
}

class _MyGameListState extends State<MyGameList> {

  late GameProvider gameProvider;
  late GameController gameController;
  Future? getFutureData;

  bool isLoading = false;

  Future<void> getGameList() async {
    //await gameController.getAllGameList();
  }


  @override
  void initState() {
    super.initState();
    gameProvider = context.read<GameProvider>();
    gameController = GameController(gameProvider: gameProvider);
    getFutureData = getGameList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MyScreenBackground(
        child: ModalProgressHUD(
          inAsyncCall: isLoading,
          child: FutureBuilder(
              future: getFutureData,
              builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
                if(asyncSnapshot.connectionState == ConnectionState.done){
                  return getMainWidget();
                }
                else {
                  return Center(child: CommonLoader(),);
                }
              }
          ),
        ),
      ),
    );
  }

  Widget getMainWidget(){
    return Column(
      children: [
        const CommonAppBar(text: 'My Games',),
        // const SizedBox(height: 10,),
        //Expanded(child: getGameListWidget())
      ],
    );
  }

}
