import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/weekly_offer.dart';
import '../models/delivery_method.dart';
<<<<<<< HEAD
=======
import '../models/vegetable_model.dart';
>>>>>>> 172df15 (order model added)

enum OrderStatus {
  pending,
  confirmed,
  ready,
  delivered,
  cancelled,
}

extension OrderStatusExtension on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending:
        return "En attente";
      case OrderStatus.confirmed:
        return "Confirmée";
      case OrderStatus.ready:
        return "Prête";
      case OrderStatus.delivered:
        return "Livrée";
      case OrderStatus.cancelled:
        return "Annulée";
    }
  }

  static OrderStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case "confirmée":
      case "confirmed":
        return OrderStatus.confirmed;
      case "prête":
      case "ready":
        return OrderStatus.ready;
      case "livrée":
      case "delivered":
        return OrderStatus.delivered;
      case "annulée":
      case "cancelled":
        return OrderStatus.cancelled;
      case "en attente":
      case "pending":
      default:
        return OrderStatus.pending;
    }
  }
}

class OrderModel {
  final String id;
  final String customerId;
  final WeeklyOffer offer;
  final DeliveryMethod deliveryMethod;
  final OrderStatus status;
  final String? notes;
<<<<<<< HEAD
  final List<Map<String, dynamic>> items;
=======
  final List<VegetableModel> items;
>>>>>>> 172df15 (order model added)
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderModel({
    required this.id,
    required this.customerId,
    required this.offer,
    required this.deliveryMethod,
    this.status = OrderStatus.pending,
    this.notes,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

<<<<<<< HEAD
  /// 🔹 Conversion depuis une Map Firestore → Order
=======
  /// 🔹 Conversion Map → Order
>>>>>>> 172df15 (order model added)
  factory OrderModel.fromMap(Map<String, dynamic> map, String documentId) {
    return OrderModel(
      id: documentId,
      customerId: map['customerId'] ?? '',
<<<<<<< HEAD
      // 🔸 Passe l'ID du document de commande à WeeklyOffer.fromMap()
      offer: WeeklyOffer.fromMap(
        Map<String, dynamic>.from(map['offer'] ?? {}),
        documentId,
=======
      offer: WeeklyOffer.fromMap(
        Map<String, dynamic>.from(map['offer'] ?? {}),
        map['offer']['id'] ?? '', // ou documentId si tu veux utiliser l'ID du parent
>>>>>>> 172df15 (order model added)
      ),
      deliveryMethod: DeliveryMethodExtension.fromString(
        map['deliveryMethod'] ?? "Retrait à la ferme",
      ),
      status: OrderStatusExtension.fromString(map['status'] ?? 'pending'),
      notes: map['notes'],
<<<<<<< HEAD
      items: List<Map<String, dynamic>>.from(map['items'] ?? []),
      createdAt: (map['createdAt'] is Timestamp)
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
              DateTime.now(),
      updatedAt: (map['updatedAt'] is Timestamp)
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['updatedAt']?.toString() ?? '') ??
              DateTime.now(),
    );
  }

  /// 🔹 Conversion vers une Map Firestore
=======
      items: (map['items'] as List<dynamic>? ?? [])
          .map((item) =>
              VegetableModel.fromMap(Map<String, dynamic>.from(item), item['id'] ?? ''))
          .toList(),
      createdAt: (map['createdAt'] is Timestamp)
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: (map['updatedAt'] is Timestamp)
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  /// 🔹 Conversion Order → Map
>>>>>>> 172df15 (order model added)
  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'offer': offer.toMap(),
      'deliveryMethod': deliveryMethod.label,
      'status': status.name,
      'notes': notes,
<<<<<<< HEAD
      'items': items,
=======
      'items': items.map((v) => v.toMap()).toList(),
>>>>>>> 172df15 (order model added)
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  OrderModel copyWith({
    String? id,
    String? customerId,
    WeeklyOffer? offer,
    DeliveryMethod? deliveryMethod,
    OrderStatus? status,
    String? notes,
<<<<<<< HEAD
    List<Map<String, dynamic>>? items,
=======
    List<VegetableModel>? items,
>>>>>>> 172df15 (order model added)
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      offer: offer ?? this.offer,
      deliveryMethod: deliveryMethod ?? this.deliveryMethod,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
