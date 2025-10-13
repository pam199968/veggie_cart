import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:mockito/mockito.dart';
import 'package:veggie_cart/repositories/account_repository.dart';
import 'package:veggie_cart/services/auth_service.dart';
import 'package:veggie_cart/services/user_service.dart';

class MockAuthService extends Mock implements AuthService {}
class MockUserService extends Mock implements UserService {}

void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockAuthService mockAuthService;
  late MockUserService mockUserService;
  late AccountRepository repository;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth(signedIn: true);
    mockAuthService = MockAuthService();
    mockUserService = MockUserService();

    repository = AccountRepository(
      authService: mockAuthService,
      userService: mockUserService,
      firebaseAuth: mockFirebaseAuth,
    );
  });

  test('le flux authStateChanges renvoie un utilisateur mocké', () async {
    final user = await repository.authStateChanges.first;
    
  });
}
