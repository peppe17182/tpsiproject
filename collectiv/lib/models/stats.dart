class FullStats {
  final StatsOverview overview;
  final List<CategoryStat> byCategory;
  final List<RatingBucket> ratingDistribution;
  final List<TimelineEntry> acquisitionTimeline;
  final StatsRecords? records;

  FullStats({
    required this.overview,
    required this.byCategory,
    required this.ratingDistribution,
    required this.acquisitionTimeline,
    this.records,
  });

  factory FullStats.fromJson(Map<String, dynamic> json) {
    final overview = json['overview'] ?? json;
    return FullStats(
      overview: StatsOverview.fromJson(overview),
      byCategory:
          (json['by_category'] as List<dynamic>?)
              ?.map((e) => CategoryStat.fromJson(e))
              .toList() ??
          [],
      ratingDistribution:
          (json['rating_distribution'] as List<dynamic>?)
              ?.map((e) => RatingBucket.fromJson(e))
              .toList() ??
          [],
      acquisitionTimeline:
          (json['acquisition_timeline'] as List<dynamic>?)
              ?.map((e) => TimelineEntry.fromJson(e))
              .toList() ??
          [],
      records: json['records'] != null
          ? StatsRecords.fromJson(json['records'])
          : null,
    );
  }
}

class StatsOverview {
  final int totalItems;
  final int totalCategories;
  final double averageRating;
  final int collectorScore;
  final double gradingConsistency;
  final int perfectItems;
  final int itemsWithImages;
  final int itemsLast30Days;

  StatsOverview({
    required this.totalItems,
    required this.totalCategories,
    required this.averageRating,
    required this.collectorScore,
    required this.gradingConsistency,
    required this.perfectItems,
    required this.itemsWithImages,
    required this.itemsLast30Days,
  });

  factory StatsOverview.fromJson(Map<String, dynamic> json) {
    return StatsOverview(
      totalItems: _parseInt(json['total_items']),
      totalCategories: _parseInt(json['total_categories']),
      averageRating: _parseDouble(json['average_rating']),
      collectorScore: _parseInt(json['collector_score']),
      gradingConsistency: _parseDouble(json['grading_consistency']),
      perfectItems: _parseInt(json['perfect_items']),
      itemsWithImages: _parseInt(json['items_with_images']),
      itemsLast30Days: _parseInt(json['items_last_30_days']),
    );
  }
}

class CategoryStat {
  final int id;
  final String category;
  final int count;
  final double avgRating;

  CategoryStat({
    required this.id,
    required this.category,
    required this.count,
    required this.avgRating,
  });

  factory CategoryStat.fromJson(Map<String, dynamic> json) {
    return CategoryStat(
      id: _parseInt(json['id']),
      category: json['category'] ?? '',
      count: _parseInt(json['count']),
      avgRating: _parseDouble(json['avg_rating']),
    );
  }
}

class RatingBucket {
  final int rating;
  final int count;

  RatingBucket({required this.rating, required this.count});

  factory RatingBucket.fromJson(Map<String, dynamic> json) {
    return RatingBucket(
      rating: _parseInt(json['rating']),
      count: _parseInt(json['count']),
    );
  }
}

class TimelineEntry {
  final int year;
  final int count;

  TimelineEntry({required this.year, required this.count});

  factory TimelineEntry.fromJson(Map<String, dynamic> json) {
    return TimelineEntry(
      year: _parseInt(json['year']),
      count: _parseInt(json['count']),
    );
  }
}

class StatsRecords {
  final RecordItem? topRated;
  final RecordItem? oldestAcquisition;
  final RecordItem? newestAcquisition;
  final BestCategory? bestCategory;

  StatsRecords({
    this.topRated,
    this.oldestAcquisition,
    this.newestAcquisition,
    this.bestCategory,
  });

  factory StatsRecords.fromJson(Map<String, dynamic> json) {
    return StatsRecords(
      topRated: json['top_rated'] != null
          ? RecordItem.fromJson(json['top_rated'])
          : null,
      oldestAcquisition: json['oldest_acquisition'] != null
          ? RecordItem.fromJson(json['oldest_acquisition'])
          : null,
      newestAcquisition: json['newest_acquisition'] != null
          ? RecordItem.fromJson(json['newest_acquisition'])
          : null,
      bestCategory: json['best_category'] != null
          ? BestCategory.fromJson(json['best_category'])
          : null,
    );
  }
}

class RecordItem {
  final int id;
  final String name;
  final int? rating;
  final String? acquisitionDate;

  RecordItem({
    required this.id,
    required this.name,
    this.rating,
    this.acquisitionDate,
  });

  factory RecordItem.fromJson(Map<String, dynamic> json) {
    return RecordItem(
      id: _parseInt(json['id']),
      name: json['name'] ?? '',
      rating: json['rating'] != null ? _parseInt(json['rating']) : null,
      acquisitionDate: json['acquisition_date'],
    );
  }
}

class BestCategory {
  final String name;
  final double avgRating;

  BestCategory({required this.name, required this.avgRating});

  factory BestCategory.fromJson(Map<String, dynamic> json) {
    return BestCategory(
      name: json['name'] ?? '',
      avgRating: _parseDouble(json['avg_rating']),
    );
  }
}

// Helpers
int _parseInt(dynamic v) => v != null ? (int.tryParse(v.toString()) ?? 0) : 0;
double _parseDouble(dynamic v) =>
    v != null ? (double.tryParse(v.toString()) ?? 0.0) : 0.0;

// Keep backward compat alias
typedef Stats = StatsOverview;
