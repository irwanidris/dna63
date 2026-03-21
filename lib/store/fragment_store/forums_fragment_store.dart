import 'package:mobx/mobx.dart';
import 'package:socialv/models/forums/common_models.dart';
import 'package:socialv/models/forums/forum_model.dart';
import 'package:socialv/models/forums/topic_model.dart';

part 'forums_fragment_store.g.dart';

class ForumsFragStore = ForumsFragmentBase with _$ForumsFragStore;

abstract class ForumsFragmentBase with Store {
  /// Forum Fragment Vars

  ///Observables

  @observable
  ObservableList<ForumModel> forumsList = ObservableList();

  @observable
  bool hasShowClearTextIcon = false;

  @observable
  bool isError = false;

  @observable
  ObservableList<TopicReplyModel> postList = ObservableList();

  @observable
  TopicModel topic = TopicModel();

}
