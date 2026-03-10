import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/woo_commerce/cart_item_model.dart';
import 'package:socialv/models/woo_commerce/product_list_model.dart';
import 'package:socialv/models/woo_commerce/recently_viewed_products_model.dart';
import 'package:socialv/models/woo_commerce/related_products_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/shop/components/cart_coupons_component.dart';
import 'package:socialv/screens/shop/components/empty_cart_component.dart';
import 'package:socialv/screens/shop/components/price_widget.dart';
import 'package:socialv/screens/shop/components/product_card_component.dart';
// TEMP DISABLED: import 'package:socialv/screens/shop/screens/checkout_screen.dart';
import 'package:socialv/screens/shop/screens/coupon_list_screen.dart';
import 'package:socialv/screens/shop/screens/product_detail_screen.dart';
import 'package:socialv/screens/shop/screens/wishlist_screen.dart';
import 'package:socialv/store/shop_store.dart';
import 'package:socialv/utils/app_constants.dart';
import 'package:socialv/utils/cached_network_image.dart';

class CartScreen extends StatefulWidget {
  final bool isFromHome;

  CartScreen({this.isFromHome = false});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool mIsLastPage = false;
  late ShopStore cartScreenVars;

  TextEditingController couponController = TextEditingController();

  @override
  void initState() {
    super.initState();
    cartScreenVars = ShopStore();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getCart();
      fetchRecentlyViewedProducts();
    });
  }

  Future<void> getCart({String? orderBy, bool showLoader = true}) async {
    if (!mounted) return;
    if (showLoader) {
      shopStore.setLoading(true);
    }

    try {
      runInAction(() {
        cartScreenVars.isError = false;
        cartScreenVars.cartItemList.clear();
        cartScreenVars.total = 0;
        shopStore.productList.clear();
      });

      final cartDetails = await getCartDetails();
      if (!mounted) return;

      runInAction(() {
        cartScreenVars.cart = cartDetails;
        cartScreenVars.cartItemList = ObservableList.of(cartDetails.items.validate());
        cartScreenVars.total = cartDetails.totals!.totalPrice.validate().toInt();
        shopStore.setCartCount(cartScreenVars.cartItemList.validate().length);
      });

      if (cartScreenVars.cartItemList.isNotEmpty) {
        final relatedProductsFutures = cartScreenVars.cartItemList.map((item) async {
          try {
            final products = await getRelatedProducts(productId: item.id.validate());
            return products.map((product) => convertToProductListModel(product)).toList();
          } catch (e) {
            log('Error fetching related products for item ${item.id}: $e');
            return <ProductListModel>[];
          }
        });

        try {
          final allRelatedProducts = await Future.wait(relatedProductsFutures);
          if (!mounted) return;
          runInAction(() {
            /// Add Related Products
            for (final productList in allRelatedProducts) {
              for (final product in productList) {
                if (!shopStore.productList.any((existing) => existing.id == product.id)) {
                  shopStore.productList.add(product);
                }
              }
            }
          });
        } catch (e) {
          log('Error fetching related products: $e');
        }
      }
    } catch (e) {
      if (!mounted) return;

      runInAction(() {
        cartScreenVars.isError = true;
      });
      log(e.toString());
      toast(e.toString(), print: true);
    } finally {
      if (!mounted) return;
      shopStore.setLoading(false);
    }
  }

  Future<void> fetchRecentlyViewedProducts() async {
    if (!mounted) return;
    try {
      final products = await getRecentlyViewedProductList();
      if (!mounted) return;
      runInAction(() {
        shopStore.recentlyViewedProductList.clear();
        shopStore.recentlyViewedProductList.addAll(products);
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> applyCouponToCart() async {
    if (couponController.text.isNotEmpty) {
      ifNotTester(() async {
        hideKeyboard(context);
        await Future.forEach<CartItemModel>(cartScreenVars.cart!.items.validate(), (element) async {
          if (element.isQuantityChanged.validate()) {
            await updateCartItem(productKey: element.key.validate(), quantity: element.quantity.validate()).then((value) async {}).catchError((e) {
              shopStore.setLoading(false);
              toast(e.toString(), print: true);
            });
          }
        }).then((value) async {
          await applyCoupon(code: couponController.text).then((value) {
            toast(language.couponApplySuccessfully);
            cartScreenVars.cart = value;
            couponController.clear();
            cartScreenVars.total = value.totals!.totalPrice.validate().toInt();

            shopStore.setLoading(false);
          }).catchError((e) {
            couponController.clear();
            shopStore.setLoading(false);
            toast(e.toString());
          });
        });
      });
    } else {
      if (couponController.text.isEmpty) {
        toast(language.enterValidCouponCode);
      } else {
        toast(language.totalAmountIsLess);
      }
    }
  }

  Future<void> onRefresh() async {
    cartScreenVars.isError = false;
    shopStore.relatedProductList.clear();
    shopStore.recentlyViewedProductList.clear();

    await Future.wait([
      getCart(),
      fetchRecentlyViewedProducts(),
    ]);
  }

  @override
  void dispose() {
    shopStore.setLoading(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return RefreshIndicator(
        onRefresh: () async {
          onRefresh();
        },
        color: context.primaryColor,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: context.iconColor),
              onPressed: () {
              Navigator.pop(context,true);
              },
            ),
            titleSpacing: 0,
            title: Text(language.myCart, style: boldTextStyle(size: 22)),
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
                ],
              ),
            ],
          ),
          body: SafeArea(
            child: Stack(
              children: [
                ///Loading widget

                Observer(builder: (context) => LoadingWidget().center().visible(shopStore.isLoading)),

                ///Error widget
                Observer(builder: (_) {
                  return SizedBox(
                    height: context.height() * 0.8,
                    child: NoDataWidget(
                      imageWidget: NoDataLottieWidget(),
                      title: language.somethingWentWrong,
                      onRetry: () {
                        onRefresh();
                      },
                      retryText: '   ${language.clickToRefresh}   ',
                    ),
                  ).center().visible(cartScreenVars.isError && !shopStore.isLoading);
                }),

                ///Empty cart widget

                Observer(builder: (_) {
                  return SizedBox(height: context.height() * 0.6, child: EmptyCartComponent(isFromHome: widget.isFromHome)).center().visible(!cartScreenVars.isError && !shopStore.isLoading && cartScreenVars.cartItemList.isEmpty);
                }),
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Observer(builder: (_) {
                        return AnimatedListView(
                          shrinkWrap: true,
                          listAnimationType: ListAnimationType.FadeIn,
                          slideConfiguration: SlideConfiguration(delay: 80.milliseconds, verticalOffset: 300),
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          itemCount: cartScreenVars.cartItemList.length,
                          itemBuilder: (context, index) {
                            CartItemModel cartItem = cartScreenVars.cartItemList[index];

                            return Container(
                              padding: EdgeInsets.all(16),
                              margin: EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(color: context.cardColor, borderRadius: radius(10)),
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      cachedImage(
                                        cartItem.images.validate().isNotEmpty ? cartItem.images!.first.src.validate() : '',
                                        height: 70,
                                        width: 70,
                                        fit: BoxFit.cover,
                                      ).cornerRadiusWithClipRRect(defaultAppButtonRadius),
                                      16.width,
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(cartItem.name.validate().capitalizeFirstLetter(), style: boldTextStyle(), maxLines: 2, overflow: TextOverflow.ellipsis).expand(),
                                              Image.asset(ic_close_square, color: context.primaryColor, height: 20, width: 20, fit: BoxFit.cover).onTap(() {
                                                showConfirmDialogCustom(
                                                  context,
                                                  onAccept: (c) {
                                                    cartItem.isQuantityChanged = true;
                                                    product.isAddedCart = false;
                                                    cartScreenVars.total = cartScreenVars.total - (cartItem.prices!.price.validate().toInt() * cartItem.quantity!.toInt());
                                                    cartScreenVars.cartItemList.remove(cartItem);
                                                    shopStore.cartItemIndexList.remove(cartItem.id);

                                                    toast(language.itemRemovedSuccessfully);
                                                    removeCartItem(productKey: cartItem.key.validate()).then((value) {
                                                      if (cartScreenVars.cartItemList.isEmpty && cartScreenVars.cart?.coupons != null && cartScreenVars.cart!.coupons!.isNotEmpty) {
                                                        removeCoupon(code: cartScreenVars.cart!.coupons![0].code.validate());
                                                      }
                                                    }).catchError((e) {
                                                      toast(e.toString(), print: true);
                                                    });
                                                  },
                                                  dialogType: DialogType.CONFIRMATION,
                                                  title: language.removeFromCartConfirmation,
                                                  positiveText: language.remove,
                                                );
                                              }, splashColor: Colors.transparent, highlightColor: Colors.transparent),
                                            ],
                                          ),
                                          4.height,
                                          PriceWidget(
                                            price: getPrice(cartItem.prices!.price.validate()),
                                            salePrice: getPrice(cartItem.prices!.salePrice.validate()),
                                            regularPrice: getPrice(cartItem.prices!.regularPrice.validate()),
                                          ),
                                          8.height,
                                          Row(
                                            children: [
                                              Text('${language.qty}: ', style: primaryTextStyle(color: appStore.isDarkMode ? bodyDark : bodyWhite, size: 12)),
                                              Icon(
                                                Icons.remove,
                                                color: appStore.isDarkMode ? bodyDark : bodyWhite,
                                                size: 18,
                                              ).paddingOnly(left: 8, right: 6, top: 8, bottom: 8).onTap(() {
                                                if (cartItem.quantity.validate() > 1 && !shopStore.isLoading) {
                                                  int newQuantity = cartItem.quantity.validate() - 1;
                                                  double singleItemPrice = cartItem.prices!.salePrice.validate().toDouble();

                                                  // Update UI immediately
                                                  runInAction(() {
                                                    cartItem.quantity = newQuantity;
                                                    cartItem.isQuantityChanged = true;
                                                    cartScreenVars.total = cartScreenVars.total - singleItemPrice.toInt();
                                                    cartItem.prices!.price = (singleItemPrice * newQuantity).toString();
                                                  });

                                                  // Update backend
                                                  updateCartItem(productKey: cartItem.key.validate(), quantity: newQuantity).then((_) {
                                                    toast(language.quantityUpdatedSuccessfully);
                                                  }).catchError((e) {
                                                    // Revert the quantity and price if API call fails
                                                    runInAction(() {
                                                      cartItem.quantity = newQuantity + 1;
                                                      cartItem.isQuantityChanged = true;
                                                      cartScreenVars.total = cartScreenVars.total + singleItemPrice.toInt();
                                                      cartItem.prices!.price = (singleItemPrice * (newQuantity + 1)).toString();
                                                    });
                                                    toast(e.toString(), print: true);
                                                  });
                                                } else if (cartItem.quantity.validate() == 1 && !shopStore.isLoading) {
                                                  runInAction(() {
                                                    cartScreenVars.total = cartScreenVars.total - cartItem.prices!.salePrice.validate().toInt();
                                                    cartScreenVars.cartItemList.remove(cartItem);
                                                    shopStore.cartItemIndexList.remove(cartItem.id);
                                                    shopStore.setCartCount(cartScreenVars.cartItemList.length);
                                                  });

                                                  removeCartItem(productKey: cartItem.key.validate()).then((_) {
                                                    toast(language.itemRemovedSuccessfully);
                                                    if (cartScreenVars.cartItemList.isEmpty && cartScreenVars.cart?.coupons != null && cartScreenVars.cart!.coupons!.isNotEmpty) {
                                                      removeCoupon(code: cartScreenVars.cart!.coupons![0].code.validate()).then((_) {
                                                        runInAction(() {
                                                          cartScreenVars.cart!.coupons!.clear();
                                                          cartScreenVars.total = 0;
                                                        });
                                                      }).catchError((e) {
                                                        toast(e.toString(), print: true);
                                                      });
                                                    }
                                                  }).catchError((e) {
                                                    runInAction(() {
                                                      cartScreenVars.cartItemList.add(cartItem);
                                                      shopStore.cartItemIndexList.add(cartItem.id);
                                                      cartScreenVars.total = cartScreenVars.total + cartItem.prices!.salePrice.validate().toInt();
                                                      shopStore.setCartCount(cartScreenVars.cartItemList.length);
                                                    });
                                                    toast(e.toString(), print: true);
                                                  });
                                                }
                                              }),
                                              Observer(builder: (_) {
                                                return Container(
                                                  padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                                                  margin: EdgeInsets.only(top: 8, bottom: 8),
                                                  decoration: BoxDecoration(borderRadius: radius(4), border: Border.all(color: appStore.isDarkMode ? bodyDark : bodyWhite)),
                                                  child: Text(cartItem.quantity.toString(), style: primaryTextStyle(color: appStore.isDarkMode ? bodyDark : bodyWhite, size: 12)),
                                                ).visible(cartScreenVars.total > 0);
                                              }),
                                              Icon(
                                                Icons.add,
                                                color: appStore.isDarkMode ? bodyDark : bodyWhite,
                                                size: 18,
                                              ).paddingOnly(left: 6, right: 12, top: 8, bottom: 8).onTap(() {
                                                if (!shopStore.isLoading) {
                                                  int newQuantity = cartItem.quantity.validate() + 1;
                                                  log("sale price------------------${cartItem.prices!.salePrice.validate().toDouble()}");
                                                  double singleItemPrice = cartItem.prices!.salePrice.validate().toDouble();

                                                  // Update UI immediately
                                                  runInAction(() {
                                                    cartItem.quantity = newQuantity;
                                                    cartItem.isQuantityChanged = true;
                                                    cartScreenVars.total = cartScreenVars.total + singleItemPrice.toInt();
                                                    cartItem.prices!.price = (singleItemPrice * newQuantity).toString();
                                                  });

                                                  // Update backend
                                                  updateCartItem(productKey: cartItem.key.validate(), quantity: newQuantity).then((_) {
                                                    toast(language.quantityUpdatedSuccessfully);
                                                  }).catchError((e) {
                                                    // Revert the quantity and price if API call fails
                                                    runInAction(() {
                                                      cartItem.quantity = newQuantity - 1;
                                                      cartItem.isQuantityChanged = true;
                                                      cartScreenVars.total = cartScreenVars.total - singleItemPrice.toInt();
                                                      cartItem.prices!.price = (singleItemPrice * (newQuantity - 1)).toString();
                                                    });
                                                    toast(e.toString(), print: true);
                                                  });
                                                }
                                              }),
                                            ],
                                          ),
                                        ],
                                      ).onTap(() {
                                        ProductDetailScreen(id: cartItem.id.validate()).launch(context);
                                      }, splashColor: Colors.transparent, highlightColor: Colors.transparent).expand(),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ).visible(cartScreenVars.cartItemList.isNotEmpty);
                      }),
                      8.height,
                      if (cartScreenVars.cart != null && cartScreenVars.cart!.coupons.validate().isEmpty)
                        ListTile(
                          onTap: () async {
                            ///open model sheet for list of coupons
                            final couponCode = await showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.transparent,
                                builder: (_) {
                                  return CouponListScreen();
                                });

                            if (couponCode != null && couponCode.isNotEmpty) {
                              couponController.text = couponCode; // 👈 paste into TextField
                            }
                          },
                          title: Text(language.coupons, style: boldTextStyle()),
                          trailing: Icon(Icons.arrow_forward_ios, color: appStore.isDarkMode ? bodyDark : bodyWhite, size: 14),
                        ),
                      if (cartScreenVars.cart != null && cartScreenVars.cart!.coupons.validate().isNotEmpty)
                        CartCouponsComponent(
                          couponsList: cartScreenVars.cart!.coupons.validate(),
                          onCouponRemoved: (value) {
                            cartScreenVars.cart = value;
                            cartScreenVars.total = value.totals!.totalPrice.validate().toInt();
                          },
                        ),
                      if (cartScreenVars.cart != null && cartScreenVars.cart!.coupons.validate().isEmpty)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: context.width() / 2 - 32,
                              child: TextField(
                                enabled: !shopStore.isLoading,
                                controller: couponController,
                                keyboardType: TextInputType.name,
                                textInputAction: TextInputAction.done,
                                maxLines: 1,
                                decoration: inputDecorationFilled(
                                  context,
                                  label: language.couponCode,
                                  contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                                  fillColor: context.cardColor,
                                ),
                                onSubmitted: (text) async {
                                  await applyCouponToCart();
                                },
                              ),
                            ),
                            TextButton(
                              child: Text(language.applyCoupon, style: primaryTextStyle(color: context.primaryColor)),
                              onPressed: () async {
                                await applyCouponToCart();
                              },
                            ).expand(),
                          ],
                        ).paddingSymmetric(horizontal: 16),
                      if (cartScreenVars.cart != null) ...[
                        Observer(builder: (_) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(language.priceDetails, style: boldTextStyle()),
                              Container(
                                padding: EdgeInsets.all(16),
                                margin: EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(color: context.cardColor, borderRadius: radius(defaultRadius)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(language.subTotal, style: secondaryTextStyle(size: 16)),
                                        PriceWidget(price: getPrice((cartScreenVars.total + cartScreenVars.cart!.totals!.totalDiscount.validate().toInt()).toString()), size: 16),
                                      ],
                                    ),
                                    8.height,
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          language.discount,
                                          style: secondaryTextStyle(size: 16),
                                        ),
                                        Text(
                                          '-${cartScreenVars.cart!.totals!.currencySymbol}${getPrice(cartScreenVars.cart!.totals!.totalDiscount.validate())}',
                                          style: primaryTextStyle(color: appStore.isDarkMode ? Colors.green : Colors.green),
                                        ),
                                      ],
                                    ),
                                    8.height,
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(language.totalAmount, style: secondaryTextStyle(size: 16)),
                                        PriceWidget(price: getPrice(cartScreenVars.total.toString()), size: 16),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ).paddingAll(16).visible(cartScreenVars.cart != null);
                        }),
                        cartScreenVars.cart!.items.validate().isNotEmpty
                            ? AppButton(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                                shapeBorder: RoundedRectangleBorder(borderRadius: radius(commonRadius)),
                                text: language.lblContinue,
                                textStyle: boldTextStyle(color: Colors.white),
                                elevation: 0,
                                color: context.primaryColor,
                                width: context.width() - 32,
                                onTap: () async {
                                  if (!shopStore.isLoading)
                                    ifNotTester(() async {
                                      await Future.forEach<CartItemModel>(cartScreenVars.cart!.items.validate(), (element) async {
                                        if (element.isQuantityChanged.validate()) {
                                          shopStore.setLoading(true);
                                          await updateCartItem(productKey: element.key.validate(), quantity: element.quantity.validate()).then((value) async {
                                            await getCart();
                                          }).catchError((e) {
                                            shopStore.setLoading(false);
                                            log(e.toString());
                                          });
                                        }
                                      }).then((value) {
        toast('Checkout temporarily disabled');
        return;  // Skip checkout
        // await getCart(showLoader: true);
        // }
        });
                                      });
                                    });
                                },
                              ).center()
                            : Offstage(),
                        16.height,

                        ///Related products List
                        Text(language.relatedProducts, style: boldTextStyle(size: 18)).paddingSymmetric(horizontal: 16).visible(shopStore.productList.isNotEmpty),
                        16.height,
                        Observer(builder: (context) {
                          return HorizontalList(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            spacing: 16,
                            runSpacing: 16,
                            itemCount: shopStore.productList.length,
                            itemBuilder: (context, index) {
                              return SizedBox(
                                width: context.width() / 2 - 24,
                                child: ProductCardComponent(
                                  product: shopStore.productList[index],
                                ),
                              );
                            },
                          );
                        }),

                        if (shopStore.recentlyViewedProductList.length > 0)

                          ///Recently Viewed Products List
                          Observer(builder: (_) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                16.height,
                                Text(language.recentlyViewedProducts, style: boldTextStyle(size: 18)).paddingSymmetric(horizontal: 16),
                                16.height,
                                HorizontalList(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  spacing: 16,
                                  runSpacing: 16,
                                  itemCount: shopStore.recentlyViewedProductList.length,
                                  itemBuilder: (context, index) {
                                    final product = convertToRecentlyViewed(shopStore.recentlyViewedProductList[index]);
                                    return SizedBox(
                                      width: context.width() / 2 - 24,
                                      child: ProductCardComponent(
                                        product: product,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            );
                          })
                      ],
                    ],
                  ),
                ).visible(!cartScreenVars.isError && !shopStore.isLoading && cartScreenVars.cartItemList.isNotEmpty),
              ],
            ),
          ),
        ),
      );
    });
  }
}
