// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_fragment_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$SearchFragStore on SearchFragmentBase, Store {
  late final _$hasShowClearTextIconAtom =
      Atom(name: 'SearchFragmentBase.hasShowClearTextIcon', context: context);

  @override
  bool get hasShowClearTextIcon {
    _$hasShowClearTextIconAtom.reportRead();
    return super.hasShowClearTextIcon;
  }

  @override
  set hasShowClearTextIcon(bool value) {
    _$hasShowClearTextIconAtom.reportWrite(value, super.hasShowClearTextIcon,
        () {
      super.hasShowClearTextIcon = value;
    });
  }

  late final _$memberListAtom =
      Atom(name: 'SearchFragmentBase.memberList', context: context);

  @override
  ObservableList<MemberResponse> get memberList {
    _$memberListAtom.reportRead();
    return super.memberList;
  }

  @override
  set memberList(ObservableList<MemberResponse> value) {
    _$memberListAtom.reportWrite(value, super.memberList, () {
      super.memberList = value;
    });
  }

  late final _$groupListAtom =
      Atom(name: 'SearchFragmentBase.groupList', context: context);

  @override
  ObservableList<GroupResponse> get groupList {
    _$groupListAtom.reportRead();
    return super.groupList;
  }

  @override
  set groupList(ObservableList<GroupResponse> value) {
    _$groupListAtom.reportWrite(value, super.groupList, () {
      super.groupList = value;
    });
  }

  late final _$postListAtom =
      Atom(name: 'SearchFragmentBase.postList', context: context);

  @override
  ObservableList<ActivityResponse> get postList {
    _$postListAtom.reportRead();
    return super.postList;
  }

  @override
  set postList(ObservableList<ActivityResponse> value) {
    _$postListAtom.reportWrite(value, super.postList, () {
      super.postList = value;
    });
  }

  late final _$recentMemberSearchListAtom =
      Atom(name: 'SearchFragmentBase.recentMemberSearchList', context: context);

  @override
  ObservableList<MemberResponse> get recentMemberSearchList {
    _$recentMemberSearchListAtom.reportRead();
    return super.recentMemberSearchList;
  }

  @override
  set recentMemberSearchList(ObservableList<MemberResponse> value) {
    _$recentMemberSearchListAtom
        .reportWrite(value, super.recentMemberSearchList, () {
      super.recentMemberSearchList = value;
    });
  }

  late final _$recentGroupsSearchListAtom =
      Atom(name: 'SearchFragmentBase.recentGroupsSearchList', context: context);

  @override
  ObservableList<GroupResponse> get recentGroupsSearchList {
    _$recentGroupsSearchListAtom.reportRead();
    return super.recentGroupsSearchList;
  }

  @override
  set recentGroupsSearchList(ObservableList<GroupResponse> value) {
    _$recentGroupsSearchListAtom
        .reportWrite(value, super.recentGroupsSearchList, () {
      super.recentGroupsSearchList = value;
    });
  }

  late final _$searchDropdownValueAtom =
      Atom(name: 'SearchFragmentBase.searchDropdownValue', context: context);

  @override
  String get searchDropdownValue {
    _$searchDropdownValueAtom.reportRead();
    return super.searchDropdownValue;
  }

  @override
  set searchDropdownValue(String value) {
    _$searchDropdownValueAtom.reportWrite(value, super.searchDropdownValue, () {
      super.searchDropdownValue = value;
    });
  }

  late final _$isSearchFieldEmptyAtom =
      Atom(name: 'SearchFragmentBase.isSearchFieldEmpty', context: context);

  @override
  bool get isSearchFieldEmpty {
    _$isSearchFieldEmptyAtom.reportRead();
    return super.isSearchFieldEmpty;
  }

  @override
  set isSearchFieldEmpty(bool value) {
    _$isSearchFieldEmptyAtom.reportWrite(value, super.isSearchFieldEmpty, () {
      super.isSearchFieldEmpty = value;
    });
  }

  @override
  String toString() {
    return '''
hasShowClearTextIcon: ${hasShowClearTextIcon},
memberList: ${memberList},
groupList: ${groupList},
postList: ${postList},
recentMemberSearchList: ${recentMemberSearchList},
recentGroupsSearchList: ${recentGroupsSearchList},
searchDropdownValue: ${searchDropdownValue},
isSearchFieldEmpty: ${isSearchFieldEmpty}
    ''';
  }
}
