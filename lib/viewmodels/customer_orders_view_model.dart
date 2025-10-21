import 'dart:async';
import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../models/order_model_with_customer.dart';
import '../repositories/order_repository.dart';
import '../services/user_service.dart';

class CustomerOrdersViewModel extends ChangeNotifier {
  final OrderRepository orderRepository;
  final UserService userService;

  List<OrderModelWithCustomer> orders = [];
  bool isLoading = false;
  bool hasMore = true;
  OrderModel? _lastOrder;

  // 🔹 Filtre des statuts
  List<OrderStatus>? statusFilter;

  CustomerOrdersViewModel({
    required this.orderRepository,
    required this.userService,
    this.statusFilter,
  });

  /// 🔹 Initialise la liste des commandes
  Future<void> initOrders() async {
    isLoading = true;
    // ⚠️ on ne notifie pas encore, on attend la première frame
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());

    final fetchedOrders = await orderRepository.fetchAllOrders(
      limit: 20,
      startAfter: _lastOrder,
    );

    final List<OrderModelWithCustomer> enriched = [];
    for (var order in fetchedOrders) {
      try {
        final customer = await userService.getUserById(order.customerId);
        enriched.add(OrderModelWithCustomer(order: order, customer: customer));
      } catch (e) {
        enriched.add(OrderModelWithCustomer(order: order, customer: null));
      }
    }

    orders = enriched;
    if (orders.isNotEmpty) _lastOrder = orders.last.order;
    hasMore = fetchedOrders.length >= 20;
    isLoading = false;

    // ⚠️ on notifie après la fin de la frame pour éviter l'erreur
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
  }

  /// 🔹 Chargement des pages suivantes
  Future<void> loadMore() async {
    if (isLoading || !hasMore) return;
    isLoading = true;
    notifyListeners();

    final fetchedOrders = await orderRepository.fetchAllOrders(
      limit: 20,
      startAfter: _lastOrder,
      statuses: statusFilter,
    );

    for (var order in fetchedOrders) {
      final customer = await userService.getUserById(order.customerId);
      orders.add(OrderModelWithCustomer(order: order, customer: customer));
    }

    if (fetchedOrders.length < 20) hasMore = false;
    if (orders.isNotEmpty) _lastOrder = orders.last.order;
    isLoading = false;
    notifyListeners();
  }

  /// 🔹 Mise à jour du statut d'une commande
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    await orderRepository.updateOrderStatus(orderId, newStatus);
    final index = orders.indexWhere((o) => o.order.id == orderId);
    if (index != -1) {
      orders[index] = OrderModelWithCustomer(
        order: orders[index].order.copyWith(status: newStatus),
        customer: orders[index].customer,
      );
      notifyListeners();
    }
  }

  /// 🔹 Met à jour le filtre des statuts et recharge les commandes
  Future<void> setStatusFilter(List<OrderStatus>? statuses) async {
    statusFilter = statuses;
    _lastOrder = null;
    orders.clear();
    hasMore = true;
    await initOrders();
  }
}
