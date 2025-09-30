import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'cloud_storage_constants.dart';

@immutable
class CloudNote {
  final String documentId;
  final String ownerUserId;
  final String userName;
  final DateTime? date;
  final String title;
  final String text;
  final bool isDone;

  const CloudNote({
    required this.documentId,
    required this.ownerUserId,
    required this.title,
    required this.text,
    required this.userName,
    this.date,
    required this.isDone,
  });

  CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
    : documentId = snapshot.id,
      ownerUserId = snapshot.data()[ownerUserIDFieldName],
      title = (snapshot.data()[titleFieldName] ?? '') as String,
      text = (snapshot.data()[textFieldName] ?? '') as String,
      userName = (snapshot.data()[nameFieldName] ?? '') as String,
      date = (snapshot.data()[dateFieldName] != null)
          ? (snapshot.data()[dateFieldName] as Timestamp).toDate()
          : null,
      isDone = (snapshot.data()[isDoneFieldName] ?? false) as bool;

  factory CloudNote.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    return CloudNote(
      documentId: doc.id,
      ownerUserId: doc.data()?[ownerUserIDFieldName] as String,
      title: doc.data()?[titleFieldName] as String? ?? '',
      text: doc.data()?[textFieldName] as String? ?? '',
      userName: doc.data()?[nameFieldName] as String? ?? '',
      isDone: doc.data()?[isDoneFieldName] as bool? ?? false,
      date: (doc.data()?[dateFieldName] as Timestamp?)?.toDate(),
    );
  }

}
