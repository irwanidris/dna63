import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/messages/unread_threads.dart';

import '../../../../models/messages/message_users.dart';
import '../../../../utils/common.dart';
import '../../../../utils/constants.dart';
import 'chat_screen_profile_image_component.dart';

// ignore: must_be_immutable
class ChatScreenTitleComponent extends StatefulWidget {
  final MessagesUsers? user;
  final bool? isFromNotification;
  final String? name;

  ChatScreenTitleComponent({Key? key, this.user, this.isFromNotification = false, this.name}) : super(key: key);

  @override
  State<ChatScreenTitleComponent> createState() => _ChatScreenTitleComponentState();
}

class _ChatScreenTitleComponentState extends State<ChatScreenTitleComponent> {
  @override
  void initState() {
    super.initState();
  }

  String appbarTitle() {
    if (messageStore.thread!.participantsCount.validate() > 2) {
      if (messageStore.thread!.subject.validate().isNotEmpty)
        return messageStore.thread!.subject.validate();
      else
        return '${messageStore.thread!.participantsCount} ${language.participants}';
    } else if (messageStore.thread!.type == ThreadType.group) {
      if (messageStore.thread!.subject.validate().isNotEmpty)
        return messageStore.thread!.subject.validate();
      else
        return '${messageStore.thread!.participantsCount} ${language.participants}';
    } else {
      if (widget.isFromNotification.validate()) {
        return widget.name.validate();
      } else {
        return widget.user!.name.validate();
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return messageStore.thread != null
          ? Row(
              children: [
                ChatScreenProfileImageComponent(
                  users: messageStore.chatUsers,
                  user: widget.user,
                  thread: messageStore.thread,
                  imageSize: 34,
                  imageSizeWhenParticipant: 24,
                  imageSpacing: 10,
                ),
                16.width,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(appbarTitle(), style: boldTextStyle(), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Observer(builder: (_) {
                      int participantCount = messageStore.thread?.participants?.length ?? 0;
                      if (messageStore.typingList.isNotEmpty) {
                        if (messageStore.typingList.any((element) => element.threadId == messageStore.thread?.threadId)) {
                          if (messageStore.thread!.type == ThreadType.group || participantCount > 2) {
                            List<UnreadThreadModel> typingList = messageStore.typingList.where((element) => element.threadId == messageStore.thread!.threadId).toList();

                            List<String> names = [];

                            typingList.forEach((element) {
                              element.typingIds!.forEach((id) {
                                names.add(messageStore.chatUsers.firstWhere((element) => element.id == id).name.validate().split(" ").first);
                              });
                            });

                            return Text(
                              '${names.toString().replaceAll('[', '').replaceAll(']', '')} ${language.typing}',
                              style: secondaryTextStyle(size: 12),
                            );
                          } else {
                            return Text(
                              ' ${language.typing}',
                              style: secondaryTextStyle(size: 12),
                            );
                          }
                        } else if (messageStore.onlineUsers.isNotEmpty) {
                          int similarElementsCount = messageStore.thread!.participants.validate().where((element) => messageStore.onlineUsers.contains(element)).toList().length;

                          if (similarElementsCount != 0) {
                            if (messageStore.thread!.type == ThreadType.group || participantCount > 2) {
                              return Text(
                                '${participantCount} ${language.participants} ($similarElementsCount ${language.online})',
                                style: secondaryTextStyle(size: 12),
                              );
                            } else {
                              return Text(language.online, style: secondaryTextStyle(size: 12, color: Colors.white));
                            }
                          }

                          return Text(
                            messageStore.thread!.type == ThreadType.group || participantCount > 2

                                ? '${messageStore.thread!.participantsCount.toString()} ${language.participants}'
                                : convertToAgo(widget.user!.lastActive.validate()),
                            style: secondaryTextStyle(size: 12),
                          );
                        } else {
                          return Text(
                            messageStore.thread!.type == ThreadType.group || participantCount > 2

                                ? '${messageStore.thread!.participantsCount.toString()} ${language.participants}'
                                : convertToAgo(widget.user!.lastActive.validate()),
                            style: secondaryTextStyle(size: 12),
                          );
                        }
                      } else if (messageStore.onlineUsers.isNotEmpty) {
                        int similarElementsCount = messageStore.thread!.participants.validate().where((element) => messageStore.onlineUsers.contains(element)).toList().length;

                        if (similarElementsCount != 0) {
                          if (messageStore.thread!.type == ThreadType.group || participantCount > 2) {
                            return Text(
                              '${participantCount} ${language.participants} ($similarElementsCount  ${language.online})',
                              style: secondaryTextStyle(size: 12),
                            );
                          } else {
                            return Text(
                              messageStore.onlineUsers.contains(widget.user!.id.validate().toInt()) ? ' ${language.online}' : convertToAgo(widget.user!.lastActive.validate()),
                              style: secondaryTextStyle(size: 12),
                            );
                          }
                        }

                        return Text(
                          messageStore.thread!.type == ThreadType.group || participantCount > 2
                              ? '${messageStore.thread!.participantsCount.toString()} ${language.participants}'
                              : convertToAgo(widget.user!.lastActive.validate()),
                          style: secondaryTextStyle(size: 12),
                        );
                      } else {
                        return Text(
                          messageStore.thread!.type == ThreadType.group || participantCount > 2
                              ? '${messageStore.thread!.participantsCount.toString()} ${language.participants}'
                              : (widget.user?.lastActive != null)
                                  ? convertToAgo(widget.user!.lastActive.validate())
                                  : "",
                          style: secondaryTextStyle(size: 12),
                        );
                      }
                    }),
                  ],
                ).expand(),
              ],
            )
          : Offstage();
    });
  }
}
