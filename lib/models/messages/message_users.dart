import 'package:mobx/mobx.dart';

part 'message_users.g.dart';

class MessagesUsers = MessagesUsersBase with _$MessagesUsers;

abstract class MessagesUsersBase with Store {
  MessagesUsersBase({
    this.id,
    this.userId,
    this.name,
    this.avatar,
    //this.url,
    this.verified,
    this.lastActive,
    this.isFriend,
    this.canVideo,
    this.canAudio,
    this.blocked,
    this.canBlock,
    this.isOnline,
  });

  MessagesUsersBase.fromJson(dynamic json) {
    id = json['id'];
    userId = json['user_id'];
    name = json['name'];
    avatar = json['avatar'];
    verified = json['verified'];
    lastActive = json['lastActive'];
    isFriend = json['isFriend'];
    canVideo = json['canVideo'];
    canAudio = json['canAudio'];
    blocked = json['blocked'];
    canBlock = json['canBlock'];
    isOnline = json['is_online'] is bool ? json['is_online'] : false;
  }

  @observable
  String? id;

  @observable
  int? userId;

  @observable
  String? name;

  @observable
  String? avatar;

  @observable
  int? verified;

  @observable
  String? lastActive;

  @observable
  int? isFriend;

  @observable
  int? canVideo;

  @observable
  int? canAudio;

  @observable
  int? blocked;

  @observable
  int? canBlock;

  @observable
  bool? isOnline;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['user_id'] = userId;
    map['name'] = name;
    map['avatar'] = avatar;
    //map['url'] = url;
    map['verified'] = verified;
    map['lastActive'] = lastActive;
    map['isFriend'] = isFriend;
    map['canVideo'] = canVideo;
    map['canAudio'] = canAudio;
    map['blocked'] = blocked;
    map['canBlock'] = canBlock;
    return map;
  }
}
