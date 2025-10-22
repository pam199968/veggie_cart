import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/delivery_method.dart';
import '../models/order_item.dart';
import '../models/order_model.dart';
import 'package:flutter/foundation.dart';


class OrderService {
  final CollectionReference _ordersRef = FirebaseFirestore.instance.collection(
    'orders',
  );

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

    return query.snapshots().map(
      (snapshot) => snapshot.docs
          .map(
            (doc) =>
                OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList(),
    );
  }

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
    return snapshot.docs
        .map(
          (doc) =>
              OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id),
        )
        .toList();
  }

  /// 🔹 Récupère une seule page (sans flux) pour le scroll infini
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
    return snapshot.docs
        .map(
          (doc) =>
              OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id),
        )
        .toList();
  }

  /// 🔹 Flux temps réel pour **toutes les commandes**
  Stream<List<OrderModel>> streamAllOrders({
    int limit = 50,
    List<OrderStatus>? statuses, // 🔹 nouveau paramètre optionnel
  }) {
    Query query = _ordersRef.orderBy('createdAt', descending: true);

    // 🔹 Filtre sur les statuts
    if (statuses != null && statuses.isNotEmpty) {
      final statusStrings = statuses.map((s) => s.name).toList();
      query = query.where('status', whereIn: statusStrings);
    }

    // 🔹 Limite de documents
    query = query.limit(limit);

    return query.snapshots().map(
      (snapshot) => snapshot.docs
          .map(
            (doc) =>
                OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList(),
    );
  }

  /// 🔹 Pagination pour toutes les commandes
  Future<List<OrderModel>> getAllOrdersPaginated({
    int limit = 20,
    OrderModel? startAfter,
    List<OrderStatus>? statuses, // 🔹 liste d'états à filtrer
  }) async {
    try {
      Query query = _ordersRef
          .orderBy('createdAt', descending: true)
          .limit(limit);

      // 🔹 Filtre sur les statuts si fournis
      if (statuses != null && statuses.isNotEmpty) {
        // Firestore Web ne supporte que whereIn <= 10 éléments
        query = query.where(
          'status',
          whereIn: statuses.map((s) => s.name).toList(),
        );
      }

      if (startAfter != null) {
        final doc = await _ordersRef.doc(startAfter.id).get();
        if (doc.exists) {
          query = query.startAfterDocument(doc);
        }
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map(
            (doc) =>
                OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    } catch (e, stack) {
      debugPrint("🔥 Firestore error in getAllOrdersPaginated: $e");
      debugPrint(stack.toString());
      rethrow; // 👉 pour propager l’erreur si nécessaire
    }
  }

  /// 🔹 Mise à jour du statut d'une commande
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    await _ordersRef.doc(orderId).update({
      'status': newStatus
          .name, // Assurez-vous que OrderModel.fromMap peut parser le string
      'updatedAt': DateTime.now(),
    });
  }
}

extension OrderServiceExtension on OrderService {
  /// Crée une commande et génère automatiquement orderNumber à partir de l'ID Firestore
  Future<OrderModel> createOrder({
    required String customerId,
    required WeeklyOfferSummary offerSummary,
    required DeliveryMethod deliveryMethod,
    OrderStatus status = OrderStatus.pending,
    String? notes,
    required List<OrderItem> items, // 🔹 changé de VegetableModel à OrderItem
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
      items: items, // 🔹 on passe directement la liste d'OrderItem
      createdAt: now,
      updatedAt: now,
    );

    await newOrderRef.set(order.toMap());

    return order;
  }

  /// Génération du numéro de commande lisible
  String _generateOrderNumber(String firestoreId) {
    final datePart = DateTime.now()
        .toIso8601String()
        .split('T')[0]
        .replaceAll('-', '');
    final idPart = firestoreId.substring(firestoreId.length - 4).toUpperCase();
    return 'CMD-$datePart-$idPart';
  }
}
