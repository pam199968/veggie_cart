import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/weekly_offer.dart';
import '../models/delivery_method.dart';
import '../models/vegetable_model.dart';

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
  final List<VegetableModel> items;
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

  /// 🔹 Conversion Map → Order
  factory OrderModel.fromMap(Map<String, dynamic> map, String documentId) {
    return OrderModel(
      id: documentId,
      customerId: map['customerId'] ?? '',
      offer: WeeklyOffer.fromMap(
        Map<String, dynamic>.from(map['offer'] ?? {}),
        map['offer']['id'] ?? '', // ou documentId si tu veux utiliser l'ID du parent
      ),
      deliveryMethod: DeliveryMethodExtension.fromString(
        map['deliveryMethod'] ?? "Retrait à la ferme",
      ),
      status: OrderStatusExtension.fromString(map['status'] ?? 'pending'),
      notes: map['notes'],
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
  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'offer': offer.toMap(),
      'deliveryMethod': deliveryMethod.label,
      'status': status.name,
      'notes': notes,
      'items': items.map((v) => v.toMap()).toList(),
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
    List<VegetableModel>? items,
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
