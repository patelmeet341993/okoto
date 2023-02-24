import 'package:okoto/backend/common/firestore_controller.dart';

import '../../configs/constants.dart';
import '../../configs/typedefs.dart';
import '../../model/game/game_model.dart';
import '../../utils/my_print.dart';
import '../../utils/my_utils.dart';

class GameRepository{
  Future<List<GameModel>> getAllGameModelsList() async {
    List<GameModel> gameList = [];

    try{
      MyFirestoreQuerySnapshot querySnapshot = await FirebaseNodes.gamesCollectionReference.get();
      if(querySnapshot.docs.isNotEmpty){
        for (MyFirestoreQueryDocumentSnapshot queryDocumentSnapshot in querySnapshot.docs) {
          if(queryDocumentSnapshot.data().isNotEmpty) {
            gameList.add(GameModel.fromMap(queryDocumentSnapshot.data()));
          }
          else {
            MyPrint.printOnConsole("Game Document Empty for Document Id:${queryDocumentSnapshot.id}");
          }
        }
      }
    }
    catch(e,s){
      MyPrint.printOnConsole('Error in getAllGameModelsList in GameRepository $e');
      MyPrint.printOnConsole(s);
    }

    return gameList;
  }

  Future<List<GameModel>> getGameModelsListFromIdsList({required List<String> idsList}) async {
    String tag = MyUtils.getUniqueIdFromUuid();
    MyPrint.printOnConsole("GameRepository().getGameModelsListFromIdsList() called with idsList:'$idsList'", tag: tag);

    List<GameModel> gameList = [];

    if(idsList.isEmpty) {
      MyPrint.printOnConsole("Returning from GameRepository().getGameModelsListFromIdsList() because ids list is empty", tag: tag);
      return gameList;
    }

    try {
      List<MyFirestoreQueryDocumentSnapshot> list = await FirestoreController.getDocsWithIdsFromFirestoreCollection(
        query: FirebaseNodes.gamesCollectionReference,
        docIds: idsList,
      );
      MyPrint.printOnConsole("Game Docs Length:${list.length}", tag: tag);

      if(list.isNotEmpty) {
        for (MyFirestoreQueryDocumentSnapshot queryDocumentSnapshot in list) {
          if(queryDocumentSnapshot.data().isNotEmpty) {
            gameList.add(GameModel.fromMap(queryDocumentSnapshot.data()));
          }
          else {
            MyPrint.printOnConsole("Game Document Empty for Document Id:${queryDocumentSnapshot.id}");
          }
        }
      }
    }
    catch(e,s) {
      MyPrint.printOnConsole('Error in GameRepository().getGameModelsListFromIdsList():$e', tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
    }

    MyPrint.printOnConsole("Final Game Models Length:${gameList.length}", tag: tag);

    return gameList;
  }
}