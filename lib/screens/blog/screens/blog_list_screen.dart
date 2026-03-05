import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/posts/wp_post_response.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/blog/components/blog_card_component.dart';
import 'package:socialv/store/profile_menu_store.dart';

import '../../../utils/app_constants.dart';

class BlogListScreen extends StatefulWidget {
  const BlogListScreen({Key? key}) : super(key: key);

  @override
  State<BlogListScreen> createState() => _BlogListScreenState();
}

class _BlogListScreenState extends State<BlogListScreen> {
  ScrollController _controller = ScrollController();
  ProfileMenuStore blogListScreenVars = ProfileMenuStore();
  TextEditingController searchController = TextEditingController();

  int mPage = 1;
  bool mIsLastPage = false;
  bool hasShowClearTextIcon = false;

  @override
  void initState() {
    getBlogs();
    super.initState();

    _controller.addListener(() {
      if (_controller.position.pixels == _controller.position.maxScrollExtent) {
        if (!mIsLastPage) {
          mPage++;
          getBlogs();
        }
      }
    });
    searchController.addListener(() {
      blogListScreenVars.showClearTextIcon(searchController.text.isNotEmpty);
    });
  }

  void showClearTextIcon() {
    if (!hasShowClearTextIcon) {
      hasShowClearTextIcon = true;
    } else {
      return;
    }
  }

  Future<void> getBlogs() async {
    blogListScreenVars.setLoading(true);

    if (mPage == 1) blogListScreenVars.blogList.clear();
    await getBlogList(page: mPage, searchText: searchController.text.trim()).then((value) {
      mIsLastPage = value.length != PER_PAGE;
      blogListScreenVars.blogList.addAll(value);
      blogListScreenVars.isError = false;
      blogListScreenVars.setLoading(false);
    }).catchError((e) {
      blogListScreenVars.setLoading(false);
      blogListScreenVars.isError = true;
      toast(e.toString(), print: true);
    });
  }

  Future<void> onRefresh() async {
    blogListScreenVars.isError = false;
    mPage = 1;
    getBlogs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(language.blogs, style: boldTextStyle(size: 20)),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.iconColor),
          onPressed: () {
            finish(context);
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: context.width() - 32,
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(color: context.cardColor, borderRadius: radius(commonRadius)),
              child: Observer(
                builder: (_) => AppTextField(
                  controller: searchController,
                  textFieldType: TextFieldType.USERNAME,
                  onFieldSubmitted: (text) {
                    mPage = 1;
                    getBlogs();
                  },
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      mPage = 1;
                      getBlogs();
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
                    suffixIcon: Observer(
                      builder: (_) => blogListScreenVars.hasShowClearTextIcon
                          ? IconButton(
                              icon: Icon(
                                Icons.cancel,
                                color: appStore.isDarkMode ? bodyDark : bodyWhite,
                                size: 18,
                              ),
                              onPressed: () {
                                searchController.clear();
                                blogListScreenVars.showClearTextIcon(false);
                                hideKeyboard(context);
                                mPage = 1;
                                getBlogs();
                              },
                            )
                          : SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
            ),
            Stack(
              alignment: Alignment.topCenter,
              children: [
                ///Error widget
                Observer(builder: (_) {
                  return SizedBox(
                    height: context.height() * 0.5,
                    child: NoDataWidget(
                      imageWidget: NoDataLottieWidget(),
                      title: language.somethingWentWrong,
                      onRetry: () {
                        onRefresh();
                      },
                      retryText: '   ${language.clickToRefresh}   ',
                    ).paddingTop(120).center().visible(!blogListScreenVars.isLoading && blogListScreenVars.isError),
                  );
                }),

                ///No Data Widget
                Observer(builder: (_) {
                  return SizedBox(
                    height: context.height() * 0.5,
                    child: NoDataWidget(
                      imageWidget: NoDataLottieWidget(),
                      title: language.noDataFound,
                      onRetry: () {
                        onRefresh();
                      },
                      retryText: '   ${language.clickToRefresh}   ',
                    ).paddingTop(120).center().visible(!blogListScreenVars.isLoading && !blogListScreenVars.isError && blogListScreenVars.blogList.isEmpty),
                  );
                }),

                ///List Data Widget
                Observer(builder: (_) {
                  return AnimatedListView(
                    controller: _controller,
                    slideConfiguration: SlideConfiguration(
                      delay: 80.milliseconds,
                      verticalOffset: 300,
                    ),
                    shrinkWrap: true,
                    padding: EdgeInsets.only(left: 16, right: 16, bottom: 50),
                    itemCount: blogListScreenVars.blogList.length,
                    itemBuilder: (context, index) {
                      WpPostResponse data = blogListScreenVars.blogList[index];
                      return BlogCardComponent(data: data);
                    },
                  ).visible(!blogListScreenVars.isError && blogListScreenVars.blogList.isNotEmpty);
                }),

                ///Loading widget
                Observer(
                  builder: (_) {
                    if (blogListScreenVars.isLoading) {
                      if (mPage != 1) {
                        return Positioned(
                          bottom: 10,
                          child: LoadingWidget(isBlurBackground: false).center(),
                        );
                      } else {
                        return LoadingWidget(isBlurBackground: false).paddingTop(context.height() * 0.1);
                      }
                    } else {
                      return Offstage();
                    }
                  },
                ),
              ],
            ).expand(),
          ],
        ),
      ),
    );
  }
}
