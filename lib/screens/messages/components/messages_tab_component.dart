import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/messages/message_users.dart';
import 'package:socialv/models/messages/messages_model.dart';
import 'package:socialv/models/messages/threads_model.dart';
import 'package:socialv/network/messages_repository.dart';
import 'package:socialv/screens/messages/components/initial_message_component.dart';
import 'package:socialv/screens/messages/components/recent_message_component.dart';
import 'package:socialv/screens/messages/screens/message_screen.dart';
import 'package:socialv/utils/app_constants.dart';

class MessagesTabComponent extends StatefulWidget {
  const MessagesTabComponent({Key? key}) : super(key: key);

  @override
  State<MessagesTabComponent> createState() => _MessagesTabComponentState();
}

class _MessagesTabComponentState extends State<MessagesTabComponent> {
  @override
  void initState() {
    super.initState();

    recentMessages();
    messageStore.setRefreshRecentMessages(true);
    refreshRecentMessages();

    LiveStream().on(RefreshRecentMessage, (p0) {
      Threads thread = LiveStream().getValue(RefreshRecentMessage) as Threads;

      if (messageStore.threadsList != null) {
        if (messageStore.threadsList!.threads.validate().any((element) => element.threadId == thread.threadId)) {
          addMessage(messageId: thread.lastMessage.validate(), threadId: thread.threadId.validate());
        } else {
          recentMessages();
        }
      } else {
        recentMessages();
      }
    });

    LiveStream().on(RefreshRecentMessages, (p0) {
      recentMessages();
    });

    LiveStream().on(RecentThreadStatus, (p0) {
      Threads thread = LiveStream().getValue(RecentThreadStatus) as Threads;

      int? index;

      if (messageStore.threadsList!.threads.validate().any((element) => element.threadId == thread.threadId)) {
        messageStore.threadsList!.threads!.forEach((element) {
          if (element.threadId == thread.threadId) {
            if (thread.participantsCount != element.participantsCount) {
              recentMessages();
            } else if (thread.subject != element.subject) {
              index = messageStore.threadsList!.threads!.indexOf(element);
            }
          }
        });

        if (index != null) {
          messageStore.threadsList!.threads![index.validate()].subject = thread.subject;
        }
      } else {
        recentMessages();
      }
    });
  }

  Future<void> addMessage({required int messageId, required int threadId}) async {
    await getMessage(messageId: messageId).then((value) async {
      messageStore.threadsList!.messages!.add(value);

      messageStore.threadsList!.threads.validate().forEach((element) {
        if (element.threadId == threadId) {
          element.lastMessage = messageId;
        }
      });
    }).catchError((e) {
      log('Error: ${e.toString()}');
    });
  }

  sendSocketMessage(List<Threads> threads) {
    List<int> list = [];

    Future.forEach(threads, (Threads element) {
      list.add(element.threadId.validate());
    }).then((value) {
      String message = '42["${SocketEvents.subscribeToThreads}",$list]';
      log('Send Message : $message');
      if (messageStore.refreshRecentMessage) channel?.sink.add(message);
    });
  }

  Future<void> recentMessages({bool showLoader = true}) async {
    messageStore.isErrorInMessages = false;
    if (showLoader) {
      messageStore.setLoading(true);
    }
    await getRecentMessages().then((value) {
      sendSocketMessage(value.threads.validate());
      messageStore.users = value.users!;
      messageStore.threadsList = value;
      messageStore.setLoading(false);
    }).catchError((error) {
      messageStore.setLoading(false);
      messageStore.isErrorInMessages = true;
      log('Error: $error');
    });
  }

  Future<void> refreshRecentMessages() async {
    if (!appStore.isWebsocketEnable && messageStore.refreshRecentMessage) {
      Future.delayed(Duration(seconds: 15), () {
        recentMessages(showLoader: false);
        refreshRecentMessages();
      });
    }
  }

  @override
  void dispose() {
    LiveStream().dispose(RefreshRecentMessage);
    LiveStream().dispose(RecentThreadStatus);
    LiveStream().dispose(RefreshRecentMessages);
    messageStore.setRefreshRecentMessages(false);
    messageStore.isErrorInMessages = false;
    messageStore.showRestore = false;
    messageStore.deletedThreadId = null;
    messageStore.participantUsers.clear();
    messageStore.threadsList = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return Stack(
        children: [
          if (messageStore.threadsList != null)
            if (messageStore.threadsList!.threads.validate().isNotEmpty)
              Observer(builder: (context) {
                return AnimatedListView(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  itemCount: messageStore.threadsList!.threads.validate().length,
                  slideConfiguration: SlideConfiguration(delay: 80.milliseconds, verticalOffset: 300),
                  itemBuilder: (context, index) {
                    MessagesUsers user;
                    Threads thread = messageStore.threadsList!.threads.validate()[index];

                    if (thread.participantsCount.validate() >= 2) {
                      user = messageStore.threadsList!.users.validate().firstWhere((element) => element.userId == thread.participants!.first);
                    } else {
                      user = MessagesUsers(name: userStore.loginName);
                    }
                    messageStore.threadsList!.messages.validate().firstWhere(
                          (element) => element.messageId == thread.lastMessage,
                          orElse: () => Messages(),
                        );
                    if (thread.participantsCount.validate() > 2 && thread.type != ThreadType.group) {
                      messageStore.participantUsers.clear();
                      thread.participants.validate().forEach((val) {
                        if (messageStore.threadsList!.users.validate().any((element) => element.userId == val)) {
                          messageStore.participantUsers.add(messageStore.threadsList!.users.validate().firstWhere((element) => element.userId == val));
                        }
                      });
                    }
                    return RecentMessageComponent(
                      user: user,
                      userList: messageStore.users,
                      thread: thread,
                      message: messageStore.threadsList!.messages.validate(),
                      participantUsers: messageStore.participantUsers,
                      refreshThread: (bool showLoading) {
                        recentMessages(showLoader: showLoading);
                      },
                      onDeleteConvo: () async {
                        messageStore.deletedThreadId = thread.threadId.validate();
                        messageStore.deleteUserName = user.name.validate();

                        messageStore.showRestore = true;
                      },
                      doRefresh: () {
                        messageStore.setRefreshRecentMessages(true);
                        refreshRecentMessages();
                      },
                    );
                  },
                  shrinkWrap: true,
                );
              })
            else
              InitialMessageComponent(title: language.noConversationsYet, showButton: true).visible(!messageStore.isLoading),

/*          /// show restore component
          Observer(builder: (context) {
            return Positioned(
              top: context.height() / 1.8,
              child: RestoreComponent(
                message: "${language.chatWith} ${messageStore.deleteUserName} ${language.deleted}.",
                threadId: messageStore.deletedThreadId.validate(),
                callback: (bool value) {
                  if (!value) {
                    recentMessages();
                  }
                  messageStore.showRestore = false;
                  messageStore.deletedThreadId = null;
                },
              ),
            ).visible(messageStore.showRestore);
          }),*/
          Observer(builder: (context) {
            return SizedBox(
              height: context.height() * 0.65,
              child: NoDataWidget(
                imageWidget: NoDataLottieWidget(),
                title: language.somethingWentWrong,
                onRetry: () {
                  recentMessages();
                },
                retryText: '   ${language.clickToRefresh}   ',
              ).center(),
            ).visible(messageStore.isErrorInMessages && !messageStore.isLoading && messageStore.threadsList == null);
          }),
          Observer(builder: (context) {
            return SizedBox(
              height: context.height() * 0.65,
              child: ThreeBounceLoadingWidget(),
            ).visible(messageStore.isLoading);
          }),
        ],
      );
    });
  }
}
