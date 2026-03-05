import 'dart:convert';

class StoryReactionListModel {
  bool? status;
  String? message;
  List<ReactionList>? data;

  StoryReactionListModel({
    this.status,
    this.message,
    this.data,
  });

  factory StoryReactionListModel.fromRawJson(String str) => StoryReactionListModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory StoryReactionListModel.fromJson(Map<String, dynamic> json) => StoryReactionListModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? [] : List<ReactionList>.from(json["data"]!.map((x) => ReactionList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class ReactionList {
  int? id;
  String? name;
  ReactionEmoji? image;

  ReactionList({
    this.id,
    this.name,
    this.image,
  });

  factory ReactionList.fromRawJson(String str) => ReactionList.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ReactionList.fromJson(Map<String, dynamic> json) => ReactionList(
        id: json["id"],
        name: json["name"],
        image: json["image"] == null ? null : ReactionEmoji.fromJson(json["image"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "image": image?.toJson(),
      };
}

class ReactionEmoji {
  String? url;
  String? id;
  String? height;
  String? width;
  String? thumbnail;

  ReactionEmoji({
    this.url,
    this.id,
    this.height,
    this.width,
    this.thumbnail,
  });

  factory ReactionEmoji.fromRawJson(String str) => ReactionEmoji.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ReactionEmoji.fromJson(Map<String, dynamic> json) => ReactionEmoji(
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