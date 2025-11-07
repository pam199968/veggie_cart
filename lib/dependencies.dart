// dependencies.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'repositories/delivery_method_repository.dart';
import 'services/delivery_method_service.dart';

import 'l10n/app_localizations.dart';

// 🔹 Services
import 'services/auth_service.dart';
import 'services/user_service.dart';
import 'services/catalog_service.dart';
import 'services/weekly_offers_service.dart';
import 'services/order_service.dart';

// 🔹 Repositories
import 'repositories/account_repository.dart';
import 'repositories/catalog_repository.dart';
import 'repositories/weekly_offers_repository.dart';
import 'repositories/order_repository.dart';

// 🔹 ViewModels
import 'viewmodels/account_view_model.dart';
import 'viewmodels/catalog_view_model.dart';
import 'viewmodels/customer_orders_view_model.dart';
import 'viewmodels/delivery_method_view_model.dart';
import 'viewmodels/weekly_offers_view_model.dart';
import 'viewmodels/my_orders_view_model.dart';
import 'viewmodels/cart_view_model.dart';

// 🔹 UI
import 'views/my_home_page.dart';

/// Construit l'application avec toutes les dépendances injectées.
Widget buildApp({
  AuthService? authService,
  UserService? userService,
  CatalogService? catalogService,
  WeeklyOffersService? weeklyOffersService,
  OrderService? orderService,
  DeliveryMethodService? deliveryMethodService,
}) {
  return MultiProvider(
    providers: [
      // ----------------------
      // 🧩 Services de base
      // ----------------------
      Provider<AuthService>(create: (_) => authService ?? AuthService()),
      Provider<UserService>(create: (_) => userService ?? UserService()),
      Provider<CatalogService>(
        create: (_) => catalogService ?? CatalogService(),
      ),
      Provider<WeeklyOffersService>(
        create: (_) => weeklyOffersService ?? WeeklyOffersService(),
      ),
      Provider<OrderService>(create: (_) => orderService ?? OrderService()),

      // ----------------------
      // 🧩 Repositories
      // ----------------------
      Provider<DeliveryMethodRepository>(
        create: (context) => DeliveryMethodRepository(),
      ),
      Provider<AccountRepository>(
        create: (context) => AccountRepository(
          authService: context.read<AuthService>(),
          userService: context.read<UserService>(),
        ),
      ),
      Provider<CatalogRepository>(
        create: (context) =>
            CatalogRepository(catalogService: context.read<CatalogService>()),
      ),
      Provider<WeeklyOffersRepository>(
        create: (context) => WeeklyOffersRepository(
          weeklyOffersService: context.read<WeeklyOffersService>(),
        ),
      ),
      Provider<OrderRepository>(
        create: (context) =>
            OrderRepository(service: context.read<OrderService>()),
      ),

      // ----------------------
      // 🧩 ViewModels (ChangeNotifier)
      // ----------------------
      ChangeNotifierProvider<AccountViewModel>(
        create: (context) => AccountViewModel(
          accountRepository: context.read<AccountRepository>(),
        ),
      ),
      ChangeNotifierProvider<CatalogViewModel>(
        create: (context) => CatalogViewModel(
          catalogRepository: context.read<CatalogRepository>(),
        ),
      ),
      ChangeNotifierProvider<WeeklyOffersViewModel>(
        create: (context) => WeeklyOffersViewModel(
          repository: context.read<WeeklyOffersRepository>(),
        ),
      ),
      ChangeNotifierProvider<OrderViewModel>(
        create: (context) => OrderViewModel(
          accountViewModel: context.read<AccountViewModel>(),
          repository: context.read<OrderRepository>(),
        ),
      ),
      ChangeNotifierProvider<CustomerOrdersViewModel>(
        create: (context) => CustomerOrdersViewModel(
          orderRepository: context.read<OrderRepository>(),
          userService: context.read<UserService>(),
        ),
      ),
      ChangeNotifierProvider<DeliveryMethodViewModel>(
        create: (context) => DeliveryMethodViewModel(
          deliveryMethodRepository: context.read<DeliveryMethodRepository>(),
        ),// 🔹 précharge automatiquement les méthodes
      ),

      ChangeNotifierProvider<CartViewModel>(
        create: (context) => CartViewModel(
          accountViewModel: context.read<AccountViewModel>(),
          weeklyOffersViewModel: context.read<WeeklyOffersViewModel>(),
          orderRepository: context.read<OrderRepository>(),
        ),
      ),
    ],
    child: const MyApp(),
  );
}

/// Lance réellement l'application
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
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('fr')],
      home: const MyHomePage(title: 'Mon panier maraîcher'),
    );
  }
}
