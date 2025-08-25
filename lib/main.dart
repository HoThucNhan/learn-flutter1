import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:learn_flutter1/firebase_options.dart';
import 'package:learn_flutter1/views/login_view.dart';

const String resetColor = '\x1B[0m';
const String redColor = '\x1B[31m';
const String greenColor = '\x1B[32m';
const String yellowColor = '\x1B[33m';
const String blueColor = '\x1B[34m';
const String magentaColor = '\x1B[35m';
const String cyanColor = '\x1B[36m';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomePage(),
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = FirebaseAuth.instance.currentUser;
              if(user?.emailVerified ?? false) {
                print('You are verified user');
              } else {
                print('You need to verify your email first');
              }
              return Text('Done');
            default:
              return Text('Loading...');
          }
        },
      ),
    );
  }
}




