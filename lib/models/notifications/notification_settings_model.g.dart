// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_settings_model.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$NotificationSettingsModel on NotificationSettingsModelBase, Store {
  late final _$valueAtom =
      Atom(name: 'NotificationSettingsModelBase.value', context: context);

  @override
  bool? get value {
    _$valueAtom.reportRead();
    return super.value;
  }

  @override
  set value(bool? value) {
    _$valueAtom.reportWrite(value, super.value, () {
      super.value = value;
    });
  }

  @override
  String toString() {
    return '''
value: ${value}
    ''';
  }
}
