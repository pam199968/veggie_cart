import 'package:flutter/material.dart';
import '../models/order_item.dart';
import '../services/dashboard_service.dart';
import '../services/user_service.dart';

class DashboardRepository {
  final DashboardService _service;
  final UserService userService;

  DashboardRepository({
    required DashboardService dashboardService,
    required this.userService,
  }) : _service = dashboardService;

  /// 1️⃣ Nombre total de commandes
  Future<int> getPendingOrdersCount(DateTimeRange range) async {
    final orders = await _service.fetchPendingOrdersForRange(range);
    return orders.length;
  }

  /// 2️⃣ Nombre de commandes livrées/prêtes
  Future<int> getDeliveredOrReadyCount(DateTimeRange range) async {
    final orders = await _service.fetchDeliveredOrdersForRange(range);

    return orders.where((o) {
      final status = o['status'] as String;
      return status == 'delivered' || status == 'ready';
    }).length;
  }

  /// 3️⃣ Quantités vendues par légume
  Future<Map<String, Map<String, dynamic>>> getQuantitiesByVegetable(
    DateTimeRange range,
  ) async {
    final orders = await _service.fetchDeliveredOrdersForRange(range);

    final accumulator = <String, double>{};
    final sampleItem =
        <String, OrderItem>{}; // pour retrouver packaging/standardQuantity

    for (final raw in orders) {
      final items = (raw['items'] as List)
          .map((m) => OrderItem.fromMap(m))
          .toList();

      for (final item in items) {
        accumulator[item.vegetable.name] =
            (accumulator[item.vegetable.name] ?? 0) + item.quantity;

        // garder un item de référence pour retrouver unit/packaging
        sampleItem[item.vegetable.name] ??= item;
      }
    }

    // 🔥 tri + top 10
    final sorted = accumulator.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final top10 = sorted.take(10);

    // 🔹 construire un map riche pour la UI
    final result = <String, Map<String, dynamic>>{};

    for (final entry in top10) {
      final vegetableName = entry.key;
      final totalQty = entry.value;
      final item = sampleItem[vegetableName]!;

      result[vegetableName] = {
        'quantity': totalQty,
        'label': formatQuantityLabel(item, totalQty),
        'packaging': item.vegetable.packaging,
        'standardQuantity': item.vegetable.standardQuantity,
      };
    }

    return result;
  }

  /// 4️⃣ Ventes par client et par légume
  Future<Map<String, Map<String, Map<String, dynamic>>>>
  getSalesByCustomerAndVegetable(DateTimeRange range) async {
    // top 10
    final top10 = await getQuantitiesByVegetable(range);
    final allowedVeg = top10.keys.toSet();

    final orders = await _service.fetchDeliveredOrdersForRange(range);

    final result = <String, Map<String, Map<String, dynamic>>>{};

    for (final raw in orders) {
      final customerId = raw['customerId'] as String;
      final customer = await userService.getUserById(customerId);

      final customerName = customer != null
          ? "${customer.givenName} ${customer.name}".trim()
          : "Client inconnu";

      final items = (raw['items'] as List)
          .map((m) => OrderItem.fromMap(m))
          .toList();

      result.putIfAbsent(customerName, () => {});

      for (final item in items) {
        final vegName = item.vegetable.name;

        if (!allowedVeg.contains(vegName)) continue;

        final previous = result[customerName]![vegName]?['quantity'] ?? 0.0;

        final newQty = previous + item.quantity;

        result[customerName]![vegName] = {
          'quantity': newQty,
          'label': formatQuantityLabel(item, newQty),
        };
      }
    }

    return result;
  }

  String formatQuantityLabel(OrderItem item, double totalQuantity) {
    final std = item.vegetable.standardQuantity;
    final packaging = item.vegetable.packaging;

    if (std == null || std == 0) {
      // Cas sans standardQuantity → fallback simple
      return '${totalQuantity.toStringAsFixed(2)} $packaging';
    }

    return '${totalQuantity.toStringAsFixed(2)} x ${std.toStringAsFixed(2)} $packaging';
  }
}
