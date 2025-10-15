// test/views/login_content_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:veggie_cart/views/login_content.dart';
import 'package:veggie_cart/viewmodels/account_view_model.dart';
import 'package:veggie_cart/models/delivery_method.dart';
import 'package:veggie_cart/models/user_model.dart';
import 'package:veggie_cart/i18n/strings.dart';

// Générera login_content_test.mocks.dart
@GenerateMocks([AccountViewModel])
import 'login_content_test.mocks.dart';

void main() {
  group('LoginContent Widget Tests', () {
    late MockAccountViewModel mockViewModel;

    setUp(() {
      mockViewModel = MockAccountViewModel();
      
      // Configuration des comportements par défaut
      when(mockViewModel.showSignUpForm).thenReturn(false);
      when(mockViewModel.showSignInForm).thenReturn(true);
      when(mockViewModel.currentUser).thenReturn(UserModel.empty());
      when(mockViewModel.password).thenReturn('');
      when(mockViewModel.confirmPassword).thenReturn('');
      when(mockViewModel.isEmailValid(any)).thenReturn(true);
      when(mockViewModel.isPasswordValid(any)).thenReturn(true);
    });

    Widget createTestWidget(MockAccountViewModel viewModel) {
      return MaterialApp(
        home: Scaffold(
          body: ChangeNotifierProvider<AccountViewModel>.value(
            value: viewModel,
            child: const LoginContent(),
          ),
        ),
      );
    }

    group('Sign In Form Tests', () {
      testWidgets('Affiche le formulaire de connexion par défaut', 
          (WidgetTester tester) async {
        // Arrange
        when(mockViewModel.showSignUpForm).thenReturn(false);

        // Act
        await tester.pumpWidget(createTestWidget(mockViewModel));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text(Strings.emailLabel), findsOneWidget);
        expect(find.text(Strings.passwordLabel), findsOneWidget);
        expect(find.text(Strings.signInButton), findsOneWidget);
        expect(find.text(Strings.createAccountLink), findsOneWidget);
        
        // Vérifie que les champs de création de compte ne sont pas visibles
        expect(find.text(Strings.nameLabel), findsNothing);
        expect(find.text(Strings.givenNameLabel), findsNothing);
      });

      testWidgets('Le logo est affiché', 
          (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(mockViewModel));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(Image), findsOneWidget);
      });

      testWidgets('Saisie de l\'email met à jour le viewModel', 
          (WidgetTester tester) async {
        // Arrange
        const testEmail = 'test@example.com';

        // Act
        await tester.pumpWidget(createTestWidget(mockViewModel));
        await tester.pumpAndSettle();

        final emailField = find.widgetWithText(TextField, Strings.emailLabel);
        await tester.enterText(emailField, testEmail);
        await tester.pumpAndSettle();

        // Assert
        verify(mockViewModel.currentUser = any).called(greaterThan(0));
      });

      testWidgets('Saisie du mot de passe met à jour le viewModel', 
          (WidgetTester tester) async {
        // Arrange
        const testPassword = 'password123';

        // Act
        await tester.pumpWidget(createTestWidget(mockViewModel));
        await tester.pumpAndSettle();

        final passwordField = find.widgetWithText(TextField, Strings.passwordLabel);
        await tester.enterText(passwordField, testPassword);
        await tester.pumpAndSettle();

        // Assert
        verify(mockViewModel.password = testPassword).called(1);
      });

      testWidgets('Le champ mot de passe est masqué', 
          (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(mockViewModel));
        await tester.pumpAndSettle();

        // Assert
        final passwordField = tester.widget<TextField>(
          find.widgetWithText(TextField, Strings.passwordLabel)
        );
        expect(passwordField.obscureText, isTrue);
      });

      testWidgets('Clic sur "Se connecter" appelle signIn', 
          (WidgetTester tester) async {
        // Arrange
        when(mockViewModel.signIn(any)).thenAnswer((_) async => {});

        // Act
        await tester.pumpWidget(createTestWidget(mockViewModel));
        await tester.pumpAndSettle();

        await tester.tap(find.text(Strings.signInButton));
        await tester.pumpAndSettle();

        // Assert
        verify(mockViewModel.signIn(any)).called(1);
      });

      testWidgets('Clic sur "Créer un compte" bascule vers le formulaire d\'inscription', 
          (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(mockViewModel));
        await tester.pumpAndSettle();

        await tester.tap(find.text(Strings.createAccountLink));
        await tester.pumpAndSettle();

        // Assert
        verify(mockViewModel.toggleSignUpForm()).called(1);
      });
    });

    group('Sign Up Form Tests', () {
      testWidgets('Affiche le formulaire de création de compte', 
          (WidgetTester tester) async {
        // Arrange
        when(mockViewModel.showSignUpForm).thenReturn(true);

        // Act
        await tester.pumpWidget(createTestWidget(mockViewModel));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text(Strings.nameLabel), findsOneWidget);
        expect(find.text(Strings.givenNameLabel), findsOneWidget);
        expect(find.text(Strings.emailLabel), findsOneWidget);
        expect(find.text(Strings.passwordLabel), findsOneWidget);
        expect(find.text(Strings.confirmPasswordLabel), findsOneWidget);
        expect(find.text(Strings.phoneLabel), findsOneWidget);
        expect(find.text(Strings.addressLabel), findsOneWidget);
        expect(find.text(Strings.createAccountButton), findsOneWidget);
        expect(find.text(Strings.cancelButton), findsOneWidget);
      });

      testWidgets('Affiche le hint du mot de passe', 
          (WidgetTester tester) async {
        // Arrange
        when(mockViewModel.showSignUpForm).thenReturn(true);

        // Act
        await tester.pumpWidget(createTestWidget(mockViewModel));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text(Strings.passwordHint), findsOneWidget);
      });

      testWidgets('Le dropdown de méthode de livraison est présent', 
          (WidgetTester tester) async {
        // Arrange
        when(mockViewModel.showSignUpForm).thenReturn(true);

        // Act
        await tester.pumpWidget(createTestWidget(mockViewModel));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(DeliveryMethodDropdown), findsOneWidget);
        expect(find.text(Strings.deliveryMethodLabel), findsOneWidget);
      });

      testWidgets('Le switch de notifications push est présent', 
          (WidgetTester tester) async {
        // Arrange
        when(mockViewModel.showSignUpForm).thenReturn(true);

        // Act
        await tester.pumpWidget(createTestWidget(mockViewModel));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(PushNotificationSwitch), findsOneWidget);
        expect(find.text(Strings.pushNotificationLabel), findsOneWidget);
      });

      testWidgets('Tous les champs peuvent être remplis', 
          (WidgetTester tester) async {
        // Arrange
        when(mockViewModel.showSignUpForm).thenReturn(true);

        // Act
        await tester.pumpWidget(createTestWidget(mockViewModel));
        await tester.pumpAndSettle();

        // Remplir tous les champs
        await tester.enterText(find.widgetWithText(TextField, Strings.nameLabel), 'Dupont');
        await tester.enterText(find.widgetWithText(TextField, Strings.givenNameLabel), 'Jean');
        await tester.enterText(find.widgetWithText(TextField, Strings.emailLabel), 'jean@example.com');
        
        final passwordFields = find.widgetWithText(TextField, Strings.passwordLabel);
        await tester.enterText(passwordFields, 'Password123!');
        
        await tester.enterText(find.widgetWithText(TextField, Strings.confirmPasswordLabel), 'Password123!');
        await tester.enterText(find.widgetWithText(TextField, Strings.phoneLabel), '0123456789');
        await tester.enterText(find.widgetWithText(TextField, Strings.addressLabel), '123 Rue de Test');
        
        await tester.pumpAndSettle();

        // Assert - Vérifie que les appels ont été faits
        verify(mockViewModel.currentUser = any).called(greaterThan(0));
      });

      testWidgets('Création de compte avec email invalide affiche une erreur', 
          (WidgetTester tester) async {
        // Arrange
        when(mockViewModel.showSignUpForm).thenReturn(true);
        when(mockViewModel.isEmailValid(any)).thenReturn(false);

        // Act
        await tester.pumpWidget(createTestWidget(mockViewModel));
        await tester.pumpAndSettle();
        // Trouver le bouton
        final createAccountButton = find.text(Strings.createAccountButton);
        // Récupérer l’élément BuildContext du widget
        final context = tester.element(createAccountButton);
        // Faire défiler jusqu’à ce que le widget soit visible
        await Scrollable.ensureVisible(context);
        await tester.tap(find.text(Strings.createAccountButton));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text(Strings.emailError), findsOneWidget);
        verifyNever(mockViewModel.signUp(any));
      });

      testWidgets('Création de compte avec mot de passe invalide affiche une erreur', 
          (WidgetTester tester) async {
        // Arrange
        when(mockViewModel.showSignUpForm).thenReturn(true);
        when(mockViewModel.isEmailValid(any)).thenReturn(true);
        when(mockViewModel.isPasswordValid(any)).thenReturn(false);

        // Act
        await tester.pumpWidget(createTestWidget(mockViewModel));
        await tester.pumpAndSettle();

        await tester.tap(find.text(Strings.createAccountButton));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text(Strings.passwordError), findsOneWidget);
        verifyNever(mockViewModel.signUp(any));
      });

      testWidgets('Création de compte avec mots de passe différents affiche une erreur', 
          (WidgetTester tester) async {
        // Arrange
        when(mockViewModel.showSignUpForm).thenReturn(true);
        when(mockViewModel.isEmailValid(any)).thenReturn(true);
        when(mockViewModel.isPasswordValid(any)).thenReturn(true);
        when(mockViewModel.password).thenReturn('Password123!');
        when(mockViewModel.confirmPassword).thenReturn('DifferentPassword');

        // Act
        await tester.pumpWidget(createTestWidget(mockViewModel));
        await tester.pumpAndSettle();
        // Trouver le bouton
        final createAccountButton = find.text(Strings.createAccountButton);
        // Récupérer l’élément BuildContext du widget
        final context = tester.element(createAccountButton);
        // Faire défiler jusqu’à ce que le widget soit visible
        await Scrollable.ensureVisible(context);
        await tester.tap(find.text(Strings.createAccountButton));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text(Strings.passwordMismatchError), findsOneWidget);
        verifyNever(mockViewModel.signUp(any));
      });

      testWidgets('Création de compte avec données valides appelle signUp', 
          (WidgetTester tester) async {
        // Arrange
        when(mockViewModel.showSignUpForm).thenReturn(true);
        when(mockViewModel.isEmailValid(any)).thenReturn(true);
        when(mockViewModel.isPasswordValid(any)).thenReturn(true);
        when(mockViewModel.password).thenReturn('Password123!');
        when(mockViewModel.confirmPassword).thenReturn('Password123!');
        when(mockViewModel.signUp(any)).thenAnswer((_) async => {});

        // Act
        await tester.pumpWidget(createTestWidget(mockViewModel));
        await tester.pumpAndSettle();
        // Trouver le bouton
        final createAccountButton = find.text(Strings.createAccountButton);
        // Récupérer l’élément BuildContext du widget
        final context = tester.element(createAccountButton);
        // Faire défiler jusqu’à ce que le widget soit visible
        await Scrollable.ensureVisible(context);
        await tester.tap(createAccountButton);
        await tester.pumpAndSettle();

        // Assert
        verify(mockViewModel.signUp(any)).called(1);
        verify(mockViewModel.toggleSignUpForm()).called(1);
      });

      testWidgets('Clic sur "Annuler" bascule vers le formulaire de connexion', 
          (WidgetTester tester) async {
        // Arrange
        when(mockViewModel.showSignUpForm).thenReturn(true);

        // Act
        await tester.pumpWidget(createTestWidget(mockViewModel));
        await tester.pumpAndSettle();
        // Trouver le bouton
        final cancelButton = find.text(Strings.cancelButton);
        // Récupérer l’élément BuildContext du widget
        final context = tester.element(cancelButton);
        // Faire défiler jusqu’à ce que le widget soit visible
        await Scrollable.ensureVisible(context);
        await tester.tap(cancelButton);
        await tester.pumpAndSettle();

        // Assert
        verify(mockViewModel.toggleSignUpForm()).called(1);
      });
    });

    group('DeliveryMethodDropdown Tests', () {
      testWidgets('Change la méthode de livraison', 
          (WidgetTester tester) async {
        // Arrange
        when(mockViewModel.showSignUpForm).thenReturn(true);

        // Act
        await tester.pumpWidget(createTestWidget(mockViewModel));
        await tester.pumpAndSettle();
        // Trouver le dropDown
        final dropDownFinder = find.byType(DropdownButtonFormField<DeliveryMethod>);
        // Récupérer l’élément BuildContext du widget
        final context = tester.element(dropDownFinder);
        // Faire défiler jusqu’à ce que le widget soit visible
        await Scrollable.ensureVisible(context);
        // Ouvrir le dropdown
        await tester.tap(dropDownFinder);
        await tester.pumpAndSettle();

        // Sélectionner une option (si plusieurs valeurs existent)
        if (DeliveryMethod.values.length > 1) {
          await tester.tap(find.text(DeliveryMethod.values[1].label).last);
          await tester.pumpAndSettle();

          // Assert
          verify(mockViewModel.currentUser = any).called(greaterThan(0));
        }
      });
    });

    group('PushNotificationSwitch Tests', () {
      testWidgets('Toggle le switch de notifications', (WidgetTester tester) async {
        // Arrange
        when(mockViewModel.showSignUpForm).thenReturn(true);

        // Act
        await tester.pumpWidget(createTestWidget(mockViewModel));
        await tester.pumpAndSettle();

        // Trouver le switch
        final switchFinder = find.byType(Switch);
        // Récupérer l’élément BuildContext du widget
        final context = tester.element(switchFinder);
        // 👇 FAIRE DÉFILER pour le rendre visible
        await Scrollable.ensureVisible(context);

        // Taper sur le switch
        await tester.tap(switchFinder);
        await tester.pumpAndSettle();

        // Assert
        verify(mockViewModel.currentUser = any).called(greaterThan(0));
      });

    });
  });
}