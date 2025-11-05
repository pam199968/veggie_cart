import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/delivery_method_config.dart';
import '../models/user_model.dart';
import '../models/weekly_offer.dart';
import '../viewmodels/delivery_method_view_model.dart';
import '../viewmodels/my_orders_view_model.dart';
import '../viewmodels/weekly_offers_view_model.dart';
import '../viewmodels/cart_view_model.dart';
import 'package:veggie_cart/extensions/context_extension.dart';

class OffersPageContent extends StatefulWidget {
  final UserModel? user;
  final VoidCallback? onOrderComplete;
  const OffersPageContent({super.key, this.user, this.onOrderComplete});

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
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final offersVm = context.watch<WeeklyOffersViewModel>();
    final orderVm = context.watch<OrderViewModel>();

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
                      builder: (_) =>
                          OfferDetailScreen(offer: offer, user: widget.user),
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
  final UserModel? user;
  const OfferDetailScreen({required this.offer, this.user, super.key});

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
                    MaterialPageRoute(builder: (_) => CartScreen(user: user)),
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
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🥬 Image du légume
                  if (veg.image != null && veg.image!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        veg.image!,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 64,
                          height: 64,
                          color: Colors.grey.shade200,
                        ),
                      ),
                    ),
                  const SizedBox(width: 12),

                  // 🧱 Contenu texte + boutons
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🔹 Ligne 1 : Nom du légume
                        Text(
                          veg.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        // 🔹 Ligne 2 : Prix + conditionnement
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                          child: Text(
                            '${veg.price?.toStringAsFixed(2) ?? "-"} € / ${veg.packaging} '
                            '(cond. ${veg.standardQuantity} ${veg.packaging})',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),

                        // 🔹 Ligne 3 : Quantité + boutons +/- alignés horizontalement
                        Row(
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
                                keyboardType:
                                    const TextInputType.numberWithOptions(
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
                              onPressed: () =>
                                  cartVm.updateQuantity(veg, qty + 1),
                            ),
                          ],
                        ),
                      ],
                    ),
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
                    MaterialPageRoute(builder: (_) => CartScreen(user: user)),
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
  final UserModel? user;
  const CartScreen({super.key, this.user});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _noteController = TextEditingController();
  DeliveryMethodConfig? _selectedDeliveryMethod;

  @override
  void initState() {
    super.initState();
    final deliveryMethodVM = context.read<DeliveryMethodViewModel>();

    // Initialisation avec la méthode de l'utilisateur
    _selectedDeliveryMethod =
        widget.user?.deliveryMethod ??
        (deliveryMethodVM.methods.isNotEmpty
            ? deliveryMethodVM.defaultMethod
            : null);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartVm = context.watch<CartViewModel>();
    final deliveryMethodVM = context.watch<DeliveryMethodViewModel>();

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.myCart)),
      body: SafeArea(
        child: cartVm.items.isEmpty
            ? Center(child: Text(context.l10n.cartEmpty))
            : ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  // Liste des articles dans le panier
                  ...cartVm.items.entries.map((entry) {
                    final veg = entry.key;
                    final qty = entry.value;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 🥬 Image du légume
                            if (veg.image != null && veg.image!.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  veg.image!,
                                  width: 64,
                                  height: 64,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        width: 64,
                                        height: 64,
                                        color: Colors.grey.shade200,
                                      ),
                                ),
                              )
                            else
                              const Icon(Icons.local_florist, size: 48),
                            const SizedBox(width: 12),

                            // 🧱 Contenu texte + boutons
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 🔹 Ligne 1 : Nom du légume
                                  Text(
                                    veg.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  // 🔹 Ligne 2 : Prix + conditionnement
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 4.0,
                                      bottom: 8.0,
                                    ),
                                    child: Text(
                                      '${veg.price?.toStringAsFixed(2) ?? "-"} € / ${veg.packaging} '
                                      '(cond. ${veg.standardQuantity} ${veg.packaging})',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),

                                  // 🔹 Ligne 3 : Quantité + boutons +/- alignés horizontalement
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.remove_circle_outline,
                                        ),
                                        onPressed: qty > 0
                                            ? () => cartVm.updateQuantity(
                                                veg,
                                                (qty - 1).clamp(
                                                  0.0,
                                                  double.infinity,
                                                ),
                                              )
                                            : null,
                                      ),
                                      SizedBox(
                                        width: 60,
                                        child: TextField(
                                          keyboardType:
                                              const TextInputType.numberWithOptions(
                                                decimal: true,
                                              ),
                                          textAlign: TextAlign.center,
                                          controller: TextEditingController(
                                            text: qty.toStringAsFixed(2),
                                          ),
                                          onSubmitted: (value) {
                                            final parsed = double.tryParse(
                                              value,
                                            );
                                            if (parsed != null && parsed >= 0) {
                                              cartVm.updateQuantity(
                                                veg,
                                                parsed,
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.add_circle_outline,
                                        ),
                                        onPressed: () =>
                                            cartVm.updateQuantity(veg, qty + 1),
                                      ),
                                      const SizedBox(width: 8),
                                      // 🔹 Bouton supprimer
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline),
                                        onPressed: () =>
                                            cartVm.updateQuantity(veg, 0),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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
                  if (deliveryMethodVM.loading)
                    const Center(child: CircularProgressIndicator())
                  else if (deliveryMethodVM.error != null)
                    Text("Erreur: ${deliveryMethodVM.error}")
                  else
                    DeliveryMethodDropdown(
                      notifier: ValueNotifier<DeliveryMethodConfig>(
                        _selectedDeliveryMethod!,
                      ),
                      methods: deliveryMethodVM.activeMethods,
                      onChanged: (v) => setState(() {
                        _selectedDeliveryMethod = v;
                      }),
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
                          onPressed:
                              (_selectedDeliveryMethod != null &&
                                  cartVm.totalItems > 0)
                              ? () async {
                                  await cartVm.submitOrder(
                                    user: widget.user,
                                    deliveryMethod: _selectedDeliveryMethod!,
                                    notes: _noteController.text.isNotEmpty
                                        ? _noteController.text
                                        : null,
                                  );

                                  if (!context.mounted) return;

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(context.l10n.orderSent),
                                    ),
                                  );
                                  Navigator.of(
                                    context,
                                  ).popUntil((route) => route.isFirst);
                                }
                              : null,
                          child: Text(context.l10n.validateOrder),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

class DeliveryMethodDropdown extends StatelessWidget {
  final ValueNotifier<DeliveryMethodConfig> notifier;
  final List<DeliveryMethodConfig> methods;
  final ValueChanged<DeliveryMethodConfig> onChanged;

  const DeliveryMethodDropdown({
    super.key,
    required this.notifier,
    required this.methods,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    double fieldWidth = MediaQuery.of(context).size.width * 0.9;
    if (fieldWidth > 300) fieldWidth = 300;

    return ValueListenableBuilder<DeliveryMethodConfig>(
      valueListenable: notifier,
      builder: (context, value, child) {
        return SizedBox(
          width: fieldWidth,
          child: DropdownButtonFormField<DeliveryMethodConfig>(
            isExpanded: true,
            initialValue: value,
            items: methods
                .map((m) => DropdownMenuItem(value: m, child: Text(m.label)))
                .toList(),
            onChanged: (v) {
              if (v != null) {
                notifier.value = v;
                onChanged(v);
              }
            },
            decoration: InputDecoration(
              labelText: context.l10n.deliveryMethod,
              border: const OutlineInputBorder(),
            ),
          ),
        );
      },
    );
  }
}
