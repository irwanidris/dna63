import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/forums/forum_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/forums/components/forums_card_component.dart';
import 'package:socialv/screens/forums/screens/forum_detail_screen.dart';
// TEMP DISABLED: import 'package:socialv/screens/groups/screens/group_detail_screen.dart';
import 'package:socialv/screens/membership/screens/membership_plans_screen.dart';
import 'package:socialv/store/fragment_store/forums_fragment_store.dart';

import '../../../utils/app_constants.dart';

class ForumsFragment extends StatefulWidget {
  final ScrollController controller;

  const ForumsFragment({super.key, required this.controller});

  @override
  State<ForumsFragment> createState() => _ForumsFragment();
}

class _ForumsFragment extends State<ForumsFragment> {
  TextEditingController searchController = TextEditingController();
  ForumsFragStore forumsFragStore = ForumsFragStore();
  int mPage = 1;
  bool mIsLastPage = false;
  String errorText = "";

  @override
  void initState() {
    super.initState();
    init();

    widget.controller.addListener(() {
      /// pagination
      if (appStore.currentDashboardIndex == 2) {
        if (widget.controller.position.pixels == widget.controller.position.maxScrollExtent) {
          if (!mIsLastPage) {
            onNextPage();
          }
        }
      }
    });

    searchController.addListener(() {
      if (searchController.text.isNotEmpty) {
        showClearTextIcon();
      } else {
        forumsFragStore.hasShowClearTextIcon = false;
      }
    });

    LiveStream().on(RefreshForumsFragment, (p0) {
      mPage = 1;
      mIsLastPage = false;
      init();
    });
  }

  void showClearTextIcon() {
    if (!forumsFragStore.hasShowClearTextIcon) {
      forumsFragStore.hasShowClearTextIcon = true;
    } else {
      return;
    }
  }

  Future<void> init({bool showLoader = true, int page = 1}) async {
    appStore.setLoading(showLoader);

    await getForumList(
      page: page,
      keyword: searchController.text,
      forumsList: forumsFragStore.forumsList,
      lastPageCallback: (p0) {
        mIsLastPage = p0;
      },
    ).then((value) {
      forumsFragStore.isError = false;
      appStore.setLoading(false);
    }).catchError((e) {
      appStore.setLoading(false);
      forumsFragStore.isError = true;
      errorText = e.toString();
      toast(e.toString(), print: true);
    });
  }

  Future<void> onNextPage() async {
    mPage++;
    init(page: mPage);
  }

  @override
  void dispose() {
    searchController.dispose();
    LiveStream().dispose(RefreshForumsFragment);
    forumsFragStore.hasShowClearTextIcon = false;
    forumsFragStore.forumsList.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Observer(builder: (context) {
              return Container(
                margin: EdgeInsets.only(bottom: 16, top: 16),
                decoration: BoxDecoration(color: context.cardColor, borderRadius: radius(commonRadius)),
                child: Theme(
                  data: ThemeData(textSelectionTheme: TextSelectionThemeData(selectionHandleColor: Colors.transparent)),
                  child: AppTextField(
                    textAlignVertical: TextAlignVertical.center,
                    controller: searchController,
                    textFieldType: TextFieldType.USERNAME,
                    onFieldSubmitted: (text) {
                      init(page: 1);
                    },
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        showClearTextIcon();
                        init(page: 1);
                      } else {
                        forumsFragStore.hasShowClearTextIcon = false;
                      }
                    },
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: language.searchHere,
                      hintStyle: secondaryTextStyle(),
                      prefixIcon: Image.asset(
                        ic_search,
                        height: 16,
                        width: 16,
                        fit: BoxFit.cover,
                        color: appStore.isDarkMode ? bodyDark : bodyWhite,
                      ).paddingAll(16),
                      suffixIcon: forumsFragStore.hasShowClearTextIcon
                          ? IconButton(
                              icon: Icon(Icons.cancel, color: appStore.isDarkMode ? bodyDark : bodyWhite, size: 18),
                              onPressed: () {
                                hideKeyboard(context);
                                forumsFragStore.hasShowClearTextIcon = false;
                                searchController.clear();
                                init();
                              },
                            )
                          : null,
                    ),
                  ),
                ),
              );
            }),

            /// Error Widget
            Observer(builder: (context) {
              return SizedBox(
                height: context.height() * 0.8,
                width: context.width() - 32,
                child: NoDataWidget(
                  imageWidget: NoDataLottieWidget(),
                  title: jsonEncode(errorText),
                  onRetry: () {
                    LiveStream().emit(RefreshForumsFragment);
                  },
                  retryText: '   ${language.clickToRefresh}   ',
                ),
              ).center().visible(forumsFragStore.isError && !appStore.isLoading);
            }),

            /// No Data Widget
            Observer(builder: (context) {
              return SizedBox(
                height: context.height() * 0.8,
                child: NoDataWidget(
                  imageWidget: NoDataLottieWidget(),
                  title: searchController.text.isEmpty ? language.noForumsFound : "${language.cantFind} ${searchController.text} ${language.inForums}",
                  onRetry: () {
                    LiveStream().emit(RefreshForumsFragment);
                  },
                  retryText: '   ${language.clickToRefresh}   ',
                ).center(),
              ).visible(forumsFragStore.forumsList.isEmpty && !appStore.isLoading && !forumsFragStore.isError);
            }),

            /// Forum List
            Observer(builder: (context) {
              return AnimatedListView(
                itemCount: forumsFragStore.forumsList.length,
                padding: EdgeInsets.zero,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (p0, index) {
                  ForumModel data = forumsFragStore.forumsList[index];
                  return InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      appStore.setLoading(true);
                      await getForumDetail(
                        forumId: data.id.validate(),
                        page: 1,
                        topicPerPage: PER_PAGE,
                        forumsPerPage: PER_PAGE,
                      ).then((value) async {
                        if (data.isPrivate.getBoolInt()) {
                          if (data.groupDetails?.isGroupMember.validate() == true) {
                            ForumDetailScreen(
                              type: data.type.validate(),
                              forumId: data.id.validate(),
                              forumTitle: data.title.validate(),
                            ).launch(context).then((value) {
                              if (value ?? false) {
                                init();
                              }
                            });
                          } else if (data.isRequestSent != 0) {
                            appStore.setLoading(false);
                            await showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  //  title: Text(language.joinGroup, style: boldTextStyle(size: 18)),
                                  content: Text(
                                    'Already sent request for this group',
                                    style: secondaryTextStyle(size: 14),
                                  ),
                                  actions: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: context.primaryColor,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text(language.ok, style: primaryTextStyle(color: Colors.white)),
                                    ),
                                  ],
                                );
                              },
                            );

                            return;
                          } else {
                            if (!value.groupDetails!.isGroupMember.validate()) {
                              appStore.setLoading(false);

                              ///open popup dialog to join the group
                              await showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (dialogContext) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    //  title: Text(language.joinGroup, style: boldTextStyle(size: 18)),
                                    content: Text(
                                      "${language.youAreNotAMemberOfThisGroup}?",
                                      style: secondaryTextStyle(size: 14),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context); // Close dialog
                                        },
                                        child: Text(language.cancel, style: primaryTextStyle(color: Colors.red)),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: context.primaryColor,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                        onPressed: () {
                                          if (value.groupDetails != null && value.groupDetails!.groupId != 0) {
                                            // Close dialog first
                                            Navigator.pop(dialogContext);

                                            // Launch the screen after dialog is closed
                                            Future.delayed(Duration(milliseconds: 200), () {
                                              if (pmpStore.viewSingleGroup) {
                                                GroupDetailScreen(
                                                  groupId: value.groupDetails!.groupId.validate(),
                                                ).launch(context).then((refresh) {
                                                  init();
                                                  LiveStream().emit(RefreshForumsFragment);
                                                });
                                              } else {
                                                MembershipPlansScreen().launch(context).then((_) {
                                                  init();
                                                  LiveStream().emit(RefreshForumsFragment);
                                                });
                                              }
                                            });
                                          } else {
                                            toast(language.canNotViewThisGroup);
                                          }
                                        },
                                        child: Text(language.joinGroup, style: primaryTextStyle(color: Colors.white)),
                                      ),
                                    ],
                                  );
                                },
                              );
                              return;
                            }
                          }
                        }
                        if (data.isRequestSent != 0 && data.isPrivate.getBoolInt()) {
                          await showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                //  title: Text(language.joinGroup, style: boldTextStyle(size: 18)),
                                content: Text(
                                  language.alreadySentRequestForJoinThisGroup,
                                  style: secondaryTextStyle(size: 14),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context); // Close dialog
                                    },
                                    child: Text(language.ok, style: primaryTextStyle(color: Colors.red)),
                                  ),
                                ],
                              );
                            },
                          );
                        } else if (data.isPrivate.getBoolInt() && !value.groupDetails!.isGroupMember.validate()) {
                          ///open popup dialog to join the group
                          await showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                //  title: Text(language.joinGroup, style: boldTextStyle(size: 18)),
                                content: Text(
                                  "${language.youAreNotAMemberOfThisGroup}?",
                                  style: secondaryTextStyle(size: 14),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context); // Close dialog
                                    },
                                    child: Text(language.cancel, style: primaryTextStyle(color: Colors.red)),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: context.primaryColor,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context); // Close dialog first
                                      if (value.groupDetails != null && value.groupDetails!.groupId != 0) {
                                        if (pmpStore.viewSingleGroup) {
                                          GroupDetailScreen(groupId: value.groupDetails?.groupId.validate()).launch(context);
                                        } else {
                                          MembershipPlansScreen().launch(context);
                                        }
                                      } else {
                                        toast(language.canNotViewThisGroup);
                                      }
                                    },
                                    child: Text(language.joinGroup, style: primaryTextStyle(color: Colors.white)),
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          ForumDetailScreen(
                            type: data.type.validate(),
                            forumId: data.id.validate(),
                            forumTitle: data.title.validate(),
                          ).launch(context).then((value) {
                            if (value ?? false) {
                              init();
                            }
                          });
                        }
                        appStore.setLoading(false);
                      }).catchError((e) {
                        appStore.setLoading(false);
                        toast(e.toString(), print: true);
                      });
                    },
                    child: ForumsCardComponent(
                      title: data.title,
                      description: data.description,
                      postCount: data.postCount,
                      topicCount: data.topicCount,
                      freshness: data.freshness,
                    ),
                  );
                },
              ).visible(!forumsFragStore.isError);
            })
          ],
        ).paddingBottom(120),
        Observer(
          builder: (_) {
            if (appStore.isLoading) {
              if (mPage > 1) {
                return Positioned(
                  bottom: 32,
                  child: LoadingWidget(isBlurBackground: false).center(),
                  left: 16,
                  right: 16,
                );
              } else {
                return LoadingWidget(isBlurBackground: false).paddingTop(context.height() * 0.4).center();
              }
            } else {
              return Offstage();
            }
          },
        ),
      ],
    );
  }
}
