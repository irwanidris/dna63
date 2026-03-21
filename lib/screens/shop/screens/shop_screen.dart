import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/common_models.dart';
import 'package:socialv/models/woo_commerce/category_model.dart';
import 'package:socialv/screens/shop/components/product_card_component.dart';
import 'package:socialv/screens/shop/screens/wishlist_screen.dart';
import '../../../models/woo_commerce/product_list_model.dart';
import '../../../network/rest_apis.dart';
import '../../../utils/app_constants.dart';
import '../components/cached_image_widget.dart';
import '../components/sort_by_bottom_sheet.dart';
import 'cart_screen.dart';

class ShopScreen extends StatefulWidget {
  final int? categoryId;
  final String? categoryName;

  const ShopScreen({this.categoryId, this.categoryName});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  ScrollController _scrollController = ScrollController();

  List<FilterModel> filterOptions = getProductFilters();

  @override
  void initState() {
    shopStore.selectedIndex = -1;
    getProducts(
      categoryId: widget.categoryId != null ? widget.categoryId.validate() : null,
      orderBy: shopStore.selectedOrderBy,
    );
    super.initState();

    _scrollController.addListener(() {
      /// scroll down
      if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
        if (appStore.showShopBottom) appStore.setShopBottom(false);
      }

      /// scroll up
      if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
        if (!appStore.showShopBottom) appStore.setShopBottom(true);
      }

      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        if (!shopStore.mIsLastPage) {
          shopStore.mPage++;

          getProducts(
            categoryId: widget.categoryId != null ? widget.categoryId.validate() : null,
            orderBy: shopStore.selectedOrderBy,
          );
        }
      }
    });

    getCategories();
    getCartDetails().then((value) {
      shopStore.cartItemIndexList.clear();
      value.items!.forEach((item) {
        shopStore.cartItemIndexList.add(item.id);
      });
    });

    LiveStream().on(STREAM_FILTER_ORDER_BY, (p0) {
      shopStore.mPage = 1;
      shopStore.selectedOrderBy = (p0 as FilterModel).value.validate();
      shopStore.productList.clear();
      getProducts(orderBy: shopStore.selectedOrderBy).then((_) {
        setState(() {});
      });
    });

    afterBuildCreated(() async {
      appStore.setShopBottom(true);
    });
  }

  Future<List<ProductListModel>> getProducts({String? orderBy, int? categoryId}) async {
    if (shopStore.mPage == 1) shopStore.productList.clear();
    appStore.setLoading(true);
    shopStore.isError = false;

    try {
      final value = await getProductsList(page: shopStore.mPage, categoryId: categoryId, orderBy: orderBy ?? ProductFilters.date, searchText: shopStore.searchCont.text);

      shopStore.mIsLastPage = value.length != PER_PAGE;
      shopStore.productList.addAll(value);
      appStore.setLoading(false);
    } catch (e) {
      shopStore.isError = true;
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    }

    return shopStore.productList;
  }

  Future<void> getCategories() async {
    shopStore.categoryList.clear();
    await getCategoryList().then((value) {
      shopStore.categoryList.add(CategoryModel(name: 'All', id: -1));

      shopStore.categoryList.addAll(value);
    }).catchError((e) {
      toast(e.toString(), print: true);
    });
  }

  Future<void> onRefresh({int? categoryId}) async {
    shopStore.mPage = 1;
    shopStore.isError = false;
    shopStore.mPage = 1;

    getProducts(
        categoryId: categoryId != null
            ? categoryId
            : widget.categoryId != null
                ? widget.categoryId.validate()
                : null);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    appStore.setLoading(false);
    LiveStream().dispose(STREAM_FILTER_ORDER_BY);
    shopStore.searchCont.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        if (shopStore.selectedIndex == -1) {
          onRefresh();
        } else {
          onRefresh(categoryId: shopStore.selectedIndex);
        }
      },
      color: context.primaryColor,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: context.iconColor),
            onPressed: () {
              finish(context);
            },
          ),
          titleSpacing: 0,
          title: Text(widget.categoryName != null ? widget.categoryName.validate() : language.shop, style: boldTextStyle(size: 22)),
          elevation: 0,
          centerTitle: true,
          actions: [
            Wrap(
              children: [
                IconButton(
                  onPressed: () {
                    WishlistScreen(
                      refreshCallback: () {
                        onRefresh();
                      },
                    ).launch(context);
                  },
                  icon: Image.asset(ic_heart, height: 22, width: 22, color: context.primaryColor, fit: BoxFit.fill),
                ),
                Stack(
                  children: [
                    IconButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => CartScreen()),
                        );
                        // This runs after coming back from CartScreen
                        if (shopStore.selectedIndex == -1) {
                          onRefresh(); // or init() method
                        } else {
                          onRefresh(categoryId: shopStore.selectedIndex);
                        }
                      },
                      icon: Image.asset(ic_cart, height: 24, width: 24, color: context.primaryColor, fit: BoxFit.cover),
                    ),
                    Observer(
                      builder: (context) => Positioned(
                        top: 5,
                        right: 8,
                        child: Container(
                          padding: EdgeInsets.all(5),
                          decoration: boxDecorationDefault(
                            color: appColorPrimary,
                            shape: BoxShape.circle,
                          ),
                          child: Text(shopStore.cartItemIndexList.length.toString(), style: secondaryTextStyle(color: Colors.white, size: 10)),
                        ),
                      ).visible(shopStore.cartItemIndexList.length > 0),
                    )
                  ],
                ),
                16.width,
              ],
            ),
          ],
        ),
        body: Stack(
          children: [
            ///Loading Widget
            Positioned(
              // bottom: shopStore.mPage != 1 ? context.navigationBarHeight + 8 : null,
              child: Observer(builder: (context) {
                return LoadingWidget(isBlurBackground: shopStore.mPage == 1 ? true : false).visible(appStore.isLoading && shopStore.productList.isEmpty).center();
              }),
            ),

            Column(
              children: [
                ///Search textfield Widget
                AppTextField(
                  suffix: shopStore.searchCont.text.isNotEmpty
                      ? CloseButton(
                          color: context.primaryColor,
                          onPressed: () {
                            shopStore.searchCont.clear();
                            hideKeyboard(context);

                            shopStore.mPage = 1;
                            shopStore.selectedIndex = -1;
                            onRefresh();
                          })
                      : null,
                  textFieldType: TextFieldType.OTHER,
                  controller: shopStore.searchCont,
                  onChanged: (s) async {
                    if (s.isEmpty) {
                      hideKeyboard(context);
                      shopStore.mPage = 1;

                      shopStore.categoryList.clear();
                      onRefresh();
                      return await 2.seconds.delay;
                    }
                    if (s.isNotEmpty) {
                      onRefresh();
                    }
                  },
                  onFieldSubmitted: (s) async {
                    onRefresh();
                  },
                  decoration: InputDecoration(
                    hintText: language.searchHere,
                    prefixIcon: Icon(Icons.search, color: context.iconColor, size: 20),
                    hintStyle: secondaryTextStyle(),
                    border: OutlineInputBorder(
                      borderRadius: radius(),
                      borderSide: BorderSide(width: 0, style: BorderStyle.none),
                    ),
                    filled: true,
                    contentPadding: EdgeInsets.all(16),
                    fillColor: context.cardColor,
                  ),
                ).paddingSymmetric(horizontal: 16),
                16.height,

                ///Horizontal list Widget
                Observer(builder: (context) {
                  return HorizontalList(
                    itemCount: shopStore.categoryList.length,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      CategoryModel item = shopStore.categoryList[index];

                      return Observer(builder: (context) {
                        return Container(
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          decoration: BoxDecoration(
                            color: shopStore.selectedIndex == item.id ? context.primaryColor : context.cardColor,
                            borderRadius: BorderRadius.all(radiusCircular()),
                          ),
                          child: Row(
                            children: [
                              if (item.image != null)
                                CachedImageWidget(
                                  url: item.image!.src.validate(),
                                  fit: BoxFit.cover,
                                  width: 16,
                                  height: 16,
                                  circle: true,
                                ).paddingOnly(right: 4),
                              Text(item.name.validate(), style: boldTextStyle(size: 14, color: shopStore.selectedIndex == item.id ? context.cardColor : context.primaryColor), maxLines: 1),
                            ],
                          ),
                        ).onTap(
                          () {
                            shopStore.selectedIndex = item.id!;
                            shopStore.searchCont.clear();
                            shopStore.categoryList.forEach((element) {
                              element.isSelected = false;
                            });
                            item.isSelected = true;
                            shopStore.mPage = 1;
                            shopStore.selectedCategory = item;

                            if (item.id == -1) {
                              getProducts();
                            } else {
                              getProducts(categoryId: shopStore.selectedCategory!.id.validate());
                            }
                          },
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                        );
                      });
                    },
                  );
                }),
                16.height,

                SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.only(bottom: 80),
                  controller: _scrollController,
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Stack(
                    children: [
                      ///Error widget
                      Observer(builder: (_) {
                        return SizedBox(
                          height: context.height() * 0.6,
                          child: NoDataWidget(
                            imageWidget: NoDataLottieWidget(),
                            title: language.somethingWentWrong,
                            onRetry: () {
                              shopStore.searchCont.clear();
                              if (shopStore.selectedIndex == -1) {
                                onRefresh();
                              } else {
                                onRefresh(categoryId: shopStore.selectedIndex);
                              }
                            },
                            retryText: '   ${language.clickToRefresh}   ',
                          ).visible(shopStore.isError && !appStore.isLoading).center(),
                        );
                      }),

                      ///No Data widget
                      Observer(builder: (_) {
                        return SizedBox(
                          height: context.height() * 0.6,
                          child: NoDataWidget(
                            imageWidget: NoDataLottieWidget(),
                            title: language.noDataFound,
                            onRetry: () {
                              shopStore.searchCont.clear();
                              if (shopStore.selectedIndex == -1) {
                                onRefresh();
                              } else {
                                onRefresh(categoryId: shopStore.selectedIndex);
                              }
                            },
                            retryText: '   ${language.clickToRefresh}   ',
                          ).visible(shopStore.productList.isEmpty && !appStore.isLoading && !shopStore.isError).center(),
                        );
                      }),

                      ///Product list widget
                      Observer(builder: (context) {
                        final visibleProducts = shopStore.productList.where((p) => p.status == 'publish').toList();
                        return AnimatedWrap(
                          alignment: WrapAlignment.start,
                          itemCount: visibleProducts.length,
                          spacing: 16,
                          runSpacing: 16,
                          slideConfiguration: SlideConfiguration(delay: 120.milliseconds),
                          itemBuilder: (ctx, index) {
                            return ProductCardComponent(product: visibleProducts[index],refresh: (){
                              if (shopStore.selectedIndex == -1) {
                                onRefresh();
                              } else {
                                onRefresh(categoryId: shopStore.selectedIndex);
                              }
                            },);
                          },
                        ).visible(visibleProducts.isNotEmpty && !shopStore.isError).paddingSymmetric(horizontal: 16);
                      }),

                      ///Loading Widget
                      Observer(builder: (_) {
                        return Positioned(left: 0, right: 0, bottom: 10, child: ThreeBounceLoadingWidget().visible(shopStore.mPage > 1 && !shopStore.mIsLastPage));
                      }),
                    ],
                  ),
                ).expand(),
              ],
            )
          ],
        ),
        floatingActionButton: Observer(
          builder: (_) => AnimatedSlide(
            offset: appStore.showShopBottom ? Offset.zero : Offset(0, 0.4),
            duration: Duration(milliseconds: 350),
            child: Container(
              margin: EdgeInsets.only(bottom: 16),
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: boxDecorationDefault(color: context.primaryColor, borderRadius: radius(8)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextIcon(
                    text: language.sortBy,
                    textStyle: primaryTextStyle(color: appStore.isDarkMode ? bodyDark : Colors.white, size: 12),
                    prefix: Image.asset(ic_sort_by, height: 18, width: 18, color: appStore.isDarkMode ? bodyDark : Colors.white, fit: BoxFit.cover),
                    onTap: () async {
                      FilterModel? data = await showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        isDismissible: true,
                        shape: RoundedRectangleBorder(borderRadius: radiusOnly(topLeft: defaultRadius, topRight: defaultRadius)),
                        builder: (_) {
                          return SortByBottomSheet(getProductFilters());
                        },
                      );

                      if (data != null) {
                        LiveStream().emit(STREAM_FILTER_ORDER_BY, data);
                        //getProducts(orderBy: data.value);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
