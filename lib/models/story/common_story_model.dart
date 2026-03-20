import 'dart:io';

import 'package:mobx/mobx.dart';
part 'common_story_model.g.dart';

/// Common Story Models
class CreateStoryModel = CreateStoryModelBase with _$CreateStoryModel;

abstract class CreateStoryModelBase with Store {
  String? storyText;
  String? storyLink;
  @observable
  String storyDuration;

  CreateStoryModelBase({this.storyText, this.storyLink, required this.storyDuration});
  CreateStoryModelBase.fromJson(Map<String, dynamic> json)
      : storyText = json['story_text'],
        storyLink = json['story_link'],
        storyDuration = json['story_duration'] ?? '24';
}

class MediaSourceModel {
  File mediaFile;
  String extension;
  String mediaType;

  MediaSourceModel({required this.mediaFile, required this.extension, required this.mediaType});
}
