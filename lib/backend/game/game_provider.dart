import 'package:okoto/backend/common/common_provider.dart';

import '../../model/game/game_model.dart';

class GameProvider extends CommonProvider{
  GameProvider() {
    _initializeFields();
  }

  void resetAllData() {}

  void _initializeFields() {
    gameModelList = CommonProviderListParameter<GameModel>(
      list: <GameModel>[],
      notify: notify,
    );
  }

  late CommonProviderListParameter<GameModel> gameModelList;
}