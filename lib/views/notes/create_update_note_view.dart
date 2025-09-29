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
  late final TextEditingController _textController;
  late final TextEditingController _titleController;

  @override
  void initState() {
    _notesService = FireBaseCloudStorage();
    _textController = TextEditingController();
    _titleController = TextEditingController();
    _titleController.addListener(_titleControllerListener);
    super.initState();
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) return;
    final text = _textController.text;
    final title = _titleController.text;
    await _notesService.updateNote(documentId: note.documentID, text: text, title: title);
  }

  void _setupTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  void _titleControllerListener() async {
    final note = _note;
    if (note == null) return;
    final title = _titleController.text;
    await _notesService.updateNote(
      documentId: note.documentID,
      title: title,
      text: _textController.text,
    );
  }

  Future<CloudNote> createOrGetExistingNote(BuildContext context) async {
    final widgetNote = context.getArgument<CloudNote>();
    if (widgetNote != null) {
      _note = widgetNote;
      _titleController.text = widgetNote.title;
      _textController.text = widgetNote.text;
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
    if (note != null && (text.isNotEmpty || title.isNotEmpty)) {
      await _notesService.updateNote(
        documentId: note.documentID,
        title: title,
        text: text,
      );
    }
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextNotEmpty();
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double fontSize = 18.0;
    const double lineHeightFactor = 1.8;
    const double contentPaddingTop = 16.0;

    final textScale = MediaQuery.of(context).textScaleFactor;
    final textStyle = TextStyle(
      fontSize: fontSize,
      height: lineHeightFactor,
      color: Colors.white,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Note'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: FutureBuilder(
        future: createOrGetExistingNote(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _setupTextControllerListener();
              return Column(
                children: [
                  Container(
                    width: double.infinity,
                    color: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        hintText: 'Title',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.white70),
                      ),
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Expanded(
                    child: CustomPaint(
                      painter: LinedPaperPainter(
                        textStyle: textStyle,
                        textScaleFactor: textScale,
                        contentPaddingTop: contentPaddingTop,
                        lineColor: Colors.white.withOpacity(0.12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: contentPaddingTop,
                          bottom: 32,
                        ),
                        child: TextField(
                          controller: _textController,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          decoration: const InputDecoration.collapsed(
                            hintText: 'Start typing your note...',
                            hintStyle: TextStyle(color: Colors.white54),
                          ),
                          style: textStyle,
                          textAlignVertical: TextAlignVertical.top,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            default:
              return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class LinedPaperPainter extends CustomPainter {
  final TextStyle textStyle;
  final double textScaleFactor;
  final double contentPaddingTop;
  final Color lineColor;

  LinedPaperPainter({
    required this.textStyle,
    required this.textScaleFactor,
    required this.contentPaddingTop,
    this.lineColor = const Color.fromARGB(100, 255, 255, 255),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final tp = TextPainter(
      text: TextSpan(text: 'Hg', style: textStyle),
      textDirection: TextDirection.ltr,
      textScaleFactor: textScaleFactor,
    );

    tp.layout(minWidth: 0, maxWidth: size.width);

    final metrics = tp.computeLineMetrics();
    double lineHeight;
    double ascent;

    if (metrics.isNotEmpty) {
      lineHeight = metrics[0].height;
      ascent = metrics[0].ascent;
    } else {
      final fz = textStyle.fontSize ?? 16.0;
      final h = textStyle.height ?? 1.0;
      lineHeight = fz * h * textScaleFactor;
      ascent = fz * 0.8 * textScaleFactor;
    }

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.0;

    double y = contentPaddingTop + ascent;

    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      y += lineHeight;
    }
  }

  @override
  bool shouldRepaint(covariant LinedPaperPainter oldDelegate) {
    return oldDelegate.textStyle != textStyle ||
        oldDelegate.textScaleFactor != textScaleFactor ||
        oldDelegate.contentPaddingTop != contentPaddingTop ||
        oldDelegate.lineColor != lineColor;
  }
}
