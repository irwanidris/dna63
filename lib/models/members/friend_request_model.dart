import 'package:mobx/mobx.dart';

part 'friend_request_model.g.dart';

class FriendListResponse {
  bool status;
  String message;
  int count;
  List<FriendRequestModel> friendList;

  FriendListResponse({
    this.status = false,
    this.message = "",
    this.count = -1,
    this.friendList = const <FriendRequestModel>[],
  });

  factory FriendListResponse.fromJson(Map<String, dynamic> json) {
    return FriendListResponse(
      status: json['status'] is bool ? json['status'] : false,
      message: json['message'] is String ? json['message'] : "",
      count: json['count'] is int ? json['count'] : -1,
      friendList: json['data'] is List ? List<FriendRequestModel>.from(json['data'].map((x) => FriendRequestModel.fromJson(x))) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'count': count,
      'data': friendList.map((e) => e.toJson()).toList(),
    };
  }
}

class FriendRequestModel = FriendRequestModelBase with _$FriendRequestModel;

abstract class FriendRequestModelBase with Store {
  int? userId;
  String? userName;
  String? userMentionName;
  String? userImage;
  bool? isUserVerified;
  @observable
  bool? isRequested;

  FriendRequestModelBase({
    this.userId = -1,
    this.userName = "",
    this.userMentionName = "",
    this.userImage = "",
    this.isUserVerified = false,
    this.isRequested = false,
  });

  FriendRequestModelBase.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'] is int ? json['user_id'] : -1;
    userName = json['user_name'] is String ? json['user_name'] : "";
    userMentionName = json['user_mention_name'] is String ? json['user_mention_name'] : "";
    userImage = json['user_image'] is String ? json['user_image'] : "";
    isUserVerified = json['is_user_verified'] is bool ? json['is_user_verified'] : false;
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_name': userName,
      'user_mention_name': userMentionName,
      'user_image': userImage,
      'is_user_verified': isUserVerified,
    };
  }
}
