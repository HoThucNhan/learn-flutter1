import 'package:flutter/material.dart';
import 'package:learn_flutter1/service/auth/auth_service.dart';
import 'package:learn_flutter1/service/cloud/cloud_note.dart';
import 'package:learn_flutter1/service/cloud/firebase_cloud_storage.dart';

class CreateUpdateNoteView extends StatefulWidget {
  final CloudNote? note;

  const CreateUpdateNoteView({super.key, this.note});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  CloudNote? _note;
  late final FireBaseCloudStorage _notesService;
  late final TextEditingController _titleController;
  late final TextEditingController _textController;
  DateTime? _selectedDate;

  bool _shouldSave = false;
  late final bool isNew = widget.note == null;

  @override
  void initState() {
    _notesService = FireBaseCloudStorage();
    _textController = TextEditingController();
    _titleController = TextEditingController();
    _selectedDate = widget.note?.date;
    super.initState();
  }

  Future<CloudNote?> createOrGetExistingNote(BuildContext context) async {
    final widgetNote = widget.note;
    if (widgetNote != null) {
      _note = widgetNote;
      _textController.text = widgetNote.text;
      _titleController.text = widgetNote.title;
      return widgetNote;
    }
    return null;
  }

  void _deleteNoteIfTextAndTitleIsEmpty() {
    final note = _note;
    if (note != null &&
        _textController.text.isEmpty &&
        _titleController.text.isEmpty) {
      _notesService.deleteNote(documentId: note.documentId);
    }
  }

  void _saveNoteIfTextNotEmpty() async {
    final note = _note;
    final text = _textController.text;
    final title = _titleController.text;
    if (note != null &&
        (_textController.text.isNotEmpty || _titleController.text.isNotEmpty)) {
      await _notesService.updateNote(
        documentId: note.documentId,
        text: text,
        title: title,
        date: _selectedDate,
      );
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
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
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isNew ? 'Create Task' : 'Update Task',
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
                        textInputAction: TextInputAction.newline,
                        expands: false,
                        decoration: const InputDecoration(
                          hintText: 'Description (max 100 chars)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1.0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedDate == null
                                  ? 'No date chosen'
                                  : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                            ),
                            IconButton(
                              onPressed: _pickDate,
                              icon: const Icon(Icons.calendar_month),
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
                              backgroundColor: Color(0xFF0177FF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () async {
                              final text = _textController.text;
                              final title = _titleController.text;
                              final currentUser = AuthService.firebase().currentUser!;
                              final userId = currentUser.id;

                              if (isNew) {
                                // 👉 Tạo mới task với data đầy đủ luôn
                                if (title.isNotEmpty || text.isNotEmpty) {
                                  await _notesService.createNewNote(
                                    ownerUserID: userId,
                                    title: title,
                                    text: text,
                                    date: _selectedDate,
                                  );
                                }
                              } else {
                                // 👉 Cập nhật task cũ
                                if (_note != null) {
                                  await _notesService.updateNote(
                                    documentId: _note!.documentId,
                                    title: title,
                                    text: text,
                                    date: _selectedDate,
                                  );
                                }
                              }

                              Navigator.pop(context);
                            },

                            child: Text(
                              isNew ? 'Create' : 'Save',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          default:
            return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
