import 'package:firebase_auth/firebase_auth.dart';
import 'package:okoto/backend/common/common_provider.dart';

import '../../model/user/user_model.dart';

class UserProvider extends CommonProvider {
  //region Firebase User
  User? _firebaseUser;

  User? getFirebaseUser() => _firebaseUser;

  void setFirebaseUser({User? user, bool isNotify = true}) {
    _firebaseUser = user;
    if(isNotify) notifyListeners();
  }
  //endregion

  //region UserModel
  UserModel? _userModel;

  UserModel? getUserModel() => _userModel;

  void setUserModel({UserModel? userModel, bool isNotify = true}) {
    _userModel = userModel;
    if(isNotify) notifyListeners();
  }
  //endregion

  //region UserId
  String _userId = "";

  String getUserId() => _userId;

  void setUserId({String userId = "", bool isNotify = true}) {
    _userId = userId;
    if(isNotify) notifyListeners();
  }
  //endregion
}