import 'package:mobx/mobx.dart';
import 'package:socialv/models/messages/chat_background_model.dart';
import 'permissions.dart';

part 'threads_model.g.dart';

class Threads = _ThreadsBase with _$Threads;

abstract class _ThreadsBase with Store {
  _ThreadsBase({
    this.threadId,
    this.lastMessage,
    this.isHidden,
    this.isDeleted,
    this.subject,
    this.lastTime,
    this.participants,
    this.participantsCount,
    this.type,
    this.title,
    this.image,
    this.meta,
    this.isPinned,
    this.permissions,
    this.unread,
    this.secretKey,
    this.chatBackground,
  });

  @observable
  int? threadId;

  @observable
  int? lastMessage;

  @observable
  int? isHidden;

  @observable
  int? isDeleted;

  @observable
  String? subject;

  @observable
  int? lastTime;

  @observable
  List<int>? participants;

  @observable
  List<int>? moderators;

  @observable
  int? participantsCount;

  @observable
  String? type;

  @observable
  bool? isMuted;

  @observable
  String? title;

  @observable
  String? image;

  @observable
  Meta? meta;

  @observable
  int? isPinned;

  @observable
  Permissions? permissions;

  @observable
  List<dynamic>? mentions;

  @observable
  int? unread;

  @observable
  String? secretKey;

  @observable
  ChatBackgroundModel? chatBackground;

  _ThreadsBase.fromJson(dynamic json) {
    threadId = json['thread_id'];
    lastMessage = json['lastMessage'];
    isHidden = json['isHidden'];
    isDeleted = json['isDeleted'];
    subject = json['subject'];
    lastTime = json['lastTime'] is int ? json['lastTime'] : int.tryParse(json['lastTime'].toString());
    participants = json['participants'] != null ? json['participants'].cast<int>() : [];
    moderators = json['moderators'] != null ? json['moderators'].cast<int>() : [];
    participantsCount = json['participantsCount'];
    type = json['type'];
    title = json['title'];
    isMuted = json['isMuted'];
    image = json['image'];
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
    isPinned = json['isPinned'];
    permissions = json['permissions'] != null ? Permissions.fromJson(json['permissions']) : null;
    mentions = json['mentions'] != null ? (json['mentions'] as List).map((i) => i.fromJson(i)).toList() : null;
    unread = json['unread'];
    secretKey = json['secret_key'];
    chatBackground = json['chat_background'] != null ? ChatBackgroundModel.fromJson(json['chat_background']) : null;
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['thread_id'] = threadId;
    map['lastTime'] = lastMessage;
    map['isHidden'] = isHidden;
    map['isDeleted'] = isDeleted;
    map['subject'] = subject;
    map['participants'] = participants;
    map['participantsCount'] = participantsCount;
    map['type'] = type;
    map['title'] = title;
    map['isMuted'] = isMuted;
    map['image'] = image;
    map['secret_key'] = secretKey;
    if (meta != null) {
      map['meta'] = meta!.toJson();
    }
    map['isPinned'] = isPinned;
    if (permissions != null) {
      map['permissions'] = permissions!.toJson();
    }
    map['unread'] = unread;
    if (chatBackground != null) {
      map['chat_background'] = chatBackground!.toJson();
    }
    return map;
  }
}

class Meta {
  Meta({this.allowInvite});

  Meta.fromJson(dynamic json) {
    allowInvite = json['allowInvite'];
  }

  @observable
  bool? allowInvite;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['allowInvite'] = allowInvite;
    return map;
  }
}
