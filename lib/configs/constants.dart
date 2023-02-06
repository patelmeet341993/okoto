import '../backend/common/firestore_controller.dart';
import 'typedefs.dart';

class AppConstants {
  static String getAppNameFromAppType({required bool isDev}) {
    if(isDev) {
      return "Okoto Dev";
    }
    else {
      return "Okoto";
    }
  }
}

class FirestoreExceptionCodes {
  static const String notFound = "not-found";
}

class UserGender {
  static const String male = "Male";
  static const String female = "Female";
  static const String other = "Other";

  static const List<String> values = [male, female, other];
}

class OrderType {
  static const String subscription = "Subscription";
  static const String product = "Product";

  static const List<String> values = [subscription, product];
}

class FirebaseNodes {
  //region Admin
  static const String adminCollection = "admin";

  static MyFirestoreCollectionReference get adminCollectionReference => FirestoreController.collectionReference(
    collectionName: adminCollection,
  );

  static MyFirestoreDocumentReference adminDocumentReference({String? documentId}) => FirestoreController.documentReference(
    collectionName: adminCollection,
    documentId: documentId,
  );

  //region Property Document
  static const String propertyDocument = "properties";

  static MyFirestoreDocumentReference get adminPropertyDocumentReference => adminDocumentReference(
    documentId: propertyDocument,
  );
  //endregion
  //endregion

  //region Users Collection
  static const String usersCollection = 'users';

  static MyFirestoreCollectionReference get usersCollectionReference => FirestoreController.collectionReference(
    collectionName: FirebaseNodes.usersCollection,
  );

  static MyFirestoreDocumentReference userDocumentReference({String? userId}) => FirestoreController.documentReference(
    collectionName: FirebaseNodes.usersCollection,
    documentId: userId,
  );
  //endregion

  //region Timestamp Collection
  static const String timestampCollection = "timestamp_collection";

  static MyFirestoreCollectionReference get timestampCollectionReference => FirestoreController.collectionReference(
    collectionName: timestampCollection,
  );
  //endregion
}

//Shared Preference Keys
class SharePreferenceKeys {
  static const String isUserLoggedIn = "isUserLoggedIn";
}

class UIConstants {
  static const String noUserImageUrl = "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png";
}

