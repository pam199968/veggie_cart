import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/delivery_method.dart';
import '../models/user_model.dart';
import '../models/profile.dart';
import '../viewmodels/account_view_model.dart';
import 'profile_page.dart';
import 'login_content.dart';
import '../i18n/strings.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _currentPage = 'offres'; // 'offres', 'commandes', ou 'accueil'

  @override
  Widget build(BuildContext context) {
    final homeViewModel = context.watch<AccountViewModel>();
    final isAuthenticated = homeViewModel.isAuthenticated;

    Widget bodyContent;

    if (!isAuthenticated) {
        bodyContent = const LoginContent(); // ← Remplace les formulaires internes
    } else {
      // Affichage en fonction de _currentPage
      switch (_currentPage) {
        case 'offres':
          bodyContent = const OffersPageContent();
          break;
        case 'commandes':
          bodyContent = const OrdersPageContent();
          break;
         case 'commandes_client':
         bodyContent = const ClientOrdersPageContent();
         break;
         case 'catalogue':
         bodyContent = const CatalogPageContent(); 
         break;
        default:
          bodyContent = const OffersPageContent();
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.appTitle),
        backgroundColor: Colors.greenAccent,
        actions: [
          if (isAuthenticated) ...[
            PopupMenuButton<String>(
              onSelected: (value) {
                setState(() {
                  _currentPage = value; // Changer la page affichée
                });
              },
              itemBuilder: (context) => _buildMenuItems(homeViewModel.currentUser),
              icon: const Icon(Icons.menu),
            ),
            IconButton(
              icon: const Icon(Icons.account_circle),
              tooltip: "Voir le profil",
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ProfilePage(user: homeViewModel.currentUser)),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: Strings.logoutTooltip,
              onPressed: () async {
                await homeViewModel.signOut(context);
              },
            ),
          ],
        ],
      ),
      body: Center(child: bodyContent),
    );
  }

  List<PopupMenuEntry<String>> _buildMenuItems(UserModel user) {
    List<PopupMenuEntry<String>> items = [
      const PopupMenuItem(value: 'offres', child: Text('Offres de la semaine')),
      const PopupMenuItem(value: 'commandes', child: Text('Mes commandes')),
    ];

    // 🔹 Options visibles uniquement pour le profile gardener
    if (user.profile == Profile.gardener) {
      items.addAll([
        const PopupMenuItem(value: 'commandes_client', child: Text('Commandes client')),
        const PopupMenuItem(value: 'catalogue', child: Text('Catalogue')),
      ]);
    }

    return items;
  }
}



// 🔹 Pages fictives pour navigation
class OffersPageContent extends StatelessWidget {
  const OffersPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Liste des offres'));
  }
}

class OrdersPageContent extends StatelessWidget {
  const OrdersPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Mes commandes'));
  }
}

class ClientOrdersPageContent extends StatelessWidget {
  const ClientOrdersPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Liste des commandes'));
  }
}

class CatalogPageContent extends StatelessWidget {
  const CatalogPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Catalogue'));
  }
}
