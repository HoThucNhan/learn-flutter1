import 'package:flutter/material.dart';
import 'package:learn_flutter1/service/auth/auth_service.dart';
import 'package:learn_flutter1/utilities/generics/get_arguments.dart';
import 'package:learn_flutter1/service/cloud/cloud_note.dart';
import 'package:learn_flutter1/service/cloud/firebase_cloud_storage.dart';
import 'package:learn_flutter1/service/cloud/cloud_storage_exceptions.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  CloudNote? _note;
  late final FireBaseCloudStorage _notesService;
  late final TextEditingController _textController;
  late final TextEditingController _titleController;
  int? _dueDateMs;
  bool _isDone = false;

  @override
  void initState() {
    _notesService = FireBaseCloudStorage();
    _textController = TextEditingController();
    _titleController = TextEditingController();
    super.initState();
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final text = _textController.text;
    await _notesService.updateNote(documentId: note.documentID, text: text);
  }

  void _titleControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final title = _titleController.text;
    await _notesService.updateNote(documentId: note.documentID, title: title);
  }

  void _setupTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
    _titleController.removeListener(_titleControllerListener);
    _titleController.addListener(_titleControllerListener);
  }

  Future<CloudNote> createOrGetExistingNote(BuildContext context) async {
    final widgetNote = context.getArgument<CloudNote>();
    if (widgetNote != null) {
      _note = widgetNote;
      _textController.text = widgetNote.text;
      _titleController.text = widgetNote.title;
      _dueDateMs = widgetNote.dueDateMs;
      _isDone = widgetNote.isDone;
      return widgetNote;
    }

    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    } else {
      final currentUser = AuthService.firebase().currentUser!;
      final userId = currentUser.id;
      final newNote = await _notesService.CreateNewNote(ownerUserID: userId);
      _note = newNote;
      return newNote;
    }
  }

  void _deleteNoteIfTextIsEmpty() {
    final note = _note;
    if (note != null && _textController.text.isEmpty) {
      _notesService.deleteNote(documentId: note.documentID);
    }
  }

  void _saveNoteIfTextNotEmpty() async {
    final note = _note;
    final text = _textController.text;
    final title = _titleController.text;
    if (note != null && (_textController.text.isNotEmpty || _titleController.text.isNotEmpty)) {
      await _notesService.updateNote(
        documentId: note.documentID,
        text: text,
        title: title,
        dueDateMs: _dueDateMs,
        isDone: _isDone,
      );
    }
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextNotEmpty();
    _textController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todo')),
      body: FutureBuilder(
        future: createOrGetExistingNote(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _setupTextControllerListener();
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        hintText: 'What do you need to do?',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final now = DateTime.now();
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _dueDateMs != null
                                    ? DateTime.fromMillisecondsSinceEpoch(_dueDateMs!)
                                    : now,
                                firstDate: now.subtract(const Duration(days: 365)),
                                lastDate: now.add(const Duration(days: 365 * 5)),
                              );
                              if (picked != null) {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.fromDateTime(_dueDateMs != null
                                      ? DateTime.fromMillisecondsSinceEpoch(_dueDateMs!)
                                      : now),
                                );
                                final finalDateTime = DateTime(
                                  picked.year,
                                  picked.month,
                                  picked.day,
                                  time?.hour ?? 0,
                                  time?.minute ?? 0,
                                );
                                setState(() {
                                  _dueDateMs = finalDateTime.millisecondsSinceEpoch;
                                });
                                final note = _note;
                                if (note != null) {
                                  await _notesService.updateNote(
                                    documentId: note.documentID,
                                    dueDateMs: _dueDateMs,
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.event),
                            label: Text(
                              _dueDateMs != null
                                  ? DateTime.fromMillisecondsSinceEpoch(_dueDateMs!)
                                      .toLocal()
                                      .toString()
                                  : 'Pick due date',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        FilterChip(
                          selected: _isDone,
                          label: const Text('Done'),
                          onSelected: (val) async {
                            setState(() {
                              _isDone = val;
                            });
                            final note = _note;
                            if (note != null) {
                              await _notesService.updateNote(
                                documentId: note.documentID,
                                isDone: _isDone,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _textController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        hintText: 'Add details...',
                      ),
                    ),
                  ],
                ),
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
