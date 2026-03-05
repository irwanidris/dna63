import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:flutter/material.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:mobx/mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/models/common_models.dart';
import 'package:socialv/models/common_models/post_mdeia_model.dart';
import 'package:socialv/models/dashboard_api_response.dart';
import 'package:socialv/models/groups/group_response.dart';
import 'package:socialv/models/members/friend_request_model.dart';
import 'package:socialv/models/members/member_response.dart';
import 'package:socialv/models/posts/comment_model.dart';
import 'package:socialv/models/posts/get_post_likes_model.dart';
import 'package:socialv/models/posts/media_model.dart';
import 'package:socialv/models/posts/post_in_list_model.dart';
import 'package:socialv/models/posts/post_model.dart';
import 'package:socialv/models/story/common_story_model.dart';
import 'package:socialv/models/story/story_reaction_list_model.dart';
import 'package:socialv/models/story/story_response_model.dart';
import 'package:socialv/models/story/story_views_model.dart';
import 'package:socialv/models/story/user_story_model.dart';
import 'package:socialv/models/story/user_story_reaction_model.dart';
import '../../models/reactions/reactions_count_model.dart';
part 'home_fragment_store.g.dart';

class HomeFragStore = HomeFragmentBase with _$HomeFragStore;

abstract class HomeFragmentBase with Store {
  HomeFragmentBase() {
    initializeStore();
  }

  void initializeStore() {
    // Initialize story-related variables
    storyMediaList = ObservableList<MediaSourceModel>();
    storyContentList = ObservableList<CreateStoryModel>();
    selectedMediaIndex = 0;
    doResize = true;
    linkText = '';
  }

  ///Common Observables

  @observable
  bool isError = false;

  /// Home Fragment Vars
  @observable
  ObservableList<PostModel> postList = ObservableList();

  @observable
  int mHomePage = 1;

  @observable
  ObservableList<GetPostLikesModel> postLikeList = ObservableList();

  @observable
  ObservableList<Reactions> postReactionList = ObservableList();

  @observable
  bool isLiked = false;

  @observable
  int postLikeCount = 0;

  @observable
  int index = 0;

  @observable
  bool? isReacted;

  @observable
  bool isPostHidden = false;

  @observable
  int postReactionCount = 0;

  @observable
  bool notify = false;

  /// add post Screen vars
  @observable
  ObservableList<PostMedia> mediaList = ObservableList();

  @observable
  ObservableList<PostMediaModel> postMedia = ObservableList();

  @observable
  ObservableList<MediaModel> mediaTypeList = ObservableList();

  @observable
  ObservableList<PostInListModel> postInList = ObservableList();

  @observable
  ObservableList<MemberResponse> mentionsMemberList = ObservableList();

  @observable
  ObservableList<Map<String, dynamic>> userNameForMention = ObservableList();

  @observable
  PostInListModel dropdownValue = PostInListModel();

  @observable
  bool enableSelectMedia = true;

  @observable
  GiphyGif? gif;

  @observable
  MediaModel? selectedMedia;

  @observable
  String postContent = '';

  @action
  void setPostContent(String value) {
    postContent = value;
  }

  /// singlePostScreenVars
  @observable
  PostModel? singlePost;

  @observable
  ObservableList<GetPostLikesModel> likeList = ObservableList();

  @observable
  bool isLike = false;

  @observable
  int likeCount = 0;

  @observable
  bool isChange = false;

  ///commentScreenVars
  @observable
  int commentParentId = -1;

  @observable
  ObservableList<CommentModel> commentList = ObservableList();

  @observable
  GiphyGif? commentGif;

  ///memberListComponentVars

  @observable
  ObservableList<MemberResponse> memberList = ObservableList();

  ///memberSuggestionListComponentVars
  @observable
  ObservableList<FriendRequestModel> suggestedMemberList = ObservableList();

  ///reactionScreenVars
  @observable
  ObservableList<Reactions> reactionsList = ObservableList();

  @observable
  ObservableList<Reactions> reactionsCount = ObservableList();

  @observable
  String selectedReaction = "";

  ///postLikesScreenVars

  @observable
  ObservableList<GetPostLikesModel> likePostList = ObservableList();

  ///commentReplyScreenVars
  @observable
  int commentReplyParentId = -1;

  @observable
  ObservableList<CommentModel> commentReplyList = ObservableList();

  @observable
  GiphyGif? commentReplyGif;

  ///videoPostComponentVars

  @observable
  late CachedVideoPlayerController videoPlayerController;

  @observable
  late CustomVideoPlayerController customVideoPlayerController;

  @observable
  GlobalKey visibilityKey = GlobalKey();

  @observable
  String videoUrl = '';

  ///postMediaComponentVars
  @observable
  late int selectedIndex;

  ///likeButtonWidgetVars
  @observable
  double likeScale = 1.0;

  @observable
  bool isPostLiked = false;

  ///commentComponentVars
  @observable
  late PageController pageController;

  @observable
  ObservableList<Reactions> commentReactionList = ObservableList();

  @observable
  int commentReactionCount = 0;

  @observable
  bool isEditing = false;

  @observable
  bool? isReactedOnComment;

  ///seekBarVars
  @observable
  double? dragValue;

  ///memberFriendsScreenVars
  @observable
  ObservableList<FriendRequestModel> membersList = ObservableList();

  ///membersListScreenVars
  @observable
  bool isSuggested = true;

  ///groupListScreenVars

  @observable
  ObservableList<GroupResponse> groupList = ObservableList();

  @observable
  ObservableList<SuggestedGroup> suggestedGroups = ObservableList();

  ///createStoryScreenVars
  @observable
  ObservableList<MediaSourceModel> storyMediaList = ObservableList();

  @observable
  ObservableList<CreateStoryModel> storyContentList = ObservableList();

  @observable
  String linkText = '';

  @observable
  int selectedMediaIndex = 0;

  @observable
  bool doResize = true;

  @observable
  String? status;

  ///setStoryDurationVars
  @observable
  int current = 3;

  @action
  void setStoryContent(CreateStoryModel content, int index) {
    if (index >= storyContentList.length) {
      storyContentList.add(content);
    } else {
      storyContentList[index] = content;
    }
  }

  @action
  void ensureStoryContentExists(int index, String defaultDuration) {
    while (storyContentList.length <= index) {
      storyContentList.add(CreateStoryModel(
        storyText: '',
        storyLink: '',
        storyDuration: defaultDuration,
      ));
    }
  }

  ///homeStoryComponentVars
  @observable
  ObservableList<StoryResponseModel> homeStoryList = ObservableList();

  @observable
  Observable<UserStoryData> currentUserStory = Observable<UserStoryData>(UserStoryData());

  @computed
  bool get hasStories => currentUserStory.value.items != null && currentUserStory.value.items!.isNotEmpty;

  @computed
  bool get hasUnseenStories => hasStories && currentUserStory.value.items!.any((story) => !story.seen.validate());

  @computed
  bool get allStoriesSeen => hasStories && currentUserStory.value.items!.every((story) => story.seen.validate());

  @observable
  bool seen = false;

  @observable
  bool showBorder = false;

//region UserStoryPage
  @observable
  bool storyViewed = false;

  @action
  void setStoryViewed(bool value) {
    storyViewed = value;
  }

  @observable
  bool isMediaLoading = false;

  @action
  void setMediaLoading(bool value) {
    isMediaLoading = value;
  }

  @action
  void onMediaLoaded() {
    isMediaLoading = false;
  }
//endregion

//region Reaction
  @observable
  ObservableList<ReactionList> reactionList = ObservableList();

  @observable
  ObservableList<UserStoryReactionList> userStoryReactionList = ObservableList();

  @observable
  Map<int, int> storyReactions = {};
  @action
  void updateStoryReaction(int storyId, int reactionId) {
    storyReactions = {
      ...storyReactions,
      storyId: reactionId,
    };
  }

  @action
  void removeStoryReaction(int storyId) {
    final updatedReactions = Map<int, int>.from(storyReactions);
    updatedReactions.remove(storyId);
    storyReactions = updatedReactions;
  }

  @observable
  bool isStoryReacted = false;
//endregion

//region storyViewsScreenVars
  ///storyViewsScreenVars

  @observable
  ObservableList<StoryViewsModel> storyMemberList = ObservableList();

  @action
  void clearStoryMembers() {
    storyMemberList.clear();
  }

  @action
  void addStoryMembers(List<StoryViewsModel> members) {
    storyMemberList.addAll(members);
  }

  @observable
  bool setStoryViewsLoading = false;

  @observable
  int currentUserIndex = 0;

  @action
  void setCurrentUserIndex(int value) {
    currentUserIndex = value;
  }

  @observable
  int currentStoryIndex = 0;

  @action
  void setCurrentStoryIndex(int value) {
    currentStoryIndex = value;
  }

  @observable
  bool isStoryDeleted = false;

  @action
  void resetStoryDeleted() {
    isStoryDeleted = false;
  }

  @observable
  int currentPage = 1;

  @action
  void setCurrentPage(int value) {
    currentPage = value;
  }

  @observable
  bool isLastPage = false;

  @action
  void setLastPage(bool value) {
    isLastPage = value;
  }

  @observable
  bool hasError = false;

  @action
  void setHasError(bool value) {
    hasError = value;
  }
//endregion

  ///showReportDialogVars
  @observable
  int selectedReportIndex = 0;
}
