import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:learn_flutter1/service/cloud/cloud_note.dart';
import 'package:learn_flutter1/utilities/dialogs/delete_dialog.dart';

typedef NoteCallback = void Function(CloudNote note);

class NotesListView extends StatefulWidget {
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
  State<NotesListView> createState() => _NotesListViewState();
}

class _NotesListViewState extends State<NotesListView> {
  final ScrollController _scrollController = ScrollController();

  // Tùy chỉnh visuals
  final double _trackWidth = 6.0;
  final double _minThumbHeight = 24.0;

  @override
  void initState() {
    super.initState();
    // Khi scroll thay đổi thì rebuild để cập nhật thumb (safe)
    _scrollController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double viewHeight = constraints.maxHeight;

        return Row(
          children: [
            // Track + Thumb
            SizedBox(
              width: _trackWidth,
              height: viewHeight,
              child: AnimatedBuilder(
                animation: _scrollController,
                builder: (context, child) {
                  // Track nền
                  final track = Container(
                    width: _trackWidth,
                    height: viewHeight,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );

                  // Nếu chưa attach thì chỉ vẽ track
                  if (!_scrollController.hasClients) return track;

                  final maxScroll = _scrollController.position.maxScrollExtent;
                  final scrollOffset = _scrollController.position.pixels.clamp(
                    0.0,
                    maxScroll,
                  );

                  // Tổng chiều cao content
                  final contentHeight = viewHeight + maxScroll;

                  // Tỉ lệ phần nhìn thấy
                  final fractionVisible = contentHeight <= 0
                      ? 1.0
                      : (viewHeight / contentHeight);

                  // Chiều cao thumb (có min)
                  final thumbHeight = math.max(
                    _minThumbHeight,
                    viewHeight * fractionVisible,
                  );

                  // Vị trí top của thumb (luôn trong giới hạn)
                  final thumbTop = maxScroll <= 0
                      ? 0.0
                      : (scrollOffset / maxScroll) * (viewHeight - thumbHeight);

                  return Stack(
                    children: [
                      track,
                      Positioned(
                        top: thumbTop,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: thumbHeight,
                          decoration: BoxDecoration(
                            color: Color(0xFF0177FF),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: widget.notes.length,
                padding: const EdgeInsets.only(bottom: 10),
                itemBuilder: (context, index) {
                  final note = widget.notes.elementAt(index);
                  return ToDoTile(
                    title: note.title,
                    text: note.text,
                    isDone: note.isDone,
                    onChanged: (value) {
                      if (value != null) widget.onChanged(note, value);
                    },
                    onDelete: () async {
                      final shouldDelete = await showDeleteDialog(context);
                      if (shouldDelete) widget.onDeleteNote(note);
                    },
                    onTap: () => widget.onTap(note),
                  );
                },
              ),
            ),
          ],
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
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 5.0, bottom: 8.0),
        decoration: BoxDecoration(
          color: isDone
              ? const Color(0xFF2D9BEE).withOpacity(0.16)
              : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black.withOpacity(0.1), width: 1.5),
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
                  fontWeight: FontWeight.w500,
                  color: isDone ? Colors.black.withOpacity(0.47) : Colors.black,
                ),
              ),
              Text(
                text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: isDone
                      ? Colors.black.withOpacity(0.37)
                      : Colors.black.withOpacity(0.6),
                  fontWeight: FontWeight.w400,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!isDone) ...[
                    OutlinedButton(
                      onPressed: onDelete,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                        side: const BorderSide(color: Colors.black12),
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(76, 35),
                      ),
                      child: Text(
                        'Delete',
                        style: TextStyle(
                          color: Colors.black..withOpacity(0.54),
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (onChanged != null) {
                          onChanged!(!isDone);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF2D9BEE),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                        minimumSize: const Size(76, 35),
                        padding: EdgeInsets.zero,
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ] else ...[
                    IconButton(
                      onPressed: () {
                        if (onChanged != null) {
                          onChanged!(!isDone);
                        }
                      },
                      icon: SvgPicture.asset(
                        'assets/icons/checkmark-done-circle.svg',
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
