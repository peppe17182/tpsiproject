import 'package:flutter/material.dart';
import '../models/stats.dart';
import '../services/api_service.dart';

class StatsProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  Stats? _globalStats;
  bool _isLoading = false;

  Stats? get globalStats => _globalStats;
  bool get isLoading => _isLoading;

  Future<void> fetchGlobalStats() async {
    _setLoading(true);
    try {
      final response = await _apiService.get('/stats');
      _globalStats = Stats.fromJson(response);
    } catch (e) {
      print(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<Stats?> fetchCategoryStats(int categoryId) async {
    try {
      final response = await _apiService.get('/stats/$categoryId');
      return Stats.fromJson(response);
    } catch (e) {
      print(e);
      return null;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
