import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learn_flutter1/service/cloud/cloud_note.dart';
import 'package:learn_flutter1/service/cloud/cloud_storage_constants.dart';
import 'package:learn_flutter1/service/cloud/cloud_storage_exceptions.dart';

class FireBaseCloudStorage {
  final notes = FirebaseFirestore.instance.collection('notes');

  Stream<Iterable<CloudNote>> allNote({required String ownerUserID}) =>
      notes.snapshots().map(
        (event) => event.docs
            .map((doc) => CloudNote.fromSnapshot(doc))
            .where((note) => note.ownerUserId == ownerUserID),
      );

  static final FireBaseCloudStorage _shared =
      FireBaseCloudStorage._sharedInstance();

  FireBaseCloudStorage._sharedInstance();

  factory FireBaseCloudStorage() => _shared;

  Future<CloudNote> createNewNote({
    required String ownerUserID,
    String title = '',
    String text = '',
    DateTime? date,
  }) async {
    final document = await notes.add({
      ownerUserIDFieldName: ownerUserID,
      titleFieldName: title,
      textFieldName: text,
      dateFieldName: date,
      isDoneFieldName: false,
    });
    final fetchedNote = await document.get();
    return CloudNote.fromDocument(fetchedNote);
  }


  Future<Iterable<CloudNote>> getNotes({required String ownerUserID}) async {
    try {
      return await notes
          .where(ownerUserIDFieldName, isEqualTo: ownerUserID)
          .get()
          .then(
            (value) => value.docs.map(
              (doc) => CloudNote.fromSnapshot(doc),
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
