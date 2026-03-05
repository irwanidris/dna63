import 'package:mobx/mobx.dart';
import 'package:socialv/models/members/member_detail_model.dart';
import 'package:socialv/models/posts/post_model.dart';

part 'profile_fragment_store.g.dart';

class ProfileFragStore = ProfileFragmentBase with _$ProfileFragStore;

abstract class ProfileFragmentBase with Store {
  /// Profile Fragment Vars

  ///Observables

  @observable
  ObservableList<PostModel> userPostList = ObservableList();

  @observable
  bool isError = false;

  @observable
  String errorMSG = "";

  @observable
  MemberDetailModel? memberDetails;

  @observable
  bool isFavorites = false;

  @observable
  int mProfilePage = 1;

  /// Member Profile Screen Vars
  @observable
  MemberDetailModel? member;

  @observable
  ObservableList<PostModel> memberPostList = ObservableList();

  @observable
  bool showDetails = false;

  @observable
  bool hasInfo = false;


}
