import 'dart:async';
import '../models/vegetable_model.dart';
import '../services/catalog_service.dart';

class CatalogRepository {
  final CatalogService _service;

  CatalogRepository({
    required CatalogService catalogService,
  }) : _service = catalogService;

    /// Cache en mémoire pour les légumes actifs
    List<VegetableModel>? _activeVegetablesCache;
    DateTime? _lastCacheUpdate;

  /// 🔹 Récupérer tous les légumes
  /// Possibilité de filtrer par catégorie, recherche par nom et actif uniquement
  Stream<List<VegetableModel>> getVegetables({
    VegetableCategory? category,
    String? searchQuery,
    bool onlyActive = false,
  }) {
    return _service.getVegetablesStream().map((vegetables) {
      var filtered = vegetables;

      // Filtrer par catégorie
      if (category != null) {
        filtered = filtered.where((v) => v.category == category).toList();
      }

      // Filtrer par nom
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final query = searchQuery.toLowerCase();
        filtered = filtered
            .where((v) => v.name.toLowerCase().contains(query))
            .toList();
      }

      // Filtrer par actif
      if (onlyActive) {
        filtered = filtered.where((v) => v.active).toList();
      }

      return filtered;
    });
  }

    /// Récupère **une seule fois** tous les légumes actifs
    Future<List<VegetableModel>> getAllActiveVegetables({bool forceRefresh = false}) async {
      // 🔹 Si cache disponible et pas de refresh forcé, on le renvoie
      if (!forceRefresh && _activeVegetablesCache != null) {
        // Durée de validité :10 min
        final isRecent = _lastCacheUpdate != null &&
            DateTime.now().difference(_lastCacheUpdate!).inMinutes < 10;
        if (isRecent) return _activeVegetablesCache!;
      }
      // 🔹 Sinon, on recharge depuis Firestore
      final all = await _service.getAllVegetablesOnce();
      final active = all.where((v) => v.active).toList();

      // 🔹 Mise à jour du cache
      _activeVegetablesCache = active;
      _lastCacheUpdate = DateTime.now();

      return active;
    }

  /// Vide le cache manuellement (utile pour tests ou admin)
  void clearCache() {
    _activeVegetablesCache = null;
    _lastCacheUpdate = null;
  }

  /// 🔹 Récupérer un légume par ID
  Future<VegetableModel?> getVegetableById(String id) async {
    return await _service.getVegetableById(id);
  }

  /// 🔹 Ajouter un légume
  Future<void> addVegetable(VegetableModel vegetable) async {
    if (vegetable.name.isEmpty || vegetable.packaging.isEmpty) {
      throw Exception('Le nom et le packaging sont obligatoires');
    }
    await _service.addVegetable(vegetable);
  }

  /// 🔹 Mettre à jour un légume
  Future<void> updateVegetable(VegetableModel vegetable) async {
    if (vegetable.id.isEmpty) {
      throw Exception('ID du légume obligatoire pour la mise à jour');
    }
    await _service.updateVegetable(vegetable.id, vegetable);
  }

  /// 🔹 Supprimer un légume
  Future<void> deleteVegetable(String id) async {
    if (id.isEmpty) {
      throw Exception('ID du légume obligatoire pour la suppression');
    }
    await _service.deleteVegetable(id);
  }
}
