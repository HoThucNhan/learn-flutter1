import 'package:flutter/material.dart';
import 'package:learn_flutter1/constants/routes.dart';
import 'package:learn_flutter1/service/auth/auth_service.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email'), backgroundColor: Colors.black, elevation: 0,),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          const SizedBox(height: 50),
          Text(
            "We've sent you an email verification, please check your inbox.",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          Text(
            "If you don't see it, please press the button below to send it again.",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          TextButton(
            onPressed: () async {
              await AuthService.firebase().sendEmailVerification();
            },
            child: const Text('Send verification email'),
          ),
          TextButton(
            onPressed: () async {
              await AuthService.firebase().logOut();
              Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (route) => false);
            },
            child: const Text('Delete account'),
          ),
          TextButton(
            onPressed: () async {
              await AuthService.firebase().reloadUser();
              final refreshedUser = AuthService.firebase().currentUser;
              if (refreshedUser?.isEmailVerified ?? false) {
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
