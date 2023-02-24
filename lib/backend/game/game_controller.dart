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
}