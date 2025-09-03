import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learn_flutter1/constants/routes.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email')),
      body: Column(
        children: [
          Text(
            "We've sent you an email verification, please check your inbox.",
          ),
          Text(
            "If you don't see it, please press the button below to send it again.",
          ),
          TextButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              await user?.sendEmailVerification();
            },
            child: const Text('Send verification email'),
          ),
          TextButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              await FirebaseAuth.instance.signOut();
            },
            child: const Text('Delete account'),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.currentUser?.reload();
              final refreshedUser = FirebaseAuth.instance.currentUser;
              if (refreshedUser?.emailVerified ?? false) {
                Navigator.of(context).pushNamedAndRemoveUntil(notesRoute, (route) => false);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Email chưa được xác thực, thử lại sau.")),
                );
              }
            },
            child: const Text('Reload'),
          ),
        ],
      ),
    );
  }
}
