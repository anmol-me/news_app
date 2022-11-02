import 'package:flutter_riverpod/flutter_riverpod.dart';

class CategoryEntries {
  final int id;
  final String title;
  final String author;
  final int readTime;
  final bool isFav;
  final String status;
  final String link;
  final String content;
  final String imageUrl;

  CategoryEntries({
    required this.id,
    required this.title,
    required this.author,
    required this.readTime,
    required this.isFav,
    required this.status,
    required this.link,
    required this.content,
    required this.imageUrl,
  });

  CategoryEntries copyWith({
    int? id,
    String? title,
    String? author,
    int? readTime,
    bool? isFav,
    String? status,
    String? link,
    String? content,
    String? imageUrl,
  }) {
    return CategoryEntries(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      readTime: readTime ?? this.readTime,
      isFav: isFav ?? this.isFav,
      status: status ?? this.status,
      link: link ?? this.link,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

class CategoryEntriesNotifier extends StateNotifier {
  CategoryEntriesNotifier() : super([]);

  void fetchCategoryEntries() async {

  }
}
