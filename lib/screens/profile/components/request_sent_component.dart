import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/members/friend_request_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/profile/screens/member_profile_screen.dart';
import 'package:socialv/store/profile_menu_store.dart';
import 'package:socialv/utils/cached_network_image.dart';

import '../../../utils/app_constants.dart';

class RequestSentComponent extends StatefulWidget {
  RequestSentComponent();

  @override
  State<RequestSentComponent> createState() => _RequestSentComponentState();
}

class _RequestSentComponentState extends State<RequestSentComponent> with AutomaticKeepAliveClientMixin {
  ScrollController _scrollController = ScrollController();

  ProfileMenuStore requestSentComponentVars = ProfileMenuStore();
  int mPage = 1;
  bool mIsLastPage = false;

  @override
  void initState() {
    requestSentList();
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        if (!mIsLastPage) {
          mPage++;
          requestSentList();
        }
      }
    });

    afterBuildCreated(() async {
      appStore.setLoading(true);
    });
  }

  Future<void> requestSentList({bool loading = true}) async {
    appStore.setLoading(loading);
    requestSentComponentVars.isError = false;
    await getFriendRequestSent(page: mPage).then((value) {
      if (mPage == 1) requestSentComponentVars.sentReq.clear();

      mIsLastPage = value.length != 20;
      requestSentComponentVars.sentReq.addAll(value);
      appStore.setLoading(false);
    }).catchError((e) {
      requestSentComponentVars.isError = true;
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  @override
  void dispose() {
    requestSentComponentVars.sentReq.clear();
    requestSentComponentVars.isError = false;
    appStore.setLoading(false);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Container(
        width: context.width(),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: radiusOnly(topLeft: defaultRadius, topRight: defaultRadius),
        ),
        child: Observer(
          builder: (_) => Stack(
            alignment: requestSentComponentVars.isError || requestSentComponentVars.sentReq.isEmpty ? Alignment.center : Alignment.topCenter,
            children: [
              SingleChildScrollView(
                physics: PageScrollPhysics(),
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ///Error widget
                    Observer(builder: (_) {
                      return NoDataWidget(
                        imageWidget: NoDataLottieWidget(),
                        title: language.somethingWentWrong,
                        onRetry: () {
                          requestSentComponentVars.isError = false;
                          mPage = 1;
                          requestSentList();
                        },
                        retryText: '   ${language.clickToRefresh}   ',
                      ).center().visible(!appStore.isLoading && requestSentComponentVars.isError);
                    }),

                    ///No data widget
                    Observer(builder: (_) {
                      return NoDataWidget(
                        imageWidget: NoDataLottieWidget(),
                        title: language.noDataFound,
                        onRetry: () {
                          requestSentComponentVars.isError = false;
                          mPage = 1;
                          requestSentList();
                        },
                        retryText: '   ${language.clickToRefresh}   ',
                      ).center().visible(!appStore.isLoading && !requestSentComponentVars.isError && requestSentComponentVars.sentReq.isEmpty);
                    }),

                    ///List of sent request
                    Observer(builder: (_) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Sent Request( ${requestSentComponentVars.sentReq.length} )', style: boldTextStyle()).paddingAll(16).visible(!appStore.isLoading && !requestSentComponentVars.isError && requestSentComponentVars.sentReq.isNotEmpty),

                          AnimatedListView(
                            padding: EdgeInsets.only(left: 16, right: 16, bottom: 50),
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            slideConfiguration: SlideConfiguration(delay: 80.milliseconds, verticalOffset: 300),
                            itemCount: requestSentComponentVars.sentReq.length,
                            itemBuilder: (context, index) {
                              FriendRequestModel friend = requestSentComponentVars.sentReq[index];

                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [

                                  cachedImage(
                                    friend.userImage.validate(),
                                    height: 42,
                                    width: 42,
                                    fit: BoxFit.cover,
                                  ).cornerRadiusWithClipRRect(100),
                                  12.width,
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(text: '${friend.userName.validate()} ', style: boldTextStyle(fontFamily: fontFamily)),
                                            if (friend.isUserVerified.validate()) WidgetSpan(child: Image.asset(ic_tick_filled, height: 18, width: 18, color: blueTickColor, fit: BoxFit.cover)),
                                          ],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.start,
                                      ),
                                      4.height,
                                      Text(friend.userMentionName.validate(), style: secondaryTextStyle()),
                                    ],
                                  ).expand(),
                                  8.width,
                                  IconButton(
                                    onPressed: () {
                                      if (!appStore.isLoading)
                                        showConfirmDialogCustom(context,
                                            dialogType: DialogType.CONFIRMATION,
                                            positiveText: language.yes,
                                            title: "${language.doYouReallyWantToRemoveRequest} ${friend.userName}?", onAccept: (c) {
                                          ifNotTester(() {
                                            removeExistingFriendConnection(friendId: friend.userId.validate().toString(), passRequest: false).then((value) async {
                                              if (value.deleted.validate()) {
                                                mPage = 1;
                                                await requestSentList(loading: true);
                                                toast(language.successfullyRemoveSentRequests);
                                              }
                                            }).catchError((e) {
                                              toast(e.toString(), print: true);
                                            });
                                          });
                                        });
                                    },
                                    icon: Image.asset(
                                      ic_close_square,
                                      color: appStore.isDarkMode ? bodyDark : bodyWhite,
                                      width: 20,
                                      height: 20,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ],
                              ).onTap(() async {
                                MemberProfileScreen(memberId: friend.userId.validate()).launch(context).then((value) {
                                  if (value ?? false) {
                                    mPage = 1;
                                    appStore.setLoading(true);
                                    requestSentList();
                                  }
                                });
                              }).paddingSymmetric(vertical: 8);
                            },
                          ).visible(!appStore.isLoading && !requestSentComponentVars.isError && requestSentComponentVars.sentReq.isNotEmpty),
                        ],
                      );
                    })
                  ],
                ),
              ),

              ///Loading widget
              Observer(
                builder: (_) => Positioned(
                  bottom: mPage != 1 ? 10 : null,
                  child: LoadingWidget(isBlurBackground: true).visible(appStore.isLoading),
                ),
              ),
            ],
          ),
        ));
  }

  @override
  bool get wantKeepAlive => true;
}
