  import 'package:flutter/material.dart';
  import 'package:flutter_mobx/flutter_mobx.dart';
  import 'package:nb_utils/nb_utils.dart';
  import 'package:socialv/components/loading_widget.dart';
  import 'package:socialv/main.dart';
  import 'package:socialv/network/rest_apis.dart';
  import 'package:socialv/screens/membership/screens/membership_plans_screen.dart';
  import 'package:socialv/screens/search/components/search_group_component.dart';
  import 'package:socialv/screens/search/components/search_member_component.dart';
  import 'package:socialv/screens/search/components/search_post_component.dart';

  import '../../components/no_data_lottie_widget.dart';
  import '../../utils/app_constants.dart';

  class SearchFragment extends StatefulWidget {
    final ScrollController controller;

    const SearchFragment({required this.controller});

    @override
    State<SearchFragment> createState() => _SearchFragmentState();
  }

  class _SearchFragmentState extends State<SearchFragment> with SingleTickerProviderStateMixin {
    List<String> searchOptions = [language.members, language.groups, language.posts];

    TextEditingController searchController = TextEditingController();

    int mPage = 1;
    bool mIsLastPage = false;

    @override
    void initState() {
      if (pmpStore.memberDirectory) {
        searchFragStore.searchDropdownValue = searchOptions.first;
      } else if (pmpStore.viewGroups) {
        searchFragStore.searchDropdownValue = searchOptions[1];
      } else {
        searchFragStore.searchDropdownValue = searchOptions[2];
      }

      widget.controller.addListener(() {
        if (widget.controller.position.pixels == widget.controller.position.maxScrollExtent) {
          if (!mIsLastPage) {
            mPage++;
            configureSearch(showLoader: true, page: mPage);
          }
        }
      });

      searchController.addListener(() {
        if (searchController.text.isNotEmpty) {
          showClearTextIcon();
        } else {
          searchFragStore.hasShowClearTextIcon = false;
        }
      });
      super.initState();
    }

    Future<void> configureSearch({bool showLoader = true, int page = 1, String type = ''}) async {
      if (searchController.text.isNotEmpty) {
        if (searchFragStore.searchDropdownValue == searchOptions.first) {
          getMembersList(page: page, showLoader: showLoader, type: type);
        } else if (searchFragStore.searchDropdownValue == searchOptions[1]) {
          getGroups(page: page, showLoader: showLoader);
        } else {
          getPosts(page: page, showLoader: showLoader);
        }
      }
    }

    Future<void> getMembersList({bool showLoader = true, int page = 1, String type = ''}) async {
      appStore.setLoading(true);
      await getAllMembers(
        searchText: searchController.text,
        page: page,
        memberList: searchFragStore.memberList,
        type: type,
        lastPageCallback: (p0) {
          mIsLastPage = p0;
        },
      ).then((value) {
        appStore.setLoading(false);
      }).catchError((e) {
        toast(e.toString());
        appStore.setLoading(false);
      });
    }

    Future<void> getGroups({bool showLoader = true, int page = 1}) async {
      appStore.setLoading(true);
      await getBuddyPressGroupList(
        searchText: searchController.text,
        groupList: searchFragStore.groupList,
        page: page,
        lastPageCallback: (p0) {
          mIsLastPage = p0;
        },
      ).then((value) {
        appStore.setLoading(false);
      }).catchError((e) {
        toast(e.toString());
        appStore.setLoading(false);
      });
    }

    Future<void> getPosts({bool showLoader = true, int page = 1}) async {
      appStore.setLoading(true);
      await searchPost(searchText: searchController.text, page: page).then((value) {
        if (mPage == 1) searchFragStore.postList.clear();
        mIsLastPage = value.length != PER_PAGE;
        searchFragStore.postList.addAll(value);
        appStore.setLoading(false);
      }).catchError((e) {
        appStore.setLoading(false);
        toast(e.toString(), print: true);
      });
    }

    void showClearTextIcon() {
      if (!searchFragStore.hasShowClearTextIcon) {
        searchFragStore.hasShowClearTextIcon = true;
      } else {
        return;
      }
    }

    @override
    void dispose() {
      searchController.dispose();
      searchFragStore.hasShowClearTextIcon = false;
      searchFragStore.memberList.clear();
      searchFragStore.groupList.clear();
      searchFragStore.postList.clear();
      super.dispose();
    }

    Widget buildEmptyWidget() {
      if (searchFragStore.isSearchFieldEmpty && searchFragStore.recentMemberSearchList.isEmpty && searchFragStore.recentGroupsSearchList.isEmpty)
        return Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              EmptySearchWidget().paddingTop(context.height() * 0.15),
              16.height,
              Text('Search and connect with members, groups and posts!', textAlign: TextAlign.center, style: primaryTextStyle()),
            ],
          ),
        );
      return SizedBox(
        height: context.height() * 0.45,
        child: NoDataWidget(
            imageWidget: NoDataLottieWidget(),
            title: searchFragStore.searchDropdownValue == searchOptions[0]
                ? "${language.cantFind} @${searchController.text}"
                : searchFragStore.searchDropdownValue == searchOptions[1]
                    ? "${language.cantFindGroup}"
                    : "${language.cantFindPost}"),
      ).visible(((searchFragStore.searchDropdownValue == searchOptions.first && searchFragStore.memberList.isEmpty) ||
              (searchFragStore.searchDropdownValue == searchOptions[1] && searchFragStore.groupList.isEmpty) ||
              (searchFragStore.searchDropdownValue == searchOptions.last && searchFragStore.postList.isEmpty)) &&
          !appStore.isLoading &&
          searchFragStore.recentMemberSearchList.isEmpty);
    }

    @override
    Widget build(BuildContext context) {
      return Stack(
        alignment: Alignment.topCenter,
        children: [
          AnimatedScrollView(
            listAnimationType: ListAnimationType.None,
            onNextPage: () {
              if (!mIsLastPage) {
                mPage++;
                configureSearch(showLoader: true, page: mPage);
              }
            },
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: context.width() * 0.54,
                    margin: EdgeInsets.only(left: 16, right: 16),
                    decoration: BoxDecoration(color: context.cardColor, borderRadius: radius(commonRadius)),
                    child: Observer(builder: (context) {
                      return AppTextField(
                        controller: searchController,
                        onChanged: (val) {
                          searchFragStore.isSearchFieldEmpty = searchController.text.isEmpty;
                          configureSearch();
                        },
                        textFieldType: TextFieldType.USERNAME,
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
                          suffixIcon: searchFragStore.hasShowClearTextIcon
                              ? IconButton(
                                  icon: Icon(Icons.cancel, color: appStore.isDarkMode ? bodyDark : bodyWhite, size: 18),
                                  onPressed: () {
                                    hideKeyboard(context);
                                    mPage = 1;
                                    searchController.clear();
                                    searchFragStore.hasShowClearTextIcon = false;
                                    searchFragStore.memberList.clear();
                                    searchFragStore.groupList.clear();
                                    searchFragStore.postList.clear();
                                    searchFragStore.isSearchFieldEmpty = true;
                                  },
                                )
                              : null,
                        ),
                      );
                    }),
                  ),
                  Observer(builder: (context) {
                    return Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        width: context.width() * 0.35,
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: context.cardColor,
                          borderRadius: radius(commonRadius),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            RenderBox renderBox = context.findRenderObject() as RenderBox;
                            Offset position = renderBox.localToGlobal(Offset.zero);
                            double screenHeight = MediaQuery.of(context).size.height;
                            double availableHeightBelow = screenHeight - position.dy - renderBox.size.height;

                            /// Show the dropdown menu
                            showMenu<String>(
                              context: context,
                              position: RelativeRect.fromLTRB(
                                position.dx,
                                availableHeightBelow >= 200 ? position.dy + renderBox.size.height : position.dy - 200,
                                position.dx + renderBox.size.width,
                                0,
                              ),
                              items: searchOptions.validate().map((String value) {
                                return PopupMenuItem<String>(
                                  value: value,
                                  padding: EdgeInsets.all(5),
                                  child: Text(value, style: primaryTextStyle()),
                                );
                              }).toList(),
                            ).then((selectedValue) {
                              if (selectedValue != null) {
                                mPage = 1;
                                if ((selectedValue == searchOptions.first && pmpStore.memberDirectory) ||
                                    (selectedValue == searchOptions[1] && pmpStore.viewGroups) ||
                                    selectedValue == searchOptions.last) {
                                  searchFragStore.searchDropdownValue = selectedValue;
                                  configureSearch();
                                } else {
                                  MembershipPlansScreen().launch(context);
                                }
                              }
                            });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                searchFragStore.searchDropdownValue,
                                style: primaryTextStyle(),
                                overflow: TextOverflow.ellipsis,
                              ),
                              ),
                              Icon(Icons.arrow_drop_down, color: appStore.isDarkMode ? bodyDark : bodyWhite),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ).paddingSymmetric(vertical: 16),

              /// members list widget
              Observer(
                builder: (context) => SearchMemberComponent(
                  showRecent: searchFragStore.recentMemberSearchList.isNotEmpty && searchFragStore.isSearchFieldEmpty,
                ).visible(searchFragStore.searchDropdownValue == searchOptions[0]),
              ),

              /// group list widget
              Observer(
                builder: (context) => SearchGroupComponent(
                  showRecent: searchFragStore.recentGroupsSearchList.isNotEmpty && searchFragStore.isSearchFieldEmpty,
                ).visible(searchFragStore.searchDropdownValue == searchOptions[1]),
              ),

              /// post list widget
              Observer(
                builder: (context) => SearchPostComponent(postList: searchFragStore.postList).visible(searchFragStore.searchDropdownValue == searchOptions[2]),
              ),

              /// empty list
              Observer(builder: (context) {
                return buildEmptyWidget();
              })
            ],
          ),
          Observer(
            builder: (_) {
              if (appStore.isLoading) {
                if (mPage > 1) {
                  return Positioned(
                    bottom: 10,
                    child: ThreeBounceLoadingWidget(),
                  );
                } else {
                  return LoadingWidget(isBlurBackground: false).paddingTop(context.height() * 0.3);
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
