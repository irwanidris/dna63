// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forums_fragment_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ForumsFragStore on ForumsFragmentBase, Store {
  late final _$forumsListAtom =
      Atom(name: 'ForumsFragmentBase.forumsList', context: context);

  @override
  ObservableList<ForumModel> get forumsList {
    _$forumsListAtom.reportRead();
    return super.forumsList;
  }

  @override
  set forumsList(ObservableList<ForumModel> value) {
    _$forumsListAtom.reportWrite(value, super.forumsList, () {
      super.forumsList = value;
    });
  }

  late final _$hasShowClearTextIconAtom =
      Atom(name: 'ForumsFragmentBase.hasShowClearTextIcon', context: context);

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

  late final _$isErrorAtom =
      Atom(name: 'ForumsFragmentBase.isError', context: context);

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

  late final _$postListAtom =
      Atom(name: 'ForumsFragmentBase.postList', context: context);

  @override
  ObservableList<TopicReplyModel> get postList {
    _$postListAtom.reportRead();
    return super.postList;
  }

  @override
  set postList(ObservableList<TopicReplyModel> value) {
    _$postListAtom.reportWrite(value, super.postList, () {
      super.postList = value;
    });
  }

  late final _$topicAtom =
      Atom(name: 'ForumsFragmentBase.topic', context: context);

  @override
  TopicModel get topic {
    _$topicAtom.reportRead();
    return super.topic;
  }

  @override
  set topic(TopicModel value) {
    _$topicAtom.reportWrite(value, super.topic, () {
      super.topic = value;
    });
  }

  @override
  String toString() {
    return '''
forumsList: ${forumsList},
hasShowClearTextIcon: ${hasShowClearTextIcon},
isError: ${isError},
postList: ${postList},
topic: ${topic}
    ''';
  }
}
