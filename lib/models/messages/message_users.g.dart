// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_users.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$MessagesUsers on MessagesUsersBase, Store {
  late final _$idAtom = Atom(name: 'MessagesUsersBase.id', context: context);

  @override
  String? get id {
    _$idAtom.reportRead();
    return super.id;
  }

  @override
  set id(String? value) {
    _$idAtom.reportWrite(value, super.id, () {
      super.id = value;
    });
  }

  late final _$userIdAtom =
      Atom(name: 'MessagesUsersBase.userId', context: context);

  @override
  int? get userId {
    _$userIdAtom.reportRead();
    return super.userId;
  }

  @override
  set userId(int? value) {
    _$userIdAtom.reportWrite(value, super.userId, () {
      super.userId = value;
    });
  }

  late final _$nameAtom =
      Atom(name: 'MessagesUsersBase.name', context: context);

  @override
  String? get name {
    _$nameAtom.reportRead();
    return super.name;
  }

  @override
  set name(String? value) {
    _$nameAtom.reportWrite(value, super.name, () {
      super.name = value;
    });
  }

  late final _$avatarAtom =
      Atom(name: 'MessagesUsersBase.avatar', context: context);

  @override
  String? get avatar {
    _$avatarAtom.reportRead();
    return super.avatar;
  }

  @override
  set avatar(String? value) {
    _$avatarAtom.reportWrite(value, super.avatar, () {
      super.avatar = value;
    });
  }

  late final _$verifiedAtom =
      Atom(name: 'MessagesUsersBase.verified', context: context);

  @override
  int? get verified {
    _$verifiedAtom.reportRead();
    return super.verified;
  }

  @override
  set verified(int? value) {
    _$verifiedAtom.reportWrite(value, super.verified, () {
      super.verified = value;
    });
  }

  late final _$lastActiveAtom =
      Atom(name: 'MessagesUsersBase.lastActive', context: context);

  @override
  String? get lastActive {
    _$lastActiveAtom.reportRead();
    return super.lastActive;
  }

  @override
  set lastActive(String? value) {
    _$lastActiveAtom.reportWrite(value, super.lastActive, () {
      super.lastActive = value;
    });
  }

  late final _$isFriendAtom =
      Atom(name: 'MessagesUsersBase.isFriend', context: context);

  @override
  int? get isFriend {
    _$isFriendAtom.reportRead();
    return super.isFriend;
  }

  @override
  set isFriend(int? value) {
    _$isFriendAtom.reportWrite(value, super.isFriend, () {
      super.isFriend = value;
    });
  }

  late final _$canVideoAtom =
      Atom(name: 'MessagesUsersBase.canVideo', context: context);

  @override
  int? get canVideo {
    _$canVideoAtom.reportRead();
    return super.canVideo;
  }

  @override
  set canVideo(int? value) {
    _$canVideoAtom.reportWrite(value, super.canVideo, () {
      super.canVideo = value;
    });
  }

  late final _$canAudioAtom =
      Atom(name: 'MessagesUsersBase.canAudio', context: context);

  @override
  int? get canAudio {
    _$canAudioAtom.reportRead();
    return super.canAudio;
  }

  @override
  set canAudio(int? value) {
    _$canAudioAtom.reportWrite(value, super.canAudio, () {
      super.canAudio = value;
    });
  }

  late final _$blockedAtom =
      Atom(name: 'MessagesUsersBase.blocked', context: context);

  @override
  int? get blocked {
    _$blockedAtom.reportRead();
    return super.blocked;
  }

  @override
  set blocked(int? value) {
    _$blockedAtom.reportWrite(value, super.blocked, () {
      super.blocked = value;
    });
  }

  late final _$canBlockAtom =
      Atom(name: 'MessagesUsersBase.canBlock', context: context);

  @override
  int? get canBlock {
    _$canBlockAtom.reportRead();
    return super.canBlock;
  }

  @override
  set canBlock(int? value) {
    _$canBlockAtom.reportWrite(value, super.canBlock, () {
      super.canBlock = value;
    });
  }

  @override
  String toString() {
    return '''
id: ${id},
userId: ${userId},
name: ${name},
avatar: ${avatar},
verified: ${verified},
lastActive: ${lastActive},
isFriend: ${isFriend},
canVideo: ${canVideo},
canAudio: ${canAudio},
blocked: ${blocked},
canBlock: ${canBlock}
    ''';
  }
}
