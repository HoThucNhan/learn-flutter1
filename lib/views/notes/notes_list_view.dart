import 'package:flutter/material.dart';
import 'package:learn_flutter1/service/cloud/cloud_note.dart';
import 'package:learn_flutter1/utilities/dialogs/delete_dialog.dart';

typedef NoteCallback = void Function(CloudNote note);

class NotesListView extends StatelessWidget {
  final Iterable<CloudNote> notes;
  final NoteCallback onDeleteNote;
  final NoteCallback onTap;
  final void Function(CloudNote, bool) onChanged;

  const NotesListView({
    super.key,
    required this.notes,
    required this.onDeleteNote,
    required this.onTap,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes.elementAt(index);
        return ToDoTile(
          title: note.title,
          text: note.text,
          isDone: note.isDone,
          onChanged: (value) {
            if (value != null) {
              onChanged(note, value);
            }
          },
          onDelete: () async {
            final shouldDelete = await showDeleteDialog(context);
            if (shouldDelete) {
              onDeleteNote(note);
            }
          },
          onTap: () {
            onTap(note);
          },
        );
      },
    );
  }
}

class ToDoTile extends StatelessWidget {
  final String? title;
  final String text;
  final bool isDone;
  final Function(bool?)? onChanged;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  ToDoTile({
    super.key,
    required this.title,
    required this.text,
    required this.isDone,
    this.onChanged,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: isDone ? Color(0xFF2D9BEE).withOpacity(0.16) : Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (title?.trim().isEmpty ?? true) ? 'No Title' : title!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!isDone) ...[
                      ElevatedButton(
                        onPressed: () {
                          if (onChanged != null) {
                            onChanged!(!isDone);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Done',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton(
                        onPressed: onDelete,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: const Text('Delete'),
                      ),
                    ] else ...[
                      IconButton(
                        onPressed: () {
                          if (onChanged != null) {
                            onChanged!(!isDone);
                          }
                        },
                        icon: Icon(
                          Icons.check_circle,
                          color: Colors.blue,
                          size: 24,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
