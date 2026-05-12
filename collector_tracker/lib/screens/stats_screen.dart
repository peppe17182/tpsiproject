import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stats_provider.dart';
import '../providers/category_provider.dart';
import '../models/stats.dart';
import 'package:fl_chart/fl_chart.dart';


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

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text('Nerd Stats', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: colorScheme.background,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Collection Overview', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (statsProvider.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Row(
                children: [
                  Expanded(child: _buildStatCard(context, 'Total Categories', statsProvider.globalStats?.totalCategories.toString() ?? '0', Icons.category, colorScheme.primary)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard(context, 'Total Items', statsProvider.globalStats?.totalItems.toString() ?? '0', Icons.list_alt, colorScheme.secondary)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard(context, 'Average Rating', statsProvider.globalStats?.averageRating.toStringAsFixed(1) ?? '0.0', Icons.star, colorScheme.tertiary)),
                ],
              ),
            
            const SizedBox(height: 48),
            Text('Activity Trend', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              height: 250,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(color: colorScheme.outlineVariant.withOpacity(0.5), strokeWidth: 1),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final style = TextStyle(color: colorScheme.outline, fontSize: 12);
                          return Padding(padding: const EdgeInsets.only(top: 8), child: Text('Day ${value.toInt()}', style: style));
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 3),
                        FlSpot(1, 1),
                        FlSpot(2, 4),
                        FlSpot(3, 2),
                        FlSpot(4, 5),
                        FlSpot(5, 3),
                        FlSpot(6, 6),
                      ],
                      isCurved: true,
                      color: colorScheme.secondary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: colorScheme.secondary.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 48),
            Text('Category Deep Dive', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    DropdownButtonFormField<int>(
                      value: _selectedCategoryId,
                      decoration: InputDecoration(
                        labelText: 'Select Category', 
                        labelStyle: TextStyle(color: colorScheme.onSurface),
                        filled: true,
                        fillColor: colorScheme.background,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: colorScheme.outlineVariant)),
                      ),
                      dropdownColor: colorScheme.surfaceVariant,
                      items: [
                        DropdownMenuItem<int>(value: null, child: Text('None', style: TextStyle(color: colorScheme.onSurface))),
                        ...categoryProvider.categories.map((cat) => DropdownMenuItem(value: cat.id, child: Text(cat.name, style: TextStyle(color: colorScheme.onSurface)))),
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
                            Expanded(child: _buildStatCard(context, 'Category Items', _categoryStats!.totalItems.toString(), Icons.inventory_2, colorScheme.tertiary)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildStatCard(context, 'Average Rating', _categoryStats!.averageRating.toStringAsFixed(1), Icons.star_half, colorScheme.primary)),
                          ],
                        )
                    else
                      Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text('Select a category to view its statistics', style: TextStyle(color: colorScheme.outline)),
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
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: color),
          const SizedBox(height: 16),
          Text(value, style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 8),
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
