import 'package:flutter/material.dart';
import 'package:learn_flutter1/service/cloud/cloud_note.dart';
import 'package:learn_flutter1/utilities/dialogs/delete_dialog.dart';

typedef NoteCallback = void Function(CloudNote note);

class NotesListView extends StatelessWidget {
  final Iterable<CloudNote> notes;
  final NoteCallback onDeleteNote;
  final NoteCallback onTap;

  const NotesListView({
    super.key,
    required this.notes,
    required this.onDeleteNote,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12), // khoảng cách toàn bộ list
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes.elementAt(index);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0), // khoảng cách giữa các note
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],               // nền tối để hợp với background đen
              borderRadius: BorderRadius.circular(12), // bo góc
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onTap: () => onTap(note),
              title: Text(
                note.text,
                maxLines: 2,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () async {
                  final shouldDelete = await showDeleteDialog(context);
                  if (shouldDelete) {
                    onDeleteNote(note);
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
