import 'package:cloud_firestore/cloud_firestore.dart';

import '../../configs/constants.dart';
import '../../configs/typedefs.dart';
import '../../model/user/user_model.dart';
import '../../utils/my_print.dart';
import '../../utils/my_utils.dart';

class UserRepository {
  Future<UserModel?> getUserModelFromId({required String userId}) async {
    String tag = MyUtils.getUniqueIdFromUuid();

    MyPrint.printOnConsole("UserRepository().getUserModelFromId() called with userId:'$userId'", tag: tag);

    if(userId.isEmpty) {
      return null;
    }

    try {
      MyFirestoreDocumentSnapshot snapshot = await FirebaseNodes.userDocumentReference(userId: userId).get();
      MyPrint.printOnConsole("snapshot.exists:'${snapshot.exists}'", tag: tag);
      MyPrint.printOnConsole("snapshot.data():'${snapshot.data()}'", tag: tag);

      if(snapshot.exists && (snapshot.data()?.isNotEmpty ?? false)) {
        return UserModel.fromMap(snapshot.data()!);
      }
      else {
        return null;
      }
    }
    catch(e,s) {
      MyPrint.printOnConsole("Error in UserRepository().getUserModelFromId():'$e'", tag: tag);
      MyPrint.printOnConsole(s ,tag: tag);
      return null;
    }
  }

  Future<bool> createUserWithUserModel({required UserModel userModel}) async {
    String tag = MyUtils.getUniqueIdFromUuid();

    MyPrint.printOnConsole("UserRepository().createUserWithUserModel() called with userModel:'$userModel'", tag: tag);

    bool isUserCreated = false;

    if(userModel.id.isEmpty) {
      return isUserCreated;
    }

    try {
      await FirebaseNodes.userDocumentReference(userId: userModel.id).set(userModel.toMap(), SetOptions(merge: true));

      MyPrint.printOnConsole("User Created from UserRepository().createUserWithUserModel() with UserId:'${userModel.id}'", tag: tag);
      isUserCreated = true;
    }
    catch(e,s) {
      MyPrint.printOnConsole("Error in UserRepository().createUserWithUserModel():'$e'", tag: tag);
      MyPrint.printOnConsole(s ,tag: tag);
    }

    return isUserCreated;
  }

  Future<bool> updateUserDataFromMap({required String userId, required Map<String, dynamic> data}) async {
    String tag = MyUtils.getUniqueIdFromUuid();

    MyPrint.printOnConsole("UserRepository().updateUserDataFromMap() called with userId:'$userId', data:'$data'", tag: tag);

    bool isUserUpdated = false;

    if(userId.isEmpty || data.isEmpty) {
      return isUserUpdated;
    }

    try {
      await FirebaseNodes.userDocumentReference(userId: userId).update(data);

      MyPrint.printOnConsole("User Data Updated from UserRepository().updateUserDataFromMap() with userId:'$userId'", tag: tag);
      isUserUpdated = true;
    }
    catch(e,s) {
      MyPrint.printOnConsole("Error in UserRepository().updateUserDataFromMap():'$e'", tag: tag);
      MyPrint.printOnConsole(s ,tag: tag);
    }

    MyPrint.printOnConsole("Final isUserUpdated:$isUserUpdated", tag: tag);

    return isUserUpdated;
  }
}