import 'package:json_annotation/json_annotation.dart';

part 'try.g.dart';

void main() {}

@JsonSerializable()
class Person {
  final String name;
  final int number;

  Person({
    required this.name,
    required this.number,
  });

  factory Person.fromJson(Map<String, dynamic> json) => _$PersonFromJson(json);

  Map<String, dynamic> toJson() => _$PersonToJson(this);
}
