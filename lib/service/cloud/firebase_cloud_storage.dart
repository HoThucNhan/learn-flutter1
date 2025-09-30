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
            .where((note) => note.ownerUserID == ownerUserID),
      );

  static final FireBaseCloudStorage _shared =
      FireBaseCloudStorage._sharedInstance();

  FireBaseCloudStorage._sharedInstance();

  factory FireBaseCloudStorage() => _shared;

  Future<CloudNote> CreateNewNote({required String ownerUserID}) async {
    final document = await notes.add({
      ownerUserIDFieldName: ownerUserID,
    });
    final fetchNote = await document.get();
    return CloudNote(
      documentID: fetchNote.id,
      ownerUserID: ownerUserID,
      text: '',
      userName: '',
      dueDate: DateTime.now(),
      title: '',
      isDone: false,
    );

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
