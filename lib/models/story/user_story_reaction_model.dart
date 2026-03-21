import 'dart:convert';

class UserStoryReactionModel {
  bool? status;
  String? message;
  List<UserStoryReactionList>? data;

  UserStoryReactionModel({
    this.status,
    this.message,
    this.data,
  });

  factory UserStoryReactionModel.fromRawJson(String str) => UserStoryReactionModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UserStoryReactionModel.fromJson(Map<String, dynamic> json) => UserStoryReactionModel(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? [] : List<UserStoryReactionList>.from(json["data"]!.map((x) => UserStoryReactionList.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class UserStoryReactionList {
  String? userId;
  String? storyId;
  int? reactionId;
  String? reactionName;
  ReactionImage? reactionImage;

  UserStoryReactionList({
    this.userId,
    this.storyId,
    this.reactionId,
    this.reactionName,
    this.reactionImage,
  });

  factory UserStoryReactionList.fromJson(Map<String, dynamic> json) => UserStoryReactionList(
    userId: json["user_id"],
    storyId: json["story_id"],
    reactionId: json["reaction_id"],
    reactionName: json["reaction_name"],
    reactionImage: json["reaction_image"] != null ? ReactionImage.fromJson(json["reaction_image"]) : null,
  );

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "story_id": storyId,
    "reaction_id": reactionId,
    "reaction_name": reactionName,
    "reaction_image": reactionImage?.toJson(),
  };
}

class ReactionImage {
  String? url;
  String? id;
  String? height;
  String? width;
  String? thumbnail;

  ReactionImage({
    this.url,
    this.id,
    this.height,
    this.width,
    this.thumbnail,
  });

  factory ReactionImage.fromJson(Map<String, dynamic> json) => ReactionImage(
    url: json["url"],
    id: json["id"],
    height: json["height"],
    width: json["width"],
    thumbnail: json["thumbnail"],
  );

  Map<String, dynamic> toJson() => {
    "url": url,
    "id": id,
    "height": height,
    "width": width,
    "thumbnail": thumbnail,
  };
}
