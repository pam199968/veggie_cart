import 'dart:async';

import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../repositories/order_repository.dart';
import 'account_view_model.dart';

class OrderViewModel extends ChangeNotifier {
  final AccountViewModel accountViewModel;
  final OrderRepository repository;

  List<OrderModel> orders = [];
  bool isLoading = false;
  bool hasMore = true;
  final int pageSize = 20;

  OrderModel? _lastOrder;
  StreamSubscription<List<OrderModel>>? _subscription;

  OrderViewModel({required this.accountViewModel, required this.repository});

  /// 🔹 Initialisation du flux temps réel
  void initOrders() {
    if (!accountViewModel.isAuthenticated) return;

    _subscription?.cancel();
    _subscription = repository
        .streamOrdersForCustomer(accountViewModel.currentUser.id!)
        .listen((fetchedOrders) {
          orders = fetchedOrders;
          if (orders.isNotEmpty) _lastOrder = orders.last;
          hasMore = fetchedOrders.length >= pageSize;
          notifyListeners();
        });
  }

  /// 🔹 Pagination au scroll
  Future<void> loadMore() async {
    if (isLoading || !hasMore) return;

    isLoading = true;
    notifyListeners();

    final fetched = await repository.fetchOrdersForCustomer(
      customerId: accountViewModel.currentUser.id!,
      limit: pageSize,
      startAfter: _lastOrder,
    );

    orders.addAll(fetched);
    if (fetched.length < pageSize) hasMore = false;
    if (orders.isNotEmpty) _lastOrder = orders.last;

    isLoading = false;
    notifyListeners();
  }

  /// 🔹 Vérifie si une commande (non annulée) existe déjà pour une offre donnée
  bool hasActiveOrderForOffer(String offerId) {
    return orders.any((order) {
      final isSameOffer = order.offerSummary.id == offerId;
      final isNotCancelled = order.status != OrderStatus.cancelled;
      return isSameOffer && isNotCancelled;
    });
  }

  /// 🔹 Annuler une commande (changer le statut vers cancelled)
  Future<void> cancelOrder(String orderId) async {
    await repository.updateOrderStatus(orderId, OrderStatus.cancelled);
  }

  /// 🔹 Flux temps réel des commandes
  Stream<List<OrderModel>> watchOrders() {
    return repository.streamOrdersForCustomer(accountViewModel.currentUser.id!);
  }

  /// 🔹 Annulation des streams lors de la déconnexion
  void cancelSubscriptions() {
    _subscription?.cancel();
    _subscription = null;
  }
}
