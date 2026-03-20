import 'package:socialv/models/story/common_story_model.dart';

class HighlightStory {
  final String id;
  final String title;
  final String thumbnailUrl;

  final String? createdAt; // optional field for creation date
  final List<String> stories; // list of story URLs (images/videos)

  final List<CreateStoryModel> contentList;

  HighlightStory({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    this.createdAt, // optional field
    required this.stories,
    this.contentList = const [],
  });

  factory HighlightStory.fromJson(Map<String, dynamic> json) {
    return HighlightStory(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      thumbnailUrl: json['thumbnail_url'] ?? '',
      createdAt: json['created_at']?.toString(), // convert to string if not null
      stories: List<String>.from(json['stories'] ?? []),
      contentList:  (json['content_list'] as List<dynamic>?)
          ?.map((item) => CreateStoryModel.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

class StoryHighlightResponse {
  final bool status;
  final String message;
  final List<StoryHighlight> data;

  StoryHighlightResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory StoryHighlightResponse.fromJson(Map<String, dynamic> json) {
    return StoryHighlightResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => StoryHighlight.fromJson(e))
          .toList() ??
          [],
    );
  }
}

class StoryHighlight {
  final int id;
  final String? duration ; // Default duration set to 0
  final String? mediaType;
  final String? mediaUrl;
  final String? storyLink;
  final String? storyText;
  final int? createdTime;
  final bool isSeen;
  final int? viewCount;

  StoryHighlight.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? 0,
        duration = json['duration'] ?? 0,
        mediaType = json['media_type'] ?? '',
        mediaUrl = json['story_media'],
        storyLink = json['story_link'],
        storyText = json['story_text'],
        createdTime = json['time'] ?? 0,
        isSeen = json['seen'] ?? false,
        viewCount = json['view_count'] ?? 0;
}



