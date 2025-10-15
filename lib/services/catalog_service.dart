import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vegetable_model.dart';

class CatalogService {
  final CollectionReference _catalogRef =
      FirebaseFirestore.instance.collection('vegetables');

  /// CREATE
  Future<void> addVegetable(VegetableModel vegetable) async {
    await _catalogRef.add(vegetable.toMap());
  }

  /// READ (stream)
  Stream<List<VegetableModel>> getVegetablesStream() {
    return _catalogRef.snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) => VegetableModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  /// READ (single)
  Future<VegetableModel?> getVegetableById(String id) async {
    final doc = await _catalogRef.doc(id).get();
    if (doc.exists) {
      return VegetableModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  /// UPDATE
  Future<void> updateVegetable(String id, VegetableModel updated) async {
    await _catalogRef.doc(id).update(updated.toMap());
  }

  /// DELETE
  Future<void> deleteVegetable(String id) async {
    await _catalogRef.doc(id).delete();
  }
}
