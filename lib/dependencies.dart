// dependencies.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'repositories/account_repository.dart';
import 'repositories/catalog_repository.dart';
import 'services/user_service.dart';
import 'services/catalog_service.dart';
import 'views/my_home_page.dart';
import 'viewmodels/account_view_model.dart';
import 'viewmodels/catalog_view_model.dart';


/// Construit l'application avec toutes les dépendances injectées.
/// On peut fournir des instances mock pour les tests.
Widget buildApp({
  AuthService? authService,
  UserService? userService,
  CatalogService? catalogService,
}) {
  return MultiProvider(
    providers: [
      Provider<AuthService>(
        create: (context) => authService ?? AuthService(),
      ),
      Provider<UserService>(
        create: (context) => userService ?? UserService(),
      ),
      Provider<CatalogService>(
        create: (context) => catalogService ?? CatalogService(),
      ),
      Provider<AccountRepository>(
        create: (context) => AccountRepository(
          authService: context.read(),
          userService: context.read(),
        ),
      ),
      Provider<CatalogRepository>(
        create: (context) => CatalogRepository(
          catalogService: context.read(),
          ),
        ),
      ChangeNotifierProvider<AccountViewModel>(
        create: (context) => AccountViewModel(
          accountRepository: context.read(),
        ),
      ),
      ChangeNotifierProvider<CatalogViewModel>(
        create: (context) => CatalogViewModel(
          catalogRepository: context.read(),
        ),
      ),
    ],
    child: const MyApp(),
  );
}

/// Lance réellement l'application (appel à `runApp`).
void runWithDependencies() {
  runApp(buildApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Veggie Harvest',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.greenAccent),
      ),
      home: const MyHomePage(title: 'Mon panier maraîcher'),
    );
  }
}
