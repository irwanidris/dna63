// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_fragment_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ProfileFragStore on ProfileFragmentBase, Store {
  late final _$userPostListAtom =
      Atom(name: 'ProfileFragmentBase.userPostList', context: context);

  @override
  ObservableList<PostModel> get userPostList {
    _$userPostListAtom.reportRead();
    return super.userPostList;
  }

  @override
  set userPostList(ObservableList<PostModel> value) {
    _$userPostListAtom.reportWrite(value, super.userPostList, () {
      super.userPostList = value;
    });
  }

  late final _$isErrorAtom =
      Atom(name: 'ProfileFragmentBase.isError', context: context);

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

  late final _$errorMSGAtom =
      Atom(name: 'ProfileFragmentBase.errorMSG', context: context);

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

  late final _$memberDetailsAtom =
      Atom(name: 'ProfileFragmentBase.memberDetails', context: context);

  @override
  MemberDetailModel? get memberDetails {
    _$memberDetailsAtom.reportRead();
    return super.memberDetails;
  }

  @override
  set memberDetails(MemberDetailModel? value) {
    _$memberDetailsAtom.reportWrite(value, super.memberDetails, () {
      super.memberDetails = value;
    });
  }

  late final _$isFavoritesAtom =
      Atom(name: 'ProfileFragmentBase.isFavorites', context: context);

  @override
  bool get isFavorites {
    _$isFavoritesAtom.reportRead();
    return super.isFavorites;
  }

  @override
  set isFavorites(bool value) {
    _$isFavoritesAtom.reportWrite(value, super.isFavorites, () {
      super.isFavorites = value;
    });
  }

  late final _$mProfilePageAtom =
      Atom(name: 'ProfileFragmentBase.mProfilePage', context: context);

  @override
  int get mProfilePage {
    _$mProfilePageAtom.reportRead();
    return super.mProfilePage;
  }

  @override
  set mProfilePage(int value) {
    _$mProfilePageAtom.reportWrite(value, super.mProfilePage, () {
      super.mProfilePage = value;
    });
  }

  late final _$memberAtom =
      Atom(name: 'ProfileFragmentBase.member', context: context);

  @override
  MemberDetailModel? get member {
    _$memberAtom.reportRead();
    return super.member;
  }

  @override
  set member(MemberDetailModel? value) {
    _$memberAtom.reportWrite(value, super.member, () {
      super.member = value;
    });
  }

  late final _$memberPostListAtom =
      Atom(name: 'ProfileFragmentBase.memberPostList', context: context);

  @override
  ObservableList<PostModel> get memberPostList {
    _$memberPostListAtom.reportRead();
    return super.memberPostList;
  }

  @override
  set memberPostList(ObservableList<PostModel> value) {
    _$memberPostListAtom.reportWrite(value, super.memberPostList, () {
      super.memberPostList = value;
    });
  }

  late final _$showDetailsAtom =
      Atom(name: 'ProfileFragmentBase.showDetails', context: context);

  @override
  bool get showDetails {
    _$showDetailsAtom.reportRead();
    return super.showDetails;
  }

  @override
  set showDetails(bool value) {
    _$showDetailsAtom.reportWrite(value, super.showDetails, () {
      super.showDetails = value;
    });
  }

  late final _$hasInfoAtom =
      Atom(name: 'ProfileFragmentBase.hasInfo', context: context);

  @override
  bool get hasInfo {
    _$hasInfoAtom.reportRead();
    return super.hasInfo;
  }

  @override
  set hasInfo(bool value) {
    _$hasInfoAtom.reportWrite(value, super.hasInfo, () {
      super.hasInfo = value;
    });
  }

  @override
  String toString() {
    return '''
userPostList: ${userPostList},
isError: ${isError},
errorMSG: ${errorMSG},
memberDetails: ${memberDetails},
isFavorites: ${isFavorites},
mProfilePage: ${mProfilePage},
member: ${member},
memberPostList: ${memberPostList},
showDetails: ${showDetails},
hasInfo: ${hasInfo}
    ''';
  }
}
