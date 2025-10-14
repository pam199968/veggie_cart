import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../models/delivery_method.dart';
import '../viewmodels/account_view_model.dart';
import '../repositories/account_repository.dart';
import '../i18n/strings.dart';

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
        title: Text(_isEditing ? Strings.profileUpdateLabel : Strings.profileTitle),
        backgroundColor: Colors.greenAccent,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: Strings.profileUpdateLabel,
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
        _buildInfoTile("Nom", _editableUser.name),
        _buildInfoTile("Prénom", _editableUser.givenName),
        _buildInfoTile("Email", _editableUser.email),
        _buildInfoTile("Téléphone", _editableUser.phoneNumber),
        _buildInfoTile("Adresse", _editableUser.address),
        _buildInfoTile("Livraison", _editableUser.deliveryMethod.label),
        _buildInfoTile("Notifications", _editableUser.pushNotifications ? "Oui" : "Non"),
      ],
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return ListTile(
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value.isNotEmpty ? value : "—"),
    );
  }

  Widget _buildEditForm(AccountViewModel homeViewModel, AccountRepository accountRepository) {
    return ListView(
      children: [
        const SizedBox(height: 10),
        _buildEditableField("Nom", _nameController, (v) => _editableUser = _editableUser.copyWith(name: v)),
        _buildEditableField("Prénom", _givenNameController, (v) => _editableUser = _editableUser.copyWith(givenName: v)),
        _buildEditableField("Email", _emailController, (v) {}, readOnly: true),
        _buildEditableField("Téléphone", _phoneController, (v) => _editableUser = _editableUser.copyWith(phoneNumber: v)),
        _buildEditableField("Adresse", _addressController, (v) => _editableUser = _editableUser.copyWith(address: v), maxLines: 3),

        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          ElevatedButton.icon(
            icon: _isSaving
                ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                : const Icon(Icons.save),
            label: const Text("Enregistrer"),
            onPressed: _isSaving
                ? null
                : () async {
                    setState(() => _isSaving = true);

                    // 🔹 Mise à jour via HomeViewModel (qui utilise AccountRepository)
                    final success = await homeViewModel.updateUserProfile(
                      context,
                      _editableUser,
                    );

                    if (success) {
                      setState(() {
                        // Met à jour le user courant et sort du mode édition
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
              child: const Text("Annuler"),
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
