// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$MessageStore on MessageStoreBase, Store {
  Computed<bool>? _$isCallActiveComputed;

  @override
  bool get isCallActive => (_$isCallActiveComputed ??= Computed<bool>(() => super.isCallActive, name: 'MessageStoreBase.isCallActive')).value;
  Computed<bool>? _$hasActiveUsersComputed;

  @override
  bool get hasActiveUsers => (_$hasActiveUsersComputed ??= Computed<bool>(() => super.hasActiveUsers, name: 'MessageStoreBase.hasActiveUsers')).value;
  Computed<String>? _$formattedCallDurationComputed;

  @override
  String get formattedCallDuration => (_$formattedCallDurationComputed ??= Computed<String>(() => super.formattedCallDuration, name: 'MessageStoreBase.formattedCallDuration')).value;
  Computed<bool>? _$shouldShowLocalVideoComputed;

  @override
  bool get shouldShowLocalVideo => (_$shouldShowLocalVideoComputed ??= Computed<bool>(() => super.shouldShowLocalVideo, name: 'MessageStoreBase.shouldShowLocalVideo')).value;
  Computed<bool>? _$canShowRemoteVideoComputed;

  @override
  bool get canShowRemoteVideo => (_$canShowRemoteVideoComputed ??= Computed<bool>(() => super.canShowRemoteVideo, name: 'MessageStoreBase.canShowRemoteVideo')).value;

  late final _$globalChatBackgroundAtom = Atom(name: 'MessageStoreBase.globalChatBackground', context: context);

  @override
  String get globalChatBackground {
    _$globalChatBackgroundAtom.reportRead();
    return super.globalChatBackground;
  }

  @override
  set globalChatBackground(String value) {
    _$globalChatBackgroundAtom.reportWrite(value, super.globalChatBackground, () {
      super.globalChatBackground = value;
    });
  }

  late final _$messageCountAtom = Atom(name: 'MessageStoreBase.messageCount', context: context);

  @override
  int get messageCount {
    _$messageCountAtom.reportRead();
    return super.messageCount;
  }

  @override
  set messageCount(int value) {
    _$messageCountAtom.reportWrite(value, super.messageCount, () {
      super.messageCount = value;
    });
  }

  late final _$userNameKeyAtom = Atom(name: 'MessageStoreBase.userNameKey', context: context);

  @override
  String get userNameKey {
    _$userNameKeyAtom.reportRead();
    return super.userNameKey;
  }

  @override
  set userNameKey(String value) {
    _$userNameKeyAtom.reportWrite(value, super.userNameKey, () {
      super.userNameKey = value;
    });
  }

  late final _$userAvatarKeyAtom = Atom(name: 'MessageStoreBase.userAvatarKey', context: context);

  @override
  String get userAvatarKey {
    _$userAvatarKeyAtom.reportRead();
    return super.userAvatarKey;
  }

  @override
  set userAvatarKey(String value) {
    _$userAvatarKeyAtom.reportWrite(value, super.userAvatarKey, () {
      super.userAvatarKey = value;
    });
  }

  late final _$bmSecretKeyAtom = Atom(name: 'MessageStoreBase.bmSecretKey', context: context);

  @override
  String get bmSecretKey {
    _$bmSecretKeyAtom.reportRead();
    return super.bmSecretKey;
  }

  @override
  set bmSecretKey(String value) {
    _$bmSecretKeyAtom.reportWrite(value, super.bmSecretKey, () {
      super.bmSecretKey = value;
    });
  }

  late final _$refreshRecentMessageAtom = Atom(name: 'MessageStoreBase.refreshRecentMessage', context: context);

  @override
  bool get refreshRecentMessage {
    _$refreshRecentMessageAtom.reportRead();
    return super.refreshRecentMessage;
  }

  @override
  set refreshRecentMessage(bool value) {
    _$refreshRecentMessageAtom.reportWrite(value, super.refreshRecentMessage, () {
      super.refreshRecentMessage = value;
    });
  }

  late final _$hasShowClearTextIconAtom = Atom(name: 'MessageStoreBase.hasShowClearTextIcon', context: context);

  @override
  bool get hasShowClearTextIcon {
    _$hasShowClearTextIconAtom.reportRead();
    return super.hasShowClearTextIcon;
  }

  @override
  set hasShowClearTextIcon(bool value) {
    _$hasShowClearTextIconAtom.reportWrite(value, super.hasShowClearTextIcon, () {
      super.hasShowClearTextIcon = value;
    });
  }

  late final _$isErrorAtom = Atom(name: 'MessageStoreBase.isError', context: context);

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

  late final _$refreshChatAtom = Atom(name: 'MessageStoreBase.refreshChat', context: context);

  @override
  bool get refreshChat {
    _$refreshChatAtom.reportRead();
    return super.refreshChat;
  }

  @override
  set refreshChat(bool value) {
    _$refreshChatAtom.reportWrite(value, super.refreshChat, () {
      super.refreshChat = value;
    });
  }

  late final _$threadIDAtom = Atom(name: 'MessageStoreBase.threadID', context: context);

  @override
  int get threadID {
    _$threadIDAtom.reportRead();
    return super.threadID;
  }

  @override
  set threadID(int value) {
    _$threadIDAtom.reportWrite(value, super.threadID, () {
      super.threadID = value;
    });
  }

  late final _$webSocketReadyAtom = Atom(name: 'MessageStoreBase.webSocketReady', context: context);

  @override
  bool get webSocketReady {
    _$webSocketReadyAtom.reportRead();
    return super.webSocketReady;
  }

  @override
  set webSocketReady(bool value) {
    _$webSocketReadyAtom.reportWrite(value, super.webSocketReady, () {
      super.webSocketReady = value;
    });
  }

  late final _$allowBlockAtom = Atom(name: 'MessageStoreBase.allowBlock', context: context);

  @override
  bool get allowBlock {
    _$allowBlockAtom.reportRead();
    return super.allowBlock;
  }

  @override
  set allowBlock(bool value) {
    _$allowBlockAtom.reportWrite(value, super.allowBlock, () {
      super.allowBlock = value;
    });
  }

  late final _$selectedMessageTabAtom = Atom(name: 'MessageStoreBase.selectedMessageTab', context: context);

  @override
  int get selectedMessageTab {
    _$selectedMessageTabAtom.reportRead();
    return super.selectedMessageTab;
  }

  @override
  set selectedMessageTab(int value) {
    _$selectedMessageTabAtom.reportWrite(value, super.selectedMessageTab, () {
      super.selectedMessageTab = value;
    });
  }

  late final _$isSearchPerformedAtom = Atom(name: 'MessageStoreBase.isSearchPerformed', context: context);

  @override
  bool get isSearchPerformed {
    _$isSearchPerformedAtom.reportRead();
    return super.isSearchPerformed;
  }

  @override
  set isSearchPerformed(bool value) {
    _$isSearchPerformedAtom.reportWrite(value, super.isSearchPerformed, () {
      super.isSearchPerformed = value;
    });
  }

  late final _$isErrorInSearchAtom = Atom(name: 'MessageStoreBase.isErrorInSearch', context: context);

  @override
  bool get isErrorInSearch {
    _$isErrorInSearchAtom.reportRead();
    return super.isErrorInSearch;
  }

  @override
  set isErrorInSearch(bool value) {
    _$isErrorInSearchAtom.reportWrite(value, super.isErrorInSearch, () {
      super.isErrorInSearch = value;
    });
  }

  late final _$isErrorInMessagesAtom = Atom(name: 'MessageStoreBase.isErrorInMessages', context: context);

  @override
  bool get isErrorInMessages {
    _$isErrorInMessagesAtom.reportRead();
    return super.isErrorInMessages;
  }

  @override
  set isErrorInMessages(bool value) {
    _$isErrorInMessagesAtom.reportWrite(value, super.isErrorInMessages, () {
      super.isErrorInMessages = value;
    });
  }

  late final _$selectedInviteRequestsAtom = Atom(name: 'MessageStoreBase.selectedInviteRequests', context: context);

  @override
  ObservableList<dynamic> get selectedInviteRequests {
    _$selectedInviteRequestsAtom.reportRead();
    return super.selectedInviteRequests;
  }

  @override
  set selectedInviteRequests(ObservableList<dynamic> value) {
    _$selectedInviteRequestsAtom.reportWrite(value, super.selectedInviteRequests, () {
      super.selectedInviteRequests = value;
    });
  }

  late final _$isCheckedAtom = Atom(name: 'MessageStoreBase.isChecked', context: context);

  @override
  bool get isChecked {
    _$isCheckedAtom.reportRead();
    return super.isChecked;
  }

  @override
  set isChecked(bool value) {
    _$isCheckedAtom.reportWrite(value, super.isChecked, () {
      super.isChecked = value;
    });
  }

  late final _$usersAtom = Atom(name: 'MessageStoreBase.users', context: context);

  @override
  ObservableList<MessagesUsers> get users {
    _$usersAtom.reportRead();
    return super.users;
  }

  @override
  set users(ObservableList<MessagesUsers> value) {
    _$usersAtom.reportWrite(value, super.users, () {
      super.users = value;
    });
  }

  late final _$optionsAtom = Atom(name: 'MessageStoreBase.options', context: context);

  @override
  ObservableList<Options> get options {
    _$optionsAtom.reportRead();
    return super.options;
  }

  @override
  set options(ObservableList<Options> value) {
    _$optionsAtom.reportWrite(value, super.options, () {
      super.options = value;
    });
  }

  late final _$blockedUsersAtom = Atom(name: 'MessageStoreBase.blockedUsers', context: context);

  @override
  ObservableList<UserObject> get blockedUsers {
    _$blockedUsersAtom.reportRead();
    return super.blockedUsers;
  }

  @override
  set blockedUsers(ObservableList<UserObject> value) {
    _$blockedUsersAtom.reportWrite(value, super.blockedUsers, () {
      super.blockedUsers = value;
    });
  }

  late final _$participantUsersAtom = Atom(name: 'MessageStoreBase.participantUsers', context: context);

  @override
  ObservableList<MessagesUsers> get participantUsers {
    _$participantUsersAtom.reportRead();
    return super.participantUsers;
  }

  @override
  set participantUsers(ObservableList<MessagesUsers> value) {
    _$participantUsersAtom.reportWrite(value, super.participantUsers, () {
      super.participantUsers = value;
    });
  }

  late final _$messagesAtom = Atom(name: 'MessageStoreBase.messages', context: context);

  @override
  ObservableList<Messages> get messages {
    _$messagesAtom.reportRead();
    return super.messages;
  }

  @override
  set messages(ObservableList<Messages> value) {
    _$messagesAtom.reportWrite(value, super.messages, () {
      super.messages = value;
    });
  }

  late final _$chatUsersAtom = Atom(name: 'MessageStoreBase.chatUsers', context: context);

  @override
  ObservableList<MessagesUsers> get chatUsers {
    _$chatUsersAtom.reportRead();
    return super.chatUsers;
  }

  @override
  set chatUsers(ObservableList<MessagesUsers> value) {
    _$chatUsersAtom.reportWrite(value, super.chatUsers, () {
      super.chatUsers = value;
    });
  }

  late final _$reactionListAtom = Atom(name: 'MessageStoreBase.reactionList', context: context);

  @override
  ObservableList<sv_reaction.Reaction> get reactionList {
    _$reactionListAtom.reportRead();
    return super.reactionList;
  }

  @override
  set reactionList(ObservableList<sv_reaction.Reaction> value) {
    _$reactionListAtom.reportWrite(value, super.reactionList, () {
      super.reactionList = value;
    });
  }

  late final _$messageIdsAtom = Atom(name: 'MessageStoreBase.messageIds', context: context);

  @override
  ObservableList<int> get messageIds {
    _$messageIdsAtom.reportRead();
    return super.messageIds;
  }

  @override
  set messageIds(ObservableList<int> value) {
    _$messageIdsAtom.reportWrite(value, super.messageIds, () {
      super.messageIds = value;
    });
  }

  late final _$userNameForMentionAtom = Atom(name: 'MessageStoreBase.userNameForMention', context: context);

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

  late final _$isEditMessageAtom = Atom(name: 'MessageStoreBase.isEditMessage', context: context);

  @override
  bool get isEditMessage {
    _$isEditMessageAtom.reportRead();
    return super.isEditMessage;
  }

  @override
  set isEditMessage(bool value) {
    _$isEditMessageAtom.reportWrite(value, super.isEditMessage, () {
      super.isEditMessage = value;
    });
  }

  late final _$stopRefreshingThreadInChatAtom = Atom(name: 'MessageStoreBase.stopRefreshingThreadInChat', context: context);

  @override
  bool get stopRefreshingThreadInChat {
    _$stopRefreshingThreadInChatAtom.reportRead();
    return super.stopRefreshingThreadInChat;
  }

  @override
  set stopRefreshingThreadInChat(bool value) {
    _$stopRefreshingThreadInChatAtom.reportWrite(value, super.stopRefreshingThreadInChat, () {
      super.stopRefreshingThreadInChat = value;
    });
  }

  late final _$doRefreshAtom = Atom(name: 'MessageStoreBase.doRefresh', context: context);

  @override
  bool get doRefresh {
    _$doRefreshAtom.reportRead();
    return super.doRefresh;
  }

  @override
  set doRefresh(bool value) {
    _$doRefreshAtom.reportWrite(value, super.doRefresh, () {
      super.doRefresh = value;
    });
  }

  late final _$sendingMessageAtom = Atom(name: 'MessageStoreBase.sendingMessage', context: context);

  @override
  bool get sendingMessage {
    _$sendingMessageAtom.reportRead();
    return super.sendingMessage;
  }

  @override
  set sendingMessage(bool value) {
    _$sendingMessageAtom.reportWrite(value, super.sendingMessage, () {
      super.sendingMessage = value;
    });
  }

  late final _$showPaginationLoaderAtom = Atom(name: 'MessageStoreBase.showPaginationLoader', context: context);

  @override
  bool get showPaginationLoader {
    _$showPaginationLoaderAtom.reportRead();
    return super.showPaginationLoader;
  }

  @override
  set showPaginationLoader(bool value) {
    _$showPaginationLoaderAtom.reportWrite(value, super.showPaginationLoader, () {
      super.showPaginationLoader = value;
    });
  }

  late final _$isErrorInChatAtom = Atom(name: 'MessageStoreBase.isErrorInChat', context: context);

  @override
  bool get isErrorInChat {
    _$isErrorInChatAtom.reportRead();
    return super.isErrorInChat;
  }

  @override
  set isErrorInChat(bool value) {
    _$isErrorInChatAtom.reportWrite(value, super.isErrorInChat, () {
      super.isErrorInChat = value;
    });
  }

  late final _$errorTextOfChatAtom = Atom(name: 'MessageStoreBase.errorTextOfChat', context: context);

  @override
  String get errorTextOfChat {
    _$errorTextOfChatAtom.reportRead();
    return super.errorTextOfChat;
  }

  @override
  set errorTextOfChat(String value) {
    _$errorTextOfChatAtom.reportWrite(value, super.errorTextOfChat, () {
      super.errorTextOfChat = value;
    });
  }

  late final _$selectedMessageAtom = Atom(name: 'MessageStoreBase.selectedMessage', context: context);

  @override
  Messages? get selectedMessage {
    _$selectedMessageAtom.reportRead();
    return super.selectedMessage;
  }

  @override
  set selectedMessage(Messages? value) {
    _$selectedMessageAtom.reportWrite(value, super.selectedMessage, () {
      super.selectedMessage = value;
    });
  }

  late final _$replyMessageAtom = Atom(name: 'MessageStoreBase.replyMessage', context: context);

  @override
  Messages? get replyMessage {
    _$replyMessageAtom.reportRead();
    return super.replyMessage;
  }

  @override
  set replyMessage(Messages? value) {
    _$replyMessageAtom.reportWrite(value, super.replyMessage, () {
      super.replyMessage = value;
    });
  }

  late final _$canReplyMsgAtom = Atom(name: 'MessageStoreBase.canReplyMsg', context: context);

  @override
  CanReplyMsg? get canReplyMsg {
    _$canReplyMsgAtom.reportRead();
    return super.canReplyMsg;
  }

  @override
  set canReplyMsg(CanReplyMsg? value) {
    _$canReplyMsgAtom.reportWrite(value, super.canReplyMsg, () {
      super.canReplyMsg = value;
    });
  }

  late final _$wallpaperAtom = Atom(name: 'MessageStoreBase.wallpaper', context: context);

  @override
  String? get wallpaper {
    _$wallpaperAtom.reportRead();
    return super.wallpaper;
  }

  @override
  set wallpaper(String? value) {
    _$wallpaperAtom.reportWrite(value, super.wallpaper, () {
      super.wallpaper = value;
    });
  }

  late final _$chatWallpaperFileAtom = Atom(name: 'MessageStoreBase.chatWallpaperFile', context: context);

  @override
  File? get chatWallpaperFile {
    _$chatWallpaperFileAtom.reportRead();
    return super.chatWallpaperFile;
  }

  @override
  set chatWallpaperFile(File? value) {
    _$chatWallpaperFileAtom.reportWrite(value, super.chatWallpaperFile, () {
      super.chatWallpaperFile = value;
    });
  }

  late final _$searchResponseAtom = Atom(name: 'MessageStoreBase.searchResponse', context: context);

  @override
  SearchMessageResponse? get searchResponse {
    _$searchResponseAtom.reportRead();
    return super.searchResponse;
  }

  @override
  set searchResponse(SearchMessageResponse? value) {
    _$searchResponseAtom.reportWrite(value, super.searchResponse, () {
      super.searchResponse = value;
    });
  }

  late final _$threadsListAtom = Atom(name: 'MessageStoreBase.threadsList', context: context);

  @override
  ThreadsListModel? get threadsList {
    _$threadsListAtom.reportRead();
    return super.threadsList;
  }

  @override
  set threadsList(ThreadsListModel? value) {
    _$threadsListAtom.reportWrite(value, super.threadsList, () {
      super.threadsList = value;
    });
  }

  late final _$threadAtom = Atom(name: 'MessageStoreBase.thread', context: context);

  @override
  Threads? get thread {
    _$threadAtom.reportRead();
    return super.thread;
  }

  @override
  set thread(Threads? value) {
    _$threadAtom.reportWrite(value, super.thread, () {
      super.thread = value;
    });
  }

  late final _$wallpaperFileAtom = Atom(name: 'MessageStoreBase.wallpaperFile', context: context);

  @override
  File? get wallpaperFile {
    _$wallpaperFileAtom.reportRead();
    return super.wallpaperFile;
  }

  @override
  set wallpaperFile(File? value) {
    _$wallpaperFileAtom.reportWrite(value, super.wallpaperFile, () {
      super.wallpaperFile = value;
    });
  }

  late final _$wallpaperUrlAtom = Atom(name: 'MessageStoreBase.wallpaperUrl', context: context);

  @override
  String? get wallpaperUrl {
    _$wallpaperUrlAtom.reportRead();
    return super.wallpaperUrl;
  }

  @override
  set wallpaperUrl(String? value) {
    _$wallpaperUrlAtom.reportWrite(value, super.wallpaperUrl, () {
      super.wallpaperUrl = value;
    });
  }

  late final _$isLoadingAtom = Atom(name: 'MessageStoreBase.isLoading', context: context);

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

  late final _$isGeneralSettingAtom = Atom(name: 'MessageStoreBase.isGeneralSetting', context: context);

  @override
  bool get isGeneralSetting {
    _$isGeneralSettingAtom.reportRead();
    return super.isGeneralSetting;
  }

  @override
  set isGeneralSetting(bool value) {
    _$isGeneralSettingAtom.reportWrite(value, super.isGeneralSetting, () {
      super.isGeneralSetting = value;
    });
  }

  late final _$selectedReactionAtom = Atom(name: 'MessageStoreBase.selectedReaction', context: context);

  @override
  sv_reaction.Reaction? get selectedReaction {
    _$selectedReactionAtom.reportRead();
    return super.selectedReaction;
  }

  @override
  set selectedReaction(sv_reaction.Reaction? value) {
    _$selectedReactionAtom.reportWrite(value, super.selectedReaction, () {
      super.selectedReaction = value;
    });
  }

  late final _$videoUsersAtom = Atom(name: 'MessageStoreBase.videoUsers', context: context);

  @override
  ObservableList<int> get videoUsers {
    _$videoUsersAtom.reportRead();
    return super.videoUsers;
  }

  @override
  set videoUsers(ObservableList<int> value) {
    _$videoUsersAtom.reportWrite(value, super.videoUsers, () {
      super.videoUsers = value;
    });
  }

  late final _$mutedAtom = Atom(name: 'MessageStoreBase.muted', context: context);

  @override
  bool get muted {
    _$mutedAtom.reportRead();
    return super.muted;
  }

  @override
  set muted(bool value) {
    _$mutedAtom.reportWrite(value, super.muted, () {
      super.muted = value;
    });
  }

  late final _$engineAtom = Atom(name: 'MessageStoreBase.engine', context: context);

  @override
  RtcEngine get engine {
    _$engineAtom.reportRead();
    return super.engine;
  }

  bool _engineIsInitialized = false;

  @override
  set engine(RtcEngine value) {
    _$engineAtom.reportWrite(value, _engineIsInitialized ? super.engine : null, () {
      super.engine = value;
      _engineIsInitialized = true;
    });
  }

  late final _$switchRenderAtom = Atom(name: 'MessageStoreBase.switchRender', context: context);

  @override
  bool get switchRender {
    _$switchRenderAtom.reportRead();
    return super.switchRender;
  }

  @override
  set switchRender(bool value) {
    _$switchRenderAtom.reportWrite(value, super.switchRender, () {
      super.switchRender = value;
    });
  }

  late final _$isUserJoinedAtom = Atom(name: 'MessageStoreBase.isUserJoined', context: context);

  @override
  bool get isUserJoined {
    _$isUserJoinedAtom.reportRead();
    return super.isUserJoined;
  }

  @override
  set isUserJoined(bool value) {
    _$isUserJoinedAtom.reportWrite(value, super.isUserJoined, () {
      super.isUserJoined = value;
    });
  }

  late final _$isVideoCallAtom = Atom(name: 'MessageStoreBase.isVideoCall', context: context);

  @override
  bool get isVideoCall {
    _$isVideoCallAtom.reportRead();
    return super.isVideoCall;
  }

  @override
  set isVideoCall(bool value) {
    _$isVideoCallAtom.reportWrite(value, super.isVideoCall, () {
      super.isVideoCall = value;
    });
  }

  late final _$offsetAtom = Atom(name: 'MessageStoreBase.offset', context: context);

  @override
  Offset get offset {
    _$offsetAtom.reportRead();
    return super.offset;
  }

  @override
  set offset(Offset value) {
    _$offsetAtom.reportWrite(value, super.offset, () {
      super.offset = value;
    });
  }

  late final _$callStatusAtom = Atom(name: 'MessageStoreBase.callStatus', context: context);

  @override
  String get callStatus {
    _$callStatusAtom.reportRead();
    return super.callStatus;
  }

  @override
  set callStatus(String value) {
    _$callStatusAtom.reportWrite(value, super.callStatus, () {
      super.callStatus = value;
    });
  }

  late final _$secondsAtom = Atom(name: 'MessageStoreBase.seconds', context: context);

  @override
  int get seconds {
    _$secondsAtom.reportRead();
    return super.seconds;
  }

  @override
  set seconds(int value) {
    _$secondsAtom.reportWrite(value, super.seconds, () {
      super.seconds = value;
    });
  }

  late final _$missCallSecondsAtom = Atom(name: 'MessageStoreBase.missCallSeconds', context: context);

  @override
  int get missCallSeconds {
    _$missCallSecondsAtom.reportRead();
    return super.missCallSeconds;
  }

  @override
  set missCallSeconds(int value) {
    _$missCallSecondsAtom.reportWrite(value, super.missCallSeconds, () {
      super.missCallSeconds = value;
    });
  }

  late final _$startTimerAtom = Atom(name: 'MessageStoreBase.startTimer', context: context);

  @override
  bool get startTimer {
    _$startTimerAtom.reportRead();
    return super.startTimer;
  }

  @override
  set startTimer(bool value) {
    _$startTimerAtom.reportWrite(value, super.startTimer, () {
      super.startTimer = value;
    });
  }

  late final _$selectedSuggestionListAtom = Atom(name: 'MessageStoreBase.selectedSuggestionList', context: context);

  @override
  ObservableList<MessagesUsers> get selectedSuggestionList {
    _$selectedSuggestionListAtom.reportRead();
    return super.selectedSuggestionList;
  }

  @override
  set selectedSuggestionList(ObservableList<MessagesUsers> value) {
    _$selectedSuggestionListAtom.reportWrite(value, super.selectedSuggestionList, () {
      super.selectedSuggestionList = value;
    });
  }

  late final _$suggestionListAtom = Atom(name: 'MessageStoreBase.suggestionList', context: context);

  @override
  ObservableList<MessagesUsers> get suggestionList {
    _$suggestionListAtom.reportRead();
    return super.suggestionList;
  }

  @override
  set suggestionList(ObservableList<MessagesUsers> value) {
    _$suggestionListAtom.reportWrite(value, super.suggestionList, () {
      super.suggestionList = value;
    });
  }

  late final _$showReplyAtom = Atom(name: 'MessageStoreBase.showReply', context: context);

  @override
  bool get showReply {
    _$showReplyAtom.reportRead();
    return super.showReply;
  }

  @override
  set showReply(bool value) {
    _$showReplyAtom.reportWrite(value, super.showReply, () {
      super.showReply = value;
    });
  }

  late final _$isRestoredAtom = Atom(name: 'MessageStoreBase.isRestored', context: context);

  @override
  bool get isRestored {
    _$isRestoredAtom.reportRead();
    return super.isRestored;
  }

  @override
  set isRestored(bool value) {
    _$isRestoredAtom.reportWrite(value, super.isRestored, () {
      super.isRestored = value;
    });
  }

  late final _$mediaListAtom = Atom(name: 'MessageStoreBase.mediaList', context: context);

  @override
  ObservableList<MediaSourceModel> get mediaList {
    _$mediaListAtom.reportRead();
    return super.mediaList;
  }

  @override
  set mediaList(ObservableList<MediaSourceModel> value) {
    _$mediaListAtom.reportWrite(value, super.mediaList, () {
      super.mediaList = value;
    });
  }

  late final _$selectedMediaIndexAtom = Atom(name: 'MessageStoreBase.selectedMediaIndex', context: context);

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

  late final _$allowOtherToInviteAtom = Atom(name: 'MessageStoreBase.allowOtherToInvite', context: context);

  @override
  bool get allowOtherToInvite {
    _$allowOtherToInviteAtom.reportRead();
    return super.allowOtherToInvite;
  }

  @override
  set allowOtherToInvite(bool value) {
    _$allowOtherToInviteAtom.reportWrite(value, super.allowOtherToInvite, () {
      super.allowOtherToInvite = value;
    });
  }

  late final _$inviteListAtom = Atom(name: 'MessageStoreBase.inviteList', context: context);

  @override
  ObservableList<InviteListModel> get inviteList {
    _$inviteListAtom.reportRead();
    return super.inviteList;
  }

  @override
  set inviteList(ObservableList<InviteListModel> value) {
    _$inviteListAtom.reportWrite(value, super.inviteList, () {
      super.inviteList = value;
    });
  }

  late final _$dropdownBulkActionsValueAtom = Atom(name: 'MessageStoreBase.dropdownBulkActionsValue', context: context);

  @override
  String get dropdownBulkActionsValue {
    _$dropdownBulkActionsValueAtom.reportRead();
    return super.dropdownBulkActionsValue;
  }

  @override
  set dropdownBulkActionsValue(String value) {
    _$dropdownBulkActionsValueAtom.reportWrite(value, super.dropdownBulkActionsValue, () {
      super.dropdownBulkActionsValue = value;
    });
  }

  late final _$threadsListModelAtom = Atom(name: 'MessageStoreBase.threadsListModel', context: context);

  @override
  ThreadsListModel get threadsListModel {
    _$threadsListModelAtom.reportRead();
    return super.threadsListModel;
  }

  @override
  set threadsListModel(ThreadsListModel value) {
    _$threadsListModelAtom.reportWrite(value, super.threadsListModel, () {
      super.threadsListModel = value;
    });
  }

  late final _$isErrorInStaredMessagesAtom = Atom(name: 'MessageStoreBase.isErrorInStaredMessages', context: context);

  @override
  bool get isErrorInStaredMessages {
    _$isErrorInStaredMessagesAtom.reportRead();
    return super.isErrorInStaredMessages;
  }

  @override
  set isErrorInStaredMessages(bool value) {
    _$isErrorInStaredMessagesAtom.reportWrite(value, super.isErrorInStaredMessages, () {
      super.isErrorInStaredMessages = value;
    });
  }

  late final _$staredMessageErrorTextAtom = Atom(name: 'MessageStoreBase.staredMessageErrorText', context: context);

  @override
  String get staredMessageErrorText {
    _$staredMessageErrorTextAtom.reportRead();
    return super.staredMessageErrorText;
  }

  @override
  set staredMessageErrorText(String value) {
    _$staredMessageErrorTextAtom.reportWrite(value, super.staredMessageErrorText, () {
      super.staredMessageErrorText = value;
    });
  }

  late final _$showRestoreAtom = Atom(name: 'MessageStoreBase.showRestore', context: context);

  @override
  bool get showRestore {
    _$showRestoreAtom.reportRead();
    return super.showRestore;
  }

  @override
  set showRestore(bool value) {
    _$showRestoreAtom.reportWrite(value, super.showRestore, () {
      super.showRestore = value;
    });
  }

  late final _$deletedThreadIdAtom = Atom(name: 'MessageStoreBase.deletedThreadId', context: context);

  @override
  int? get deletedThreadId {
    _$deletedThreadIdAtom.reportRead();
    return super.deletedThreadId;
  }

  @override
  set deletedThreadId(int? value) {
    _$deletedThreadIdAtom.reportWrite(value, super.deletedThreadId, () {
      super.deletedThreadId = value;
    });
  }

  late final _$selectedOptionAtom = Atom(name: 'MessageStoreBase.selectedOption', context: context);

  @override
  int get selectedOption {
    _$selectedOptionAtom.reportRead();
    return super.selectedOption;
  }

  @override
  set selectedOption(int value) {
    _$selectedOptionAtom.reportWrite(value, super.selectedOption, () {
      super.selectedOption = value;
    });
  }

  late final _$onlineUsersAtom = Atom(name: 'MessageStoreBase.onlineUsers', context: context);

  @override
  List<int> get onlineUsers {
    _$onlineUsersAtom.reportRead();
    return super.onlineUsers;
  }

  @override
  set onlineUsers(List<int> value) {
    _$onlineUsersAtom.reportWrite(value, super.onlineUsers, () {
      super.onlineUsers = value;
    });
  }

  late final _$highlightedMessageIdAtom = Atom(name: 'MessageStoreBase.highlightedMessageId', context: context);

  @override
  int? get highlightedMessageId {
    _$highlightedMessageIdAtom.reportRead();
    return super.highlightedMessageId;
  }

  @override
  set highlightedMessageId(int? value) {
    _$highlightedMessageIdAtom.reportWrite(value, super.highlightedMessageId, () {
      super.highlightedMessageId = value;
    });
  }

  late final _$unreadThreadsAtom = Atom(name: 'MessageStoreBase.unreadThreads', context: context);

  @override
  ObservableList<UnreadThreadModel> get unreadThreads {
    _$unreadThreadsAtom.reportRead();
    return super.unreadThreads;
  }

  @override
  set unreadThreads(ObservableList<UnreadThreadModel> value) {
    _$unreadThreadsAtom.reportWrite(value, super.unreadThreads, () {
      super.unreadThreads = value;
    });
  }

  late final _$typingListAtom = Atom(name: 'MessageStoreBase.typingList', context: context);

  @override
  ObservableList<UnreadThreadModel> get typingList {
    _$typingListAtom.reportRead();
    return super.typingList;
  }

  @override
  set typingList(ObservableList<UnreadThreadModel> value) {
    _$typingListAtom.reportWrite(value, super.typingList, () {
      super.typingList = value;
    });
  }

  late final _$isFavouriteAtom = Atom(name: 'MessageStoreBase.isFavourite', context: context);

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

  late final _$draftMessageAtom = Atom(name: 'MessageStoreBase.draftMessage', context: context);

  @override
  String get draftMessage {
    _$draftMessageAtom.reportRead();
    return super.draftMessage;
  }

  @override
  set draftMessage(String value) {
    _$draftMessageAtom.reportWrite(value, super.draftMessage, () {
      super.draftMessage = value;
    });
  }

  late final _$deleteUserNameAtom = Atom(name: 'MessageStoreBase.deleteUserName', context: context);

  @override
  String get deleteUserName {
    _$deleteUserNameAtom.reportRead();
    return super.deleteUserName;
  }

  @override
  set deleteUserName(String value) {
    _$deleteUserNameAtom.reportWrite(value, super.deleteUserName, () {
      super.deleteUserName = value;
    });
  }

  late final _$messageMetaDataAtom = Atom(name: 'MessageStoreBase.messageMetaData', context: context);

  @override
  ObservableMap<String, dynamic> get messageMetaData {
    _$messageMetaDataAtom.reportRead();
    return super.messageMetaData;
  }

  @override
  set messageMetaData(ObservableMap<String, dynamic> value) {
    _$messageMetaDataAtom.reportWrite(value, super.messageMetaData, () {
      super.messageMetaData = value;
    });
  }

  late final _$setUserNameKeyAsyncAction = AsyncAction('MessageStoreBase.setUserNameKey', context: context);

  @override
  Future<void> setUserNameKey(String val, {bool isInitializing = false}) {
    return _$setUserNameKeyAsyncAction.run(() => super.setUserNameKey(val, isInitializing: isInitializing));
  }

  late final _$setUserAvatarKeyAsyncAction = AsyncAction('MessageStoreBase.setUserAvatarKey', context: context);

  @override
  Future<void> setUserAvatarKey(String val, {bool isInitializing = false}) {
    return _$setUserAvatarKeyAsyncAction.run(() => super.setUserAvatarKey(val, isInitializing: isInitializing));
  }

  late final _$setBmSecretKeyAsyncAction = AsyncAction('MessageStoreBase.setBmSecretKey', context: context);

  @override
  Future<void> setBmSecretKey(String val, {bool isInitializing = false}) {
    return _$setBmSecretKeyAsyncAction.run(() => super.setBmSecretKey(val, isInitializing: isInitializing));
  }

  late final _$setGlobalChatBackgroundAsyncAction = AsyncAction('MessageStoreBase.setGlobalChatBackground', context: context);

  @override
  Future<void> setGlobalChatBackground(String val) {
    return _$setGlobalChatBackgroundAsyncAction.run(() => super.setGlobalChatBackground(val));
  }

  late final _$setLoadingAsyncAction = AsyncAction('MessageStoreBase.setLoading', context: context);

  @override
  Future<void> setLoading(bool val) {
    return _$setLoadingAsyncAction.run(() => super.setLoading(val));
  }

  late final _$startCallTimerAsyncAction = AsyncAction('MessageStoreBase.startCallTimer', context: context);

  @override
  Future<void> startCallTimer() {
    return _$startCallTimerAsyncAction.run(() => super.startCallTimer());
  }

  late final _$startMissCallTimerAsyncAction = AsyncAction('MessageStoreBase.startMissCallTimer', context: context);

  @override
  Future<void> startMissCallTimer() {
    return _$startMissCallTimerAsyncAction.run(() => super.startMissCallTimer());
  }

  late final _$initializeEngineAsyncAction = AsyncAction('MessageStoreBase.initializeEngine', context: context);

  @override
  Future<void> initializeEngine(String appId) {
    return _$initializeEngineAsyncAction.run(() => super.initializeEngine(appId));
  }

  late final _$MessageStoreBaseActionController = ActionController(name: 'MessageStoreBase', context: context);

  @override
  void setWebSocketReady(bool val) {
    final _$actionInfo = _$MessageStoreBaseActionController.startAction(name: 'MessageStoreBase.setWebSocketReady');
    try {
      return super.setWebSocketReady(val);
    } finally {
      _$MessageStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setRefreshRecentMessages(bool val) {
    final _$actionInfo = _$MessageStoreBaseActionController.startAction(name: 'MessageStoreBase.setRefreshRecentMessages');
    try {
      return super.setRefreshRecentMessages(val);
    } finally {
      _$MessageStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setRefreshChat(bool val) {
    final _$actionInfo = _$MessageStoreBaseActionController.startAction(name: 'MessageStoreBase.setRefreshChat');
    try {
      return super.setRefreshChat(val);
    } finally {
      _$MessageStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setAllowBlock(bool val) {
    final _$actionInfo = _$MessageStoreBaseActionController.startAction(name: 'MessageStoreBase.setAllowBlock');
    try {
      return super.setAllowBlock(val);
    } finally {
      _$MessageStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setMessageTab(int val) {
    final _$actionInfo = _$MessageStoreBaseActionController.startAction(name: 'MessageStoreBase.setMessageTab');
    try {
      return super.setMessageTab(val);
    } finally {
      _$MessageStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setHighlightedMessageId(int? id) {
    final _$actionInfo = _$MessageStoreBaseActionController.startAction(name: 'MessageStoreBase.setHighlightedMessageId');
    try {
      return super.setHighlightedMessageId(id);
    } finally {
      _$MessageStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addOnlineUsers(int data) {
    final _$actionInfo = _$MessageStoreBaseActionController.startAction(name: 'MessageStoreBase.addOnlineUsers');
    try {
      return super.addOnlineUsers(data);
    } finally {
      _$MessageStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void removeOnlineUser(int data) {
    final _$actionInfo = _$MessageStoreBaseActionController.startAction(name: 'MessageStoreBase.removeOnlineUser');
    try {
      return super.removeOnlineUser(data);
    } finally {
      _$MessageStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearOnlineUser() {
    final _$actionInfo = _$MessageStoreBaseActionController.startAction(name: 'MessageStoreBase.clearOnlineUser');
    try {
      return super.clearOnlineUser();
    } finally {
      _$MessageStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addUnReads(UnreadThreadModel data) {
    final _$actionInfo = _$MessageStoreBaseActionController.startAction(name: 'MessageStoreBase.addUnReads');
    try {
      return super.addUnReads(data);
    } finally {
      _$MessageStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void removeUnReads(UnreadThreadModel data) {
    final _$actionInfo = _$MessageStoreBaseActionController.startAction(name: 'MessageStoreBase.removeUnReads');
    try {
      return super.removeUnReads(data);
    } finally {
      _$MessageStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearUnReads() {
    final _$actionInfo = _$MessageStoreBaseActionController.startAction(name: 'MessageStoreBase.clearUnReads');
    try {
      return super.clearUnReads();
    } finally {
      _$MessageStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addTyping(UnreadThreadModel data) {
    final _$actionInfo = _$MessageStoreBaseActionController.startAction(name: 'MessageStoreBase.addTyping');
    try {
      return super.addTyping(data);
    } finally {
      _$MessageStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void removeTyping(UnreadThreadModel data) {
    final _$actionInfo = _$MessageStoreBaseActionController.startAction(name: 'MessageStoreBase.removeTyping');
    try {
      return super.removeTyping(data);
    } finally {
      _$MessageStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearTyping() {
    final _$actionInfo = _$MessageStoreBaseActionController.startAction(name: 'MessageStoreBase.clearTyping');
    try {
      return super.clearTyping();
    } finally {
      _$MessageStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setMessageCount(int value) {
    final _$actionInfo = _$MessageStoreBaseActionController.startAction(name: 'MessageStoreBase.setMessageCount');
    try {
      return super.setMessageCount(value);
    } finally {
      _$MessageStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setMuted(bool value) {
    final _$actionInfo = _$MessageStoreBaseActionController.startAction(name: 'MessageStoreBase.setMuted');
    try {
      return super.setMuted(value);
    } finally {
      _$MessageStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void switchCamera() {
    final _$actionInfo = _$MessageStoreBaseActionController.startAction(name: 'MessageStoreBase.switchCamera');
    try {
      return super.switchCamera();
    } finally {
      _$MessageStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addVideoUser(int uid) {
    final _$actionInfo = _$MessageStoreBaseActionController.startAction(name: 'MessageStoreBase.addVideoUser');
    try {
      return super.addVideoUser(uid);
    } finally {
      _$MessageStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void removeVideoUser(int uid) {
    final _$actionInfo = _$MessageStoreBaseActionController.startAction(name: 'MessageStoreBase.removeVideoUser');
    try {
      return super.removeVideoUser(uid);
    } finally {
      _$MessageStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearVideoUsers() {
    final _$actionInfo = _$MessageStoreBaseActionController.startAction(name: 'MessageStoreBase.clearVideoUsers');
    try {
      return super.clearVideoUsers();
    } finally {
      _$MessageStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCallStatus(String status) {
    final _$actionInfo = _$MessageStoreBaseActionController.startAction(name: 'MessageStoreBase.setCallStatus');
    try {
      return super.setCallStatus(status);
    } finally {
      _$MessageStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setUserJoined(bool value) {
    final _$actionInfo = _$MessageStoreBaseActionController.startAction(name: 'MessageStoreBase.setUserJoined');
    try {
      return super.setUserJoined(value);
    } finally {
      _$MessageStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setVideoCall(bool value) {
    final _$actionInfo = _$MessageStoreBaseActionController.startAction(name: 'MessageStoreBase.setVideoCall');
    try {
      return super.setVideoCall(value);
    } finally {
      _$MessageStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void toggleSwitchRender() {
    final _$actionInfo = _$MessageStoreBaseActionController.startAction(name: 'MessageStoreBase.toggleSwitchRender');
    try {
      return super.toggleSwitchRender();
    } finally {
      _$MessageStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateOffset(Offset newOffset) {
    final _$actionInfo = _$MessageStoreBaseActionController.startAction(name: 'MessageStoreBase.updateOffset');
    try {
      return super.updateOffset(newOffset);
    } finally {
      _$MessageStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void incrementSeconds() {
    final _$actionInfo = _$MessageStoreBaseActionController.startAction(name: 'MessageStoreBase.incrementSeconds');
    try {
      return super.incrementSeconds();
    } finally {
      _$MessageStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void incrementMissCallSeconds() {
    final _$actionInfo = _$MessageStoreBaseActionController.startAction(name: 'MessageStoreBase.incrementMissCallSeconds');
    try {
      return super.incrementMissCallSeconds();
    } finally {
      _$MessageStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void resetCallTimer() {
    final _$actionInfo = _$MessageStoreBaseActionController.startAction(name: 'MessageStoreBase.resetCallTimer');
    try {
      return super.resetCallTimer();
    } finally {
      _$MessageStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void initializeCallState({required bool isVideo}) {
    final _$actionInfo = _$MessageStoreBaseActionController.startAction(name: 'MessageStoreBase.initializeCallState');
    try {
      return super.initializeCallState(isVideo: isVideo);
    } finally {
      _$MessageStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void endCall() {
    final _$actionInfo = _$MessageStoreBaseActionController.startAction(name: 'MessageStoreBase.endCall');
    try {
      return super.endCall();
    } finally {
      _$MessageStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
globalChatBackground: ${globalChatBackground},
messageCount: ${messageCount},
userNameKey: ${userNameKey},
userAvatarKey: ${userAvatarKey},
bmSecretKey: ${bmSecretKey},
refreshRecentMessage: ${refreshRecentMessage},
hasShowClearTextIcon: ${hasShowClearTextIcon},
isError: ${isError},
refreshChat: ${refreshChat},
threadID: ${threadID},
webSocketReady: ${webSocketReady},
allowBlock: ${allowBlock},
selectedMessageTab: ${selectedMessageTab},
isSearchPerformed: ${isSearchPerformed},
isErrorInSearch: ${isErrorInSearch},
isErrorInMessages: ${isErrorInMessages},
selectedInviteRequests: ${selectedInviteRequests},
isChecked: ${isChecked},
users: ${users},
options: ${options},
blockedUsers: ${blockedUsers},
participantUsers: ${participantUsers},
messages: ${messages},
chatUsers: ${chatUsers},
reactionList: ${reactionList},
messageIds: ${messageIds},
userNameForMention: ${userNameForMention},
isEditMessage: ${isEditMessage},
stopRefreshingThreadInChat: ${stopRefreshingThreadInChat},
doRefresh: ${doRefresh},
sendingMessage: ${sendingMessage},
showPaginationLoader: ${showPaginationLoader},
isErrorInChat: ${isErrorInChat},
errorTextOfChat: ${errorTextOfChat},
selectedMessage: ${selectedMessage},
replyMessage: ${replyMessage},
canReplyMsg: ${canReplyMsg},
wallpaper: ${wallpaper},
chatWallpaperFile: ${chatWallpaperFile},
searchResponse: ${searchResponse},
threadsList: ${threadsList},
thread: ${thread},
wallpaperFile: ${wallpaperFile},
wallpaperUrl: ${wallpaperUrl},
isLoading: ${isLoading},
isGeneralSetting: ${isGeneralSetting},
selectedReaction: ${selectedReaction},
videoUsers: ${videoUsers},
muted: ${muted},
engine: ${engine},
switchRender: ${switchRender},
isUserJoined: ${isUserJoined},
isVideoCall: ${isVideoCall},
offset: ${offset},
callStatus: ${callStatus},
seconds: ${seconds},
missCallSeconds: ${missCallSeconds},
startTimer: ${startTimer},
selectedSuggestionList: ${selectedSuggestionList},
suggestionList: ${suggestionList},
showReply: ${showReply},
isRestored: ${isRestored},
mediaList: ${mediaList},
selectedMediaIndex: ${selectedMediaIndex},
allowOtherToInvite: ${allowOtherToInvite},
inviteList: ${inviteList},
dropdownBulkActionsValue: ${dropdownBulkActionsValue},
threadsListModel: ${threadsListModel},
isErrorInStaredMessages: ${isErrorInStaredMessages},
staredMessageErrorText: ${staredMessageErrorText},
showRestore: ${showRestore},
deletedThreadId: ${deletedThreadId},
selectedOption: ${selectedOption},
onlineUsers: ${onlineUsers},
highlightedMessageId: ${highlightedMessageId},
unreadThreads: ${unreadThreads},
typingList: ${typingList},
isFavourite: ${isFavourite},
draftMessage: ${draftMessage},
deleteUserName: ${deleteUserName},
messageMetaData: ${messageMetaData},
isCallActive: ${isCallActive},
hasActiveUsers: ${hasActiveUsers},
formattedCallDuration: ${formattedCallDuration},
shouldShowLocalVideo: ${shouldShowLocalVideo},
canShowRemoteVideo: ${canShowRemoteVideo}
    ''';
  }
}
