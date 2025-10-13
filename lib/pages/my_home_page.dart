import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../repositories/account_repository.dart';
import '../models/delivery_method.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _givenNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _profileController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  DeliveryMethod _selectedDeliveryMethod = DeliveryMethod.farmPickup;
  bool _pushNotifications = true;

  void _showSignInDialog(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Se connecter'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Mot de passe')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              final accountService = context.read<AccountRepository>();
              await accountService.signInExistingAccount(
                context: context,
                email: emailController.text.trim(),
                password: passwordController.text.trim(),
              );
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Se connecter'),
          ),
        ],
      ),
    );
  }

  void _showSignUpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Créer un compte'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nom')),
              TextField(controller: _givenNameController, decoration: const InputDecoration(labelText: 'Prénom')),
              TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
              TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Mot de passe')),
              TextField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Téléphone')),
              TextField(controller: _profileController, decoration: const InputDecoration(labelText: 'Profil')),
              TextField(controller: _addressController, decoration: const InputDecoration(labelText: 'Adresse')),
              const SizedBox(height: 10),
              DropdownButtonFormField<DeliveryMethod>(
                initialValue: _selectedDeliveryMethod,
                items: DeliveryMethod.values.map((m) => DropdownMenuItem(value: m, child: Text(m.label))).toList(),
                onChanged: (v) => setState(() => _selectedDeliveryMethod = v!),
                decoration: const InputDecoration(labelText: 'Méthode de livraison'),
              ),
              SwitchListTile(
                title: const Text("Activer les notifications push"),
                value: _pushNotifications,
                onChanged: (v) => setState(() => _pushNotifications = v),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              final accountService = context.read<AccountRepository>();
              await accountService.signUp(
                context: context,
                name: _nameController.text.trim(),
                givenName: _givenNameController.text.trim(),
                email: _emailController.text.trim(),
                password: _passwordController.text.trim(),
                phoneNumber: _phoneController.text.trim(),
                profile: _profileController.text.trim(),
                address: _addressController.text.trim(),
                deliveryMethod: _selectedDeliveryMethod,
                pushNotifications: _pushNotifications,
              );
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Créer le compte'),
          ),
        ],
      ),
    );
  }


  Future<void> _signOut() async {
    final accountService = context.read<AccountRepository>();
    await accountService.signOut(context);
    _clearControllers();
  }

  void _clearControllers() {
    _nameController.clear();
    _givenNameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _phoneController.clear();
    _profileController.clear();
    _addressController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
            backgroundColor: Colors.amber,
            actions: [
              if (user == null) ...[
                IconButton(icon: const Icon(Icons.link), onPressed: () => _showSignUpDialog(context), tooltip: 'Créer un compte'),
                IconButton(icon: const Icon(Icons.login), onPressed: () => _showSignInDialog(context), tooltip: 'Se connecter'),
              ],
              if (user != null && !user.isAnonymous)
                IconButton(icon: const Icon(Icons.logout), onPressed: _signOut, tooltip: 'Déconnexion'),
            ],
          ),
          body: Center(
            child: user == null
                ? const Text("Utilisateur non connecté")
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Connecté en tant que ${user.email}"),
                      const SizedBox(height: 20),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
