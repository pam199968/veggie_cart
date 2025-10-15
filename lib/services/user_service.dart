import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:veggie_cart/models/profile.dart';
import '../models/user_model.dart';

class UserService {

  final FirebaseFirestore _firestore;
  final CollectionReference _usersCollection;

  UserService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _usersCollection = (firestore ?? FirebaseFirestore.instance).collection('users');

  // CREATE
  Future<void> createUser(UserModel user) async {
    await _usersCollection.add(user.toMap());
  }

  Future<void> createUserWithId(String id, UserModel user) async {
    await _firestore
        .collection('users')
        .doc(id)
        .set(user.toMap());
  }

  // READ (un seul utilisateur par ID)
  Future<UserModel?> getUserById(String id) async {
    final doc = await _usersCollection.doc(id).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  // READ ALL (flux continu)
  Stream<List<UserModel>> getUsersStream() {
    return _usersCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Recheche insensible à la casse des clients 
  Future<List<UserModel>> searchCustomersByName(String searchTerm) async {
    if (searchTerm.isEmpty) return [];

    final lowerTerm = searchTerm.toLowerCase();

    // 🔹 Requête sur le nom de famille
    final nameQuery = await _usersCollection
        .where('profile', isEqualTo: Profile.customer.label)
        .where('nameLower', isGreaterThanOrEqualTo: lowerTerm)
        .where('nameLower', isLessThanOrEqualTo: '$lowerTerm\uf8ff')
        .get();

    // 🔹 Requête sur le prénom
    final givenNameQuery = await _usersCollection
        .where('profile', isEqualTo: Profile.customer.label)
        .where('givenNameLower', isGreaterThanOrEqualTo: lowerTerm)
        .where('givenNameLower', isLessThanOrEqualTo: '$lowerTerm\uf8ff')
        .get();

    // 🔹 Fusionne les deux résultats sans doublons
    final allDocs = [
      ...nameQuery.docs,
      ...givenNameQuery.docs,
    ];

    final uniqueDocs = {
      for (var doc in allDocs) doc.id: doc,
    };

    return uniqueDocs.values.map((doc) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }


  // UPDATE
  Future<void> updateUser(UserModel user) async {
    if (user.id == null) throw Exception("User ID manquant");
    await _usersCollection.doc(user.id).update(user.toMap());
  }

  // DELETE
  Future<void> deleteUser(String id) async {
    await _usersCollection.doc(id).delete();
  }
}
