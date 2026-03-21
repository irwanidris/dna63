// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_menu_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ProfileMenuStore on ProfileMenuStoreBase, Store {
  late final _$isErrorAtom =
      Atom(name: 'ProfileMenuStoreBase.isError', context: context);

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
      Atom(name: 'ProfileMenuStoreBase.errorMSG', context: context);

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

  late final _$isFetchedAtom =
      Atom(name: 'ProfileMenuStoreBase.isFetched', context: context);

  @override
  bool get isFetched {
    _$isFetchedAtom.reportRead();
    return super.isFetched;
  }

  @override
  set isFetched(bool value) {
    _$isFetchedAtom.reportWrite(value, super.isFetched, () {
      super.isFetched = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: 'ProfileMenuStoreBase.isLoading', context: context);

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$codeListAtom =
      Atom(name: 'ProfileMenuStoreBase.codeList', context: context);

  @override
  ObservableList<DiscountCode> get codeList {
    _$codeListAtom.reportRead();
    return super.codeList;
  }

  @override
  set codeList(ObservableList<DiscountCode> value) {
    _$codeListAtom.reportWrite(value, super.codeList, () {
      super.codeList = value;
    });
  }

  late final _$selectedCodeAtom =
      Atom(name: 'ProfileMenuStoreBase.selectedCode', context: context);

  @override
  DiscountCode? get selectedCode {
    _$selectedCodeAtom.reportRead();
    return super.selectedCode;
  }

  @override
  set selectedCode(DiscountCode? value) {
    _$selectedCodeAtom.reportWrite(value, super.selectedCode, () {
      super.selectedCode = value;
    });
  }

  late final _$highlightListAtom =
      Atom(name: 'ProfileMenuStoreBase.highlightList', context: context);

  @override
  ObservableList<HighlightStoriesModel> get highlightList {
    _$highlightListAtom.reportRead();
    return super.highlightList;
  }

  @override
  set highlightList(ObservableList<HighlightStoriesModel> value) {
    _$highlightListAtom.reportWrite(value, super.highlightList, () {
      super.highlightList = value;
    });
  }

  late final _$userStoryListAtom =
      Atom(name: 'ProfileMenuStoreBase.userStoryList', context: context);

  @override
  ObservableList<StoryResponseModel> get userStoryList {
    _$userStoryListAtom.reportRead();
    return super.userStoryList;
  }

  @override
  set userStoryList(ObservableList<StoryResponseModel> value) {
    _$userStoryListAtom.reportWrite(value, super.userStoryList, () {
      super.userStoryList = value;
    });
  }

  late final _$currentValueAtom =
      Atom(name: 'ProfileMenuStoreBase.currentValue', context: context);

  @override
  int get currentValue {
    _$currentValueAtom.reportRead();
    return super.currentValue;
  }

  @override
  set currentValue(int value) {
    _$currentValueAtom.reportWrite(value, super.currentValue, () {
      super.currentValue = value;
    });
  }

  late final _$titleAtom =
      Atom(name: 'ProfileMenuStoreBase.title', context: context);

  @override
  String get title {
    _$titleAtom.reportRead();
    return super.title;
  }

  @override
  set title(String value) {
    _$titleAtom.reportWrite(value, super.title, () {
      super.title = value;
    });
  }

  late final _$showHighlightStoryAtom =
      Atom(name: 'ProfileMenuStoreBase.showHighlightStory', context: context);

  @override
  bool get showHighlightStory {
    _$showHighlightStoryAtom.reportRead();
    return super.showHighlightStory;
  }

  @override
  set showHighlightStory(bool value) {
    _$showHighlightStoryAtom.reportWrite(value, super.showHighlightStory, () {
      super.showHighlightStory = value;
    });
  }

  late final _$statusAtom =
      Atom(name: 'ProfileMenuStoreBase.status', context: context);

  @override
  String get status {
    _$statusAtom.reportRead();
    return super.status;
  }

  @override
  set status(String value) {
    _$statusAtom.reportWrite(value, super.status, () {
      super.status = value;
    });
  }

  late final _$showNewCategoryAtom =
      Atom(name: 'ProfileMenuStoreBase.showNewCategory', context: context);

  @override
  bool get showNewCategory {
    _$showNewCategoryAtom.reportRead();
    return super.showNewCategory;
  }

  @override
  set showNewCategory(bool value) {
    _$showNewCategoryAtom.reportWrite(value, super.showNewCategory, () {
      super.showNewCategory = value;
    });
  }

  late final _$membershipAtom =
      Atom(name: 'ProfileMenuStoreBase.membership', context: context);

  @override
  MembershipModel? get membership {
    _$membershipAtom.reportRead();
    return super.membership;
  }

  @override
  set membership(MembershipModel? value) {
    _$membershipAtom.reportWrite(value, super.membership, () {
      super.membership = value;
    });
  }

  late final _$hasMembershipAtom =
      Atom(name: 'ProfileMenuStoreBase.hasMembership', context: context);

  @override
  bool get hasMembership {
    _$hasMembershipAtom.reportRead();
    return super.hasMembership;
  }

  @override
  set hasMembership(bool value) {
    _$hasMembershipAtom.reportWrite(value, super.hasMembership, () {
      super.hasMembership = value;
    });
  }

  late final _$isCancelledAtom =
      Atom(name: 'ProfileMenuStoreBase.isCancelled', context: context);

  @override
  bool get isCancelled {
    _$isCancelledAtom.reportRead();
    return super.isCancelled;
  }

  @override
  set isCancelled(bool value) {
    _$isCancelledAtom.reportWrite(value, super.isCancelled, () {
      super.isCancelled = value;
    });
  }

  late final _$showAddDiscountAtom =
      Atom(name: 'ProfileMenuStoreBase.showAddDiscount', context: context);

  @override
  bool get showAddDiscount {
    _$showAddDiscountAtom.reportRead();
    return super.showAddDiscount;
  }

  @override
  set showAddDiscount(bool value) {
    _$showAddDiscountAtom.reportWrite(value, super.showAddDiscount, () {
      super.showAddDiscount = value;
    });
  }

  late final _$selectedIndexAtom =
      Atom(name: 'ProfileMenuStoreBase.selectedIndex', context: context);

  @override
  int? get selectedIndex {
    _$selectedIndexAtom.reportRead();
    return super.selectedIndex;
  }

  @override
  set selectedIndex(int? value) {
    _$selectedIndexAtom.reportWrite(value, super.selectedIndex, () {
      super.selectedIndex = value;
    });
  }

  late final _$friendReqListAtom =
      Atom(name: 'ProfileMenuStoreBase.friendReqList', context: context);

  @override
  ObservableList<FriendRequestModel> get friendReqList {
    _$friendReqListAtom.reportRead();
    return super.friendReqList;
  }

  @override
  set friendReqList(ObservableList<FriendRequestModel> value) {
    _$friendReqListAtom.reportWrite(value, super.friendReqList, () {
      super.friendReqList = value;
    });
  }

  late final _$sentReqAtom =
      Atom(name: 'ProfileMenuStoreBase.sentReq', context: context);

  @override
  ObservableList<FriendRequestModel> get sentReq {
    _$sentReqAtom.reportRead();
    return super.sentReq;
  }

  @override
  set sentReq(ObservableList<FriendRequestModel> value) {
    _$sentReqAtom.reportWrite(value, super.sentReq, () {
      super.sentReq = value;
    });
  }

  late final _$receiveReqAtom =
      Atom(name: 'ProfileMenuStoreBase.receiveReq', context: context);

  @override
  ObservableList<FriendRequestModel> get receiveReq {
    _$receiveReqAtom.reportRead();
    return super.receiveReq;
  }

  @override
  set receiveReq(ObservableList<FriendRequestModel> value) {
    _$receiveReqAtom.reportWrite(value, super.receiveReq, () {
      super.receiveReq = value;
    });
  }

  late final _$selectedTabAtom =
      Atom(name: 'ProfileMenuStoreBase.selectedTab', context: context);

  @override
  int get selectedTab {
    _$selectedTabAtom.reportRead();
    return super.selectedTab;
  }

  @override
  set selectedTab(int value) {
    _$selectedTabAtom.reportWrite(value, super.selectedTab, () {
      super.selectedTab = value;
    });
  }

  late final _$topicsListAtom =
      Atom(name: 'ProfileMenuStoreBase.topicsList', context: context);

  @override
  ObservableList<TopicModel> get topicsList {
    _$topicsListAtom.reportRead();
    return super.topicsList;
  }

  @override
  set topicsList(ObservableList<TopicModel> value) {
    _$topicsListAtom.reportWrite(value, super.topicsList, () {
      super.topicsList = value;
    });
  }

  late final _$isSubscribedAtom =
      Atom(name: 'ProfileMenuStoreBase.isSubscribed', context: context);

  @override
  bool get isSubscribed {
    _$isSubscribedAtom.reportRead();
    return super.isSubscribed;
  }

  @override
  set isSubscribed(bool value) {
    _$isSubscribedAtom.reportWrite(value, super.isSubscribed, () {
      super.isSubscribed = value;
    });
  }

  late final _$isFavouriteAtom =
      Atom(name: 'ProfileMenuStoreBase.isFavourite', context: context);

  @override
  bool get isFavourite {
    _$isFavouriteAtom.reportRead();
    return super.isFavourite;
  }

  @override
  set isFavourite(bool value) {
    _$isFavouriteAtom.reportWrite(value, super.isFavourite, () {
      super.isFavourite = value;
    });
  }

  late final _$repliesListAtom =
      Atom(name: 'ProfileMenuStoreBase.repliesList', context: context);

  @override
  ObservableList<TopicReplyModel> get repliesList {
    _$repliesListAtom.reportRead();
    return super.repliesList;
  }

  @override
  set repliesList(ObservableList<TopicReplyModel> value) {
    _$repliesListAtom.reportWrite(value, super.repliesList, () {
      super.repliesList = value;
    });
  }

  late final _$topicsEngagementListAtom =
      Atom(name: 'ProfileMenuStoreBase.topicsEngagementList', context: context);

  @override
  ObservableList<TopicModel> get topicsEngagementList {
    _$topicsEngagementListAtom.reportRead();
    return super.topicsEngagementList;
  }

  @override
  set topicsEngagementList(ObservableList<TopicModel> value) {
    _$topicsEngagementListAtom.reportWrite(value, super.topicsEngagementList,
        () {
      super.topicsEngagementList = value;
    });
  }

  late final _$topicsFavouriteListAtom =
      Atom(name: 'ProfileMenuStoreBase.topicsFavouriteList', context: context);

  @override
  ObservableList<TopicModel> get topicsFavouriteList {
    _$topicsFavouriteListAtom.reportRead();
    return super.topicsFavouriteList;
  }

  @override
  set topicsFavouriteList(ObservableList<TopicModel> value) {
    _$topicsFavouriteListAtom.reportWrite(value, super.topicsFavouriteList, () {
      super.topicsFavouriteList = value;
    });
  }

  late final _$forumListAtom =
      Atom(name: 'ProfileMenuStoreBase.forumList', context: context);

  @override
  ObservableList<ForumModel> get forumList {
    _$forumListAtom.reportRead();
    return super.forumList;
  }

  @override
  set forumList(ObservableList<ForumModel> value) {
    _$forumListAtom.reportWrite(value, super.forumList, () {
      super.forumList = value;
    });
  }

  late final _$topicsSubscriptionListAtom = Atom(
      name: 'ProfileMenuStoreBase.topicsSubscriptionList', context: context);

  @override
  ObservableList<TopicModel> get topicsSubscriptionList {
    _$topicsSubscriptionListAtom.reportRead();
    return super.topicsSubscriptionList;
  }

  @override
  set topicsSubscriptionList(ObservableList<TopicModel> value) {
    _$topicsSubscriptionListAtom
        .reportWrite(value, super.topicsSubscriptionList, () {
      super.topicsSubscriptionList = value;
    });
  }

  late final _$tempRepliesAtom =
      Atom(name: 'ProfileMenuStoreBase.tempReplies', context: context);

  @override
  ObservableList<String> get tempReplies {
    _$tempRepliesAtom.reportRead();
    return super.tempReplies;
  }

  @override
  set tempReplies(ObservableList<String> value) {
    _$tempRepliesAtom.reportWrite(value, super.tempReplies, () {
      super.tempReplies = value;
    });
  }

  late final _$doNotifyAtom =
      Atom(name: 'ProfileMenuStoreBase.doNotify', context: context);

  @override
  bool get doNotify {
    _$doNotifyAtom.reportRead();
    return super.doNotify;
  }

  @override
  set doNotify(bool value) {
    _$doNotifyAtom.reportWrite(value, super.doNotify, () {
      super.doNotify = value;
    });
  }

  late final _$badgeListAtom =
      Atom(name: 'ProfileMenuStoreBase.badgeList', context: context);

  @override
  ObservableList<CommonGamiPressModel> get badgeList {
    _$badgeListAtom.reportRead();
    return super.badgeList;
  }

  @override
  set badgeList(ObservableList<CommonGamiPressModel> value) {
    _$badgeListAtom.reportWrite(value, super.badgeList, () {
      super.badgeList = value;
    });
  }

  late final _$levelsAtom =
      Atom(name: 'ProfileMenuStoreBase.levels', context: context);

  @override
  ObservableList<CommonGamiPressModel> get levels {
    _$levelsAtom.reportRead();
    return super.levels;
  }

  @override
  set levels(ObservableList<CommonGamiPressModel> value) {
    _$levelsAtom.reportWrite(value, super.levels, () {
      super.levels = value;
    });
  }

  late final _$courseAtom =
      Atom(name: 'ProfileMenuStoreBase.course', context: context);

  @override
  CourseListModel? get course {
    _$courseAtom.reportRead();
    return super.course;
  }

  @override
  set course(CourseListModel? value) {
    _$courseAtom.reportWrite(value, super.course, () {
      super.course = value;
    });
  }

  late final _$selectedCourseDetailTabIndexAtom = Atom(
      name: 'ProfileMenuStoreBase.selectedCourseDetailTabIndex',
      context: context);

  @override
  int get selectedCourseDetailTabIndex {
    _$selectedCourseDetailTabIndexAtom.reportRead();
    return super.selectedCourseDetailTabIndex;
  }

  @override
  set selectedCourseDetailTabIndex(int value) {
    _$selectedCourseDetailTabIndexAtom
        .reportWrite(value, super.selectedCourseDetailTabIndex, () {
      super.selectedCourseDetailTabIndex = value;
    });
  }

  late final _$courseListAtom =
      Atom(name: 'ProfileMenuStoreBase.courseList', context: context);

  @override
  ObservableList<CourseListModel> get courseList {
    _$courseListAtom.reportRead();
    return super.courseList;
  }

  @override
  set courseList(ObservableList<CourseListModel> value) {
    _$courseListAtom.reportWrite(value, super.courseList, () {
      super.courseList = value;
    });
  }

  late final _$coursesTypeAtom =
      Atom(name: 'ProfileMenuStoreBase.coursesType', context: context);

  @override
  ObservableList<CourseCategory> get coursesType {
    _$coursesTypeAtom.reportRead();
    return super.coursesType;
  }

  @override
  set coursesType(ObservableList<CourseCategory> value) {
    _$coursesTypeAtom.reportWrite(value, super.coursesType, () {
      super.coursesType = value;
    });
  }

  late final _$selectedCourseCategoryAtom = Atom(
      name: 'ProfileMenuStoreBase.selectedCourseCategory', context: context);

  @override
  int get selectedCourseCategory {
    _$selectedCourseCategoryAtom.reportRead();
    return super.selectedCourseCategory;
  }

  @override
  set selectedCourseCategory(int value) {
    _$selectedCourseCategoryAtom
        .reportWrite(value, super.selectedCourseCategory, () {
      super.selectedCourseCategory = value;
    });
  }

  late final _$cartItemListAtom =
      Atom(name: 'ProfileMenuStoreBase.cartItemList', context: context);

  @override
  ObservableList<CartItemModel> get cartItemList {
    _$cartItemListAtom.reportRead();
    return super.cartItemList;
  }

  @override
  set cartItemList(ObservableList<CartItemModel> value) {
    _$cartItemListAtom.reportWrite(value, super.cartItemList, () {
      super.cartItemList = value;
    });
  }

  late final _$totalAtom =
      Atom(name: 'ProfileMenuStoreBase.total', context: context);

  @override
  int get total {
    _$totalAtom.reportRead();
    return super.total;
  }

  @override
  set total(int value) {
    _$totalAtom.reportWrite(value, super.total, () {
      super.total = value;
    });
  }

  late final _$cartAtom =
      Atom(name: 'ProfileMenuStoreBase.cart', context: context);

  @override
  CartModel? get cart {
    _$cartAtom.reportRead();
    return super.cart;
  }

  @override
  set cart(CartModel? value) {
    _$cartAtom.reportWrite(value, super.cart, () {
      super.cart = value;
    });
  }

  late final _$blogListAtom =
      Atom(name: 'ProfileMenuStoreBase.blogList', context: context);

  @override
  ObservableList<WpPostResponse> get blogList {
    _$blogListAtom.reportRead();
    return super.blogList;
  }

  @override
  set blogList(ObservableList<WpPostResponse> value) {
    _$blogListAtom.reportWrite(value, super.blogList, () {
      super.blogList = value;
    });
  }

  late final _$groupTypeAtom =
      Atom(name: 'ProfileMenuStoreBase.groupType', context: context);

  @override
  GroupType? get groupType {
    _$groupTypeAtom.reportRead();
    return super.groupType;
  }

  @override
  set groupType(GroupType? value) {
    _$groupTypeAtom.reportWrite(value, super.groupType, () {
      super.groupType = value;
    });
  }

  late final _$selectedRewardIndexAtom =
      Atom(name: 'ProfileMenuStoreBase.selectedRewardIndex', context: context);

  @override
  int get selectedRewardIndex {
    _$selectedRewardIndexAtom.reportRead();
    return super.selectedRewardIndex;
  }

  @override
  set selectedRewardIndex(int value) {
    _$selectedRewardIndexAtom.reportWrite(value, super.selectedRewardIndex, () {
      super.selectedRewardIndex = value;
    });
  }

  late final _$rewardDataAtom =
      Atom(name: 'ProfileMenuStoreBase.rewardData', context: context);

  @override
  RewardsModel? get rewardData {
    _$rewardDataAtom.reportRead();
    return super.rewardData;
  }

  @override
  set rewardData(RewardsModel? value) {
    _$rewardDataAtom.reportWrite(value, super.rewardData, () {
      super.rewardData = value;
    });
  }

  late final _$rewardTabsAtom =
      Atom(name: 'ProfileMenuStoreBase.rewardTabs', context: context);

  @override
  ObservableList<String> get rewardTabs {
    _$rewardTabsAtom.reportRead();
    return super.rewardTabs;
  }

  @override
  set rewardTabs(ObservableList<String> value) {
    _$rewardTabsAtom.reportWrite(value, super.rewardTabs, () {
      super.rewardTabs = value;
    });
  }

  late final _$couponsListAtom =
      Atom(name: 'ProfileMenuStoreBase.couponsList', context: context);

  @override
  ObservableList<CouponModel> get couponsList {
    _$couponsListAtom.reportRead();
    return super.couponsList;
  }

  @override
  set couponsList(ObservableList<CouponModel> value) {
    _$couponsListAtom.reportWrite(value, super.couponsList, () {
      super.couponsList = value;
    });
  }

  late final _$notificationListAtom =
      Atom(name: 'ProfileMenuStoreBase.notificationList', context: context);

  @override
  ObservableList<NotificationSettingsModel> get notificationList {
    _$notificationListAtom.reportRead();
    return super.notificationList;
  }

  @override
  set notificationList(ObservableList<NotificationSettingsModel> value) {
    _$notificationListAtom.reportWrite(value, super.notificationList, () {
      super.notificationList = value;
    });
  }

  late final _$isChangeAtom =
      Atom(name: 'ProfileMenuStoreBase.isChange', context: context);

  @override
  bool get isChange {
    _$isChangeAtom.reportRead();
    return super.isChange;
  }

  @override
  set isChange(bool value) {
    _$isChangeAtom.reportWrite(value, super.isChange, () {
      super.isChange = value;
    });
  }

  late final _$dropdownValueAtom =
      Atom(name: 'ProfileMenuStoreBase.dropdownValue', context: context);

  @override
  Visibilities get dropdownValue {
    _$dropdownValueAtom.reportRead();
    return super.dropdownValue;
  }

  @override
  set dropdownValue(Visibilities value) {
    _$dropdownValueAtom.reportWrite(value, super.dropdownValue, () {
      super.dropdownValue = value;
    });
  }

  late final _$visibilityListAtom =
      Atom(name: 'ProfileMenuStoreBase.visibilityList', context: context);

  @override
  ObservableList<ProfileVisibilityModel> get visibilityList {
    _$visibilityListAtom.reportRead();
    return super.visibilityList;
  }

  @override
  set visibilityList(ObservableList<ProfileVisibilityModel> value) {
    _$visibilityListAtom.reportWrite(value, super.visibilityList, () {
      super.visibilityList = value;
    });
  }

  late final _$membersListAtom =
      Atom(name: 'ProfileMenuStoreBase.membersList', context: context);

  @override
  ObservableList<BlockedAccountsModel> get membersList {
    _$membersListAtom.reportRead();
    return super.membersList;
  }

  @override
  set membersList(ObservableList<BlockedAccountsModel> value) {
    _$membersListAtom.reportWrite(value, super.membersList, () {
      super.membersList = value;
    });
  }

  late final _$plansAtom =
      Atom(name: 'ProfileMenuStoreBase.plans', context: context);

  @override
  ObservableList<MembershipModel> get plans {
    _$plansAtom.reportRead();
    return super.plans;
  }

  @override
  set plans(ObservableList<MembershipModel> value) {
    _$plansAtom.reportWrite(value, super.plans, () {
      super.plans = value;
    });
  }

  late final _$selectedLanguageIndexAtom = Atom(
      name: 'ProfileMenuStoreBase.selectedLanguageIndex', context: context);

  @override
  int get selectedLanguageIndex {
    _$selectedLanguageIndexAtom.reportRead();
    return super.selectedLanguageIndex;
  }

  @override
  set selectedLanguageIndex(int value) {
    _$selectedLanguageIndexAtom.reportWrite(value, super.selectedLanguageIndex,
        () {
      super.selectedLanguageIndex = value;
    });
  }

  late final _$selectedPaymentMethodAtom = Atom(
      name: 'ProfileMenuStoreBase.selectedPaymentMethod', context: context);

  @override
  LmsPaymentModel? get selectedPaymentMethod {
    _$selectedPaymentMethodAtom.reportRead();
    return super.selectedPaymentMethod;
  }

  @override
  set selectedPaymentMethod(LmsPaymentModel? value) {
    _$selectedPaymentMethodAtom.reportWrite(value, super.selectedPaymentMethod,
        () {
      super.selectedPaymentMethod = value;
    });
  }

  late final _$isPaymentGatewayLoadingAtom = Atom(
      name: 'ProfileMenuStoreBase.isPaymentGatewayLoading', context: context);

  @override
  bool get isPaymentGatewayLoading {
    _$isPaymentGatewayLoadingAtom.reportRead();
    return super.isPaymentGatewayLoading;
  }

  @override
  set isPaymentGatewayLoading(bool value) {
    _$isPaymentGatewayLoadingAtom
        .reportWrite(value, super.isPaymentGatewayLoading, () {
      super.isPaymentGatewayLoading = value;
    });
  }

  late final _$paymentGatewaysAtom =
      Atom(name: 'ProfileMenuStoreBase.paymentGateways', context: context);

  @override
  ObservableList<LmsPaymentModel> get paymentGateways {
    _$paymentGatewaysAtom.reportRead();
    return super.paymentGateways;
  }

  @override
  set paymentGateways(ObservableList<LmsPaymentModel> value) {
    _$paymentGatewaysAtom.reportWrite(value, super.paymentGateways, () {
      super.paymentGateways = value;
    });
  }

  late final _$lessonAtom =
      Atom(name: 'ProfileMenuStoreBase.lesson', context: context);

  @override
  LessonModel get lesson {
    _$lessonAtom.reportRead();
    return super.lesson;
  }

  @override
  set lesson(LessonModel value) {
    _$lessonAtom.reportWrite(value, super.lesson, () {
      super.lesson = value;
    });
  }

  late final _$isLessonFetchedAtom =
      Atom(name: 'ProfileMenuStoreBase.isLessonFetched', context: context);

  @override
  bool get isLessonFetched {
    _$isLessonFetchedAtom.reportRead();
    return super.isLessonFetched;
  }

  @override
  set isLessonFetched(bool value) {
    _$isLessonFetchedAtom.reportWrite(value, super.isLessonFetched, () {
      super.isLessonFetched = value;
    });
  }

  late final _$snapAtom =
      Atom(name: 'ProfileMenuStoreBase.snap', context: context);

  @override
  CourseReviewModel get snap {
    _$snapAtom.reportRead();
    return super.snap;
  }

  @override
  set snap(CourseReviewModel value) {
    _$snapAtom.reportWrite(value, super.snap, () {
      super.snap = value;
    });
  }

  late final _$ratingsAtom =
      Atom(name: 'ProfileMenuStoreBase.ratings', context: context);

  @override
  List<SingleRatingItem> get ratings {
    _$ratingsAtom.reportRead();
    return super.ratings;
  }

  @override
  set ratings(List<SingleRatingItem> value) {
    _$ratingsAtom.reportWrite(value, super.ratings, () {
      super.ratings = value;
    });
  }

  late final _$showLoadingAtom =
      Atom(name: 'ProfileMenuStoreBase.showLoading', context: context);

  @override
  bool get showLoading {
    _$showLoadingAtom.reportRead();
    return super.showLoading;
  }

  @override
  set showLoading(bool value) {
    _$showLoadingAtom.reportWrite(value, super.showLoading, () {
      super.showLoading = value;
    });
  }

  late final _$isReviewQuizAtom =
      Atom(name: 'ProfileMenuStoreBase.isReviewQuiz', context: context);

  @override
  bool get isReviewQuiz {
    _$isReviewQuizAtom.reportRead();
    return super.isReviewQuiz;
  }

  @override
  set isReviewQuiz(bool value) {
    _$isReviewQuizAtom.reportWrite(value, super.isReviewQuiz, () {
      super.isReviewQuiz = value;
    });
  }

  late final _$quizAtom =
      Atom(name: 'ProfileMenuStoreBase.quiz', context: context);

  @override
  QuizModel get quiz {
    _$quizAtom.reportRead();
    return super.quiz;
  }

  @override
  set quiz(QuizModel value) {
    _$quizAtom.reportWrite(value, super.quiz, () {
      super.quiz = value;
    });
  }

  late final _$answersAtom =
      Atom(name: 'ProfileMenuStoreBase.answers', context: context);

  @override
  List<Answers> get answers {
    _$answersAtom.reportRead();
    return super.answers;
  }

  @override
  set answers(List<Answers> value) {
    _$answersAtom.reportWrite(value, super.answers, () {
      super.answers = value;
    });
  }

  late final _$reviewAnswersAtom =
      Atom(name: 'ProfileMenuStoreBase.reviewAnswers', context: context);

  @override
  ObservableList<QuestionAnsweresModel> get reviewAnswers {
    _$reviewAnswersAtom.reportRead();
    return super.reviewAnswers;
  }

  @override
  set reviewAnswers(ObservableList<QuestionAnsweresModel> value) {
    _$reviewAnswersAtom.reportWrite(value, super.reviewAnswers, () {
      super.reviewAnswers = value;
    });
  }

  late final _$quizPageIndexAtom =
      Atom(name: 'ProfileMenuStoreBase.quizPageIndex', context: context);

  @override
  int get quizPageIndex {
    _$quizPageIndexAtom.reportRead();
    return super.quizPageIndex;
  }

  @override
  set quizPageIndex(int value) {
    _$quizPageIndexAtom.reportWrite(value, super.quizPageIndex, () {
      super.quizPageIndex = value;
    });
  }

  late final _$timeToShowAtom =
      Atom(name: 'ProfileMenuStoreBase.timeToShow', context: context);

  @override
  String get timeToShow {
    _$timeToShowAtom.reportRead();
    return super.timeToShow;
  }

  @override
  set timeToShow(String value) {
    _$timeToShowAtom.reportWrite(value, super.timeToShow, () {
      super.timeToShow = value;
    });
  }

  late final _$topicsViewListAtom =
      Atom(name: 'ProfileMenuStoreBase.topicsViewList', context: context);

  @override
  ObservableList<TopicModel> get topicsViewList {
    _$topicsViewListAtom.reportRead();
    return super.topicsViewList;
  }

  @override
  set topicsViewList(ObservableList<TopicModel> value) {
    _$topicsViewListAtom.reportWrite(value, super.topicsViewList, () {
      super.topicsViewList = value;
    });
  }

  late final _$forumsListAtom =
      Atom(name: 'ProfileMenuStoreBase.forumsList', context: context);

  @override
  ObservableList<ForumModel> get forumsList {
    _$forumsListAtom.reportRead();
    return super.forumsList;
  }

  @override
  set forumsList(ObservableList<ForumModel> value) {
    _$forumsListAtom.reportWrite(value, super.forumsList, () {
      super.forumsList = value;
    });
  }

  late final _$forumDataAtom =
      Atom(name: 'ProfileMenuStoreBase.forumData', context: context);

  @override
  ForumModel? get forumData {
    _$forumDataAtom.reportRead();
    return super.forumData;
  }

  @override
  set forumData(ForumModel? value) {
    _$forumDataAtom.reportWrite(value, super.forumData, () {
      super.forumData = value;
    });
  }

  late final _$showNewCategoryListAtom =
      Atom(name: 'ProfileMenuStoreBase.showNewCategoryList', context: context);

  @override
  bool get showNewCategoryList {
    _$showNewCategoryListAtom.reportRead();
    return super.showNewCategoryList;
  }

  @override
  set showNewCategoryList(bool value) {
    _$showNewCategoryListAtom.reportWrite(value, super.showNewCategoryList, () {
      super.showNewCategoryList = value;
    });
  }

  late final _$hasShowClearTextIconAtom =
      Atom(name: 'ProfileMenuStoreBase.hasShowClearTextIcon', context: context);

  @override
  bool get hasShowClearTextIcon {
    _$hasShowClearTextIconAtom.reportRead();
    return super.hasShowClearTextIcon;
  }

  @override
  set hasShowClearTextIcon(bool value) {
    _$hasShowClearTextIconAtom.reportWrite(value, super.hasShowClearTextIcon,
        () {
      super.hasShowClearTextIcon = value;
    });
  }

  late final _$highlightCategoryListAtom = Atom(
      name: 'ProfileMenuStoreBase.highlightCategoryList', context: context);

  @override
  ObservableList<HighlightCategoryListModel> get highlightCategoryList {
    _$highlightCategoryListAtom.reportRead();
    return super.highlightCategoryList;
  }

  @override
  set highlightCategoryList(ObservableList<HighlightCategoryListModel> value) {
    _$highlightCategoryListAtom.reportWrite(value, super.highlightCategoryList,
        () {
      super.highlightCategoryList = value;
    });
  }

  late final _$highlightDropdownValAtom =
      Atom(name: 'ProfileMenuStoreBase.highlightDropdownVal', context: context);

  @override
  HighlightCategoryListModel get highlightDropdownVal {
    _$highlightDropdownValAtom.reportRead();
    return super.highlightDropdownVal;
  }

  @override
  set highlightDropdownVal(HighlightCategoryListModel value) {
    _$highlightDropdownValAtom.reportWrite(value, super.highlightDropdownVal,
        () {
      super.highlightDropdownVal = value;
    });
  }

  late final _$categoryImageAtom =
      Atom(name: 'ProfileMenuStoreBase.categoryImage', context: context);

  @override
  File? get categoryImage {
    _$categoryImageAtom.reportRead();
    return super.categoryImage;
  }

  @override
  set categoryImage(File? value) {
    _$categoryImageAtom.reportWrite(value, super.categoryImage, () {
      super.categoryImage = value;
    });
  }

  late final _$dialogHighlightListAtom =
      Atom(name: 'ProfileMenuStoreBase.dialogHighlightList', context: context);

  @override
  ObservableList<HighlightStoriesModel> get dialogHighlightList {
    _$dialogHighlightListAtom.reportRead();
    return super.dialogHighlightList;
  }

  @override
  set dialogHighlightList(ObservableList<HighlightStoriesModel> value) {
    _$dialogHighlightListAtom.reportWrite(value, super.dialogHighlightList, () {
      super.dialogHighlightList = value;
    });
  }

  late final _$dialogDropdownValueAtom =
      Atom(name: 'ProfileMenuStoreBase.dialogDropdownValue', context: context);

  @override
  HighlightStoriesModel get dialogDropdownValue {
    _$dialogDropdownValueAtom.reportRead();
    return super.dialogDropdownValue;
  }

  @override
  set dialogDropdownValue(HighlightStoriesModel value) {
    _$dialogDropdownValueAtom.reportWrite(value, super.dialogDropdownValue, () {
      super.dialogDropdownValue = value;
    });
  }

  late final _$categoryPicAtom =
      Atom(name: 'ProfileMenuStoreBase.categoryPic', context: context);

  @override
  File? get categoryPic {
    _$categoryPicAtom.reportRead();
    return super.categoryPic;
  }

  @override
  set categoryPic(File? value) {
    _$categoryPicAtom.reportWrite(value, super.categoryPic, () {
      super.categoryPic = value;
    });
  }

  late final _$topicListAtom =
      Atom(name: 'ProfileMenuStoreBase.topicList', context: context);

  @override
  ObservableList<TopicModel> get topicList {
    _$topicListAtom.reportRead();
    return super.topicList;
  }

  @override
  set topicList(ObservableList<TopicModel> value) {
    _$topicListAtom.reportWrite(value, super.topicList, () {
      super.topicList = value;
    });
  }

  late final _$forumListDataAtom =
      Atom(name: 'ProfileMenuStoreBase.forumListData', context: context);

  @override
  ObservableList<ForumModel> get forumListData {
    _$forumListDataAtom.reportRead();
    return super.forumListData;
  }

  @override
  set forumListData(ObservableList<ForumModel> value) {
    _$forumListDataAtom.reportWrite(value, super.forumListData, () {
      super.forumListData = value;
    });
  }

  late final _$isRequestedAtom =
      Atom(name: 'ProfileMenuStoreBase.isRequested', context: context);

  @override
  bool get isRequested {
    _$isRequestedAtom.reportRead();
    return super.isRequested;
  }

  @override
  set isRequested(bool value) {
    _$isRequestedAtom.reportWrite(value, super.isRequested, () {
      super.isRequested = value;
    });
  }

  late final _$avatarUrlAtom =
      Atom(name: 'ProfileMenuStoreBase.avatarUrl', context: context);

  @override
  String get avatarUrl {
    _$avatarUrlAtom.reportRead();
    return super.avatarUrl;
  }

  @override
  set avatarUrl(String value) {
    _$avatarUrlAtom.reportWrite(value, super.avatarUrl, () {
      super.avatarUrl = value;
    });
  }

  late final _$coverImageAtom =
      Atom(name: 'ProfileMenuStoreBase.coverImage', context: context);

  @override
  String get coverImage {
    _$coverImageAtom.reportRead();
    return super.coverImage;
  }

  @override
  set coverImage(String value) {
    _$coverImageAtom.reportWrite(value, super.coverImage, () {
      super.coverImage = value;
    });
  }

  late final _$avatarImageAtom =
      Atom(name: 'ProfileMenuStoreBase.avatarImage', context: context);

  @override
  File? get avatarImage {
    _$avatarImageAtom.reportRead();
    return super.avatarImage;
  }

  @override
  set avatarImage(File? value) {
    _$avatarImageAtom.reportWrite(value, super.avatarImage, () {
      super.avatarImage = value;
    });
  }

  late final _$coverAtom =
      Atom(name: 'ProfileMenuStoreBase.cover', context: context);

  @override
  File? get cover {
    _$coverAtom.reportRead();
    return super.cover;
  }

  @override
  set cover(File? value) {
    _$coverAtom.reportWrite(value, super.cover, () {
      super.cover = value;
    });
  }

  late final _$fieldListAtom =
      Atom(name: 'ProfileMenuStoreBase.fieldList', context: context);

  @override
  ObservableList<SignupFields> get fieldList {
    _$fieldListAtom.reportRead();
    return super.fieldList;
  }

  @override
  set fieldList(ObservableList<SignupFields> value) {
    _$fieldListAtom.reportWrite(value, super.fieldList, () {
      super.fieldList = value;
    });
  }

  late final _$isCoverAtom =
      Atom(name: 'ProfileMenuStoreBase.isCover', context: context);

  @override
  bool get isCover {
    _$isCoverAtom.reportRead();
    return super.isCover;
  }

  @override
  set isCover(bool value) {
    _$isCoverAtom.reportWrite(value, super.isCover, () {
      super.isCover = value;
    });
  }

  late final _$friendshipStatusAtom =
      Atom(name: 'ProfileMenuStoreBase.friendshipStatus', context: context);

  @override
  String get friendshipStatus {
    _$friendshipStatusAtom.reportRead();
    return super.friendshipStatus;
  }

  bool _friendshipStatusIsInitialized = false;

  @override
  set friendshipStatus(String value) {
    _$friendshipStatusAtom.reportWrite(
        value, _friendshipStatusIsInitialized ? super.friendshipStatus : null,
        () {
      super.friendshipStatus = value;
      _friendshipStatusIsInitialized = true;
    });
  }

  late final _$listOfBadgeAtom =
      Atom(name: 'ProfileMenuStoreBase.listOfBadge', context: context);

  @override
  ObservableList<Rank> get listOfBadge {
    _$listOfBadgeAtom.reportRead();
    return super.listOfBadge;
  }

  @override
  set listOfBadge(ObservableList<Rank> value) {
    _$listOfBadgeAtom.reportWrite(value, super.listOfBadge, () {
      super.listOfBadge = value;
    });
  }

  late final _$pastOrderListAtom =
      Atom(name: 'ProfileMenuStoreBase.pastOrderList', context: context);

  @override
  ObservableList<PmpOrderModel> get pastOrderList {
    _$pastOrderListAtom.reportRead();
    return super.pastOrderList;
  }

  @override
  set pastOrderList(ObservableList<PmpOrderModel> value) {
    _$pastOrderListAtom.reportWrite(value, super.pastOrderList, () {
      super.pastOrderList = value;
    });
  }

  late final _$allOrderListAtom =
      Atom(name: 'ProfileMenuStoreBase.allOrderList', context: context);

  @override
  ObservableList<PmpOrderModel> get allOrderList {
    _$allOrderListAtom.reportRead();
    return super.allOrderList;
  }

  @override
  set allOrderList(ObservableList<PmpOrderModel> value) {
    _$allOrderListAtom.reportWrite(value, super.allOrderList, () {
      super.allOrderList = value;
    });
  }

  late final _$mPageAtom =
      Atom(name: 'ProfileMenuStoreBase.mPage', context: context);

  @override
  int get mPage {
    _$mPageAtom.reportRead();
    return super.mPage;
  }

  @override
  set mPage(int value) {
    _$mPageAtom.reportWrite(value, super.mPage, () {
      super.mPage = value;
    });
  }

  late final _$mIsLastPageAtom =
      Atom(name: 'ProfileMenuStoreBase.mIsLastPage', context: context);

  @override
  bool get mIsLastPage {
    _$mIsLastPageAtom.reportRead();
    return super.mIsLastPage;
  }

  @override
  set mIsLastPage(bool value) {
    _$mIsLastPageAtom.reportWrite(value, super.mIsLastPage, () {
      super.mIsLastPage = value;
    });
  }

  late final _$profileListAtom =
      Atom(name: 'ProfileMenuStoreBase.profileList', context: context);

  @override
  ObservableList<ProfileVisibilityModel> get profileList {
    _$profileListAtom.reportRead();
    return super.profileList;
  }

  @override
  set profileList(ObservableList<ProfileVisibilityModel> value) {
    _$profileListAtom.reportWrite(value, super.profileList, () {
      super.profileList = value;
    });
  }

  late final _$futuresAtom =
      Atom(name: 'ProfileMenuStoreBase.futures', context: context);

  @override
  ObservableList<Future<dynamic>> get futures {
    _$futuresAtom.reportRead();
    return super.futures;
  }

  @override
  set futures(ObservableList<Future<dynamic>> value) {
    _$futuresAtom.reportWrite(value, super.futures, () {
      super.futures = value;
    });
  }

  late final _$messagesAtom =
      Atom(name: 'ProfileMenuStoreBase.messages', context: context);

  @override
  ObservableList<String> get messages {
    _$messagesAtom.reportRead();
    return super.messages;
  }

  @override
  set messages(ObservableList<String> value) {
    _$messagesAtom.reportWrite(value, super.messages, () {
      super.messages = value;
    });
  }

  late final _$selectedAchievementTypeIndexAtom = Atom(
      name: 'ProfileMenuStoreBase.selectedAchievementTypeIndex',
      context: context);

  @override
  int get selectedAchievementTypeIndex {
    _$selectedAchievementTypeIndexAtom.reportRead();
    return super.selectedAchievementTypeIndex;
  }

  @override
  set selectedAchievementTypeIndex(int value) {
    _$selectedAchievementTypeIndexAtom
        .reportWrite(value, super.selectedAchievementTypeIndex, () {
      super.selectedAchievementTypeIndex = value;
    });
  }

  late final _$achievementFutureAtom =
      Atom(name: 'ProfileMenuStoreBase.achievementFuture', context: context);

  @override
  Future<List<CommonGamiPressModel>>? get achievementFuture {
    _$achievementFutureAtom.reportRead();
    return super.achievementFuture;
  }

  @override
  set achievementFuture(Future<List<CommonGamiPressModel>>? value) {
    _$achievementFutureAtom.reportWrite(value, super.achievementFuture, () {
      super.achievementFuture = value;
    });
  }

  late final _$achievementListAtom =
      Atom(name: 'ProfileMenuStoreBase.achievementList', context: context);

  @override
  ObservableList<CommonGamiPressModel> get achievementList {
    _$achievementListAtom.reportRead();
    return super.achievementList;
  }

  @override
  set achievementList(ObservableList<CommonGamiPressModel> value) {
    _$achievementListAtom.reportWrite(value, super.achievementList, () {
      super.achievementList = value;
    });
  }

  late final _$selectedAchievementAtom =
      Atom(name: 'ProfileMenuStoreBase.selectedAchievement', context: context);

  @override
  GamipressAchievementTypes? get selectedAchievement {
    _$selectedAchievementAtom.reportRead();
    return super.selectedAchievement;
  }

  @override
  set selectedAchievement(GamipressAchievementTypes? value) {
    _$selectedAchievementAtom.reportWrite(value, super.selectedAchievement, () {
      super.selectedAchievement = value;
    });
  }

  late final _$selectedRankTypeIndexAtom = Atom(
      name: 'ProfileMenuStoreBase.selectedRankTypeIndex', context: context);

  @override
  int get selectedRankTypeIndex {
    _$selectedRankTypeIndexAtom.reportRead();
    return super.selectedRankTypeIndex;
  }

  @override
  set selectedRankTypeIndex(int value) {
    _$selectedRankTypeIndexAtom.reportWrite(value, super.selectedRankTypeIndex,
        () {
      super.selectedRankTypeIndex = value;
    });
  }

  late final _$rankFutureAtom =
      Atom(name: 'ProfileMenuStoreBase.rankFuture', context: context);

  @override
  Future<List<CommonGamiPressModel>>? get rankFuture {
    _$rankFutureAtom.reportRead();
    return super.rankFuture;
  }

  @override
  set rankFuture(Future<List<CommonGamiPressModel>>? value) {
    _$rankFutureAtom.reportWrite(value, super.rankFuture, () {
      super.rankFuture = value;
    });
  }

  late final _$rankListAtom =
      Atom(name: 'ProfileMenuStoreBase.rankList', context: context);

  @override
  List<CommonGamiPressModel> get rankList {
    _$rankListAtom.reportRead();
    return super.rankList;
  }

  @override
  set rankList(List<CommonGamiPressModel> value) {
    _$rankListAtom.reportWrite(value, super.rankList, () {
      super.rankList = value;
    });
  }

  late final _$selectedRankAtom =
      Atom(name: 'ProfileMenuStoreBase.selectedRank', context: context);

  @override
  GamipressAchievementTypes? get selectedRank {
    _$selectedRankAtom.reportRead();
    return super.selectedRank;
  }

  @override
  set selectedRank(GamipressAchievementTypes? value) {
    _$selectedRankAtom.reportWrite(value, super.selectedRank, () {
      super.selectedRank = value;
    });
  }

  late final _$setLoadingAsyncAction =
      AsyncAction('ProfileMenuStoreBase.setLoading', context: context);

  @override
  Future<void> setLoading(bool val) {
    return _$setLoadingAsyncAction.run(() => super.setLoading(val));
  }

  late final _$setAchievementTypeAsyncAction =
      AsyncAction('ProfileMenuStoreBase.setAchievementType', context: context);

  @override
  Future<void> setAchievementType(GamipressAchievementTypes achievementType) {
    return _$setAchievementTypeAsyncAction
        .run(() => super.setAchievementType(achievementType));
  }

  late final _$setSelectedAchievementTypeIndexAsyncAction = AsyncAction(
      'ProfileMenuStoreBase.setSelectedAchievementTypeIndex',
      context: context);

  @override
  Future<void> setSelectedAchievementTypeIndex(int index) {
    return _$setSelectedAchievementTypeIndexAsyncAction
        .run(() => super.setSelectedAchievementTypeIndex(index));
  }

  late final _$setSelectedRankTypeAsyncAction =
      AsyncAction('ProfileMenuStoreBase.setSelectedRankType', context: context);

  @override
  Future<void> setSelectedRankType(GamipressAchievementTypes rankType) {
    return _$setSelectedRankTypeAsyncAction
        .run(() => super.setSelectedRankType(rankType));
  }

  late final _$setSelectedRankTypeIndexAsyncAction = AsyncAction(
      'ProfileMenuStoreBase.setSelectedRankTypeIndex',
      context: context);

  @override
  Future<void> setSelectedRankTypeIndex(int index) {
    return _$setSelectedRankTypeIndexAsyncAction
        .run(() => super.setSelectedRankTypeIndex(index));
  }

  late final _$ProfileMenuStoreBaseActionController =
      ActionController(name: 'ProfileMenuStoreBase', context: context);

  @override
  void showClearTextIcon(bool value) {
    final _$actionInfo = _$ProfileMenuStoreBaseActionController.startAction(
        name: 'ProfileMenuStoreBase.showClearTextIcon');
    try {
      return super.showClearTextIcon(value);
    } finally {
      _$ProfileMenuStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isError: ${isError},
errorMSG: ${errorMSG},
isFetched: ${isFetched},
isLoading: ${isLoading},
codeList: ${codeList},
selectedCode: ${selectedCode},
highlightList: ${highlightList},
userStoryList: ${userStoryList},
currentValue: ${currentValue},
title: ${title},
showHighlightStory: ${showHighlightStory},
status: ${status},
showNewCategory: ${showNewCategory},
membership: ${membership},
hasMembership: ${hasMembership},
isCancelled: ${isCancelled},
showAddDiscount: ${showAddDiscount},
selectedIndex: ${selectedIndex},
friendReqList: ${friendReqList},
sentReq: ${sentReq},
receiveReq: ${receiveReq},
selectedTab: ${selectedTab},
topicsList: ${topicsList},
isSubscribed: ${isSubscribed},
isFavourite: ${isFavourite},
repliesList: ${repliesList},
topicsEngagementList: ${topicsEngagementList},
topicsFavouriteList: ${topicsFavouriteList},
forumList: ${forumList},
topicsSubscriptionList: ${topicsSubscriptionList},
tempReplies: ${tempReplies},
doNotify: ${doNotify},
badgeList: ${badgeList},
levels: ${levels},
course: ${course},
selectedCourseDetailTabIndex: ${selectedCourseDetailTabIndex},
courseList: ${courseList},
coursesType: ${coursesType},
selectedCourseCategory: ${selectedCourseCategory},
cartItemList: ${cartItemList},
total: ${total},
cart: ${cart},
blogList: ${blogList},
groupType: ${groupType},
selectedRewardIndex: ${selectedRewardIndex},
rewardData: ${rewardData},
rewardTabs: ${rewardTabs},
couponsList: ${couponsList},
notificationList: ${notificationList},
isChange: ${isChange},
dropdownValue: ${dropdownValue},
visibilityList: ${visibilityList},
membersList: ${membersList},
plans: ${plans},
selectedLanguageIndex: ${selectedLanguageIndex},
selectedPaymentMethod: ${selectedPaymentMethod},
isPaymentGatewayLoading: ${isPaymentGatewayLoading},
paymentGateways: ${paymentGateways},
lesson: ${lesson},
isLessonFetched: ${isLessonFetched},
snap: ${snap},
ratings: ${ratings},
showLoading: ${showLoading},
isReviewQuiz: ${isReviewQuiz},
quiz: ${quiz},
answers: ${answers},
reviewAnswers: ${reviewAnswers},
quizPageIndex: ${quizPageIndex},
timeToShow: ${timeToShow},
topicsViewList: ${topicsViewList},
forumsList: ${forumsList},
forumData: ${forumData},
showNewCategoryList: ${showNewCategoryList},
hasShowClearTextIcon: ${hasShowClearTextIcon},
highlightCategoryList: ${highlightCategoryList},
highlightDropdownVal: ${highlightDropdownVal},
categoryImage: ${categoryImage},
dialogHighlightList: ${dialogHighlightList},
dialogDropdownValue: ${dialogDropdownValue},
categoryPic: ${categoryPic},
topicList: ${topicList},
forumListData: ${forumListData},
isRequested: ${isRequested},
avatarUrl: ${avatarUrl},
coverImage: ${coverImage},
avatarImage: ${avatarImage},
cover: ${cover},
fieldList: ${fieldList},
isCover: ${isCover},
friendshipStatus: ${friendshipStatus},
listOfBadge: ${listOfBadge},
pastOrderList: ${pastOrderList},
allOrderList: ${allOrderList},
mPage: ${mPage},
mIsLastPage: ${mIsLastPage},
profileList: ${profileList},
futures: ${futures},
messages: ${messages},
selectedAchievementTypeIndex: ${selectedAchievementTypeIndex},
achievementFuture: ${achievementFuture},
achievementList: ${achievementList},
selectedAchievement: ${selectedAchievement},
selectedRankTypeIndex: ${selectedRankTypeIndex},
rankFuture: ${rankFuture},
rankList: ${rankList},
selectedRank: ${selectedRank}
    ''';
  }
}
