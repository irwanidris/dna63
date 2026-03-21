import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/messages/message_users.dart';
import 'package:socialv/network/messages_repository.dart';
import 'package:socialv/screens/messages/screens/chat_screen.dart';
import 'package:socialv/store/message_store.dart';
import 'package:socialv/utils/cached_network_image.dart';

import '../../../models/messages/messages_model.dart';
import '../../../models/messages/threads_model.dart';
import '../../../utils/app_constants.dart';
import '../components/add_new_participant_component.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

WebSocketChannel? channel;

// ignore: must_be_immutable
class ParticipantsScreen extends StatefulWidget {
  final int participantsCount;
  bool? isModerator;
  final bool? canInvite;
  List<MessagesUsers> user;
  final int? threadId;
  List<Messages>? messages;
  Threads? thread;

  final MessagesUsers? loginUser;

  ParticipantsScreen(
      {required this.participantsCount,
      required this.user,
      this.threadId,
      this.isModerator,
      this.canInvite,
      this.messages,
      this.thread,
      this.loginUser});

  @override
  State<ParticipantsScreen> createState() => _ParticipantsScreenState();
}

class _ParticipantsScreenState extends State<ParticipantsScreen> {
  MessageStore participantsScreenVars = MessageStore();

  TextEditingController subjectController = TextEditingController();

  bool isRefresh = false;

  @override
  void initState() {
    super.initState();
    participantsScreenVars.allowOtherToInvite = widget.canInvite.validate();
  }

  Future<void> removeChatParticipant({required int id}) async {
    appStore.setLoading(true);
    await removeParticipant(userId: id, threadId: widget.threadId.validate())
        .then((value) {
      widget.user.removeWhere((element) {
        return element.userId == id;
      });
      isRefresh = true;
      appStore.setLoading(false);
    }).catchError((e) {
      toast(e.toString());
      appStore.setLoading(false);
    });
  }

  Future<void> allowOthersToInvite() async {
    appStore.setLoading(true);
    await allowOtherToInviteMembers(
            canInvite: participantsScreenVars.allowOtherToInvite,
            threadId: widget.threadId.validate())
        .then((value) {
      isRefresh = true;
      appStore.setLoading(false);
      finish(context, isRefresh);
    }).catchError((e) {
      isRefresh = true;
      appStore.setLoading(false);
      finish(context, isRefresh);
    });
  }

  Future<void> changeSubject() async {
    appStore.setLoading(true);
    await changeSubjectOfParticipants(
            subject: subjectController.text,
            threadId: widget.threadId.validate())
        .then((value) {
      isRefresh = true;
      appStore.setLoading(false);
    }).catchError((e) {
      isRefresh = true;
      toast(e.toString());
      appStore.setLoading(false);
    });
  }

  Future<void> refreshThread() async {
    appStore.setLoading(true);
    await getSpecificThread(threadId: widget.threadId.validate())
        .then((value) async {
      widget.messages.validate().clear();
      widget.messages = value.messages.validate().reversed.validate();
      widget.thread = value.threads.validate().first;
      widget.user = value.users.validate();
      isRefresh = true;
      setState(() {});

      appStore.setLoading(false);
    }).catchError((e) {
      toast(e.toString());
      appStore.setLoading(false);
    });
  }

  @override
  void dispose() {
    if (appStore.isLoading) appStore.setLoading(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (widget.canInvite.validate() !=
              participantsScreenVars.allowOtherToInvite) {
            allowOthersToInvite();
          } else {
            finish(context, isRefresh);
          }
          isRefresh = false;
        }
      },
      child: Observer(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: Text(language.participants.capitalizeFirstLetter(),
                style: boldTextStyle(size: 20)),
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: context.iconColor),
              onPressed: () {
                if (widget.canInvite.validate() !=
                    participantsScreenVars.allowOtherToInvite) {
                  allowOthersToInvite();
                } else {
                  finish(context, isRefresh);
                }
                isRefresh = false;
              },
            ),
            actions: [
              if ((widget.isModerator.validate() ||
                  widget.canInvite
                      .validate()) /*&& (widget.loginUser!.blocked != 1)*/)
                IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      isDismissible: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) {
                        return FractionallySizedBox(
                          heightFactor: 0.8,
                          child: AddNewParticipantComponent(
                            threadId: widget.threadId.validate(),
                            callback: () {
                              finish(context);
                              isRefresh = true;
                              refreshThread();
                            },
                          ),
                        );
                      },
                    );
                  },
                  icon: Icon(Icons.add_circle_outline),
                  color: appColorPrimary,
                  iconSize: 24,
                ),
            ],
          ),
          body: appStore.isLoading
              ? LoadingWidget()
              : SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        if (widget.isModerator
                            .validate() /*&& (widget.loginUser!.blocked != 1)*/)
                          Column(
                            children: [
                              16.height,
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text(language.conversationSettings,
                                    style: boldTextStyle(size: 18)),
                              ).paddingSymmetric(horizontal: 16),
                              16.height,
                              Row(
                                children: [
                                  AppTextField(
                                    textFieldType: TextFieldType.NAME,
                                    controller: subjectController,
                                    decoration: inputDecorationFilled(
                                      context,
                                      fillColor: context.cardColor,
                                      label: language.changeConversationSubject,
                                    ),
                                  ).paddingSymmetric(horizontal: 16).expand(),

                                  ///Add done button
                                  AppButton(
                                    height: 30,
                                    width: 80,
                                    margin: EdgeInsets.all(12),
                                    textColor: Colors.white,
                                    color: appColorPrimary,
                                    onTap: () {
                                      if (subjectController.text
                                          .trim()
                                          .isNotEmpty) {
                                        changeSubject();
                                      }
                                    },
                                    text: language.save,
                                  ).paddingOnly(right: 16)
                                ],
                              ),
                              16.height,
                              Observer(builder: (context) {
                                return CheckboxListTile(
                                  title: Text(language.allowInviteText,
                                      style: primaryTextStyle(size: 16)),
                                  subtitle: Text(
                                      language.enableInviteConversation,
                                      style: secondaryTextStyle(size: 12)),
                                  isThreeLine: true,
                                  value:
                                      participantsScreenVars.allowOtherToInvite,
                                  onChanged: (value) {
                                    participantsScreenVars.allowOtherToInvite =
                                        !participantsScreenVars
                                            .allowOtherToInvite;
                                  },
                                );
                              })
                            ],
                          ),
                        ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.only(
                              left: 16, right: 8, top: 16, bottom: 16),
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: widget.user.length,
                          itemBuilder: (ctx, index) {
                            MessagesUsers element = widget.user[index];

                            List<int>? moderators =
                                widget.thread?.moderators.validate() ?? [];
                            bool isModerator =
                                moderators.contains(element.userId.validate());
                            bool isLoinUser =
                                userStore.loginUserId.validate().toString() ==
                                    element.userId.validate().toString();

                            ///elements id is match with moderator id then it is moderator

                            return Row(
                              children: [
                                cachedImage(element.avatar.validate(),
                                        height: 36,
                                        width: 36,
                                        fit: BoxFit.cover)
                                    .cornerRadiusWithClipRRect(18),
                                16.width,
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          if (isLoinUser)
                                            TextSpan(
                                                text: language.you,
                                                style: primaryTextStyle(
                                                    fontFamily: fontFamily))
                                          else
                                            TextSpan(
                                                text:
                                                    '${element.name.validate()} ',
                                                style: primaryTextStyle(
                                                    fontFamily: fontFamily)),
                                          if (element.verified.validate() == 1)
                                            WidgetSpan(
                                                child: Image.asset(
                                                        ic_tick_filled,
                                                        height: 16,
                                                        width: 16,
                                                        color: blueTickColor,
                                                        fit: BoxFit.cover)
                                                    .paddingOnly(left: 4)),
                                        ],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.start,
                                    ),

                                    ///Denoted admin
                                    if (isModerator)
                                      Container(
                                        decoration: BoxDecoration(
                                            color: Colors.green.shade400,
                                            borderRadius: radius()),
                                        child: Text(language.groupAdmin,
                                            style: secondaryTextStyle(
                                                color: white, size: 12)),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                      ),
                                  ],
                                ).expand(),
                                if (element.id.validate() !=
                                    userStore.loginUserId)
                                  Theme(
                                    data: Theme.of(context).copyWith(
                                      highlightColor: Colors.transparent,
                                      splashColor: Colors.transparent,
                                    ),
                                    child: Observer(builder: (context) {
                                      return (widget.isModerator.validate() ||
                                              element.canBlock == 1)
                                          ? PopupMenuButton(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          commonRadius)),
                                              onSelected: (val) async {
                                                if (val == 1) {
                                                  if (element.blocked == 0) {
                                                    element.blocked = 1;
                                                    blockUser(
                                                        userId: element.userId
                                                            .validate());
                                                  } else {
                                                    element.blocked = 0;
                                                    unblockUser(
                                                        userId: element.userId
                                                            .validate());
                                                  }
                                                } else if (val == 2) {
                                                  removeChatParticipant(
                                                      id: element.userId
                                                          .validate());
                                                } else if (val == 3) {
                                                  await privateThread(
                                                          userId: element.userId
                                                              .validate())
                                                      .then((value) {
                                                    if (value.threadId
                                                            .validate() >
                                                        0)

                                                      ///remove until message screen
                                                      Navigator.of(context)
                                                          .popUntil((route) =>
                                                              route.settings
                                                                  .name ==
                                                              'MessageScreen');
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: (_) =>
                                                            ChatScreen(
                                                          threadId: value
                                                              .threadId
                                                              .validate(),
                                                          user: element,
                                                          name: element.name
                                                              .validate(),
                                                          callback: () =>
                                                              finish(context),
                                                          onDeleteThread: () =>
                                                              finish(context),
                                                        ),
                                                      ),
                                                    );
                                                  });
                                                } else if (val == 4) {
                                                  promoteAsAdmin(
                                                          userId: element.userId
                                                              .validate(),
                                                          groupId: widget
                                                              .threadId
                                                              .validate())
                                                      .then((value) {
                                                    isModerator = true;

                                                    widget.thread?.moderators
                                                        ?.add(element.userId
                                                            .validate());
                                                    setState(() {});
                                                  });
                                                } else if (val == 5) {
                                                  demoteAsAdmin(
                                                          userId: element.userId
                                                              .validate(),
                                                          groupId: widget
                                                              .threadId
                                                              .validate())
                                                      .then((value) {
                                                    isModerator = false;

                                                    widget.thread?.moderators
                                                        ?.remove(element.userId
                                                            .validate());
                                                    setState(() {});
                                                  });
                                                }
                                              },
                                              icon: Icon(Icons.more_horiz),
                                              itemBuilder: (context) =>
                                                  <PopupMenuEntry>[
                                                if (element.canBlock == 1 &&
                                                    widget.isModerator
                                                        .validate())
                                                  PopupMenuItem(
                                                    value: 1,
                                                    child: TextIcon(
                                                      text: element.blocked
                                                                  .validate() ==
                                                              0
                                                          ? language.block
                                                          : language.unblock,
                                                      textStyle:
                                                          secondaryTextStyle(),
                                                    ),
                                                  ),
                                                if (widget.isModerator
                                                    .validate())
                                                  PopupMenuItem(
                                                    value: 2,
                                                    child: TextIcon(
                                                      text:
                                                          "${language.remove} ${element.name.validate()}",
                                                      textStyle:
                                                          secondaryTextStyle(),
                                                    ),
                                                  ),
                                                PopupMenuItem(
                                                  value: 3,
                                                  child: TextIcon(
                                                    text:
                                                        "${language.message} ${element.name.validate()}",
                                                    textStyle:
                                                        secondaryTextStyle(),
                                                  ),
                                                ),
                                                if (widget.isModerator
                                                        .validate() &&
                                                    isModerator != true)
                                                  PopupMenuItem(
                                                    value: 4,
                                                    child: TextIcon(
                                                      text: language
                                                          .promoteAsAdmin,
                                                      textStyle:
                                                          secondaryTextStyle(),
                                                    ),
                                                  ),
                                                if (widget.isModerator
                                                        .validate() &&
                                                    isModerator == true)
                                                  PopupMenuItem(
                                                    value: 5,
                                                    child: TextIcon(
                                                      text: language
                                                          .demoteFromAdmin,
                                                      textStyle:
                                                          secondaryTextStyle(),
                                                    ),
                                                  ),
                                              ],
                                            )
                                          : Offstage();
                                    }),
                                  )
                                else
                                  SizedBox(
                                    width: 50,
                                  ),
                              ],
                            ).paddingSymmetric(vertical: 8);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
        );
      }),
    );
  }
}
