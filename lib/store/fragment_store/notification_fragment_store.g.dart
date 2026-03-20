// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_fragment_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$NotificationFragStore on NotificationFragmentBase, Store {
  late final _$notificationListAtom =
      Atom(name: 'NotificationFragmentBase.notificationList', context: context);

  @override
  ObservableList<NotificationModel> get notificationList {
    _$notificationListAtom.reportRead();
    return super.notificationList;
  }

  @override
  set notificationList(ObservableList<NotificationModel> value) {
    _$notificationListAtom.reportWrite(value, super.notificationList, () {
      super.notificationList = value;
    });
  }

  late final _$isErrorAtom =
      Atom(name: 'NotificationFragmentBase.isError', context: context);

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
      Atom(name: 'NotificationFragmentBase.errorMSG', context: context);

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

  @override
  String toString() {
    return '''
notificationList: ${notificationList},
isError: ${isError},
errorMSG: ${errorMSG}
    ''';
  }
}
