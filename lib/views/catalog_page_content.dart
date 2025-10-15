import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vegetable_model.dart';
import '../viewmodels/catalog_view_model.dart';

class CatalogPageContent extends StatelessWidget {
  const CatalogPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => context.watch<CatalogViewModel>(),
      child: Consumer<CatalogViewModel>(
        builder: (context, vm, child) {
          return Column(
            children: [
              _buildSearchAndFilter(context, vm),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 3/4,
                  ),
                  itemCount: vm.vegetables.length,
                  itemBuilder: (context, index) {
                    final veg = vm.vegetables[index];
                    return VegetableCard(
                      vegetable: veg,
                      onToggleActive: () => vm.toggleActive(veg),
                      onDelete: () => vm.deleteVegetable(veg.id),
                    );
                  },
                ),
              ),
            ],
          );
        },
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
              decoration: const InputDecoration(
                hintText: 'Rechercher un légume...',
                border: OutlineInputBorder(),
              ),
              onChanged: vm.setSearchQuery,
            ),
          ),
          const SizedBox(width: 16),
          DropdownButton<VegetableCategory?>(
            value: vm.selectedCategory,
            hint: const Text('All Categories'),
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('All Categories'),
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
}

class VegetableCard extends StatelessWidget {
  final VegetableModel vegetable;
  final VoidCallback onToggleActive;
  final VoidCallback onDelete;

  const VegetableCard({
    super.key,
    required this.vegetable,
    required this.onToggleActive,
    required this.onDelete,
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
              '€${vegetable.price?.toStringAsFixed(2) ?? '-'} /${vegetable.packaging}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () {}, // TODO: edit
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
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
      default:
        return Colors.grey;
    }
  }
}
