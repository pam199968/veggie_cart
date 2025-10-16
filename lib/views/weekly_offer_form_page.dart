import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/weekly_offer.dart';
import '../models/vegetable_model.dart';
import '../viewmodels/weekly_offers_view_model.dart';
import '../repositories/catalog_repository.dart';

class WeeklyOfferFormPage extends StatefulWidget {
  final WeeklyOffer? existingOffer;

  const WeeklyOfferFormPage({super.key, this.existingOffer});

  @override
  State<WeeklyOfferFormPage> createState() => _WeeklyOfferFormPageState();
}

class _WeeklyOfferFormPageState extends State<WeeklyOfferFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isPublished = false;
  List<VegetableModel> _selectedVegetables = [];

  @override
  void initState() {
    super.initState();
    final offer = widget.existingOffer;
    _titleController = TextEditingController(text: offer?.title ?? '');
    _descriptionController = TextEditingController(text: offer?.description ?? '');
    _startDate = offer?.startDate;
    _endDate = offer?.endDate;
    _isPublished = offer?.isPublished ?? false;
    _selectedVegetables = offer?.vegetables ?? [];
  }

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final initial = isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
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
    final catalog = context.read<CatalogRepository>();
    final vegetables = await catalog.getAllActiveVegetables();
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
        const SnackBar(content: Text('Veuillez compléter tous les champs.')),
      );
      return;
    }

    final newOffer = WeeklyOffer(
      id: widget.existingOffer?.id ?? '',
      title: _titleController.text,
      description: _descriptionController.text,
      startDate: _startDate!,
      endDate: _endDate!,
      isPublished: _isPublished,
      vegetables: _selectedVegetables,
    );

    final vm = context.read<WeeklyOffersViewModel>();
    if (widget.existingOffer == null) {
      await vm.createOffer(newOffer);
    } else {
      await vm.updateOffer(newOffer);
    }

    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingOffer == null
            ? 'Nouvelle offre'
            : 'Modifier l’offre'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Titre'),
                validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: Text(_startDate == null
                          ? 'Date de début'
                          : 'Début : ${_startDate!.toLocal().toString().split(" ")[0]}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () => _pickDate(context, true),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: Text(_endDate == null
                          ? 'Date de fin'
                          : 'Fin : ${_endDate!.toLocal().toString().split(" ")[0]}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () => _pickDate(context, false),
                    ),
                  ),
                ],
              ),
              SwitchListTile(
                title: const Text('Publier l’offre'),
                value: _isPublished,
                onChanged: (v) => setState(() => _isPublished = v),
              ),
              const Divider(),
              ListTile(
                title: const Text('Légumes inclus'),
                trailing: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _openVegetableSelector,
                ),
              ),
              ..._selectedVegetables.map(
                (veg) => ListTile(
                  title: Text(veg.name),
                  subtitle: Text('Prix : ${veg.price ?? '-'} € / ${veg.packaging}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      final newPrice = await showDialog<double>(
                        context: context,
                        builder: (context) {
                          final controller = TextEditingController(
                              text: veg.price?.toString() ?? '');
                          return AlertDialog(
                            title: Text('Modifier le prix de ${veg.name}'),
                            content: TextField(
                              controller: controller,
                              keyboardType:
                                  const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(labelText: 'Prix (€)'),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, double.tryParse(controller.text)),
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                      if (newPrice != null) {
                        setState(() {
                          final index = _selectedVegetables.indexOf(veg);
                          _selectedVegetables[index] = VegetableModel(
                            id: veg.id,
                            name: veg.name,
                            category: veg.category,
                            packaging: veg.packaging,
                            price: newPrice,
                            description: veg.description,
                            standardQuantity: veg.standardQuantity,
                            active: veg.active,
                            image: veg.image,
                          );
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _saveOffer,
                icon: const Icon(Icons.save),
                label: const Text('Enregistrer'),
              ),
            ],
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

  @override
  void initState() {
    super.initState();
    _tempSelection = [...widget.selectedVegetables];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sélectionner des légumes'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: ListView.builder(
          itemCount: widget.allVegetables.length,
          itemBuilder: (context, index) {
            final veg = widget.allVegetables[index];
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
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _tempSelection),
          child: const Text('Valider'),
        ),
      ],
    );
  }
}
