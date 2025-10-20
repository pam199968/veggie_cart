import 'package:veggie_cart/models/profile.dart';
import 'delivery_method.dart';

/// Modèle de données pour un utilisateur
class UserModel {
  final String? id; // optionnel : ID Firestore
  final String name;
  final String givenName;
  final String email;
  final String phoneNumber;
  final Profile profile;
  final String address;
  final DeliveryMethod deliveryMethod;
  final bool pushNotifications;

  UserModel({
    this.id,
    required this.name,
    required this.givenName,
    required this.email,
    required this.phoneNumber,
    this.profile = Profile.customer,
    required this.address,
    this.deliveryMethod = DeliveryMethod.farmPickup,
    this.pushNotifications = true,
  });

  /// 🧩 Crée une copie du modèle avec certaines valeurs modifiées
  UserModel copyWith({
    String? id,
    String? name,
    String? givenName,
    String? email,
    String? phoneNumber,
    Profile? profile,
    String? address,
    DeliveryMethod? deliveryMethod,
    bool? pushNotifications,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      givenName: givenName ?? this.givenName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profile: profile ?? this.profile,
      address: address ?? this.address,
      deliveryMethod: deliveryMethod ?? this.deliveryMethod,
      pushNotifications: pushNotifications ?? this.pushNotifications,
    );
  }

  /// 🔁 Convertit en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'givenName': givenName,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'deliveryMethod': deliveryMethod.name,
      'pushNotifications': pushNotifications,
      'profile': profile.name,
      // 🔽 Ajout pour recherche insensible à la casse
      'nameLower': name.toLowerCase(),
      'givenNameLower': givenName.toLowerCase(),
    };
  }


  /// 🏗️ Construit un UserModel depuis Firestore
  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      id: documentId,
      name: map['name'] ?? '',
      givenName: map['givenName'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      profile: ProfileExtension.fromString(map['profile'] ?? 'customer'),
      address: map['address'] ?? '',
      deliveryMethod: DeliveryMethodExtension.fromString(
        map['deliveryMethod'] ?? 'farmPickup',
      ),
      pushNotifications: map['pushNotifications'] ?? true,
    );
  }

  /// 🧱 Retourne un utilisateur vide
  static UserModel empty() {
    return UserModel(
      id: null,
      name: '',
      givenName: '',
      email: '',
      phoneNumber: '',
      profile: Profile.customer,
      address: '',
      deliveryMethod: DeliveryMethod.farmPickup,
      pushNotifications: true,
    );
  }

  /// 🧠 Debugging facile
  @override
  String toString() {
    return 'UserModel('
        'id: $id, '
        'name: $name, '
        'givenName: $givenName, '
        'email: $email, '
        'phoneNumber: $phoneNumber, '
        'profile: ${profile.label}, '
        'address: $address, '
        'deliveryMethod: ${deliveryMethod.label}, '
        'pushNotifications: $pushNotifications'
        ')';
  }
}
