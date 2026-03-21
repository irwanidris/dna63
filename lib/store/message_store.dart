import 'dart:io';
import 'dart:ui';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:mobx/mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/models/invitations/invite_list_model.dart';
import 'package:socialv/models/messages/message_users.dart';
import 'package:socialv/models/messages/messages_model.dart';
import 'package:socialv/models/messages/permissions.dart';
import 'package:socialv/models/messages/search_message_response.dart';
import 'package:socialv/models/messages/threads_list_model.dart';
import 'package:socialv/models/messages/threads_model.dart';
import 'package:socialv/models/messages/unread_threads.dart';
import 'package:socialv/models/messages/user_settings_model.dart';
import 'package:socialv/models/story/common_story_model.dart';
import 'package:socialv/utils/app_constants.dart';
import '../../../utils/sv_reactions/sv_reaction.dart' as sv_reaction;

part 'message_store.g.dart';

class MessageStore = MessageStoreBase with _$MessageStore;

abstract class MessageStoreBase with Store {
  @observable
  String globalChatBackground = '';

  @observable
  int messageCount = 0;

  @observable
  String userNameKey = '';

  @observable
  String userAvatarKey = '';

  @observable
  String bmSecretKey = '';

  @observable
  bool refreshRecentMessage = false;

  @observable
  bool hasShowClearTextIcon = false;

  @observable
  bool isError = false;

  @observable
  bool refreshChat = false;

  @observable
  int threadID = 0;

  @observable
  bool webSocketReady = false;

  @observable
  bool allowBlock = false;

  @observable
  int selectedMessageTab = 0;

  @observable
  bool isSearchPerformed = false;

  @observable
  bool isErrorInSearch = false;

  @observable
  bool isErrorInMessages = false;

  @observable
  ObservableList selectedInviteRequests = ObservableList();

  @observable
  bool isChecked = false;

  @observable
  ObservableList<MessagesUsers> users = ObservableList();

  @observable
  ObservableList<Options> options = ObservableList();

  @observable
  ObservableList<UserObject> blockedUsers = ObservableList();

  @observable
  ObservableList<MessagesUsers> participantUsers = ObservableList();

  //region chat screen vars

  @observable
  ObservableList<Messages> messages = ObservableList();

  @observable
  ObservableList<MessagesUsers> chatUsers = ObservableList();

  @observable
  ObservableList<sv_reaction.Reaction> reactionList = ObservableList();

  @observable
  ObservableList<int> messageIds = ObservableList();

  @observable
  ObservableList<Map<String, dynamic>> userNameForMention = ObservableList();

  @observable
  bool isEditMessage = false;

  @observable
  bool stopRefreshingThreadInChat = false;

  @observable
  bool doRefresh = false;

  @observable
  bool sendingMessage = false;

  @observable
  bool showPaginationLoader = false;

  @observable
  bool isErrorInChat = false;

  @observable
  String errorTextOfChat = '';

  @observable
  Messages? selectedMessage;

  @observable
  Messages? replyMessage;

  @observable
  CanReplyMsg? canReplyMsg;

  @observable
  String? wallpaper;

  @observable
  File? chatWallpaperFile;

  //endregion

  @observable
  SearchMessageResponse? searchResponse;

  @observable
  ThreadsListModel? threadsList;

  @observable
  Threads? thread;

  @observable
  File? wallpaperFile;

  @observable
  String? wallpaperUrl;

  @observable
  bool isLoading = false;

  @observable
  bool isGeneralSetting = false;

  @observable
  sv_reaction.Reaction? selectedReaction;

  /// agoraVideoCallScreenVars

  @observable
  ObservableList<int> videoUsers = ObservableList();

  @observable
  bool muted = false;

  @observable
  late RtcEngine engine;

  @observable
  bool switchRender = true;

  @observable
  bool isUserJoined = false;

  @observable
  bool isVideoCall = false;

  @observable
  Offset offset = Offset(120, 16);

  @observable
  String callStatus = "Ringing";

  @observable
  int seconds = 0;

  @observable
  int missCallSeconds = 0;

  @observable
  bool startTimer = false;

  ///addNewParticipantCompVars

  @observable
  ObservableList<MessagesUsers> selectedSuggestionList = ObservableList();

  @observable
  ObservableList<MessagesUsers> suggestionList = ObservableList();

  ///writeMessageCompVars
  @observable
  bool showReply = false;

  ///restoreComponentVars

  @observable
  bool isRestored = false;

  ///messageMediaScreenVars
  @observable
  ObservableList<MediaSourceModel> mediaList = ObservableList();

  @observable
  int selectedMediaIndex = 0;

  ///participantsScreenVars
  @observable
  bool allowOtherToInvite = false;

  /// pendingInvitesScreenVars
  @observable
  ObservableList<InviteListModel> inviteList = ObservableList();

  @observable
  String dropdownBulkActionsValue = "";

  ///favouriteMessageScreenVrs

  @observable
  ThreadsListModel threadsListModel = ThreadsListModel();

  @observable
  bool isErrorInStaredMessages = false;

  @observable
  String staredMessageErrorText = "";

  @observable
  bool showRestore = false;

  @observable
  int? deletedThreadId;

  ///previewScreenVars

  @observable
  int selectedOption = 0;

  /// endregion

  @action
  void setWebSocketReady(bool val) {
    webSocketReady = val;
  }

  @action
  void setRefreshRecentMessages(bool val) {
    refreshRecentMessage = val;
  }

  @action
  void setRefreshChat(bool val) {
    refreshChat = val;
  }

  @action
  void setAllowBlock(bool val) {
    allowBlock = val;
  }

  @action
  void setMessageTab(int val) {
    selectedMessageTab = val;
  }

  @action
  Future<void> setUserNameKey(String val, {bool isInitializing = false}) async {
    userNameKey = val;
    if (!isInitializing) await setValue(SharePreferencesKey.USERNAME_KEY, '$val');
  }

  @action
  Future<void> setUserAvatarKey(String val, {bool isInitializing = false}) async {
    userAvatarKey = val;
    if (!isInitializing) await setValue(SharePreferencesKey.USER_AVATAR_KEY, '$val');
  }

  @action
  Future<void> setBmSecretKey(String val, {bool isInitializing = false}) async {
    bmSecretKey = val;
    if (!isInitializing) await setValue(SharePreferencesKey.BM_SECRET_KEY, '$val');
  }

  @observable
  List<int> onlineUsers = ObservableList<int>();

  @observable
  int? highlightedMessageId;

  @action
  void setHighlightedMessageId(int? id) {
    highlightedMessageId = id;
  }

  @action
  void addOnlineUsers(int data) => onlineUsers.add(data);

  @action
  void removeOnlineUser(int data) => onlineUsers.remove(data);

  @action
  void clearOnlineUser() => onlineUsers.clear();

  @observable
  var unreadThreads = ObservableList<UnreadThreadModel>();

  @action
  void addUnReads(UnreadThreadModel data) => unreadThreads.add(data);

  @action
  void removeUnReads(UnreadThreadModel data) => unreadThreads.remove(data);

  @action
  void clearUnReads() => unreadThreads.clear();

  @observable
  var typingList = ObservableList<UnreadThreadModel>();

  @action
  void addTyping(UnreadThreadModel data) => typingList.add(data);

  @action
  void removeTyping(UnreadThreadModel data) => typingList.remove(data);

  @action
  void clearTyping() => typingList.clear();

  @action
  void setMessageCount(int value) {
    messageCount = value;
  }

  @action
  Future<void> setGlobalChatBackground(String val) async {
    globalChatBackground = val;
  }

  @action
  Future<void> setLoading(bool val) async {
    isLoading = val;
  }

  /// agoraVideoCallScreenVars actions
  @action
  void setMuted(bool value) {
    muted = value;
    engine.muteLocalAudioStream(muted);
  }

  @action
  void switchCamera() {
    engine.switchCamera();
  }

  @action
  void addVideoUser(int uid) {
    videoUsers.add(uid);
  }

  @action
  void removeVideoUser(int uid) {
    videoUsers.remove(uid);
  }

  @action
  void clearVideoUsers() {
    videoUsers.clear();
  }

  @action
  void setCallStatus(String status) {
    callStatus = status;
  }

  @action
  void setUserJoined(bool value) {
    isUserJoined = value;
  }

  @action
  void setVideoCall(bool value) {
    isVideoCall = value;
  }

  @action
  void toggleSwitchRender() {
    switchRender = !switchRender;
    videoUsers = ObservableList.of(videoUsers.reversed);
  }

  @action
  void updateOffset(Offset newOffset) {
    offset = newOffset;
  }

  @action
  void incrementSeconds() {
    seconds++;
    int sec = seconds % 60;
    int min = (seconds / 60).floor();
    String minute = min.toString().length <= 1 ? "0$min" : "$min";
    String second = sec.toString().length <= 1 ? "0$sec" : "$sec";
    callStatus = "$minute : $second";
  }

  @action
  void incrementMissCallSeconds() {
    missCallSeconds++;
  }

  @action
  void resetCallTimer() {
    seconds = 0;
    startTimer = false;
    callStatus = 'Call End';
  }

  @action
  void initializeCallState({required bool isVideo}) {
    isVideoCall = isVideo;
    isUserJoined = false;
    muted = false;
    startTimer = false;
    seconds = 0;
    missCallSeconds = 0;
    callStatus = "Ringing";
    clearVideoUsers();
  }

  @action
  void endCall() {
    resetCallTimer();
    clearVideoUsers();
    engine.leaveChannel();
    engine.release();
  }

  @action
  Future<void> startCallTimer() async {
    if (startTimer) {
      await Future.delayed(Duration(seconds: 1));
      incrementSeconds();
      if (startTimer) {
        startCallTimer();
      }
    }
  }

  @action
  Future<void> startMissCallTimer() async {
    if (!isUserJoined && missCallSeconds < 30) {
      await Future.delayed(Duration(seconds: 1));
      incrementMissCallSeconds();
      if (!isUserJoined && missCallSeconds < 30) {
        startMissCallTimer();
      }
    }
  }

  /// agoraVideoCallScreenVars Initialize Engine
  @action
  Future<void> initializeEngine(String appId) async {
    engine = createAgoraRtcEngine();
    await engine.initialize(RtcEngineContext(
      appId: appId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));

    if (isVideoCall) {
      await engine.enableVideo();
      await engine.startPreview();
    }
    await engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
  }

  /// agoraVideoCallScreenVars Computed Properties
  @computed
  bool get isCallActive => startTimer;

  @computed
  bool get hasActiveUsers => videoUsers.isNotEmpty;

  @computed
  String get formattedCallDuration {
    int min = (seconds / 60).floor();
    int sec = seconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  @computed
  bool get shouldShowLocalVideo => !isUserJoined || isVideoCall;

  @computed
  bool get canShowRemoteVideo => isUserJoined && isVideoCall;

  @observable
  bool isFavourite = false;

  @observable
  String draftMessage = "";

  @observable
  String deleteUserName = '';

  @observable
  ObservableMap<String, dynamic> messageMetaData = ObservableMap<String, dynamic>();
}
