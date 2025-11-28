// Copyright (c) 2025 Patrick Mortas
// All rights reserved.

enum Profile {
  gardener,    // Maraicher
  customer,    // Client

}

extension ProfileExtension on Profile {
  String get label {
    switch (this) {
      case Profile.customer:
        return "Client";
      case Profile.gardener:
        return "Maraicher";
    }
  }

  // Pour convertir depuis un String Firestore
  static Profile fromString(String value) {
    switch (value) {
      case "customer":
        return Profile.customer;
      case "gardener":
        return Profile.gardener;
      default:
        return Profile.customer;
    }
  }
}
