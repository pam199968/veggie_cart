// test/viewmodels/account_view_model_test.dart
import 'package:au_bio_jardin_app/models/delivery_method_config.dart';
import 'package:au_bio_jardin_app/models/profile.dart';
import 'package:au_bio_jardin_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:au_bio_jardin_app/viewmodels/account_view_model.dart';
import 'package:au_bio_jardin_app/repositories/account_repository.dart';
// Générera account_view_model_test.mocks.dart
@GenerateMocks([AccountRepository, FlutterSecureStorage])
import 'account_view_model_test.mocks.dart';

void main() {
  // Mock FlutterSecureStorage globalement
  FlutterSecureStorage.setMockInitialValues({});

  group('AccountViewModel Tests', () {
    late MockAccountRepository mockRepository;
    late AccountViewModel viewModel;
    late UserModel testUser;

    setUp(() {
      mockRepository = MockAccountRepository();
      viewModel = AccountViewModel(accountRepository: mockRepository);

      testUser = UserModel(
        id: 'user-123',
        name: 'Dupont',
        givenName: 'Marie',
        email: 'marie@example.com',
        phoneNumber: '0123456789',
        address: '123 Rue Test',
        deliveryMethod: DeliveryMethodConfig(
          key: "farmPickup",
          label: 'Retrait à la ferme',
          enabled: true,
          isDefault: false,
        ),
        pushNotifications: true,
        profile: Profile.customer,
        isActive: true,
      );
    });

    group('Initialization Tests', () {
      test('Initialise avec un utilisateur vide', () {
        expect(viewModel.currentUser.name, isEmpty);
        expect(viewModel.currentUser.email, isEmpty);
        expect(viewModel.currentUser.profile, Profile.customer);
        expect(viewModel.showSignInForm, isTrue);
        expect(viewModel.showSignUpForm, isFalse);
        expect(viewModel.isLoggedIn, isFalse);
      });

      test('Les mots de passe sont vides au démarrage', () {
        expect(viewModel.password, isEmpty);
        expect(viewModel.confirmPassword, isEmpty);
      });
    });

    group('Form Toggle Tests', () {
      test('toggleSignInForm bascule l\'état du formulaire de connexion', () {
        // Arrange
        final initialState = viewModel.showSignInForm;

        // Act
        viewModel.toggleSignInForm();

        // Assert
        expect(viewModel.showSignInForm, !initialState);
      });

      test('toggleSignInForm notifie les listeners', () {
        // Arrange
        var notified = false;
        viewModel.addListener(() => notified = true);

        // Act
        viewModel.toggleSignInForm();

        // Assert
        expect(notified, isTrue);
      });

      test('toggleSignUpForm bascule les deux formulaires', () {
        // Arrange
        viewModel.showSignUpForm = false;
        viewModel.showSignInForm = true;

        // Act
        viewModel.toggleSignUpForm();

        // Assert
        expect(viewModel.showSignUpForm, isTrue);
        expect(viewModel.showSignInForm, isFalse);
      });

      test('toggleSignUpForm notifie les listeners', () {
        // Arrange
        var notified = false;
        viewModel.addListener(() => notified = true);

        // Act
        viewModel.toggleSignUpForm();

        // Assert
        expect(notified, isTrue);
      });
    });

    group('Sign In Tests', () {
      testWidgets('signIn avec succès met à jour currentUser', (
        WidgetTester tester,
      ) async {
        // Arrange
        final context = await _createMockContext(tester);
        viewModel.currentUser = viewModel.currentUser.copyWith(
          email: 'marie@example.com',
        );
        viewModel.password = 'Password123';

        when(
          mockRepository.signInExistingAccount(
            context: anyNamed('context'),
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        ).thenAnswer((_) async => testUser);

        // Act
        await viewModel.signIn(context);

        // Assert
        expect(viewModel.currentUser.id, 'user-123');
        expect(viewModel.currentUser.email, 'marie@example.com');
        verify(
          mockRepository.signInExistingAccount(
            context: context,
            email: 'marie@example.com',
            password: 'Password123',
          ),
        ).called(1);
      });

      testWidgets('signIn échec ne met pas à jour currentUser', (
        WidgetTester tester,
      ) async {
        // Arrange
        final context = await _createMockContext(tester);
        viewModel.currentUser = viewModel.currentUser.copyWith(
          email: 'wrong@example.com',
        );

        when(
          mockRepository.signInExistingAccount(
            context: anyNamed('context'),
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        ).thenAnswer((_) async => null);

        // Act
        await viewModel.signIn(context);

        // Assert
        expect(viewModel.currentUser.id, isNull);
      });

      testWidgets('signIn notifie les listeners', (WidgetTester tester) async {
        // Arrange
        final context = await _createMockContext(tester);
        var notified = false;
        viewModel.addListener(() => notified = true);

        when(
          mockRepository.signInExistingAccount(
            context: anyNamed('context'),
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        ).thenAnswer((_) async => testUser);

        // Act
        await viewModel.signIn(context);

        // Assert
        expect(notified, isTrue);
      });
    });

    group('Sign Up Tests', () {
      testWidgets('signUp avec succès crée un utilisateur', (
        WidgetTester tester,
      ) async {
        // Arrange
        final context = await _createMockContext(tester);
        viewModel.currentUser = UserModel(
          name: 'Dupont',
          givenName: 'Marie',
          email: 'marie@example.com',
          phoneNumber: '0123456789',
          address: '123 Rue Test',
          deliveryMethod: DeliveryMethodConfig(
            key: "farmPickup",
            label: 'Retrait à la ferme',
            enabled: true,
            isDefault: false,
          ),
          pushNotifications: true,
          profile: Profile.customer,
        );
        viewModel.password = 'Password123';

        when(
          mockRepository.signUp(
            context: anyNamed('context'),
            user: anyNamed('user'),
            password: anyNamed('password'),
          ),
        ).thenAnswer((_) async => testUser);

        // Act
        await viewModel.signUp(context);

        // Assert
        expect(viewModel.currentUser.id, 'user-123');
        verify(
          mockRepository.signUp(
            context: context,
            user: anyNamed('user'),
            password: 'Password123',
          ),
        ).called(1);
      });

      testWidgets('signUp trim les données utilisateur', (
        WidgetTester tester,
      ) async {
        // Arrange
        final context = await _createMockContext(tester);
        viewModel.currentUser = UserModel(
          name: ' Dupont ',
          givenName: ' Marie ',
          email: ' marie@example.com ',
          phoneNumber: ' 0123456789 ',
          address: ' 123 Rue Test ',
          deliveryMethod: DeliveryMethodConfig(
            key: "farmPickup",
            label: 'Retrait à la ferme',
            enabled: true,
            isDefault: false,
          ),
          pushNotifications: true,
          profile: Profile.customer,
        );
        viewModel.password = ' Password123 ';

        when(
          mockRepository.signUp(
            context: anyNamed('context'),
            user: anyNamed('user'),
            password: anyNamed('password'),
          ),
        ).thenAnswer((_) async => testUser);

        // Act
        await viewModel.signUp(context);

        // Assert
        final captured = verify(
          mockRepository.signUp(
            context: context,
            user: captureAnyNamed('user'),
            password: captureAnyNamed('password'),
          ),
        ).captured;

        final capturedUser = captured[0] as UserModel;
        final capturedPassword = captured[1] as String;

        expect(capturedUser.name, 'Dupont');
        expect(capturedUser.givenName, 'Marie');
        expect(capturedUser.email, 'marie@example.com');
        expect(capturedPassword, 'Password123');
      });
    });

    group('Sign Out Tests', () {
      testWidgets('signOut efface les données et réinitialise l\'état', (
        WidgetTester tester,
      ) async {
        // Arrange
        final context = await _createMockContext(tester);
        viewModel.currentUser = testUser;
        viewModel.password = 'Password123';
        viewModel.showSignInForm = false;

        when(mockRepository.signOut(any)).thenAnswer((_) async => {});

        // Act
        await viewModel.signOut(context);

        // Assert
        expect(viewModel.currentUser.id, isNull);
        expect(viewModel.currentUser.email, isEmpty);
        expect(viewModel.password, isEmpty);
        expect(viewModel.showSignInForm, isTrue);
        expect(viewModel.showSignUpForm, isFalse);
        expect(viewModel.isLoggedIn, isFalse);
      });
    });

    group('Clear User Data Tests', () {
      test('clearUserData réinitialise l\'utilisateur', () {
        // Arrange
        viewModel.currentUser = testUser;
        viewModel.password = 'Password123';
        viewModel.confirmPassword = 'Password123';

        // Act
        viewModel.clearUserData();

        // Assert
        expect(viewModel.currentUser.id, isNull);
        expect(viewModel.currentUser.name, isEmpty);
        expect(viewModel.currentUser.email, isEmpty);
        expect(viewModel.password, isEmpty);
        expect(viewModel.confirmPassword, isEmpty);
      });
    });

    group('Authentication State Tests', () {
      test('isAuthenticated retourne true si l\'utilisateur a un id', () {
        // Arrange
        viewModel.currentUser = testUser;

        // Assert
        expect(viewModel.isAuthenticated, isTrue);
      });

      test(
        'isAuthenticated retourne false si l\'utilisateur n\'a pas d\'id',
        () {
          // Arrange
          viewModel.currentUser = UserModel(
            name: '',
            givenName: '',
            email: '',
            phoneNumber: '',
            address: '',
            deliveryMethod: DeliveryMethodConfig(
              key: "farmPickup",
              label: 'Retrait à la ferme',
              enabled: true,
              isDefault: false,
            ),
            pushNotifications: true,
            profile: Profile.customer,
          );

          // Assert
          expect(viewModel.isAuthenticated, isFalse);
        },
      );
    });

    group('Gardeners Stream Tests', () {
      test('gardenersStream retourne le stream du repository', () {
        // Arrange
        final mockStream = Stream<List<UserModel>>.value([testUser]);
        when(mockRepository.getGardenersStream()).thenAnswer((_) => mockStream);

        // Act
        final stream = viewModel.gardenersStream;

        // Assert
        expect(stream, mockStream);
        verify(mockRepository.getGardenersStream()).called(1);
      });
    });

    group('Customers Stream Tests', () {
      test('customersStream retourne le stream du repository', () {
        // Arrange
        final mockStream = Stream<List<UserModel>>.value([testUser]);
        when(mockRepository.getCustomersStream()).thenAnswer((_) => mockStream);

        // Act
        final stream = viewModel.customersStream;

        // Assert
        expect(stream, mockStream);
        verify(mockRepository.getCustomersStream()).called(1);
      });
    });

    group('Toggle Gardener Status Tests', () {
      testWidgets('toggleGardenerStatus met à jour le profil en gardener', (
        WidgetTester tester,
      ) async {
        // Arrange
        final context = await _createMockContext(tester);
        when(
          mockRepository.updateUserProfile(
            context: anyNamed('context'),
            user: anyNamed('user'),
          ),
        ).thenAnswer((_) async => true);

        // Act
        await viewModel.toggleGardenerStatus(context, testUser, true);

        // Assert
        final captured =
            verify(
                  mockRepository.updateUserProfile(
                    context: context,
                    user: captureAnyNamed('user'),
                  ),
                ).captured.single
                as UserModel;

        expect(captured.profile, Profile.gardener);
      });

      testWidgets('toggleGardenerStatus met à jour le profil en customer', (
        WidgetTester tester,
      ) async {
        // Arrange
        final context = await _createMockContext(tester);
        final gardenerUser = testUser.copyWith(profile: Profile.gardener);

        when(
          mockRepository.updateUserProfile(
            context: anyNamed('context'),
            user: anyNamed('user'),
          ),
        ).thenAnswer((_) async => true);

        // Act
        await viewModel.toggleGardenerStatus(context, gardenerUser, false);

        // Assert
        final captured =
            verify(
                  mockRepository.updateUserProfile(
                    context: context,
                    user: captureAnyNamed('user'),
                  ),
                ).captured.single
                as UserModel;

        expect(captured.profile, Profile.customer);
      });
    });

    group('Search Customers Tests', () {
      test('searchCustomers retourne les résultats du repository', () async {
        // Arrange
        final searchResults = [testUser];
        when(
          mockRepository.searchCustomersByName(any),
        ).thenAnswer((_) async => searchResults);

        // Act
        final results = await viewModel.searchCustomers('Marie');

        // Assert
        expect(results, searchResults);
        verify(mockRepository.searchCustomersByName('Marie')).called(1);
      });
    });

    group('Promote To Gardener Tests', () {
      testWidgets('promoteToGardener met à jour le profil', (
        WidgetTester tester,
      ) async {
        // Arrange
        final context = await _createMockContext(tester);
        when(
          mockRepository.updateUserProfile(
            context: anyNamed('context'),
            user: anyNamed('user'),
          ),
        ).thenAnswer((_) async => true);

        // Act
        await viewModel.promoteToGardener(context, testUser);

        // Assert
        final captured =
            verify(
                  mockRepository.updateUserProfile(
                    context: context,
                    user: captureAnyNamed('user'),
                  ),
                ).captured.single
                as UserModel;

        expect(captured.profile, Profile.gardener);
      });
    });

    group('Update User Profile Tests', () {
      testWidgets('updateUserProfile avec succès met à jour currentUser', (
        WidgetTester tester,
      ) async {
        // Arrange
        final context = await _createMockContext(tester);
        final updatedUser = testUser.copyWith(name: 'Nouveau Nom');

        when(
          mockRepository.updateUserProfile(
            context: anyNamed('context'),
            user: anyNamed('user'),
          ),
        ).thenAnswer((_) async => true);

        // Act
        final success = await viewModel.updateUserProfile(context, updatedUser);

        // Assert
        expect(success, isTrue);
        expect(viewModel.currentUser.name, 'Nouveau Nom');
      });

      testWidgets('updateUserProfile échec ne met pas à jour currentUser', (
        WidgetTester tester,
      ) async {
        // Arrange
        final context = await _createMockContext(tester);
        final updatedUser = testUser.copyWith(name: 'Nouveau Nom');
        viewModel.currentUser = testUser;

        when(
          mockRepository.updateUserProfile(
            context: anyNamed('context'),
            user: anyNamed('user'),
          ),
        ).thenAnswer((_) async => false);

        // Act
        final success = await viewModel.updateUserProfile(context, updatedUser);

        // Assert
        expect(success, isFalse);
        expect(viewModel.currentUser.name, 'Dupont'); // Inchangé
      });
    });

    group('Account Enable/Disable Tests', () {
      testWidgets('disableCustomerAccount désactive un compte', (
        WidgetTester tester,
      ) async {
        // Arrange
        final context = await _createMockContext(tester);
        when(
          mockRepository.disableUserAccount(any, any),
        ).thenAnswer((_) async => {});

        // Act
        await viewModel.disableCustomerAccount(context, testUser);

        // Assert
        verify(mockRepository.disableUserAccount(context, testUser)).called(1);
      });

      testWidgets('enableCustomerAccount réactive un compte', (
        WidgetTester tester,
      ) async {
        // Arrange
        final context = await _createMockContext(tester);
        when(
          mockRepository.enableUserAccount(any, any),
        ).thenAnswer((_) async => {});

        // Act
        await viewModel.enableCustomerAccount(context, testUser);

        // Assert
        verify(mockRepository.enableUserAccount(context, testUser)).called(1);
      });
    });

    group('Validation Tests', () {
      test('isPasswordValid retourne true pour un mot de passe valide', () {
        // Act & Assert
        expect(viewModel.isPasswordValid('Password123'), isTrue);
        expect(viewModel.isPasswordValid('MyPass1234'), isTrue);
      });

      test('isPasswordValid retourne false pour un mot de passe invalide', () {
        // Act & Assert
        expect(
          viewModel.isPasswordValid('password'),
          isFalse,
        ); // Pas de majuscule
        expect(
          viewModel.isPasswordValid('PASSWORD'),
          isFalse,
        ); // Pas de chiffre
        expect(viewModel.isPasswordValid('Pass1'), isFalse); // Trop court
        expect(viewModel.isPasswordValid(''), isFalse);
      });

      test('isEmailValid retourne true pour un email valide', () {
        // Act & Assert
        expect(viewModel.isEmailValid('test@example.com'), isTrue);
        expect(viewModel.isEmailValid('user.name@domain.co.uk'), isTrue);
      });

      test('isEmailValid retourne false pour un email invalide', () {
        // Act & Assert
        expect(viewModel.isEmailValid('invalidemail'), isFalse);
        expect(viewModel.isEmailValid('@example.com'), isFalse);
        expect(viewModel.isEmailValid('test@'), isFalse);
        expect(viewModel.isEmailValid(''), isFalse);
      });
    });
  });
}

// Helper pour créer un BuildContext mock dans les tests
Future<BuildContext> _createMockContext(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: Builder(builder: (context) => Container())),
    ),
  );
  return tester.element(find.byType(Container));
}
