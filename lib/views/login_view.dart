import 'package:flutter/material.dart';
import 'package:learn_flutter1/constants/routes.dart';
import 'package:learn_flutter1/service/auth/auth_exception.dart';
import 'package:learn_flutter1/service/auth/auth_service.dart';
import 'package:learn_flutter1/utilities/dialogs/error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController();
    _password = TextEditingController();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: FutureBuilder(
        future: AuthService.firebase().Initialize(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 50),
                    Center(
                      child: Image.asset(
                        'assets/images/login_view.png',
                        width: 200,
                        height: 200,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 12, top: 40, bottom: 6),
                      child: Text(
                        'Email',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white30, width: 1.2),
                      ),

                      child: TextField(
                        controller: _email,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter your email',
                        ),
                        enableSuggestions: false,
                        autocorrect: false,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(
                          color: Colors.white,
                        )
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 12, top: 20, bottom: 6),
                      child: Text(
                        'Password',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white30, width: 1.2),
                      ),
                      child: TextField(
                        controller: _password,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '••••••••••••••••',
                        ),
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                        autofillHints: null,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: MaterialButton(
                        onPressed: () async {
                          final email = _email.text;
                          final password = _password.text;
                          try {
                            await AuthService.firebase().logIn(
                              email: email,
                              password: password,
                            );
                            final user = AuthService.firebase().currentUser;
                            if (user?.isEmailVerified ?? false) {
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                notesRoute,
                                (route) => false,
                              );
                            } else {
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                verifyEmailRoute,
                                (route) => false,
                              );
                            }
                          } on InvalidCredentialAuthException {
                            await showErrorDialog(
                              context,
                              'Email or password is incorrect',
                            );
                          } on InvalidEmailAuthException {
                            await showErrorDialog(context, 'invalid-email');
                          } on GenericAuthException {
                            await showErrorDialog(context, 'Authentication error');
                          }
                        },
                        child: const Text('Login'),
                        color: Color(0xFF8687E7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),

                      ),
                    ),
                    const SizedBox(height: 50),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            registerRoute,
                            (route) => false,
                          );
                        },
                        child: const Text('Not registered yet? Register here!', ),
                      ),
                    ),
                  ],
                ),
              );
            default:
              return Text('Loading...');
          }
        },
      ),
    );
  }
}
