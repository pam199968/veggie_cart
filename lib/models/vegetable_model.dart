/// Enum représentant les catégories de légumes
enum VegetableCategory {
  leaf,   // légumes feuille
  fruit,  // légumes fruit
  root,   // légumes racine
  other,  // fruits ou autres
}

extension VegetableCategoryExtension on VegetableCategory {
  String get label {
    switch (this) {
      case VegetableCategory.leaf:
        return 'Légumes feuille';
      case VegetableCategory.fruit:
        return 'Légumes fruit';
      case VegetableCategory.root:
        return 'Légumes racine';
      case VegetableCategory.other:
        return 'Autres';
    }
  }

  static VegetableCategory fromString(String value) {
    switch (value) {
      case 'leaf':
        return VegetableCategory.leaf;
      case 'fruit':
        return VegetableCategory.fruit;
      case 'root':
        return VegetableCategory.root;
      case 'other':
      default:
        return VegetableCategory.other;
    }
  }
}

class VegetableModel {
  final String id;
  final String name;
  final VegetableCategory category;
  final String? description;
  final String packaging; // ex : "kg", "unité"
  final double? standardQuantity;
  final double? price;
  final bool active;
  final String? image;

  /// Quantité sélectionnée par l'utilisateur (non persistée dans Firestore)
  final double? selectedQuantity;

  VegetableModel({
    required this.id,
    required this.name,
    required this.category,
    this.description,
    required this.packaging,
    this.standardQuantity,
    this.price,
    this.active = true,
    this.image,
    this.selectedQuantity,
  });

  /// Conversion Map → Objet (sans selectedQuantity)
  factory VegetableModel.fromMap(Map<String, dynamic> map, String documentId) {
    return VegetableModel(
      id: documentId,
      name: map['name'] ?? '',
      category: VegetableCategoryExtension.fromString(map['category'] ?? 'other'),
      description: map['description'],
      packaging: map['packaging'] ?? '',
      standardQuantity: (map['standardQuantity'] as num?)?.toDouble(),
      price: (map['price'] as num?)?.toDouble(),
      active: map['active'] ?? true,
      image: map['image'],
      selectedQuantity: null, // toujours nul à la lecture Firestore
    );
  }

  /// Conversion Objet → Map (sans selectedQuantity)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category.name,
      'description': description,
      'packaging': packaging,
      'standardQuantity': standardQuantity,
      'price': price,
      'active': active,
      'image': image,
      // ⚠️ on n’inclut PAS selectedQuantity
    };
  }

  /// copyWith pour cloner l'objet avec champs modifiés
  VegetableModel copyWith({
    String? id,
    String? name,
    VegetableCategory? category,
    String? description,
    String? packaging,
    double? standardQuantity,
    double? price,
    bool? active,
    String? image,
    double? selectedQuantity,
  }) {
    return VegetableModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      packaging: packaging ?? this.packaging,
      standardQuantity: standardQuantity ?? this.standardQuantity,
      price: price ?? this.price,
      active: active ?? this.active,
      image: image ?? this.image,
      selectedQuantity: selectedQuantity ?? this.selectedQuantity,
    );
  }

  /// 🔹 Représentation lisible pour les aperçus
  @override
  String toString() {
    final quantity =
        standardQuantity != null ? '${standardQuantity!.toStringAsFixed(0)} $packaging' : packaging;
    final formattedPrice = price != null ? '${price!.toStringAsFixed(2)}€' : '-';
    final selection = selectedQuantity != null ? ' | Sélection: ${selectedQuantity!.toStringAsFixed(2)} $packaging' : '';
    return '$name ($quantity, $formattedPrice)$selection';
  }
}
