import 'delivery_method.dart';
// Modèle de données pour un utilisateur
class UserModel {
  String? id; // optionnel : ID Firestore
  final String name;
  final String givenName;
  final String email;
  final String phoneNumber;
  final String profile;
  final String address;
  final DeliveryMethod deliveryMethod; // 🔹 Enum
  final bool pushNotifications;

  UserModel({
    this.id,
    required this.name,
    required this.givenName,
    required this.email,
    required this.phoneNumber,
    required this.profile,
    required this.address,
    this.deliveryMethod = DeliveryMethod.farmPickup,// valeur par défaut
    this.pushNotifications = true, // activé par défaut
  });

  // Convertit en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'givenName': givenName,
      'email': email,
      'phoneNumber': phoneNumber,
      'profile': profile,
      'address': address,
      'deliveryMethod': deliveryMethod.label, // Stocker le label dans Firestore
      'pushNotifications': pushNotifications,
    };
  }

  // Construit un UserModel depuis Firestore
  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      id: documentId,
      name: map['name'] ?? '',
      givenName: map['givenName'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      profile: map['profile'] ?? '',
      address: map['address'] ?? '',
      deliveryMethod: DeliveryMethodExtension.fromString(map['deliveryMethod'] ?? 'Retrait à la ferme'),
      pushNotifications: map['pushNotifications'] ?? true,
    );
  }
}
