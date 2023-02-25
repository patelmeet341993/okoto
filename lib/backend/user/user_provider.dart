import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:okoto/backend/common/common_provider.dart';
import 'package:okoto/configs/typedefs.dart';

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

  void setUserModel({UserModel? userModel, bool isUpdate = false, bool isNotify = true}) {
    if(isUpdate && userModel != null && _userModel != null) {
      _userModel!.updateFromMap(userModel.toMap());
    }
    else {
      _userModel = userModel;
    }
    notify(isNotify: isNotify);
  }
  //endregion

  //region UserId
  String _userId = "";

  String getUserId() => _userId;

  void setUserId({String userId = "", bool isNotify = true}) {
    _userId = userId;
    notify(isNotify: isNotify);
  }
  //endregion

  //region User Listening StreamSubscription
  StreamSubscription<MyFirestoreDocumentSnapshot>? _userListeningStreamSubscription;

  Future<void> initializeUserListeningStreamSubscription({
    required StreamSubscription<MyFirestoreDocumentSnapshot>? subscription,
    bool isNotify = true,
  }) async {
    await stopUserListeningStreamSubscription(isNotify: false);
    _userListeningStreamSubscription = subscription;
    notify(isNotify: isNotify);
  }

  Future<void> stopUserListeningStreamSubscription({bool isNotify = true}) async {
    await _userListeningStreamSubscription?.cancel();
    _userListeningStreamSubscription = null;
    notify(isNotify: isNotify);
  }
  //endregion
}