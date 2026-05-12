class Item {
  final int id;
  final String name;
  final String? description;
  final int? rating;
  final String? acquisitionDate;
  final String? imageUrl;
  final int? userId;
  final int? categoryId;
  final String? createdAt;

  Item({
    required this.id,
    required this.name,
    this.description,
    this.rating,
    this.acquisitionDate,
    this.imageUrl,
    this.userId,
    this.categoryId,
    this.createdAt,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      rating: json['rating'] != null ? int.tryParse(json['rating'].toString()) : null,
      acquisitionDate: json['acquisition_date'],
      imageUrl: json['image_url'] != null ? '${json['image_url']}?v=${DateTime.now().millisecondsSinceEpoch}' : null,
      userId: json['user_id'] != null ? int.tryParse(json['user_id'].toString()) : null,
      categoryId: json['category_id'] != null ? int.tryParse(json['category_id'].toString()) : null,
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'rating': rating,
      'acquisition_date': acquisitionDate,
      'category_id': categoryId,
    };
  }
}
