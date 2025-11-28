// Copyright (c) 2025 Patrick Mortas
// All rights reserved.

class DeliveryMethodConfig {
  final String key; // ex: "farmPickup"
  final String label; // ex: "Retrait à la ferme"
  final bool enabled; // optionnel : permet d'en activer/désactiver certaines
  final bool isDefault;

  DeliveryMethodConfig({
    required this.key,
    required this.label,
    this.enabled = true,
    this.isDefault = false,
  });

  factory DeliveryMethodConfig.fromFirestore(Map<String, dynamic> data) {
    return DeliveryMethodConfig(
      key: data['key'] as String,
      label: data['label'] as String,
      enabled: data['enabled'] ?? true,
      isDefault: data['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'label': label,
      'enabled': enabled,
      'isDefault': isDefault
    };
  }

  /// 🔹 Crée une copie avec des modifications optionnelles
  DeliveryMethodConfig copyWith({
    String? key,
    String? label,
    bool? enabled,
    bool? isDefault,
  }) {
    return DeliveryMethodConfig(
      key: key ?? this.key,
      label: label ?? this.label,
      enabled: enabled ?? this.enabled,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  // 🔹 AJOUT : Comparaison basée sur la clé unique
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeliveryMethodConfig && other.key == key;
  }

  @override
  int get hashCode => key.hashCode;

  @override
  String toString() => 'DeliveryMethodConfig(key: $key, label: $label)';
}