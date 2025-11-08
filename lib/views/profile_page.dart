import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/delivery_method_config.dart';
import '../models/user_model.dart';
import '../viewmodels/account_view_model.dart';
import '../repositories/account_repository.dart';
import '../extensions/context_extension.dart';
import '../viewmodels/delivery_method_view_model.dart';

class ProfilePage extends StatefulWidget {
  final UserModel user;

  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late UserModel _editableUser;
  bool _isEditing = false;
  bool _isSaving = false;

  late final TextEditingController _nameController;
  late final TextEditingController _givenNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _editableUser = widget.user.copyWith();

    _nameController = TextEditingController(text: _editableUser.name);
    _givenNameController = TextEditingController(text: _editableUser.givenName);
    _emailController = TextEditingController(text: _editableUser.email);
    _phoneController = TextEditingController(text: _editableUser.phoneNumber);
    _addressController = TextEditingController(text: _editableUser.address);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _givenNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeViewModel = context.read<AccountViewModel>();
    final accountRepository = context.read<AccountRepository>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing
              ? context.l10n.profileUpdateLabel
              : context.l10n.profileTitle,
        ),
        backgroundColor: Colors.greenAccent,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: context.l10n.profileUpdateLabel,
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isEditing
            ? _buildEditForm(homeViewModel, accountRepository)
            : _buildReadOnlyView(),
      ),
    );
  }

  Widget _buildReadOnlyView() {
    return ListView(
      children: [
        const Icon(Icons.account_circle, size: 100, color: Colors.green),
        const SizedBox(height: 16),
        _buildInfoTile(context.l10n.name, _editableUser.name),
        _buildInfoTile(context.l10n.givenNameLabel, _editableUser.givenName),
        _buildInfoTile(context.l10n.emailLabel, _editableUser.email),
        _buildInfoTile(context.l10n.phoneLabel, _editableUser.phoneNumber),
        _buildInfoTile(context.l10n.addressLabel, _editableUser.address),
        _buildInfoTile(
          context.l10n.deliveryMethodLabel,
          _editableUser.deliveryMethod.label,
        ),
        _buildInfoTile(
          context.l10n.pushNotificationLabel,
          _editableUser.pushNotifications ? "Oui" : "Non",
        ),
      ],
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return ListTile(
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value.isNotEmpty ? value : "—"),
    );
  }

  Widget _buildEditForm(
    AccountViewModel homeViewModel,
    AccountRepository accountRepository,
  ) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 10),
      children: [
        _buildEditableField(
          context.l10n.name,
          _nameController,
          (v) => _editableUser = _editableUser.copyWith(name: v),
        ),
        _buildEditableField(
          context.l10n.givenNameLabel,
          _givenNameController,
          (v) => _editableUser = _editableUser.copyWith(givenName: v),
        ),
        _buildEditableField(
          context.l10n.emailLabel,
          _emailController,
          (v) {},
          readOnly: true,
        ),
        _buildEditableField(
          context.l10n.phoneLabel,
          _phoneController,
          (v) => _editableUser = _editableUser.copyWith(phoneNumber: v),
        ),
        _buildEditableField(
          context.l10n.addressLabel,
          _addressController,
          (v) => _editableUser = _editableUser.copyWith(address: v),
          maxLines: 3,
        ),

        // ---------------------------
        // Dropdown pour la méthode de livraison
        const SizedBox(height: 16),
        Consumer<DeliveryMethodViewModel>(
          builder: (context, deliveryMethodVM, child) {
            if (deliveryMethodVM.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            // ✅ Si aucune méthode chargée, afficher message
            if (deliveryMethodVM.methods.isEmpty) {
              return const Center(
                child: Text('Aucune méthode de livraison disponible'),
              );
            }

            // ✅ Assurer que la méthode actuelle existe dans la liste
            final currentMethod = _editableUser.deliveryMethod;
            final methodExists = deliveryMethodVM.activeMethods
                .any((m) => m.key == currentMethod.key);

            // Si la méthode n'existe pas, utiliser la première disponible
            if (!methodExists && deliveryMethodVM.activeMethods.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _editableUser = _editableUser.copyWith(
                    deliveryMethod: deliveryMethodVM.activeMethods.first,
                  );
                });
              });
              return const SizedBox.shrink();
            }

            return DeliveryMethodDropdown(
              value: _editableUser.deliveryMethod,
              methods: deliveryMethodVM.activeMethods,
              onChanged: (method) {
                setState(() {
                  _editableUser = _editableUser.copyWith(
                    deliveryMethod: method,
                  );
                });
              },
            );
          },
        ),

        // Switch pour les notifications push
        const SizedBox(height: 16),
        SwitchListTile(
          title: Text(context.l10n.pushNotificationLabel),
          value: _editableUser.pushNotifications,
          activeThumbColor: Colors.green,
          onChanged: (value) {
            setState(() {
              _editableUser = _editableUser.copyWith(pushNotifications: value);
            });
          },
        ),

        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: _isSaving
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    )
                  : const Icon(Icons.save),
              label: Text(context.l10n.save),
              onPressed: _isSaving
                  ? null
                  : () async {
                      setState(() => _isSaving = true);

                      final success = await homeViewModel.updateUserProfile(
                        context,
                        _editableUser,
                      );

                      if (success) {
                        setState(() {
                          homeViewModel.currentUser = _editableUser;
                          _isEditing = false;
                          _isSaving = false;
                        });
                      } else {
                        setState(() => _isSaving = false);
                      }
                    },
            ),
            const SizedBox(width: 16),
            OutlinedButton(
              onPressed: () => setState(() {
                _editableUser = widget.user.copyWith();
                _nameController.text = _editableUser.name;
                _givenNameController.text = _editableUser.givenName;
                _emailController.text = _editableUser.email;
                _phoneController.text = _editableUser.phoneNumber;
                _addressController.text = _editableUser.address;
                _isEditing = false;
              }),
              child: Text(context.l10n.cancel),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEditableField(
    String label,
    TextEditingController controller,
    Function(String) onChanged, {
    int maxLines = 1,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        maxLines: maxLines,
        onChanged: onChanged,
        readOnly: readOnly,
      ),
    );
  }
}

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
            .map((m) => DropdownMenuItem(
                  value: m,
                  child: Text(m.label),
                ))
            .toList(),
        onChanged: (v) {
          if (v != null) {
            onChanged(v);
          }
        },
        decoration: InputDecoration(
          labelText: context.l10n.deliveryMethodLabel,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}