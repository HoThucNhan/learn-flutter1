import 'package:flutter/material.dart';
import 'package:learn_flutter1/service/cloud/cloud_note.dart';
import 'package:learn_flutter1/service/crud/notes_service.dart';
import 'package:learn_flutter1/utilities/dialogs/delete_dialog.dart';

typedef NoteCallback = void Function(CloudNote note);

class NotesListView extends StatelessWidget {
  final Iterable<CloudNote> notes;
  final NoteCallback onDeleteNote;
  final NoteCallback onTap;
  final NoteCallback onToggleDone;

  const NotesListView({
    super.key,
    required this.notes,
    required this.onDeleteNote,
    required this.onTap,
    required this.onToggleDone,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes.elementAt(index);
        final title = (note.title.isNotEmpty ? note.title : note.text);
        final subtitle = note.dueDateMs != null
            ? DateTime.fromMillisecondsSinceEpoch(note.dueDateMs!)
                .toLocal()
                .toString()
            : null;
        return AnimatedScale(
          duration: const Duration(milliseconds: 200),
          scale: 1.0,
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
          onTap: () {
            onTap(note);
          },
          leading: InkWell(
            onTap: () => onToggleDone(note),
            child: Icon(
              note.isDone ? Icons.check_circle : Icons.radio_button_unchecked,
              color: note.isDone ? Colors.green : null,
            ),
          ),
          title: Text(
            title,
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            style: note.isDone
                ? const TextStyle(decoration: TextDecoration.lineThrough)
                : null,
          ),
          subtitle: subtitle != null ? Text(subtitle) : null,
          trailing: IconButton(
            onPressed: () async {
              final shouldDelete = await showDeleteDialog(context);
              if (shouldDelete) {
                onDeleteNote(note);
              }
            },
            icon: const Icon(Icons.delete),
          ),
            ),
          ),
        );
      },
    );
  }
}
