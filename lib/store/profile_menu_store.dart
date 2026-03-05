import 'dart:io';

import 'package:mobx/mobx.dart';
import 'package:socialv/models/block_report/blocked_accounts_model.dart';
import 'package:socialv/models/forums/common_models.dart';
import 'package:socialv/models/forums/forum_model.dart';
import 'package:socialv/models/forums/topic_model.dart';
import 'package:socialv/models/gamipress/common_gamipress_model.dart';
import 'package:socialv/models/gamipress/rewards_model.dart';
import 'package:socialv/models/general_settings_model.dart';
import 'package:socialv/models/lms/course_category.dart';
import 'package:socialv/models/lms/course_list_model.dart';
import 'package:socialv/models/lms/course_review_model.dart';
import 'package:socialv/models/lms/lesson_model.dart';
import 'package:socialv/models/lms/lms_payment_model.dart';
import 'package:socialv/models/lms/quiz_answers.dart';
import 'package:socialv/models/lms/quiz_model.dart';
import 'package:socialv/models/members/profile_visibility_model.dart';
import 'package:socialv/models/notifications/notification_settings_model.dart';
import 'package:socialv/models/pmp_models/discount_code_model.dart';
import 'package:socialv/models/pmp_models/membership_model.dart';
import 'package:socialv/models/pmp_models/pmp_order_model.dart';
import 'package:socialv/models/posts/wp_post_response.dart';
import 'package:socialv/models/story/highlight_category_list_model.dart';
import 'package:socialv/models/story/highlight_stories_model.dart';
import 'package:socialv/models/story/story_response_model.dart';
import 'package:socialv/models/woo_commerce/cart_item_model.dart';
import 'package:socialv/models/woo_commerce/cart_model.dart';
import 'package:socialv/models/woo_commerce/coupon_model.dart';
import 'package:socialv/utils/constants.dart';

import '../models/members/friend_request_model.dart';
import '../screens/settings/screens/safe_content_settings_screen.dart';

part 'profile_menu_store.g.dart';

class ProfileMenuStore = ProfileMenuStoreBase with _$ProfileMenuStore;

abstract class ProfileMenuStoreBase with Store {
  /// Common vars
  @observable
  bool isError = false;

  @observable
  String errorMSG = "";

  @observable
  bool isFetched = false;

  @observable
  bool isLoading = false;

  ///Setter method
  @action
  Future<void> setLoading(bool val) async {
    isLoading = val;
  }

  ///discountCodesScreenVars
  @observable
  ObservableList<DiscountCode> codeList = ObservableList();

  @observable
  DiscountCode? selectedCode;

  ///userStoryScreenVars

  @observable
  ObservableList<HighlightStoriesModel> highlightList = ObservableList();

  @observable
  ObservableList<StoryResponseModel> userStoryList = ObservableList();

  @observable
  int currentValue = 1;

  @observable
  String title = "";

  @observable
  bool showHighlightStory = false;

  @observable
  String status = StoryHighlightOptions.publish;

  ///newStoryHighlightDialogVars

  @observable
  bool showNewCategory = false;

  ///myMembershipScreenVars

  @observable
  MembershipModel? membership;

  @observable
  bool hasMembership = false;

  ///cancelMembershipScreenVars

  @observable
  bool isCancelled = false;

  ///pmpCheckoutScreenVars and singleChoiceComponentVars
  @observable
  bool showAddDiscount = false;

  @observable
  int? selectedIndex;

  ///friendsComponentVars

  @observable
  ObservableList<FriendRequestModel> friendReqList = ObservableList();

  ///requestSentComponentVars
  @observable
  ObservableList<FriendRequestModel> sentReq = ObservableList();

  ///requestsReceivedComponentVars
  @observable
  ObservableList<FriendRequestModel> receiveReq = ObservableList();

  ///myForumsScreenVars
  @observable
  int selectedTab = 0;

  ///userTopicComponentVars
  @observable
  ObservableList<TopicModel> topicsList = ObservableList();

  ///topicDetailScreenVars
  @observable
  bool isSubscribed = false;

  @observable
  bool isFavourite = false;

  ///forumRepliesComponentVars
  @observable
  ObservableList<TopicReplyModel> repliesList = ObservableList();

  ///forumsEngagementComponentVars
  @observable
  ObservableList<TopicModel> topicsEngagementList = ObservableList();

  ///favouriteTopicComponentVars
  @observable
  ObservableList<TopicModel> topicsFavouriteList = ObservableList();

  ///forumSubscriptionComponentVars
  @observable
  ObservableList<ForumModel> forumList = ObservableList();

  @observable
  ObservableList<TopicModel> topicsSubscriptionList = ObservableList();

  ///topicReplyScreenVars and createTopicScreenVars

  @observable
  ObservableList<String> tempReplies = ObservableList();

  @observable
  bool doNotify = false;

  ///badgeListScreenVars
  @observable
  ObservableList<CommonGamiPressModel> badgeList = ObservableList();

  ///levelsScreenVars
  @observable
  ObservableList<CommonGamiPressModel> levels = ObservableList();

  ///courseDetailScreenVars
  @observable
  CourseListModel? course = CourseListModel();

  @observable
  int selectedCourseDetailTabIndex = 0;

  ///courseListScreenVars
  @observable
  ObservableList<CourseListModel> courseList = ObservableList();

  @observable
  ObservableList<CourseCategory> coursesType = ObservableList();

  @observable
  int selectedCourseCategory = 0;

  ///cartScreenVars
  @observable
  ObservableList<CartItemModel> cartItemList = ObservableList();

  @observable
  int total = 0;

  @observable
  CartModel? cart = CartModel();

  ///blogListScreenVars
  @observable
  ObservableList<WpPostResponse> blogList = ObservableList();

  ///safeContentSettingsScreenVars
  @observable
  GroupType? groupType;

  ///rewardsScreenVars
  @observable
  int selectedRewardIndex = 0;

  @observable
  RewardsModel? rewardData = RewardsModel();

  @observable
  ObservableList<String> rewardTabs = ObservableList();



  ///couponListScreenVars
  @observable
  ObservableList<CouponModel> couponsList = ObservableList();

  ///notificationSettingsVars
  @observable
  ObservableList<NotificationSettingsModel> notificationList = ObservableList();

  @observable
  bool isChange = false;

  ///visibilityComponentVars
  @observable
  Visibilities dropdownValue = Visibilities();

  @observable
  ObservableList<ProfileVisibilityModel> visibilityList = ObservableList();

  ///blockedAccountsVars
  @observable
  ObservableList<BlockedAccountsModel> membersList = ObservableList();

  ///membershipPlansScreenVars
  @observable
  ObservableList<MembershipModel> plans = ObservableList();

  ///languageScreenVars
  @observable
  int selectedLanguageIndex = 0;

  ///buyCourseScreenVars
  @observable
  LmsPaymentModel? selectedPaymentMethod;

  @observable
  bool isPaymentGatewayLoading = true;

  @observable
  ObservableList<LmsPaymentModel> paymentGateways = ObservableList();

  ///lessonScreenVars
  @observable
  LessonModel lesson = LessonModel();

  @observable
  bool isLessonFetched = false;

  ///reviewTabComponentVars
  @observable
  CourseReviewModel snap = CourseReviewModel();

  @observable
  List<SingleRatingItem> ratings = [];

  @observable
  bool showLoading = true;

  ///quizScreenVars
  @observable
  bool isReviewQuiz = false;

  @observable
  QuizModel quiz = QuizModel();

  @observable
  List<Answers> answers = [];

  @observable
  ObservableList<QuestionAnsweresModel> reviewAnswers = ObservableList();

  ///quizComponentVars
  @observable
  int quizPageIndex = 1;

  @observable
  String timeToShow = "";

  ///topicsScreenVars

  @observable
  ObservableList<TopicModel> topicsViewList = ObservableList();

  ///forumsScreenVars

  @observable
  ObservableList<ForumModel> forumsList = ObservableList();

  ///forumDetailScreenVars

  @observable
  ForumModel? forumData;

  ///newHighlightScreenVars

  @observable
  bool showNewCategoryList = false;

  @observable
  bool hasShowClearTextIcon = false;

  @action
  void showClearTextIcon(bool value) {
    hasShowClearTextIcon = value;
  }

  @observable
  ObservableList<HighlightCategoryListModel> highlightCategoryList = ObservableList();

  @observable
  HighlightCategoryListModel highlightDropdownVal = HighlightCategoryListModel();

  @observable
  File? categoryImage;
  ///newStoryHighlightDialogVars

  @observable
  ObservableList<HighlightStoriesModel> dialogHighlightList = ObservableList();

  @observable
  HighlightStoriesModel dialogDropdownValue = HighlightStoriesModel();

  @observable
  File? categoryPic;

  ///forumDetailComponentVars

  @observable
  ObservableList<TopicModel> topicList = ObservableList();

  @observable
  ObservableList<ForumModel> forumListData = ObservableList();

  ///joinGroupWidgetVars

  @observable
  bool isRequested = false;

  ///editProfileScreenVars
  @observable
  String avatarUrl = "";

  @observable
  String coverImage = "";

  @observable
  File? avatarImage;

  @observable
  File? cover;

  @observable
  ObservableList<SignupFields> fieldList = ObservableList();

  @observable
  bool isCover = false;

  ///requestFollowWidget

  @observable
  late String friendshipStatus;

  ///earnedBadgesScreenVars
  @observable
  ObservableList<Rank> listOfBadge = ObservableList();

  ///pastInvoicesComponentVars

  @observable
  ObservableList<PmpOrderModel> pastOrderList = ObservableList();

  ///allOrdersScreenVars

  @observable
  ObservableList<PmpOrderModel> allOrderList = ObservableList();

  @observable
  int mPage = 1;

  @observable
  bool mIsLastPage = false;

  ///profileVisibilityScreenVars
  @observable
  ObservableList<ProfileVisibilityModel> profileList = ObservableList();

  @observable
  ObservableList<Future> futures = ObservableList();

  @observable
  ObservableList<String> messages = ObservableList();

  //region Gamipress

  ///achievementStore
  @observable
  int selectedAchievementTypeIndex = 0;

  @observable
  Future<List<CommonGamiPressModel>>? achievementFuture;

  @observable
  ObservableList<CommonGamiPressModel> achievementList = ObservableList();

  @observable
  GamipressAchievementTypes? selectedAchievement;

  @action
  Future<void> setAchievementType(GamipressAchievementTypes achievementType) async {
    selectedAchievement = achievementType;
  }

  @action
  Future<void> setSelectedAchievementTypeIndex(int index) async {
    selectedAchievementTypeIndex = index;
  }

  ///rankStore
  @observable
  int selectedRankTypeIndex = 0;

  @observable
  Future<List<CommonGamiPressModel>>? rankFuture;

  @observable
  List<CommonGamiPressModel> rankList = ObservableList();

  @observable
  GamipressAchievementTypes? selectedRank;

  @action
  Future<void> setSelectedRankType(GamipressAchievementTypes rankType) async {
    selectedRank = rankType;
  }

  @action
  Future<void> setSelectedRankTypeIndex(int index) async {
    selectedRankTypeIndex = index;
  }
//endRegion
}
