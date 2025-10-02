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
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final TextEditingController _confirmPassword;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
    _email = TextEditingController();
    _password = TextEditingController();
    _confirmPassword = TextEditingController();
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  // 🔹 Tạo InputDecoration dùng chung cho các TextField
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Colors.black.withOpacity(0.41),
      ),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.grey, width: 1.2),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF0177FF), width: 2),
      ),
      disabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.grey, width: 1.2),
      ),
      errorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Sign Up',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: FutureBuilder(
        future: AuthService.firebase().Initialize(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return Padding(
                padding: const EdgeInsets.all(40.0),
                child: SingleChildScrollView( // tránh tràn màn hình khi bàn phím bật
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 50),
                      Text(
                        'Name',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black.withOpacity(0.72),
                        ),
                      ),
                      TextField(
                        controller: _name,
                        decoration: _inputDecoration('Enter your name'),
                        enableSuggestions: false,
                        autocorrect: false,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(height: 25),
                      Text(
                        'Email',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black.withOpacity(0.72),
                        ),
                      ),
                      TextField(
                        controller: _email,
                        decoration: _inputDecoration('Enter your email'),
                        keyboardType: TextInputType.emailAddress,
                        enableSuggestions: false,
                        autocorrect: false,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(height: 25),
                      Text(
                        'Password',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black.withOpacity(0.72),
                        ),
                      ),
                      TextField(
                        controller: _password,
                        decoration: _inputDecoration('Enter your password'),
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(height: 25),
                      Text(
                        'Confirm Password',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black.withOpacity(0.72),
                        ),
                      ),
                      TextField(
                        controller: _confirmPassword,
                        decoration: _inputDecoration('Confirm your password'),
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(height: 50),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: SizedBox(
                          width: double.infinity,
                          height: 69,
                          child: ElevatedButton(
                            onPressed: () async {
                              final name = _name.text;
                              final email = _email.text;
                              final password = _password.text;
                              final confirmPassword = _confirmPassword.text;

                              if (password != confirmPassword) {
                                await showErrorDialog(
                                  context,
                                  'Passwords do not match',
                                );
                                return;
                              }
                              if (name.isEmpty ||
                                  email.isEmpty ||
                                  password.isEmpty ||
                                  confirmPassword.isEmpty) {
                                await showErrorDialog(
                                  context,
                                  'All fields must be filled',
                                );
                                return;
                              }

                              try {
                                await AuthService.firebase().CreateUser(
                                  email: email,
                                  password: password,
                                  name: name,
                                );
                                await AuthService.firebase().sendEmailVerification();
                                Navigator.of(context).pushNamed(verifyEmailRoute);
                              } on WeakPasswordAuthException {
                                await showErrorDialog(context, 'Password is too weak');
                              } on EmailAlreadyInUseAuthException {
                                await showErrorDialog(context, 'Email is already in use');
                              } on InvalidEmailAuthException {
                                await showErrorDialog(context, 'Invalid email entered');
                              } on GenericAuthException {
                                await showErrorDialog(context, 'Failed to register');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0177FF),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 14,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text(
                                  'Sign Up',
                                  style: TextStyle(fontSize: 20, color: Colors.white),
                                ),
                                Spacer(),
                                Icon(Icons.arrow_forward, size: 25),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account?',
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.79),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                loginRoute,
                                    (route) => false,
                              );
                            },
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                color: Color(0xFF0177FF),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline,
                                decorationColor: Color(0xFF0177FF),
                                decorationThickness: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            default:
              return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
