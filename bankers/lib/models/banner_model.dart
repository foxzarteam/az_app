class BannerModel {
  final String id;
  final String imageUrl;
  final String? title;
  final String? description;
  final String category;
  final int displayOrder;
  final String? actionUrl;
  final String? actionType;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  BannerModel({
    required this.id,
    required this.imageUrl,
    this.title,
    this.description,
    required this.category,
    required this.displayOrder,
    this.actionUrl,
    this.actionType,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] as String,
      imageUrl: json['imageUrl'] as String,
      title: json['title'] as String?,
      description: json['description'] as String?,
      category: json['category'] as String? ?? 'carousel',
      displayOrder: json['displayOrder'] as int? ?? 0,
      actionUrl: json['actionUrl'] as String?,
      actionType: json['actionType'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'title': title,
      'description': description,
      'category': category,
      'displayOrder': displayOrder,
      'actionUrl': actionUrl,
      'actionType': actionType,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
