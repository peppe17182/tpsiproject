import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/stats_provider.dart';
import '../providers/item_provider.dart';
import '../providers/category_provider.dart';
import '../services/api_service.dart';
import '../widgets/glass_panel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatsProvider>().fetchGlobalStats();
      final ip = context.read<ItemProvider>();
      ip.setCategoryFilter(null);
      ip.fetchItems(refresh: true);
      context.read<CategoryProvider>().fetchCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final stats = context.watch<StatsProvider>();
    final itemProvider = context.watch<ItemProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final cs = Theme.of(context).colorScheme;
    final w = MediaQuery.of(context).size.width;
    final pad = w > 800 ? 40.0 : 20.0;

    // Build category name lookup
    final catMap = <int, String>{};
    for (final c in categoryProvider.categories) {
      catMap[c.id] = c.name;
    }

    final recentItems = itemProvider.items.take(6).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: pad, vertical: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Greeting ───
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [cs.primary, cs.secondary],
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: cs.surface,
                    child: Text(
                      (user?.username ?? 'U')[0].toUpperCase(),
                      style: TextStyle(
                        color: cs.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back, ${user?.username ?? 'Collector'}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Here\'s your collection overview',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ─── Stats Overview ───
            if (stats.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (stats.globalStats != null) ...[
              LayoutBuilder(
                builder: (context, constraints) {
                  final cols = constraints.maxWidth > 700 ? 4 : 2;
                  final cardW = (constraints.maxWidth - (cols - 1) * 12) / cols;
                  final overview = stats.globalStats!;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _MiniStat(
                        width: cardW,
                        label: 'Items',
                        value: overview.totalItems.toString(),
                        icon: Icons.grid_view_rounded,
                        color: cs.primary,
                      ),
                      _MiniStat(
                        width: cardW,
                        label: 'Categories',
                        value: overview.totalCategories.toString(),
                        icon: Icons.folder_rounded,
                        color: cs.secondary,
                      ),
                      _MiniStat(
                        width: cardW,
                        label: 'Avg Rating',
                        value: overview.averageRating.toStringAsFixed(1),
                        icon: Icons.star_rounded,
                        color: const Color(0xFFF59E0B),
                      ),
                      _MiniStat(
                        width: cardW,
                        label: 'Last 30 Days',
                        value: overview.itemsLast30Days.toString(),
                        icon: Icons.trending_up_rounded,
                        color: cs.tertiary,
                      ),
                    ],
                  );
                },
              ),
            ],

            const SizedBox(height: 32),

            // ─── Recent Items ───
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Recent Items',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                TextButton(
                  onPressed: () => context.go('/items'),
                  child: Text(
                    'See all',
                    style: TextStyle(
                      color: cs.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (itemProvider.isLoading && recentItems.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (recentItems.isEmpty)
              GlassPanel(
                borderRadius: 16,
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.inbox_rounded, size: 48, color: cs.outline),
                      const SizedBox(height: 12),
                      Text(
                        'No items yet',
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final cols = constraints.maxWidth > 900
                      ? 3
                      : (constraints.maxWidth > 500 ? 2 : 1);
                  final cardW = (constraints.maxWidth - (cols - 1) * 12) / cols;

                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: recentItems.map((item) {
                      final catName = item.categoryId != null
                          ? catMap[item.categoryId]
                          : null;
                      return SizedBox(
                        width: cardW,
                        child: GlassPanel(
                          borderRadius: 16,
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Thumbnail
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: SizedBox(
                                  width: 52,
                                  height: 52,
                                  child: item.imageUrl != null
                                      ? Image.network(
                                          '${ApiService.baseUrl}${item.imageUrl}',
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              Container(
                                                color:
                                                    cs.surfaceContainerHighest,
                                                child: Icon(
                                                  Icons.image_outlined,
                                                  size: 24,
                                                  color: cs.outline,
                                                ),
                                              ),
                                        )
                                      : Container(
                                          color: cs.surfaceContainerHighest,
                                          child: Icon(
                                            Icons.image_outlined,
                                            size: 24,
                                            color: cs.outline,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    if (catName != null)
                                      Text(
                                        catName,
                                        style: TextStyle(
                                          color: cs.onSurfaceVariant,
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),
                              if (item.rating != null)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      size: 16,
                                      color: Color(0xFFF59E0B),
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      '${item.rating}',
                                      style: const TextStyle(
                                        color: Color(0xFFF59E0B),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),

            // ─── Highlights ───
            const SizedBox(height: 32),
            Text(
              'Highlights',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            if (stats.fullStats?.records != null &&
                (stats.fullStats!.records!.topRated != null ||
                    stats.fullStats!.records!.newestAcquisition != null ||
                    stats.fullStats!.records!.bestCategory != null))
              GlassPanel(
                borderRadius: 16,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    if (stats.fullStats!.records!.topRated != null)
                      _RecordRow(
                        icon: Icons.emoji_events_rounded,
                        color: const Color(0xFFF59E0B),
                        label: 'Top Rated',
                        value:
                            '${stats.fullStats!.records!.topRated!.name} (${stats.fullStats!.records!.topRated!.rating}★)',
                      ),
                    if (stats.fullStats!.records!.newestAcquisition !=
                        null) ...[
                      Divider(color: cs.outline, height: 24),
                      _RecordRow(
                        icon: Icons.new_releases_rounded,
                        color: cs.tertiary,
                        label: 'Newest',
                        value:
                            stats.fullStats!.records!.newestAcquisition!.name,
                      ),
                    ],
                    if (stats.fullStats!.records!.bestCategory != null) ...[
                      Divider(color: cs.outline, height: 24),
                      _RecordRow(
                        icon: Icons.workspace_premium_rounded,
                        color: cs.secondary,
                        label: 'Best Category',
                        value:
                            '${stats.fullStats!.records!.bestCategory!.name} (${stats.fullStats!.records!.bestCategory!.avgRating}★)',
                      ),
                    ],
                  ],
                ),
              )
            else
              GlassPanel(
                borderRadius: 16,
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.emoji_events_outlined,
                        size: 40,
                        color: cs.outline,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No highlights yet',
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Start adding items to see your collection highlights here.',
                        style: TextStyle(
                          color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final double width;
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MiniStat({
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
        borderRadius: 16,
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
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

class _RecordRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _RecordRow({
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
