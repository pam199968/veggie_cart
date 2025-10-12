import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';
import '../models/delivery_method.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _givenNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _profileController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  DeliveryMethod _selectedDeliveryMethod = DeliveryMethod.farmPickup;
  bool _pushNotifications = true;


  Future<void> _linkAccount() async {

    try {
      final user = _authService.currentUser;
      if (user == null || !user.isAnonymous) {
        throw FirebaseAuthException(
          code: 'no-anonymous-user',
          message: 'Aucun utilisateur anonyme connecté.',
        );
      }

      // Crée les credentials email/password
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      // Lie le compte anonyme via _authService
      final linkedUser = await _authService.linkAnonymousAccount(
        email,
        password,
      );

      // Crée le document Firestore avec toutes les informations
      final newUser = UserModel(
        name: _nameController.text.trim(),
        givenName: _givenNameController.text.trim(),
        email: email,
        phoneNumber: _phoneController.text.trim(),
        profile: _profileController.text.trim(),
        address: _addressController.text.trim(),
        deliveryMethod: _selectedDeliveryMethod,
        pushNotifications: _pushNotifications,
      );

    
      await _userService.createUserWithId(linkedUser!.uid, newUser);
      if (!mounted) return; // Le widget n'est plus dans l'arbre, on stoppe
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compte créé et lié avec succès 🎉')),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur Auth : ${e.message}')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur inconnue : $e')));
    }
  }

Future<void> _signInExistingAccount(String email, String password) async {
  try {
    await _authService.signInWithExistingAccount(email, password);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Connexion réussie ✅')),
    );
  } on FirebaseAuthException catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erreur connexion : ${e.message}')),
    );
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erreur inconnue : $e')),
    );
  }
}

  void _showSignInDialog(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _signInExistingAccount(emailController.text.trim(), passwordController.text.trim());
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Se connecter'),
          ),
        ],
      ),
    );
  }

  void _showLinkDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Créer un compte'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nom'),
              ),
              TextField(
                controller: _givenNameController,
                decoration: const InputDecoration(labelText: 'Prénom'),
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Mot de passe'),
              ),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Téléphone'),
              ),
              TextField(
                controller: _profileController,
                decoration: const InputDecoration(labelText: 'Profil'),
              ),
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Adresse'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<DeliveryMethod>(
                initialValue: _selectedDeliveryMethod,
                items: DeliveryMethod.values.map((method) => DropdownMenuItem(
                  value: method,
                  child: Text(method.label),
                )).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedDeliveryMethod = value);
                },
                decoration: const InputDecoration(labelText: 'Méthode de livraison'),
              ),
              SwitchListTile(
                title: const Text("Activer les notifications push"),
                value: _pushNotifications,
                onChanged: (value) => setState(() => _pushNotifications = value),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _linkAccount();
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Créer le compte'),
          ),
        ],
      ),
    );
  }

  Future<void> _addSampleUser() async {
    debugPrint("🔹 Tentative d'ajout d'un utilisateur...");
    try {
      final user = UserModel(
        name: "Dupont",
        givenName: "Jean",
        email: "jean.dupont@example.com",
        phoneNumber: "+33612345678",
        profile: "Admin",
        address: "12 rue des Fleurs, Paris",
        deliveryMethod: _selectedDeliveryMethod,
        pushNotifications: _pushNotifications,
      );
      
      await _userService.createUser(user);
      debugPrint("✅ Utilisateur ajouté avec succès !");
      if (!mounted) return; // Le widget n'est plus dans l'arbre, on stoppe
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Utilisateur ajouté avec succès ✅")),
      );
    } catch (e, st) {
      debugPrint("❌ Erreur lors de l’ajout de l’utilisateur : $e");
      debugPrintStack(stackTrace: st);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur : $e")));
    }
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();

      // Reconnecte l’utilisateur anonymement après la déconnexion
      await _authService.signInAnonymously();

      // clear text input controllers
      _nameController.clear();
      _givenNameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _phoneController.clear();
      _profileController.clear();
      _addressController.clear();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Déconnecté avec succès !')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la déconnexion : $e')),
      );
    }
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
              if (user != null && user.isAnonymous) ...[
                IconButton(
                  icon: const Icon(Icons.link),
                  onPressed: () => _showLinkDialog(context),
                  tooltip: 'Créer un compte'
                ),
                IconButton(
                  icon: const Icon(Icons.login),
                  onPressed: () => _showSignInDialog(context),
                  tooltip: 'Se connecter avec un compte existant',
                ),
              ], 
              if (user != null && !user.isAnonymous)
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: _signOut,
                  tooltip: 'Déconnexion',
                ),
            ],
          ),
          body: Center(
            child: user == null
                ? const Text("Utilisateur non connecté")
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        user.isAnonymous
                            ? "Connecté anonymement"
                            : "Connecté en tant que ${user.email}",
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _addSampleUser,
                        child: const Text("Ajouter un utilisateur"),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
