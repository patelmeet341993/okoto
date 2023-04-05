import 'package:okoto/model/game/game_model.dart';
import 'package:okoto/utils/my_print.dart';

import 'game_provider.dart';
import 'game_repository.dart';

class GameController {
  late GameProvider _gameProvider;
  late GameRepository _gameRepository;

  GameController({required GameProvider? gameProvider, GameRepository? repository}){
    _gameProvider = gameProvider ?? GameProvider();
    _gameRepository = repository ?? GameRepository();
  }

  GameProvider get gameProvider => _gameProvider;
  GameRepository get gameRepository => _gameRepository;

  Future<bool> getAllGameList() async {
    bool isFetched = false;
    try {
      List<GameModel> gameModelList = [];
      gameModelList = await _gameRepository.getAllGameModelsList();
      gameProvider.gameModelList.setList(list: gameModelList,);
    } catch (e,s){
      MyPrint.printOnConsole("Error in getAllGameList ${e}");
      MyPrint.printOnConsole(s);
    }

    return isFetched;
  }

  Future<GameModel?> getGameDetailsFromGameId(String gameId)async{
    try {
      GameModel? gameModel;
      gameModel = await _gameRepository.getGameModelFromId(gameId: gameId);
      return gameModel;

    } catch (e,s){
      MyPrint.printOnConsole("Error in getGameDetailsFromGameId ${e}");
      MyPrint.printOnConsole(s);
    }
  }

}