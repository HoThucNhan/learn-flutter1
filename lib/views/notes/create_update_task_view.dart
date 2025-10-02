import 'package:flutter/material.dart';
import 'package:learn_flutter1/constants/task_groups.dart';
import 'package:learn_flutter1/service/auth/auth_service.dart';
import 'package:learn_flutter1/service/cloud/cloud_task.dart';
import 'package:learn_flutter1/service/cloud/firebase_cloud_storage.dart';

class CreateUpdateNoteView extends StatefulWidget {
  final CloudTask? note;

  const CreateUpdateNoteView({super.key, this.note});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  CloudTask? _note;
  late final FireBaseCloudStorage _notesService;
  late final TextEditingController _titleController;
  late final TextEditingController _textController;
  DateTime? _selectedDate;
  String _selectedGroup = TaskGroups.general;

  bool _shouldSave = false;
  late final bool isNew = widget.note == null;

  @override
  void initState() {
    _notesService = FireBaseCloudStorage();
    _textController = TextEditingController();
    _titleController = TextEditingController();
    _selectedDate = widget.note?.date;
    _selectedGroup = widget.note?.taskGroup ?? TaskGroups.general;
    super.initState();
  }

  Future<CloudTask?> createOrGetExistingNote(BuildContext context) async {
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
        taskGroup: _selectedGroup,
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
                      // Title
                      Text(
                        isNew ? 'Create Task' : 'Update Task',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Task title
                      TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          hintText: 'Title',
                          hintStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.black.withOpacity(0.41),
                          ),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Task content
                      TextField(
                        controller: _textController,
                        keyboardType: TextInputType.multiline,
                        maxLength: 100,
                        maxLines: 5,
                        textInputAction: TextInputAction.newline,
                        expands: false,
                        decoration: InputDecoration(
                          hintText: 'Description (max 100 chars)',
                          hintStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.black.withOpacity(0.41),
                          ),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Task date
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
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: _selectedDate == null
                                    ? Colors.black.withOpacity(0.41)
                                    : Colors.black,
                              ),
                            ),
                            IconButton(
                              onPressed: _pickDate,
                              icon: const Icon(Icons.calendar_month),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Task Group Dropdown (custom design)
                      // Task Group Dropdown (custom design)
                      DropdownButtonHideUnderline(
                        child: DropdownButtonFormField<String>(
                          value: _selectedGroup,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                            ),
                            labelText: 'Task Group',
                            filled: true,
                            fillColor: Colors.white, // nền trắng cho box
                          ),
                          dropdownColor: Colors.white, // nền trắng cho menu khi mở
                          borderRadius: BorderRadius.circular(12), // bo góc menu
                          items: TaskGroups.all.map((group) {
                            final icon = TaskGroupIcons.icons[group] ?? Icons.task;
                            final color = TaskGroupIcons.colors[group] ?? Colors.grey;

                            return DropdownMenuItem(
                              value: group,
                              child: Row(
                                children: [
                                  Icon(icon, color: color, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    group,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedGroup = value;
                              });
                            }
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Action buttons
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
                              backgroundColor: const Color(0xFF0177FF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () async {
                              final text = _textController.text;
                              final title = _titleController.text;
                              final currentUser =
                              AuthService.firebase().currentUser!;
                              final userId = currentUser.id;

                              if (isNew) {
                                if (title.isNotEmpty || text.isNotEmpty) {
                                  await _notesService.createNewNote(
                                    ownerUserID: userId,
                                    title: title,
                                    text: text,
                                    date: _selectedDate,
                                    taskGroup: _selectedGroup,
                                  );
                                }
                              } else {
                                if (_note != null) {
                                  await _notesService.updateNote(
                                    documentId: _note!.documentId,
                                    title: title,
                                    text: text,
                                    date: _selectedDate,
                                    taskGroup: _selectedGroup,
                                  );
                                }
                              }

                              Navigator.pop(context);
                            },
                            child: Text(
                              isNew ? 'Create' : 'Save',
                              style: const TextStyle(color: Colors.white),
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
