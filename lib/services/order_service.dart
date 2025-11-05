import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/order_item.dart';
import '../models/order_model.dart';
import '../models/delivery_method_config.dart';

class OrderService {
  final CollectionReference _ordersRef = FirebaseFirestore.instance.collection('orders');

  CollectionReference get ordersRef => _ordersRef;

  /// 🔹 Flux temps réel paginé par client
  Stream<List<OrderModel>> streamOrdersByCustomer({
    required String customerId,
    int limit = 10,
    DocumentSnapshot? startAfterDoc,
  }) {
    Query query = _ordersRef
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (startAfterDoc != null) {
      query = query.startAfterDocument(startAfterDoc);
    }

    // ⚠️ Stream Firestore → nécessite transformation asynchrone
    return query.snapshots().asyncMap((snapshot) async {
      final orders = await Future.wait(
        snapshot.docs.map((doc) async {
          return await OrderModel.fromMapAsync(doc.data() as Map<String, dynamic>, doc.id);
        }),
      );
      return orders;
    });
  }

  /// 🔹 Pagination par client (sans flux)
  Future<List<OrderModel>> getOrdersByCustomerPaginated({
    required String customerId,
    int limit = 20,
    OrderModel? startAfter,
  }) async {
    Query query = _ordersRef
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (startAfter != null) {
      final doc = await _ordersRef.doc(startAfter.id).get();
      query = query.startAfterDocument(doc);
    }

    final snapshot = await query.get();
    return Future.wait(snapshot.docs.map(
      (doc) => OrderModel.fromMapAsync(doc.data() as Map<String, dynamic>, doc.id),
    ));
  }

  /// 🔹 Récupère une seule page (sans flux)
  Future<List<OrderModel>> fetchOrdersPage({
    required String customerId,
    int limit = 10,
    DocumentSnapshot? startAfterDoc,
  }) async {
    Query query = _ordersRef
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (startAfterDoc != null) {
      query = query.startAfterDocument(startAfterDoc);
    }

    final snapshot = await query.get();
    return Future.wait(snapshot.docs.map(
      (doc) => OrderModel.fromMapAsync(doc.data() as Map<String, dynamic>, doc.id),
    ));
  }

  /// 🔹 Flux temps réel pour toutes les commandes
  Stream<List<OrderModel>> streamAllOrders({
    int limit = 50,
    List<OrderStatus>? statuses,
  }) {
    Query query = _ordersRef.orderBy('createdAt', descending: true);

    if (statuses != null && statuses.isNotEmpty) {
      query = query.where('status', whereIn: statuses.map((s) => s.name).toList());
    }

    query = query.limit(limit);

    return query.snapshots().asyncMap((snapshot) async {
      final orders = await Future.wait(
        snapshot.docs.map((doc) async {
          return await OrderModel.fromMapAsync(doc.data() as Map<String, dynamic>, doc.id);
        }),
      );
      return orders;
    });
  }

  /// 🔹 Pagination toutes commandes
  Future<List<OrderModel>> getAllOrdersPaginated({
    int limit = 20,
    OrderModel? startAfter,
    List<OrderStatus>? statuses,
  }) async {
    try {
      Query query = _ordersRef
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (statuses != null && statuses.isNotEmpty) {
        query = query.where('status', whereIn: statuses.map((s) => s.name).toList());
      }

      if (startAfter != null) {
        final doc = await _ordersRef.doc(startAfter.id).get();
        if (doc.exists) {
          query = query.startAfterDocument(doc);
        }
      }

      final snapshot = await query.get();
      return Future.wait(snapshot.docs.map(
        (doc) => OrderModel.fromMapAsync(doc.data() as Map<String, dynamic>, doc.id),
      ));
    } catch (e, stack) {
      debugPrint("🔥 Firestore error in getAllOrdersPaginated: $e");
      debugPrint(stack.toString());
      rethrow;
    }
  }

  /// 🔹 Mise à jour du statut d'une commande
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    await _ordersRef.doc(orderId).update({
      'status': newStatus.name,
      'updatedAt': DateTime.now(),
    });
  }
}

extension OrderServiceExtension on OrderService {
  /// 🔹 Crée une commande et génère automatiquement un numéro
  Future<OrderModel> createOrder({
    required String customerId,
    required WeeklyOfferSummary offerSummary,
    required DeliveryMethodConfig deliveryMethod,
    OrderStatus status = OrderStatus.pending,
    String? notes,
    required List<OrderItem> items,
  }) async {
    final newOrderRef = _ordersRef.doc();
    final orderNumber = _generateOrderNumber(newOrderRef.id);
    final now = DateTime.now();

    final order = OrderModel(
      id: newOrderRef.id,
      orderNumber: orderNumber,
      customerId: customerId,
      offerSummary: offerSummary,
      deliveryMethod: deliveryMethod,
      status: status,
      notes: notes,
      items: items,
      createdAt: now,
      updatedAt: now,
    );

    await newOrderRef.set(order.toMap());
    return order;
  }

  /// Génération du numéro de commande lisible
  String _generateOrderNumber(String firestoreId) {
    final datePart = DateTime.now().toIso8601String().split('T')[0].replaceAll('-', '');
    final idPart = firestoreId.substring(firestoreId.length - 4).toUpperCase();
    return 'CMD-$datePart-$idPart';
  }
}
