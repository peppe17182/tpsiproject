class Category {
  final int id;
  final String name;
  final String? description;
  final int? userId;
  final String? createdAt;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.userId,
    this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      userId: json['user_id'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
    };
  }
}
