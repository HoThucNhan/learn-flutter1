import 'package:flutter/material.dart';
import 'package:learn_flutter1/constants/data_ui.dart';
import 'package:learn_flutter1/constants/routes.dart';
import 'package:learn_flutter1/service/auth/auth_service.dart';
import 'package:learn_flutter1/service/cloud/cloud_note.dart';
import 'package:learn_flutter1/service/cloud/firebase_cloud_storage.dart';
import 'package:learn_flutter1/utilities/dialogs/logout_dialog.dart';
import 'package:learn_flutter1/views/notes/create_update_note_view.dart';
import 'package:learn_flutter1/views/notes/notes_list_view.dart';

class NoteView extends StatefulWidget {
  const NoteView({super.key});

  @override
  State<NoteView> createState() => _NoteViewState();
}

class _NoteViewState extends State<NoteView> {
  late final FireBaseCloudStorage _notesService;

  String get userId => AuthService.firebase().currentUser!.id;

  String get userName => AuthService.firebase().currentUser!.name;

  // Date time options
  String selectedFilter = "all";
  DateTime? optionDate;

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
        title: Padding(
          padding: const EdgeInsets.only(left: screenHorizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello $userName!',
                style: TextStyle(
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: screenHorizontalPadding),
            child: IconButton(
              icon: const Icon(Icons.menu, color: Colors.black),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Menu'),
                    backgroundColor: Colors.white,
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.logout),
                          title: const Text('Logout'),
                          onTap: () async {
                            final shouldLogout = await showLogoutDialog(
                              context,
                            );
                            if (shouldLogout) {
                              await AuthService.firebase().logOut();
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                loginRoute,
                                (_) => false,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _notesService.allNote(ownerUserID: userId),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.active:
              if (snapshot.hasData) {
                final allNotes = snapshot.data as Iterable<CloudNote>;
                // Filter list task theo option
                Iterable<CloudNote> filteredNotes;
                String titleText = "Today Tasks";
                final now = DateTime.now();
                if (selectedFilter == "today") {
                  filteredNotes = allNotes.where(
                    (n) =>
                        n.date != null &&
                        n.date!.year == now.year &&
                        n.date!.month == now.month &&
                        n.date!.day == now.day,
                  );
                  titleText = "Today Tasks";
                } else if (selectedFilter == "all") {
                  filteredNotes = allNotes;
                  titleText = "All Tasks";
                } else {
                  if (optionDate == null) {
                    filteredNotes = [];
                    titleText = "Task (pick a date)";
                  } else {
                    filteredNotes = allNotes.where(
                      (n) =>
                          n.date != null &&
                          n.date!.year == optionDate!.year &&
                          n.date!.month == optionDate!.month &&
                          n.date!.day == optionDate!.day,
                    );
                    titleText =
                        "Tasks ${optionDate!.day}/${optionDate!.month}/${optionDate!.year}";
                  }
                }
                final totalTasks = filteredNotes.length;
                final completedTasks = filteredNotes
                    .where((note) => note.isDone)
                    .length;
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: screenHorizontalPadding,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Container hiển thị state
                      Container(
                        width: double.infinity,
                        height: 100,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFF0177FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.black.withOpacity(0.1),
                            width: 1.5,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  titleText,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      '$completedTasks - $totalTasks',
                                      style: TextStyle(
                                        fontSize: 32,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Tasks',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white.withOpacity(0.72),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(width: 4.0),
                            Positioned(
                              right: -10,
                              top: -40,
                              child: SizedBox(
                                width: 150,
                                height: 150,
                                child: Image.asset(
                                  'assets/images/date_image.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Filter buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ChoiceChip(
                            label: Text(
                              "Today",
                              style: TextStyle(
                                color: selectedFilter == "today"
                                    ? Colors.white
                                    : Color(0xFF9B9B9B),
                              ),
                            ),
                            selected: selectedFilter == "today",
                            selectedColor: const Color(0xFF3C96FF),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: Colors.black.withOpacity(0.1),
                                width: 1.5,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            onSelected: (_) {
                              setState(() => selectedFilter = "today");
                            },
                          ),
                          ChoiceChip(
                            label: Text(
                              "All",
                              style: TextStyle(
                                color: selectedFilter == "all"
                                    ? Colors.white
                                    : Color(0xFF9B9B9B),
                              ),
                            ),
                            selected: selectedFilter == "all",
                            selectedColor: const Color(0xFF3C96FF),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: Colors.black.withOpacity(0.1),
                                width: 1.5,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            onSelected: (_) {
                              setState(() => selectedFilter = "all");
                            },
                          ),
                          ChoiceChip(
                            label: Text(
                              "Option",
                              style: TextStyle(
                                color: selectedFilter == "Option"
                                    ? Colors.white
                                    : Color(0xFF9B9B9B),
                              ),
                            ),
                            selected: selectedFilter == "option",
                            selectedColor: const Color(0xFF3C96FF),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: Colors.black.withOpacity(0.1),
                                width: 1.5,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            onSelected: (_) async {
                              setState(() => selectedFilter = "option");
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                setState(() => optionDate = picked);
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // List tasks
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 120),
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
                      ),
                    ],
                  ),
                );
              } else {
                return const CircularProgressIndicator();
              }
            default:
              return const CircularProgressIndicator();
          }
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF0177FF),
        elevation: 4,
        shape: CircleBorder(),
        onPressed: () {
          showGeneralDialog(
            context: context,
            barrierDismissible: true,
            barrierLabel: 'Dismiss',
            barrierColor: Colors.black.withOpacity(0.5),
            pageBuilder: (context, _, __) {
              return Center(child: CreateUpdateNoteView(note: null));
            },
          );
        },
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
