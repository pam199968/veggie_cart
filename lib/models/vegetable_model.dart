/// Enum représentant les catégories de légumes
enum VegetableCategory {
  leaf,   // légumes feuille
  fruit,  // légumes fruits
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
  });

  /// Conversion Map → Objet
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
    );
  }

  /// Conversion Objet → Map
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
    };
  }
}
