class Stats {
  final int totalItems;
  final int totalCategories;
  final double averageRating;

  Stats({
    required this.totalItems,
    required this.totalCategories,
    required this.averageRating,
  });

  factory Stats.fromJson(Map<String, dynamic> json) {
    final overview = json['overview'] ?? json;
    return Stats(
      totalItems: overview['total_items'] != null ? int.tryParse(overview['total_items'].toString()) ?? 0 : 0,
      totalCategories: overview['total_categories'] != null ? int.tryParse(overview['total_categories'].toString()) ?? 0 : 0,
      averageRating: overview['average_rating'] != null ? double.tryParse(overview['average_rating'].toString()) ?? 0.0 : 0.0,
    );
  }
}
