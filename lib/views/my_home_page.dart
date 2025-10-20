import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:veggie_cart/views/offers_mngt_page_content.dart';
import '../models/profile.dart';
import '../viewmodels/account_view_model.dart';
import '../viewmodels/catalog_view_model.dart';
import 'profile_page.dart';
import 'login_content.dart';
import 'catalog_page_content.dart';
import 'orders_page_content.dart';
import 'offers_page_content.dart';
import 'client_orders_page_content.dart';
import 'gardeners_page_content.dart';
import 'package:veggie_cart/extensions/context_extension.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _currentPage = 'offres';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _attemptAutoLogin();
  }

  Future<void> _attemptAutoLogin() async {
    final accountVM = context.read<AccountViewModel>();
    await accountVM.tryAutoLogin();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeViewModel = context.watch<AccountViewModel>();
    final isAuthenticated = homeViewModel.isAuthenticated;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    Widget bodyContent;

    if (!isAuthenticated) {
      bodyContent = const LoginContent();
    } else {
      switch (_currentPage) {
        case 'weekly_offers':
          bodyContent = const OffersPageContent();
          break;
          case 'offers_management':
          bodyContent = const OffersMngtPageContent();
          break;
        case 'my_orders':
          bodyContent = const OrdersPageContent();
          break;
        case 'customer_orders':
          bodyContent = const ClientOrdersPageContent();
          break;
        case 'catalog':
          bodyContent = const CatalogPageContent();
          break;
        case 'gardeners':
          bodyContent = const GardenersPageContent();
          break;
        default:
          bodyContent = const LoginContent();
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.appTitle),
        backgroundColor: Colors.greenAccent,
        actions: [
          if (isAuthenticated) ...[
            IconButton(
              icon: const Icon(Icons.account_circle),
              tooltip: "Voir le profil",
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        ProfilePage(user: homeViewModel.currentUser),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: context.l10n.logoutTooltip,
              onPressed: () async {
                final vm = context.read<CatalogViewModel>();
                vm.cancelSubscriptions(); // <--- important
                await homeViewModel.signOut(context);
              },
            ),
          ],
        ],
      ),

      // ✅ Burger menu Drawer
      drawer: isAuthenticated
          ? Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  UserAccountsDrawerHeader(
                    accountName: Text(homeViewModel.currentUser.givenName),
                    accountEmail: Text(homeViewModel.currentUser.email),
                    currentAccountPicture: const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, color: Colors.green),
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.greenAccent,
                    ),
                  ),
                  if (homeViewModel.currentUser.profile == Profile.customer) ...[
                    ListTile(
                      leading: const Icon(Icons.local_offer),
                      title: const Text('Offres de la semaine'),
                      selected: _currentPage == 'weekly_offers',
                      onTap: () {
                        _navigateTo('weekly_offers');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.shopping_bag),
                      title: const Text('Mes commandes'),
                      selected: _currentPage == 'my_orders',
                      onTap: () {
                        _navigateTo('my_orders');
                      },
                    ),
                  ],
                  if (homeViewModel.currentUser.profile == Profile.gardener) ...[
                  ListTile(
                    leading: const Icon(Icons.local_offer),
                    title: const Text('Gestion des offres'),
                    selected: _currentPage == 'offers_management',
                    onTap: () {
                      _navigateTo('offers_management');
                    },
                  ),
                    ListTile(
                      leading: const Icon(Icons.receipt_long),
                      title: const Text('Commandes client'),
                      selected: _currentPage == 'clients_orders',
                      onTap: () {
                        _navigateTo('clients_orders');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.store),
                      title: const Text('Catalogue'),
                      selected: _currentPage == 'catalog',
                      onTap: () {
                        _navigateTo('catalog');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.manage_accounts),
                      title: const Text('Liste des administrateurs'),
                      selected: _currentPage == 'gardeners',
                      onTap: () {
                        _navigateTo('gardeners');
                      },
                    ),
                  ],
                ],
              ),
            )
          : null,

      body: Center(child: bodyContent),
    );
  }

  void _navigateTo(String page) {
    setState(() {
      _currentPage = page;
    });
    Navigator.pop(context); // Ferme le Drawer après la sélection
  }
}




