import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/api_service.dart';

class CategoryProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Category> _categories = [];
  bool _isLoading = false;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> fetchCategories() async {
    _setLoading(true);
    try {
      final response = await _apiService.get('/categories');
      if (response is List) {
        _categories = response.map((json) => Category.fromJson(json)).toList();
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createCategory(String name, String description) async {
    _setLoading(true);
    try {
      await _apiService.post('/categories', {
        'name': name,
        'description': description,
      });
      await fetchCategories();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateCategory(int id, String name, String description) async {
    _setLoading(true);
    try {
      await _apiService.put('/categories/$id', {
        'name': name,
        'description': description,
      });
      await fetchCategories();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteCategory(int id) async {
    _setLoading(true);
    try {
      await _apiService.delete('/categories/$id');
      await fetchCategories();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
