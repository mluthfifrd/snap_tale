import 'package:json_annotation/json_annotation.dart';

part 'story_model.g.dart';

@JsonSerializable()
class StoryList {
  final bool error;
  final String message;
  final List<StoryListElement> listStory;

  StoryList({
    required this.error,
    required this.message,
    required this.listStory,
  });

  factory StoryList.fromJson(Map<String, dynamic> json) => _$StoryListFromJson(json);
  Map<String, dynamic> toJson() => _$StoryListToJson(this);
}

@JsonSerializable()
class StoryListElement {
  final String id;
  final String name;
  final String description;
  final String photoUrl;
  final DateTime createdAt;
  final double? lat;
  final double? lon;

  StoryListElement({
    required this.id,
    required this.name,
    required this.description,
    required this.photoUrl,
    required this.createdAt,
    required this.lat,
    required this.lon,
  });

  factory StoryListElement.fromJson(Map<String, dynamic> json) => _$StoryListElementFromJson(json);
  Map<String, dynamic> toJson() => _$StoryListElementToJson(this);
}