import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:learn_flutter1/constants/task_groups.dart';
import 'cloud_storage_constants.dart';

@immutable
class CloudTask {
  final String documentId;
  final String ownerUserId;
  final String userName;
  final DateTime? date;
  final String title;
  final String text;
  final bool isDone;
  final String taskGroup;

  const CloudTask({
    required this.documentId,
    required this.ownerUserId,
    required this.title,
    required this.text,
    required this.userName,
    this.date,
    required this.isDone,
    required this.taskGroup,
  });

  CloudTask.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
    : documentId = snapshot.id,
      ownerUserId = snapshot.data()[ownerUserIDFieldName],
      title = (snapshot.data()[titleFieldName] ?? '') as String,
      text = (snapshot.data()[textFieldName] ?? '') as String,
      userName = (snapshot.data()[nameFieldName] ?? '') as String,
      date = (snapshot.data()[dateFieldName] != null)
          ? (snapshot.data()[dateFieldName] as Timestamp).toDate()
          : null,
      isDone = (snapshot.data()[isDoneFieldName] ?? false) as bool,
      taskGroup = (snapshot.data()[taskGroupFieldName] ?? TaskGroups.general) as String;

  factory CloudTask.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    return CloudTask(
      documentId: doc.id,
      ownerUserId: doc.data()?[ownerUserIDFieldName] as String,
      title: doc.data()?[titleFieldName] as String? ?? '',
      text: doc.data()?[textFieldName] as String? ?? '',
      userName: doc.data()?[nameFieldName] as String? ?? '',
      isDone: doc.data()?[isDoneFieldName] as bool? ?? false,
      date: (doc.data()?[dateFieldName] as Timestamp?)?.toDate(),
      taskGroup: doc.data()?[taskGroupFieldName] as String? ?? 'General',
    );
  }

}
