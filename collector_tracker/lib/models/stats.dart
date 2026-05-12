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
    return Stats(
      totalItems: json['total_items'] != null ? int.tryParse(json['total_items'].toString()) ?? 0 : 0,
      totalCategories: json['total_categories'] != null ? int.tryParse(json['total_categories'].toString()) ?? 0 : 0,
      averageRating: json['average_rating'] != null ? double.tryParse(json['average_rating'].toString()) ?? 0.0 : 0.0,
    );
  }
}
