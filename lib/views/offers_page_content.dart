import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/weekly_offer.dart';
import '../viewmodels/account_view_model.dart';
import '../viewmodels/weekly_offers_view_model.dart';
import '../viewmodels/cart_view_model.dart';

class OffersPageContent extends StatelessWidget {
  const OffersPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    final offersVm = context.watch<WeeklyOffersViewModel>();
    final cartVm = context.watch<CartViewModel>();

    if (offersVm.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (offersVm.offers.isEmpty) {
      return const Center(
        child: Text("Aucune offre disponible pour le moment."),
      );
    }

    // Affiche la liste des offres publiées
    return ListView.builder(
      itemCount: offersVm.offers.length,
      itemBuilder: (context, index) {
        final offer = offersVm.offers[index];
        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            title: Text(
              offer.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(offer.description),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OfferDetailScreen(offer: offer),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// 🔹 Écran pour sélectionner les articles et ajouter au panier
class OfferDetailScreen extends StatelessWidget {
  final WeeklyOffer offer;
  const OfferDetailScreen({required this.offer, super.key});

  @override
  Widget build(BuildContext context) {
    final cartVm = context.watch<CartViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(offer.title),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  );
                },
              ),
              if (cartVm.totalItems > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: Colors.red,
                    child: Text(
                      cartVm.totalItems.toString(),
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: offer.vegetables.map((veg) {
          final qty = cartVm.items[veg] ?? 0;
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              title: Text(veg.name),
              subtitle: Text('${veg.price?.toStringAsFixed(2) ?? "-"} € / ${veg.packaging}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: qty > 0 ? () => cartVm.updateQuantity(veg, qty - 1) : null,
                  ),
                  Text(qty.toString()),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () => cartVm.updateQuantity(veg, qty + 1),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// 🔹 Écran du panier : modifier quantités, supprimer articles, ajouter note et valider

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartVm = context.watch<CartViewModel>();
    final accountVm = context.read<AccountViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Mon panier')),
      body: cartVm.items.isEmpty
          ? const Center(child: Text('Votre panier est vide'))
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                // Liste des articles dans le panier
                ...cartVm.items.entries.map((entry) {
                  final veg = entry.key; // VegetableModel
                  final qty = entry.value;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: veg.image != null
                          ? Image.network(veg.image!, width: 48, height: 48, fit: BoxFit.cover)
                          : const Icon(Icons.local_florist, size: 40),
                      title: Text(veg.name),
                      subtitle: Text('${veg.price?.toStringAsFixed(2) ?? "-"} € / ${veg.packaging}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Supprimer l'article
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => cartVm.updateQuantity(veg, 0),
                          ),
                          // Diminuer la quantité
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: qty > 0 ? () => cartVm.updateQuantity(veg, qty - 1) : null,
                          ),
                          // Afficher la quantité
                          Text(qty.toString()),
                          // Augmenter la quantité
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () => cartVm.updateQuantity(veg, qty + 1),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 12),
                // Note
                TextField(
                  controller: _noteController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Ajouter une note',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                // Boutons retour et valider
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        child: const Text('Retour à l\'offre'),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        child: const Text('Valider ma commande'),
                        onPressed: () async {
                          final deliveryMethod = accountVm.currentUser.deliveryMethod;

                          await cartVm.submitOrder(
                            deliveryMethod: deliveryMethod,
                            notes: _noteController.text.isNotEmpty ? _noteController.text : null,
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Commande envoyée !')),
                          );

                          Navigator.pop(context); // retour à la liste des offres
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
