import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/messages/message_users.dart';
import 'package:socialv/models/messages/messages_model.dart';
import 'package:socialv/models/messages/threads_model.dart';
import 'package:socialv/models/messages/threads_list_model.dart';
import 'package:socialv/network/messages_repository.dart';
import 'package:socialv/screens/messages/components/message_media_component.dart';
import 'package:socialv/screens/messages/components/recent_message_component.dart';
import 'package:socialv/screens/messages/components/restore_component.dart';
import 'package:socialv/screens/messages/screens/chat_screen.dart';
import 'package:socialv/screens/messages/screens/message_screen.dart';
import 'package:socialv/store/message_store.dart';
import 'package:socialv/utils/app_constants.dart';
import 'package:socialv/utils/cached_network_image.dart';

class FavouriteMessageScreen extends StatefulWidget {
  const FavouriteMessageScreen({Key? key}) : super(key: key);

  @override
  State<FavouriteMessageScreen> createState() => _FavouriteMessageScreenState();
}

class _FavouriteMessageScreenState extends State<FavouriteMessageScreen> {
  MessageStore favouriteMessageScreenVrs = MessageStore();
  bool doRefresh = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<ThreadsListModel> init() async {
    appStore.setLoading(true);
    await getFavorites().then(
      (value) {
        favouriteMessageScreenVrs.threadsListModel = value;

        favouriteMessageScreenVrs.isErrorInStaredMessages = false;
        appStore.setLoading(false);
      },
    ).catchError((e) {
      toast(e.toString());
      favouriteMessageScreenVrs.isErrorInStaredMessages = true;
      favouriteMessageScreenVrs.staredMessageErrorText = e.toString();
      appStore.setLoading(false);
    });

    return favouriteMessageScreenVrs.threadsListModel;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          finish(context, doRefresh);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(language.starredMessages, style: boldTextStyle(size: 20)),
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: context.iconColor),
            onPressed: () {
              finish(context, doRefresh);
            },
          ),
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedScrollView(children: [
              /// error widget
              Observer(builder: (context) {
                return favouriteMessageScreenVrs.isErrorInStaredMessages && !appStore.isLoading
                    ? SizedBox(
                        height: context.height() * 0.8,
                        child: NoDataWidget(
                          imageWidget: NoDataLottieWidget(),
                          title: language.somethingWentWrong,
                          subTitle: favouriteMessageScreenVrs.staredMessageErrorText,
                          onRetry: () {
                            init();
                          },
                        ).center(),
                      )
                    : Offstage();
              }),

              /// empty widget

              Observer(builder: (context) {
                return (favouriteMessageScreenVrs.threadsListModel.messages == null || favouriteMessageScreenVrs.threadsListModel.messages!.isEmpty) && !favouriteMessageScreenVrs.isErrorInStaredMessages && !appStore.isLoading
                    ? SizedBox(
                        height: context.height() * 0.8,
                        child: NoDataWidget(
                          imageWidget: NoDataLottieWidget(),
                          title: language.noDataFound,
                          onRetry: () {
                            init();
                          },
                        ).center(),
                      )
                    : Offstage();
              }),
              Observer(builder: (context) {
                return favouriteMessageScreenVrs.threadsListModel.messages != null && favouriteMessageScreenVrs.threadsListModel.messages!.isNotEmpty && !favouriteMessageScreenVrs.isErrorInStaredMessages
                    ? ListView.separated(
                        padding: EdgeInsets.all(16),
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: favouriteMessageScreenVrs.threadsListModel.messages.validate().length,
                        itemBuilder: (ctx, index) {
                          Messages message = favouriteMessageScreenVrs.threadsListModel.messages.validate()[index];
                          Threads thread = favouriteMessageScreenVrs.threadsListModel.threads.validate().isNotEmpty
                              ? favouriteMessageScreenVrs.threadsListModel.threads.validate().firstWhere(
                                    (element) => element.threadId == message.threadId,
                                    orElse: () => Threads(),
                                  )
                              : Threads();

                          MessagesUsers user = favouriteMessageScreenVrs.threadsListModel.users.validate().isNotEmpty
                              ? favouriteMessageScreenVrs.threadsListModel.users.validate().firstWhere(
                                    (element) => element.userId == message.senderId,
                                    orElse: () => MessagesUsers(),
                                  )
                              : MessagesUsers();

                          MessageMeta? meta;

                          if (message.meta.toString() != '[]') {
                            meta = MessageMeta.fromJson(message.meta);
                          }

                          return Observer(builder: (context) {
                            return InkWell(
                              onTap: () {
                                String socketMessage = '42["${SocketEvents.threadOpen}",${thread.threadId.validate()}]';
                                String socketMessageOne = '421["${SocketEvents.v3GetStatuses}",[${thread.threadId.validate()}]]';

                                log('Send Message = $socketMessage');
                                log('Send Message = $socketMessageOne');
                                channel?.sink.add(socketMessage);
                                channel?.sink.add(socketMessageOne);

                                threadOpened = thread.threadId.validate();

                                ChatScreen(
                                  onDeleteThread: () {
                                    finish(context);
                                    messageStore.deletedThreadId = thread.threadId.validate();
                                    messageStore.showRestore = true;
                                  },
                                  threadId: thread.threadId.validate(),
                                  thread: thread,
                                  user: user,
                                  initialMessageId: message.messageId.validate(),
                                ).launch(context);
                              },
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: context.width() * 0.85,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            cachedImage(
                                              thread.type == ThreadType.group ? thread.image : user.avatar,
                                              fit: BoxFit.cover,
                                              height: 40,
                                              width: 40,
                                            ).cornerRadiusWithClipRRect(20),
                                            12.width,
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                RichText(
                                                  text: TextSpan(
                                                    children: [
                                                      TextSpan(text: '${thread.type == ThreadType.group ? thread.title.validate() : user.name.validate()} ', style: boldTextStyle(fontFamily: fontFamily)),
                                                      if (thread.type == ThreadType.group && user.verified.validate() == 1)
                                                        WidgetSpan(
                                                          child: Image.asset(ic_tick_filled, height: 18, width: 18, color: blueTickColor, fit: BoxFit.cover),
                                                        ),
                                                    ],
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                Text(DateFormat('hh:mm a').format(DateTime.parse(message.dateSent.validate())), style: secondaryTextStyle()),
                                              ],
                                            ),
                                          ],
                                        ),
                                        16.height,
                                        if (meta != null && meta.files.validate().isNotEmpty) MessageMediaComponent(files: meta.files.validate()).paddingOnly(bottom: 8),
                                        Container(
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: context.cardColor,
                                            borderRadius: radius(commonRadius),
                                          ),
                                          child: Text(parseHtmlString(message.message.validate()), style: primaryTextStyle()),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.arrow_forward_ios_outlined, color: appStore.isDarkMode ? bodyDark : bodyWhite, size: 20)
                                ],
                              ),
                            );
                          });
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return Divider(color: context.dividerColor);
                        },
                      )
                    : Offstage();
              }),
            ]),
            Observer(builder: (context) {
              return LoadingWidget().center().visible(appStore.isLoading);
            }),
            Observer(builder: (context) {
              return Positioned(
                bottom: 20,
                child: RestoreComponent(
                  threadId: messageStore.deletedThreadId.validate(),
                  callback: (bool value) {
                    if (!value) {
                      doRefresh = true;
                    }

                    messageStore.showRestore = false;
                    messageStore.deletedThreadId = null;
                  },
                ),
              ).visible(messageStore.showRestore);
            }),
          ],
        ),
      ),
    );
  }
}
