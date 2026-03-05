import 'package:mobx/mobx.dart';
import 'package:socialv/models/activity_response.dart';
import 'package:socialv/models/groups/group_response.dart';
import 'package:socialv/models/members/member_response.dart';

part 'search_fragment_store.g.dart';

class SearchFragStore = SearchFragmentBase with _$SearchFragStore;

abstract class SearchFragmentBase with Store {
  /// search fragment

  ///Observables

  @observable
  bool hasShowClearTextIcon = false;

  @observable
  ObservableList<MemberResponse> memberList = ObservableList();

  @observable
  ObservableList<GroupResponse> groupList = ObservableList();

  @observable
  ObservableList<ActivityResponse> postList = ObservableList();

  @observable
  ObservableList<MemberResponse> recentMemberSearchList = ObservableList();

  @observable
  ObservableList<GroupResponse> recentGroupsSearchList = ObservableList();

  @observable
  String searchDropdownValue = "";

  @observable
  bool isSearchFieldEmpty = true;

  /// Setter methods ( actions )
}
