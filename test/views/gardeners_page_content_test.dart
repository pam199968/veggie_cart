// test/views/gardeners_page_content_test.dart
import 'dart:async';

import 'package:au_bio_jardin_app/l10n/app_localizations.dart';
import 'package:au_bio_jardin_app/models/delivery_method_config.dart';
import 'package:au_bio_jardin_app/models/profile.dart';
import 'package:au_bio_jardin_app/models/user_model.dart';
import 'package:au_bio_jardin_app/viewmodels/account_view_model.dart';
import 'package:au_bio_jardin_app/views/gardeners_page_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
        deliveryMethod: DeliveryMethodConfig(
          key: 'farmPickup',
          label: 'Retrait à la ferme',
          enabled: true,
        ),
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
          deliveryMethod: DeliveryMethodConfig(
            key: 'farmPickup',
            label: 'Retrait à la ferme',
            enabled: true,
          ),
          phoneNumber: '0111111111',
          address: '1 Rue du Jardin',
        ),
        UserModel(
          id: 'gardener-2',
          name: 'Martin',
          givenName: 'Pierre',
          email: 'pierre.martin@example.com',
          profile: Profile.customer,
          deliveryMethod: DeliveryMethodConfig(
            key: 'farmPickup',
            label: 'Retrait à la ferme',
            enabled: true,
          ),
          phoneNumber: '0222222222',
          address: '2 Rue du Potager',
        ),
        currentUser, // L'utilisateur connecté dans la liste
      ];

      // Configuration des comportements par défaut
      when(mockViewModel.currentUser).thenReturn(currentUser);
      when(
        mockViewModel.gardenersStream,
      ).thenAnswer((_) => Stream.value(mockGardeners));
    });

    Widget createTestWidget(MockAccountViewModel viewModel) {
      return MaterialApp(
        // Ajout de la configuration des localisations
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('fr', 'FR'),
          Locale('en', 'US'),
        ],
        locale: const Locale('fr', 'FR'),
        home: ChangeNotifierProvider<AccountViewModel>.value(
          value: viewModel,
          child: const GardenersPageContent(),
        ),
      );
    }

    group('UI Elements Tests', () {
      testWidgets('Affiche l\'AppBar avec le titre correct', (
        WidgetTester tester,
      ) async {
        // Act
        await tester.pumpWidget(createTestWidget(mockViewModel));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Liste des administrateurs'), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);
      });

      testWidgets('Affiche le bouton d\'ajout dans l\'AppBar', (
        WidgetTester tester,
      ) async {
        // Act
        await tester.pumpWidget(createTestWidget(mockViewModel));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byIcon(Icons.add), findsOneWidget);
        expect(find.byTooltip('Ajouter un administrateur'), findsOneWidget);
      });

      testWidgets('Affiche un message quand il n\'y a pas de d\'administrateur', (
        WidgetTester tester,
      ) async {
        // Arrange
        when(mockViewModel.gardenersStream).thenAnswer((_) => Stream.value([]));

        // Act
        await tester.pumpWidget(createTestWidget(mockViewModel));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Aucun administrateur trouvé'), findsOneWidget);
      });
    });

    group('ListView Tests', () {
      testWidgets('Affiche la liste des maraîchers', (
        WidgetTester tester,
      ) async {
        // Act
        await tester.pumpWidget(createTestWidget(mockViewModel));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(ListView), findsOneWidget);
        expect(find.byType(Card), findsNWidgets(mockGardeners.length));
        expect(find.byType(ListTile), findsNWidgets(mockGardeners.length));
      });

      testWidgets('Affiche les noms et emails des maraîchers', (
        WidgetTester tester,
      ) async {
        // Act
        await tester.pumpWidget(createTestWidget(mockViewModel));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Marie Dupont'), findsOneWidget);
        expect(find.text('marie.dupont@example.com'), findsOneWidget);
        expect(find.text('Pierre Martin'), findsOneWidget);
        expect(find.text('pierre.martin@example.com'), findsOneWidget);
      });

      testWidgets('Affiche le bouton de suppression pour chaque maraîcher (sauf l\'utilisateur connecté)', (
        WidgetTester tester,
      ) async {
        // Act
        await tester.pumpWidget(createTestWidget(mockViewModel));
        await tester.pumpAndSettle();

        // Assert - devrait y avoir 2 boutons delete (pas pour currentUser)
        expect(find.byIcon(Icons.delete), findsNWidgets(2));
      });

      testWidgets('L\'utilisateur connecté n\'a pas de bouton de suppression', (
        WidgetTester tester,
      ) async {
        // Act
        await tester.pumpWidget(createTestWidget(mockViewModel));
        await tester.pumpAndSettle();

        // Assert - le 3ème ListTile (currentUser) n'a pas de trailing IconButton
        final listTiles = tester.widgetList<ListTile>(find.byType(ListTile)).toList();
        final currentUserTile = listTiles[2];
        expect(currentUserTile.trailing, isNull);
      });

      testWidgets('Les autres ListTiles ont un bouton de suppression', (
        WidgetTester tester,
      ) async {
        // Act
        await tester.pumpWidget(createTestWidget(mockViewModel));
        await tester.pumpAndSettle();

        // Assert
        final listTiles = tester.widgetList<ListTile>(find.byType(ListTile)).toList();
        expect(listTiles[0].trailing, isA<IconButton>());
        expect(listTiles[1].trailing, isA<IconButton>());
      });
    });

    group('Toggle Gardener Status Tests', () {
      testWidgets(
        'Clic sur le bouton delete appelle toggleGardenerStatus avec false',
        (WidgetTester tester) async {
          // Arrange
          when(
            mockViewModel.toggleGardenerStatus(any, any, any),
          ).thenAnswer((_) async => {});

          // Act
          await tester.pumpWidget(createTestWidget(mockViewModel));
          await tester.pumpAndSettle();

          // Tap sur le premier bouton delete (Marie Dupont - gardener)
          final deleteButtons = find.byIcon(Icons.delete);
          await tester.tap(deleteButtons.first);
          await tester.pumpAndSettle();

          // Assert
          verify(
            mockViewModel.toggleGardenerStatus(
              any,
              argThat(predicate<UserModel>((user) => user.id == 'gardener-1')),
              false,
            ),
          ).called(1);
        },
      );

      testWidgets(
        'Clic sur le deuxième bouton delete appelle toggleGardenerStatus',
        (WidgetTester tester) async {
          // Arrange
          when(
            mockViewModel.toggleGardenerStatus(any, any, any),
          ).thenAnswer((_) async => {});

          // Act
          await tester.pumpWidget(createTestWidget(mockViewModel));
          await tester.pumpAndSettle();

          // Tap sur le deuxième bouton delete (Pierre Martin - customer)
          final deleteButtons = find.byIcon(Icons.delete);
          await tester.tap(deleteButtons.at(1));
          await tester.pumpAndSettle();

          // Assert
          verify(
            mockViewModel.toggleGardenerStatus(
              any,
              argThat(predicate<UserModel>((user) => user.id == 'gardener-2')),
              false,
            ),
          ).called(1);
        },
      );
    });

    group('Add Gardener Dialog Tests', () {
      testWidgets('Clic sur le bouton + ouvre le dialogue', (
        WidgetTester tester,
      ) async {
        // Act
        await tester.pumpWidget(createTestWidget(mockViewModel));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text('Ajouter un administrateur'), findsOneWidget);
      });

      testWidgets('Le dialogue contient un champ de recherche', (
        WidgetTester tester,
      ) async {
        // Act
        await tester.pumpWidget(createTestWidget(mockViewModel));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        // Assert
        expect(
          find.widgetWithText(TextField, 'Rechercher un utilisateur'),
          findsOneWidget,
        );
        expect(find.byIcon(Icons.search), findsAtLeastNWidgets(1));
      });

      testWidgets('Le dialogue affiche "Aucun résultat" par défaut', (
        WidgetTester tester,
      ) async {
        // Act
        await tester.pumpWidget(createTestWidget(mockViewModel));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Aucun résultat'), findsOneWidget);
      });

      testWidgets('Le dialogue a un bouton Annuler', (
        WidgetTester tester,
      ) async {
        // Act
        await tester.pumpWidget(createTestWidget(mockViewModel));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Annuler'), findsOneWidget);
      });

      testWidgets('Clic sur Annuler ferme le dialogue', (
        WidgetTester tester,
      ) async {
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

      testWidgets('Recherche d\'utilisateurs affiche les résultats', (
        WidgetTester tester,
      ) async {
        // Arrange
        final searchResults = [
          UserModel(
            id: 'search-1',
            name: 'Recherche',
            givenName: 'Test',
            email: 'test@example.com',
            profile: Profile.customer,
            deliveryMethod: DeliveryMethodConfig(
              key: 'farmPickup',
              label: 'Retrait à la ferme',
              enabled: true,
            ),
            phoneNumber: '0333333333',
            address: '3 Rue Test',
          ),
        ];
        when(
          mockViewModel.searchCustomers(any),
        ).thenAnswer((_) async => searchResults);

        // Act
        await tester.pumpWidget(createTestWidget(mockViewModel));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        // Saisir dans le champ de recherche
        await tester.enterText(
          find.widgetWithText(TextField, 'Rechercher un utilisateur'),
          'Test',
        );

        // Attendre le debounce (300ms) + un peu plus
        await tester.pumpAndSettle(const Duration(milliseconds: 400));

        // Assert
        expect(find.text('Test Recherche'), findsOneWidget);
        expect(find.text('test@example.com'), findsOneWidget);
      });

      testWidgets('Saisie vide ne déclenche pas de recherche', (
        WidgetTester tester,
      ) async {
        // Arrange
        when(mockViewModel.searchCustomers(any)).thenAnswer((_) async => []);

        // Act
        await tester.pumpWidget(createTestWidget(mockViewModel));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        // Saisir puis effacer
        final searchField = find.widgetWithText(
          TextField,
          'Rechercher un utilisateur',
        );
        await tester.enterText(searchField, 'Test');
        await tester.pumpAndSettle(const Duration(milliseconds: 400));

        await tester.enterText(searchField, '');
        await tester.pumpAndSettle(const Duration(milliseconds: 400));

        // Assert
        expect(find.text('Aucun résultat'), findsOneWidget);
      });

      testWidgets(
        'Clic sur un résultat appelle promoteToGardener et ferme le dialogue',
        (WidgetTester tester) async {
          // Arrange
          final searchResults = [
            UserModel(
              id: 'search-1',
              name: 'Recherche',
              givenName: 'Test',
              email: 'test@example.com',
              profile: Profile.customer,
              deliveryMethod: DeliveryMethodConfig(
                key: 'farmPickup',
                label: 'Retrait à la ferme',
                enabled: true,
              ),
              phoneNumber: '0333333333',
              address: '3 Rue Test',
            ),
          ];
          when(
            mockViewModel.searchCustomers(any),
          ).thenAnswer((_) async => searchResults);
          when(
            mockViewModel.promoteToGardener(any, any),
          ).thenAnswer((_) async => {});

          // Act
          await tester.pumpWidget(createTestWidget(mockViewModel));
          await tester.pumpAndSettle();

          await tester.tap(find.byIcon(Icons.add));
          await tester.pumpAndSettle();

          await tester.enterText(
            find.widgetWithText(TextField, 'Rechercher un utilisateur'),
            'Test',
          );
          await tester.pumpAndSettle(const Duration(milliseconds: 400));

          // Taper sur le résultat
          await tester.tap(find.text('Test Recherche'));
          await tester.pumpAndSettle();

          // Assert
          verify(
            mockViewModel.promoteToGardener(
              any,
              argThat(predicate<UserModel>((user) => user.id == 'search-1')),
            ),
          ).called(1);
          expect(find.byType(AlertDialog), findsNothing);
        },
      );
    });

    group('Stream Updates Tests', () {
      testWidgets(
        'La liste se met à jour quand le stream émet de nouvelles données',
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
              deliveryMethod: DeliveryMethodConfig(
                key: 'farmPickup',
                label: 'Retrait à la ferme',
                enabled: true,
              ),
              phoneNumber: '0444444444',
              address: '4 Rue Nouvelle',
            ),
          ];

          // Créer un StreamController pour contrôler les émissions
          final streamController = StreamController<List<UserModel>>();
          when(
            mockViewModel.gardenersStream,
          ).thenAnswer((_) => streamController.stream);

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
        },
      );
    });
  });
}