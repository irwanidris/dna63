import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/messages/fast_message_model.dart';
import 'package:socialv/models/messages/message_users.dart';
import 'package:socialv/models/messages/messages_model.dart';
import 'package:socialv/models/messages/permissions.dart';
import 'package:socialv/models/messages/stream_message.dart';
import 'package:socialv/models/messages/threads_model.dart';
import 'package:socialv/network/messages_repository.dart';
import 'package:socialv/screens/messages/components/chat_screen_components/chat_screen_popup_menu_component.dart';
import 'package:socialv/screens/messages/components/no_message_component.dart';
import 'package:socialv/screens/messages/components/reaction_bottom_sheet.dart';
import 'package:socialv/screens/messages/components/recent_message_component.dart';
import 'package:socialv/screens/profile/screens/member_profile_screen.dart';
import 'package:socialv/utils/app_constants.dart';
import 'package:socialv/utils/cached_network_image.dart';
import 'package:socialv/utils/sv_reactions/sv_reaction.dart';
import '../components/chat_screen_components/chat_screen_message_component.dart';
import '../components/chat_screen_components/chat_screen_title_component.dart';
import '../components/chat_screen_components/write_message_component.dart';
import 'dart:convert';
import 'dart:io';

// ignore: must_be_immutable
class ChatScreen extends StatefulWidget {
  final int threadId;
  final String? name;
  MessagesUsers? user;
  final Threads? thread;
  final VoidCallback? callback;
  final VoidCallback onDeleteThread;
  final bool? isFromNotification;
  final int? initialMessageId;
  final void Function(List<Messages>)? getMessages;

  ChatScreen(
      {required this.threadId, this.user, this.thread, this.callback, required this.onDeleteThread, Key? key, this.isFromNotification = false, this.name, this.initialMessageId, this.getMessages})
      : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool isLastPage = false;
  ScrollController _controller = ScrollController();
  final ScrollController _scrollController = ScrollController();
  int? highlightMessageId;
  bool shouldHighlight = true;

  @override
  void initState() {
    super.initState();
    messageStore.threadID = widget.threadId;
    addReactionList();
    messageStore.isFavourite = false;
    init();
    messageStore.stopRefreshingThreadInChat = false;

    _controller.addListener(() {
      if (_controller.position.pixels == _controller.position.minScrollExtent) {
        if (!isLastPage) loadMore();
      }
    });

    LiveStream().on(ThreadMessageReceived, (p0) {
      int messageId = LiveStream().getValue(ThreadMessageReceived).toString().toInt();
      addMessage(messageId: messageId);
    });

    LiveStream().on(FastMessage, (p0) {
      FastMessageModel message = FastMessageModel.fromJson(jsonDecode(LiveStream().getValue(FastMessage).toString()));
      addMessage(fastMessage: message);
    });

    LiveStream().on(AbortFastMessage, (p0) {
      AbortMessageModel message = AbortMessageModel.fromJson(jsonDecode(LiveStream().getValue(AbortFastMessage).toString()));
      removeMessage(tmpId: message.messageId);
    });

    LiveStream().on(ThreadStatusChanged, (p0) {
      Threads object = LiveStream().getValue(ThreadStatusChanged) as Threads;
      if (object.participantsCount != messageStore.thread!.participantsCount) {
        getThread();
      } else if (object.subject != messageStore.thread!.subject) {
        messageStore.thread!.subject = object.subject;
      } else if (object.meta!.allowInvite != messageStore.thread!.meta!.allowInvite) {
        messageStore.thread!.meta!.allowInvite = object.meta!.allowInvite;
      }
    });

    LiveStream().on(MetaChanged, (p0) {
      StreamMessage object = LiveStream().getValue(MetaChanged) as StreamMessage;
      messageStore.messages.forEach((element) {
        if (element.messageId == object.messageId) {
          element.meta = object.meta;
        }
      });
    });

    LiveStream().on(DeleteMessage, (p0) {
      int? index;
      int object = LiveStream().getValue(DeleteMessage).toString().toInt();
      if (messageStore.messages.isNotEmpty) {
        if (messageStore.messages.any((element) => element.messageId == object)) {
          index = messageStore.messages.indexWhere((element) => element.messageId == object);
        }
      }
      if (index != null) {
        messageStore.messages.removeAt(index.validate());
      }
    });

    if (widget.initialMessageId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToMessage(widget.initialMessageId!);
      });
    }

    if (widget.initialMessageId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        int index = messageStore.messages.indexWhere((m) => m.messageId == widget.initialMessageId);
        if (index != -1) {
          _scrollController.animateTo(
            index * 100.0,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          messageStore.setHighlightedMessageId(widget.initialMessageId);

          Future.delayed(Duration(seconds: 3), () {
            if (mounted) {
              messageStore.setHighlightedMessageId(null);
            }
          });
        }
      });
    }
  }

  void init() async {
    await getThread().then((value) {
      if (widget.thread != null) {
        messageStore.thread = widget.thread!;
      }
    });
    messageStore.setRefreshChat(true);
    refreshThread();
  }

  void _scrollToMessage(int messageId) {
    final messageIndex = messageStore.messages.indexWhere((msg) => msg.messageId == messageId);
    if (messageIndex != -1) {
      final itemHeight = 100.0;
      final offset = messageIndex * itemHeight;
      _scrollController.animateTo(
        offset,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> getThread({bool showLoader = true}) async {
    try {
      if (showLoader) {
        appStore.setLoading(true);
      }
      messageStore.isErrorInChat = false;

      final value = await getSpecificThread(threadId: messageStore.threadID);
      messageStore.messages.clear();
      if (value.messages != null) {
        messageStore.messages.addAll(value.messages.validate().reversed.validate());
        value.messages?.forEach((msg) {});
      }

      if (value.threads != null && value.threads!.isNotEmpty) {
        messageStore.thread = value.threads!.first;
        if (messageStore.thread!.participantsCount.validate() >= 2 && messageStore.thread!.participants != null && messageStore.thread!.participants!.isNotEmpty) {
          if (value.users != null && value.users!.isNotEmpty) {
            MessagesUsers updatedUser = value.users!.firstWhere(
              (element) => element.userId == messageStore.thread!.participants!.first,
              orElse: () => MessagesUsers(name: 'Deleted User'),
            );
            widget.user = MessagesUsers(
              id: updatedUser.id,
              userId: updatedUser.userId,
              name: updatedUser.name,
              avatar: updatedUser.avatar,
              verified: updatedUser.verified,
              lastActive: updatedUser.lastActive,
              isFriend: updatedUser.isFriend,
              canVideo: updatedUser.canVideo,
              canAudio: updatedUser.canAudio,
              blocked: updatedUser.blocked,
              canBlock: updatedUser.canBlock,
            );
          } else {
            widget.user = MessagesUsers(name: 'Deleted User');
          }
        } else {
          widget.user = MessagesUsers(
            userId: userStore.loginUserId.toInt(),
            name: userStore.loginName,
            avatar: userStore.loginAvatarUrl,
          );
        }

        messageStore.chatUsers.clear();
        if (value.users != null) {
          messageStore.chatUsers.addAll(value.users.validate());
        }

        getMentionsMembers();
        addMessageIds();

        if (messageStore.thread!.permissions != null) {
          if (messageStore.thread!.permissions!.canReplyMsg != null && messageStore.thread!.permissions!.canReplyMsg.toString() != '[]') {
            messageStore.canReplyMsg = CanReplyMsg.fromJson(messageStore.thread!.permissions!.canReplyMsg);
          } else {
            messageStore.canReplyMsg = null;
          }
        }

        if (messageStore.thread!.chatBackground != null && messageStore.thread!.chatBackground!.url.validate().isNotEmpty) {
          messageStore.wallpaper = messageStore.thread!.chatBackground!.url.validate();
        } else if (messageStore.globalChatBackground.isNotEmpty) {
          messageStore.wallpaper = messageStore.globalChatBackground;
        } else {
          messageStore.wallpaper = null;
        }
      }

      appStore.setLoading(false);
      if (showLoader) {
        await Future.delayed(Duration(milliseconds: 1000));
        _scrollDown();
      }

      messageStore.setRefreshChat(true);
    } catch (e) {
      messageStore.isErrorInChat = true;
      messageStore.errorTextOfChat = e.toString();
      appStore.setLoading(false);
      log('Error in getThread: ${e.toString()}');
    }
  }

  Future<void> refreshThread() async {
    if (!appStore.isWebsocketEnable && messageStore.refreshChat) {
      Future.delayed(Duration(seconds: 15), () {
        if (!messageStore.stopRefreshingThreadInChat) {
          getThread(showLoader: false);
          refreshThread();
        }
      });
    }
  }

  Future<void> addMessage({int? messageId, FastMessageModel? fastMessage}) async {
    if (fastMessage != null) {
      messageStore.sendingMessage = false;
      final newMessage = Messages(
        tmpId: fastMessage.tempId,
        threadId: fastMessage.threadId,
        dateSent: DateTime.now().toUtc().toIso8601String(),
        // Use current UTC time
        message: fastMessage.message,
        senderId: fastMessage.senderId,
      );
      messageStore.messages.add(newMessage);
      log('Added fast message ${newMessage.tmpId}: createdAt=${newMessage.createdAt}, dateSent=${newMessage.dateSent}');
      _scrollDown();
    } else {
      await getMessage(messageId: messageId.validate()).then((value) async {
        if (messageStore.messages.any((element) => element.messageId == value.messageId)) {
          messageStore.messages[messageStore.messages.indexWhere((element) => element.messageId == value.messageId)] = value;
          messageStore.sendingMessage = false;
        } else if (messageStore.messages.any((element) => element.tmpId == value.tmpId) && value.tmpId.validate().isNotEmpty) {
          messageStore.messages[messageStore.messages.indexWhere((element) => element.tmpId == value.tmpId)] = value;
          messageStore.sendingMessage = false;
          _scrollDown();
        } else {
          messageStore.sendingMessage = false;
          messageStore.messages.add(value);
          log('Added message ${value.messageId}: createdAt=${value.createdAt}, dateSent=${value.dateSent}');
          _scrollDown();
        }
      }).catchError((e) {
        log('Error adding message: ${e.toString()}');
      });
    }
  }

  void removeMessage({String? tmpId}) {
    messageStore.messages.removeWhere((element) => element.tmpId == tmpId);
  }

  void _scrollDown() {
    if (_scrollController.hasClients) {
      try {
        final position = _scrollController.position.maxScrollExtent;
        _scrollController.jumpTo(position);
      } catch (e) {
        log('Error in _scrollDown: ${e.toString()}');
      }
    }
  }

  Future<void> addReactionList() async {
    for (int i = 0; i <= appStore.emojiList.length - 1; i++) {
      messageStore.reactionList.add(Reaction(
          icon: Text(appStore.emojiList[i].skins.validate().first.native.validate(), style: TextStyle(fontSize: 20)), emojiId: appStore.emojiList[i].skins.validate().first.unified.validate()));
    }
  }

  void addMessageIds() {
    messageStore.messages.forEach((element) {
      if (!messageStore.messageIds.contains(element.messageId.validate())) {
        messageStore.messageIds.add(element.messageId.validate());
      }
    });
  }

  Future<void> getMentionsMembers({String? mentionText}) async {
    messageStore.chatUsers.validate().forEach((element) {
      messageStore.userNameForMention.add({"id": element.id, "full_name": element.name, "display": element.name, "photo": element.avatar});
    });
  }

  Future<void> loadMore() async {
    messageStore.showPaginationLoader = true;
    await loadMoreMessages(threadId: messageStore.thread!.threadId.validate(), messageIds: messageStore.messageIds).then((value) {
      List<Messages> temp = value.messages!.sublist(1);
      if (temp.isEmpty) {
        isLastPage = true;
      } else {
        messageStore.messages.insertAll(0, temp.reversed.validate());
        addMessageIds();
      }
      messageStore.showPaginationLoader = false;
    }).catchError((e) {
      messageStore.showPaginationLoader = false;
    });
  }

  // Extracted method to reduce repetition
  Widget buildMessageList({required List<Messages> messages}) {
    return SizedBox(
      height: context.height() * 0.9,
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.only(
          top: 16,
          bottom: messageStore.selectedMessage != null || messageStore.isEditMessage ? 120 : 80,
        ),
        itemCount: messages.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          final message = messages[index];
          final bool isLoggedInUser = message.senderId.toString() == userStore.loginUserId;
          int createdAt = int.tryParse(message.createdAt.toString()) ?? 0;
          DateTime dateTime = DateTime.now();
          String date = DateFormat('yyyy-MM-dd').format(dateTime);
          if (createdAt.toString().length <= 10) {
            /// i want convert datetime.now in miliseconds
            date = DateFormat('yyyy-MM-dd').format(DateTime.now());
          } else {
            dateTime = DateTime.fromMicrosecondsSinceEpoch(createdAt * 100);
            date = DateFormat('yyyy-MM-dd').format(dateTime);
          }

          int previousDate = 0;
          if (index != 0) previousDate = int.tryParse(messages[index - 1].createdAt.toString()) ?? 0;
          DateTime previousDateTime = DateTime.fromMicrosecondsSinceEpoch(previousDate * 100);
          final String previousDateString = DateFormat('yyyy-MM-dd').format(previousDateTime);
          final bool isDateVisible = index == 0 || date != previousDateString;

          MessageMeta? meta;
          Messages? repliedMessage;
          MessagesUsers? repliedUser;
          MessagesUsers? sender = messageStore.chatUsers.firstWhere((e) => e.userId == message.senderId);

          String reactionIcon = "";
          String emoji = "";

          if (message.meta.toString() != '[]' && message.meta != null) {
            meta = MessageMeta.fromJson(message.meta);

            final reactions = meta.reactions.validate();
            if (reactions.isNotEmpty) {
              final currentUserId = userStore.loginUserId.toInt();

              int? matchedReactionIndex = reactions.indexWhere((e) => e.users.validate().contains(currentUserId));
              if (matchedReactionIndex == -1 && reactions.isNotEmpty) matchedReactionIndex = 0;

              if (matchedReactionIndex >= 0) {
                final reaction = reactions[matchedReactionIndex];
                final emojiMatch = messageStore.reactionList.validate().firstWhere(
                      (e) => e.emojiId.validate() == reaction.reaction.validate(),
                    );

                final iconIndex = appStore.emojiList.indexWhere((e) => e.skins.validate().first.unified.validate() == emojiMatch.emojiId.validate());

                if (iconIndex != -1) {
                  reactionIcon = appStore.emojiList[iconIndex].skins.validate().first.native.validate();
                  emoji = emojiMatch.emojiId.validate();
                }
              }
            }

            if (meta.replyTo != null) {
              final replyMsg = messages.firstWhere((e) => e.messageId == meta!.replyTo.validate(), orElse: () => Messages());
              repliedMessage = replyMsg;
              repliedUser = messageStore.chatUsers.firstWhere((e) => e.userId == replyMsg.senderId);
            }
          }

          return Column(
            children: [
              if (index == 0 && messageStore.showPaginationLoader) ThreeBounceLoadingWidget(),
              Container(
                decoration: widget.initialMessageId == message.messageId ? BoxDecoration(color: context.primaryColor.withValues(alpha: 0.3)) : null,
                child: ChatScreenMessagesComponent(
                  participantCount: messageStore.thread!.participantsCount.validate(),
                  isDateVisible: isDateVisible,
                  repliedUser: repliedUser,
                  repliedMessage: repliedMessage,
                  user: sender,
                  selectedMessage: messageStore.selectedMessage,
                  date: date,
                  isLoggedInUser: isLoggedInUser,
                  message: message,
                  meta: meta,
                  time: date == DateTime.now() ? "Just now" : convertToAgo(dateTime.toString()),
                  threadType: messageStore.thread!.type,
                  reactionList: messageStore.reactionList,
                  emojiId: emoji,
                  reactionIcon: reactionIcon,
                  callback: (value, String? emoji, int? messageId, bool? isReactionRemoved) async {
                    switch (value) {
                      case ChatScreenMessagesComponentCallbacks.onTap:
                        messageStore.selectedMessage = null;
                        break;
                      case ChatScreenMessagesComponentCallbacks.onLongPress:
                        messageStore.selectedMessage = message;
                        break;
                      case ChatScreenMessagesComponentCallbacks.saveReaction:
                        messageStore.sendingMessage = true;
                        messageStore.selectedMessage = null;
                        await saveReaction(messageId: messageId.validate(), emoji: emoji.validate()).then((value) async {
                          value.messages.validate().forEach((element) {
                            if (element.messageId == message.messageId) {
                              message.meta = element.meta;
                            }
                          });
                          messageStore.sendingMessage = false;
                        }).catchError((e) {
                          toast(e.toString());
                          appStore.setLoading(false);
                        });
                        break;
                      case ChatScreenMessagesComponentCallbacks.openReactionBottomSheet:
                        if (message.meta != '[]')
                          showModalBottomSheet(
                            elevation: 0,
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) {
                              return FractionallySizedBox(
                                heightFactor: 0.6,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 45,
                                      height: 5,
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colors.white),
                                    ),
                                    8.height,
                                    Container(
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                      decoration: BoxDecoration(
                                        color: context.cardColor,
                                        borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                                      ),
                                      child: ReactionBottomSheet(users: messageStore.chatUsers, meta: meta!),
                                    ).expand(),
                                  ],
                                ),
                              );
                            },
                          );
                        break;
                    }
                  },
                ),
              ),
              if (index == messages.length - 1 && messageStore.sendingMessage) ThreeBounceLoadingWidget()
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    LiveStream().dispose(ThreadMessageReceived);
    LiveStream().dispose(ThreadStatusChanged);
    LiveStream().dispose(MetaChanged);
    LiveStream().dispose(FastMessage);
    LiveStream().dispose(AbortFastMessage);
    if (appStore.isLoading) appStore.setLoading(false);
    messageStore.setRefreshChat(false);
    messageStore.messages.clear();
    messageStore.chatUsers.clear();
    messageStore.reactionList.clear();
    messageStore.userNameForMention.clear();
    messageStore.isEditMessage = false;
    messageStore.doRefresh = false;
    messageStore.sendingMessage = false;
    messageStore.showPaginationLoader = false;
    messageStore.isErrorInChat = false;
    messageStore.errorTextOfChat = "";
    messageStore.selectedMessage = null;
    messageStore.replyMessage = null;
    messageStore.canReplyMsg = null;
    messageStore.wallpaper = null;
    messageStore.chatWallpaperFile = null;
    messageStore.stopRefreshingThreadInChat = true;
    messageStore.thread = null;
    threadOpened = null;
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          finish(context, messageStore.doRefresh ? true : null);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: context.scaffoldBackgroundColor,
          leadingWidth: 24,
          actions: [
            Observer(builder: (context) {
              ///add star icon
              return messageStore.isFavourite
                  ? IconButton(
                      onPressed: () {
                        messageStore.isFavourite = false;
                      },
                      icon: Icon(Icons.star))
                  : Offstage();
            }),
            Observer(builder: (context) {
              return messageStore.selectedMessage != null
                  ? Row(
                      children: [
                        if (messageStore.thread!.permissions!.canReply.validate() && messageStore.selectedMessage!.senderId.toString() != userStore.loginUserId)
                          InkWell(
                            onTap: () {
                              messageStore.replyMessage = messageStore.selectedMessage;
                              messageStore.selectedMessage = null;
                            },
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            child: Icon(Icons.reply, size: 20, color: context.iconColor),
                          ).paddingSymmetric(horizontal: 6),
                        if (messageStore.thread!.permissions!.canFavorite.validate())
                          InkWell(
                            onTap: () {
                              if (messageStore.selectedMessage!.favorited == 0) {
                                messageStore.selectedMessage!.favorited = 1;
                                starMessage(threadId: messageStore.threadID, messageId: messageStore.selectedMessage!.messageId.validate(), type: FavouriteType.star);
                              } else {
                                messageStore.selectedMessage!.favorited = 0;
                                starMessage(threadId: messageStore.threadID, messageId: messageStore.selectedMessage!.messageId.validate(), type: FavouriteType.unStar);
                              }
                              messageStore.selectedMessage = null;
                            },
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            child: cachedImage(
                              messageStore.selectedMessage!.favorited == 0 ? ic_star_filled : ic_unstar,
                              color: context.iconColor,
                              height: 20,
                              width: 20,
                              fit: BoxFit.cover,
                            ),
                          ).paddingSymmetric(horizontal: 6),
                        InkWell(
                          onTap: () {
                            toast(language.copiedToClipboard);
                            Clipboard.setData(new ClipboardData(text: messageStore.selectedMessage!.message.validate()));
                            messageStore.selectedMessage = null;
                          },
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          child: Icon(Icons.copy, size: 20, color: context.iconColor),
                        ).paddingSymmetric(horizontal: 6),
                        if (messageStore.thread!.permissions!.canEditOwnMessages.validate() && messageStore.selectedMessage!.senderId.toString() == userStore.loginUserId)
                          InkWell(
                            onTap: () {
                              messageStore.replyMessage = messageStore.selectedMessage;
                              messageContentKey.currentState?.controller?.text = messageStore.selectedMessage!.message.validate();
                              messageStore.isEditMessage = true;
                              messageStore.selectedMessage = null;
                            },
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            child: Icon(Icons.edit, size: 20, color: context.iconColor),
                          ).paddingSymmetric(horizontal: 6),
                        if (messageStore.thread!.permissions!.canDeleteAllMessages.validate() ||
                            (messageStore.thread!.permissions!.canDeleteOwnMessages.validate() && messageStore.selectedMessage!.senderId.toString() == userStore.loginUserId))
                          InkWell(
                            onTap: () {
                              messageStore.messages.removeWhere((element) => element == messageStore.selectedMessage);
                              if (!appStore.isWebsocketEnable) {
                                messageStore.messages.removeWhere((element) => element.messageId == messageStore.selectedMessage!.messageId.validate());
                              }
                              deleteMessage(messageId: messageStore.selectedMessage!.messageId.validate(), threadId: messageStore.threadID.validate()).then((value) {});
                              messageStore.selectedMessage = null;
                            },
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            child: Icon(Icons.delete, size: 20, color: context.iconColor),
                          ).paddingSymmetric(horizontal: 8),
                      ],
                    )
                  : Offstage();
            }),
            Observer(builder: (context) {
              return ChatScreenPopUpMenuComponent(
                thread: messageStore.thread,
                threadId: messageStore.threadID,
                user: widget.user,
                users: messageStore.chatUsers,
                doRefresh: messageStore.doRefresh,
                wallpaper: messageStore.wallpaper,
                callback: (p0) async {
                  switch (p0) {
                    case ChatScreenPopUpMenuComponentCallbacks.MuteOrUnMute:
                      widget.callback?.call();
                      break;
                    case ChatScreenPopUpMenuComponentCallbacks.GetThread:
                      messageStore.doRefresh = true;
                      await getThread();
                      break;
                    case ChatScreenPopUpMenuComponentCallbacks.DeleteThread:
                      widget.onDeleteThread.call();
                      break;
                  }
                },
                sendFile: (file) {
                  messageStore.wallpaperFile = file;
                  if (file == null) {
                    if (messageStore.globalChatBackground.isNotEmpty) {
                      messageStore.wallpaper = messageStore.globalChatBackground;
                    } else {
                      messageStore.wallpaper = null;
                    }
                  }
                },
              ).visible(messageStore.selectedMessage == null /*&& widget.user!.blocked == 0*/);
            }),
          ],
          title: ChatScreenTitleComponent(user: widget.user, isFromNotification: widget.isFromNotification, name: widget.name).onTap(() {
            if (!(messageStore.thread?.type == ThreadType.group)) {
              MemberProfileScreen(memberId: widget.user!.id.toInt()).launch(context);
            }
          }),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: context.iconColor),
            onPressed: () {
              finish(context, messageStore.doRefresh ? true : null);
            },
          ),
        ),
        body: SizedBox(
          height: context.height(),
          child: Observer(builder: (context) {
            return Stack(
              children: [
                Observer(builder: (context) {
                  return messageStore.wallpaperFile != null
                      ? Image.file(File(messageStore.wallpaperFile!.path.validate()), height: context.height(), width: context.width(), fit: BoxFit.cover)
                      : Offstage();
                }),
                Observer(builder: (context) {
                  return cachedImage(messageStore.wallpaper, height: context.height(), width: context.width(), fit: BoxFit.cover)
                      .visible(messageStore.wallpaper != null && messageStore.wallpaper.validate().isNotEmpty);
                }),
                Observer(
                  builder: (context) {
                    final allMessages = messageStore.messages.validate();
                    if (messageStore.isFavourite) {
                      final favoritedMessages = allMessages.where((m) => m.favorited == 1).toList();
                      return favoritedMessages.isNotEmpty
                          ? buildMessageList(messages: favoritedMessages).paddingOnly(bottom: 40)
                          : SizedBox(
                              width: context.width(),
                              child: NoMessageComponent(errorText: language.noStarredMessagesFound).paddingSymmetric(horizontal: 16),
                            );
                    } else {
                      return allMessages.isNotEmpty ? buildMessageList(messages: allMessages).paddingOnly(bottom: 40) : Offstage();
                    }
                  },
                ),
                Observer(builder: (context) {
                  return SizedBox(width: context.width(), child: NoMessageComponent().paddingSymmetric(horizontal: 16))
                      .visible(messageStore.messages.isEmpty && !appStore.isLoading && !messageStore.isErrorInChat);
                }),
                Observer(builder: (context) {
                  return SizedBox(width: context.width(), child: NoMessageComponent(errorText: messageStore.errorTextOfChat).paddingSymmetric(horizontal: 16))
                      .visible(messageStore.isErrorInChat && !appStore.isLoading);
                }),
                if (messageStore.canReplyMsg != null && messageStore.canReplyMsg!.userBlockedMessages != null)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: context.width(),
                      decoration: BoxDecoration(color: context.cardColor, border: Border(top: BorderSide(color: context.dividerColor))),
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Text(
                        messageStore.canReplyMsg!.userBlockedMessages.validate().isNotEmpty ? messageStore.canReplyMsg!.userBlockedMessages.validate() : '',
                        style: secondaryTextStyle(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else if (widget.user != null && widget.user!.blocked != null && widget.user!.blocked != 0)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: context.width(),
                      decoration: BoxDecoration(color: context.cardColor, border: Border(top: BorderSide(color: context.dividerColor))),
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Text(
                        language.youCanTSendMessage,
                        style: secondaryTextStyle(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  Positioned(
                    bottom: context.navigationBarHeight,
                    child: Observer(builder: (context) {
                      return WriteMessageComponent(
                        threadSecretKey: messageStore.thread != null ? messageStore.thread!.secretKey.validate() : "",
                        users: messageStore.userNameForMention,
                        threadId: messageStore.threadID,
                        replyMessage: messageStore.replyMessage,
                        isEditMessage: messageStore.isEditMessage,
                        canUpload: messageStore.thread != null
                            ? messageStore.thread!.permissions!.canUpload.runtimeType == int
                                ? messageStore.thread!.permissions!.canUpload == 1
                                    ? true
                                    : false
                                : messageStore.thread!.permissions!.canUpload
                            : false,
                        callback: (p0) {
                          switch (p0) {
                            case WriteMessageCallbacks.ClearReplyMessage:
                              messageStore.replyMessage = null;
                              break;
                            case WriteMessageCallbacks.GetThread:
                              messageStore.doRefresh = true;
                              getThread();
                              break;
                            case WriteMessageCallbacks.SendingMessage:
                              messageStore.sendingMessage = true;
                              break;
                            case WriteMessageCallbacks.SendingMessageRejected:
                              getThread();
                              messageStore.sendingMessage = false;
                              break;
                          }
                        },
                        onAddMessage: (value) {
                          if (messageStore.messages.any((element) => element.messageId == value.messageId)) {
                            messageStore.messages[messageStore.messages.indexWhere((element) => element.messageId == value.messageId)] = value;
                            messageStore.sendingMessage = false;
                          } else if (messageStore.messages.any((element) => element.tmpId == value.tmpId)) {
                            messageStore.messages[messageStore.messages.indexWhere((element) => element.tmpId == value.tmpId)] = value;
                            messageStore.sendingMessage = false;
                          } else {
                            messageStore.sendingMessage = false;
                            messageStore.messages.add(value);
                            _scrollDown();
                          }
                        },
                      );
                    }),
                  ),
                Observer(builder: (_) => LoadingWidget().visible(appStore.isLoading))
              ],
            );
          }),
        ),
      ),
    );
  }
}
