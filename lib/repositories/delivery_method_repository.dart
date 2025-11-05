import '../models/delivery_method_config.dart';
import '../services/delivery_method_service.dart';

class DeliveryMethodRepository {
  static final DeliveryMethodRepository _instance =
      DeliveryMethodRepository._internal();
  factory DeliveryMethodRepository() => _instance;
  DeliveryMethodRepository._internal();

  final List<DeliveryMethodConfig> _cache = [];
  bool _isLoaded = false;
  static final DeliveryMethodConfig defaultMethod =
      DeliveryMethodService.defaultMethods.first;

  /// 🔹 Charge les méthodes de livraison via le service
  Future<void> load() async {
    if (_isLoaded) return;

    final methods = await DeliveryMethodService.fetchDeliveryMethods();
    _cache
      ..clear()
      ..addAll(methods);

    _isLoaded = true;
  }

  /// 🔹 Retourne toutes les méthodes chargées
  List<DeliveryMethodConfig> get all => List.unmodifiable(_cache);

  Stream<List<DeliveryMethodConfig>> stream() =>
      DeliveryMethodService.streamDeliveryMethods();

  /// 🔹 Recherche une méthode par sa clé
  DeliveryMethodConfig? findByKey(String key) {
    try {
      return _cache.firstWhere((m) => m.key == key);
    } catch (_) {
      return null;
    }
  }

  /// 🔹 Récupère une méthode à partir de sa clé (et charge si nécessaire)
  static Future<DeliveryMethodConfig?> fromKey(String key) async {
    final repo = DeliveryMethodRepository();
    if (!repo._isLoaded) {
      await repo.load();
    }
    return repo.findByKey(key);
  }

  /// 🔹 Crée une nouvelle méthode de livraison et l’ajoute au cache
  Future<void> create(DeliveryMethodConfig method) async {
    await DeliveryMethodService.createDeliveryMethod(method);

    // Recharge le cache pour inclure la nouvelle méthode
    _isLoaded = false;
    await load();
  }

  /// 🔹 Met à jour une méthode existante et met à jour le cache
  Future<void> update(String key, DeliveryMethodConfig method) async {
    await DeliveryMethodService.updateDeliveryMethodByKey(key, method);

    _isLoaded = false;
    await load();
  }
}
