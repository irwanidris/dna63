// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_model.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$PostModel on _PostModelBase, Store {
  late final _$isPinnedAtom =
      Atom(name: '_PostModelBase.isPinned', context: context);

  @override
  int? get isPinned {
    _$isPinnedAtom.reportRead();
    return super.isPinned;
  }

  @override
  set isPinned(int? value) {
    _$isPinnedAtom.reportWrite(value, super.isPinned, () {
      super.isPinned = value;
    });
  }

  late final _$canUnpinPostAtom =
      Atom(name: '_PostModelBase.canUnpinPost', context: context);

  @override
  int? get canUnpinPost {
    _$canUnpinPostAtom.reportRead();
    return super.canUnpinPost;
  }

  @override
  set canUnpinPost(int? value) {
    _$canUnpinPostAtom.reportWrite(value, super.canUnpinPost, () {
      super.canUnpinPost = value;
    });
  }

  @override
  String toString() {
    return '''
isPinned: ${isPinned},
canUnpinPost: ${canUnpinPost}
    ''';
  }
}
