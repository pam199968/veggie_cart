import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DashboardService {
  final CollectionReference _ordersRef =
      FirebaseFirestore.instance.collection('orders');

  DashboardService();

  /// 🔹 Récupère les commandes d’une période avec uniquement les champs utiles
  Future<List<Map<String, dynamic>>> fetchDeliveredOrdersForRange(DateTimeRange range) async {
    final snapshot = await _ordersRef
        .where('createdAt', isGreaterThanOrEqualTo: range.start)
        .where('createdAt', isLessThanOrEqualTo: range.end)
        .where('status', isEqualTo: 'delivered')
        .get();

    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

    Future<List<Map<String, dynamic>>> fetchPendingOrdersForRange(DateTimeRange range) async {
    final snapshot = await _ordersRef
        .where('createdAt', isGreaterThanOrEqualTo: range.start)
        .where('createdAt', isLessThanOrEqualTo: range.end)
        .where('status', isEqualTo: 'pending')
        .get();

    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }
}
