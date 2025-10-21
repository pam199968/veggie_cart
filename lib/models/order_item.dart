import 'vegetable_model.dart';

class OrderItem {
  final VegetableModel vegetable;
  final double quantity;

  OrderItem({
    required this.vegetable,
    this.quantity = 1.0,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      vegetable: VegetableModel.fromMap(
        Map<String, dynamic>.from(map['vegetable']), 
        map['vegetable']['id'] ?? '',
      ),
      quantity: (map['quantity'] as num?)?.toDouble() ?? 1.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vegetable': vegetable.toMap(),
      'quantity': quantity,
    };
  }

  OrderItem copyWith({VegetableModel? vegetable, double? quantity}) {
    return OrderItem(
      vegetable: vegetable ?? this.vegetable,
      quantity: quantity ?? this.quantity,
    );
  }
}
