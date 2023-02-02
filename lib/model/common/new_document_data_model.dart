import 'package:cloud_firestore/cloud_firestore.dart';

class NewDocumentDataModel {
  String docId = "";
  Timestamp timestamp = Timestamp.now();

  NewDocumentDataModel({
    this.docId = "",
    required this.timestamp,
  });
}