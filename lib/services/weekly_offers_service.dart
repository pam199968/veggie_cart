import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/weekly_offer.dart';

class WeeklyOffersService {
  final FirebaseFirestore _firestore;

  WeeklyOffersService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _collection => _firestore.collection('weeklyOffers');

  /// 🔹 CREATE — Firestore génère automatiquement l’ID
  Future<String> addWeeklyOffer(WeeklyOffer offer) async {
    final docRef = await _collection.add(offer.toMap());
    return docRef.id;
  }

  /// 🔹 READ (un seul)
  Future<WeeklyOffer?> getWeeklyOffer(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return WeeklyOffer.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  /// 🔹 READ (tous)
  Future<List<WeeklyOffer>> getAllWeeklyOffers({
    WeeklyOfferStatus? status,
  }) async {
    Query query = _collection;
    if (status != null) {
      query = query.where(
        'status',
        isEqualTo: status.name,
      ); // ou status.toString() selon le stockage
    }
    final snapshot = await query.get();
    return snapshot.docs
        .map(
          (doc) =>
              WeeklyOffer.fromMap(doc.data() as Map<String, dynamic>, doc.id),
        )
        .toList();
  }

  /// 🔹 STREAM temps réel — optionnellement filtré par statut
  Stream<List<WeeklyOffer>> streamWeeklyOffers({WeeklyOfferStatus? status}) {
    Query query = _collection;
    if (status != null) {
      query = query.where('status', isEqualTo: status.name);
    }
    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map(
            (doc) =>
                WeeklyOffer.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    });
  }

  /// 🔹 UPDATE
  Future<void> updateWeeklyOffer(WeeklyOffer offer) async {
    if (offer.id == null) {
      throw Exception('Impossible de mettre à jour une offre sans ID.');
    }
    await _collection.doc(offer.id).update(offer.toMap());
  }

  /// 🔹 DELETE
  Future<void> deleteWeeklyOffer(String id) async {
    await _collection.doc(id).delete();
  }
}
