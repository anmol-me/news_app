// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

News _$NewsFromJson(Map<String, dynamic> json) => News(
      entryId: json['entryId'] as int,
      feedId: json['feedId'] as int,
      categoryTitle: json['categoryTitle'] as String,
      titleText: json['titleText'] as String,
      author: json['author'] as String,
      readTime: json['readTime'] as int,
      isFav: json['isFav'] as bool,
      link: json['link'] as String,
      content: json['content'] as String,
      imageUrl: json['imageUrl'] as String,
      status: json['status'] as Status,
      publishedTime: DateTime.parse(json['publishedTime'] as String),
      isExpanded: json['isExpanded'] as bool? ?? false,
    );

Map<String, dynamic> _$NewsToJson(News instance) => <String, dynamic>{
      'entryId': instance.entryId,
      'feedId': instance.feedId,
      'categoryTitle': instance.categoryTitle,
      'titleText': instance.titleText,
      'author': instance.author,
      'readTime': instance.readTime,
      'isFav': instance.isFav,
      'link': instance.link,
      'content': instance.content,
      'imageUrl': instance.imageUrl,
      'status': instance.status,
      'publishedTime': instance.publishedTime.toIso8601String(),
      'isExpanded': instance.isExpanded,
    };
