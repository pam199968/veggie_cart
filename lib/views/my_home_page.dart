import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/delivery_method.dart';
import '../models/user_model.dart';
import '../models/profile.dart';
import '../viewmodels/account_view_model.dart';
import 'profile_page.dart';
import '../i18n/strings.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _currentPage = 'offres'; // 'offres', 'commandes', ou 'accueil'

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _givenNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  DeliveryMethod _selectedDeliveryMethod = DeliveryMethod.farmPickup;
  bool _pushNotifications = true;

  @override
  void dispose() {
    _nameController.dispose();
    _givenNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void clearControllers() {
    _nameController.clear();
    _givenNameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _phoneController.clear();
    _addressController.clear();
  }


  @override
  Widget build(BuildContext context) {
    final homeViewModel = context.watch<AccountViewModel>();
    final isAuthenticated = homeViewModel.isAuthenticated;

    Widget bodyContent;

    if (!isAuthenticated) {
      bodyContent = homeViewModel.showSignUpForm
          ? _buildSignUpForm(context, homeViewModel)
          : _buildSignInForm(context, homeViewModel);
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
                clearControllers();
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


Widget _buildUserInfo(UserModel user) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Icon(Icons.account_circle, size: 100, color: Colors.green),
      const SizedBox(height: 20),
      Text("${Strings.connectedAs} ${user.name} ${user.givenName}",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      Text("Email : ${user.email}"),
      Text("Téléphone : ${user.phoneNumber}"),
      Text("Adresse : ${user.address}"),
      Text("Méthode de livraison : ${user.deliveryMethod.label}"),
      Text("Notifications : ${user.pushNotifications ? "Oui" : "Non"}"),
      const SizedBox(height: 20),
    ],
  );
}

  // 🔹 FORMULAIRE INSCRIPTION
  Widget _buildSignUpForm(BuildContext context, AccountViewModel homeViewModel) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('img/logo.jpeg', height: 100, width: 100),
        const SizedBox(height: 20),

        _buildTextField(_nameController, Strings.nameLabel, (v) {
          homeViewModel.currentUser = homeViewModel.currentUser.copyWith(name: v.trim());
        }),
        _buildTextField(_givenNameController, Strings.givenNameLabel, (v) {
          homeViewModel.currentUser = homeViewModel.currentUser.copyWith(givenName: v.trim());
        }),
        _buildTextField(_emailController, Strings.emailLabel, (v) {
          homeViewModel.currentUser = homeViewModel.currentUser.copyWith(email: v.trim());
        }),
        _buildPasswordField(_passwordController, Strings.passwordLabel, (v) {
          homeViewModel.password = v.trim();
        }),
        const SizedBox(height: 5),
        const SizedBox(
          width: 300,
          child: Text(
            Strings.passwordHint,
            style: TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.start,
          ),
        ),
        const SizedBox(height: 10),
        _buildPasswordField(_confirmPasswordController, Strings.confirmPasswordLabel, (v) {
          homeViewModel.confirmPassword = v.trim();
        }),
        _buildTextField(_phoneController, Strings.phoneLabel, (v) {
          homeViewModel.currentUser = homeViewModel.currentUser.copyWith(phoneNumber: v.trim());
        }),
        _buildTextField(_addressController, Strings.addressLabel, (v) {
          homeViewModel.currentUser = homeViewModel.currentUser.copyWith(address: v.trim());
        }, maxLines: 4),
        const SizedBox(height: 10),

        DeliveryMethodDropdown(
          notifier: ValueNotifier<DeliveryMethod>(_selectedDeliveryMethod),
          onChanged: (v) {
            _selectedDeliveryMethod = v;
            homeViewModel.currentUser = homeViewModel.currentUser.copyWith(deliveryMethod: v);
          },
        ),
        PushNotificationSwitch(
          notifier: ValueNotifier<bool>(_pushNotifications),
          onChanged: (v) {
            _pushNotifications = v;
            homeViewModel.currentUser = homeViewModel.currentUser.copyWith(pushNotifications: v);
          },
        ),

        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                if (!homeViewModel.isEmailValid(homeViewModel.currentUser.email)) {
                  _showError(context, Strings.emailError);
                  return;
                }

                if (!homeViewModel.isPasswordValid(homeViewModel.password)) {
                  _showError(context, Strings.passwordError);
                  return;
                }

                if (homeViewModel.password != homeViewModel.confirmPassword) {
                  _showError(context, Strings.passwordMismatchError);
                  return;
                }

                await homeViewModel.signUp(context);
                clearControllers();
                if (mounted) homeViewModel.toggleSignUpForm();
              },
              child: const Text(Strings.createAccountButton),
            ),
            const SizedBox(width: 10),
            TextButton(
              onPressed: () => homeViewModel.toggleSignUpForm(),
              child: const Text(Strings.cancelButton),
            ),
          ],
        ),
      ],
    );
  }

  // 🔹 FORMULAIRE CONNEXION
  Widget _buildSignInForm(BuildContext context, AccountViewModel homeViewModel) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('img/logo.jpeg', height: 100, width: 100),
        const SizedBox(height: 20),
        _buildTextField(_emailController, Strings.emailLabel, (v) {
          homeViewModel.currentUser = homeViewModel.currentUser.copyWith(email: v.trim());
        }),
        _buildPasswordField(_passwordController, Strings.passwordLabel, (v) {
          homeViewModel.password = v.trim();
        }),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await homeViewModel.signIn(context);
                clearControllers();
                homeViewModel.toggleSignInForm();
              },
              child: const Text(Strings.signInButton),
            ),
            const SizedBox(width: 10),
            TextButton(
              onPressed: () => homeViewModel.toggleSignUpForm(),
              child: const Text(Strings.createAccountLink),
            ),
          ],
        ),
      ],
    );
  }

  // 🔹 Widgets utilitaires
  Widget _buildTextField(TextEditingController controller, String label, Function(String) onChanged,
      {int maxLines = 1}) {
    return SizedBox(
      width: 300,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        maxLength: 40,
        maxLines: maxLines,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label, Function(String) onChanged) {
    return SizedBox(
      width: 300,
      child: TextField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(labelText: label),
        maxLength: 20,
        maxLines: 1,
        onChanged: onChanged,
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

// 🔹 Dropdown avec callback intégré
class DeliveryMethodDropdown extends StatelessWidget {
  final ValueNotifier<DeliveryMethod> notifier;
  final Function(DeliveryMethod) onChanged;

  const DeliveryMethodDropdown({
    Key? key,
    required this.notifier,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DeliveryMethod>(
      valueListenable: notifier,
      builder: (context, value, child) {
        return SizedBox(
          width: 300,
          child: DropdownButtonFormField<DeliveryMethod>(
            value: value,
            items: DeliveryMethod.values
                .map((m) => DropdownMenuItem(
                      value: m,
                      child: Text(m.label),
                    ))
                .toList(),
            onChanged: (v) {
              if (v != null) {
                notifier.value = v;
                onChanged(v);
              }
            },
            decoration: const InputDecoration(labelText: Strings.deliveryMethodLabel),
          ),
        );
      },
    );
  }
}

// 🔹 Switch avec callback intégré
class PushNotificationSwitch extends StatelessWidget {
  final ValueNotifier<bool> notifier;
  final Function(bool) onChanged;

  const PushNotificationSwitch({
    Key? key,
    required this.notifier,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: notifier,
      builder: (context, value, child) {
        return SizedBox(
          width: 300,
          child: SwitchListTile(
            title: const Text(Strings.pushNotificationLabel),
            value: value,
            onChanged: (v) {
              notifier.value = v;
              onChanged(v);
            },
          ),
        );
      },
    );
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
