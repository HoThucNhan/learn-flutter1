import 'package:learn_flutter1/service/auth/auth_user.dart';

abstract class AuthProvider {
  AuthUser? get currentUser;
  Future<void> Initialize();
  Future<AuthUser> logIn({
    required String email,
    required String password,
  });
  Future<AuthUser> CreateUser({
    required String email,
    required String password,
  });
  Future<void> logOut();
  Future<void> sendEmailVerification();
  Future<void> reloadUser();
}
