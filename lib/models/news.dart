import 'package:json_annotation/json_annotation.dart';
import 'package:news_app/common/enums.dart';

class News {
  final int entryId;
  final int feedId;
  final int catId;
  final String categoryTitle;
  final String titleText;
  final String author;
  final int readTime;
  final bool isFav;
  final String link;
  final String content;
  final String imageUrl;
  final Status status;
  final DateTime publishedTime;
  bool isExpanded;

  News({
    required this.entryId,
    required this.feedId,
    required this.catId,
    required this.categoryTitle,
    required this.titleText,
    required this.author,
    required this.readTime,
    required this.isFav,
    required this.link,
    required this.content,
    required this.imageUrl,
    required this.status,
    required this.publishedTime,
    this.isExpanded = false,
  });

  News copyWith({
    int? entryId,
    int? feedId,
    int? catId,
    String? categoryTitle,
    String? titleText,
    String? author,
    int? readTime,
    bool? isFav,
    String? link,
    String? content,
    String? imageUrl,
    Status? status,
    int? total,
    DateTime? publishedTime,
    bool? isExpanded,
  }) {
    return News(
      entryId: entryId ?? this.entryId,
      feedId: feedId ?? this.feedId,
      catId: catId ?? this.catId,
      categoryTitle: categoryTitle ?? this.categoryTitle,
      titleText: titleText ?? this.titleText,
      author: author ?? this.author,
      readTime: readTime ?? this.readTime,
      isFav: isFav ?? this.isFav,
      link: link ?? this.link,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      publishedTime: publishedTime ?? this.publishedTime,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}
