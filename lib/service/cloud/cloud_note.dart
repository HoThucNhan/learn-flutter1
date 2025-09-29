import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'cloud_storage_constants.dart';

@immutable
class CloudNote {
  final String documentID;
  final String ownerUserID;
  final String title;
  final String text;

  const CloudNote({
    required this.documentID,
    required this.ownerUserID,
    required this.title,
    required this.text,
  });

  CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentID = snapshot.id,
        ownerUserID = snapshot.data()[ownerUserIDFieldName] as String,
        title = (snapshot.data()[titleFieldName] as String?) ?? '',
        text = (snapshot.data()[textFieldName] as String?) ?? '';
}