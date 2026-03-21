import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/screens/settings/components/pending_invites_card_component.dart';
import 'package:socialv/store/message_store.dart';
import 'package:socialv/utils/app_constants.dart';
import '../../../components/no_data_lottie_widget.dart';
import '../../../main.dart';
import '../../../models/invitations/invite_list_model.dart';
import '../../../network/rest_apis.dart';

class PendingInvitesScreen extends StatefulWidget {
  const PendingInvitesScreen({Key? key}) : super(key: key);

  @override
  State<PendingInvitesScreen> createState() => _PendingInvitesScreenState();
}

class _PendingInvitesScreenState extends State<PendingInvitesScreen> {
  MessageStore pendingInvitesScreenVars = MessageStore();
  List bulkActionsList = [language.bulkAction, language.resend, language.cancel];

  @override
  void initState() {
    super.initState();
    pendingInvitesScreenVars.dropdownBulkActionsValue = language.bulkAction;
    init();
  }

  void init() {
    fetchInviteList();
  }

  Future<List<InviteListModel>> fetchInviteList() async {
    appStore.setLoading(true);
    pendingInvitesScreenVars.inviteList.clear();
    await getInviteList().then((value) {
      pendingInvitesScreenVars.inviteList.addAll(value);
      appStore.setLoading(false);
    }).catchError((e) {
      toast(e.toString());
      pendingInvitesScreenVars.isError = true;
      appStore.setLoading(false);
    });
    return pendingInvitesScreenVars.inviteList;
  }

  Future<void> sendInviteRequest({required List id}) async {
    appStore.setLoading(true);
    await sendInvite(inviteId: id, isResend: true).then((value) {
      toast(value.message, print: true);
      appStore.setLoading(false);
      messageStore.isChecked = false;
    }).catchError((e) {
      toast(e.toString());
      appStore.setLoading(false);
    });
  }

  Future<void> deleteInvite({required List id, bool isBulkActions = false}) async {
    appStore.setLoading(true);
    await deleteInvitedList(id: id).then((value) {
      if (isBulkActions) {
        id.forEach((val) {
          pendingInvitesScreenVars.inviteList.removeWhere((element) => element.id == val);
        });
      } else {
        pendingInvitesScreenVars.inviteList.removeWhere((element) => element.id == id.first);
      }
      toast(value.message);
      messageStore.isChecked = false;
      appStore.setLoading(false);
    }).catchError((e) {
      toast(e.toString(), print: true);
      appStore.setLoading(false);
    });
  }

  @override
  void dispose() {
    messageStore.selectedInviteRequests.clear();
    appStore.setMultiSelect(false);
    messageStore.isChecked = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(language.pendingInvites, style: boldTextStyle(size: 20)),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.iconColor),
          onPressed: () {
            finish(context);
          },
        ),
      ),
      body: Stack(
        children: [
          AnimatedScrollView(children: [
            /// error widget
            Observer(builder: (context) {
              return pendingInvitesScreenVars.isError && !appStore.isLoading
                  ? SizedBox(
                      height: context.height() * 0.8,
                      child: NoDataWidget(
                        imageWidget: NoDataLottieWidget(),
                        title: language.somethingWentWrong,
                        onRetry: () {
                          init();
                        },
                        retryText: '   ${language.clickToRefresh}   ',
                      ).center(),
                    )
                  : Offstage();
            }),

            /// empty widget

            Observer(builder: (context) {
              return pendingInvitesScreenVars.inviteList.isEmpty && !pendingInvitesScreenVars.isError && !appStore.isLoading
                  ? SizedBox(
                      height: context.height() * 0.8,
                      child: NoDataWidget(
                        imageWidget: NoDataLottieWidget(),
                        title: language.noDataFound,
                        onRetry: () {
                          init();
                        },
                        retryText: '   ${language.clickToRefresh}   ',
                      ).center(),
                    )
                  : Offstage();
            }),

            /// list widget
            Observer(builder: (context) {
              return pendingInvitesScreenVars.inviteList.isNotEmpty && !pendingInvitesScreenVars.isError
                  ? Stack(
                      children: [
                        SingleChildScrollView(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.topRight,
                                child: TextIcon(
                                  text: language.selectAll,
                                  textStyle: primaryTextStyle(color: appColorPrimary),
                                  prefix: Icon(
                                    messageStore.isChecked ? Icons.check_circle : Icons.circle_outlined,
                                    color: appColorPrimary,
                                    size: 20,
                                  ),
                                ),
                              ).onTap(() {
                                messageStore.isChecked = !messageStore.isChecked;
                                if (messageStore.isChecked) {
                                  appStore.setMultiSelect(true);
                                  pendingInvitesScreenVars.inviteList.forEach((element) {
                                    messageStore.selectedInviteRequests.add(element.id);
                                  });
                                } else {
                                  appStore.setMultiSelect(false);
                                  messageStore.selectedInviteRequests.clear();
                                }
                              }, splashColor: Colors.transparent, hoverColor: Colors.transparent, highlightColor: Colors.transparent),
                              AnimatedListView(
                                padding: EdgeInsets.only(bottom: appStore.isMultiSelect ? 80 : 16),
                                itemCount: pendingInvitesScreenVars.inviteList.length,
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                slideConfiguration: SlideConfiguration(delay: 80.milliseconds, verticalOffset: 300),
                                itemBuilder: (p0, index) {
                                  InviteListModel data = pendingInvitesScreenVars.inviteList[index];

                                  return Observer(builder: (context) {
                                    return PendingInvitesCardComponent(
                                      inviteList: data,
                                      isChecked: messageStore.isChecked,
                                      isSent: data.inviteSent == 1,
                                      callback: (id, isResend) {
                                        messageStore.selectedInviteRequests.add(id);
                                        if (isResend.validate()) {
                                          sendInviteRequest(id: messageStore.selectedInviteRequests).then(
                                            (value) => messageStore.selectedInviteRequests.remove(id),
                                          );
                                        } else {
                                          deleteInvite(id: messageStore.selectedInviteRequests).then(
                                            (value) => messageStore.selectedInviteRequests.remove(id),
                                          );
                                        }
                                      },
                                    ).paddingSymmetric(vertical: 8);
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        if (appStore.isMultiSelect)
                          Positioned(
                            bottom: 0,
                            width: context.width(),
                            child: Container(
                              height: 80,
                              color: context.scaffoldBackgroundColor,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Observer(builder: (context) {
                                    return Container(
                                      height: 50,
                                      decoration: BoxDecoration(color: context.cardColor, borderRadius: radius(commonRadius), border: Border.all(color: context.dividerColor)),
                                      child: DropdownButtonHideUnderline(
                                        child: ButtonTheme(
                                          alignedDropdown: true,
                                          child: DropdownButton<String>(
                                            isExpanded: true,
                                            borderRadius: BorderRadius.circular(commonRadius),
                                            value: pendingInvitesScreenVars.dropdownBulkActionsValue,
                                            icon: Icon(Icons.keyboard_arrow_up, color: appStore.isDarkMode ? bodyDark : Colors.black),
                                            elevation: 8,
                                            style: primaryTextStyle(),
                                            underline: Container(height: 2, color: appColorPrimary),
                                            alignment: Alignment.bottomCenter,
                                            onChanged: (newValue) {
                                              pendingInvitesScreenVars.dropdownBulkActionsValue = newValue!;
                                            },
                                            items: [
                                              DropdownMenuItem(child: Text(bulkActionsList[0]), value: bulkActionsList[0]),
                                              DropdownMenuItem(child: Text(bulkActionsList[1]), value: bulkActionsList[1]),
                                              DropdownMenuItem(child: Text(bulkActionsList[2]), value: bulkActionsList[2]),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ).expand();
                                  }),
                                  16.width,
                                  Observer(builder: (context) {
                                    return Container(
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: pendingInvitesScreenVars.dropdownBulkActionsValue == language.bulkAction ? appColorPrimary.withValues(alpha: 0.5) : appColorPrimary,
                                        borderRadius: radius(commonRadius),
                                      ),
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          language.apply,
                                          style: primaryTextStyle(size: 16, color: context.cardColor),
                                        ),
                                      ),
                                    ).onTap(() {
                                      if (pendingInvitesScreenVars.dropdownBulkActionsValue == language.bulkAction) {
                                        //
                                      } else if (pendingInvitesScreenVars.dropdownBulkActionsValue == language.resend) {
                                        sendInviteRequest(id: messageStore.selectedInviteRequests).then(
                                          (value) {
                                            messageStore.selectedInviteRequests.clear();
                                            appStore.setMultiSelect(false);
                                          },
                                        );
                                      } else {
                                        showConfirmDialogCustom(
                                          context,
                                          title: language.cancelInviteRequest,
                                          onAccept: (s) {
                                            deleteInvite(id: messageStore.selectedInviteRequests, isBulkActions: true).then(
                                              (value) {
                                                messageStore.selectedInviteRequests.clear();
                                                appStore.setMultiSelect(false);
                                              },
                                            );
                                          },
                                          dialogType: DialogType.CONFIRMATION,
                                        );
                                      }
                                    }).expand();
                                  }),
                                ],
                              ).paddingSymmetric(horizontal: 16),
                            ),
                          ),
                      ],
                    )
                  : Offstage();
            }),
          ]),
          Observer(
            builder: (context) => LoadingWidget().center().visible(appStore.isLoading),
          ),
        ],
      ),
    );
  }
}
