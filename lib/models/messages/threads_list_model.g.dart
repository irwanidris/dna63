// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'threads_list_model.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ThreadsListModel on ThreadsListModelBase, Store {
  late final _$threadsAtom =
      Atom(name: 'ThreadsListModelBase.threads', context: context);

  @override
  ObservableList<Threads>? get threads {
    _$threadsAtom.reportRead();
    return super.threads;
  }

  @override
  set threads(ObservableList<Threads>? value) {
    _$threadsAtom.reportWrite(value, super.threads, () {
      super.threads = value;
    });
  }

  late final _$usersAtom =
      Atom(name: 'ThreadsListModelBase.users', context: context);

  @override
  ObservableList<MessagesUsers>? get users {
    _$usersAtom.reportRead();
    return super.users;
  }

  @override
  set users(ObservableList<MessagesUsers>? value) {
    _$usersAtom.reportWrite(value, super.users, () {
      super.users = value;
    });
  }

  late final _$messagesAtom =
      Atom(name: 'ThreadsListModelBase.messages', context: context);

  @override
  ObservableList<Messages>? get messages {
    _$messagesAtom.reportRead();
    return super.messages;
  }

  @override
  set messages(ObservableList<Messages>? value) {
    _$messagesAtom.reportWrite(value, super.messages, () {
      super.messages = value;
    });
  }

  late final _$serverTimeAtom =
      Atom(name: 'ThreadsListModelBase.serverTime', context: context);

  @override
  int? get serverTime {
    _$serverTimeAtom.reportRead();
    return super.serverTime;
  }

  @override
  set serverTime(int? value) {
    _$serverTimeAtom.reportWrite(value, super.serverTime, () {
      super.serverTime = value;
    });
  }

  @override
  String toString() {
    return '''
threads: ${threads},
users: ${users},
messages: ${messages},
serverTime: ${serverTime}
    ''';
  }
}
