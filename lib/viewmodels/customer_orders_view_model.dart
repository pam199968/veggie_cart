// Copyright (c) 2025 Patrick Mortas
// All rights reserved.

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

  // 🔹 Filtres
  List<OrderStatus>? statusFilter;
  String? offerFilterId; // 👈 nouveau filtre sur l'offre

  CustomerOrdersViewModel({
    required this.orderRepository,
    required this.userService,
    this.statusFilter,
  });

  /// 🔹 Initialise la liste des commandes (avec filtres)
  Future<void> initOrders() async {
    isLoading = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());

    // 🔹 Récupération brute
    final fetchedOrders = await orderRepository.fetchAllOrders(
      limit: 20,
      startAfter: _lastOrder,
      statuses: statusFilter,
    );

    // 🔹 Application du filtre sur l'offre si présent
    final filteredOrders = offerFilterId == null
        ? fetchedOrders
        : fetchedOrders
            .where((o) => o.offerSummary.id == offerFilterId)
            .toList();

    // 🔹 Enrichissement avec le client
    final List<OrderModelWithCustomer> enriched = [];
    for (var order in filteredOrders) {
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
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
  }

  /// 🔹 Chargement des pages suivantes (pagination)
  Future<void> loadMore() async {
    if (isLoading || !hasMore) return;
    isLoading = true;
    notifyListeners();

    final fetchedOrders = await orderRepository.fetchAllOrders(
      limit: 20,
      startAfter: _lastOrder,
      statuses: statusFilter,
    );

    // 🔹 Application du filtre sur l'offre
    final filteredOrders = offerFilterId == null
        ? fetchedOrders
        : fetchedOrders
            .where((o) => o.offerSummary.id == offerFilterId)
            .toList();

    for (var order in filteredOrders) {
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

  /// 🔹 Met à jour le filtre des statuts
  Future<void> setStatusFilter(List<OrderStatus>? statuses) async {
    statusFilter = statuses;
    _lastOrder = null;
    orders.clear();
    hasMore = true;
    await initOrders();
  }

  /// 🔹 Met à jour le filtre sur l'offre
  Future<void> setOfferFilter(String? offerId) async {
    offerFilterId = offerId;
    _lastOrder = null;
    orders.clear();
    hasMore = true;
    await initOrders();
  }
}
