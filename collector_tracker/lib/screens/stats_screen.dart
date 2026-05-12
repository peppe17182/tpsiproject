import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stats_provider.dart';
import '../providers/category_provider.dart';
import '../models/stats.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int? _selectedCategoryId;
  Stats? _categoryStats;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().fetchCategories();
      context.read<StatsProvider>().fetchGlobalStats();
    });
  }

  void _fetchCategoryStats(int? categoryId) async {
    if (categoryId == null) {
      setState(() {
        _selectedCategoryId = null;
        _categoryStats = null;
      });
      return;
    }
    
    setState(() {
      _selectedCategoryId = categoryId;
    });
    
    final stats = await context.read<StatsProvider>().fetchCategoryStats(categoryId);
    setState(() {
      _categoryStats = stats;
    });
  }

  @override
  Widget build(BuildContext context) {
    final statsProvider = context.watch<StatsProvider>();
    final categoryProvider = context.watch<CategoryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Global Statistics', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            if (statsProvider.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Row(
                children: [
                  Expanded(child: _buildStatCard(context, 'Total Categories', statsProvider.globalStats?.totalCategories.toString() ?? '0', Icons.category, Colors.blue)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard(context, 'Total Items', statsProvider.globalStats?.totalItems.toString() ?? '0', Icons.list_alt, Colors.green)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard(context, 'Average Rating', statsProvider.globalStats?.averageRating.toStringAsFixed(1) ?? '0.0', Icons.star, Colors.amber)),
                ],
              ),
            
            const SizedBox(height: 48),
            Text('Category Statistics', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    DropdownButtonFormField<int>(
                      value: _selectedCategoryId,
                      decoration: const InputDecoration(labelText: 'Select Category', border: OutlineInputBorder()),
                      items: [
                        const DropdownMenuItem<int>(value: null, child: Text('None')),
                        ...categoryProvider.categories.map((cat) => DropdownMenuItem(value: cat.id, child: Text(cat.name))),
                      ],
                      onChanged: _fetchCategoryStats,
                    ),
                    const SizedBox(height: 24),
                    if (_selectedCategoryId != null)
                      if (_categoryStats == null)
                        const CircularProgressIndicator()
                      else
                        Row(
                          children: [
                            Expanded(child: _buildStatCard(context, 'Category Items', _categoryStats!.totalItems.toString(), Icons.inventory_2, Colors.purple)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildStatCard(context, 'Average Rating', _categoryStats!.averageRating.toStringAsFixed(1), Icons.star_half, Colors.orange)),
                          ],
                        )
                    else
                      const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text('Select a category to view its statistics'),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 16),
            Text(value, style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 8),
            Text(title, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
