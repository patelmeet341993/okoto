import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:okoto/utils/extensions.dart';

import '../../configs/constants.dart';
import '../../model/common/new_document_data_model.dart';
import '../../model/user/user_model.dart';
import '../../utils/my_print.dart';
import '../../utils/my_utils.dart';
import 'user_provider.dart';
import 'user_repository.dart';

class UserController {
  late UserProvider _userProvider;
  late UserRepository _userRepository;

  UserController({required UserProvider? userProvider, UserRepository? repository}) {
    _userProvider = userProvider ?? UserProvider();
    _userRepository = repository ?? UserRepository();
  }

  UserProvider get userProvider => _userProvider;

  UserRepository get userRepository => _userRepository;

  Future<bool> checkUserWithIdExistOrNot({required String userId}) async {
    String tag = MyUtils.getUniqueIdFromUuid();

    MyPrint.printOnConsole("UserController().checkUserWithIdExistOrNot() called with userId:'$userId'", tag: tag);

    bool isExist = false;

    if(userId.isEmpty) return isExist;

    try {
      UserModel? userModel = await userRepository.getUserModelFromId(userId: userId);
      MyPrint.printOnConsole("userModel:'$userModel'", tag: tag);

      if(userModel != null) {
        isExist = true;
      }
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in UserController().checkUserWithIdExistOrNot():'$e'", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
    }

    return isExist;
  }

  Future<bool> checkUserWithIdExistOrNotAndIfNotExistThenCreate({required String userId,}) async {
    String tag = MyUtils.getUniqueIdFromUuid();

    MyPrint.printOnConsole("UserController().checkUserWithIdExistOrNotAndIfNotExistThenCreate() called with userId:'$userId'", tag: tag);

    bool isUserExist = false;

    if(userId.isEmpty) return isUserExist;

    try {
      UserModel? userModel = await userRepository.getUserModelFromId(userId: userId);
      MyPrint.printOnConsole("userModel:'$userModel'", tag: tag);

      if(userModel != null) {
        isUserExist = true;
        userProvider.setUserModel(userModel: userModel, isNotify: false);
      }
      else {
        UserModel? createdUserModel = await createUserWithId(userId: userId, mobileNumber: userProvider.getFirebaseUser()?.phoneNumber ?? "");
        MyPrint.printOnConsole("isUserCreated:'$createdUserModel'", tag: tag);

        if(createdUserModel != null) {
          userProvider.setUserModel(userModel: createdUserModel, isNotify: false);
        }
      }
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in UserController().checkUserWithIdExistOrNotAndIfNotExistThenCreate():'$e'", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
    }

    return isUserExist;
  }

  Future<UserModel?> createUserWithId({required String userId, UserModel? userModel, String mobileNumber = ""}) async {
    String tag = MyUtils.getUniqueIdFromUuid();

    MyPrint.printOnConsole("UserController().createUserWithId() called with userId:'$userId', userModel:'$userModel'", tag: tag);

    bool isCreated = false;

    if(userId.isEmpty) return userModel;

    try {
      userModel ??= UserModel(
        id: userId,
        mobileNumber: mobileNumber,
      );

      if(userModel.createdDate == null) {
        NewDocumentDataModel newDocumentDataModel = await MyUtils.getNewDocIdAndTimeStamp(isGetTimeStamp: true);
        userModel.createdDate = newDocumentDataModel.timestamp;
      }

      isCreated = await userRepository.createUserWithUserModel(userModel: userModel);
      MyPrint.printOnConsole("isUserCreated:'$isCreated'", tag: tag);
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in UserController().createUserWithId():'$e'", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
    }

    return userModel;
  }

  Future<void> getUserDataAndStoreInProvider({required String userId}) async {
    String tag = MyUtils.getUniqueIdFromUuid();

    MyPrint.printOnConsole("UserController().getUserDataAndStoreInProvider() called with userId:'$userId'", tag: tag);

    try {
      UserModel? userModel = await userRepository.getUserModelFromId(userId: userId);
      MyPrint.printOnConsole("userModel:'$userModel'", tag: tag);

      if(userModel != null) {
        userProvider.setUserModel(userModel: userModel, isNotify: false);
      }
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in UserController().getUserDataAndStoreInProvider():'$e'", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
    }
  }

  Future<bool> updateUserData({required UserModel userModel}) async {
    String tag = MyUtils.getUniqueIdFromUuid();

    MyPrint.printOnConsole("UserController().updateUserData() called with userModel:'$userModel'", tag: tag);

    bool isUpdated = false;

    if(userModel.id.isEmpty) return isUpdated;

    try {
      if(userModel.createdDate == null) {
        NewDocumentDataModel newDocumentDataModel = await MyUtils.getNewDocIdAndTimeStamp(isGetTimeStamp: true);
        userModel.createdDate = newDocumentDataModel.timestamp;
      }

      isUpdated = await userRepository.createUserWithUserModel(userModel: userModel);
      MyPrint.printOnConsole("isUserUpdated:'$isUpdated'", tag: tag);
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in UserController().updateUserData():'$e'", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
    }

    return isUpdated;
  }

  Future<void> updateUserProfileData({String? name,String? gender,String? occupation,Timestamp? dateOfBirth,double? yearlyIncomeApprox,}) async {
    String tag = MyUtils.getUniqueIdFromUuid();
    MyPrint.printOnConsole("UserController().updateUserData() called");

    try {
      UserModel? userModel = userProvider.getUserModel();
      if(userModel != null){
        Map<String,dynamic> updatedMap ={};
        if(name != null){
          updatedMap['name'] = name;
          userModel.name = name;
        }
        if(gender != null){
          updatedMap['gender'] = gender;
          userModel.gender = gender;
        }
        if(dateOfBirth != null){
          updatedMap['dateOfBirth'] = dateOfBirth;
          userModel.dateOfBirth = dateOfBirth;
        }

        if(updatedMap.isNotEmpty){
          await FirebaseNodes.userDocumentReference(userId: userModel.id).update(updatedMap);
        }
        userProvider.notify();
      }

      MyPrint.printOnConsole("isUserUpdated:true", tag: tag);
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in UserController().updateUserData():'$e'", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
    }
  }

  Future<bool> checkUserHavingDevices({required String userId}) async {
    String tag = MyUtils.getUniqueIdFromUuid();
    MyPrint.printOnConsole("UserController().checkUserHavingDevices() called with userId:$userId", tag: tag);

    bool isUserHavingDevices = false;

    try {
      UserModel? userModel = await userRepository.getUserModelFromId(userId: userId);
      MyPrint.printOnConsole("userModel:$userModel", tag: tag);

      isUserHavingDevices = (userModel?.deviceIds).checkNotEmpty;
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in UserController().checkUserHavingDevices():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
    }

    MyPrint.printOnConsole("isUserHavingDevices:$isUserHavingDevices", tag: tag);

    return isUserHavingDevices;
  }
}