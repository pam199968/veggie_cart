import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:veggie_cart/l10n/app_localizations.dart';
import '../models/vegetable_model.dart';
import '../viewmodels/catalog_view_model.dart';

class CatalogPageContent extends StatefulWidget {
  const CatalogPageContent({super.key});

  @override
  State<CatalogPageContent> createState() => _CatalogPageContentState();
}

class _CatalogPageContentState extends State<CatalogPageContent> {
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final vm = context.read<CatalogViewModel>();
      vm.loadVegetables();
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CatalogViewModel>();

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSearchAndFilter(context, vm),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: vm.vegetables.map((veg) {
              return SizedBox(
                width: 250,
                child: VegetableCard(
                  vegetable: veg,
                  onToggleActive: () => vm.toggleActive(veg),
                  onDelete: () => vm.deleteVegetable(veg.id),
                  onEdit: () => _showEditVegetableDialog(context, vm, veg),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 80),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddVegetableDialog(context, vm),
        icon: const Icon(Icons.add),
        label: Text(AppLocalizations.of(context)!.addVegetable),
      ),
    );
  }

  Widget _buildSearchAndFilter(BuildContext context, CatalogViewModel vm) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.searchVegetable,
                border: const OutlineInputBorder(),
              ),
              onChanged: vm.setSearchQuery,
            ),
          ),
          const SizedBox(width: 16),
          DropdownButton<VegetableCategory?>(
            value: vm.selectedCategory,
            hint: Text(AppLocalizations.of(context)!.allCategories),
            items: [
              DropdownMenuItem(
                value: null,
                child: Text(AppLocalizations.of(context)!.allCategories),
              ),
              ...VegetableCategory.values.map(
                (cat) => DropdownMenuItem(
                  value: cat,
                  child: Text(cat.label),
                ),
              ),
            ],
            onChanged: vm.setCategory,
          ),
        ],
      ),
    );
  }

  void _showAddVegetableDialog(BuildContext context, CatalogViewModel vm) {
    _showVegetableDialog(context, vm, isEdit: false);
  }

  void _showEditVegetableDialog(
      BuildContext context, CatalogViewModel vm, VegetableModel vegetable) {
    _showVegetableDialog(context, vm, isEdit: true, vegetable: vegetable);
  }

  void _showVegetableDialog(BuildContext context, CatalogViewModel vm,
      {required bool isEdit, VegetableModel? vegetable}) {
    final nameController = TextEditingController(text: vegetable?.name ?? '');
    final descController =
        TextEditingController(text: vegetable?.description ?? '');
    final packagingController =
        TextEditingController(text: vegetable?.packaging ?? '');
    final quantityController = TextEditingController(
        text: vegetable?.standardQuantity?.toString() ?? '');
    final priceController =
        TextEditingController(text: vegetable?.price?.toString() ?? '');
    final imageController = TextEditingController(text: vegetable?.image ?? '');
    VegetableCategory? selectedCategory =
        vegetable?.category ?? VegetableCategory.other;
    bool active = vegetable?.active ?? true;

    bool isFormValid() {
      final price = double.tryParse(priceController.text);
      final qty = double.tryParse(quantityController.text);
      return nameController.text.isNotEmpty &&
          selectedCategory != null &&
          (price == null || price >= 0) &&
          (qty == null || qty >= 0);
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            void onFieldChanged() => setState(() {});

            return AlertDialog(
              title: Text(isEdit ? AppLocalizations.of(context)!.editVegetable : AppLocalizations.of(context)!.addVegetable),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: AppLocalizations.of(context)!.name),
                      onChanged: (_) => onFieldChanged(),
                    ),
                    TextField(
                      controller: descController,
                      decoration:
                          InputDecoration(labelText: AppLocalizations.of(context)!.description),
                      maxLines: 2,
                    ),
                    DropdownButton<VegetableCategory>(
                      value: selectedCategory,
                      hint: Text(AppLocalizations.of(context)!.category),
                      items: VegetableCategory.values.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text(cat.label),
                        );
                      }).toList(),
                      onChanged: (cat) {
                        selectedCategory = cat;
                        onFieldChanged();
                      },
                    ),
                    TextField(
                      controller: packagingController,
                      decoration: InputDecoration(labelText: AppLocalizations.of(context)!.packaging),
                    ),
                    TextField(
                      controller: quantityController,
                      decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.standardQuantity),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => onFieldChanged(),
                    ),
                    TextField(
                      controller: priceController,
                      decoration:
                          InputDecoration(labelText: AppLocalizations.of(context)!.price),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => onFieldChanged(),
                    ),
                    SwitchListTile(
                      value: active,
                      title: Text(AppLocalizations.of(context)!.active),
                      onChanged: (val) {
                        setState(() {
                          active = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                ElevatedButton(
                  onPressed: isFormValid()
                      ? () {
                          final model = VegetableModel(
                            id: vegetable?.id ?? DateTime.now().toString(),
                            name: nameController.text,
                            category: selectedCategory!,
                            description: descController.text.isNotEmpty
                                ? descController.text
                                : null,
                            packaging: packagingController.text,
                            standardQuantity:
                                double.tryParse(quantityController.text),
                            price: double.tryParse(priceController.text),
                            active: active,
                            image: imageController.text.isNotEmpty
                                ? imageController.text
                                : null,
                          );

                          if (isEdit) {
                            vm.updateVegetable(model);
                          } else {
                            vm.addVegetable(model);
                          }

                          Navigator.pop(context);
                        }
                      : null,
                  child: Text(isEdit ? AppLocalizations.of(context)!.save : AppLocalizations.of(context)!.add),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class VegetableCard extends StatelessWidget {
  final VegetableModel vegetable;
  final VoidCallback onToggleActive;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const VegetableCard({
    super.key,
    required this.vegetable,
    required this.onToggleActive,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.eco, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    vegetable.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Switch(
                  value: vegetable.active,
                  onChanged: (_) => onToggleActive(),
                ),
              ],
            ),
            if (vegetable.description != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  vegetable.description!,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            const SizedBox(height: 4),
            Text(
              vegetable.packaging,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _categoryColor(vegetable.category),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                vegetable.category.label,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${vegetable.price?.toStringAsFixed(2) ?? '-'} ${AppLocalizations.of(context)!.currencySymbol} /${vegetable.packaging}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit),
                  label: Text(AppLocalizations.of(context)!.edit),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _categoryColor(VegetableCategory category) {
    switch (category) {
      case VegetableCategory.leaf:
        return Colors.green;
      case VegetableCategory.fruit:
        return Colors.pink;
      case VegetableCategory.root:
        return Colors.orange;
      case VegetableCategory.other:
        return Colors.blueGrey;
      default:
        return Colors.grey;
    }
  }
}
