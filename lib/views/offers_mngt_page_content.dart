import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

        // Column avec Expanded pour GridView
        return Column(
          children: [
            _buildHeader(context, vm),
            const SizedBox(height: 16),
            Expanded(
              child: vm.offers.isEmpty
                  ? const Center(child: Text('Aucune offre disponible'))
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        // Nombre de colonnes responsive
                        int crossAxisCount = 1;
                        if (constraints.maxWidth >= 900) {
                          crossAxisCount = 3;
                        } else if (constraints.maxWidth >= 600) {
                          crossAxisCount = 2;
                        }

                        return GridView.builder(
                          padding: const EdgeInsets.all(12),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
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
          // Texte flexible
          Expanded(
            child: Text(
              'Gestion des offres',
              style: Theme.of(context).textTheme.headlineSmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          // Row des boutons flexible + FittedBox
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown, // réduit la taille si nécessaire
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: vm.toggleFilter,
                    icon: Icon(
                        vm.showPublishedOnly ? Icons.visibility : Icons.visibility_off),
                    label: Text(
                      vm.showPublishedOnly ? 'Afficher tous' : 'Afficher publiés',
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const WeeklyOfferFormPage()),
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
    final isPublished = offer.isPublished;
    final badgeColor = isPublished ? Colors.green : Colors.orange;
    final badgeText = isPublished ? 'Publiée' : 'Brouillon';

    return Stack(
      children: [
        Card(
          color: isPublished ? Colors.green[50] : Colors.grey[100],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Wrap le contenu du haut et le badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Semaine du ${offer.startDate.day}/${offer.startDate.month}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Chip(
                      label: Text(
                        badgeText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                        ),
                      ),
                      backgroundColor: badgeColor,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${offer.startDate.toLocal().toString().split(' ')[0]} → '
                  '${offer.endDate.toLocal().toString().split(' ')[0]}',
                ),
                const Spacer(),
                Wrap(
                  spacing: 8,
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
                isPublished
                    ? TextButton.icon(
                        onPressed: () async {
                          await vm.updateOffer(
                            offer.copyWith(isPublished: false),
                          );
                        },
                        icon: const Icon(Icons.unpublished),
                        label: const Text('Dépublier'),
                      )
                    : ElevatedButton.icon(
                        onPressed: () async => vm.publishOffer(offer),
                        icon: const Icon(Icons.send),
                        label: const Text('Publier'),
                      ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
