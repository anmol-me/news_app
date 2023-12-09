import 'dart:convert';

import '../../common/enums.dart';
import '../../models/model.dart';
import '../../models/news.dart';

class MyCombinedCodec extends Codec<Object?, Object?> {
  const MyCombinedCodec();

  @override
  Converter<Object?, Object?> get decoder => const _MyCombinedDecoder();

  @override
  Converter<Object?, Object?> get encoder => const _MyCombinedEncoder();
}

class _MyCombinedDecoder extends Converter<Object?, Object?> {
  const _MyCombinedDecoder();

  @override
  Object? convert(Object? input) {
    if (input == null) {
      return null;
    }

    final List<Object?> inputAsList = input as List<Object?>;

    if (inputAsList.isEmpty) {
      return null;
    }

    final String typeName = inputAsList[0] as String;
    final Object? data = inputAsList[1];

    switch (typeName) {
      case 'News':
        return _decodeNews(data);
      case 'CategoryList':
        return _decodeCategoryList(data);
      case 'DiscoverSubscription':
        return _decodeDiscoverSubscription(data);
      default:
        throw FormatException('Unknown type: $typeName');
    }
  }

  Object? _decodeNews(Object? data) {
    if (data == null) {
      return null;
    }

    final Map<String, dynamic> newsData = data as Map<String, dynamic>;

    return News(
      entryId: newsData['entryId'] as int,
      feedId: newsData['feedId'] as int,
      catId: newsData['catId'] as int,
      categoryTitle: newsData['categoryTitle'] as String,
      titleText: newsData['titleText'] as String,
      author: newsData['author'] as String,
      readTime: newsData['readTime'] as int,
      isFav: newsData['isFav'] as bool,
      link: newsData['link'] as String,
      content: newsData['content'] as String,
      imageUrl: newsData['imageUrl'] as String,
      status: Status.values.firstWhere((e) => e.value == newsData['status']),
      publishedTime: DateTime.parse(newsData['publishedTime'] as String),
      isExpanded: newsData['isExpanded'] as bool? ?? false,
    );
  }

  Object? _decodeCategoryList(Object? data) {
    if (data == null) {
      return null;
    }

    final Map<String, dynamic> categoryListData = data as Map<String, dynamic>;

    return CategoryList(
      id: categoryListData['id'] as int,
      title: categoryListData['title'] as String,
    );
  }

  Object? _decodeDiscoverSubscription(Object? data) {
    if (data == null) {
      return null;
    }

    final Map<String, dynamic> discoverSubscriptionData = data as Map<String, dynamic>;

    return DiscoverSubscription(
      title: discoverSubscriptionData['title'] as String,
      url: discoverSubscriptionData['url'] as String,
    );
  }
}

class _MyCombinedEncoder extends Converter<Object?, Object?> {
  const _MyCombinedEncoder();

  @override
  Object? convert(Object? input) {
    if (input == null) {
      return null;
    }

    if (input is News) {
      return _encodeNews(input);
    } else if (input is CategoryList) {
      return _encodeCategoryList(input);
    } else if (input is DiscoverSubscription) {
      return _encodeDiscoverSubscription(input);
    }

    throw FormatException('Unknown type: ${input.runtimeType}');
  }

  List<Object?> _encodeNews(News news) {
    return <Object?>[
      'News',
      <String, dynamic>{
        'entryId': news.entryId,
        'feedId': news.feedId,
        'catId': news.catId,
        'categoryTitle': news.categoryTitle,
        'titleText': news.titleText,
        'author': news.author,
        'readTime': news.readTime,
        'isFav': news.isFav,
        'link': news.link,
        'content': news.content,
        'imageUrl': news.imageUrl,
        'status': news.status.value,
        'publishedTime': news.publishedTime.toIso8601String(),
        'isExpanded': news.isExpanded,
      },
    ];
  }

  List<Object?> _encodeCategoryList(CategoryList categoryList) {
    return <Object?>[
      'CategoryList',
      <String, dynamic>{
        'id': categoryList.id,
        'title': categoryList.title,
      },
    ];
  }

  List<Object?> _encodeDiscoverSubscription(DiscoverSubscription discoverSubscription) {
    return <Object?>[
      'DiscoverSubscription',
      <String, dynamic>{
        'title': discoverSubscription.title,
        'url': discoverSubscription.url,
      },
    ];
  }
}
