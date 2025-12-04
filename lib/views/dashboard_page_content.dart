// Copyright (c) 2025
// All rights reserved.

import 'package:au_bio_jardin_app/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/dashboard_view_model.dart';

class DashboardPageContent extends StatefulWidget {
  const DashboardPageContent({super.key});

  @override
  State<DashboardPageContent> createState() => _DashboardPageContentState();
}

class _DashboardPageContentState extends State<DashboardPageContent> {
  late DateTimeRange selectedRange;
  String selectedPreset = "Sem."; // valeur par défaut

  @override
  void initState() {
    super.initState();
    selectedRange = _defaultWeekRange();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardViewModel>().loadDashboard(selectedRange);
    });
  }

  // 🔹 Plage de dates par défaut : semaine courante
  DateTimeRange _defaultWeekRange() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    return DateTimeRange(start: monday, end: sunday);
  }

  // 🔹 Périodes prédéfinies
  void _selectRangePreset(String preset) {
    selectedPreset = preset; // 🔹 mettre à jour la période sélectionnée
    final now = DateTime.now();
    late DateTimeRange newRange;

    switch (preset) {
      case "Sem.":
        newRange = _defaultWeekRange();
        break;

      case "Mois":
        final start = DateTime(now.year, now.month, 1);
        final end = DateTime(now.year, now.month + 1, 0);
        newRange = DateTimeRange(start: start, end: end);
        break;

      case "Trim.":
        final quarter = ((now.month - 1) ~/ 3) + 1;
        final start = DateTime(now.year, (quarter - 1) * 3 + 1, 1);
        final end = DateTime(now.year, quarter * 3 + 1, 0);
        newRange = DateTimeRange(start: start, end: end);
        break;

      case "Année":
        final start = DateTime(now.year, 1, 1);
        final end = DateTime(now.year, 12, 31);
        newRange = DateTimeRange(start: start, end: end);
        break;

      default:
        return;
    }

    setState(() => selectedRange = newRange);
    context.read<DashboardViewModel>().loadDashboard(newRange);
  }

  // 🔹 Sélection personnalisée via DateRangePicker
  Future<void> _selectCustomRange() async {
    final firstDate = DateTime(
      selectedRange.start.year - 1,
      selectedRange.start.month,
      1,
    );

    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: selectedRange,
      firstDate: firstDate,
      lastDate: DateTime(2100),
      locale: const Locale('fr', 'FR'),
      helpText: "Sélectionnez une période",
      useRootNavigator: true,
    );

    if (picked != null && mounted) {
      selectedRange = picked;
      selectedPreset = "Perso.";
      setState(() => selectedRange = picked);
      context.read<DashboardViewModel>().loadDashboard(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.dashboard), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ----------------------
            // 🔹 Sélecteur de période
            // ----------------------
            _buildPeriodSelector(),

            const SizedBox(height: 24),

            if (vm.loading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else
              Expanded(child: _buildMetrics(vm)),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------
  // 🔹 Widget du sélecteur de période
  // ------------------------------------------------
  Widget _buildPeriodSelector() {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: Row(
          children: [
            Expanded(
              child: Wrap(
                spacing: 4,
                children: [
                  _chip("Sem."),
                  _chip("Mois"),
                  _chip("Perso.", custom: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, {bool custom = false}) {
    final isSelected = selectedPreset == label;

    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (isSelected) ...[const SizedBox(width: 4)],
        ],
      ),
      selected: isSelected,
      onSelected: (_) {
        if (custom) {
          _selectCustomRange();
        } else {
          _selectRangePreset(label);
          setState(() {}); // 🔹 rafraîchir pour mettre à jour le checkmark
        }
      },
    );
  }

  // ------------------------------------------------
  // 🔹 Affichage des indicateurs
  // ------------------------------------------------
  Widget _buildMetrics(DashboardViewModel vm) {
    return ListView(
      children: [
        Row(
          children: [
            Expanded(
              child: _metricCard(
                title: context.l10n.pendingOrders,
                value: vm.pendingOrders.toString(),
                icon: Icons.pending,
                iconColor: Colors.orange,
                //label: "Commandes en attente", // nouveau libellé
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _metricCard(
                title: context.l10n.deliveredOrders,
                value: vm.deliveredOrReady.toString(),
                icon: Icons.check_circle,
                iconColor: Colors.green,
                //label: "Commandes livrées",
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _metricCard(
          title: context.l10n.qtyByVegetable,
          icon: Icons.leaderboard,
          iconColor: Colors.indigo,
          label: context.l10n.qtyByVegetableLabel,
          valueWidget: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: vm.quantitiesByVeg.entries
                .map((e) => Text("• ${e.key} : ${e.value['label']}"))
                .toList(),
          ),
        ),
        const SizedBox(height: 16),
        _metricCard(
          title: context.l10n.qtyByCustomer,
          icon: Icons.person,
          iconColor: Colors.teal,
          label: context.l10n.qtyByCustomerLabel,
          valueWidget: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: vm.salesByCustomerVeg.entries.map((entry) {
              final customer = entry.key;
              final veggies = entry.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ...veggies.entries
                        .map((v) => Text("• ${v.key} : ${v.value['label']}")),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _metricCard({
    required String title,
    required IconData icon,
    Color? iconColor,
    String? value,
    Widget? valueWidget,
    String? label,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Colonne icône + libellé
            Expanded(
              child: Column(
                children: [
                  Icon(
                    icon,
                    size: 32,
                    color: iconColor ?? Theme.of(context).iconTheme.color,
                  ),
                  if (label != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: SizedBox(
                        width: 100,
                        child: Text(
                          label,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(fontSize: 12),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // 🔹 Colonne valeur SOUS le titre
            if (valueWidget == null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value ?? "",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              )
            else
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    valueWidget,
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
