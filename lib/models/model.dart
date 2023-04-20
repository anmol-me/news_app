class CategoryList {
  final int id;
  final String title;

  CategoryList({
    required this.id,
    required this.title,
  });

  CategoryList copyWith({
    int? id,
    String? title,
  }) {
    return CategoryList(
      id: id ?? this.id,
      title: title ?? this.title,
    );
  }
}


class DiscoverSubscription {
  final String title;
  final String url;

  DiscoverSubscription({
    required this.title,
    required this.url,
  });
}