import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:veggie_cart/views/weekly_offer_form_page.dart';
import '../viewmodels/weekly_offers_view_model.dart';
import '../models/weekly_offer.dart';
import 'package:veggie_cart/extensions/context_extension.dart';

class OffersMngtPageContent extends StatelessWidget {
  const OffersMngtPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WeeklyOffersViewModel>(
      builder: (context, vm, _) {
        if (vm.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            _buildHeader(context, vm),
            const SizedBox(height: 16),
            Expanded(
              child: vm.offers.isEmpty
                  ? Center(child: Text(context.l10n.noOffersAvailable))
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        return ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: vm.offers.length,
                          itemBuilder: (context, index) {
                            final offer = vm.offers[index];
                            return _buildOfferCard(context, vm, offer);
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, WeeklyOffersViewModel vm) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.offersManagement,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              SizedBox(
                height: 40,
                child: DropdownButton<OfferFilter>(
                  value: vm.offerFilter,
                  onChanged: (value) {
                    if (value != null) vm.setOfferFilter(value);
                  },
                  items: [
                    DropdownMenuItem(
                      value: OfferFilter.draft,
                      child: Text(context.l10n.draft),
                    ),
                    DropdownMenuItem(
                      value: OfferFilter.published,
                      child: Text(context.l10n.published),
                    ),
                    DropdownMenuItem(
                      value: OfferFilter.closed,
                      child: Text(context.l10n.closed),
                    ),
                    DropdownMenuItem(
                      value: OfferFilter.all,
                      child: Text(context.l10n.all),
                    ),
                  ],
                ),
              ),

              // Bouton "Créer une offre"
              SizedBox(
                height: 40,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WeeklyOfferFormPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add, size: 20),
                  label: Text(context.l10n.offerCreation),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOfferCard(
    BuildContext context,
    WeeklyOffersViewModel vm,
    WeeklyOffer offer,
  ) {
    final status = offer.status;
    final style = _statusStyle(status);
    final DateFormat frenchDateFormat = DateFormat('dd/MM/yyyy', 'fr_FR');

    List<Widget> actionButtons = switch (status) {
      WeeklyOfferStatus.draft => [
        IconButton(
          tooltip: context.l10n.publish,
          onPressed: vm.isPublishing
              ? null
              : () async => await vm.publishOffer(offer, context),
          icon: vm.isPublishing
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.send),
        ),

        IconButton(
          onPressed: () async => await vm.closeOffer(offer),
          icon: const Icon(Icons.lock),
          tooltip: context.l10n.close,
        ),
      ],
      WeeklyOfferStatus.published => [
        IconButton(
          onPressed: () async => await vm.closeOffer(offer),
          icon: const Icon(Icons.lock),
          tooltip: context.l10n.close,
        ),
      ],
      WeeklyOfferStatus.closed => [
        IconButton(
          onPressed: () async => await vm.reopenOffer(offer),
          icon: const Icon(Icons.refresh),
          tooltip: context.l10n.reopen,
        ),
      ],
    };

    return Card(
      color: style['bgColor'] as Color?,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ligne des boutons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    IconButton(
                      tooltip: context.l10n.edit,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                WeeklyOfferFormPage(existingOffer: offer),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit),
                    ),
                    IconButton(
                      tooltip: context.l10n.copy,
                      onPressed: () async {
                        final newStart = offer.startDate.add(
                          const Duration(days: 7),
                        );
                        final newEnd = offer.endDate.add(
                          const Duration(days: 7),
                        );
                        await vm.duplicateOffer(offer, newStart, newEnd);
                      },
                      icon: const Icon(Icons.copy),
                    ),
                    ...actionButtons,
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Semaine + statut
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${context.l10n.weekRange} ${offer.startDate.day}/${offer.startDate.month}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Chip(
                  avatar: Icon(
                    style['icon'] as IconData,
                    color: Colors.white,
                    size: 14,
                  ),
                  label: Text(
                    style['label'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                    ),
                  ),
                  backgroundColor: style['color'] as Color?,
                ),
              ],
            ),

            const SizedBox(height: 6),

            // Titre et description
            Text(
              offer.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (offer.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                offer.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[700], fontSize: 13),
              ),
            ],

            const SizedBox(height: 8),

            // Légumes : jusqu'à 3 en Chips + liste scrollable dépliable
            ExpansionTile(
              title: Text(
                context.l10n.moreVegetables,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 200, // hauteur max pour scroll interne
                  ),
                  child: ListView.builder(
                    shrinkWrap: true, // ✅ indispensable
                    physics:
                        const ClampingScrollPhysics(), // scroll interne limité
                    itemCount: offer.vegetables.length,
                    itemBuilder: (context, index) {
                      final veg = offer.vegetables[index];
                      return ListTile(
                        dense: true,
                        title: Text(veg.name),
                        subtitle: Text(
                          'Prix : ${veg.price ?? '-'} € / ${veg.packaging}',
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Dates
            Text(
              '${frenchDateFormat.format(offer.startDate)} → ${frenchDateFormat.format(offer.endDate)}',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  /// Styles pour les statuts
  Map<String, dynamic> _statusStyle(WeeklyOfferStatus status) {
    switch (status) {
      case WeeklyOfferStatus.draft:
        return {
          'label': 'Brouillon',
          'color': Colors.orange,
          'bgColor': Colors.orange[50],
          'icon': Icons.edit,
        };
      case WeeklyOfferStatus.published:
        return {
          'label': 'Publiée',
          'color': Colors.green,
          'bgColor': Colors.green[50],
          'icon': Icons.check_circle,
        };
      case WeeklyOfferStatus.closed:
        return {
          'label': 'Fermée',
          'color': Colors.red,
          'bgColor': Colors.red[50],
          'icon': Icons.lock,
        };
    }
  }
}
