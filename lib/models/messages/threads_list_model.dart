import 'package:mobx/mobx.dart';

import 'threads_model.dart';
import 'message_users.dart';
import 'messages_model.dart';

part 'threads_list_model.g.dart';

class ThreadsListModel = ThreadsListModelBase with _$ThreadsListModel;

abstract class ThreadsListModelBase with Store {
  ThreadsListModelBase({
    this.threads,
    this.users,
    this.messages,
    this.serverTime,
  });

  ThreadsListModelBase.fromJson(dynamic json) {
    if (json['threads'] != null) {
      threads = ObservableList();
      json['threads'].forEach((v) {
        threads!.add(Threads.fromJson(v));
      });
    }
    if (json['users'] != null) {
      users = ObservableList();
      json['users'].forEach((v) {
        users!.add(MessagesUsers.fromJson(v));
      });
    }
    if (json['messages'] != null) {
      messages = ObservableList();
      json['messages'].forEach((v) {
        messages!.add(Messages.fromJson(v));
      });
    }
    serverTime = json['serverTime'];
  }

  @observable
  ObservableList<Threads>? threads;

  @observable
  ObservableList<MessagesUsers>? users;

  @observable
  ObservableList<Messages>? messages;

  @observable
  int? serverTime;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (threads != null) {
      map['threads'] = threads!.map((v) => v.toJson()).toList();
    }
    if (users != null) {
      map['users'] = users!.map((v) => v.toJson()).toList();
    }
    if (messages != null) {
      map['messages'] = messages!.map((v) => v.toJson()).toList();
    }
    map['serverTime'] = serverTime;
    return map;
  }
}
