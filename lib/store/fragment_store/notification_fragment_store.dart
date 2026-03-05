import 'package:mobx/mobx.dart';
import 'package:socialv/models/notifications/notification_model.dart';

part 'notification_fragment_store.g.dart';

class NotificationFragStore = NotificationFragmentBase with _$NotificationFragStore;

abstract class NotificationFragmentBase with Store {
  /// Home Fragment Vars

  ///Observables

  @observable
  ObservableList<NotificationModel> notificationList = ObservableList();

  @observable
  bool isError = false;

  @observable
  String errorMSG = "";
}
