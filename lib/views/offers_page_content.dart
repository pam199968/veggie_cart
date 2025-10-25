import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/delivery_method.dart';
import '../models/weekly_offer.dart';
import '../viewmodels/account_view_model.dart';
import '../viewmodels/my_orders_view_model.dart';
import '../viewmodels/weekly_offers_view_model.dart';
import '../viewmodels/cart_view_model.dart';
import 'package:veggie_cart/extensions/context_extension.dart';

class OffersPageContent extends StatefulWidget {
  const OffersPageContent({super.key});

  @override
  State<OffersPageContent> createState() => _OffersPageContentState();
}

class _OffersPageContentState extends State<OffersPageContent> {
  @override
  void initState() {
    super.initState();
    // 🔹 Appeler loadOffers après le premier frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final vm = context.read<WeeklyOffersViewModel>();
        vm.setOfferFilter(OfferFilter.published); // <-- on définit le filtre
        vm.loadOffers(); // recharge les offres avec ce filtre
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final offersVm = context.watch<WeeklyOffersViewModel>();
    final orderVm = context.watch<OrderViewModel>(); // 👈 renommé pour clarté

    if (offersVm.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (offersVm.offers.isEmpty) {
      return Center(child: Text(context.l10n.noOffersAvailable));
    }

    return ListView.builder(
      itemCount: offersVm.offers.length,
      itemBuilder: (context, index) {
        final offer = offersVm.offers[index];
        final hasOrder = orderVm.hasActiveOrderForOffer(offer.id!);

        return Card(
          margin: const EdgeInsets.all(8),
          child: Stack(
            children: [
              // 🧱 Contenu principal
              ListTile(
                title: Text(
                  offer.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(offer.description),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  final cartVm = context.read<CartViewModel>();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    cartVm.setOffer(offer);
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OfferDetailScreen(offer: offer),
                    ),
                  );
                },
              ),

              // ✅ Indicateur si une commande existe déjà
              if (hasOrder)
                Positioned(
                  top: 8,
                  right: 72,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade600,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.receipt_long, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text(
                          context.l10n.orderInProgress,
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
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

      // ✅ Contenu principal
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: offer.vegetables.map((veg) {
          final qty = cartVm.items[veg] ?? 0;
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              title: Text(
                '${veg.name} : ${veg.price?.toStringAsFixed(2) ?? "-"} € / ${veg.packaging}',
              ),
              subtitle: Text(
                '(cond. par ${veg.standardQuantity} ${veg.packaging})',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: qty > 0
                        ? () => cartVm.updateQuantity(
                            veg,
                            (qty - 1).clamp(0.0, double.infinity),
                          )
                        : null,
                  ),
                  SizedBox(
                    width: 60,
                    child: TextField(
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textAlign: TextAlign.center,
                      controller: TextEditingController(
                        text: qty.toStringAsFixed(2),
                      ),
                      onSubmitted: (value) {
                        final parsed = double.tryParse(value);
                        if (parsed != null && parsed >= 0) {
                          cartVm.updateQuantity(veg, parsed);
                        }
                      },
                    ),
                  ),
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

      // ✅ Bouton "Finaliser la commande" en bas de l’écran
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(12), // marge autour du bouton
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.check_circle_outline, color: Colors.white),
          label: Text(
            '${context.l10n.finalizeOrder} (${cartVm.totalItems.toString()})',
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
          onPressed: cartVm.totalItems > 0
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  );
                }
              : null,
        ),
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
  late DeliveryMethod _selectedDeliveryMethod;

  @override
  void initState() {
    super.initState();
    final accountVm = context.read<AccountViewModel>();
    _selectedDeliveryMethod = accountVm.currentUser.deliveryMethod;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartVm = context.watch<CartViewModel>();

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.myCart)),
      body: cartVm.items.isEmpty
          ? Center(child: Text(context.l10n.cartEmpty))
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
                          ? Image.network(
                              veg.image!,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.local_florist, size: 40),
                      title: Text(veg.name),
                      subtitle: Text(
                        '${veg.price?.toStringAsFixed(2) ?? "-"} € / ${veg.standardQuantity} ${veg.packaging}',
                      ),
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
                            onPressed: qty > 0
                                ? () => cartVm.updateQuantity(veg, qty - 1)
                                : null,
                          ),
                          // Afficher la quantité
                          Text(qty.toString()),
                          // Augmenter la quantité
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () =>
                                cartVm.updateQuantity(veg, qty + 1),
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
                  decoration: InputDecoration(
                    labelText: context.l10n.addNote,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // 🚚 Sélection de la méthode de livraison
                DropdownButtonFormField<DeliveryMethod>(
                  initialValue: _selectedDeliveryMethod,
                  decoration: InputDecoration(
                    labelText: context.l10n.deliveryMethod,
                    border: const OutlineInputBorder(),
                  ),
                  items: DeliveryMethod.values.map((method) {
                    return DropdownMenuItem<DeliveryMethod>(
                      value: method,
                      child: Text(method.label),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedDeliveryMethod = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                // Boutons retour et valider
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        child: Text(context.l10n.backToOffer),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        child: Text(context.l10n.validateOrder),
                        onPressed: () async {
                          final deliveryMethod = _selectedDeliveryMethod;

                          await cartVm.submitOrder(
                            deliveryMethod: deliveryMethod,
                            notes: _noteController.text.isNotEmpty
                                ? _noteController.text
                                : null,
                          );

                          // 🔹 Vérifier mounted APRÈS l'opération async
                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(context.l10n.orderSent)),
                          );

                          Navigator.of(context).popUntil(
                            (route) => route.isFirst,
                          ); // retour à la liste des offres
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
