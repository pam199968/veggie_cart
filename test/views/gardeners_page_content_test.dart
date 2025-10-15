// test/views/gardeners_page_content_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'dart:async';

import 'package:veggie_cart/views/gardeners_page_content.dart';
import 'package:veggie_cart/viewmodels/account_view_model.dart';
import 'package:veggie_cart/models/user_model.dart';
import 'package:veggie_cart/models/profile.dart';

// Générera gardeners_page_content_test.mocks.dart
@GenerateMocks([AccountViewModel])
import 'gardeners_page_content_test.mocks.dart';

void main() {
  group('GardenersPageContent Widget Tests', () {
    late MockAccountViewModel mockViewModel;
    late List<UserModel> mockGardeners;
    late UserModel currentUser;

    setUp(() {
      mockViewModel = MockAccountViewModel();
      
      // Utilisateur connecté
      currentUser = UserModel(
        id: 'current-user-id',
        name: 'Utilisateur',
        givenName: 'Courant',
        email: 'current@example.com',
        profile: Profile.gardener,
        phoneNumber: '0123456789',
        address: '123 Rue Test',
      );

      // Liste de maraîchers test
      mockGardeners = [
        UserModel(
          id: 'gardener-1',
          name: 'Dupont',
          givenName: 'Marie',
          email: 'marie.dupont@example.com',
          profile: Profile.gardener,
          phoneNumber: '0111111111',
          address: '1 Rue du Jardin',
        ),
        UserModel(
          id: 'gardener-2',
          name: 'Martin',
          givenName: 'Pierre',
          email: 'pierre.martin@example.com',
          profile: Profile.customer,
          phoneNumber: '0222222222',
          address: '2 Rue du Potager',
        ),
        currentUser, // L'utilisateur connecté dans la liste
      ];

      // Configuration des comportements par défaut
      when(mockViewModel.currentUser).thenReturn(currentUser);
      when(mockViewModel.gardenersStream).thenAnswer(
        (_) => Stream.value(mockGardeners),
      );
    });

    Widget createTestWidget(MockAccountViewModel viewModel) {
      return MaterialApp(
        home: ChangeNotifierProvider<AccountViewModel>.value(
          value: viewModel,
          child: const GardenersPageContent(),
        ),
      );
    }

    group('UI Elements Tests', () {
      testWidgets('Affiche l\'AppBar avec le titre correct', 
          (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(mockViewModel));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Liste des maraîchers'), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);
      });

      testWidgets('Affiche le bouton d\'ajout dans l\'AppBar', 
          (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(mockViewModel));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byIcon(Icons.add), findsOneWidget);
        expect(find.byTooltip('Ajouter un maraîcher'), findsOneWidget);
      });

      testWidgets('Affiche un message quand il n\'y a pas de maraîchers', 
          (WidgetTester tester) async {
        // Arrange
        when(mockViewModel.gardenersStream).thenAnswer(
          (_) => Stream.value([]),
        );

        // Act
        await tester.pumpWidget(createTestWidget(mockViewModel));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Aucun maraîcher trouvé.'), findsOneWidget);
      });
    });

    group('ListView Tests', () {
      testWidgets('Affiche la liste des maraîchers', 
          (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(mockViewModel));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(ListView), findsOneWidget);
        expect(find.byType(Card), findsNWidgets(mockGardeners.length));
        expect(find.byType(ListTile), findsNWidgets(mockGardeners.length));
      });

      testWidgets('Affiche les noms et emails des maraîchers', 
          (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(mockViewModel));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Marie Dupont'), findsOneWidget);
        expect(find.text('marie.dupont@example.com'), findsOneWidget);
        expect(find.text('Pierre Martin'), findsOneWidget);
        expect(find.text('pierre.martin@example.com'), findsOneWidget);
      });

      testWidgets('Affiche les checkboxes pour chaque maraîcher', 
          (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(mockViewModel));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(Checkbox), findsNWidgets(mockGardeners.length));
      });

      testWidgets('La checkbox est cochée pour un maraîcher', 
          (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(mockViewModel));
        await tester.pumpAndSettle();

        // Assert
        final checkboxes = tester.widgetList<Checkbox>(find.byType(Checkbox));
        final gardenerCheckbox = checkboxes.first;
        expect(gardenerCheckbox.value, isTrue); // gardener-1 a profile.gardener
      });

      testWidgets('La checkbox n\'est pas cochée pour un non-maraîcher', 
          (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(mockViewModel));
        await tester.pumpAndSettle();

        // Assert
        final checkboxes = tester.widgetList<Checkbox>(find.byType(Checkbox)).toList();
        final customerCheckbox = checkboxes[1];
        expect(customerCheckbox.value, isFalse); // gardener-2 a profile.customer
      });

      testWidgets('La checkbox de l\'utilisateur connecté est désactivée', 
          (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(mockViewModel));
        await tester.pumpAndSettle();

        // Assert
        final checkboxes = tester.widgetList<Checkbox>(find.byType(Checkbox)).toList();
        final currentUserCheckbox = checkboxes[2]; // Le 3ème est l'utilisateur connecté
        expect(currentUserCheckbox.onChanged, isNull); // Désactivée
      });

      testWidgets('Les autres checkboxes sont activées', 
          (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(mockViewModel));
        await tester.pumpAndSettle();

        // Assert
        final checkboxes = tester.widgetList<Checkbox>(find.byType(Checkbox)).toList();
        expect(checkboxes[0].onChanged, isNotNull); // gardener-1
        expect(checkboxes[1].onChanged, isNotNull); // gardener-2
      });
    });

    group('Toggle Gardener Status Tests', () {
      testWidgets('Cocher une checkbox appelle toggleGardenerStatus avec true', 
          (WidgetTester tester) async {
        // Arrange
        when(mockViewModel.toggleGardenerStatus(any, any, any))
            .thenAnswer((_) async => {});

        // Act
        await tester.pumpWidget(createTestWidget(mockViewModel));
        await tester.pumpAndSettle();

        // Tap sur la deuxième checkbox (Pierre Martin - customer)
        final checkboxes = find.byType(Checkbox);
        await tester.tap(checkboxes.at(1));
        await tester.pumpAndSettle();

        // Assert
        verify(mockViewModel.toggleGardenerStatus(
          any,
          argThat(predicate<UserModel>((user) => user.id == 'gardener-2')),
          true,
        )).called(1);
      });

      testWidgets('Décocher une checkbox appelle toggleGardenerStatus avec false', 
          (WidgetTester tester) async {
        // Arrange
        when(mockViewModel.toggleGardenerStatus(any, any, any))
            .thenAnswer((_) async => {});

        // Act
        await tester.pumpWidget(createTestWidget(mockViewModel));
        await tester.pumpAndSettle();

        // Tap sur la première checkbox (Marie Dupont - gardener)
        final checkboxes = find.byType(Checkbox);
        await tester.tap(checkboxes.first);
        await tester.pumpAndSettle();

        // Assert
        verify(mockViewModel.toggleGardenerStatus(
          any,
          argThat(predicate<UserModel>((user) => user.id == 'gardener-1')),
          false,
        )).called(1);
      });

      testWidgets('Taper sur la checkbox de l\'utilisateur connecté ne fait rien', 
          (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(mockViewModel));
        await tester.pumpAndSettle();

        // Tap sur la checkbox de l'utilisateur connecté (3ème)
        final checkboxes = find.byType(Checkbox);
        await tester.tap(checkboxes.at(2));
        await tester.pumpAndSettle();

        // Assert
        verifyNever(mockViewModel.toggleGardenerStatus(any, any, any));
      });
    });

    group('Add Gardener Dialog Tests', () {
      testWidgets('Clic sur le bouton + ouvre le dialogue', 
          (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(mockViewModel));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text('Ajouter un maraîcher'), findsOneWidget);
      });

      testWidgets('Le dialogue contient un champ de recherche', 
          (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(mockViewModel));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        // Assert
        expect(find.widgetWithText(TextField, 'Rechercher un utilisateur'), findsOneWidget);
        expect(find.byIcon(Icons.search), findsOneWidget);
      });

      testWidgets('Le dialogue affiche "Aucun résultat" par défaut', 
          (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(mockViewModel));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Aucun résultat'), findsOneWidget);
      });

      testWidgets('Le dialogue a un bouton Annuler', 
          (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(mockViewModel));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Annuler'), findsOneWidget);
      });

      testWidgets('Clic sur Annuler ferme le dialogue', 
          (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(mockViewModel));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Annuler'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(AlertDialog), findsNothing);
      });

      testWidgets('Recherche d\'utilisateurs affiche les résultats', 
          (WidgetTester tester) async {
        // Arrange
        final searchResults = [
          UserModel(
            id: 'search-1',
            name: 'Recherche',
            givenName: 'Test',
            email: 'test@example.com',
            profile: Profile.customer,
            phoneNumber: '0333333333',
            address: '3 Rue Test',
          ),
        ];
        when(mockViewModel.searchCustomers(any))
            .thenAnswer((_) async => searchResults);

        // Act
        await tester.pumpWidget(createTestWidget(mockViewModel));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        // Saisir dans le champ de recherche
        await tester.enterText(
          find.widgetWithText(TextField, 'Rechercher un utilisateur'),
          'Test'
        );
        
        // Attendre le debounce (300ms) + un peu plus
        await tester.pumpAndSettle(const Duration(milliseconds: 400));

        // Assert
        expect(find.text('Test Recherche'), findsOneWidget);
        expect(find.text('test@example.com'), findsOneWidget);
      });

      testWidgets('Saisie vide ne déclenche pas de recherche', 
          (WidgetTester tester) async {
        // Arrange
        when(mockViewModel.searchCustomers(any))
            .thenAnswer((_) async => []);

        // Act
        await tester.pumpWidget(createTestWidget(mockViewModel));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        // Saisir puis effacer
        final searchField = find.widgetWithText(TextField, 'Rechercher un utilisateur');
        await tester.enterText(searchField, 'Test');
        await tester.pumpAndSettle(const Duration(milliseconds: 400));
        
        await tester.enterText(searchField, '');
        await tester.pumpAndSettle(const Duration(milliseconds: 400));

        // Assert
        expect(find.text('Aucun résultat'), findsOneWidget);
      });

      testWidgets('Clic sur un résultat appelle promoteToGardener et ferme le dialogue', 
          (WidgetTester tester) async {
        // Arrange
        final searchResults = [
          UserModel(
            id: 'search-1',
            name: 'Recherche',
            givenName: 'Test',
            email: 'test@example.com',
            profile: Profile.customer,
            phoneNumber: '0333333333',
            address: '3 Rue Test',
          ),
        ];
        when(mockViewModel.searchCustomers(any))
            .thenAnswer((_) async => searchResults);
        when(mockViewModel.promoteToGardener(any, any))
            .thenAnswer((_) async => {});

        // Act
        await tester.pumpWidget(createTestWidget(mockViewModel));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(TextField, 'Rechercher un utilisateur'),
          'Test'
        );
        await tester.pumpAndSettle(const Duration(milliseconds: 400));

        // Taper sur le résultat
        await tester.tap(find.text('Test Recherche'));
        await tester.pumpAndSettle();

        // Assert
        verify(mockViewModel.promoteToGardener(
          any,
          argThat(predicate<UserModel>((user) => user.id == 'search-1')),
        )).called(1);
        expect(find.byType(AlertDialog), findsNothing);
      });
    });

    group('Stream Updates Tests', () {
      testWidgets('La liste se met à jour quand le stream émet de nouvelles données', 
          (WidgetTester tester) async {
        // Arrange
        final newGardeners = [
          ...mockGardeners,
          UserModel(
            id: 'new-gardener',
            name: 'Nouveau',
            givenName: 'Maraîcher',
            email: 'nouveau@example.com',
            profile: Profile.gardener,
            phoneNumber: '0444444444',
            address: '4 Rue Nouvelle',
          ),
        ];

        // Créer un StreamController pour contrôler les émissions
        final streamController = StreamController<List<UserModel>>();
        when(mockViewModel.gardenersStream).thenAnswer(
          (_) => streamController.stream,
        );

        // Act
        await tester.pumpWidget(createTestWidget(mockViewModel));
        
        // Émettre les données initiales
        streamController.add(mockGardeners);
        await tester.pumpAndSettle();

        // Vérifier l'état initial
        expect(find.byType(Card), findsNWidgets(mockGardeners.length));

        // Émettre les nouvelles données
        streamController.add(newGardeners);
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(Card), findsNWidgets(newGardeners.length));
        expect(find.text('Maraîcher Nouveau'), findsOneWidget);

        // Cleanup
        await streamController.close();
      });
    });
  });
}