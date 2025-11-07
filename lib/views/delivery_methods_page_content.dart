import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../extensions/context_extension.dart';
import '../viewmodels/delivery_method_view_model.dart';

class DeliveryMethodsPageContent extends StatefulWidget {
  const DeliveryMethodsPageContent({super.key});

  @override
  State<DeliveryMethodsPageContent> createState() =>
      _DeliveryMethodsPageContentState();
}

class _DeliveryMethodsPageContentState
    extends State<DeliveryMethodsPageContent> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // ✅ Utilisation de Future.microtask au lieu d'accéder directement au context
    Future.microtask(() {
      final vm = context.read<DeliveryMethodViewModel>();
      if (vm.methods.isEmpty && !vm.loading) {
        vm.loadMethods();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final deliveryMethodVM = context.watch<DeliveryMethodViewModel>();
   return Column(
      children: [
        // 🔍 Barre de recherche
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: context.l10n.searchDeliveryMethod,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            onChanged: (value) {
              setState(() => _searchQuery = value.toLowerCase());
            },
          ),
        ),

        // ➕ Bouton pour créer une méthode
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                context.l10n.addDeliveryMethod,
                style: const TextStyle(color: Colors.white),
              ),
              onPressed: () => _showCreateDialog(context, deliveryMethodVM),
            ),
          ),
        ),

        Expanded(
          child: deliveryMethodVM.loading
              ? const Center(child: CircularProgressIndicator())
              : deliveryMethodVM.error != null
              ? Center(child: Text('Erreur : ${deliveryMethodVM.error}'))
              : _buildList(context, deliveryMethodVM),
        ),
      ],
    );
  }

  Widget _buildList(BuildContext context, DeliveryMethodViewModel vm) {
    var methods = vm.methods;

    if (_searchQuery.isNotEmpty) {
      methods = methods
          .where((m) => m.label.toLowerCase().contains(_searchQuery))
          .toList();
    }

    if (methods.isEmpty) {
      return Center(child: Text(context.l10n.noDeliveryMethodsFound));
    }

    return ListView.builder(
      itemCount: methods.length,
      itemBuilder: (context, index) {
        final method = methods[index];
        final isEnabled = method.enabled;

        return Card(
          color: isEnabled ? Colors.white : Colors.grey.shade200,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            leading: Icon(
              isEnabled ? Icons.local_shipping : Icons.local_shipping_outlined,
              color: isEnabled ? Colors.green : Colors.grey,
            ),
            title: Text(
              method.label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: method.isDefault ? Colors.grey : Colors.black,
              ),
            ),
            trailing: method.isDefault
                ? null // 👈 lecture seule
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ✏️ Modifier
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blueAccent),
                        tooltip: context.l10n.edit,
                        onPressed: () => _showEditDialog(
                          context,
                          vm,
                          method.key,
                          method.label,
                        ),
                      ),

                      // 🔒 Désactiver
                      IconButton(
                        icon: Icon(
                          isEnabled ? Icons.visibility_off : Icons.visibility,
                          color: isEnabled ? Colors.redAccent : Colors.green,
                        ),
                        tooltip: isEnabled
                            ? context.l10n.disable
                            : context.l10n.reactivate,
                        onPressed: () async {
                          if (isEnabled) {
                            await vm.updateMethod(method.key, enabled: false);
                          } else {
                            await vm.updateMethod(method.key, enabled: true);
                          }
                        },
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  /// 🟢 Dialogue de création
  void _showCreateDialog(BuildContext context, DeliveryMethodViewModel vm) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.addDeliveryMethod),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: context.l10n.deliveryMethodLabel,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            child: Text(context.l10n.cancel),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text(context.l10n.save),
            onPressed: () async {
              final label = controller.text.trim();
              if (label.isEmpty) return;
              await vm.createMethod(label);
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  /// ✏️ Dialogue d’édition
  void _showEditDialog(
    BuildContext context,
    DeliveryMethodViewModel vm,
    String key,
    String currentLabel,
  ) {
    final controller = TextEditingController(text: currentLabel);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.editDeliveryMethod),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: context.l10n.deliveryMethodLabel,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            child: Text(context.l10n.cancel),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: Text(context.l10n.save),
            onPressed: () async {
              final newLabel = controller.text.trim();
              if (newLabel.isEmpty) return;
              await vm.updateMethod(key, label: newLabel);
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
