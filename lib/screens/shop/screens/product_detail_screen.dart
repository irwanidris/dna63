import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/woo_commerce/common_models.dart';
import 'package:socialv/models/woo_commerce/product_detail_model.dart';
import 'package:socialv/models/woo_commerce/variation_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/shop/components/price_widget.dart';
import 'package:socialv/screens/shop/components/product_card_component.dart';
import 'package:socialv/screens/shop/components/product_review_component.dart';
import 'package:socialv/screens/shop/screens/cart_screen.dart';
import 'package:socialv/screens/shop/screens/shop_screen.dart';
import 'package:socialv/store/shop_store.dart';
import 'package:socialv/utils/cached_network_image.dart';

import '../../../utils/app_constants.dart';

class ProductDetailScreen extends StatefulWidget {
  final int id;

  const ProductDetailScreen({required this.id});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

ProductDetailModel product = ProductDetailModel();
ProductDetailModel mainProduct = ProductDetailModel();

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  ShopStore productDetailsVars = ShopStore();
  Map<int, int> groupProductCounts = {};

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    afterBuildCreated(() {
      setStatusBarColor(Colors.transparent);
    });

    appStore.setLoading(true);

    await getProductDetail(productId: widget.id.validate()).then((value) {
      productDetailsVars.isFetched = true;
      productDetailsVars.isWishListed = value.first.isAddedWishlist.validate();

      value.forEach((element) {
        int index = value.indexOf(element);

        if (index == 0) {
          product = value.first;
          if (value.first.type == ProductTypes.variable) {
            value.first.attributes!.forEach((attribute) {
              attribute.options!.insert(0, '${language.chooseAnOption}');
            });
            mainProduct = value.first;
          }
        } else {
          productDetailsVars.groupProductList.add(GroupProductModel(id: element.id.validate(), product: element));
          productDetailsVars.groupProductList.forEach((e) {
            groupProductCounts[e.id] = 0; // start with 0
          });
        }
      });
      productDetailsVars.isError = false;
      appStore.setLoading(false);
    }).catchError((e) {
      log('Error: ${e.toString()}');
      productDetailsVars.isError = true;
      appStore.setLoading(false);
    });
  }

  @override
  void dispose() {
    appStore.setLoading(false);
    mainProduct.attributes?.forEach((element) {
      element.options?.clear();
    });

    productDetailsVars.pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SafeArea(
          child: Observer(
            builder: (_) {
              if (productDetailsVars.isFetched) {
                return Stack(
                  children: [
                    NestedScrollView(
                      headerSliverBuilder: ((BuildContext context, bool innerBoxIsScrolled) {
                        return <Widget>[
                          SliverAppBar(
                            expandedHeight: context.height() * 0.5,
                            pinned: true,
                            flexibleSpace: FlexibleSpaceBar(
                              background: SizedBox(
                                height: context.height() * 0.5,
                                width: context.width(),
                                child: Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    PageView.builder(
                                      controller: productDetailsVars.pageController,
                                      itemCount: product.images.validate().length,
                                      itemBuilder: (BuildContext context, int index) {
                                        return cachedImage(
                                          product.images![index].src.validate(),
                                          height: context.height() * 0.5,
                                          width: context.width(),
                                          fit: BoxFit.cover,
                                        );
                                      },
                                    ),
                                    Positioned(
                                      top: 76,
                                      right: 16,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                        decoration: BoxDecoration(color: context.primaryColor, borderRadius: radius(4)),
                                        child: Text(language.sale, style: secondaryTextStyle(size: 10, color: Colors.white)),
                                      ).visible(product.onSale.validate()),
                                    ),
                                    Positioned(
                                      bottom: 8,
                                      child: DotIndicator(
                                        indicatorColor: context.primaryColor,
                                        pageController: productDetailsVars.pageController,
                                        pages: product.images.validate(),
                                      ),
                                    ).visible(product.images.validate().length > 1),
                                  ],
                                ),
                              ),
                              collapseMode: CollapseMode.parallax,
                            ),
                            backgroundColor: context.scaffoldBackgroundColor,
                            leading: BackButton(
                              color: context.iconColor,
                              onPressed: () async {
                                finish(context);
                              },
                            ),
                            title: Text(product.name.validate().capitalizeFirstLetter(), style: boldTextStyle(size: 22)).visible(innerBoxIsScrolled),
                            actions: [
                              Stack(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      CartScreen().launch(context);
                                    },
                                    icon: Image.asset(ic_cart, width: 24, height: 24, color: context.primaryColor, fit: BoxFit.cover),
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
                                        child: Text(appStore.cartCount.toString(), style: secondaryTextStyle(color: Colors.white, size: 10)),
                                      ),
                                    ).visible(appStore.cartCount > 0),
                                  )
                                ],
                              ).visible(innerBoxIsScrolled),
                            ],
                          ),
                        ];
                      }),
                      body: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product.name.validate().capitalizeFirstLetter(), style: boldTextStyle(size: 20)).paddingSymmetric(horizontal: 16, vertical: 8),
                            PriceWidget(
                              price: product.price,
                              priceHtml: product.priceHtml,
                              salePrice: product.salePrice,
                              regularPrice: product.regularPrice,
                              showDiscountPercentage: true,
                              size: 16,
                            ).paddingSymmetric(horizontal: 16),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                RatingBarWidget(
                                  onRatingChanged: (rating) {},
                                  activeColor: Colors.amber,
                                  inActiveColor: Colors.amber,
                                  rating: product.averageRating.validate().toDouble(),
                                  size: 18,
                                  disable: true,
                                ),
                                16.width,
                                Text('(${product.ratingCount} ${language.reviews.toLowerCase()})', style: secondaryTextStyle(color: context.primaryColor)),
                              ],
                            ).paddingOnly(left: 16, right: 16, top: 8).visible(product.averageRating.validate().toDouble() != 0.0),
                            16.height,
                            if (product.shortDescription.validate().isNotEmpty) Text(parseHtmlString(product.shortDescription), style: secondaryTextStyle()).paddingSymmetric(horizontal: 16),
                            if (mainProduct.type == ProductTypes.variable)
                              Column(
                                children: mainProduct.attributes.validate().map((e) {
                                  if (e.options.validate().isEmpty) return Offstage();
                                  return Row(
                                    children: [
                                      Text(e.name.validate(), style: boldTextStyle()),
                                      Container(
                                        height: 40,
                                        decoration: BoxDecoration(color: context.cardColor, borderRadius: radius(commonRadius)),
                                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        child: Observer(builder: (context) {
                                          return DropdownButtonHideUnderline(
                                            child: ButtonTheme(
                                              alignedDropdown: true,
                                              child: DropdownButton<String>(
                                                borderRadius: BorderRadius.circular(commonRadius),
                                                icon: Icon(Icons.arrow_drop_down, color: appStore.isDarkMode ? bodyDark : bodyWhite),
                                                elevation: 8,
                                                value: e.dropDownValue,
                                                style: primaryTextStyle(),
                                                underline: Container(height: 2, color: appColorPrimary),
                                                onChanged: (String? newValue) {
                                                  e.dropDownValue = newValue!;
                                                  if (newValue == 'Choose an option') {
                                                    product = mainProduct;
                                                  } else {
                                                    productDetailsVars.groupProductList.forEach((element) {
                                                      log('element: $element');

                                                      element.product.attributes.validate().forEach((attribute) {
                                                        if (attribute.optionString == newValue) {
                                                          product = element.product;
                                                        }
                                                      });
                                                    });
                                                  }
                                                },
                                                hint: Text(language.chooseAnOption, style: secondaryTextStyle()),
                                                items: e.options.validate().map<DropdownMenuItem<String>>((String value) {
                                                  return DropdownMenuItem<String>(
                                                    value: value,
                                                    child: Text(value, style: primaryTextStyle()),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                          );
                                        }),
                                      ).expand(),
                                    ],
                                  );
                                }).toList(),
                              ).paddingSymmetric(horizontal: 16),
                            if (product.type.validate() != ProductTypes.grouped)
                              Row(
                                children: [
                                  Text('${language.qty}: ', style: primaryTextStyle(color: appStore.isDarkMode ? bodyDark : bodyWhite, size: 12)),
                                  Icon(
                                    Icons.remove,
                                    color: appStore.isDarkMode ? bodyDark : bodyWhite,
                                    size: 18,
                                  ).paddingOnly(left: 8, right: 6, top: 8, bottom: 8).onTap(() {
                                    if (productDetailsVars.count > 1) {
                                      productDetailsVars.count = productDetailsVars.count - 1;
                                    }
                                  }, splashColor: Colors.transparent, highlightColor: Colors.transparent),
                                  Observer(builder: (context) {
                                    return Container(
                                      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                                      margin: EdgeInsets.only(top: 8, bottom: 8),
                                      decoration: BoxDecoration(borderRadius: radius(4), border: Border.all(color: appStore.isDarkMode ? bodyDark : bodyWhite)),
                                      child: Text(productDetailsVars.count.toString(), style: primaryTextStyle(color: appStore.isDarkMode ? bodyDark : bodyWhite, size: 12)),
                                    );
                                  }),
                                  Icon(
                                    Icons.add,
                                    color: appStore.isDarkMode ? bodyDark : bodyWhite,
                                    size: 18,
                                  ).paddingOnly(left: 6, right: 12, top: 8, bottom: 8).onTap(() {
                                    productDetailsVars.count = productDetailsVars.count + 1;
                                  }, splashColor: Colors.transparent, highlightColor: Colors.transparent),
                                ],
                              ).paddingSymmetric(horizontal: 16),
                            RichText(
                              text: TextSpan(
                                text: '${language.sku}:',
                                style: boldTextStyle(color: appStore.isDarkMode ? bodyDark : bodyWhite, size: 14),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: ' ${product.sku}',
                                    style: primaryTextStyle(color: appStore.isDarkMode ? bodyDark : bodyWhite),
                                  ),
                                ],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ).paddingOnly(top: 16, left: 16, right: 16),
                            if (product.categories.validate().isNotEmpty)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${language.category}: ', style: boldTextStyle(color: appStore.isDarkMode ? bodyDark : bodyWhite, size: 14)),
                                  Wrap(
                                          children: product.categories!.map((e) {
                                    return Text(e.name.validate(), style: primaryTextStyle(color: context.primaryColor, size: 14)).onTap(() {
                                      ShopScreen(categoryName: e.name, categoryId: e.id).launch(context);
                                    });
                                  }).toList())
                                      .expand(),
                                ],
                              ).paddingSymmetric(horizontal: 16),
                            16.height,
                            if (productDetailsVars.groupProductList.validate().isNotEmpty && product.type == ProductTypes.grouped)
                              Column(
                                children: productDetailsVars.groupProductList.map((e) {
                                  int count = groupProductCounts[e.id] ?? 0;

                                  return Container(
                                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: context.cardColor,
                                      borderRadius: radius(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        /// Product Thumbnail
                                        cachedImage(
                                          e.product.images!.first.src.validate(),
                                          height: 60,
                                          width: 60,
                                          fit: BoxFit.cover,
                                        ).cornerRadiusWithClipRRect(8),

                                        12.width,

                                        /// Name + Price Column
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                e.product.name.validate(),
                                                style: boldTextStyle(size: 14),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              4.height,
                                              PriceWidget(
                                                price: e.product.price,
                                                priceHtml: e.product.priceHtml,
                                                salePrice: e.product.salePrice,
                                                regularPrice: e.product.regularPrice,
                                                showDiscountPercentage: false,
                                                showRegularPrice: true,
                                              ),
                                            ],
                                          ),
                                        ),

                                        /// Counter Section
                                        Row(
                                          children: [
                                            /// Remove Button
                                            IconButton(
                                              icon: Icon(Icons.remove_circle_outline, color: textSecondaryColor),
                                              onPressed: () {
                                                if (count > 0) {
                                                  groupProductCounts[e.id] = count - 1;
                                                  setState(() {});
                                                }
                                              },
                                            ),

                                            /// Count Display
                                            Container(
                                              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                                              decoration: BoxDecoration(
                                                color: context.scaffoldBackgroundColor,
                                                borderRadius: radius(6),
                                                border: Border.all(color: context.dividerColor),
                                              ),
                                              child: Text(
                                                count.toString(),
                                                style: boldTextStyle(size: 14),
                                              ),
                                            ),

                                            /// Add Button
                                            IconButton(
                                              icon: Icon(Icons.add_circle_outline, color: textSecondaryColor),
                                              onPressed: () {
                                                groupProductCounts[e.id] = count + 1;
                                                setState(() {});
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ).onTap(() {
                                    ProductDetailScreen(id: e.id).launch(context);
                                  }, splashColor: Colors.transparent, highlightColor: Colors.transparent);
                                }).toList(),
                              ),
                            if (parseHtmlString(product.description).isNotEmpty)
                              Column(
                                children: [
                                  24.height,
                                  Text(language.description, style: boldTextStyle()).paddingSymmetric(horizontal: 16),
                                  16.height,
                                  ReadMoreText(
                                    parseHtmlString(product.description),
                                    style: secondaryTextStyle(),
                                    trimLines: 5,
                                    textAlign: TextAlign.start,
                                  ).paddingSymmetric(horizontal: 16),
                                ],
                              ),
                            16.height,
                            if (product.attributes.validate().isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(language.additionalInformation, style: boldTextStyle()).paddingSymmetric(horizontal: 16),
                                  Table(
                                    columnWidths: {
                                      0: FractionColumnWidth(0.3),
                                      1: FractionColumnWidth(0.7),
                                    },
                                    border: TableBorder.all(
                                      color: appStore.isDarkMode ? bodyDark.withValues(alpha: 0.2) : bodyWhite.withValues(alpha: 0.2),
                                      style: BorderStyle.solid,
                                      width: 2,
                                    ),
                                    children: product.attributes.validate().map((e) {
                                      return TableRow(
                                        children: [
                                          Text(
                                            e.name.validate(),
                                            style: boldTextStyle(color: appStore.isDarkMode ? bodyDark : bodyWhite, size: 14),
                                            textAlign: TextAlign.center,
                                          ).paddingSymmetric(vertical: 8),
                                          product.type == ProductTypes.variation
                                              ? Text(e.optionString.validate(), style: primaryTextStyle(color: appStore.isDarkMode ? bodyDark : bodyWhite)).paddingAll(8)
                                              : Wrap(
                                                  children: e.options.validate().map((option) {
                                                    if (option != 'Choose an option') {
                                                      return Text(
                                                        option.validate(),
                                                        style: primaryTextStyle(color: appStore.isDarkMode ? bodyDark : bodyWhite),
                                                      ).paddingAll(8);
                                                    } else {
                                                      return Offstage();
                                                    }
                                                  }).toList(),
                                                ),
                                        ],
                                      );
                                    }).toList(),
                                  ).paddingAll(16),
                                  8.height,
                                ],
                              ),
                            ProductReviewComponent(productId: widget.id),
                            if (product.relatedIds.validate().isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  16.height,
                                  Text(language.relatedProducts, style: boldTextStyle(size: 18)).paddingSymmetric(horizontal: 18),
                                  8.height,
                                  ThreeBounceLoadingWidget().paddingSymmetric(vertical: 16).visible(productDetailsVars.isLoading),
                                  HorizontalList(
                                    padding: EdgeInsets.all(16),
                                    spacing: 16,
                                    itemCount: product.relatedProductList!.length,
                                    itemBuilder: (ctx, index) {
                                      return RelatedProductCardComponent(product: product.relatedProductList![index]);
                                    },
                                  ).visible(!productDetailsVars.isLoading),
                                ],
                              ),
                            32.height,
                          ],
                        ),
                      ),
                    ),
                    LoadingWidget().center().visible(appStore.isLoading),
                  ],
                );
              } else if (productDetailsVars.isError) {
                return NoDataWidget(
                  imageWidget: NoDataLottieWidget(),
                  title: productDetailsVars.isError ? language.somethingWentWrong : language.noDataFound,
                ).center();
              } else {
                return LoadingWidget().center();
              }
            },
          ),
        ),
        bottomNavigationBar: Observer(builder: (context) {
          return productDetailsVars.isFetched /*&& product.type != ProductTypes.variable*/
              ? Observer(builder: (context) {
                  return Container(
                    color: context.cardColor,
                    padding: EdgeInsets.only(left: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            if (productDetailsVars.isWishListed) {
                              productDetailsVars.isWishListed = !productDetailsVars.isWishListed;

                              removeFromWishlist(productId: product.id.validate()).then((value) {
                                toast(value.message);
                              }).catchError((e) {
                                productDetailsVars.isWishListed = true;
                                log(e.toString());
                              });
                            } else {
                              productDetailsVars.isWishListed = !productDetailsVars.isWishListed;
                              addToWishlist(productId: product.id.validate()).then((value) {
                                toast(value.message);
                              }).catchError((e) {
                                productDetailsVars.isWishListed = false;
                                log(e.toString());
                              });
                            }
                          },
                          icon: Image.asset(
                            productDetailsVars.isWishListed ? ic_heart_filled : ic_heart,
                            height: 22,
                            width: 22,
                            color: context.primaryColor,
                            fit: BoxFit.fill,
                          ),
                        ),
                        16.width.visible(product.type != ProductTypes.grouped),
                        Observer(builder: (context) {
                          return AppButton(
                            shapeBorder: RoundedRectangleBorder(borderRadius: radius(0)),
                            child: Observer(builder: (context) {
                              return TextIcon(
                                text: shopStore.cartItemIndexList.contains(product.id)
                                    ? language.goToCart
                                    : (product.type != ProductTypes.variable && product.type != ProductTypes.grouped && product.purchasable.validate() && product.inStock.validate())
                                        ? language.addToCart
                                        : language.outOfStock,
                                textStyle: boldTextStyle(
                                    color: (product.type != ProductTypes.variable && product.type != ProductTypes.grouped && product.purchasable.validate()) ? Colors.white : Colors.white),
                              );
                            }),
                            padding: EdgeInsets.symmetric(vertical: 8),
                            onTap: () async {
                              if ((product.type != ProductTypes.variable && product.type != ProductTypes.grouped && product.purchasable.validate() && product.inStock.validate())) {
                                if (product.isAddedCart.validate()) {
                                  CartScreen().launch(context);
                                } else {
                                  if (product.inStock.validate()) {
                                    appStore.setLoading(true);
                                    Map? request;
                                    if (product.type.validate() == ProductTypes.variation) {
                                      List<VariationModel> variations = [];
                                      mainProduct.attributes.validate().forEach((element) {
                                        variations.add(VariationModel(attribute: element.name, value: element.dropDownValue));
                                      });

                                      request = {"id": product.id.validate(), "quantity": productDetailsVars.count, "variation": variations};
                                    }
                                    shopStore.cartItemIndexList.contains(product.id)
                                        ? CartScreen().launch(context)
                                        : addItemToCart(productId: product.id.validate(), quantity: productDetailsVars.count, req: request).then((value) {
                                            toast(language.successfullyAddedToCart);
                                            shopStore.cartItemIndexList.add(product.id);
                                            productDetailsVars.buttonName = language.goToCart;
                                            appStore.setLoading(false);
                                            product.isAddedCart = true;
                                          }).catchError((e) {
                                            appStore.setLoading(false);
                                            toast(e.toString(), print: true);
                                          });
                                  }
                                }
                              } else {
                                toast("Product is out of stock");
                              }
                            },
                            elevation: 0,
                            color: (product.type != ProductTypes.variable && product.type != ProductTypes.grouped && product.purchasable.validate() && product.inStock.validate())
                                ? context.primaryColor
                                : Colors.red,
                          ).expand().visible(product.type != ProductTypes.grouped);
                        }),
                        Observer(builder: (context) {
                          return AppButton(
                                  shapeBorder: RoundedRectangleBorder(borderRadius: radius(0)),
                                  child: Observer(builder: (context) {
                                    return TextIcon(
                                        text: language.addToCart,
                                        textStyle: boldTextStyle(
                                          color: Colors.white,
                                        ));
                                  }),
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  onTap: () async {
                                    if (product.inStock.validate()) {
                                      appStore.setLoading(true);

                                      try {
                                        for (var entry in groupProductCounts.entries) {
                                          int id = entry.key;
                                          int count = entry.value;

                                          if (count > 0) {
                                            Map request = {
                                              "id": id,
                                              "quantity": count,
                                            };

                                            await addItemToCart(
                                              productId: id,
                                              quantity: count,
                                              req: request,
                                            );

                                            shopStore.cartItemIndexList.add(id);
                                          }
                                        }

                                        toast(language.successfullyAddedToCart);
                                        productDetailsVars.buttonName = language.goToCart;
                                        product.isAddedCart = true;

                                        if (context.mounted) Navigator.pop(context);
                                      } catch (e) {
                                        toast(e.toString(), print: true);
                                      } finally {
                                        appStore.setLoading(false);
                                      }
                                    }
                                  },
                                  elevation: 0,
                                  color: context.primaryColor)
                              .expand()
                              .visible(product.type == ProductTypes.grouped);
                        }),
                      ],
                    ),
                  );
                })
              : Offstage();
        }),
      ),
    );
  }
}
