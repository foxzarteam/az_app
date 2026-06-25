/// Active service row from GET /api/services (server filters `is_active`).
class ActiveService {
  const ActiveService({
    required this.slug,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.sortOrder,
  });

  final String slug;
  final String title;
  final String description;
  final String imageUrl;
  final int sortOrder;

  Map<String, dynamic> toMap() => {
        'slug': slug,
        'title': title,
        'description': description,
        'imageUrl': imageUrl,
        'sortOrder': sortOrder,
      };

  factory ActiveService.fromMap(Map<String, dynamic> map) {
    final sortRaw = map['sortOrder'] ?? map['sort_order'];
    var sortOrder = 0;
    if (sortRaw is int) {
      sortOrder = sortRaw;
    } else if (sortRaw is num) {
      sortOrder = sortRaw.toInt();
    }

    return ActiveService(
      slug: (map['slug'] ?? '').toString().trim(),
      title: (map['title'] ?? '').toString().trim(),
      description: (map['description'] ?? '').toString().trim(),
      imageUrl: (map['imageUrl'] ?? map['image_url'] ?? '').toString().trim(),
      sortOrder: sortOrder,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ActiveService &&
        other.slug == slug &&
        other.title == title &&
        other.description == description &&
        other.imageUrl == imageUrl &&
        other.sortOrder == sortOrder;
  }

  @override
  int get hashCode => Object.hash(slug, title, description, imageUrl, sortOrder);
}

bool activeServicesListEquals(List<ActiveService> a, List<ActiveService> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
