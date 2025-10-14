// dependencies.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'repositories/account_repository.dart';
import 'services/user_service.dart';
import 'views/my_home_page.dart';
import 'viewmodels/account_view_model.dart';

/// Construit l'application avec toutes les dépendances injectées.
/// On peut l'utiliser à la fois dans `main.dart` et dans les tests.
Widget buildApp() {
  return MultiProvider(
    providers: [
      Provider(create: (context) => AuthService()),
      Provider(create: (context) => UserService()),
      Provider(
        create: (context) => AccountRepository(
          authService: context.read(),
          userService: context.read(),
        ),
      ),
      ChangeNotifierProvider(
        create: (context) => AccountViewModel(
          accountRepository: context.read(),
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
