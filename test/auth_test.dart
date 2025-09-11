import 'package:learn_flutter1/service/auth/auth_exception.dart';
import 'package:learn_flutter1/service/auth/auth_provider.dart';
import 'package:learn_flutter1/service/auth/auth_user.dart';
import 'package:test/test.dart ';

void main() {
  group('Mock Authentication', () {
    final provider = MockAuthProvider();
    test('Should not be initialized to begin with', () {
      expect(provider.isInitialize, false);
    });

    test('Cannot log out or read user if not initialized', () {
      expect(
        provider.logOut(),
        throwsA(const TypeMatcher<NotInitializedException>()),
      );
    });

    test('Should be able to be initialized', () async {
      await provider.Initialize();
      expect(provider.isInitialize, true);
    });

    test('User should be null after initialization', () {
      expect(provider.currentUser, null);
    });

    test(
      'Should be able to initialize in less than 2 seconds',
      () async {
        await provider.Initialize();
        expect(provider.isInitialize, true);
      },
      timeout: const Timeout(Duration(seconds: 2)),
    );

    test('Create user should delegate to login function', () async {
      final badEmailUser = provider.CreateUser(
        email: 'foo@bar.com',
        password: 'any-password',
      );
      expect(
        badEmailUser,
        throwsA(const TypeMatcher<InvalidCredentialAuthException>()),
      );
      final badPasswordUser = provider.CreateUser(
        email: 'foo@bar.com',
        password: 'foobar',
      );
      expect(
        badPasswordUser,
        throwsA(const TypeMatcher<InvalidCredentialAuthException>()),
      );
      final user = await provider.CreateUser(email: 'foo', password: 'bar');
      expect(provider.currentUser, user);
      expect(user.isEmailVerified, false);
    });

    test('Logged in user should be able to get verified', () {
      provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });

    test('Should be able to log out and log in again', () async {
      await provider.logOut();
      await provider.logIn(email: 'email', password: 'password');
      final user = provider.currentUser;
      expect(user, isNotNull);
    });
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  var _isInitialize = false;

  bool get isInitialize => _isInitialize;

  AuthUser? _user;

  @override
  Future<AuthUser> CreateUser({
    required String email,
    required String password,
  }) async {
    if (!isInitialize) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 1));
    return logIn(email: email, password: password);
  }

  @override
  Future<void> Initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialize = true;
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<AuthUser> logIn({required String email, required String password}) {
    if (!isInitialize) throw NotInitializedException();
    if (email == 'foo@bar.com') throw InvalidCredentialAuthException();
    if (password == 'foobar') throw InvalidCredentialAuthException();
    const user = AuthUser(isEmailVerified: false, email: 'foo@bar.com',);
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if (!isInitialize) throw NotInitializedException();
    if (_user == null) throw UserNotLoggedInAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> reloadUser() {
    // TODO: implement reloadUser
    throw UnimplementedError();
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialize) throw NotInitializedException();
    final user = _user;
    if (user == null) throw UserNotLoggedInAuthException();
    const newUser = AuthUser(isEmailVerified: true, email: 'foo@bar.com');
    _user = newUser;
  }
}
