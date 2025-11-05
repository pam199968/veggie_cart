import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/delivery_method_config.dart';
import '../viewmodels/account_view_model.dart';
import '../viewmodels/delivery_method_view_model.dart';
import 'package:veggie_cart/extensions/context_extension.dart';

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

  DeliveryMethodConfig? _selectedDeliveryMethod;
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
    final deliveryMethodVM = context.watch<DeliveryMethodViewModel>();

    // Initialisation du choix par défaut si nécessaire
    _selectedDeliveryMethod ??= deliveryMethodVM.methods.isNotEmpty
        ? deliveryMethodVM.methods.first
        : null;

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset('img/logo.jpeg', height: 100, width: 100),
        const SizedBox(height: 20),
        _buildTextField(_nameController, context.l10n.nameLabel, (v) {
          homeViewModel.currentUser = homeViewModel.currentUser.copyWith(
            name: v.trim(),
          );
        }),
        _buildTextField(_givenNameController, context.l10n.givenNameLabel, (v) {
          homeViewModel.currentUser = homeViewModel.currentUser.copyWith(
            givenName: v.trim(),
          );
        }),
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
        _buildPasswordField(
          _confirmPasswordController,
          context.l10n.confirmPasswordLabel,
          (v) {
            homeViewModel.confirmPassword = v.trim();
          },
        ),
        _buildTextField(_phoneController, context.l10n.phoneLabel, (v) {
          homeViewModel.currentUser = homeViewModel.currentUser.copyWith(
            phoneNumber: v.trim(),
          );
        }),
        _buildTextField(_addressController, context.l10n.addressLabel, (v) {
          homeViewModel.currentUser = homeViewModel.currentUser.copyWith(
            address: v.trim(),
          );
        }, maxLines: 4),
        const SizedBox(height: 10),
        if (deliveryMethodVM.loading)
          const CircularProgressIndicator()
        else if (deliveryMethodVM.error != null)
          Text("Erreur: ${deliveryMethodVM.error}")
        else
          DeliveryMethodDropdown(
            notifier: ValueNotifier<DeliveryMethodConfig>(
              _selectedDeliveryMethod!,
            ),
            methods: deliveryMethodVM.methods,
            onChanged: (v) {
              setState(() {
                _selectedDeliveryMethod = v;
                homeViewModel.currentUser = homeViewModel.currentUser.copyWith(
                  deliveryMethod: v,
                );
              });
            },
          ),
        PushNotificationSwitch(
          notifier: ValueNotifier<bool>(_pushNotifications),
          onChanged: (v) {
            _pushNotifications = v;
            homeViewModel.currentUser = homeViewModel.currentUser.copyWith(
              pushNotifications: v,
            );
          },
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                if (!homeViewModel.isEmailValid(
                  homeViewModel.currentUser.email,
                )) {
                  _showError(context, context.l10n.emailError);
                  return;
                }
                if (!homeViewModel.isPasswordValid(homeViewModel.password)) {
                  _showError(context, context.l10n.passwordError);
                  return;
                }
                if (homeViewModel.password != homeViewModel.confirmPassword) {
                  _showError(context, context.l10n.passwordMismatchError);
                  return;
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
        Image.asset('img/logo.jpeg', height: 100, width: 100),
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

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

/// 🔹 Dropdown pour DeliveryMethodConfig
class DeliveryMethodDropdown extends StatelessWidget {
  final ValueNotifier<DeliveryMethodConfig> notifier;
  final List<DeliveryMethodConfig> methods;
  final ValueChanged<DeliveryMethodConfig> onChanged;

  const DeliveryMethodDropdown({
    super.key,
    required this.notifier,
    required this.methods,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    double fieldWidth = MediaQuery.of(context).size.width * 0.9;
    if (fieldWidth > 300) fieldWidth = 300;

    return ValueListenableBuilder<DeliveryMethodConfig>(
      valueListenable: notifier,
      builder: (context, value, child) {
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
                notifier.value = v;
                onChanged(v);
              }
            },
            decoration: InputDecoration(
              labelText: context.l10n.deliveryMethodLabel,
            ),
          ),
        );
      },
    );
  }
}

class PushNotificationSwitch extends StatelessWidget {
  final ValueNotifier<bool> notifier;
  final Function(bool) onChanged;
  const PushNotificationSwitch({
    super.key,
    required this.notifier,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) {
    double fieldWidth = MediaQuery.of(context).size.width * 0.9;
    if (fieldWidth > 300) fieldWidth = 300;
    return ValueListenableBuilder<bool>(
      valueListenable: notifier,
      builder: (context, value, child) {
        return SizedBox(
          width: fieldWidth,
          child: SwitchListTile(
            title: Text(context.l10n.pushNotificationLabel),
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
