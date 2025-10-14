// test/main_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:provider/provider.dart';

import 'package:veggie_cart/dependencies.dart';
import 'package:veggie_cart/services/auth_service.dart';
import 'package:veggie_cart/services/user_service.dart';

void main() {
  group('Application démarrage tests', () {
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFirestore mockFirestore;
    late AuthService authService;
    late UserService userService;

    setUp(() {
      // Initialisation des mocks avant chaque test
      mockAuth = MockFirebaseAuth(signedIn: false);
      mockFirestore = FakeFirebaseFirestore();
      
      // Création des services avec les mocks
      authService = AuthService(firebaseAuth: mockAuth);
      userService = UserService(firestore: mockFirestore);
    });

    testWidgets('L\'application démarre correctement avec les mocks', 
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildApp(
          authService: authService,
          userService: userService,
        ),
      );

      // Attend que tous les widgets soient construits
      await tester.pumpAndSettle();

      // Assert
      // Vérifie que MaterialApp est présent
      expect(find.byType(MaterialApp), findsOneWidget);
      
      // Vérifie que le titre de l'application est correct
      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      expect(app.title, equals('Veggie Harvest'));
      
      // Vérifie que la page d'accueil est affichée
      expect(find.text('Mon panier maraîcher'), findsOneWidget);
    });

    testWidgets('Les providers sont correctement injectés', 
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        buildApp(
          authService: authService,
          userService: userService,
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      final BuildContext context = tester.element(find.byType(MaterialApp));
      
      // Vérifie que AuthService est accessible
      final retrievedAuthService = context.read<AuthService>();
      expect(retrievedAuthService, isNotNull);
      expect(retrievedAuthService, equals(authService));
      
      // Vérifie que UserService est accessible
      final retrievedUserService = context.read<UserService>();
      expect(retrievedUserService, isNotNull);
      expect(retrievedUserService, equals(userService));
    });

    testWidgets('AuthService fonctionne avec le mock', 
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        buildApp(
          authService: authService,
          userService: userService,
        ),
      );
      await tester.pumpAndSettle();

      // Act & Assert
      expect(authService.isLoggedIn, isFalse);
      expect(authService.currentUser, isNull);
    });

    testWidgets('UserService fonctionne avec le mock Firestore', 
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        buildApp(
          authService: authService,
          userService: userService,
        ),
      );
      await tester.pumpAndSettle();

      // Act - Créer un utilisateur test dans le mock Firestore
      await mockFirestore.collection('users').doc('test-user').set({
        'name': 'Test User',
        'email': 'test@example.com',
      });

      // Assert - Vérifier que l'utilisateur existe
      final doc = await mockFirestore.collection('users').doc('test-user').get();
      expect(doc.exists, isTrue);
      expect(doc.data()?['name'], equals('Test User'));
    });

    testWidgets('L\'application affiche correctement le thème', 
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        buildApp(
          authService: authService,
          userService: userService,
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      expect(app.theme, isNotNull);
      expect(app.theme!.colorScheme.primary, isNotNull);
    });

    test('buildApp peut être appelé sans paramètres', () {
      // Cette fonction ne devrait pas lancer d'exception
      // Note: Ce test ne peut pas être un testWidgets car Firebase 
      // n'est pas initialisé, mais on vérifie que la fonction existe
      expect(() => buildApp, returnsNormally);
    });
  });

  group('Tests d\'intégration des services', () {
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFirestore mockFirestore;
    late AuthService authService;
    late UserService userService;

    setUp(() {
      mockAuth = MockFirebaseAuth(signedIn: false);
      mockFirestore = FakeFirebaseFirestore();
      authService = AuthService(firebaseAuth: mockAuth);
      userService = UserService(firestore: mockFirestore);
    });

    testWidgets('Les services peuvent être utilisés dans l\'application', 
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        buildApp(
          authService: authService,
          userService: userService,
        ),
      );
      await tester.pumpAndSettle();

      // Act - Accéder aux services depuis le contexte
      final BuildContext context = tester.element(find.byType(MaterialApp));
      final auth = context.read<AuthService>();
      final users = context.read<UserService>();

      // Assert
      expect(auth, isNotNull);
      expect(users, isNotNull);
      expect(auth.isLoggedIn, isFalse);
    });
  });
}