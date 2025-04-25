import 'package:json_annotation/json_annotation.dart';

part 'story_add_response.g.dart';

@JsonSerializable()
class StoryAddResponse {
  final bool error;
  final String message;

  StoryAddResponse({
    required this.error,
    required this.message,
  });

  factory StoryAddResponse.fromJson(Map<String, dynamic> json) =>
      _$StoryAddResponseFromJson(json);

  Map<String, dynamic> toJson() => _$StoryAddResponseToJson(this);
}
