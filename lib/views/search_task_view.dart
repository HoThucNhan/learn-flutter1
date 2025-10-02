import 'package:flutter/material.dart';
import 'package:learn_flutter1/service/cloud/cloud_task.dart';
import 'package:learn_flutter1/service/cloud/firebase_cloud_storage.dart';
import 'package:learn_flutter1/service/auth/auth_service.dart';
import 'package:learn_flutter1/views/notes/create_update_task_view.dart';
import 'package:learn_flutter1/views/notes/tasks_list_view.dart';

class SearchTaskView extends StatefulWidget {
  const SearchTaskView({super.key});

  @override
  State<SearchTaskView> createState() => _SearchTaskViewState();
}

class _SearchTaskViewState extends State<SearchTaskView> {
  final TextEditingController _searchController = TextEditingController();
  final FireBaseCloudStorage _notesService = FireBaseCloudStorage();
  Iterable<CloudTask> _allNotes = [];
  Iterable<CloudTask> _filteredNotes = [];

  @override
  void initState() {
    super.initState();
    _fetchNotes();
    _searchController.addListener(_filterNotes);
  }

  void _fetchNotes() async {
    final userId = AuthService.firebase().currentUser!.id;
    final notesStream = _notesService.allNote(ownerUserID: userId);
    notesStream.listen((notes) {
      setState(() {
        _allNotes = notes;
        _filteredNotes = notes;
      });
    });
  }

  void _filterNotes() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredNotes = _allNotes.where(
        (note) =>
            note.title.toLowerCase().contains(query) ||
            note.text.toLowerCase().contains(query),
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Search Tasks',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        centerTitle: true,
        // back button
        // leadingWidth: screenHorizontalPadding + 40,
        // leading: Container(
        //   margin: const EdgeInsets.only(left: screenHorizontalPadding),
        //   child: IconButton(
        //     icon: SvgPicture.asset(
        //       'assets/icons/Arrow-Left.svg',
        //       width: 24,
        //       height: 24,
        //     ),
        //     onPressed: () {
        //       Navigator.of(context).pop();
        //     },
        //   ),
        // ),
      ),
      body: Column(
        children: [
          SizedBox(height: 30),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search tasks...',
              hintStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.black.withOpacity(0.41),
              ),
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: NotesListView(
              notes: _filteredNotes,
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
      ),
    );
  }
}
