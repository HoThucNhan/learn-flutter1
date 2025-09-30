import 'package:flutter/material.dart';
import 'package:learn_flutter1/service/auth/auth_service.dart';
import 'package:learn_flutter1/utilities/generics/get_arguments.dart';
import 'package:learn_flutter1/service/cloud/cloud_note.dart';
import 'package:learn_flutter1/service/cloud/firebase_cloud_storage.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  CloudNote? _note;
  late final FireBaseCloudStorage _notesService;
  late final TextEditingController _titleController;
  late final TextEditingController _textController;

  bool _shouldSave = false;

  @override
  void initState() {
    _notesService = FireBaseCloudStorage();
    _textController = TextEditingController();
    _titleController = TextEditingController();
    super.initState();
  }

  void _textControllerListener() async {
    // final note = _note;
    // if (note == null) {
    //   return;
    // }
    // final text = _textController.text;
    // final title = _titleController.text;
    // await _notesService.updateNote(
    //   documentId: note.documentID,
    //   text: text,
    //   title: title,
    // );
  }

  void _setupTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  void _setupTitleControllerListener() {
    _titleController.removeListener(_textControllerListener);
    _titleController.addListener(_textControllerListener);
  }

  Future<CloudNote> createOrGetExistingNote(BuildContext context) async {
    final widgetNote = context.getArgument<CloudNote>();
    if (widgetNote != null) {
      _note = widgetNote;
      _textController.text = widgetNote.text;
      _titleController.text = widgetNote.title;
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

  void _deleteNoteIfTextAndTitleIsEmpty() {
    final note = _note;
    if (note != null &&
        _textController.text.isEmpty &&
        _titleController.text.isEmpty) {
      _notesService.deleteNote(documentId: note.documentID);
    }
  }

  void _saveNoteIfTextNotEmpty() async {
    final note = _note;
    final text = _textController.text;
    final title = _titleController.text;
    if (note != null &&
        (_textController.text.isNotEmpty || _titleController.text.isNotEmpty)) {
      await _notesService.updateNote(
        documentId: note.documentID,
        text: text,
        title: title,
      );
    }
  }

  @override
  void dispose() {
    _deleteNoteIfTextAndTitleIsEmpty();
    if (_shouldSave) {
      _saveNoteIfTextNotEmpty();
    }
    _textController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: createOrGetExistingNote(context),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            _setupTextControllerListener();
            _setupTitleControllerListener();
            return Material(
              color: Colors.transparent,
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  constraints: const BoxConstraints(maxHeight: 500),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        (_note != null) ? 'Update Task' : 'Create Task',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          hintText: 'Title',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _textController,
                        keyboardType: TextInputType.multiline,
                        maxLength: 100,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          hintText: 'Description (max 100 chars)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Date of your task'),
                            IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.calendar_month),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              _shouldSave = false;
                              Navigator.pop(context);
                            },
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () async {
                              _saveNoteIfTextNotEmpty();
                              Navigator.pop(context);
                              _shouldSave = true;
                            },
                            child: const Text('Save', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}
