// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story_add_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StoryAddResponse _$StoryAddResponseFromJson(Map<String, dynamic> json) =>
    StoryAddResponse(
      error: json['error'] as bool,
      message: json['message'] as String,
    );

Map<String, dynamic> _$StoryAddResponseToJson(StoryAddResponse instance) =>
    <String, dynamic>{'error': instance.error, 'message': instance.message};
