class StoryReactionModel {
  int? isReacted;
  bool? status;
  String? message;

  StoryReactionModel({this.isReacted, this.status, this.message});

  factory StoryReactionModel.fromJson(Map<String, dynamic> json) {
    return StoryReactionModel(
      isReacted: json['is_reacted'],
      status: json["status"],
      message: json["message"],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['is_reacted'] = this.isReacted;
    data['status'] = this.status;
    data['message'] = this.message;
    return data;
  }
}
