import 'package:mobx/mobx.dart';

part 'notification_settings_model.g.dart';

class NotificationSettingsModel = NotificationSettingsModelBase with _$NotificationSettingsModel;

abstract class NotificationSettingsModelBase with Store {
  String? key;
  String? name;

  @observable
  bool? value;

  NotificationSettingsModelBase({this.key, this.name, this.value});

  NotificationSettingsModelBase.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    name = json['name'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['key'] = this.key;
    data['name'] = this.name;
    data['value'] = this.value;
    return data;
  }
}
