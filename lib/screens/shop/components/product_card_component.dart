import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/woo_commerce/product_detail_model.dart';
import 'package:socialv/models/woo_commerce/product_list_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/shop/components/price_widget.dart';
import 'package:socialv/screens/shop/screens/cart_screen.dart';
import 'package:socialv/screens/shop/screens/product_detail_screen.dart';
import 'package:socialv/store/shop_store.dart';
import 'package:socialv/utils/app_constants.dart';
import 'package:socialv/utils/cached_network_image.dart';

import '../../../models/woo_commerce/wishlist_model.dart';

class ProductCardComponent extends StatefulWidget {
  final ProductListModel product;
  final VoidCallback? refresh;

   ProductCardComponent({required this.product, this.refresh});

  @override
  State<ProductCardComponent> createState() => _ProductCardComponentState();
}

class _ProductCardComponentState extends State<ProductCardComponent> {
  ShopStore productCardComponentVars = ShopStore();
  late ProductListModel product;
  bool isWishListed = false;
  List<WishlistModel> orderList = [];

  @override
  void initState() {
    product = widget.product;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        ProductDetailScreen(id: product.id.validate()).launch(context);
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(color: context.cardColor, borderRadius: radius(defaultAppButtonRadius)),
        width: context.width() / 2 - 24,
        child: Column(
          children: [
            Stack(
              children: [
                cachedImage(
                  product.images.validate().isNotEmpty ? product.images.validate().first.src : AppImages.profileBackgroundImage,
                  height: 150,
                  width: context.width() / 2 - 24,
                  fit: BoxFit.cover,
                ).cornerRadiusWithClipRRectOnly(topRight: defaultAppButtonRadius.toInt(), topLeft: defaultAppButtonRadius.toInt()),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(color: context.primaryColor, borderRadius: radiusOnly(topLeft: defaultAppButtonRadius, bottomRight: 4)),
                  child: Text(language.sale, style: secondaryTextStyle(size: 10, color: Colors.white)),
                ).visible(product.onSale.validate()),
              ],
            ),
            16.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Marquee(
                      child: Text(
                        product.name.validate().capitalizeFirstLetter(),
                        style: boldTextStyle(),
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis, // fallback in case Marquee is off
                        maxLines: 1,
                      ),
                    ),
                  ),
                ),
                if (product.averageRating != null && product.averageRating.validate().toString() != "0.00")
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: Colors.yellow, size: 14),
                      4.width,
                          Text(
                        product.averageRating.validate().toString(),
                        style: boldTextStyle(size: 12),
                      ),
                    ],
                  ),
              ],
            ),
            4.height,
            if(product.type!="grouped")
              Align(
                alignment: Alignment.centerLeft,
                child: PriceWidget(
                  price: product.price,
                  priceHtml: product.priceHtml,
                  salePrice: product.salePrice,
                  regularPrice: product.regularPrice,
                  showDiscountPercentage: true,
                ),
              ),
            if(product.type=="grouped")
              Align(

                alignment: Alignment.centerLeft,
                child: PriceWidget(
                  price: "",
                  priceHtml: "",
                  salePrice: "",
                  regularPrice: "",
                ),
              ),

            8.height,
            if (product.stockStatus == "instock")
              Observer(builder: (context) {
                return !productCardComponentVars.isLoading
                    ? product.type=="grouped"?
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: Size(context.width() / 2 - 24, 40),
                      backgroundColor: appStore.isDarkMode ? appColorPrimary : appColorPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  onPressed: () {
                    ProductDetailScreen(id: product.id.validate()).launch(context);
                  },
                  child: Text( language.viewProduct, style: secondaryTextStyle(color: Colors.white, weight: FontWeight.w800)),
                ):
                 product.type != ProductTypes.variable?ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: Size(context.width() / 2 - 24, 40),
                      backgroundColor: appStore.isDarkMode ? appColorPrimary : appColorPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  onPressed: () {
                    productCardComponentVars.isLoading = true;
                    shopStore.cartItemIndexList.contains(product.id)
                        ? CartScreen().launch(context).then((value) {
                          widget.refresh!.call();
                      productCardComponentVars.isLoading = false;
                    })
                        : addItemToCart(productId: product.id.validate(), quantity: 1).then((value) {
                      shopStore.cartItemIndexList.add(product.id);
                      toast(language.successfullyAddedToCart);
                      appStore.setCartCount((getIntAsync(SharePreferencesKey.cartCount, defaultValue: 0) + 1));
                      productCardComponentVars.isLoading = false;
                    }).catchError((e) {
                      productCardComponentVars.isLoading = false;
                      log(e.toString());
                    });
                  },
                  child: Text(shopStore.cartItemIndexList.contains(product.id) ? language.goToCart : language.addToCart, style: secondaryTextStyle(color: Colors.white, weight: FontWeight.w800)),
                ):ElevatedButton(
                   style: ElevatedButton.styleFrom(
                       minimumSize: Size(context.width() / 2 - 24, 40),
                       backgroundColor: appStore.isDarkMode ? appColorPrimary : appColorPrimary,
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                   onPressed: () {
                     ProductDetailScreen(id: product.id.validate()).launch(context);
                   },
                   child: Text( language.viewProduct, style: secondaryTextStyle(color: Colors.white, weight: FontWeight.w800)),
                 )
                    : ThreeBounceLoadingWidget();
              })
            else
              AbsorbPointer(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: Size(context.width() / 2 - 24, 40),
                      backgroundColor: appStore.isDarkMode ? scaffoldDarkColor : context.cardColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  onPressed: () {},
                  child: Text(
                    language.outOfStock,
                    style: secondaryTextStyle(color: Colors.red, weight: FontWeight.w800),
                  ),
                ),
              ),
            8.height,
          ],
        ),
      ),
    );
  }
}

class RelatedProductCardComponent extends StatefulWidget {
  final RelatedProductModel product;

  const RelatedProductCardComponent({required this.product});

  @override
  State<RelatedProductCardComponent> createState() => _RelatedProductCardComponentState();
}

class _RelatedProductCardComponentState extends State<RelatedProductCardComponent> {
  late RelatedProductModel product;
  ShopStore relatedProductCardComponentVars = ShopStore();

  @override
  void initState() {
    product = widget.product;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        ProductDetailScreen(id: product.id.validate()).launch(context);
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(color: context.cardColor, borderRadius: radius(defaultAppButtonRadius)),
        width: context.width() / 2 - 24,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                cachedImage(
                  product.images!.first.src,
                  height: 150,
                  width: context.width() / 2 - 24,
                  fit: BoxFit.cover,
                ).cornerRadiusWithClipRRectOnly(topRight: defaultAppButtonRadius.toInt(), topLeft: defaultAppButtonRadius.toInt()),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(color: context.primaryColor, borderRadius: radiusOnly(topLeft: defaultAppButtonRadius, bottomRight: defaultAppButtonRadius)),
                  child: Text(language.sale, style: secondaryTextStyle(size: 10, color: Colors.white)),
                ).visible(product.salePrice.validate().isNotEmpty),
              ],
            ),
            14.height,
            Text(product.name.validate().capitalizeFirstLetter(), style: boldTextStyle(size: 14)).paddingSymmetric(horizontal: 10),
            4.height,
            PriceWidget(
              price: product.price,
              salePrice: product.salePrice,
              regularPrice: product.regularPrice,
              showDiscountPercentage: false,
            ).paddingSymmetric(horizontal: 10),
            14.height,
            if (product.stockStatus == "instock")
              Observer(builder: (context) {
                return !relatedProductCardComponentVars.isLoading
                    ? ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            minimumSize: Size(context.width() / 2 - 24, 40),
                            backgroundColor: appStore.isDarkMode ? appColorPrimary : appColorPrimary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        onPressed: () {
                          relatedProductCardComponentVars.isLoading = true;
                          shopStore.cartItemIndexList.contains(product.id)
                              ? CartScreen().launch(context).then((value) {
                                  relatedProductCardComponentVars.isLoading = false;
                                })
                              : addItemToCart(productId: product.id.validate(), quantity: 1).then((value) {
                                  shopStore.cartItemIndexList.add(product.id);
                                  toast(language.successfullyAddedToCart);
                                  appStore.setCartCount((getIntAsync(SharePreferencesKey.cartCount, defaultValue: 0) + 1));
                                  relatedProductCardComponentVars.isLoading = false;
                                }).catchError((e) {
                                  relatedProductCardComponentVars.isLoading = false;
                                  log(e.toString());
                                });
                        },
                        child: Text(shopStore.cartItemIndexList.contains(product.id) ? language.goToCart : language.addToCart, style: secondaryTextStyle(color: Colors.white, weight: FontWeight.w800)),
                      )
                    : ThreeBounceLoadingWidget();
              })
            else
              AbsorbPointer(
                  child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    minimumSize: Size(context.width() / 2 - 24, 40),
                    backgroundColor: appStore.isDarkMode ? scaffoldDarkColor : context.cardColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                onPressed: () {},
                child: Text(
                  language.outOfStock,
                  style: secondaryTextStyle(color: Colors.red, weight: FontWeight.w800),
                ),
              )),
            8.height,
          ],
        ),
      ),
    );
  }
}
