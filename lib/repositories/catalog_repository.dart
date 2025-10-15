import 'dart:async';
import '../models/vegetable_model.dart';
import '../services/catalog_service.dart';

class CatalogRepository {
  final CatalogService _service;

  CatalogRepository({
    required CatalogService catalogService,
  }) : _service = catalogService;

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
