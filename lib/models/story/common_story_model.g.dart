// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'common_story_model.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$CreateStoryModel on CreateStoryModelBase, Store {
  late final _$storyDurationAtom =
      Atom(name: 'CreateStoryModelBase.storyDuration', context: context);

  @override
  String get storyDuration {
    _$storyDurationAtom.reportRead();
    return super.storyDuration;
  }

  @override
  set storyDuration(String value) {
    _$storyDurationAtom.reportWrite(value, super.storyDuration, () {
      super.storyDuration = value;
    });
  }

  @override
  String toString() {
    return '''
storyDuration: ${storyDuration}
    ''';
  }
}
