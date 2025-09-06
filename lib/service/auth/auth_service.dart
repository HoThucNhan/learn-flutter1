import 'package:learn_flutter1/service/auth/auth_provider.dart';
import 'package:learn_flutter1/service/auth/auth_user.dart';
import 'package:learn_flutter1/service/auth/firebase_auth_provider.dart';

class AuthService implements AuthProvider {
  final AuthProvider provider;

  AuthService(this.provider);

  factory AuthService.firebase() => AuthService(FirebaseAuthProvider());

  @override
  Future<AuthUser> CreateUser({
    required String email,
    required String password,
  }) => provider.CreateUser(email: email, password: password);

  @override
  AuthUser? get currentUser => provider.currentUser;

  @override
  Future<AuthUser> logIn({required String email, required String password}) =>
      provider.logIn(email: email, password: password);

  @override
  Future<void> logOut() => provider.logOut();

  @override
  Future<void> sendEmailVerification() => provider.sendEmailVerification();

  @override
  Future<void> Initialize() => provider.Initialize();

  @override
  Future<void> reloadUser() => provider.reloadUser();
}
