import 'dart:io';

import 'package:mobx/mobx.dart';
import 'package:socialv/models/groups/group_model.dart';
import 'package:socialv/models/groups/group_request_model.dart';
import 'package:socialv/models/members/member_model.dart';
import 'package:socialv/models/posts/post_model.dart';
import 'package:socialv/screens/groups/components/create_group_step_one.dart';
import 'package:socialv/screens/groups/components/create_group_step_second.dart';
import 'package:socialv/utils/constants.dart';

import '../models/groups/search_invite_members_model.dart';

part 'group_store.g.dart';

class GroupStore = GroupStoreBase with _$GroupStore;

abstract class GroupStoreBase with Store {
  /// common vars

  @observable
  bool isError = false;

  ///groupScreen
  @observable
  ObservableList<GroupModel> groupList = ObservableList();

  @observable
  String errorMSG = "";

  /// Specific group Post List
  @observable
  ObservableList<PostModel> postList = ObservableList();

  @observable
  GroupModel group = GroupModel();

  ///Invites in group
  @observable
  ObservableList<GroupInviteModel> invites = ObservableList();


///Search Members Invites in group
  List<InviteData> membersList = ObservableList<InviteData>();

  ///upload image createGroupStepThirdVars
  @observable
  File? coverImage;

  @observable
  File? avatarImage;

  ///editGroupScreenVars
  @observable
  String avatarUrl = AppImages.placeHolderImage;

  @observable
  String coverUrl = AppImages.profileBackgroundImage;

  @observable
  GroupType? groupType;

  @observable
  bool enableForum = false;

  ///createGroupStepSecondVars
  @observable
  GroupInvitations? groupInvitations;

  @observable
  bool enableGallery = false;

  ///groupMemberScreenVars
  @observable
  ObservableList<MemberModel> memberList = ObservableList();

  ///privateGroupMembersComponentVars

  @observable
  ObservableList<MemberModel> groupMemberList = ObservableList();

  ///membersComponentVars
  @observable
  bool isMember = true;

  ///requestComponentVars
  @observable
  ObservableList<GroupRequestModel> requestList = ObservableList();

  ///CheckInviteCounts
  @observable
  int invitedMembersCount = 0;

  @action
  void updateInvitedMembersCount(int count) {
    invitedMembersCount = count;
  }

  @action
  void resetInvitedMembersCount() {
    invitedMembersCount = 0;
  }
}
