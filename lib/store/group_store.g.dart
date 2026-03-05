// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$GroupStore on GroupStoreBase, Store {
  late final _$isErrorAtom =
      Atom(name: 'GroupStoreBase.isError', context: context);

  @override
  bool get isError {
    _$isErrorAtom.reportRead();
    return super.isError;
  }

  @override
  set isError(bool value) {
    _$isErrorAtom.reportWrite(value, super.isError, () {
      super.isError = value;
    });
  }

  late final _$groupListAtom =
      Atom(name: 'GroupStoreBase.groupList', context: context);

  @override
  ObservableList<GroupModel> get groupList {
    _$groupListAtom.reportRead();
    return super.groupList;
  }

  @override
  set groupList(ObservableList<GroupModel> value) {
    _$groupListAtom.reportWrite(value, super.groupList, () {
      super.groupList = value;
    });
  }

  late final _$errorMSGAtom =
      Atom(name: 'GroupStoreBase.errorMSG', context: context);

  @override
  String get errorMSG {
    _$errorMSGAtom.reportRead();
    return super.errorMSG;
  }

  @override
  set errorMSG(String value) {
    _$errorMSGAtom.reportWrite(value, super.errorMSG, () {
      super.errorMSG = value;
    });
  }

  late final _$postListAtom =
      Atom(name: 'GroupStoreBase.postList', context: context);

  @override
  ObservableList<PostModel> get postList {
    _$postListAtom.reportRead();
    return super.postList;
  }

  @override
  set postList(ObservableList<PostModel> value) {
    _$postListAtom.reportWrite(value, super.postList, () {
      super.postList = value;
    });
  }

  late final _$groupAtom = Atom(name: 'GroupStoreBase.group', context: context);

  @override
  GroupModel get group {
    _$groupAtom.reportRead();
    return super.group;
  }

  @override
  set group(GroupModel value) {
    _$groupAtom.reportWrite(value, super.group, () {
      super.group = value;
    });
  }

  late final _$invitesAtom =
      Atom(name: 'GroupStoreBase.invites', context: context);

  @override
  ObservableList<GroupInviteModel> get invites {
    _$invitesAtom.reportRead();
    return super.invites;
  }

  @override
  set invites(ObservableList<GroupInviteModel> value) {
    _$invitesAtom.reportWrite(value, super.invites, () {
      super.invites = value;
    });
  }

  late final _$coverImageAtom =
      Atom(name: 'GroupStoreBase.coverImage', context: context);

  @override
  File? get coverImage {
    _$coverImageAtom.reportRead();
    return super.coverImage;
  }

  @override
  set coverImage(File? value) {
    _$coverImageAtom.reportWrite(value, super.coverImage, () {
      super.coverImage = value;
    });
  }

  late final _$avatarImageAtom =
      Atom(name: 'GroupStoreBase.avatarImage', context: context);

  @override
  File? get avatarImage {
    _$avatarImageAtom.reportRead();
    return super.avatarImage;
  }

  @override
  set avatarImage(File? value) {
    _$avatarImageAtom.reportWrite(value, super.avatarImage, () {
      super.avatarImage = value;
    });
  }

  late final _$avatarUrlAtom =
      Atom(name: 'GroupStoreBase.avatarUrl', context: context);

  @override
  String get avatarUrl {
    _$avatarUrlAtom.reportRead();
    return super.avatarUrl;
  }

  @override
  set avatarUrl(String value) {
    _$avatarUrlAtom.reportWrite(value, super.avatarUrl, () {
      super.avatarUrl = value;
    });
  }

  late final _$coverUrlAtom =
      Atom(name: 'GroupStoreBase.coverUrl', context: context);

  @override
  String get coverUrl {
    _$coverUrlAtom.reportRead();
    return super.coverUrl;
  }

  @override
  set coverUrl(String value) {
    _$coverUrlAtom.reportWrite(value, super.coverUrl, () {
      super.coverUrl = value;
    });
  }

  late final _$groupTypeAtom =
      Atom(name: 'GroupStoreBase.groupType', context: context);

  @override
  GroupType? get groupType {
    _$groupTypeAtom.reportRead();
    return super.groupType;
  }

  @override
  set groupType(GroupType? value) {
    _$groupTypeAtom.reportWrite(value, super.groupType, () {
      super.groupType = value;
    });
  }

  late final _$enableForumAtom =
      Atom(name: 'GroupStoreBase.enableForum', context: context);

  @override
  bool get enableForum {
    _$enableForumAtom.reportRead();
    return super.enableForum;
  }

  @override
  set enableForum(bool value) {
    _$enableForumAtom.reportWrite(value, super.enableForum, () {
      super.enableForum = value;
    });
  }

  late final _$groupInvitationsAtom =
      Atom(name: 'GroupStoreBase.groupInvitations', context: context);

  @override
  GroupInvitations? get groupInvitations {
    _$groupInvitationsAtom.reportRead();
    return super.groupInvitations;
  }

  @override
  set groupInvitations(GroupInvitations? value) {
    _$groupInvitationsAtom.reportWrite(value, super.groupInvitations, () {
      super.groupInvitations = value;
    });
  }

  late final _$enableGalleryAtom =
      Atom(name: 'GroupStoreBase.enableGallery', context: context);

  @override
  bool get enableGallery {
    _$enableGalleryAtom.reportRead();
    return super.enableGallery;
  }

  @override
  set enableGallery(bool value) {
    _$enableGalleryAtom.reportWrite(value, super.enableGallery, () {
      super.enableGallery = value;
    });
  }

  late final _$memberListAtom =
      Atom(name: 'GroupStoreBase.memberList', context: context);

  @override
  ObservableList<MemberModel> get memberList {
    _$memberListAtom.reportRead();
    return super.memberList;
  }

  @override
  set memberList(ObservableList<MemberModel> value) {
    _$memberListAtom.reportWrite(value, super.memberList, () {
      super.memberList = value;
    });
  }

  late final _$groupMemberListAtom =
      Atom(name: 'GroupStoreBase.groupMemberList', context: context);

  @override
  ObservableList<MemberModel> get groupMemberList {
    _$groupMemberListAtom.reportRead();
    return super.groupMemberList;
  }

  @override
  set groupMemberList(ObservableList<MemberModel> value) {
    _$groupMemberListAtom.reportWrite(value, super.groupMemberList, () {
      super.groupMemberList = value;
    });
  }

  late final _$isMemberAtom =
      Atom(name: 'GroupStoreBase.isMember', context: context);

  @override
  bool get isMember {
    _$isMemberAtom.reportRead();
    return super.isMember;
  }

  @override
  set isMember(bool value) {
    _$isMemberAtom.reportWrite(value, super.isMember, () {
      super.isMember = value;
    });
  }

  late final _$requestListAtom =
      Atom(name: 'GroupStoreBase.requestList', context: context);

  @override
  ObservableList<GroupRequestModel> get requestList {
    _$requestListAtom.reportRead();
    return super.requestList;
  }

  @override
  set requestList(ObservableList<GroupRequestModel> value) {
    _$requestListAtom.reportWrite(value, super.requestList, () {
      super.requestList = value;
    });
  }

  late final _$invitedMembersCountAtom =
      Atom(name: 'GroupStoreBase.invitedMembersCount', context: context);

  @override
  int get invitedMembersCount {
    _$invitedMembersCountAtom.reportRead();
    return super.invitedMembersCount;
  }

  @override
  set invitedMembersCount(int value) {
    _$invitedMembersCountAtom.reportWrite(value, super.invitedMembersCount, () {
      super.invitedMembersCount = value;
    });
  }

  late final _$GroupStoreBaseActionController =
      ActionController(name: 'GroupStoreBase', context: context);

  @override
  void updateInvitedMembersCount(int count) {
    final _$actionInfo = _$GroupStoreBaseActionController.startAction(
        name: 'GroupStoreBase.updateInvitedMembersCount');
    try {
      return super.updateInvitedMembersCount(count);
    } finally {
      _$GroupStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void resetInvitedMembersCount() {
    final _$actionInfo = _$GroupStoreBaseActionController.startAction(
        name: 'GroupStoreBase.resetInvitedMembersCount');
    try {
      return super.resetInvitedMembersCount();
    } finally {
      _$GroupStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isError: ${isError},
groupList: ${groupList},
errorMSG: ${errorMSG},
postList: ${postList},
group: ${group},
invites: ${invites},
coverImage: ${coverImage},
avatarImage: ${avatarImage},
avatarUrl: ${avatarUrl},
coverUrl: ${coverUrl},
groupType: ${groupType},
enableForum: ${enableForum},
groupInvitations: ${groupInvitations},
enableGallery: ${enableGallery},
memberList: ${memberList},
groupMemberList: ${groupMemberList},
isMember: ${isMember},
requestList: ${requestList},
invitedMembersCount: ${invitedMembersCount}
    ''';
  }
}
