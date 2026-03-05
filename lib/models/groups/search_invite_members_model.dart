import 'dart:convert';

import 'group_request_model.dart';

class SearchInviteMembers {
  bool status;
  String message;
  List<InviteData> data;

  SearchInviteMembers({
    this.status = false,
    this.message = "",
    this.data = const <InviteData>[],
  });

  factory SearchInviteMembers.fromJson(Map<String, dynamic> json) {
    return SearchInviteMembers(
      status: json['status'] ?? false,
      message: json['message'] ?? "",
      data: json['data'] != null ? List<InviteData>.from(json['data'].map((x) => InviteData.fromJson(x))) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

class InviteData {
  int userId;
  bool isInvited;
  String userName;
  String userImage;
  bool isUserVerified;

  InviteData({
    this.userId = -1,
    this.isInvited = false,
    this.userName = "",
    this.userImage = "",
    this.isUserVerified = false,
  });

  factory InviteData.fromJson(Map<String, dynamic> json) {
    return InviteData(
      userId: json['user_Id'] ?? -1,
      isInvited: json['is_invited'] ?? false,
      userName: json['user_name'] ?? "",
      userImage: json['user_image'] ?? "",
      isUserVerified: json['is_user_verified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_Id': userId,
      'is_invited': isInvited,
      'user_name': userName,
      'user_image': userImage,
      'is_user_verified': isUserVerified,
    };
  }
}

List<GroupInviteModel> convertInviteDataToGroupInviteModel(List<InviteData> inviteList) {
  return inviteList.map((invite) {
    GroupInviteModel groupInvite = GroupInviteModel(
      requestId: null,
      userId: invite.userId,
      userImage: invite.userImage,
      userMentionName: null,
      userName: invite.userName,
      isInvited: invite.isInvited,
      isUserVerified: invite.isUserVerified,
    );

    String jsonString = jsonEncode(groupInvite);

    GroupInviteModel newGroupInvite = GroupInviteModel.fromJson(jsonDecode(jsonString));

    return newGroupInvite;
  }).toList();
}
