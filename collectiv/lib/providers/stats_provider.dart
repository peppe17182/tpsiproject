import 'package:flutter/material.dart';
import '../models/stats.dart';
import '../services/api_service.dart';

class StatsProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  FullStats? _fullStats;
  bool _isLoading = false;

  FullStats? get fullStats => _fullStats;
  StatsOverview? get globalStats => _fullStats?.overview;
  bool get isLoading => _isLoading;

  Future<void> fetchGlobalStats() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.get('/stats');
      _fullStats = FullStats.fromJson(response);
    } catch (e) {
      debugPrint('StatsProvider.fetchGlobalStats error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<FullStats?> fetchCategoryStats(int categoryId) async {
    try {
      final response = await _apiService.get('/stats/$categoryId');
      return FullStats.fromJson(response);
    } catch (e) {
      debugPrint('StatsProvider.fetchCategoryStats error: $e');
      return null;
    }
  }
}
