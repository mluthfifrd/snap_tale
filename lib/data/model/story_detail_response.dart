import 'package:json_annotation/json_annotation.dart';

part 'story_detail_response.g.dart';

@JsonSerializable()
class StoryDetailResponse {
  final bool error;
  final String message;
  final StoryDetailElement story;

  StoryDetailResponse({
    required this.error,
    required this.message,
    required this.story,
  });

  factory StoryDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$StoryDetailResponseFromJson(json);

  Map<String, dynamic> toJson() => _$StoryDetailResponseToJson(this);
}

@JsonSerializable()
class StoryDetailElement {
  final String id;
  final String name;
  final String description;
  final String photoUrl;
  final DateTime createdAt;
  final double? lat;
  final double? lon;

  StoryDetailElement({
    required this.id,
    required this.name,
    required this.description,
    required this.photoUrl,
    required this.createdAt,
    required this.lat,
    required this.lon,
  });

  factory StoryDetailElement.fromJson(Map<String, dynamic> json) =>
      _$StoryDetailElementFromJson(json);

  Map<String, dynamic> toJson() => _$StoryDetailElementToJson(this);
}
