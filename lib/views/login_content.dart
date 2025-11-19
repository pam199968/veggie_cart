import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/delivery_method_config.dart';
import '../viewmodels/account_view_model.dart';
import '../viewmodels/delivery_method_view_model.dart';
import '../extensions/context_extension.dart';

class LoginContent extends StatefulWidget {
  final VoidCallback? onLoginSuccess;

  const LoginContent({super.key, this.onLoginSuccess});

  @override
  State<LoginContent> createState() => _LoginContentState();
}

class _LoginContentState extends State<LoginContent> {
  final _nameController = TextEditingController();
  final _givenNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  // 🔹 Ajout de la clé de formulaire pour la validation
  final _signUpFormKey = GlobalKey<FormState>();

  DeliveryMethodConfig? _selectedDeliveryMethod;
  bool _pushNotifications = true;

  @override
  void initState() {
    super.initState();
  }

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
    final deliveryMethodVM = context.watch<DeliveryMethodViewModel>();

    // ✅ Initialisation du choix par défaut une seule fois
    if (_selectedDeliveryMethod == null &&
        deliveryMethodVM.activeMethods.isNotEmpty) {
      _selectedDeliveryMethod = deliveryMethodVM.defaultMethod;
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: homeViewModel.showSignUpForm
                ? _buildSignUpForm(context, homeViewModel, deliveryMethodVM)
                : _buildSignInForm(context, homeViewModel),
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpForm(
    BuildContext context,
    AccountViewModel homeViewModel,
    DeliveryMethodViewModel deliveryMethodVM,
  ) {
    return Form(
      key: _signUpFormKey, // 🔹 Ajout de la clé de formulaire
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset('img/logo.png', height: 256, width: 256),
          const SizedBox(height: 20),
          // 🔹 Champs avec validation
          _buildValidatedTextField(
            _nameController,
            context.l10n.nameLabel,
            (v) {
              homeViewModel.currentUser = homeViewModel.currentUser.copyWith(
                name: v.trim(),
              );
            },
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Le nom est obligatoire';
              }
              return null;
            },
          ),

          _buildValidatedTextField(
            _givenNameController,
            context.l10n.givenNameLabel,
            (v) {
              homeViewModel.currentUser = homeViewModel.currentUser.copyWith(
                givenName: v.trim(),
              );
            },
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Le prénom est obligatoire';
              }
              return null;
            },
          ),

          _buildValidatedTextField(
            _emailController,
            context.l10n.emailLabel,
            (v) {
              homeViewModel.currentUser = homeViewModel.currentUser.copyWith(
                email: v.trim(),
              );
            },
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'L\'email est obligatoire';
              }
              if (!homeViewModel.isEmailValid(value.trim())) {
                return 'Format email invalide';
              }
              return null;
            },
          ),

          _buildValidatedPasswordField(
            _passwordController,
            context.l10n.passwordLabel,
            (v) => homeViewModel.password = v.trim(),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Le mot de passe est obligatoire';
              }
              if (!homeViewModel.isPasswordValid(value.trim())) {
                return 'Le mot de passe doit contenir au moins 8 caractères';
              }
              return null;
            },
          ),

          const SizedBox(height: 5),
          SizedBox(
            width: 300,
            child: Text(
              context.l10n.passwordHint,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.start,
            ),
          ),
          const SizedBox(height: 10),

          _buildValidatedPasswordField(
            _confirmPasswordController,
            context.l10n.confirmPasswordLabel,
            (v) {
              homeViewModel.confirmPassword = v.trim();
            },
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'La confirmation du mot de passe est obligatoire';
              }
              if (value.trim() != _passwordController.text.trim()) {
                return 'Les mots de passe ne correspondent pas';
              }
              return null;
            },
          ),

          _buildValidatedTextField(
            _phoneController,
            context.l10n.phoneLabel,
            (v) {
              homeViewModel.currentUser = homeViewModel.currentUser.copyWith(
                phoneNumber: v.trim(),
              );
            },
            validator: (value) {
              final phoneRegex = RegExp(r'^(?:\+33[ .]?)?(?:\d[ .]?){9}\d$');

              if (value == null || value.isEmpty) {
                return 'Le téléphone est obligatoire';
              }
              if (!phoneRegex.hasMatch(value)) {
                return 'Format téléphone invalide';
              }
              return null;
            },
          ),

          _buildValidatedTextField(
            _addressController,
            context.l10n.addressLabel,
            (v) {
              homeViewModel.currentUser = homeViewModel.currentUser.copyWith(
                address: v.trim(),
              );
            },
            maxLines: 4,
            maxLength: 200,
            validator: (value) {
              if (_selectedDeliveryMethod?.key == "homeDelivery") {
                if (value == null || value.trim().isEmpty) {
                  return "L'adresse est obligatoire pour la livraison à domicile";
                }
              }
              return null;
            },
          ),

          const SizedBox(height: 10),

          // ✅ Gestion du dropdown avec les nouveaux composants
          if (deliveryMethodVM.loading)
            const CircularProgressIndicator()
          else if (deliveryMethodVM.error != null)
            Text(
              "Erreur: ${deliveryMethodVM.error}",
              style: const TextStyle(color: Colors.red),
            )
          else if (deliveryMethodVM.activeMethods.isEmpty)
            const Text("Aucune méthode de livraison disponible")
          else if (_selectedDeliveryMethod != null)
            DeliveryMethodDropdown(
              value: _selectedDeliveryMethod!,
              methods: deliveryMethodVM.activeMethods,
              onChanged: (v) {
                setState(() {
                  _selectedDeliveryMethod = v;
                  homeViewModel.currentUser = homeViewModel.currentUser
                      .copyWith(deliveryMethod: v);
                });
              },
            ),

          PushNotificationSwitch(
            value: _pushNotifications,
            onChanged: (v) {
              setState(() {
                _pushNotifications = v;
                homeViewModel.currentUser = homeViewModel.currentUser.copyWith(
                  pushNotifications: v,
                );
              });
            },
          ),

          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  // 🔹 Validation du formulaire avant soumission
                  if (!_signUpFormKey.currentState!.validate()) {
                    return; // Bloque si erreurs de validation
                  }

                  await homeViewModel.signUp(context);
                  clearControllers();
                  if (mounted) homeViewModel.toggleSignUpForm();
                  widget.onLoginSuccess?.call();
                },
                child: Text(context.l10n.createAccountButton),
              ),
              const SizedBox(width: 10),
              TextButton(
                onPressed: () => homeViewModel.toggleSignUpForm(),
                child: Text(context.l10n.cancelButton),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🔹 FORMULAIRE CONNEXION
  Widget _buildSignInForm(
    BuildContext context,
    AccountViewModel homeViewModel,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('img/logo.png', height: 256, width: 256),
        const SizedBox(height: 20),
        _buildTextField(_emailController, context.l10n.emailLabel, (v) {
          homeViewModel.currentUser = homeViewModel.currentUser.copyWith(
            email: v.trim(),
          );
        }),
        _buildPasswordField(
          _passwordController,
          context.l10n.passwordLabel,
          (v) => homeViewModel.password = v.trim(),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () async {
            try {
              await homeViewModel.signIn(context);
              if (!context.mounted) return;
              widget.onLoginSuccess?.call();
            } catch (e) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Erreur de connexion : $e")),
              );
            }
          },
          child: Text(context.l10n.signInButton),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () async {
                final email = homeViewModel.currentUser.email;
                if (email.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Veuillez entrer votre email pour réinitialiser le mot de passe.",
                      ),
                    ),
                  );
                  return;
                }
                try {
                  await homeViewModel.sendPasswordResetEmail(email);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Email de réinitialisation envoyé ✅, pensez à vérifier vos spams",
                      ),
                    ),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Erreur : $e")));
                }
              },
              child: const Text(
                "Mot de passe oublié ?",
                style: TextStyle(
                  color: Colors.blueAccent,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const Text(" | "),
            TextButton(
              onPressed: () => homeViewModel.toggleSignUpForm(),
              child: Text(
                context.l10n.createAccountLink,
                style: const TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 🔹 Nouveau widget pour champ texte validé
  Widget _buildValidatedTextField(
    TextEditingController controller,
    String label,
    Function(String) onChanged, {
    int maxLines = 1,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return SizedBox(
      width: 300,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        maxLines: maxLines,
        maxLength: maxLength,
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }

  // 🔹 Nouveau widget pour champ mot de passe validé
  Widget _buildValidatedPasswordField(
    TextEditingController controller,
    String label,
    Function(String) onChanged, {
    String? Function(String?)? validator,
  }) {
    return SizedBox(
      width: 300,
      child: TextFormField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(labelText: label),
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }

  // Anciens widgets sans validation (pour le formulaire de connexion)
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    Function(String) onChanged, {
    int maxLines = 1,
  }) {
    return SizedBox(
      width: 300,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        maxLines: maxLines,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildPasswordField(
    TextEditingController controller,
    String label,
    Function(String) onChanged,
  ) {
    return SizedBox(
      width: 300,
      child: TextField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(labelText: label),
        onChanged: onChanged,
      ),
    );
  }
}

/// 🔹 Dropdown pour DeliveryMethodConfig
class DeliveryMethodDropdown extends StatelessWidget {
  final DeliveryMethodConfig value;
  final List<DeliveryMethodConfig> methods;
  final ValueChanged<DeliveryMethodConfig> onChanged;

  const DeliveryMethodDropdown({
    super.key,
    required this.value,
    required this.methods,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    double fieldWidth = MediaQuery.of(context).size.width * 0.9;
    if (fieldWidth > 300) fieldWidth = 300;

    return SizedBox(
      width: fieldWidth,
      child: DropdownButtonFormField<DeliveryMethodConfig>(
        isExpanded: true,
        initialValue: value,
        items: methods
            .map((m) => DropdownMenuItem(value: m, child: Text(m.label)))
            .toList(),
        onChanged: (v) {
          if (v != null) {
            onChanged(v);
          }
        },
        decoration: InputDecoration(
          labelText: context.l10n.deliveryMethodLabel,
        ),
      ),
    );
  }
}

/// 🔹 Switch pour notifications push
class PushNotificationSwitch extends StatelessWidget {
  final bool value;
  final Function(bool) onChanged;

  const PushNotificationSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    double fieldWidth = MediaQuery.of(context).size.width * 0.9;
    if (fieldWidth > 300) fieldWidth = 300;

    return SizedBox(
      width: fieldWidth,
      child: SwitchListTile(
        title: Text(context.l10n.pushNotificationLabel),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
