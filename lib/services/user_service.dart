import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');

  // CREATE
  Future<void> createUser(UserModel user) async {
    await _usersCollection.add(user.toMap());
  }

  Future<void> createUserWithId(String id, UserModel user) async {
    await FirebaseFirestore.instance
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
