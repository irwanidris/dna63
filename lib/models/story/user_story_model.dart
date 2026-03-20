import 'dart:convert';

class UserStoryModel {
  bool? status;
  String? message;
  UserStoryData? data;

  UserStoryModel({
    this.status,
    this.message,
    this.data,
  });

  factory UserStoryModel.fromRawJson(String str) => UserStoryModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UserStoryModel.fromJson(Map<String, dynamic> json) => UserStoryModel(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? null : UserStoryData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class UserStoryData {
  int? userId;
  String? avatarUrl;
  String? name;
  int? lastUpdated;
  bool? isUserVerified;
  bool? seen;
  List<Item>? items;

  bool? showBorder;

  UserStoryData({
    this.userId,
    this.avatarUrl,
    this.name,
    this.lastUpdated,
    this.isUserVerified,
    this.seen,
    this.showBorder = false,
    this.items,
  });

  factory UserStoryData.fromRawJson(String str) => UserStoryData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UserStoryData.fromJson(Map<String, dynamic> json) => UserStoryData(
    userId: json["user_id"],
    avatarUrl: json["avatar_url"],
    name: json["name"],
    lastUpdated: json["lastUpdated"],
    isUserVerified: json["is_user_verified"],
    seen: json["seen"],
    items: json["items"] == null ? [] : List<Item>.from(json["items"]!.map((x) => Item.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "avatar_url": avatarUrl,
    "name": name,
    "lastUpdated": lastUpdated,
    "is_user_verified": isUserVerified,
    "seen": seen,
    "items": items == null ? [] : List<dynamic>.from(items!.map((x) => x.toJson())),
  };
}

class Item {
  int? id;
  String? seenByKey;
  String? duration;
  String? mediaType;
  String? storyMedia;
  String? storyLink;
  String? storyText;
  int? time;
  bool? seen;
  int? viewCount;

  Item({
    this.id,
    this.seenByKey,
    this.duration,
    this.mediaType,
    this.storyMedia,
    this.storyLink,
    this.storyText,
    this.time,
    this.seen,
    this.viewCount,
  });

  factory Item.fromRawJson(String str) => Item.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    id: json["id"],
    seenByKey: json["seen_by_key"],
    duration: json["duration"],
    mediaType: json["media_type"],
    storyMedia: json["story_media"],
    storyLink: json["story_link"],
    storyText: json["story_text"],
    time: json["time"],
    seen: json["seen"],
    viewCount: json["view_count"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "seen_by_key": seenByKey,
    "duration": duration,
    "media_type": mediaType,
    "story_media": storyMedia,
    "story_link": storyLink,
    "story_text": storyText,
    "time": time,
    "seen": seen,
    "view_count": viewCount,
  };
}
