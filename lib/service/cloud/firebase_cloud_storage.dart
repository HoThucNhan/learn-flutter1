import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learn_flutter1/service/cloud/cloud_task.dart';
import 'package:learn_flutter1/service/cloud/cloud_storage_constants.dart';
import 'package:learn_flutter1/service/cloud/cloud_storage_exceptions.dart';

class FireBaseCloudStorage {
  final notes = FirebaseFirestore.instance.collection('notes');

  Stream<Iterable<CloudTask>> allNote({required String ownerUserID}) =>
      notes.snapshots().map(
        (event) => event.docs
            .map((doc) => CloudTask.fromSnapshot(doc))
            .where((note) => note.ownerUserId == ownerUserID),
      );

  static final FireBaseCloudStorage _shared =
      FireBaseCloudStorage._sharedInstance();

  FireBaseCloudStorage._sharedInstance();

  factory FireBaseCloudStorage() => _shared;

  Future<CloudTask> createNewNote({
    required String ownerUserID,
    String title = '',
    String text = '',
    DateTime? date,
    String taskGroup = 'General',
  }) async {
    final document = await notes.add({
      ownerUserIDFieldName: ownerUserID,
      titleFieldName: title,
      textFieldName: text,
      dateFieldName: date,
      taskGroupFieldName: taskGroup,
      isDoneFieldName: false,
      nameFieldName: 'User Name',
    });
    final fetchedNote = await document.get();
    return CloudTask.fromDocument(fetchedNote);
  }


  Future<Iterable<CloudTask>> getNotes({required String ownerUserID}) async {
    try {
      return await notes
          .where(ownerUserIDFieldName, isEqualTo: ownerUserID)
          .get()
          .then(
            (value) => value.docs.map(
              (doc) => CloudTask.fromSnapshot(doc),
            ),
          );
    } catch (e) {
      throw CouldNotGetAllNotesException();
    }
  }

  Future<void> updateNote({
    required String documentId,
    required String? title,
    required String? text,
    bool? isDone,
    DateTime? date,
    String? taskGroup,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (title != null) {
        updateData[titleFieldName] = title;
      }
      if (text != null) {
        updateData[textFieldName] = text;
      }
      if (isDone != null) {
        updateData[isDoneFieldName] = isDone;
      }
      if (date != null) {
        updateData[dateFieldName] = Timestamp.fromDate(date);
      }

      if (taskGroup != null) {
        updateData[taskGroupFieldName] = taskGroup;
      }

      await notes.doc(documentId).update(updateData);
    } catch (_) {
      throw CouldNotUpdateNoteException();
    }
  }

  Future<void> deleteNote({required String documentId}) async {
    try {
      await notes.doc(documentId).delete();
    } catch (_) {
      throw CouldNotDeleteNoteException();
    }
  }
}
