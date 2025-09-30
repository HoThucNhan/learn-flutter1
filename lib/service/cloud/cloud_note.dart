import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'cloud_storage_constants.dart';

@immutable
class CloudNote {
  final String documentID;
  final String ownerUserID;
  final String userName;
  final DateTime dueDate;
  final String title;
  final String text;
  final bool isDone;

  const CloudNote({
    required this.documentID,
    required this.ownerUserID,
    required this.title,
    required this.text,
    required this.userName,
    required this.dueDate,
    required this.isDone,
  });

  CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
    : documentID = snapshot.id,
      ownerUserID = snapshot.data()[ownerUserIDFieldName],
      title = (snapshot.data()[titleFieldName] ?? '') as String,
      text = (snapshot.data()[textFieldName] ?? '') as String,
      userName = (snapshot.data()[nameFieldName] ?? '') as String,
      dueDate = (snapshot.data()[dueDateFieldName] as Timestamp?)?.toDate() ?? DateTime.now(),
      isDone = (snapshot.data()[isDoneFieldName] ?? false) as bool;
}
