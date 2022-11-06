class CategoryList {
  final int id;
  final String title;

  CategoryList({
    required this.id,
    required this.title,
  });
}


class AddNewSubscription {
  final String title;
  final String url;

  AddNewSubscription({
    required this.title,
    required this.url,
  });

// DiscoverSubscription copyWith(
//   String? title,
//   String? url,
// ) {
//   return DiscoverSubscription(
//     title: title ?? this.title,
//     url: url ?? this.url,
//   );
// }
}