enum DeliveryMethod {
  farmPickup,      // Retrait à la ferme
  marketPickup,    // Retrait au marché
  homeDelivery,    // Livraison à domicile
}

extension DeliveryMethodExtension on DeliveryMethod {
  String get label {
    switch (this) {
      case DeliveryMethod.farmPickup:
        return "Retrait à la ferme";
      case DeliveryMethod.marketPickup:
        return "Retrait au marché";
      case DeliveryMethod.homeDelivery:
        return "Livraison à domicile";
    }
  }

  // Pour convertir depuis un String Firestore
  static DeliveryMethod fromString(String value) {
    switch (value) {
      case "Retrait au marché":
        return DeliveryMethod.marketPickup;
      case "Livraison à domicile":
        return DeliveryMethod.homeDelivery;
      case "Retrait à la ferme":
      default:
        return DeliveryMethod.farmPickup;
    }
  }
}
