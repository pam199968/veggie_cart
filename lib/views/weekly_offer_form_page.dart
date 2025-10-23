import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/weekly_offer.dart';
import '../models/vegetable_model.dart';
import '../viewmodels/weekly_offers_view_model.dart';
import '../repositories/catalog_repository.dart';
import 'package:veggie_cart/extensions/context_extension.dart';

class WeeklyOfferFormPage extends StatefulWidget {
  final WeeklyOffer? existingOffer;

  const WeeklyOfferFormPage({super.key, this.existingOffer});

  @override
  State<WeeklyOfferFormPage> createState() => _WeeklyOfferFormPageState();
}

class _WeeklyOfferFormPageState extends State<WeeklyOfferFormPage> {
  final _formKey = GlobalKey<FormState>();
  final DateFormat _frenchDateFormat = DateFormat('dd/MM/yyyy', 'fr_FR');
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime? _startDate;
  DateTime? _endDate;
  late WeeklyOfferStatus _status;
  List<VegetableModel> _selectedVegetables = [];

  @override
  void initState() {
    super.initState();
    final offer = widget.existingOffer;
    _titleController = TextEditingController(text: offer?.title ?? '');
    _descriptionController = TextEditingController(
      text: offer?.description ?? '',
    );
    _startDate = offer?.startDate;
    _endDate = offer?.endDate;
    _status = offer?.status ?? WeeklyOfferStatus.draft;
    _selectedVegetables = offer?.vegetables ?? [];
  }

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final initial = isStart
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('fr', 'FR'),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _openVegetableSelector() async {
    // 🔹 Récupérer le repository AVANT l'opération async
    final catalog = context.read<CatalogRepository>();
    final vegetables = await catalog.getAllActiveVegetables();

    // 🔹 Vérifier mounted APRÈS l'opération async
    if (!mounted) return;

    final result = await showDialog<List<VegetableModel>>(
      context: context,
      builder: (context) => VegetableSelectorDialog(
        allVegetables: vegetables,
        selectedVegetables: _selectedVegetables,
      ),
    );

    if (result != null) {
      setState(() => _selectedVegetables = result);
    }
  }

  Future<void> _saveOffer() async {
    if (!_formKey.currentState!.validate() ||
        _startDate == null ||
        _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.completeAllFields)),
      );
      return;
    }

    final newOffer = WeeklyOffer(
      id: widget.existingOffer?.id ?? '',
      title: _titleController.text,
      description: _descriptionController.text,
      startDate: _startDate!,
      endDate: _endDate!,
      status: _status,
      vegetables: _selectedVegetables,
    );

    final vm = context.read<WeeklyOffersViewModel>();
    if (widget.existingOffer == null) {
      await vm.createOffer(newOffer);
    } else {
      await vm.updateOffer(newOffer);
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingOffer != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? context.l10n.editOffer : context.l10n.newOffer),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 600,
          ), // ✅ largeur max fixe (≈ 1/3 d’un écran 1920px)
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Titre'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Champ requis' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 400;
                      if (isWide) {
                        return Row(
                          children: [
                            Expanded(
                              child: ListTile(
                                title: Text(
                                  _startDate == null
                                      ? context.l10n.startDate
                                      : 'Début : ${_frenchDateFormat.format(_startDate!)}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: const Icon(Icons.calendar_today),
                                onTap: () => _pickDate(context, true),
                              ),
                            ),
                            Expanded(
                              child: ListTile(
                                title: Text(
                                  _endDate == null
                                      ? context.l10n.endDate
                                      : 'Fin : ${_frenchDateFormat.format(_endDate!)}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: const Icon(Icons.calendar_today),
                                onTap: () => _pickDate(context, false),
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            ListTile(
                              title: Text(
                                _startDate == null
                                    ? context.l10n.startDate
                                    : 'Début : ${_frenchDateFormat.format(_startDate!)}',
                              ),
                              trailing: const Icon(Icons.calendar_today),
                              onTap: () => _pickDate(context, true),
                            ),
                            ListTile(
                              title: Text(
                                _endDate == null
                                    ? context.l10n.endDate
                                    : 'Fin : ${_frenchDateFormat.format(_endDate!)}',
                              ),
                              trailing: const Icon(Icons.calendar_today),
                              onTap: () => _pickDate(context, false),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                  if (isEditing) ...[
                    const SizedBox(height: 12),
                    DropdownButtonFormField<WeeklyOfferStatus>(
                      initialValue: _status,
                      decoration: InputDecoration(
                        labelText: context.l10n.offerStatus,
                      ),
                      onChanged: (v) {
                        if (v != null) setState(() => _status = v);
                      },
                      items: const [
                        DropdownMenuItem(
                          value: WeeklyOfferStatus.draft,
                          child: Text('Brouillon'),
                        ),
                        DropdownMenuItem(
                          value: WeeklyOfferStatus.published,
                          child: Text('Publiée'),
                        ),
                        DropdownMenuItem(
                          value: WeeklyOfferStatus.closed,
                          child: Text('Fermée'),
                        ),
                      ],
                    ),
                  ],
                  const Divider(),
                  ListTile(
                    title: Text(context.l10n.vegetablesIncluded),
                    trailing: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _openVegetableSelector,
                    ),
                  ),
                  ..._selectedVegetables.map(
                    (veg) => ListTile(
                      title: Text(veg.name),
                      subtitle: Text(
                        'Prix : ${veg.price ?? '-'} € / ${veg.packaging}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            tooltip: context.l10n.editVegetable,
                            onPressed: () async {
                              final result = await showDialog<Map<String, dynamic>>(
                                context: context,
                                builder: (context) {
                                  final priceController = TextEditingController(
                                    text: veg.price?.toString() ?? '',
                                  );
                                  final quantityController =
                                      TextEditingController(
                                        text:
                                            veg.standardQuantity?.toString() ??
                                            '',
                                      );
                                  final packagingController =
                                      TextEditingController(
                                        text: veg.packaging,
                                      );

                                  return AlertDialog(
                                    title: Text('${context.l10n.editVegetable} ${veg.name}'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextField(
                                          controller: priceController,
                                          keyboardType:
                                              const TextInputType.numberWithOptions(
                                                decimal: true,
                                              ),
                                          decoration: InputDecoration(
                                            labelText: '${context.l10n.price} (${context.l10n.currencySymbol})',
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        TextField(
                                          controller: quantityController,
                                          keyboardType:
                                              const TextInputType.numberWithOptions(
                                                decimal: true,
                                              ),
                                          decoration: const InputDecoration(
                                            labelText:
                                                'Quantité par conditionnement',
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        TextField(
                                          controller: packagingController,
                                          decoration: InputDecoration(
                                            labelText:
                                                context.l10n.packagingUnit,
                                          ),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, null),
                                        child: Text(context.l10n.cancel),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          final price = double.tryParse(
                                            priceController.text,
                                          );
                                          final quantity = double.tryParse(
                                            quantityController.text,
                                          );
                                          final packaging = packagingController
                                              .text
                                              .trim();

                                          Navigator.pop(context, {
                                            'price': price,
                                            'standardQuantity': quantity,
                                            'packaging': packaging,
                                          });
                                        },
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (result != null) {
                                setState(() {
                                  final index = _selectedVegetables.indexOf(
                                    veg,
                                  );
                                  _selectedVegetables[index] = VegetableModel(
                                    id: veg.id,
                                    name: veg.name,
                                    category: veg.category,
                                    price: result['price'] ?? veg.price,
                                    standardQuantity:
                                        result['standardQuantity'] ??
                                        veg.standardQuantity,
                                    packaging:
                                        result['packaging'] ?? veg.packaging,
                                    description: veg.description,
                                    active: veg.active,
                                    image: veg.image,
                                  );
                                });
                              }
                            },
                          ),

                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: context.l10n.removeVegetable,
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('${context.l10n.removeVegetable} ${veg.name} ?'),
                                  content: Text(
                                    context.l10n.removeVegetableQuestion,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(context.l10n.cancel),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          _selectedVegetables.remove(veg);
                                        });
                                        Navigator.pop(context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.redAccent,
                                      ),
                                      child: Text(context.l10n.delete),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _saveOffer,
                    icon: const Icon(Icons.save),
                    label: Text(context.l10n.save),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Boîte de dialogue pour sélectionner les légumes

class VegetableSelectorDialog extends StatefulWidget {
  final List<VegetableModel> allVegetables;
  final List<VegetableModel> selectedVegetables;

  const VegetableSelectorDialog({
    super.key,
    required this.allVegetables,
    required this.selectedVegetables,
  });

  @override
  State<VegetableSelectorDialog> createState() =>
      _VegetableSelectorDialogState();
}

class _VegetableSelectorDialogState extends State<VegetableSelectorDialog> {
  late List<VegetableModel> _tempSelection;
  late List<VegetableModel> _filteredVegetables;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tempSelection = [...widget.selectedVegetables];
    _filteredVegetables = [...widget.allVegetables];

    _searchController.addListener(_filterVegetables);
  }

  void _filterVegetables() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredVegetables = [...widget.allVegetables];
      } else {
        _filteredVegetables = widget.allVegetables
            .where((veg) => veg.name.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    if (isMobile) {
      // ✅ Version mobile : plein écran
      return Scaffold(
        appBar: AppBar(
          title:  Text(context.l10n.selectVegetables),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, _tempSelection),
              child:  Text(
                context.l10n.validate,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        body: _buildScrollableList(),
      );
    }

    // ✅ Version desktop : boîte de dialogue centrée et scrollable
    return AlertDialog(
      title: Text(context.l10n.selectVegetables),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.33, // 1/3 de l’écran
        height: 500,
        child: _buildScrollableList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.cancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _tempSelection),
          child: Text(context.l10n.validate),
        ),
      ],
    );
  }

  /// 🔹 Liste scrollable avec champ de recherche
  Widget _buildScrollableList() {
    final scrollController = ScrollController();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              labelText: context.l10n.searchVegetable,
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          child: Scrollbar(
            thumbVisibility: true,
            controller: scrollController,
            child: ListView.builder(
              controller: scrollController,
              itemCount: _filteredVegetables.length,
              itemBuilder: (context, index) {
                final veg = _filteredVegetables[index];
                final selected = _tempSelection.contains(veg);
                return CheckboxListTile(
                  title: Text(veg.name),
                  subtitle: Text(veg.packaging),
                  value: selected,
                  onChanged: (v) {
                    setState(() {
                      if (v == true) {
                        _tempSelection.add(veg);
                      } else {
                        _tempSelection.remove(veg);
                      }
                    });
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}