import 'package:flutter/material.dart';
import 'package:learn_flutter1/constants/routes.dart';
import 'package:learn_flutter1/service/auth/auth_service.dart';
import 'package:learn_flutter1/service/theme_controller.dart';
import 'package:learn_flutter1/views/login_view.dart';
import 'package:learn_flutter1/views/notes/create_update_note_view.dart';
import 'package:learn_flutter1/views/notes/notes_view.dart';
import 'package:learn_flutter1/views/register_view.dart';
import 'package:learn_flutter1/views/verify_email_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeController = ThemeController.instance;
  runApp(
    AnimatedBuilder(
      animation: themeController,
      builder: (context, _) {
        return MaterialApp(
          title: 'Flutter Demo',
          themeMode: themeController.themeMode,
          theme: ThemeData(
            brightness: Brightness.light,
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.black,
              elevation: 0,
              centerTitle: true,
            ),
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
              },
            ),
            cardTheme: CardThemeData(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey, brightness: Brightness.dark),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
            ),
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
              },
            ),
            cardTheme: CardThemeData(
              elevation: 0,
              color: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          home: HomePage(themeController: themeController),
          routes: {
            loginRoute: (context) => const LoginView(),
            registerRoute: (context) => const RegisterView(),
            notesRoute: (context) => const NoteView(),
            verifyEmailRoute: (context) => const VerifyEmailView(),
            createOrUpdateNoteRoute: (context) => const CreateUpdateNoteView(),
          },
        );
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  final ThemeController themeController;
  const HomePage({super.key, required this.themeController});

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
                return const NoteView();
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





