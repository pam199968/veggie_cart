import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:veggie_cart/views/offers_mngt_page_content.dart';
import '../models/profile.dart';
import '../viewmodels/account_view_model.dart';
import '../viewmodels/catalog_view_model.dart';
import '../viewmodels/my_orders_view_model.dart';
import 'profile_page.dart';
import 'login_content.dart';
import 'catalog_page_content.dart';
import 'my_orders_page_content.dart';
import 'offers_page_content.dart';
import 'customer_orders_page_content.dart';
import 'gardeners_page_content.dart';
import 'package:veggie_cart/extensions/context_extension.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _currentPage = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _attemptAutoLogin();
  }

  Future<void> _attemptAutoLogin() async {
    final accountVM = context.read<AccountViewModel>();
    await accountVM.tryAutoLogin();

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _setInitialPage(accountVM.currentUser?.profile);
    });
  }

  void _setInitialPage(Profile? profile) {
    if (profile == Profile.customer) {
      _currentPage = 'weekly_offers';
    } else if (profile == Profile.gardener) {
      _currentPage = 'customer_orders';
    } else {
      _currentPage = '';
    }
  }

  void _navigateTo(String page) {
    setState(() {
      _currentPage = page;
    });
    Navigator.pop(context); // ferme le drawer
  }

  @override
  Widget build(BuildContext context) {
    final accountVM = context.watch<AccountViewModel>();
    final isAuthenticated = accountVM.isAuthenticated;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    Widget bodyContent;

    if (!isAuthenticated) {
      bodyContent = LoginContent(
        onLoginSuccess: () {
          setState(() {
            _setInitialPage(accountVM.currentUser.profile);
          });
        },
      );
    } else {
      switch (_currentPage) {
        case 'weekly_offers':
          bodyContent = const OffersPageContent();
          break;
        case 'offers_management':
          bodyContent = const OffersMngtPageContent();
          break;
        case 'my_orders':
          bodyContent = const MyOrdersPageContent();
          break;
        case 'customer_orders':
          bodyContent = const CustomerOrdersPageContent();
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
                    builder: (_) => ProfilePage(user: accountVM.currentUser),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: context.l10n.logoutTooltip,
              onPressed: () async {
                final catalogVM = context.read<CatalogViewModel>();
                catalogVM.cancelSubscriptions();

                final orderVM = context.read<OrderViewModel>();
                orderVM.cancelSubscriptions();

                await accountVM.signOut(context);

                setState(() {
                  _currentPage = '';
                });
              },
            ),
          ],
        ],
      ),
      drawer: isAuthenticated
          ? Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  UserAccountsDrawerHeader(
                    accountName: Text(accountVM.currentUser.givenName),
                    accountEmail: Text(accountVM.currentUser.email),
                    currentAccountPicture: const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, color: Colors.green),
                    ),
                    decoration: const BoxDecoration(color: Colors.greenAccent),
                  ),
                  if (accountVM.currentUser.profile == Profile.customer) ...[
                    ListTile(
                      leading: const Icon(Icons.local_offer),
                      title: const Text('Offres de la semaine'),
                      selected: _currentPage == 'weekly_offers',
                      onTap: () => _navigateTo('weekly_offers'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.shopping_bag),
                      title: const Text('Mes commandes'),
                      selected: _currentPage == 'my_orders',
                      onTap: () => _navigateTo('my_orders'),
                    ),
                  ],
                  if (accountVM.currentUser.profile == Profile.gardener) ...[
                    ListTile(
                      leading: const Icon(Icons.local_offer),
                      title: const Text('Gestion des offres'),
                      selected: _currentPage == 'offers_management',
                      onTap: () => _navigateTo('offers_management'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.receipt_long),
                      title: const Text('Commandes client'),
                      selected: _currentPage == 'customer_orders',
                      onTap: () => _navigateTo('customer_orders'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.store),
                      title: const Text('Catalogue'),
                      selected: _currentPage == 'catalog',
                      onTap: () => _navigateTo('catalog'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.manage_accounts),
                      title: const Text('Liste des administrateurs'),
                      selected: _currentPage == 'gardeners',
                      onTap: () => _navigateTo('gardeners'),
                    ),
                  ],
                ],
              ),
            )
          : null,
      body: Center(child: bodyContent),
    );
  }
}
