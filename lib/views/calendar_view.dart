import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:learn_flutter1/views/notes/create_update_task_view.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:learn_flutter1/service/auth/auth_service.dart';
import 'package:learn_flutter1/service/cloud/cloud_task.dart';
import 'package:learn_flutter1/service/cloud/firebase_cloud_storage.dart';
import 'package:learn_flutter1/views/notes/tasks_list_view.dart';

class CalendarTaskView extends StatefulWidget {
  @override
  _CalendarTaskViewState createState() => _CalendarTaskViewState();
}

class _CalendarTaskViewState extends State<CalendarTaskView> {
  DateTime _selectedDay = DateTime.now();
  final _notesService = FireBaseCloudStorage();

  String get userId => AuthService.firebase().currentUser!.id;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Delay 1 frame để widget build xong rồi mới scroll
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final itemWidth = 70.0 + 16.0; // width + margin (xấp xỉ)
      final middleIndex = 7; // hôm nay nằm ở index = 7
      _scrollController.animateTo(
        itemWidth * middleIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isToday = _isSameDate(_selectedDay, DateTime.now());

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => _openCalendarBottomSheet(),
          child: Text(
            isToday
                ? "Today's Tasks"
                : "${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year} Tasks",
            style: const TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildDateStrip(),
          const SizedBox(height: 12),
          Expanded(child: _buildTaskList()),
        ],
      ),
    );
  }

  /// 🔹 BottomSheet Calendar
  void _openCalendarBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        DateTime focusedDay = _selectedDay;
        DateTime? tempSelected = _selectedDay;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const Text(
                    "Chọn ngày",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: focusedDay,
                    selectedDayPredicate: (day) => _isSameDate(tempSelected!, day),
                    onDaySelected: (selected, focused) {
                      setModalState(() {
                        tempSelected = selected;
                        focusedDay = focused;
                      });
                    },
                    calendarFormat: CalendarFormat.month,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (tempSelected != null) {
                        setState(() {
                          _selectedDay = tempSelected!;
                        });
                      }
                      Navigator.pop(context);
                    },
                    child: const Text("Xác nhận"),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// 🔹 Thanh ngày ngang (7 ngày trước + hôm nay + 7 ngày sau)
  Widget _buildDateStrip() {
    final today = DateTime.now();

    return SizedBox(
      height: 100,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: 15, // 7 ngày trước + hôm nay + 7 ngày sau
        itemBuilder: (context, index) {
          final date = today.add(Duration(days: index - 7));
          final isSelected = _isSameDate(date, _selectedDay);

          return GestureDetector(
            onTap: () => setState(() => _selectedDay = date),
            child: Container(
              width: 70,
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0177FF) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _monthName(date.month),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${date.day}",
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _weekdayName(date.weekday),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 🔹 List Task cho ngày chọn
  Widget _buildTaskList() {
    return StreamBuilder(
      stream: _notesService.allNote(ownerUserID: userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return const Center(child: Text("Không có dữ liệu"));
        }

        final allNotes = snapshot.data as Iterable<CloudTask>;

        final tasks = allNotes.where((n) =>
        n.date != null && _isSameDate(n.date!, _selectedDay));

        if (tasks.isEmpty) {
          return Center(
            child: Column(
              children: [
                const SizedBox(height: 50),
                Image.asset(
                  'assets/images/Group_asset2.png',
                  width: 240,
                  height: 340,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Không có task ngày này",
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
          );
        }

        return NotesListView(
          notes: tasks,
          onDeleteNote: (note) async {
            await _notesService.deleteNote(documentId: note.documentId);
          },
          onTap: (note) {
            showGeneralDialog(
              context: context,
              barrierDismissible: true,
              barrierLabel: 'Dismiss',
              barrierColor: Colors.black.withOpacity(0.5),
              pageBuilder: (context, _, __) {
                return Center(
                  child: CreateUpdateNoteView(note: note),
                );
              },
            );
          },
          onChanged: (note, value) async {
            await _notesService.updateNote(
              documentId: note.documentId,
              text: note.text,
              title: note.title,
              isDone: value,
              taskGroup: note.taskGroup,
            );
          },
        );
      },
    );
  }

  /// 🔹 Utils
  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _monthName(int month) {
    const months = [
      "Jan","Feb","Mar","Apr","May","Jun",
      "Jul","Aug","Sep","Oct","Nov","Dec"
    ];
    return months[month - 1];
  }

  String _weekdayName(int weekday) {
    const days = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"];
    return days[weekday - 1];
  }
}
