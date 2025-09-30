import 'package:flutter/material.dart';
import 'package:learn_flutter1/constants/routes.dart';
import 'package:learn_flutter1/enum/menu_action.dart';
import 'dart:developer' as devtools show log;
import 'package:learn_flutter1/service/auth/auth_service.dart';
import 'package:learn_flutter1/service/cloud/cloud_note.dart';
import 'package:learn_flutter1/service/cloud/firebase_cloud_storage.dart';
import 'package:learn_flutter1/utilities/dialogs/logout_dialog.dart';
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello $userName!',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Have a great day!!!',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogoutDialog(context);
                  if (shouldLogout) {
                    await AuthService.firebase().logOut();
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil(loginRoute, (_) => false);
                  } else {
                    devtools.log('User canceled logout');
                  }
                  break;
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('Logout'),
                ),
              ];
            },
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
                return Column(
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      height: 100,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Stack(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        clipBehavior: Clip.none,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Today Tasks',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                '3 - 10 Task',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
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
                    Expanded(
                      child: NotesListView(
                        notes: allNotes,
                        onDeleteNote: (note) async {
                          await _notesService.deleteNote(
                            documentId: note.documentID,
                          );
                        },
                        onTap: (note) {
                          Navigator.of(
                            context,
                          ).pushNamed(createOrUpdateNoteRoute, arguments: note);
                        },
                        onChanged: (note, value) async {
                          await _notesService.updateNote(
                            documentId: note.documentID,
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
              } else {
                return const CircularProgressIndicator();
              }
            default:
              return const CircularProgressIndicator();
          }
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.transparent,
        elevation: 0,
        onPressed: () {
          Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
        },
        child: Center(
          child: CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blue,
            child: const Icon(Icons.add, size: 30, color: Colors.white),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
