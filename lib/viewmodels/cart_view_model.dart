import 'package:flutter/material.dart';
import 'package:veggie_cart/models/delivery_method_config.dart';

import '../models/order_item.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';
import '../models/vegetable_model.dart';
import '../models/weekly_offer.dart';
import '../repositories/order_repository.dart';
import 'account_view_model.dart';
import 'weekly_offers_view_model.dart';

class CartViewModel extends ChangeNotifier {
  final AccountViewModel accountViewModel;
  final WeeklyOffersViewModel weeklyOffersViewModel;
  final OrderRepository orderRepository;

  WeeklyOffer? _offer;
  final Map<VegetableModel, double> _items = {}; // vegetable → quantité

  CartViewModel({
    required this.accountViewModel,
    required this.weeklyOffersViewModel,
    required this.orderRepository,
  });

  WeeklyOffer? get offer => _offer;
  Map<VegetableModel, double> get items => Map.unmodifiable(_items);

  /// 🧺 Associer une offre au panier
  void setOffer(WeeklyOffer offer) {
    _offer = offer;
    _items.clear();
    notifyListeners();
  }

  /// ➕ Ajouter ou modifier une quantité
  void updateQuantity(VegetableModel vegetable, double quantity) {
    if (quantity <= 0) {
      _items.remove(vegetable);
    } else {
      _items[vegetable] = quantity;
    }
    notifyListeners();
  }

  /// 🗑️ Vider le panier
  void clearCart() {
    _items.clear();
    _offer = null;
    notifyListeners();
  }

  /// 🔸 Légumes sélectionnés avec leurs quantités locales
  List<VegetableModel> get selectedVegetables {
    if (_offer == null) return [];

    // On ne renvoie que les légumes présents dans le panier
    return _offer!.vegetables
        .where((v) => _items.containsKey(v))
        .map((v) {
          // Copier le modèle avec la quantité sélectionnée
          return v.copyWith(selectedQuantity: _items[v]);
        })
        .toList();
  }

  /// 🔸 Transforme le panier en liste d'OrderItem
  List<OrderItem> get orderItems {
    return _items.entries
        .map((e) => OrderItem(vegetable: e.key, quantity: e.value))
        .toList();
  }

  // Nombre de Légumes dans le panier
  int get totalItems {
    return _items.length;
  }

  /// ✅ Créer la commande
  Future<void> submitOrder({
    UserModel? user,
    required DeliveryMethodConfig deliveryMethod,
    String? notes,
  }) async {
    if (_offer == null || _items.isEmpty) return;

  final customerId = user == null
        ? accountViewModel.currentUser.id!
        : user.id!;
    final offerSummary = WeeklyOfferSummary.fromWeeklyOffer(_offer!);

    // Création de la commande via le repository
    await orderRepository.createOrder(
      customerId: customerId,
      offerSummary: offerSummary,
      deliveryMethod: deliveryMethod,
      items: orderItems, // 🔹 utilise la liste d'OrderItem
      notes: notes,
    );

    clearCart();
  }
}
