import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stats_provider.dart';
import '../models/stats.dart';
import '../widgets/glass_panel.dart';
import 'package:fl_chart/fl_chart.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  RangeValues? _yearRange;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatsProvider>().fetchGlobalStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<StatsProvider>();
    final cs = Theme.of(context).colorScheme;
    final w = MediaQuery.of(context).size.width;
    final pad = w > 800 ? 40.0 : 20.0;
    final full = stats.fullStats;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: stats.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: pad, vertical: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nerd Stats',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Everything about your collection',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),

                  const SizedBox(height: 24),

                  // ─── Overview Grid ───
                  if (full != null) ...[
                    _buildOverviewGrid(context, full, cs),

                    const SizedBox(height: 32),

                    // ─── Collector Score ───
                    GlassPanel(
                      borderRadius: 16,
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value: full.overview.collectorScore / 100,
                                  strokeWidth: 8,
                                  backgroundColor: cs.outline,
                                  valueColor: AlwaysStoppedAnimation(
                                    full.overview.collectorScore >= 70
                                        ? cs.tertiary
                                        : full.overview.collectorScore >= 40
                                        ? const Color(0xFFF59E0B)
                                        : cs.error,
                                  ),
                                ),
                                Text(
                                  '${full.overview.collectorScore}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Collector Score',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  full.overview.collectorScore >= 70
                                      ? 'Great job! Your collection is well curated.'
                                      : full.overview.collectorScore >= 40
                                      ? 'Getting there. Add ratings and images to boost your score.'
                                      : 'Just getting started. Keep adding items!',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ─── Charts Row ───
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 700;
                        return Flex(
                          direction: isWide ? Axis.horizontal : Axis.vertical,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Rating Distribution
                            isWide
                                ? Expanded(
                                    child: _buildRatingChart(
                                      context,
                                      full.ratingDistribution,
                                      cs,
                                    ),
                                  )
                                : _buildRatingChart(
                                    context,
                                    full.ratingDistribution,
                                    cs,
                                  ),
                            SizedBox(
                              width: isWide ? 16 : 0,
                              height: isWide ? 0 : 16,
                            ),
                            // Acquisition Timeline
                            isWide
                                ? Expanded(
                                    child: _buildTimelineChart(
                                      context,
                                      full.acquisitionTimeline,
                                      cs,
                                    ),
                                  )
                                : _buildTimelineChart(
                                    context,
                                    full.acquisitionTimeline,
                                    cs,
                                  ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // ─── Category Breakdown ───
                    Text(
                      'Categories',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    _buildCategoryTable(context, full.byCategory, cs),

                    const SizedBox(height: 32),

                    // ─── Records ───
                    const SizedBox(height: 32),
                    Text(
                      'Records',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    _buildRecordsSection(context, full.records, cs),
                  ],

                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }

  Widget _buildOverviewGrid(
    BuildContext context,
    FullStats full,
    ColorScheme cs,
  ) {
    final o = full.overview;
    // Calculate perfect items from rating_distribution since the API overview field is unreliable
    final perfectFromDist = full.ratingDistribution
        .where((b) => b.rating == 5)
        .fold(0, (sum, b) => sum + b.count);

    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth > 800 ? 4 : 2;
        final cardW = (constraints.maxWidth - (cols - 1) * 12) / cols;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _StatChip(
              width: cardW,
              label: 'Total Items',
              value: o.totalItems.toString(),
              icon: Icons.grid_view_rounded,
              color: cs.primary,
            ),
            _StatChip(
              width: cardW,
              label: 'Categories',
              value: o.totalCategories.toString(),
              icon: Icons.folder_rounded,
              color: cs.secondary,
            ),
            _StatChip(
              width: cardW,
              label: 'Avg Rating',
              value: o.averageRating.toStringAsFixed(1),
              icon: Icons.star_rounded,
              color: const Color(0xFFF59E0B),
            ),
            _StatChip(
              width: cardW,
              label: 'Items with Images',
              value: '${o.itemsWithImages}',
              icon: Icons.image_rounded,
              color: cs.tertiary,
            ),
            _StatChip(
              width: cardW,
              label: 'Inserted in the Last 30 Days',
              value: o.itemsLast30Days.toString(),
              icon: Icons.trending_up_rounded,
              color: cs.primary,
            ),
            _StatChip(
              width: cardW,
              label: 'Perfect (5★)',
              value: perfectFromDist.toString(),
              icon: Icons.emoji_events_rounded,
              color: const Color(0xFFF59E0B),
            ),
            _StatChip(
              width: cardW,
              label: 'Grading consistency (Standard Deviation)',
              value: o.gradingConsistency.toString(),
              icon: Icons.balance_rounded,
              color: cs.secondary,
            ),
          ],
        );
      },
    );
  }

  Widget _buildRatingChart(
    BuildContext context,
    List<RatingBucket> data,
    ColorScheme cs,
  ) {
    // Ensure all 5 ratings are represented
    final Map<int, int> rMap = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (final b in data) {
      rMap[b.rating] = b.count;
    }
    final maxCount = rMap.values.fold(0, (a, b) => a > b ? a : b);

    return GlassPanel(
      borderRadius: 16,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rating Distribution',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (maxCount + 1).toDouble(),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => cs.surfaceContainerHighest,
                    getTooltipItem: (group, gi, rod, ri) {
                      return BarTooltipItem(
                        '${group.x}★: ${rod.toY.toInt()}',
                        TextStyle(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '${value.toInt()}★',
                            style: TextStyle(
                              color: cs.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: rMap.entries.map((e) {
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value.toDouble(),
                        width: 28,
                        color: const Color(0xFFF59E0B),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineChart(
    BuildContext context,
    List<TimelineEntry> data,
    ColorScheme cs,
  ) {
    if (data.isEmpty) {
      return GlassPanel(
        borderRadius: 16,
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          height: 160,
          child: Center(
            child: Text(
              'No timeline data',
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
          ),
        ),
      );
    }

    final sortedData = List<TimelineEntry>.from(data)
      ..sort((a, b) => a.year.compareTo(b.year));
    final minYear = sortedData.first.year.toDouble();
    final maxYear = sortedData.last.year.toDouble();

    // Initialize range on first build
    _yearRange ??= RangeValues(minYear, maxYear);

    // Clamp range to data bounds
    final range = RangeValues(
      _yearRange!.start.clamp(minYear, maxYear),
      _yearRange!.end.clamp(minYear, maxYear),
    );

    final filtered = sortedData
        .where((e) => e.year >= range.start && e.year <= range.end)
        .toList();
    final totalInRange = filtered.fold(0, (sum, e) => sum + e.count);
    final maxCount = filtered.isEmpty
        ? 1
        : filtered.map((e) => e.count).fold(1, (a, b) => a > b ? a : b);

    return GlassPanel(
      borderRadius: 16,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Acquisitions Over Time',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$totalInRange items',
                  style: TextStyle(
                    color: cs.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${range.start.toInt()} – ${range.end.toInt()}',
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
          ),
          const SizedBox(height: 12),

          // Range slider
          if (maxYear > minYear)
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: cs.primary,
                inactiveTrackColor: cs.outline,
                thumbColor: cs.primary,
                overlayColor: cs.primary.withValues(alpha: 0.1),
                rangeThumbShape: const RoundRangeSliderThumbShape(
                  enabledThumbRadius: 8,
                ),
                trackHeight: 4,
              ),
              child: RangeSlider(
                values: range,
                min: minYear,
                max: maxYear,
                divisions: (maxYear - minYear).toInt(),
                labels: RangeLabels(
                  '${range.start.toInt()}',
                  '${range.end.toInt()}',
                ),
                onChanged: (v) => setState(() => _yearRange = v),
              ),
            ),

          const SizedBox(height: 16),

          // Year bars
          ...filtered.map((entry) {
            final barWidth = entry.count / maxCount;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 48,
                    child: Text(
                      '${entry.year}',
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          height: 28,
                          decoration: BoxDecoration(
                            color: cs.outline.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: barWidth.clamp(0.05, 1.0),
                          child: Container(
                            height: 28,
                            decoration: BoxDecoration(
                              color: cs.primary.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 10),
                            child: Text(
                              '${entry.count}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCategoryTable(
    BuildContext context,
    List<CategoryStat> cats,
    ColorScheme cs,
  ) {
    if (cats.isEmpty) {
      return GlassPanel(
        borderRadius: 16,
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text(
            'No category data',
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
        ),
      );
    }

    return GlassPanel(
      borderRadius: 16,
      padding: const EdgeInsets.all(4),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    'Category',
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Items',
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Avg Rating',
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: cs.outline, height: 1),
          ...cats.map(
            (cat) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(
                      cat.category,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      cat.count.toString(),
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (cat.avgRating > 0) ...[
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Color(0xFFF59E0B),
                          ),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          cat.avgRating > 0
                              ? cat.avgRating.toStringAsFixed(1)
                              : '—',
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordsSection(
    BuildContext context,
    StatsRecords? records,
    ColorScheme cs,
  ) {
    final hasAny =
        records != null &&
        (records.topRated != null ||
            records.newestAcquisition != null ||
            records.oldestAcquisition != null ||
            records.bestCategory != null);

    if (!hasAny) {
      return GlassPanel(
        borderRadius: 16,
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.emoji_events_outlined, size: 40, color: cs.outline),
              const SizedBox(height: 12),
              Text(
                'No records yet',
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Add more items with ratings and dates to unlock records.',
                style: TextStyle(
                  color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GlassPanel(
      borderRadius: 16,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (records!.topRated != null)
            _RecordTile(
              icon: Icons.emoji_events_rounded,
              color: const Color(0xFFF59E0B),
              label: 'Top Rated',
              value: '${records.topRated!.name} — ${records.topRated!.rating}★',
            ),
          if (records.newestAcquisition != null) ...[
            Divider(color: cs.outline, height: 24),
            _RecordTile(
              icon: Icons.new_releases_rounded,
              color: cs.tertiary,
              label: 'Newest',
              value:
                  '${records.newestAcquisition!.name} — ${records.newestAcquisition!.acquisitionDate ?? ""}',
            ),
          ],
          if (records.oldestAcquisition != null) ...[
            Divider(color: cs.outline, height: 24),
            _RecordTile(
              icon: Icons.history_rounded,
              color: cs.primary,
              label: 'Oldest',
              value:
                  '${records.oldestAcquisition!.name} — ${records.oldestAcquisition!.acquisitionDate ?? ""}',
            ),
          ],
          if (records.bestCategory != null) ...[
            Divider(color: cs.outline, height: 24),
            _RecordTile(
              icon: Icons.workspace_premium_rounded,
              color: cs.secondary,
              label: 'Best Category',
              value:
                  '${records.bestCategory!.name} — ${records.bestCategory!.avgRating}★',
            ),
          ],
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final double width;
  final String label, value;
  final IconData icon;
  final Color color;

  const _StatChip({
    required this.width,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: GlassPanel(
        borderRadius: 14,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecordTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label, value;

  const _RecordTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
