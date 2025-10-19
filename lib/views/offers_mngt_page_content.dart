import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:veggie_cart/views/weekly_offer_form_page.dart';
import '../viewmodels/weekly_offers_view_model.dart';
import '../models/weekly_offer.dart';

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
                  ? const Center(child: Text('Aucune offre disponible'))
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = 1;
                        if (constraints.maxWidth >= 900) {
                          crossAxisCount = 3;
                        } else if (constraints.maxWidth >= 600) {
                          crossAxisCount = 2;
                        }

                        return GridView.builder(
                          padding: const EdgeInsets.all(12),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1.2,
                          ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Gestion des offres',
              style: Theme.of(context).textTheme.headlineSmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: vm.toggleFilter,
                    icon: Icon(
                      vm.showPublishedOnly
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    label: Text(
                      vm.showPublishedOnly
                          ? 'Afficher tous'
                          : 'Afficher publiés',
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: vm.toggleShowClosed,
                    icon: Icon(
                      vm.showClosedOffers
                          ? Icons.lock_open
                          : Icons.lock_outline,
                    ),
                    label: Text(
                      vm.showClosedOffers
                          ? 'Masquer fermées'
                          : 'Afficher fermées',
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WeeklyOfferFormPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Créer une offre'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferCard(
      BuildContext context, WeeklyOffersViewModel vm, WeeklyOffer offer) {
    final status = offer.status;
    final style = _statusStyle(status);
    final DateFormat frenchDateFormat = DateFormat('dd/MM/yyyy', 'fr_FR');

    // 🔹 Prépare un aperçu des légumes (max 3 visibles)
    final veggiePreview = (offer.vegetables.take(3).toList());
    final hasMoreVeggies =
        offer.vegetables!.length > 3;

    // 🔹 Actions selon le statut
    List<Widget> actionButtons = switch (status) {
      WeeklyOfferStatus.draft => [
          ElevatedButton.icon(
            onPressed: () async => await vm.publishOffer(offer),
            icon: const Icon(Icons.send),
            label: const Text('Publier'),
          ),
          TextButton.icon(
            onPressed: () async => await vm.closeOffer(offer),
            icon: const Icon(Icons.lock),
            label: const Text('Fermer'),
          ),
        ],
      WeeklyOfferStatus.published => [
          TextButton.icon(
            onPressed: () async => await vm.closeOffer(offer),
            icon: const Icon(Icons.lock),
            label: const Text('Fermer'),
          ),
        ],
      WeeklyOfferStatus.closed => [
          OutlinedButton.icon(
            onPressed: () async => await vm.reopenOffer(offer),
            icon: const Icon(Icons.refresh),
            label: const Text('Réouvrir'),
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
            // === En-tête : semaine + statut ===
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Semaine du ${offer.startDate.day}/${offer.startDate.month}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Chip(
                  avatar: Icon(style['icon'] as IconData,
                      color: Colors.white, size: 14),
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

            // === Titre de l’offre ===
            Text(
              offer.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            // === Description courte ===
            if (offer.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                offer.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 13,
                ),
              ),
            ],

            const SizedBox(height: 8),

            // === Légumes (aperçu) ===
            if (veggiePreview.isNotEmpty) ...[
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  for (var veg in veggiePreview)
                    Chip(
                      label: Text(
                        veg.toString(),
                        style: const TextStyle(fontSize: 11),
                      ),
                      backgroundColor: Colors.grey[200],
                    ),
                  if (hasMoreVeggies)
                    Chip(
                      label: Text(
                        '+${offer.vegetables!.length - veggiePreview.length}',
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                      backgroundColor: Colors.grey[300],
                    ),
                ],
              ),
            ],

            const SizedBox(height: 8),

            Text(
              '${frenchDateFormat.format(offer.startDate!)} → '
              '${frenchDateFormat.format(offer.endDate!)}',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),

            const Spacer(),

            // === Boutons d’action ===
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                ElevatedButton.icon(
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
                  label: const Text('Modifier'),
                ),
                OutlinedButton.icon(
                  onPressed: () async {
                    final newStart = offer.startDate.add(const Duration(days: 7));
                    final newEnd = offer.endDate.add(const Duration(days: 7));
                    await vm.duplicateOffer(offer, newStart, newEnd);
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text('Dupliquer'),
                ),
              ],
            ),

            const SizedBox(height: 8),

            ...actionButtons,
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
