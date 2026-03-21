import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/block_report/blocked_accounts_model.dart';
import 'package:socialv/network/messages_repository.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/store/profile_menu_store.dart';
import 'package:socialv/utils/cached_network_image.dart';


class BlockedAccounts extends StatefulWidget {
  const BlockedAccounts({Key? key}) : super(key: key);

  @override
  State<BlockedAccounts> createState() => _BlockedAccountsState();
}

class _BlockedAccountsState extends State<BlockedAccounts> {
  int mPage = 1;
  bool mIsLastPage = false;
  ProfileMenuStore blockedAccountsVars = ProfileMenuStore();

  @override
  void initState() {
    init();

    setStatusBarColor(Colors.transparent);
    super.initState();
  }

  @override
  void dispose() {
    appStore.setLoading(false);
    blockedAccountsVars.isError = false;
    super.dispose();
  }

  Future<void> init({bool showLoader = true}) async {
    blockedAccountsVars.isError = false;
    if (showLoader) appStore.setLoading(true);
    appStore.blockedUsersList.clear();
    await getBlockedAccounts().then((value) {
      if (value.isNotEmpty) {
        appStore.blockedUsersList.addAll(value);
      }
      if (showLoader) appStore.setLoading(false);
    }).catchError((e) {
      toast(e.toString());
      blockedAccountsVars.isError = true;
      if (showLoader) appStore.setLoading(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        mPage = 1;
        init();
      },
      color: context.primaryColor,
      child: Scaffold(
        appBar: AppBar(
          title: Text(language.blockedAccounts, style: boldTextStyle(size: 20)),
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
          alignment: Alignment.topCenter,
          children: [
            ///Error widget
            Observer(builder: (_) {
              return NoDataWidget(
                imageWidget: NoDataLottieWidget(),
                title: language.somethingWentWrong,
                onRetry: () {
                  mPage = 1;
                  init();
                },
                retryText: '   ${language.clickToRefresh}   ',
              ).center().visible(!appStore.isLoading && blockedAccountsVars.isError && appStore.blockedUsersList.isEmpty);
            }),

            ///No data Widget
            Observer(builder: (_) {
              return NoDataWidget(
                imageWidget: NoDataLottieWidget(),
                title: language.noDataFound,
                onRetry: () {
                  mPage = 1;
                  init();
                },
                retryText: '   ${language.clickToRefresh}   ',
              ).center().visible(!appStore.isLoading && !blockedAccountsVars.isError && appStore.blockedUsersList.isEmpty);
            }),

            /// list Widget
            Observer(builder: (context) {
              return ListView.builder(
                padding: EdgeInsets.all(16),
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: appStore.blockedUsersList.length,
                itemBuilder: (ctx, index) {
                  BlockedAccountsModel user = appStore.blockedUsersList[index];
                  return Row(
                    children: [
                      cachedImage(user.userImage, height: 40, width: 40).cornerRadiusWithClipRRect(20),
                      16.width,
                      Column(
                        children: [
                          Text(user.userName.validate(), style: primaryTextStyle(size: 14)),
                          4.height,
                          Text(user.userMentionName.validate(), style: secondaryTextStyle(size: 12)).paddingOnly(right: 8),
                        ],
                        crossAxisAlignment: CrossAxisAlignment.start,
                      ).expand(),
                      AppButton(
                        enabled: true,
                        shapeBorder: RoundedRectangleBorder(borderRadius: radius(4)),
                        text: language.unblock,
                        textStyle: primaryTextStyle(color: Colors.white, size: 12),
                        onTap: () async {
                          await unblockMember(userId: user.userId.toInt().validate()).then((value) {
                            init();
                          });
                        },
                        color: context.primaryColor,
                        width: 60,
                        padding: EdgeInsets.all(0),
                        elevation: 0,
                      )
                    ],
                  );
                },
              ).visible(appStore.blockedUsersList.isNotEmpty && !appStore.isLoading);
            }),

            ///Loading widget
            Observer(
              builder: (_) {
                if (appStore.isLoading) {
                  return Positioned(
                    bottom: mPage != 1 ? 10 : null,
                    child: LoadingWidget(),
                  );
                } else {
                  return Offstage();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
