// Copyright (c) 2025 Patrick Mortas
// All rights reserved.

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/profile.dart';
import '../models/user_model.dart';
import '../repositories/delivery_method_repository.dart';

class UserService {
  final FirebaseFirestore _firestore;
  final CollectionReference _usersCollection;

  UserService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _usersCollection = (firestore ?? FirebaseFirestore.instance).collection(
        'users',
      );

  // 🔹 CREATE
  Future<void> createUser(UserModel user) async {
    await _usersCollection.add(user.toMap());
  }

  Future<void> createUserWithId(String id, UserModel user) async {
    await _firestore.collection('users').doc(id).set(user.toMap());
  }

  // 🔹 READ (un seul utilisateur par ID)
  Future<UserModel?> getUserById(String id) async {
    final doc = await _usersCollection.doc(id).get();
    if (!doc.exists) return null;

    final data = doc.data() as Map<String, dynamic>;
    final deliveryKey = data['deliveryMethod'] ?? 'farmPickup';
    final deliveryMethod =
        await DeliveryMethodRepository.fromKey(deliveryKey) ??
        DeliveryMethodRepository.defaultMethod;

    return UserModel.fromMapWithDelivery(data, doc.id, deliveryMethod);
  }

  // 🔹 READ ALL (flux temps réel)
  Stream<List<UserModel>> getUsersStream() {
    return _usersCollection.snapshots().asyncMap((snapshot) async {
      final users = await Future.wait(
        snapshot.docs.map((doc) async {
          final data = doc.data() as Map<String, dynamic>;
          final deliveryKey = data['deliveryMethod'] ?? 'farmPickup';
          final deliveryMethod =
              await DeliveryMethodRepository.fromKey(deliveryKey) ??
              DeliveryMethodRepository.defaultMethod;

          return UserModel.fromMapWithDelivery(data, doc.id, deliveryMethod);
        }),
      );
      return users;
    });
  }

  // 🔹 Recherche insensible à la casse des clients
  Future<List<UserModel>> searchCustomersByName(String searchTerm) async {
    if (searchTerm.isEmpty) return [];

    final lowerTerm = searchTerm.toLowerCase();

    // 🔹 Requête sur le nom
    final nameQuery = await _usersCollection
        .where('profile', isEqualTo: Profile.customer.name)
        .where('nameLower', isGreaterThanOrEqualTo: lowerTerm)
        .where('nameLower', isLessThanOrEqualTo: '$lowerTerm\uf8ff')
        .get();

    // 🔹 Requête sur le prénom
    final givenNameQuery = await _usersCollection
        .where('profile', isEqualTo: Profile.customer.name)
        .where('givenNameLower', isGreaterThanOrEqualTo: lowerTerm)
        .where('givenNameLower', isLessThanOrEqualTo: '$lowerTerm\uf8ff')
        .get();

    // 🔹 Fusion sans doublons
    final allDocs = [...nameQuery.docs, ...givenNameQuery.docs];
    final uniqueDocs = {for (var doc in allDocs) doc.id: doc};

    final users = await Future.wait(
      uniqueDocs.values.map((doc) async {
        final data = doc.data() as Map<String, dynamic>;
        final deliveryKey = data['deliveryMethod'] ?? 'farmPickup';
        final deliveryMethod =
            await DeliveryMethodRepository.fromKey(deliveryKey) ??
            DeliveryMethodRepository.defaultMethod;

        return UserModel.fromMapWithDelivery(data, doc.id, deliveryMethod);
      }),
    );

    return users;
  }

  // 🔹 UPDATE
  Future<void> updateUser(UserModel user) async {
    if (user.id == null) throw Exception("User ID manquant");
    await _usersCollection.doc(user.id).update(user.toMap());
  }

  // 🔹 DELETE
  Future<void> deleteUser(String id) async {
    await _usersCollection.doc(id).delete();
  }
}
