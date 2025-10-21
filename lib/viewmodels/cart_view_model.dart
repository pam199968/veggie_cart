import 'package:flutter/material.dart';
import '../models/vegetable_model.dart';
import '../models/weekly_offer.dart';
import '../models/order_model.dart';
import '../models/delivery_method.dart';
import '../repositories/order_repository.dart';
import 'account_view_model.dart';
import 'weekly_offers_view_model.dart';

class CartViewModel extends ChangeNotifier {
  final AccountViewModel accountViewModel;
  final WeeklyOffersViewModel weeklyOffersViewModel ;
  final OrderRepository orderRepository;

  WeeklyOffer? _offer;
  final Map<VegetableModel, double> _items = {}; // vegetableId → quantité

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
    return _offer!.vegetables
        .where((v) => _items.containsKey(v))
        .map((v) => v.copyWith(selectedQuantity: _items[v]))
        .toList();
  }

  // Nombre de Légumes dans le panier
  int get totalItems {
    return items.length;
  }


  /// ✅ Créer la commande
  Future<void> submitOrder({
    required DeliveryMethod deliveryMethod,
    String? notes,
  }) async {
    if (_offer == null || _items.isEmpty) return;

    final customerId = accountViewModel.currentUser.id!;
    final offerSummary = WeeklyOfferSummary.fromWeeklyOffer(_offer!);

    // Création de la commande via le repository
    await orderRepository.createOrder(
      customerId: customerId,
      offerSummary: offerSummary,
      deliveryMethod: deliveryMethod,
      items: selectedVegetables,
      notes: notes,
    );

    clearCart();
  }

}
