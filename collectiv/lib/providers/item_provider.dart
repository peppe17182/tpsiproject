import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/api_service.dart';
import 'package:image_picker/image_picker.dart';

class ItemProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Item> _allItems = [];
  bool _isLoading = false;
  int _currentPage = 1;
  bool _hasMore = true;
  String _searchQuery = '';
  int? _categoryId;

  /// Returns items filtered by active category, or all items if no filter.
  List<Item> get items => _categoryId != null
      ? _allItems.where((i) => i.categoryId == _categoryId).toList()
      : _allItems;

  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  int? get activeCategoryId => _categoryId;

  void setCategoryFilter(int? categoryId) {
    _categoryId = categoryId;
    notifyListeners();
  }

  Future<void> fetchItems({bool refresh = false, String? search}) async {
    if (refresh) {
      _currentPage = 1;
      _allItems = [];
      _hasMore = true;
    }

    if (search != null) _searchQuery = search;
    if (!_hasMore) return;

    _isLoading = true;
    notifyListeners();

    try {
      final queryParams = <String, String>{
        'page': _currentPage.toString(),
        'limit': '20',
        if (_searchQuery.isNotEmpty) 'search': _searchQuery,
      };

      final response = await _apiService.get(
        '/items',
        queryParams: queryParams,
      );
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        final List<dynamic> data = response['data'];
        final newItems = data.map((json) => Item.fromJson(json)).toList();
        _allItems.addAll(newItems);

        if (response['meta'] != null) {
          final meta = response['meta'];
          _hasMore = meta['current_page'] < meta['total_pages'];
        } else {
          _hasMore = newItems.length >= 20;
        }
        _currentPage++;
      } else if (response is List) {
        final newItems = response.map((json) => Item.fromJson(json)).toList();
        _hasMore = newItems.length >= 20;
        _allItems.addAll(newItems);
        _currentPage++;
      } else {
        _hasMore = false;
      }
    } catch (e) {
      debugPrint('ItemProvider.fetchItems error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch full item details (list endpoint omits description, acquisition_date)
  Future<Item?> fetchSingleItem(int id) async {
    try {
      final response = await _apiService.get('/items/$id');
      if (response is Map<String, dynamic>) {
        return Item.fromJson(response);
      }
    } catch (e) {
      debugPrint('ItemProvider.fetchSingleItem error: $e');
    }
    return null;
  }

  Future<void> createItem(Map<String, dynamic> data) async {
    await _apiService.post('/items', data);
    await fetchItems(refresh: true);
  }

  Future<void> updateItem(int id, Map<String, dynamic> data) async {
    await _apiService.put('/items/$id', data);
    await fetchItems(refresh: true);
  }

  Future<void> deleteItem(int id) async {
    await _apiService.delete('/items/$id');
    await fetchItems(refresh: true);
  }

  Future<void> uploadImage(int id, XFile file) async {
    final bytes = await file.readAsBytes();
    await _apiService.uploadMultipart(
      '/upload/$id',
      file.path,
      bytes,
      file.name,
    );
    await fetchItems(refresh: true);
  }
}
