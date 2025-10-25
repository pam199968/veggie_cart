import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/weekly_offer.dart';
import '../models/delivery_method.dart';
import 'order_item.dart';

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
      case "confirmed":
        return OrderStatus.confirmed;
      case "ready":
        return OrderStatus.ready;
      case "delivered":
        return OrderStatus.delivered;
      case "cancelled":
        return OrderStatus.cancelled;
      case "pending":
      default:
        return OrderStatus.pending;
    }
  }
}

/// 🔹 Version allégée de WeeklyOffer pour OrderModel
class WeeklyOfferSummary {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final WeeklyOfferStatus status;

  WeeklyOfferSummary({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  factory WeeklyOfferSummary.fromWeeklyOffer(WeeklyOffer offer) {
  assert(offer.id != null && offer.id!.isNotEmpty,
      'WeeklyOffer must have a valid id before being used in an order.');

  return WeeklyOfferSummary(
    id: offer.id!,
    title: offer.title,
    description: offer.description,
    startDate: offer.startDate,
    endDate: offer.endDate,
    status: offer.status,
  );
}


  factory WeeklyOfferSummary.fromMap(Map<String, dynamic> map) {
    return WeeklyOfferSummary(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      status: WeeklyOfferStatusExtension.fromString(map['status'] ?? 'draft'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'status': status.name,
    };
  }
}

class OrderModel {
  final String id;
  final String orderNumber;
  final String customerId;
  final WeeklyOfferSummary offerSummary;
  final DeliveryMethod deliveryMethod;
  final OrderStatus status;
  final String? notes;
  final List<OrderItem> items;

  final DateTime createdAt;
  final DateTime updatedAt;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    required this.offerSummary,
    required this.deliveryMethod,
    this.status = OrderStatus.pending,
    this.notes,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String documentId) {
  final offerMap = Map<String, dynamic>.from(map['offer'] ?? {});
  return OrderModel(
    id: documentId,
    orderNumber: map['orderNumber'] ?? '', // sera rempli par le service
    customerId: map['customerId'] ?? '',
    offerSummary: WeeklyOfferSummary.fromMap(offerMap), 
    deliveryMethod: DeliveryMethodExtension.fromString(
      map['deliveryMethod'] ?? 'farmPickup',
    ),
    status: OrderStatusExtension.fromString(map['status'] ?? 'pending'),
    notes: map['notes'],
    items: (map['items'] as List<dynamic>? ?? [])
    .map((item) => OrderItem.fromMap(Map<String, dynamic>.from(item)))
    .toList(),

    createdAt: (map['createdAt'] as Timestamp).toDate(),
    updatedAt: (map['updatedAt'] as Timestamp).toDate(),
  );
}

Map<String, dynamic> toMap() {
  return {
    'customerId': customerId,
    'orderNumber': orderNumber,
    'offer': offerSummary.toMap(), // 🔹 juste le résumé
    'deliveryMethod': deliveryMethod.name,
    'status': status.name,
    'notes': notes,
    'items': items.map((i) => i.toMap()).toList(),
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };
}


  OrderModel copyWith({
    String? id,
    String? orderNumber,
    String? customerId,
    WeeklyOfferSummary? offerSummary,
    DeliveryMethod? deliveryMethod,
    OrderStatus? status,
    String? notes,
    List<OrderItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      customerId: customerId ?? this.customerId,
      offerSummary: offerSummary ?? this.offerSummary,
      deliveryMethod: deliveryMethod ?? this.deliveryMethod,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
