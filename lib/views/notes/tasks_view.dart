import 'package:flutter/material.dart';
import 'package:learn_flutter1/constants/routes.dart';
import 'package:learn_flutter1/constants/task_groups.dart';
import 'package:learn_flutter1/service/auth/auth_service.dart';
import 'package:learn_flutter1/service/cloud/cloud_task.dart';
import 'package:learn_flutter1/service/cloud/firebase_cloud_storage.dart';
import 'package:learn_flutter1/views/notes/create_update_task_view.dart';
import 'package:learn_flutter1/views/notes/tasks_list_view.dart';

class NoteView extends StatefulWidget {
  const NoteView({super.key});

  @override
  State<NoteView> createState() => _NoteViewState();
}

class _NoteViewState extends State<NoteView> {
  late final FireBaseCloudStorage _notesService;

  String get userId => AuthService.firebase().currentUser!.id;
  String get userName => AuthService.firebase().currentUser!.name;

  String? selectedGroup; // null = màn danh sách group

  @override
  void initState() {
    _notesService = FireBaseCloudStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello $userName!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              'Have a great day!!!',
              style: TextStyle(
                color: Colors.black.withOpacity(0.65),
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      body: StreamBuilder(
        stream: _notesService.allNote(ownerUserID: userId),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.active:
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final allNotes = snapshot.data as Iterable<CloudTask>;

              if (selectedGroup == null) {
                // === Màn hình hiển thị danh sách group ===
                return ListView.builder(
                  itemCount: TaskGroups.all.length + 2,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      final total = allNotes.length;
                      final completed = allNotes.where((n) => n.isDone).length;
                      return _buildAllTasksCard(
                        totalTasks: total,
                        completedTasks: completed,
                        onViewTap: () =>
                            setState(() => selectedGroup = "All Tasks"),
                      );
                    } else if (index == 1) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 12),
                            Text(
                              "Tasks Group",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final group = TaskGroups.all[index - 2];
                    final icon = TaskGroupIcons.icons[group] ?? Icons.task_alt;
                    final groupNotes =
                    allNotes.where((n) => n.taskGroup == group).toList();
                    final total = groupNotes.length;
                    final completed = groupNotes.where((n) => n.isDone).length;

                    return _buildGroupItem(
                      group: group,
                      icon: icon,
                      totalTasks: total,
                      completedTasks: completed,
                      onTap: () => setState(() => selectedGroup = group),
                    );
                  },
                );
              } else {
                // === Màn hình hiển thị task list của group ===
                Iterable<CloudTask> filteredNotes;
                if (selectedGroup == 'All Tasks') {
                  filteredNotes = allNotes;
                } else {
                  filteredNotes =
                      allNotes.where((n) => n.taskGroup == selectedGroup);
                }

                final total = filteredNotes.length;
                final completed = filteredNotes.where((n) => n.isDone).length;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => setState(() => selectedGroup = null),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.arrow_back, color: Colors.black),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: (selectedGroup == "All Tasks")
                                ? _buildAllTasksCard(
                              totalTasks: total,
                              completedTasks: completed,
                              onViewTap: () {}, // disable
                            )
                                : _buildGroupItem(
                              group: selectedGroup!,
                              icon: TaskGroupIcons.icons[selectedGroup] ??
                                  Icons.task_alt,
                              totalTasks: total,
                              completedTasks: completed,
                              onTap: () {}, // disable
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: NotesListView(
                        notes: filteredNotes,
                        onDeleteNote: (note) async {
                          await _notesService.deleteNote(
                            documentId: note.documentId,
                          );
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
                            isDone: value,
                            title: note.title,
                          );
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                );
              }

            default:
              return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  /// Card All Tasks (màu xanh 0177FF)
  Widget _buildAllTasksCard({
    required int totalTasks,
    required int completedTasks,
    required VoidCallback onViewTap,
  }) {
    final progress = totalTasks == 0 ? 0.0 : completedTasks / totalTasks;

    return Container(
      margin: const EdgeInsets.only(bottom: 12, left: 16, right: 16, top: 60),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF0177FF), Color(0xFF0177FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Your All Tasks",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: onViewTap,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "View Task",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            width: 70,
            height: 70,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                Text(
                  "${(progress * 100).toInt()}%",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Card hiển thị 1 group
  Widget _buildGroupItem({
    required String group,
    required IconData icon,
    required int totalTasks,
    required int completedTasks,
    required VoidCallback onTap,
  }) {
    final progress = totalTasks == 0 ? 0.0 : completedTasks / totalTasks;

    // map màu theo group
    Color bgColor;
    Color iconColor;
    switch (group.toLowerCase()) {
      case "daily":
        bgColor = const Color(0xFFFFE6D4);
        iconColor = const Color(0xFFFF7A00); // cam
        break;
      case "personal":
        bgColor = const Color(0xFFEDE4FF);
        iconColor = const Color(0xFF6C63FF); // tím
        break;
      case "office":
        bgColor = const Color(0xFFFFE4F2);
        iconColor = const Color(0xFFFF4D88); // hồng
        break;
      case "general":
        bgColor = const Color(0xFFFFF9E6);
        iconColor = const Color(0xFFFFC107); // vàng
        break;
      default:
        bgColor = Colors.grey.shade100;
        iconColor = Colors.black87;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "$totalTasks Tasks",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 42,
                  width: 42,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 4,
                    backgroundColor: Colors.grey.shade200,
                    valueColor:
                    const AlwaysStoppedAnimation<Color>(Colors.pinkAccent),
                  ),
                ),
                Text(
                  "${(progress * 100).toInt()}%",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
