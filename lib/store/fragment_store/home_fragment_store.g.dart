// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_fragment_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$HomeFragStore on HomeFragmentBase, Store {
  Computed<bool>? _$hasStoriesComputed;

  @override
  bool get hasStories => (_$hasStoriesComputed ??= Computed<bool>(() => super.hasStories, name: 'HomeFragmentBase.hasStories')).value;
  Computed<bool>? _$hasUnseenStoriesComputed;

  @override
  bool get hasUnseenStories => (_$hasUnseenStoriesComputed ??= Computed<bool>(() => super.hasUnseenStories, name: 'HomeFragmentBase.hasUnseenStories')).value;
  Computed<bool>? _$allStoriesSeenComputed;

  @override
  bool get allStoriesSeen => (_$allStoriesSeenComputed ??= Computed<bool>(() => super.allStoriesSeen, name: 'HomeFragmentBase.allStoriesSeen')).value;

  late final _$isErrorAtom = Atom(name: 'HomeFragmentBase.isError', context: context);

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

  late final _$postListAtom = Atom(name: 'HomeFragmentBase.postList', context: context);

  @override
  ObservableList<PostModel> get postList {
    _$postListAtom.reportRead();
    return super.postList;
  }

  @override
  set postList(ObservableList<PostModel> value) {
    _$postListAtom.reportWrite(value, super.postList, () {
      super.postList = value;
    });
  }

  late final _$mHomePageAtom = Atom(name: 'HomeFragmentBase.mHomePage', context: context);

  @override
  int get mHomePage {
    _$mHomePageAtom.reportRead();
    return super.mHomePage;
  }

  @override
  set mHomePage(int value) {
    _$mHomePageAtom.reportWrite(value, super.mHomePage, () {
      super.mHomePage = value;
    });
  }

  late final _$postLikeListAtom = Atom(name: 'HomeFragmentBase.postLikeList', context: context);

  @override
  ObservableList<GetPostLikesModel> get postLikeList {
    _$postLikeListAtom.reportRead();
    return super.postLikeList;
  }

  @override
  set postLikeList(ObservableList<GetPostLikesModel> value) {
    _$postLikeListAtom.reportWrite(value, super.postLikeList, () {
      super.postLikeList = value;
    });
  }

  late final _$postReactionListAtom = Atom(name: 'HomeFragmentBase.postReactionList', context: context);

  @override
  ObservableList<Reactions> get postReactionList {
    _$postReactionListAtom.reportRead();
    return super.postReactionList;
  }

  @override
  set postReactionList(ObservableList<Reactions> value) {
    _$postReactionListAtom.reportWrite(value, super.postReactionList, () {
      super.postReactionList = value;
    });
  }

  late final _$isLikedAtom = Atom(name: 'HomeFragmentBase.isLiked', context: context);

  @override
  bool get isLiked {
    _$isLikedAtom.reportRead();
    return super.isLiked;
  }

  @override
  set isLiked(bool value) {
    _$isLikedAtom.reportWrite(value, super.isLiked, () {
      super.isLiked = value;
    });
  }

  late final _$postLikeCountAtom = Atom(name: 'HomeFragmentBase.postLikeCount', context: context);

  @override
  int get postLikeCount {
    _$postLikeCountAtom.reportRead();
    return super.postLikeCount;
  }

  @override
  set postLikeCount(int value) {
    _$postLikeCountAtom.reportWrite(value, super.postLikeCount, () {
      super.postLikeCount = value;
    });
  }

  late final _$indexAtom = Atom(name: 'HomeFragmentBase.index', context: context);

  @override
  int get index {
    _$indexAtom.reportRead();
    return super.index;
  }

  @override
  set index(int value) {
    _$indexAtom.reportWrite(value, super.index, () {
      super.index = value;
    });
  }

  late final _$isReactedAtom = Atom(name: 'HomeFragmentBase.isReacted', context: context);

  @override
  bool? get isReacted {
    _$isReactedAtom.reportRead();
    return super.isReacted;
  }

  @override
  set isReacted(bool? value) {
    _$isReactedAtom.reportWrite(value, super.isReacted, () {
      super.isReacted = value;
    });
  }

  late final _$isPostHiddenAtom = Atom(name: 'HomeFragmentBase.isPostHidden', context: context);

  @override
  bool get isPostHidden {
    _$isPostHiddenAtom.reportRead();
    return super.isPostHidden;
  }

  @override
  set isPostHidden(bool value) {
    _$isPostHiddenAtom.reportWrite(value, super.isPostHidden, () {
      super.isPostHidden = value;
    });
  }

  late final _$postReactionCountAtom = Atom(name: 'HomeFragmentBase.postReactionCount', context: context);

  @override
  int get postReactionCount {
    _$postReactionCountAtom.reportRead();
    return super.postReactionCount;
  }

  @override
  set postReactionCount(int value) {
    _$postReactionCountAtom.reportWrite(value, super.postReactionCount, () {
      super.postReactionCount = value;
    });
  }

  late final _$notifyAtom = Atom(name: 'HomeFragmentBase.notify', context: context);

  @override
  bool get notify {
    _$notifyAtom.reportRead();
    return super.notify;
  }

  @override
  set notify(bool value) {
    _$notifyAtom.reportWrite(value, super.notify, () {
      super.notify = value;
    });
  }

  late final _$mediaListAtom = Atom(name: 'HomeFragmentBase.mediaList', context: context);

  @override
  ObservableList<PostMedia> get mediaList {
    _$mediaListAtom.reportRead();
    return super.mediaList;
  }

  @override
  set mediaList(ObservableList<PostMedia> value) {
    _$mediaListAtom.reportWrite(value, super.mediaList, () {
      super.mediaList = value;
    });
  }

  late final _$postMediaAtom = Atom(name: 'HomeFragmentBase.postMedia', context: context);

  @override
  ObservableList<PostMediaModel> get postMedia {
    _$postMediaAtom.reportRead();
    return super.postMedia;
  }

  @override
  set postMedia(ObservableList<PostMediaModel> value) {
    _$postMediaAtom.reportWrite(value, super.postMedia, () {
      super.postMedia = value;
    });
  }

  late final _$mediaTypeListAtom = Atom(name: 'HomeFragmentBase.mediaTypeList', context: context);

  @override
  ObservableList<MediaModel> get mediaTypeList {
    _$mediaTypeListAtom.reportRead();
    return super.mediaTypeList;
  }

  @override
  set mediaTypeList(ObservableList<MediaModel> value) {
    _$mediaTypeListAtom.reportWrite(value, super.mediaTypeList, () {
      super.mediaTypeList = value;
    });
  }

  late final _$postInListAtom = Atom(name: 'HomeFragmentBase.postInList', context: context);

  @override
  ObservableList<PostInListModel> get postInList {
    _$postInListAtom.reportRead();
    return super.postInList;
  }

  @override
  set postInList(ObservableList<PostInListModel> value) {
    _$postInListAtom.reportWrite(value, super.postInList, () {
      super.postInList = value;
    });
  }

  late final _$mentionsMemberListAtom = Atom(name: 'HomeFragmentBase.mentionsMemberList', context: context);

  @override
  ObservableList<MemberResponse> get mentionsMemberList {
    _$mentionsMemberListAtom.reportRead();
    return super.mentionsMemberList;
  }

  @override
  set mentionsMemberList(ObservableList<MemberResponse> value) {
    _$mentionsMemberListAtom.reportWrite(value, super.mentionsMemberList, () {
      super.mentionsMemberList = value;
    });
  }

  late final _$userNameForMentionAtom = Atom(name: 'HomeFragmentBase.userNameForMention', context: context);

  @override
  ObservableList<Map<String, dynamic>> get userNameForMention {
    _$userNameForMentionAtom.reportRead();
    return super.userNameForMention;
  }

  @override
  set userNameForMention(ObservableList<Map<String, dynamic>> value) {
    _$userNameForMentionAtom.reportWrite(value, super.userNameForMention, () {
      super.userNameForMention = value;
    });
  }

  late final _$dropdownValueAtom = Atom(name: 'HomeFragmentBase.dropdownValue', context: context);

  @override
  PostInListModel get dropdownValue {
    _$dropdownValueAtom.reportRead();
    return super.dropdownValue;
  }

  @override
  set dropdownValue(PostInListModel value) {
    _$dropdownValueAtom.reportWrite(value, super.dropdownValue, () {
      super.dropdownValue = value;
    });
  }

  late final _$enableSelectMediaAtom = Atom(name: 'HomeFragmentBase.enableSelectMedia', context: context);

  @override
  bool get enableSelectMedia {
    _$enableSelectMediaAtom.reportRead();
    return super.enableSelectMedia;
  }

  @override
  set enableSelectMedia(bool value) {
    _$enableSelectMediaAtom.reportWrite(value, super.enableSelectMedia, () {
      super.enableSelectMedia = value;
    });
  }

  late final _$gifAtom = Atom(name: 'HomeFragmentBase.gif', context: context);

  @override
  GiphyGif? get gif {
    _$gifAtom.reportRead();
    return super.gif;
  }

  @override
  set gif(GiphyGif? value) {
    _$gifAtom.reportWrite(value, super.gif, () {
      super.gif = value;
    });
  }

  late final _$selectedMediaAtom = Atom(name: 'HomeFragmentBase.selectedMedia', context: context);

  @override
  MediaModel? get selectedMedia {
    _$selectedMediaAtom.reportRead();
    return super.selectedMedia;
  }

  @override
  set selectedMedia(MediaModel? value) {
    _$selectedMediaAtom.reportWrite(value, super.selectedMedia, () {
      super.selectedMedia = value;
    });
  }

  late final _$postContentAtom = Atom(name: 'HomeFragmentBase.postContent', context: context);

  @override
  String get postContent {
    _$postContentAtom.reportRead();
    return super.postContent;
  }

  @override
  set postContent(String value) {
    _$postContentAtom.reportWrite(value, super.postContent, () {
      super.postContent = value;
    });
  }

  late final _$singlePostAtom = Atom(name: 'HomeFragmentBase.singlePost', context: context);

  @override
  PostModel? get singlePost {
    _$singlePostAtom.reportRead();
    return super.singlePost;
  }

  @override
  set singlePost(PostModel? value) {
    _$singlePostAtom.reportWrite(value, super.singlePost, () {
      super.singlePost = value;
    });
  }

  late final _$likeListAtom = Atom(name: 'HomeFragmentBase.likeList', context: context);

  @override
  ObservableList<GetPostLikesModel> get likeList {
    _$likeListAtom.reportRead();
    return super.likeList;
  }

  @override
  set likeList(ObservableList<GetPostLikesModel> value) {
    _$likeListAtom.reportWrite(value, super.likeList, () {
      super.likeList = value;
    });
  }

  late final _$isLikeAtom = Atom(name: 'HomeFragmentBase.isLike', context: context);

  @override
  bool get isLike {
    _$isLikeAtom.reportRead();
    return super.isLike;
  }

  @override
  set isLike(bool value) {
    _$isLikeAtom.reportWrite(value, super.isLike, () {
      super.isLike = value;
    });
  }

  late final _$likeCountAtom = Atom(name: 'HomeFragmentBase.likeCount', context: context);

  @override
  int get likeCount {
    _$likeCountAtom.reportRead();
    return super.likeCount;
  }

  @override
  set likeCount(int value) {
    _$likeCountAtom.reportWrite(value, super.likeCount, () {
      super.likeCount = value;
    });
  }

  late final _$isChangeAtom = Atom(name: 'HomeFragmentBase.isChange', context: context);

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

  late final _$commentParentIdAtom = Atom(name: 'HomeFragmentBase.commentParentId', context: context);

  @override
  int get commentParentId {
    _$commentParentIdAtom.reportRead();
    return super.commentParentId;
  }

  @override
  set commentParentId(int value) {
    _$commentParentIdAtom.reportWrite(value, super.commentParentId, () {
      super.commentParentId = value;
    });
  }

  late final _$commentListAtom = Atom(name: 'HomeFragmentBase.commentList', context: context);

  @override
  ObservableList<CommentModel> get commentList {
    _$commentListAtom.reportRead();
    return super.commentList;
  }

  @override
  set commentList(ObservableList<CommentModel> value) {
    _$commentListAtom.reportWrite(value, super.commentList, () {
      super.commentList = value;
    });
  }

  late final _$commentGifAtom = Atom(name: 'HomeFragmentBase.commentGif', context: context);

  @override
  GiphyGif? get commentGif {
    _$commentGifAtom.reportRead();
    return super.commentGif;
  }

  @override
  set commentGif(GiphyGif? value) {
    _$commentGifAtom.reportWrite(value, super.commentGif, () {
      super.commentGif = value;
    });
  }

  late final _$memberListAtom = Atom(name: 'HomeFragmentBase.memberList', context: context);

  @override
  ObservableList<MemberResponse> get memberList {
    _$memberListAtom.reportRead();
    return super.memberList;
  }

  @override
  set memberList(ObservableList<MemberResponse> value) {
    _$memberListAtom.reportWrite(value, super.memberList, () {
      super.memberList = value;
    });
  }

  late final _$suggestedMemberListAtom = Atom(name: 'HomeFragmentBase.suggestedMemberList', context: context);

  @override
  ObservableList<FriendRequestModel> get suggestedMemberList {
    _$suggestedMemberListAtom.reportRead();
    return super.suggestedMemberList;
  }

  @override
  set suggestedMemberList(ObservableList<FriendRequestModel> value) {
    _$suggestedMemberListAtom.reportWrite(value, super.suggestedMemberList, () {
      super.suggestedMemberList = value;
    });
  }

  late final _$reactionsListAtom = Atom(name: 'HomeFragmentBase.reactionsList', context: context);

  @override
  ObservableList<Reactions> get reactionsList {
    _$reactionsListAtom.reportRead();
    return super.reactionsList;
  }

  @override
  set reactionsList(ObservableList<Reactions> value) {
    _$reactionsListAtom.reportWrite(value, super.reactionsList, () {
      super.reactionsList = value;
    });
  }

  late final _$reactionsCountAtom = Atom(name: 'HomeFragmentBase.reactionsCount', context: context);

  @override
  ObservableList<Reactions> get reactionsCount {
    _$reactionsCountAtom.reportRead();
    return super.reactionsCount;
  }

  @override
  set reactionsCount(ObservableList<Reactions> value) {
    _$reactionsCountAtom.reportWrite(value, super.reactionsCount, () {
      super.reactionsCount = value;
    });
  }

  late final _$selectedReactionAtom = Atom(name: 'HomeFragmentBase.selectedReaction', context: context);

  @override
  String get selectedReaction {
    _$selectedReactionAtom.reportRead();
    return super.selectedReaction;
  }

  @override
  set selectedReaction(String value) {
    _$selectedReactionAtom.reportWrite(value, super.selectedReaction, () {
      super.selectedReaction = value;
    });
  }

  late final _$likePostListAtom = Atom(name: 'HomeFragmentBase.likePostList', context: context);

  @override
  ObservableList<GetPostLikesModel> get likePostList {
    _$likePostListAtom.reportRead();
    return super.likePostList;
  }

  @override
  set likePostList(ObservableList<GetPostLikesModel> value) {
    _$likePostListAtom.reportWrite(value, super.likePostList, () {
      super.likePostList = value;
    });
  }

  late final _$commentReplyParentIdAtom = Atom(name: 'HomeFragmentBase.commentReplyParentId', context: context);

  @override
  int get commentReplyParentId {
    _$commentReplyParentIdAtom.reportRead();
    return super.commentReplyParentId;
  }

  @override
  set commentReplyParentId(int value) {
    _$commentReplyParentIdAtom.reportWrite(value, super.commentReplyParentId, () {
      super.commentReplyParentId = value;
    });
  }

  late final _$commentReplyListAtom = Atom(name: 'HomeFragmentBase.commentReplyList', context: context);

  @override
  ObservableList<CommentModel> get commentReplyList {
    _$commentReplyListAtom.reportRead();
    return super.commentReplyList;
  }

  @override
  set commentReplyList(ObservableList<CommentModel> value) {
    _$commentReplyListAtom.reportWrite(value, super.commentReplyList, () {
      super.commentReplyList = value;
    });
  }

  late final _$commentReplyGifAtom = Atom(name: 'HomeFragmentBase.commentReplyGif', context: context);

  @override
  GiphyGif? get commentReplyGif {
    _$commentReplyGifAtom.reportRead();
    return super.commentReplyGif;
  }

  @override
  set commentReplyGif(GiphyGif? value) {
    _$commentReplyGifAtom.reportWrite(value, super.commentReplyGif, () {
      super.commentReplyGif = value;
    });
  }

  late final _$videoPlayerControllerAtom = Atom(name: 'HomeFragmentBase.videoPlayerController', context: context);

  @override
  CachedVideoPlayerController get videoPlayerController {
    _$videoPlayerControllerAtom.reportRead();
    return super.videoPlayerController;
  }

  bool _videoPlayerControllerIsInitialized = false;

  @override
  set videoPlayerController(CachedVideoPlayerController value) {
    _$videoPlayerControllerAtom.reportWrite(value, _videoPlayerControllerIsInitialized ? super.videoPlayerController : null, () {
      super.videoPlayerController = value;
      _videoPlayerControllerIsInitialized = true;
    });
  }

  late final _$customVideoPlayerControllerAtom = Atom(name: 'HomeFragmentBase.customVideoPlayerController', context: context);

  @override
  CustomVideoPlayerController get customVideoPlayerController {
    _$customVideoPlayerControllerAtom.reportRead();
    return super.customVideoPlayerController;
  }

  bool _customVideoPlayerControllerIsInitialized = false;

  @override
  set customVideoPlayerController(CustomVideoPlayerController value) {
    _$customVideoPlayerControllerAtom.reportWrite(value, _customVideoPlayerControllerIsInitialized ? super.customVideoPlayerController : null, () {
      super.customVideoPlayerController = value;
      _customVideoPlayerControllerIsInitialized = true;
    });
  }

  late final _$visibilityKeyAtom = Atom(name: 'HomeFragmentBase.visibilityKey', context: context);

  @override
  GlobalKey<State<StatefulWidget>> get visibilityKey {
    _$visibilityKeyAtom.reportRead();
    return super.visibilityKey;
  }

  @override
  set visibilityKey(GlobalKey<State<StatefulWidget>> value) {
    _$visibilityKeyAtom.reportWrite(value, super.visibilityKey, () {
      super.visibilityKey = value;
    });
  }

  late final _$videoUrlAtom = Atom(name: 'HomeFragmentBase.videoUrl', context: context);

  @override
  String get videoUrl {
    _$videoUrlAtom.reportRead();
    return super.videoUrl;
  }

  @override
  set videoUrl(String value) {
    _$videoUrlAtom.reportWrite(value, super.videoUrl, () {
      super.videoUrl = value;
    });
  }

  late final _$selectedIndexAtom = Atom(name: 'HomeFragmentBase.selectedIndex', context: context);

  @override
  int get selectedIndex {
    _$selectedIndexAtom.reportRead();
    return super.selectedIndex;
  }

  bool _selectedIndexIsInitialized = false;

  @override
  set selectedIndex(int value) {
    _$selectedIndexAtom.reportWrite(value, _selectedIndexIsInitialized ? super.selectedIndex : null, () {
      super.selectedIndex = value;
      _selectedIndexIsInitialized = true;
    });
  }

  late final _$likeScaleAtom = Atom(name: 'HomeFragmentBase.likeScale', context: context);

  @override
  double get likeScale {
    _$likeScaleAtom.reportRead();
    return super.likeScale;
  }

  @override
  set likeScale(double value) {
    _$likeScaleAtom.reportWrite(value, super.likeScale, () {
      super.likeScale = value;
    });
  }

  late final _$isPostLikedAtom = Atom(name: 'HomeFragmentBase.isPostLiked', context: context);

  @override
  bool get isPostLiked {
    _$isPostLikedAtom.reportRead();
    return super.isPostLiked;
  }

  @override
  set isPostLiked(bool value) {
    _$isPostLikedAtom.reportWrite(value, super.isPostLiked, () {
      super.isPostLiked = value;
    });
  }

  late final _$pageControllerAtom = Atom(name: 'HomeFragmentBase.pageController', context: context);

  @override
  PageController get pageController {
    _$pageControllerAtom.reportRead();
    return super.pageController;
  }

  bool _pageControllerIsInitialized = false;

  @override
  set pageController(PageController value) {
    _$pageControllerAtom.reportWrite(value, _pageControllerIsInitialized ? super.pageController : null, () {
      super.pageController = value;
      _pageControllerIsInitialized = true;
    });
  }

  late final _$commentReactionListAtom = Atom(name: 'HomeFragmentBase.commentReactionList', context: context);

  @override
  ObservableList<Reactions> get commentReactionList {
    _$commentReactionListAtom.reportRead();
    return super.commentReactionList;
  }

  @override
  set commentReactionList(ObservableList<Reactions> value) {
    _$commentReactionListAtom.reportWrite(value, super.commentReactionList, () {
      super.commentReactionList = value;
    });
  }

  late final _$commentReactionCountAtom = Atom(name: 'HomeFragmentBase.commentReactionCount', context: context);

  @override
  int get commentReactionCount {
    _$commentReactionCountAtom.reportRead();
    return super.commentReactionCount;
  }

  @override
  set commentReactionCount(int value) {
    _$commentReactionCountAtom.reportWrite(value, super.commentReactionCount, () {
      super.commentReactionCount = value;
    });
  }

  late final _$isEditingAtom = Atom(name: 'HomeFragmentBase.isEditing', context: context);

  @override
  bool get isEditing {
    _$isEditingAtom.reportRead();
    return super.isEditing;
  }

  @override
  set isEditing(bool value) {
    _$isEditingAtom.reportWrite(value, super.isEditing, () {
      super.isEditing = value;
    });
  }

  late final _$isReactedOnCommentAtom = Atom(name: 'HomeFragmentBase.isReactedOnComment', context: context);

  @override
  bool? get isReactedOnComment {
    _$isReactedOnCommentAtom.reportRead();
    return super.isReactedOnComment;
  }

  @override
  set isReactedOnComment(bool? value) {
    _$isReactedOnCommentAtom.reportWrite(value, super.isReactedOnComment, () {
      super.isReactedOnComment = value;
    });
  }

  late final _$dragValueAtom = Atom(name: 'HomeFragmentBase.dragValue', context: context);

  @override
  double? get dragValue {
    _$dragValueAtom.reportRead();
    return super.dragValue;
  }

  @override
  set dragValue(double? value) {
    _$dragValueAtom.reportWrite(value, super.dragValue, () {
      super.dragValue = value;
    });
  }

  late final _$membersListAtom = Atom(name: 'HomeFragmentBase.membersList', context: context);

  @override
  ObservableList<FriendRequestModel> get membersList {
    _$membersListAtom.reportRead();
    return super.membersList;
  }

  @override
  set membersList(ObservableList<FriendRequestModel> value) {
    _$membersListAtom.reportWrite(value, super.membersList, () {
      super.membersList = value;
    });
  }

  late final _$isSuggestedAtom = Atom(name: 'HomeFragmentBase.isSuggested', context: context);

  @override
  bool get isSuggested {
    _$isSuggestedAtom.reportRead();
    return super.isSuggested;
  }

  @override
  set isSuggested(bool value) {
    _$isSuggestedAtom.reportWrite(value, super.isSuggested, () {
      super.isSuggested = value;
    });
  }

  late final _$groupListAtom = Atom(name: 'HomeFragmentBase.groupList', context: context);

  @override
  ObservableList<GroupResponse> get groupList {
    _$groupListAtom.reportRead();
    return super.groupList;
  }

  @override
  set groupList(ObservableList<GroupResponse> value) {
    _$groupListAtom.reportWrite(value, super.groupList, () {
      super.groupList = value;
    });
  }

  late final _$suggestedGroupsAtom = Atom(name: 'HomeFragmentBase.suggestedGroups', context: context);

  @override
  ObservableList<SuggestedGroup> get suggestedGroups {
    _$suggestedGroupsAtom.reportRead();
    return super.suggestedGroups;
  }

  @override
  set suggestedGroups(ObservableList<SuggestedGroup> value) {
    _$suggestedGroupsAtom.reportWrite(value, super.suggestedGroups, () {
      super.suggestedGroups = value;
    });
  }

  late final _$storyMediaListAtom = Atom(name: 'HomeFragmentBase.storyMediaList', context: context);

  @override
  ObservableList<MediaSourceModel> get storyMediaList {
    _$storyMediaListAtom.reportRead();
    return super.storyMediaList;
  }

  @override
  set storyMediaList(ObservableList<MediaSourceModel> value) {
    _$storyMediaListAtom.reportWrite(value, super.storyMediaList, () {
      super.storyMediaList = value;
    });
  }

  late final _$storyContentListAtom = Atom(name: 'HomeFragmentBase.storyContentList', context: context);

  @override
  ObservableList<CreateStoryModel> get storyContentList {
    _$storyContentListAtom.reportRead();
    return super.storyContentList;
  }

  @override
  set storyContentList(ObservableList<CreateStoryModel> value) {
    _$storyContentListAtom.reportWrite(value, super.storyContentList, () {
      super.storyContentList = value;
    });
  }

  late final _$linkTextAtom = Atom(name: 'HomeFragmentBase.linkText', context: context);

  @override
  String get linkText {
    _$linkTextAtom.reportRead();
    return super.linkText;
  }

  @override
  set linkText(String value) {
    _$linkTextAtom.reportWrite(value, super.linkText, () {
      super.linkText = value;
    });
  }

  late final _$selectedMediaIndexAtom = Atom(name: 'HomeFragmentBase.selectedMediaIndex', context: context);

  @override
  int get selectedMediaIndex {
    _$selectedMediaIndexAtom.reportRead();
    return super.selectedMediaIndex;
  }

  @override
  set selectedMediaIndex(int value) {
    _$selectedMediaIndexAtom.reportWrite(value, super.selectedMediaIndex, () {
      super.selectedMediaIndex = value;
    });
  }

  late final _$doResizeAtom = Atom(name: 'HomeFragmentBase.doResize', context: context);

  @override
  bool get doResize {
    _$doResizeAtom.reportRead();
    return super.doResize;
  }

  @override
  set doResize(bool value) {
    _$doResizeAtom.reportWrite(value, super.doResize, () {
      super.doResize = value;
    });
  }

  late final _$statusAtom = Atom(name: 'HomeFragmentBase.status', context: context);

  @override
  String? get status {
    _$statusAtom.reportRead();
    return super.status;
  }

  @override
  set status(String? value) {
    _$statusAtom.reportWrite(value, super.status, () {
      super.status = value;
    });
  }

  late final _$currentAtom = Atom(name: 'HomeFragmentBase.current', context: context);

  @override
  int get current {
    _$currentAtom.reportRead();
    return super.current;
  }

  @override
  set current(int value) {
    _$currentAtom.reportWrite(value, super.current, () {
      super.current = value;
    });
  }

  late final _$homeStoryListAtom = Atom(name: 'HomeFragmentBase.homeStoryList', context: context);

  @override
  ObservableList<StoryResponseModel> get homeStoryList {
    _$homeStoryListAtom.reportRead();
    return super.homeStoryList;
  }

  @override
  set homeStoryList(ObservableList<StoryResponseModel> value) {
    _$homeStoryListAtom.reportWrite(value, super.homeStoryList, () {
      super.homeStoryList = value;
    });
  }

  late final _$currentUserStoryAtom = Atom(name: 'HomeFragmentBase.currentUserStory', context: context);

  @override
  Observable<UserStoryData> get currentUserStory {
    _$currentUserStoryAtom.reportRead();
    return super.currentUserStory;
  }

  @override
  set currentUserStory(Observable<UserStoryData> value) {
    _$currentUserStoryAtom.reportWrite(value, super.currentUserStory, () {
      super.currentUserStory = value;
    });
  }

  late final _$seenAtom = Atom(name: 'HomeFragmentBase.seen', context: context);

  @override
  bool get seen {
    _$seenAtom.reportRead();
    return super.seen;
  }

  @override
  set seen(bool value) {
    _$seenAtom.reportWrite(value, super.seen, () {
      super.seen = value;
    });
  }

  late final _$showBorderAtom = Atom(name: 'HomeFragmentBase.showBorder', context: context);

  @override
  bool get showBorder {
    _$showBorderAtom.reportRead();
    return super.showBorder;
  }

  @override
  set showBorder(bool value) {
    _$showBorderAtom.reportWrite(value, super.showBorder, () {
      super.showBorder = value;
    });
  }

  late final _$storyViewedAtom = Atom(name: 'HomeFragmentBase.storyViewed', context: context);

  @override
  bool get storyViewed {
    _$storyViewedAtom.reportRead();
    return super.storyViewed;
  }

  @override
  set storyViewed(bool value) {
    _$storyViewedAtom.reportWrite(value, super.storyViewed, () {
      super.storyViewed = value;
    });
  }

  late final _$isMediaLoadingAtom = Atom(name: 'HomeFragmentBase.isMediaLoading', context: context);

  @override
  bool get isMediaLoading {
    _$isMediaLoadingAtom.reportRead();
    return super.isMediaLoading;
  }

  @override
  set isMediaLoading(bool value) {
    _$isMediaLoadingAtom.reportWrite(value, super.isMediaLoading, () {
      super.isMediaLoading = value;
    });
  }

  late final _$reactionListAtom = Atom(name: 'HomeFragmentBase.reactionList', context: context);

  @override
  ObservableList<ReactionList> get reactionList {
    _$reactionListAtom.reportRead();
    return super.reactionList;
  }

  @override
  set reactionList(ObservableList<ReactionList> value) {
    _$reactionListAtom.reportWrite(value, super.reactionList, () {
      super.reactionList = value;
    });
  }

  late final _$userStoryReactionListAtom = Atom(name: 'HomeFragmentBase.userStoryReactionList', context: context);

  @override
  ObservableList<UserStoryReactionList> get userStoryReactionList {
    _$userStoryReactionListAtom.reportRead();
    return super.userStoryReactionList;
  }

  @override
  set userStoryReactionList(ObservableList<UserStoryReactionList> value) {
    _$userStoryReactionListAtom.reportWrite(value, super.userStoryReactionList, () {
      super.userStoryReactionList = value;
    });
  }

  late final _$storyReactionsAtom = Atom(name: 'HomeFragmentBase.storyReactions', context: context);

  @override
  Map<int, int> get storyReactions {
    _$storyReactionsAtom.reportRead();
    return super.storyReactions;
  }

  @override
  set storyReactions(Map<int, int> value) {
    _$storyReactionsAtom.reportWrite(value, super.storyReactions, () {
      super.storyReactions = value;
    });
  }

  late final _$isStoryReactedAtom = Atom(name: 'HomeFragmentBase.isStoryReacted', context: context);

  @override
  bool get isStoryReacted {
    _$isStoryReactedAtom.reportRead();
    return super.isStoryReacted;
  }

  @override
  set isStoryReacted(bool value) {
    _$isStoryReactedAtom.reportWrite(value, super.isStoryReacted, () {
      super.isStoryReacted = value;
    });
  }

  late final _$storyMemberListAtom = Atom(name: 'HomeFragmentBase.storyMemberList', context: context);

  @override
  ObservableList<StoryViewsModel> get storyMemberList {
    _$storyMemberListAtom.reportRead();
    return super.storyMemberList;
  }

  @override
  set storyMemberList(ObservableList<StoryViewsModel> value) {
    _$storyMemberListAtom.reportWrite(value, super.storyMemberList, () {
      super.storyMemberList = value;
    });
  }

  late final _$setStoryViewsLoadingAtom = Atom(name: 'HomeFragmentBase.setStoryViewsLoading', context: context);

  @override
  bool get setStoryViewsLoading {
    _$setStoryViewsLoadingAtom.reportRead();
    return super.setStoryViewsLoading;
  }

  @override
  set setStoryViewsLoading(bool value) {
    _$setStoryViewsLoadingAtom.reportWrite(value, super.setStoryViewsLoading, () {
      super.setStoryViewsLoading = value;
    });
  }

  late final _$currentUserIndexAtom = Atom(name: 'HomeFragmentBase.currentUserIndex', context: context);

  @override
  int get currentUserIndex {
    _$currentUserIndexAtom.reportRead();
    return super.currentUserIndex;
  }

  @override
  set currentUserIndex(int value) {
    _$currentUserIndexAtom.reportWrite(value, super.currentUserIndex, () {
      super.currentUserIndex = value;
    });
  }

  late final _$currentStoryIndexAtom = Atom(name: 'HomeFragmentBase.currentStoryIndex', context: context);

  @override
  int get currentStoryIndex {
    _$currentStoryIndexAtom.reportRead();
    return super.currentStoryIndex;
  }

  @override
  set currentStoryIndex(int value) {
    _$currentStoryIndexAtom.reportWrite(value, super.currentStoryIndex, () {
      super.currentStoryIndex = value;
    });
  }

  late final _$isStoryDeletedAtom = Atom(name: 'HomeFragmentBase.isStoryDeleted', context: context);

  @override
  bool get isStoryDeleted {
    _$isStoryDeletedAtom.reportRead();
    return super.isStoryDeleted;
  }

  @override
  set isStoryDeleted(bool value) {
    _$isStoryDeletedAtom.reportWrite(value, super.isStoryDeleted, () {
      super.isStoryDeleted = value;
    });
  }

  late final _$currentPageAtom = Atom(name: 'HomeFragmentBase.currentPage', context: context);

  @override
  int get currentPage {
    _$currentPageAtom.reportRead();
    return super.currentPage;
  }

  @override
  set currentPage(int value) {
    _$currentPageAtom.reportWrite(value, super.currentPage, () {
      super.currentPage = value;
    });
  }

  late final _$isLastPageAtom = Atom(name: 'HomeFragmentBase.isLastPage', context: context);

  @override
  bool get isLastPage {
    _$isLastPageAtom.reportRead();
    return super.isLastPage;
  }

  @override
  set isLastPage(bool value) {
    _$isLastPageAtom.reportWrite(value, super.isLastPage, () {
      super.isLastPage = value;
    });
  }

  late final _$hasErrorAtom = Atom(name: 'HomeFragmentBase.hasError', context: context);

  @override
  bool get hasError {
    _$hasErrorAtom.reportRead();
    return super.hasError;
  }

  @override
  set hasError(bool value) {
    _$hasErrorAtom.reportWrite(value, super.hasError, () {
      super.hasError = value;
    });
  }

  late final _$selectedReportIndexAtom = Atom(name: 'HomeFragmentBase.selectedReportIndex', context: context);

  @override
  int get selectedReportIndex {
    _$selectedReportIndexAtom.reportRead();
    return super.selectedReportIndex;
  }

  @override
  set selectedReportIndex(int value) {
    _$selectedReportIndexAtom.reportWrite(value, super.selectedReportIndex, () {
      super.selectedReportIndex = value;
    });
  }

  late final _$HomeFragmentBaseActionController = ActionController(name: 'HomeFragmentBase', context: context);

  @override
  void setPostContent(String value) {
    final _$actionInfo = _$HomeFragmentBaseActionController.startAction(name: 'HomeFragmentBase.setPostContent');
    try {
      return super.setPostContent(value);
    } finally {
      _$HomeFragmentBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setStoryContent(CreateStoryModel content, int index) {
    final _$actionInfo = _$HomeFragmentBaseActionController.startAction(name: 'HomeFragmentBase.setStoryContent');
    try {
      return super.setStoryContent(content, index);
    } finally {
      _$HomeFragmentBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void ensureStoryContentExists(int index, String defaultDuration) {
    final _$actionInfo = _$HomeFragmentBaseActionController.startAction(name: 'HomeFragmentBase.ensureStoryContentExists');
    try {
      return super.ensureStoryContentExists(index, defaultDuration);
    } finally {
      _$HomeFragmentBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setStoryViewed(bool value) {
    final _$actionInfo = _$HomeFragmentBaseActionController.startAction(name: 'HomeFragmentBase.setStoryViewed');
    try {
      return super.setStoryViewed(value);
    } finally {
      _$HomeFragmentBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setMediaLoading(bool value) {
    final _$actionInfo = _$HomeFragmentBaseActionController.startAction(name: 'HomeFragmentBase.setMediaLoading');
    try {
      return super.setMediaLoading(value);
    } finally {
      _$HomeFragmentBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void onMediaLoaded() {
    final _$actionInfo = _$HomeFragmentBaseActionController.startAction(name: 'HomeFragmentBase.onMediaLoaded');
    try {
      return super.onMediaLoaded();
    } finally {
      _$HomeFragmentBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateStoryReaction(int storyId, int reactionId) {
    final _$actionInfo = _$HomeFragmentBaseActionController.startAction(name: 'HomeFragmentBase.updateStoryReaction');
    try {
      return super.updateStoryReaction(storyId, reactionId);
    } finally {
      _$HomeFragmentBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void removeStoryReaction(int storyId) {
    final _$actionInfo = _$HomeFragmentBaseActionController.startAction(name: 'HomeFragmentBase.removeStoryReaction');
    try {
      return super.removeStoryReaction(storyId);
    } finally {
      _$HomeFragmentBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearStoryMembers() {
    final _$actionInfo = _$HomeFragmentBaseActionController.startAction(name: 'HomeFragmentBase.clearStoryMembers');
    try {
      return super.clearStoryMembers();
    } finally {
      _$HomeFragmentBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addStoryMembers(List<StoryViewsModel> members) {
    final _$actionInfo = _$HomeFragmentBaseActionController.startAction(name: 'HomeFragmentBase.addStoryMembers');
    try {
      return super.addStoryMembers(members);
    } finally {
      _$HomeFragmentBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCurrentUserIndex(int value) {
    final _$actionInfo = _$HomeFragmentBaseActionController.startAction(name: 'HomeFragmentBase.setCurrentUserIndex');
    try {
      return super.setCurrentUserIndex(value);
    } finally {
      _$HomeFragmentBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCurrentStoryIndex(int value) {
    final _$actionInfo = _$HomeFragmentBaseActionController.startAction(name: 'HomeFragmentBase.setCurrentStoryIndex');
    try {
      return super.setCurrentStoryIndex(value);
    } finally {
      _$HomeFragmentBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void resetStoryDeleted() {
    final _$actionInfo = _$HomeFragmentBaseActionController.startAction(name: 'HomeFragmentBase.resetStoryDeleted');
    try {
      return super.resetStoryDeleted();
    } finally {
      _$HomeFragmentBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCurrentPage(int value) {
    final _$actionInfo = _$HomeFragmentBaseActionController.startAction(name: 'HomeFragmentBase.setCurrentPage');
    try {
      return super.setCurrentPage(value);
    } finally {
      _$HomeFragmentBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setLastPage(bool value) {
    final _$actionInfo = _$HomeFragmentBaseActionController.startAction(name: 'HomeFragmentBase.setLastPage');
    try {
      return super.setLastPage(value);
    } finally {
      _$HomeFragmentBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setHasError(bool value) {
    final _$actionInfo = _$HomeFragmentBaseActionController.startAction(name: 'HomeFragmentBase.setHasError');
    try {
      return super.setHasError(value);
    } finally {
      _$HomeFragmentBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isError: ${isError},
postList: ${postList},
mHomePage: ${mHomePage},
postLikeList: ${postLikeList},
postReactionList: ${postReactionList},
isLiked: ${isLiked},
postLikeCount: ${postLikeCount},
index: ${index},
isReacted: ${isReacted},
isPostHidden: ${isPostHidden},
postReactionCount: ${postReactionCount},
notify: ${notify},
mediaList: ${mediaList},
postMedia: ${postMedia},
mediaTypeList: ${mediaTypeList},
postInList: ${postInList},
mentionsMemberList: ${mentionsMemberList},
userNameForMention: ${userNameForMention},
dropdownValue: ${dropdownValue},
enableSelectMedia: ${enableSelectMedia},
gif: ${gif},
selectedMedia: ${selectedMedia},
postContent: ${postContent},
singlePost: ${singlePost},
likeList: ${likeList},
isLike: ${isLike},
likeCount: ${likeCount},
isChange: ${isChange},
commentParentId: ${commentParentId},
commentList: ${commentList},
commentGif: ${commentGif},
memberList: ${memberList},
suggestedMemberList: ${suggestedMemberList},
reactionsList: ${reactionsList},
reactionsCount: ${reactionsCount},
selectedReaction: ${selectedReaction},
likePostList: ${likePostList},
commentReplyParentId: ${commentReplyParentId},
commentReplyList: ${commentReplyList},
commentReplyGif: ${commentReplyGif},
videoPlayerController: ${videoPlayerController},
customVideoPlayerController: ${customVideoPlayerController},
visibilityKey: ${visibilityKey},
videoUrl: ${videoUrl},
selectedIndex: ${selectedIndex},
likeScale: ${likeScale},
isPostLiked: ${isPostLiked},
pageController: ${pageController},
commentReactionList: ${commentReactionList},
commentReactionCount: ${commentReactionCount},
isEditing: ${isEditing},
isReactedOnComment: ${isReactedOnComment},
dragValue: ${dragValue},
membersList: ${membersList},
isSuggested: ${isSuggested},
groupList: ${groupList},
suggestedGroups: ${suggestedGroups},
storyMediaList: ${storyMediaList},
storyContentList: ${storyContentList},
linkText: ${linkText},
selectedMediaIndex: ${selectedMediaIndex},
doResize: ${doResize},
status: ${status},
current: ${current},
homeStoryList: ${homeStoryList},
currentUserStory: ${currentUserStory},
seen: ${seen},
showBorder: ${showBorder},
storyViewed: ${storyViewed},
isMediaLoading: ${isMediaLoading},
reactionList: ${reactionList},
userStoryReactionList: ${userStoryReactionList},
storyReactions: ${storyReactions},
isStoryReacted: ${isStoryReacted},
storyMemberList: ${storyMemberList},
setStoryViewsLoading: ${setStoryViewsLoading},
currentUserIndex: ${currentUserIndex},
currentStoryIndex: ${currentStoryIndex},
isStoryDeleted: ${isStoryDeleted},
currentPage: ${currentPage},
isLastPage: ${isLastPage},
hasError: ${hasError},
selectedReportIndex: ${selectedReportIndex},
hasStories: ${hasStories},
hasUnseenStories: ${hasUnseenStories},
allStoriesSeen: ${allStoriesSeen}
    ''';
  }
}
