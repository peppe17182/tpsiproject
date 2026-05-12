import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/api_service.dart';
import 'package:image_picker/image_picker.dart';

class ItemProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Item> _items = [];
  bool _isLoading = false;
  int _currentPage = 1;
  bool _hasMore = true;
  String _searchQuery = '';

  List<Item> get items => _items;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  Future<void> fetchItems({bool refresh = false, String search = ''}) async {
    if (_isLoading) return;

    if (refresh || search != _searchQuery) {
      _currentPage = 1;
      _items = [];
      _hasMore = true;
      _searchQuery = search;
    }

    if (!_hasMore) return;

    _setLoading(true);
    try {
      final queryParams = {
        'page': _currentPage.toString(),
        'limit': '20',
        if (_searchQuery.isNotEmpty) 'search': _searchQuery,
      };

      final response = await _apiService.get('/items', queryParams: queryParams);
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        final List<dynamic> data = response['data'];
        final newItems = data.map((json) => Item.fromJson(json)).toList();
        _items.addAll(newItems);
        
        if (response['meta'] != null) {
          final meta = response['meta'];
          _hasMore = meta['current_page'] < meta['total_pages'];
        } else {
          _hasMore = newItems.length >= 20;
        }
        _currentPage++;
      } else if (response is List) {
        final newItems = response.map((json) => Item.fromJson(json)).toList();
        if (newItems.length < 20) {
          _hasMore = false;
        }
        _items.addAll(newItems);
        _currentPage++;
      } else {
        _hasMore = false;
      }
    } catch (e) {
      // Handle error appropriately
      print(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createItem(Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      await _apiService.post('/items', data);
      await fetchItems(refresh: true);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateItem(int id, Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      await _apiService.put('/items/$id', data);
      await fetchItems(refresh: true);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteItem(int id) async {
    _setLoading(true);
    try {
      await _apiService.delete('/items/$id');
      await fetchItems(refresh: true);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> uploadImage(int id, XFile file) async {
    _setLoading(true);
    try {
      final bytes = await file.readAsBytes();
      await _apiService.uploadMultipart('/upload/$id', file.path, bytes, file.name);
      await fetchItems(refresh: true);
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
