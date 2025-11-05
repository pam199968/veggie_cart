import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/delivery_method_config.dart';

class DeliveryMethodService {
  static final _firestore = FirebaseFirestore.instance;

  // DeliveryMethodService
  static Future<List<DeliveryMethodConfig>> fetchDeliveryMethods() async {
    try {
      final snapshot = await _firestore.collection('delivery_methods').get();

      final firestoreMethods = snapshot.docs.map((doc) {
        final data = doc.data();
        // include document id in the model optionally (see note below)
        final m = DeliveryMethodConfig.fromFirestore(
          Map<String, dynamic>.from(data),
        );
        return m;
      }).toList();

      // Fusion : firestore override default if same key
      final Map<String, DeliveryMethodConfig> merged = {
        for (var m in defaultMethods) m.key: m,
        for (var m in firestoreMethods) m.key: m,
      };

      return merged.values.toList();
    } catch (e) {
      // fallback local si Firestore échoue
      return defaultMethods;
    }
  }

  static Stream<List<DeliveryMethodConfig>> streamDeliveryMethods() {
    return _firestore.collection('delivery_methods').snapshots().map((
      snapshot,
    ) {
      final firestoreMethods = snapshot.docs.map((doc) {
        return DeliveryMethodConfig.fromFirestore(
          Map<String, dynamic>.from(doc.data()),
        );
      }).toList();

      final merged = {
        for (var m in defaultMethods) m.key: m,
        for (var m in firestoreMethods) m.key: m,
      };

      return merged.values.toList();
    });
  }

  /// 🔹 Crée une nouvelle méthode de livraison dans Firestore
  /// La clé est générée automatiquement : custom1, custom2, ...
  static Future<DeliveryMethodConfig> createDeliveryMethod(
    DeliveryMethodConfig method,
  ) async {
    try {
      // 🔹 Récupère les méthodes existantes pour générer une clé unique
      final snapshot = await _firestore.collection('delivery_methods').get();
      final existingKeys = snapshot.docs.map((d) => d['key'] as String).toSet();

      int counter = 1;
      String newKey;
      do {
        newKey = 'custom$counter';
        counter++;
      } while (existingKeys.contains(newKey));

      final newMethod = method.copyWith(key: newKey);

      await _firestore.collection('delivery_methods').add(newMethod.toMap());
      return newMethod;
    } catch (e) {
      rethrow;
    }
  }

  // 🔹 Récupère le documentId Firestore à partir de la clé métier
  static Future<String?> _getDocumentIdByKey(String key) async {
    final query = await _firestore
        .collection('delivery_methods')
        .where('key', isEqualTo: key)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;
    return query.docs.first.id;
  }

  // 🔹 Met à jour une méthode existante dans Firestore (par clé logique)
  static Future<DeliveryMethodConfig> updateDeliveryMethodByKey(
    String key,
    DeliveryMethodConfig method,
  ) async {
    try {
      final documentId = await _getDocumentIdByKey(key);

      if (documentId == null) {
        // Si la méthode n'existe pas dans Firestore (ex: méthode par défaut),
        // on peut choisir de la créer à la place :
        await _firestore.collection('delivery_methods').add(method.toMap());
        return method;
      }

      await _firestore
          .collection('delivery_methods')
          .doc(documentId)
          .update(method.toMap());

      return method;
    } catch (e) {
      rethrow;
    }
  }

  /// 🔹 Méthodes de livraison par défaut intégrées
  static final List<DeliveryMethodConfig> defaultMethods = [
    DeliveryMethodConfig(
      key: 'farmPickup',
      label: 'Retrait à la ferme',
      enabled: true,
      isDefault: true,
    ),
    DeliveryMethodConfig(
      key: 'marketPickup',
      label: 'Retrait au marché',
      enabled: true,
      isDefault: true,
    ),
    DeliveryMethodConfig(
      key: 'homeDelivery',
      label: 'Livraison à domicile',
      enabled: true,
      isDefault: true,
    ),
  ];
}
