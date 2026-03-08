import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/messages/message_users.dart';
import 'package:socialv/models/messages/messages_model.dart';
import 'package:socialv/models/messages/threads_model.dart';
import 'package:socialv/network/messages_repository.dart';
import 'package:socialv/screens/messages/screens/chat_screen.dart';
import 'package:socialv/screens/messages/screens/message_screen.dart';
import '../../../utils/app_constants.dart';
import 'chat_screen_components/chat_screen_profile_image_component.dart';

int? threadOpened;

class RecentMessageComponent extends StatefulWidget {
  final Threads thread;
  final MessagesUsers user;
  final List<Messages> message;
  final Function(bool showLoading)? refreshThread;
  final VoidCallback onDeleteConvo;
  final VoidCallback? doRefresh;
  final List<MessagesUsers>? participantUsers;
  final List<MessagesUsers>? userList;

  RecentMessageComponent({
    required this.thread,
    required this.user,
    required this.message,
    this.participantUsers,
    required this.refreshThread,
    required this.onDeleteConvo,
    this.doRefresh,
    this.userList,
  });

  @override
  State<RecentMessageComponent> createState() => _RecentMessageComponentState();
}

class _RecentMessageComponentState extends State<RecentMessageComponent> {
  String messagesTitle() {
    if (widget.thread.participantsCount.validate() > 2) {
      if (widget.thread.subject.validate().isNotEmpty)
        return widget.thread.subject.validate();
      else
        return 'Group Chat';
    } else if (widget.thread.type == ThreadType.group) {
      if (widget.thread.subject.validate().isNotEmpty)
        return widget.thread.subject.validate();
      else
        return 'Group Chat';
    } else if (widget.thread.participantsCount.validate() <= 1) {
      return widget.user.name.validate();
    } else {
      return widget.user.name.validate();
    }
  }

  bool hasUnreadMessages() {
    return messageStore.unreadThreads.any((element) => element.threadId == widget.thread.threadId) || widget.thread.unread != 0;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InkWell(
          onTap: () {
            if (messageStore.unreadThreads.any((element) => element.threadId == widget.thread.threadId.validate())) {
              messageStore.removeUnReads(messageStore.unreadThreads.firstWhere((element) => element.threadId == widget.thread.threadId.validate()));
            }

            String messages = '42["${SocketEvents.threadOpen}",${widget.thread.threadId.validate()}]';
            String messageOnes = '421["${SocketEvents.v3GetStatuses}",[${widget.thread.threadId.validate()}]]';

            log('Send Message = $messages');
            log('Send Message = $messageOnes');
            channel?.sink.add(messages);
            channel?.sink.add(messageOnes);

            threadOpened = widget.thread.threadId.validate();

            messageStore.setRefreshRecentMessages(false);
            ChatScreen(
              getMessages: (val) {
                if (val.isNotEmpty) {
                  messageStore.threadsList!.messages!.addAll(val);
                }
              },
              onDeleteThread: () {
                finish(context);
                widget.onDeleteConvo.call();
              },
              threadId: widget.thread.threadId.validate(),
              user: widget.user,
              thread: widget.thread,
              callback: () {
                widget.refreshThread?.call(true);
              },
            ).launch(context).then((value) {
              if (value ?? false) {
                widget.refreshThread?.call(true);
              }
              widget.doRefresh?.call();
            });
          },
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(8),
            margin: EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(color: context.cardColor, borderRadius: radius(commonRadius)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ChatScreenProfileImageComponent(
                      users: widget.participantUsers.validate(),
                      imageSizeWhenParticipant: 42,
                      imageSize: 48,
                      user: widget.user,
                      thread: widget.thread,
                      imageSpacing: 12,
                    ),
                    16.width,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Observer(builder: (context) {
                          return RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(text: messagesTitle(), style: boldTextStyle(fontFamily: fontFamily)),
                                if (widget.thread.type != ThreadType.group && widget.user.verified.validate() == 1)
                                  WidgetSpan(
                                    child: Image.asset(ic_tick_filled, height: 18, width: 18, color: blueTickColor, fit: BoxFit.cover).paddingLeft(4),
                                  ),
                                if (widget.thread.isPinned.validate() == 1)
                                  WidgetSpan(
                                    child: Image.asset(ic_pin, height: 14, width: 14, color: context.iconColor, fit: BoxFit.cover).paddingOnly(bottom: 4, left: 4, right: 2),
                                  ),
                                if (widget.thread.isMuted.validate())
                                  WidgetSpan(
                                    child: Image.asset(ic_volume_mute, height: 12, width: 12, color: context.iconColor, fit: BoxFit.cover).paddingOnly(bottom: 4, left: 2),
                                  ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          );
                        }),
                        4.height,
                        Observer(builder: (context) {
                          bool isUnread = hasUnreadMessages();

                          ///count total unread messages
                          ///i want to display total count of unread messages
                          int unreadCount = 0;
                          if (messageStore.unreadThreads.any((element) => element.threadId == widget.thread.threadId.validate())) {
                            unreadCount = messageStore.unreadThreads.firstWhere((element) => element.threadId == widget.thread.threadId.validate()).unreadCount.validate();
                          } else if (widget.thread.unread != 0) {
                            unreadCount = widget.thread.unread.validate();
                          }
                          if (unreadCount > 1) {
                            return Text(' $unreadCount ${language.unreadMessages}', style: secondaryTextStyle(size: 12));
                          } else if (messageStore.typingList.any((element) => element.threadId == widget.thread.threadId)) {
                            return Text('${language.typing}', style: secondaryTextStyle(size: 12));
                          } else {
                            log("thread id---------------${widget.thread.threadId}");
                            String draftKey = "draft_${widget.thread.threadId}";
                            String? draft = messageStore.messageMetaData[draftKey];
                            log("draft value---------------${draft}");

                            var test = widget.message.firstWhere((element) => element.threadId == widget.thread.threadId).message.validate();
                            var senderId = widget.message.firstWhere((element) => element.threadId == widget.thread.threadId).senderId.toString();

                            bool isSender = senderId == userStore.loginUserId;

                            var time = widget.message.firstWhere((element) => element.threadId == widget.thread.threadId).createdAt.validate();
                            DateTime date = DateTime.fromMicrosecondsSinceEpoch(time * 100);
                            var test1 = widget.userList?.firstWhere(
                              (u) => u.userId.toString() == senderId.toString(),
                              orElse: () => MessagesUsers(),
                            );

                            String senderName = isSender ? 'You' : (test1?.name.validate() ?? language.deletedUser);

                            return SizedBox(
                              width: context.width() * 0.36,
                              child: draft != null && draft.isNotEmpty
                                  ? RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: "Draft: ",
                                            style: TextStyle(
                                              color: Colors.green, // Draft keyword in green
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(
                                            text: draft, // Draft value
                                            style: secondaryTextStyle(), // Your existing secondary style
                                          ),
                                        ],
                                      ),
                                    )
                                  : Text(
                                      test.validate() == 'Attachment'
                                          ? isSender == false
                                              ? "Sent a photo"
                                              : "Sent ${convertToAgo(date.toString())}"
                                          : (widget.thread.participantsCount! > 2) // Group chat
                                              ? "$senderName: ${parseHtmlString(test.validate())}"
                                              : parseHtmlString(test.validate()),
                                      style: isUnread ? boldTextStyle() : secondaryTextStyle(size: 12),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                            );
                          }
                        }),
                      ],
                    ).expand(),
                  ],
                ).expand(),
                Observer(
                  builder: (context) {
                    final message = messageStore.threadsList!.messages!.firstWhere((element) => element.threadId == widget.thread.threadId);

                    int createdAt = int.tryParse(message.createdAt.toString()) ?? 0;
                    DateTime dateTime = DateTime.fromMicrosecondsSinceEpoch(createdAt * 100);
                    if (dateTime.isToday) {
                      return Text(
                        convertToAgo(dateTime.toString()),
                        style: secondaryTextStyle(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      );
                    } else {
                      return Text(
                        convertToAgo(dateTime.toString()),
                        style: secondaryTextStyle(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      );
                    }
                  },
                )
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: Theme(
            data: Theme.of(context).copyWith(),
            child: PopupMenuButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(commonRadius)),
              onSelected: (val) async {
                if (val == 1) {
                  if (widget.thread.isPinned == 1) {
                    widget.thread.isPinned = 0;
                    await unPinThread(threadId: widget.thread.threadId.validate()).catchError(onError);
                  } else {
                    widget.thread.isPinned = 1;
                    await pinThread(threadId: widget.thread.threadId.validate()).catchError(onError);
                  }
                  widget.refreshThread?.call(false);
                } else if (val == 2) {
                  widget.thread.isMuted = !widget.thread.isMuted.validate();
                  if (!widget.thread.isMuted.validate()) {
                    await unMuteThread(threadId: widget.thread.threadId.validate()).catchError(onError);
                  } else {
                    await muteThread(threadId: widget.thread.threadId.validate()).catchError(onError);
                  }
                } else {
                  showConfirmDialogCustom(
                    context,
                    onAccept: (c) {
                      ifNotTester(() async {
                        await deleteThread(threadId: widget.thread.threadId.validate()).then((value) {
                          widget.onDeleteConvo.call();
                        }).catchError(onError);
                      });
                    },
                    dialogType: DialogType.CONFIRMATION,
                    title: language.deleteChatConfirmation,
                    positiveText: language.delete,
                  );
                }
              },
              icon: Icon(Icons.more_horiz),
              itemBuilder: (context) => <PopupMenuEntry>[
                PopupMenuItem(
                  value: 1,
                  child: TextIcon(
                    text: widget.thread.isPinned == 1 ? language.unpin : language.pin,
                    textStyle: secondaryTextStyle(),
                  ),
                ),
                if (widget.thread.permissions!.canMuteThread.validate())
                  PopupMenuItem(
                    value: 2,
                    child: TextIcon(
                      text: widget.thread.isMuted.validate() ? language.unMuteConversation : language.muteConversation,
                      textStyle: secondaryTextStyle(),
                    ),
                  ),
                if (widget.thread.permissions!.deleteAllowed.validate())
                  PopupMenuItem(
                    value: 3,
                    child: TextIcon(
                      text: language.delete,
                      textStyle: secondaryTextStyle(),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Observer(
          builder: (ctx) {
            if (messageStore.unreadThreads.any((element) => element.threadId == widget.thread.threadId)) {
              int unreadCount = messageStore.unreadThreads.firstWhere((element) => element.threadId == widget.thread.threadId).unreadCount.validate();

              return Positioned(
                top: 14,
                left: 6,
                child: Container(
                  height: 16,
                  width: 16,
                  decoration: BoxDecoration(color: context.primaryColor, shape: BoxShape.circle),
                  child: FittedBox(child: Text(unreadCount.toString(), style: secondaryTextStyle(color: Colors.white))),
                ),
              );
            } else if (widget.thread.unread != 0) {
              return Positioned(
                top: 14,
                left: 6,
                child: Container(
                  height: 16,
                  width: 16,
                  decoration: BoxDecoration(color: context.primaryColor, shape: BoxShape.circle),
                  child: FittedBox(child: Text(widget.thread.unread.toString(), style: secondaryTextStyle(color: Colors.white))),
                ),
              );
            } else {
              return Offstage();
            }
          },
        ),
        Observer(builder: (_) {
          return Positioned(
            bottom: 20,
            left: 45,
            child: Icon(
              Icons.circle,
              color: Colors.green.shade700,
              size: 14,
            ),
          ).visible(widget.user.isOnline.validate() && (widget.thread.participantsCount.validate().toString() == "2"));
        })
      ],
    );
  }
}
