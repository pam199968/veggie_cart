import 'dart:async';

import 'package:flutter/foundation.dart';
import '../models/delivery_method_config.dart';
import '../repositories/delivery_method_repository.dart';

class DeliveryMethodViewModel extends ChangeNotifier {
  final DeliveryMethodRepository _repository;

  DeliveryMethodViewModel({DeliveryMethodRepository? deliveryMethodRepository})
    : _repository = deliveryMethodRepository ?? DeliveryMethodRepository();

  StreamSubscription? _subscription;

  /// Liste des méthodes de livraison disponibles
  List<DeliveryMethodConfig> _methods = [];
  List<DeliveryMethodConfig> get methods => _methods;
  DeliveryMethodConfig get defaultMethod =>
      DeliveryMethodRepository.defaultMethod;

  List<DeliveryMethodConfig> get activeMethods =>
      _methods.where((m) => m.enabled).toList();

  /// Chargement en cours
  bool _loading = false;
  bool get loading => _loading;

  /// Erreur éventuelle
  String? _error;
  String? get error => _error;

  /// 🔹 Écoute en temps réel les changements Firestore
  Future<void> loadMethods() async {
    _loading = true;
    notifyListeners();

    _subscription?.cancel(); // évite les doublons
    _subscription = _repository.stream().listen(
      (data) {
        _methods = data;
        _loading = false;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _loading = false;
        notifyListeners();
      },
    );
  }

  /// 🔹 Nettoyage à la destruction du ViewModel
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  /// 🔹 Annulation des streams lors de la déconnexion
  void cancelSubscriptions() {
    _subscription?.cancel();
    _subscription = null;
  }

  /// 🔹 Récupère une méthode par clé
  DeliveryMethodConfig? getByKey(String key) {
    try {
      return _methods.firstWhere((m) => m.key == key);
    } catch (_) {
      return null;
    }
  }

  /// 🔹 Crée une nouvelle méthode
  Future<void> createMethod(String label) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final newMethod = DeliveryMethodConfig(
        key: '', // sera défini automatiquement par le service Firestore
        label: label,
        enabled: true,
      );

      await _repository.create(newMethod);
      await loadMethods();
    } catch (e, st) {
      _error = e.toString();
      debugPrint('createMethod error: $e\n$st');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// 🔹 Met à jour une méthode existante (sauf la clé)
  Future<void> updateMethod(String key, {String? label, bool? enabled}) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final existing = getByKey(key);
      if (existing == null) {
        throw Exception('Méthode $key introuvable');
      }

      final updated = existing.copyWith(
        label: label ?? existing.label,
        enabled: enabled ?? existing.enabled,
      );

      await _repository.update(key, updated);
      await loadMethods();
    } catch (e, st) {
      _error = e.toString();
      debugPrint('updateMethod error: $e\n$st');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
