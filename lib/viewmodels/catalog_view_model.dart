import 'package:flutter/material.dart';
import '../models/vegetable_model.dart';
import '../repositories/catalog_repository.dart';

class CatalogViewModel extends ChangeNotifier {
  final CatalogRepository catalogRepository;

  CatalogViewModel({required this.catalogRepository}) {
    _loadVegetables();
  }

  List<VegetableModel> _vegetables = [];
  List<VegetableModel> get vegetables => _vegetables;

  String _searchQuery = '';
  VegetableCategory? _selectedCategory;

  String get searchQuery => _searchQuery;
  VegetableCategory? get selectedCategory => _selectedCategory;

  void _loadVegetables() {
    catalogRepository.getVegetables(onlyActive: false).listen((data) {
      _vegetables = data;
      notifyListeners();
    });
  }


  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void setCategory(VegetableCategory? category) {
    _selectedCategory = category;
    _applyFilters();
  }

  void _applyFilters() {
    catalogRepository.getVegetables(
      category: _selectedCategory,
      searchQuery: _searchQuery,
      onlyActive: false,
    ).listen((data) {
      _vegetables = data;
      notifyListeners();
    });
  }

  Future<void> toggleActive(VegetableModel vegetable) async {
    final updated = VegetableModel(
      id: vegetable.id,
      name: vegetable.name,
      category: vegetable.category,
      packaging: vegetable.packaging,
      description: vegetable.description,
      price: vegetable.price,
      standardQuantity: vegetable.standardQuantity,
      active: !vegetable.active,
      image: vegetable.image,
    );
    await catalogRepository.updateVegetable(updated);
  }

  Future<void> addVegetable(VegetableModel vegetable) async {
    await catalogRepository.addVegetable(vegetable);
  }

  Future<void> updateVegetable(VegetableModel vegetable) async {
    await catalogRepository.updateVegetable(vegetable);
  }

  Future<void> deleteVegetable(String id) async {
    await catalogRepository.deleteVegetable(id);
  }
}
