import 'package:flutter/material.dart';
import 'package:learn_flutter1/constants/routes.dart';
import 'package:learn_flutter1/service/auth/auth_exception.dart';
import 'package:learn_flutter1/service/auth/auth_service.dart';
import 'package:learn_flutter1/utilities/dialogs/error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final TextEditingController _confirmPassword;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController();
    _password = TextEditingController();
    _confirmPassword = TextEditingController();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
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
                          hintText: 'Enter your email',
                          border: InputBorder.none,
                        ),
                        enableSuggestions: false,
                        autocorrect: false,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
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
                        border: Border.all(color: Colors.white30, width: 1.2,),
                      ),
                      child: TextField(
                        controller: _password,
                        decoration: const InputDecoration(
                          hintText: '••••••••••••••••',
                          border: InputBorder.none,
                        ),
                        obscureText: true,
                        obscuringCharacter: '•',
                        enableSuggestions: false,
                        autocorrect: false,
                        autofillHints: null,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 12, top: 20, bottom: 6),
                      child: Text(
                        'Confirm Password',
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
                        border: Border.all(color: Colors.white30, width: 1.2,),
                      ),
                      child: TextField(
                        controller: _confirmPassword,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '••••••••••••••••'
                        ),
                        obscureText: true,
                        obscuringCharacter: '•',
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
                          final confirmPassword = _confirmPassword.text;
                          if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
                            await showErrorDialog(
                              context,
                              'All fields must be filled in completely!',
                            );
                            return;
                          }
                          if (password != confirmPassword) {
                            await showErrorDialog(
                              context,
                              'Passwords do not match',
                            );
                            _password.clear();
                            _confirmPassword.clear();
                            return;
                          }
                          try {
                            await AuthService.firebase().CreateUser(
                                  email: email,
                                  password: password,
                                );
                            await AuthService.firebase().sendEmailVerification();
                            Navigator.of(context).pushNamed(
                              verifyEmailRoute,
                            );
                          } on WeakPasswordAuthException {
                            await showErrorDialog(
                              context,
                              'Password is too weak',
                            );
                          } on EmailAlreadyInUseAuthException {
                            await showErrorDialog(
                              context,
                              'Email is already in use',
                            );
                          } on InvalidEmailAuthException {
                            await showErrorDialog(
                              context,
                              'Invalid email entered',
                            );
                          } on GenericAuthException {
                            await showErrorDialog(
                              context,
                              'Failed to register',
                            );
                          }

                        },
                        child: const Text('Register'),
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
                          Navigator.of(
                            context,
                          ).pushNamedAndRemoveUntil(loginRoute, (route) => false);
                        },
                        child: const Text('Already registered? Login here!'),
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
