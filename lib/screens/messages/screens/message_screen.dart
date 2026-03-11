import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/common_models.dart';
import 'package:socialv/screens/messages/components/recent_message_component.dart';
import 'package:socialv/screens/messages/components/restore_component.dart';
import 'package:socialv/screens/messages/components/search_message_component.dart';
import 'package:socialv/screens/messages/functions.dart' hide threadOpened;
import 'package:socialv/screens/messages/screens/new_chat_screen.dart';
import 'package:socialv/screens/messages/screens/user_settings_screen.dart';
import 'package:socialv/utils/app_constants.dart';
import 'package:socialv/utils/cached_network_image.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../network/messages_repository.dart';

WebSocketChannel? channel;

class MessageScreen extends StatefulWidget {
  const MessageScreen({Key? key}) : super(key: key);

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  List<DrawerModel> tabs = messageTabs();
  TextEditingController searchController = TextEditingController();
  int mPage = 1;

  @override
  void initState() {
    super.initState();
    checkSettings(-1);
    searchController.addListener(() {
      if (searchController.text.isNotEmpty) {
        showClearTextIcon();
      } else {
        messageStore.hasShowClearTextIcon = false;
        messageStore.searchResponse = null;
      }
    });

    final message = '40["$WEB_SOCKET_DOMAIN",${userStore.loginUserId},"${messageStore.bmSecretKey}"]';

    channel = IOWebSocketChannel.connect(WEB_SOCKET_URL);

    channel?.ready.then((value) {
      messageStore.clearTyping();
      messageStore.setWebSocketReady(true);

      log('*=*=*=*=*=*=*=*=*=*=*=*= READY =*=*=*=*=*=*=*=*=*=*=*=*');
      log('Message: $message');

      channel?.sink.add(message);
    }).catchError((e) {
      log('Error: ${e.toString()}');
    });

    channel?.stream.listen((message) {
      handleResponse(message);
    }, onError: (error) {
      print('WebSocket error: $error');
    }, onDone: () {
      messageStore.clearOnlineUser();
      messageStore.setWebSocketReady(false);
      print('WebSocket connection closed');
    });

    channel?.closeReason;
  }

  void handleResponse(String message) {
    if (message == '2') {
      log('--------- Handle Response ---------');
      messageStore.clearTyping();

      channel?.sink.add('3');

      if (threadOpened != null) {
        String message = '42["${SocketEvents.threadOpen}",$threadOpened]';
        channel?.sink.add(message);
      }
    } else {
      handleSocketEvents(context, message);
    }
  }

  void showClearTextIcon() {
    if (!messageStore.hasShowClearTextIcon) {
      messageStore.hasShowClearTextIcon = true;
    }
  }

  Future<void> checkSettings(int refreshIndex, {bool forceSync = false}) async {
    if (refreshIndex == 0 || refreshIndex == -1)
      checkApiCallIsWithinTimeSpan(
        forceConfigSync: forceSync,
        callback: () {
          getChatReactionList().then((value) {
            setValue(SharePreferencesKey.lastTimeCheckEmojisReactions, DateTime.timestamp().millisecondsSinceEpoch);
          });
        },
        sharePreferencesKey: SharePreferencesKey.lastTimeCheckEmojisReactions,
      );

    if (refreshIndex == 1 || refreshIndex == -1)
      checkApiCallIsWithinTimeSpan(
        forceConfigSync: forceSync,
        callback: () {
          messageSettings().then((value) {
            if (value.allowUsersBlock == '1') {
              messageStore.setAllowBlock(true);
            } else {
              messageStore.setAllowBlock(false);
            }
            setValue(SharePreferencesKey.lastTimeCheckMessagesSettings, DateTime.timestamp().millisecondsSinceEpoch);
          }).catchError((e) {
            log('Error: ${e.toString()}');
          });
        },
        sharePreferencesKey: SharePreferencesKey.lastTimeCheckMessagesSettings,
      );
    if (refreshIndex == 2 || refreshIndex == -1)
      checkApiCallIsWithinTimeSpan(
        forceConfigSync: forceSync,
        callback: () {
          userSettings().then((value) {
            if (value.isNotEmpty) {
              value.forEach((element) {
                if (element.id == MessageUserSettings.chatBackground) {
                  messageStore.setGlobalChatBackground(element.url.validate());
                }
              });
            }
            setValue(SharePreferencesKey.lastTimeCheckChatUserSettings, DateTime.timestamp().millisecondsSinceEpoch);
          }).catchError((e) {
            log('Error: ${e.toString()}');
          });
        },
        sharePreferencesKey: SharePreferencesKey.lastTimeCheckChatUserSettings,
      );
  }

  Future<void> search() async {
    if (searchController.text.isNotEmpty) {
      appStore.setLoading(true);
      await searchMessage(searchText: searchController.text.validate()).then((value) {
        messageStore.searchResponse = value;
        messageStore.isErrorInSearch = false;
        appStore.setLoading(false);
      }).catchError((e) {
        messageStore.isErrorInSearch = true;
        appStore.setLoading(false);
        toast(e.toString());
      });
    }
  }

  @override
  void dispose() {
    LiveStream().dispose(RefreshRecentMessage);
    messageStore.setRefreshRecentMessages(false);
    channel?.sink.close();
    messageStore.hasShowClearTextIcon = false;
    messageStore.selectedMessageTab = 0;
    messageStore.isSearchPerformed = false;
    messageStore.searchResponse = null;
    messageStore.deletedThreadId = null;
    messageStore.showRestore = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(language.messages, style: boldTextStyle(size: 20)),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.iconColor),
          onPressed: () {
            finish(context);
          },
        ),
        actions: [
          InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              NewChatScreen().launch(context);
            },
            child: cachedImage(ic_new_chat, color: context.iconColor, width: 26, height: 26, fit: BoxFit.contain),
          ),
          8.width,
          IconButton(
            onPressed: () {
              UserSettingsScreen().launch(context);
            },
            icon: cachedImage(ic_setting, color: context.iconColor, width: 24, height: 24, fit: BoxFit.cover),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () {
          return checkSettings(-1, forceSync: true);
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            SingleChildScrollView(
              child: Observer(builder: (context) {
                return Column(
                  children: [
                    Observer(builder: (context) {
                      return AppTextField(
                        controller: searchController,
                        textFieldType: TextFieldType.USERNAME,
                        onFieldSubmitted: (text) {
                          if (searchController.text.trim().isNotEmpty) {
                            search();
                          } else {}
                        },
                        onChanged: (p0) {
                          appStore.setLoading(true);
                          messageStore.isSearchPerformed = true;
                          if (searchController.text.trim().isNotEmpty) {
                            search();
                          } else {}
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: context.cardColor,
                          border: InputBorder.none,
                          hintText: language.searchConversations,
                          hintStyle: secondaryTextStyle(),
                          prefixIcon: Image.asset(
                            ic_search,
                            height: 16,
                            width: 16,
                            fit: BoxFit.cover,
                            color: appStore.isDarkMode ? bodyDark : bodyWhite,
                          ).paddingAll(16),
                          suffixIcon: messageStore.hasShowClearTextIcon
                              ? IconButton(
                                  icon: Icon(Icons.cancel, color: appStore.isDarkMode ? bodyDark : bodyWhite, size: 18),
                                  onPressed: () {
                                    hideKeyboard(context);
                                    messageStore.hasShowClearTextIcon = false;
                                    searchController.clear();
                                    messageStore.searchResponse = null;
                                    messageStore.isSearchPerformed = false;
                                  },
                                )
                              : null,
                        ),
                      ).cornerRadiusWithClipRRect(commonRadius).paddingAll(16);
                    }),
                    HorizontalList(
                      itemCount: tabs.length,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (context, index) {
                        DrawerModel item = tabs[index];
                        return Observer(builder: (context) {
                          return Container(
                            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            decoration: BoxDecoration(
                              color: messageStore.selectedMessageTab == index ? context.primaryColor : context.cardColor,
                              borderRadius: BorderRadius.all(radiusCircular()),
                            ),
                            child: TextIcon(
                              text: item.title.validate(),
                              textStyle: boldTextStyle(size: 14, color: messageStore.selectedMessageTab == index ? Colors.white : context.primaryColor),
                              onTap: () {
                                if (messageStore.selectedMessageTab != index) {
                                  search();
                                }
                                messageStore.setMessageTab(index);
                              },
                              prefix: cachedImage(item.image, height: 16, width: 16, fit: BoxFit.cover, color: messageStore.selectedMessageTab == index ? Colors.white : context.primaryColor),
                            ),
                          ).visible(!messageStore.isSearchPerformed);
                        });
                      },
                    ),
                    if (messageStore.isSearchPerformed && !messageStore.isErrorInSearch)
                      Observer(builder: (context) {
                        return messageStore.searchResponse == null
                            ? appStore.isLoading
                                ? Offstage()
                                : SizedBox(
                                    height: context.height() * 0.65,
                                    child: NoDataWidget(
                                      imageWidget: NoDataLottieWidget(),
                                      title: language.noDataFound,
                                      onRetry: () {
                                        search();
                                      },
                                      retryText: '   ${language.clickToRefresh}   ',
                                    ),
                                  )
                            : SearchMessageComponent(
                                onDeleteConvo: (int value) {
                                  messageStore.deletedThreadId = value;
                                  messageStore.showRestore = true;
                                },
                                searchResponse: messageStore.searchResponse!,
                                refreshThread: () {
                                  search();
                                },
                              );
                      })
                    else if (messageStore.isErrorInSearch)
                      SizedBox(
                        height: context.height() * 0.65,
                        child: NoDataWidget(
                          imageWidget: NoDataLottieWidget(),
                          title: language.somethingWentWrong,
                          onRetry: () {
                            messageStore.hasShowClearTextIcon = false;
                            searchController.clear();
                            messageStore.searchResponse = null;
                            messageStore.isErrorInSearch = false;
                          },
                          retryText: '   ${language.clickToRefresh}   ',
                        ),
                      )
                    else
                      tabs[messageStore.selectedMessageTab].attachedScreen.validate(),
                  ],
                );
              }),
            ),
            Observer(builder: (context) {
              return Positioned(
                top: context.height() / 1.4,
                child: RestoreComponent(
                  message: "${language.chatWith} ${messageStore.deleteUserName} ${language.deleted}.",
                  threadId: messageStore.deletedThreadId.validate(),
                  callback: (bool value) {
                    if (!value) {
                      search();
                    }
                    messageStore.showRestore = false;
                    messageStore.deletedThreadId = null;
                  },
                ),
              ).visible(messageStore.showRestore);
            }),
            //  Observer(builder: (_) => LoadingWidget().visible(appStore.isLoading)),
          ],
        ),
      ),
    );
  }
}
