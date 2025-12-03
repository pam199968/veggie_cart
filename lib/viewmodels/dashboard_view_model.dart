import 'package:flutter/material.dart';
import '../repositories/dashboard_repository.dart';

class DashboardViewModel extends ChangeNotifier {
  final DashboardRepository repository;

  DashboardViewModel({required this.repository});

  int pendingOrders = 0;
  int deliveredOrReady = 0;
  Map<String, Map<String, dynamic>> quantitiesByVeg = {};
  Map<String, Map<String, Map<String, dynamic>>> salesByCustomerVeg = {};

  bool loading = false;

  Future<void> loadDashboard(DateTimeRange range) async {
    loading = true;
    notifyListeners();

    pendingOrders = await repository.getPendingOrdersCount(range);
    deliveredOrReady = await repository.getDeliveredOrReadyCount(range);
    quantitiesByVeg = await repository.getQuantitiesByVegetable(range);
    salesByCustomerVeg = await repository.getSalesByCustomerAndVegetable(range);

    loading = false;
    notifyListeners();
  }
}
