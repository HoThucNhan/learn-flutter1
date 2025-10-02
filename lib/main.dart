import 'package:flutter/material.dart';
import 'package:learn_flutter1/constants/routes.dart';
import 'package:learn_flutter1/service/auth/auth_service.dart';
import 'package:learn_flutter1/views/login_view.dart';
import 'package:learn_flutter1/views/main_page_view.dart';
import 'package:learn_flutter1/views/notes/create_update_task_view.dart';
import 'package:learn_flutter1/views/notes/tasks_view.dart';
import 'package:learn_flutter1/views/search_task_view.dart';
import 'package:learn_flutter1/views/register_view.dart';
import 'package:learn_flutter1/views/verify_email_view.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        textTheme: GoogleFonts.robotoTextTheme(),
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0177FF),
          foregroundColor: Colors.white,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomePage(),
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        notesRoute: (context) => const NoteView(),
        verifyEmailRoute: (context) => const VerifyEmailView(),
        createOrUpdateNoteRoute: (context) => const CreateUpdateNoteView(),
        mainPageRoute: (context) => const MainPageView(),
        searchTaskRoute: (context) => const SearchTaskView(),
      },
      builder: (context, child) {
        return Stack(
          children: [
            Image.asset(
              'assets/images/Splash.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            Material(type: MaterialType.transparency, child:child!),
          ],
        );
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.firebase().Initialize(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = AuthService.firebase().currentUser;
            if (user != null) {
              if (user.isEmailVerified) {
                return const MainPageView();
              } else {
                return const VerifyEmailView();
              }
            } else {
              return const LoginView();
            }

          default:
            return CircularProgressIndicator();
        }
      },
    );
  }
}
