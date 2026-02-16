// Copyright (c) 2025 Patrick Mortas
// All rights reserved.

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'dart:io' show File;

import '../extensions/context_extension.dart';
import '../models/vegetable_model.dart';
import '../utils/image_picker_uploader.dart';
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
                  onDelete: () => _confirmDelete(context, vm, veg),
                  onEdit: () => _showEditVegetableDialog(context, vm, veg),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 80),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: "import",
            onPressed: () => _importFromExcel(context, vm),
            icon: const Icon(Icons.upload_file),
            label: Text(context.l10n.importFromExcel),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.extended(
            heroTag: "add",
            onPressed: () => _showAddVegetableDialog(context, vm),
            icon: const Icon(Icons.add),
            label: Text(context.l10n.addVegetable),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    CatalogViewModel vm,
    VegetableModel veg,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(context.l10n.confirmDeletion),
          content: Text('${context.l10n.deleteConfirmMessage} "${veg.name}" ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                vm.deleteVegetable(veg.id);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(context.l10n.delete),
            ),
          ],
        );
      },
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
                hintText: context.l10n.searchVegetable,
                border: const OutlineInputBorder(),
              ),
              onChanged: vm.setSearchQuery,
            ),
          ),
          const SizedBox(width: 16),
          DropdownButton<VegetableCategory?>(
            value: vm.selectedCategory,
            hint: Text(context.l10n.allCategories),
            items: [
              DropdownMenuItem(
                value: null,
                child: Text(context.l10n.allCategories),
              ),
              ...VegetableCategory.values.map(
                (cat) => DropdownMenuItem(value: cat, child: Text(cat.label)),
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
    BuildContext context,
    CatalogViewModel vm,
    VegetableModel vegetable,
  ) {
    _showVegetableDialog(context, vm, isEdit: true, vegetable: vegetable);
  }

  void _showVegetableDialog(
    BuildContext context,
    CatalogViewModel vm, {
    required bool isEdit,
    VegetableModel? vegetable,
  }) {
    final nameController = TextEditingController(text: vegetable?.name ?? '');
    final descController = TextEditingController(
      text: vegetable?.description ?? '',
    );
    final packagingController = TextEditingController(
      text: vegetable?.packaging ?? '',
    );
    final quantityController = TextEditingController(
      text: vegetable?.standardQuantity?.toString() ?? '',
    );
    final priceController = TextEditingController(
      text: vegetable?.price?.toString() ?? '',
    );
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
              title: Text(
                isEdit ? context.l10n.editVegetable : context.l10n.addVegetable,
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: context.l10n.name),
                      onChanged: (_) => onFieldChanged(),
                    ),
                    TextField(
                      controller: descController,
                      decoration: InputDecoration(
                        labelText: context.l10n.description,
                      ),
                      maxLines: 2,
                    ),
                    DropdownButton<VegetableCategory>(
                      value: selectedCategory,
                      hint: Text(context.l10n.category),
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
                      decoration: InputDecoration(
                        labelText: context.l10n.packaging,
                      ),
                    ),
                    TextField(
                      controller: quantityController,
                      decoration: InputDecoration(
                        labelText: context.l10n.standardQuantity,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (_) => onFieldChanged(),
                    ),
                    TextField(
                      controller: priceController,
                      decoration: InputDecoration(
                        labelText: context.l10n.price,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (_) => onFieldChanged(),
                    ),
                    const SizedBox(height: 16),
                    // 🖼️ Picker + miniature
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(width: 12),
                        // ✅ Picker d’image
                        Expanded(
                          child: ImagePickerUploader(
                            onImageUploaded: (url) {
                              setState(() {
                                imageController.text = url;
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    // 🕵️‍♂️ Champ masqué, conservé pour le modèle
                    Visibility(
                      visible: false,
                      maintainState: true,
                      child: TextField(controller: imageController),
                    ),

                    SwitchListTile(
                      value: active,
                      title: Text(context.l10n.active),
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
                  child: Text(context.l10n.cancel),
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
                            standardQuantity: double.tryParse(
                              quantityController.text,
                            ),
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
                  child: Text(isEdit ? context.l10n.save : context.l10n.add),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _importFromExcel(
    BuildContext context,
    CatalogViewModel vm,
  ) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.single;
    final bytes = file.bytes ?? await File(file.path!).readAsBytes();

    final excel = Excel.decodeBytes(bytes);
    final sheet = excel.tables.values.first;

    // 🔹 Lire Excel
    final List<VegetableModel> imported = [];
    for (int i = 1; i < sheet.rows.length; i++) {
      final row = sheet.rows[i];

      final model = VegetableModel(
        id: DateTime.now().millisecondsSinceEpoch.toString() + i.toString(),
        name: row[0]?.value?.toString().trim() ?? '',
        category: VegetableCategoryExtension.fromString(
          row[1]?.value?.toString().trim() ?? 'other',
        ),
        description: row[2]?.value?.toString(),
        packaging: row[3]?.value?.toString().trim() ?? '',
        standardQuantity: double.tryParse(row[4]?.value?.toString() ?? ''),
        price: double.tryParse(row[5]?.value?.toString() ?? ''),
        active: (row[6]?.value?.toString().toLowerCase() ?? 'true') == 'true',
        image: row[7]?.value?.toString(),
      );

      if (model.name.isNotEmpty && model.packaging.isNotEmpty) {
        imported.add(model);
      }
    }

    // 🔹 Charger existants
    final existing = await vm.catalogRepository.getAllActiveVegetables(
      forceRefresh: true,
    );

    final existingNames = existing.map((e) => e.name.toLowerCase()).toSet();

    // 🔹 Construire preview
    final List<_PreviewRow> preview = imported.map((v) {
      final isDuplicate = existingNames.contains(v.name.toLowerCase());
      return _PreviewRow(
        vegetable: v,
        isDuplicate: isDuplicate,
        selected: !isDuplicate,
      );
    }).toList();

    // 🔹 Dialog preview
    showDialog(
      context: context,
      builder: (_) {
        return _ImportPreviewDialog(
          rows: preview,
          onConfirm: (selected, onProgress) async {
            final total = selected.length;

            for (int i = 0; i < total; i++) {
              await vm.addVegetable(selected[i].vegetable);
              onProgress((i + 1) / total);
            }

            if (!context.mounted) return;

            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(context.l10n.nVegetablesImported(total))));
          },
        );
      },
    );
  }
}

class _PreviewRow {
  final VegetableModel vegetable;
  final bool isDuplicate;
  bool selected;

  _PreviewRow({
    required this.vegetable,
    required this.isDuplicate,
    required this.selected,
  });
}

class _ImportPreviewDialog extends StatefulWidget {
  final List<_PreviewRow> rows;
  final Future<void> Function(
    List<_PreviewRow> selected,
    void Function(double progress) onProgress,
  )
  onConfirm;

  const _ImportPreviewDialog({required this.rows, required this.onConfirm});

  @override
  State<_ImportPreviewDialog> createState() => _ImportPreviewDialogState();
}

class _ImportPreviewDialogState extends State<_ImportPreviewDialog> {
  bool _isImporting = false;
  double _progress = 0;

  @override
  Widget build(BuildContext context) {
    final selected = widget.rows.where((e) => e.selected).toList();

    return AlertDialog(
      title: Text(context.l10n.importPreview),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isImporting) ...[
              LinearProgressIndicator(value: _progress),
              const SizedBox(height: 8),
              Text('${(_progress * 100).toStringAsFixed(0)} %'),
              const SizedBox(height: 16),
            ],
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: widget.rows.map((row) {
                  return CheckboxListTile(
                    value: row.selected,
                    onChanged: _isImporting || row.isDuplicate
                        ? null
                        : (val) {
                            setState(() {
                              row.selected = val ?? false;
                            });
                          },
                    title: Text(row.vegetable.name),
                    subtitle: row.isDuplicate
                        ? Text(
                            context.l10n.duplicateVegetableWarning,
                            style: TextStyle(color: Colors.orange),
                          )
                        : Text(row.vegetable.category.label),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isImporting ? null : () => Navigator.pop(context),
          child: Text(context.l10n.cancel),
        ),
        ElevatedButton(
          onPressed: selected.isEmpty || _isImporting
              ? null
              : () async {
                  setState(() {
                    _isImporting = true;
                    _progress = 0;
                  });

                  await widget.onConfirm(selected, (p) {
                    if (!mounted) return;
                    setState(() => _progress = p);
                  });

                  if (mounted) Navigator.pop(context);
                },
          child: Text(
            _isImporting
                ? context.l10n.importInProgress
                : context.l10n.importNVegetables(selected.length),
          ),
        ),
      ],
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
            // ✅ Affiche la miniature si une image est définie
            if (vegetable.image != null && vegetable.image!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  vegetable.image!,
                  height: 128,
                  width: 128,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 100,
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    );
                  },
                ),
              )
            else
              const Icon(Icons.local_florist, size: 128),
            const SizedBox(height: 8),
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
              '${vegetable.price?.toStringAsFixed(2) ?? '-'} ${context.l10n.currencySymbol} /${vegetable.packaging}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit),
                  label: Text(context.l10n.edit),
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
    }
  }
}
