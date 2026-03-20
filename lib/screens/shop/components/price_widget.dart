import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/utils/app_constants.dart';

import '../../../main.dart';

class PriceWidget extends StatelessWidget {
  final String? salePrice;
  final String? regularPrice;
  final String? priceHtml;
  final String? price;
  final bool showDiscountPercentage;
  final bool showRegularPrice;
  final int? size;
  final int? offSize;

  const PriceWidget({
    Key? key,
    this.salePrice,
    this.regularPrice,
    this.priceHtml,
    this.price,
    this.showDiscountPercentage = false,
    this.showRegularPrice = true,
    this.size,
    this.offSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (salePrice.validate().isNotEmpty && regularPrice.validate().isNotEmpty) {
      if (salePrice.validate() != regularPrice.validate()) {
        int discount = (((regularPrice.toInt() - salePrice.toInt()) / regularPrice.toInt()) * 100).round();

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  '${appStore.wooCurrency}${regularPrice.validate()}',
                  style: secondaryTextStyle(
                    decoration: TextDecoration.lineThrough,
                    fontFamily: fontFamily,
                    size: size ?? 12,
                  ),
                ).visible(showRegularPrice),
                4.width,
                Text(
                  '${appStore.wooCurrency}${salePrice.validate()}',
                  style: boldTextStyle(
                    color: appStore.isDarkMode ? bodyDark : null,
                    decoration: TextDecoration.none,
                    size: size ?? 12,
                  ),
                ),
              ],
            ),
            Text(
              "$discount% ${language.off}",
              style: boldTextStyle(
                color: Colors.green,
                size: offSize ?? 12,
              ),
            ).visible(showDiscountPercentage),
          ],
        );
      } else {
        return Text(
          '${appStore.wooCurrency}${price.validate()}',
          style: boldTextStyle(
            decoration: TextDecoration.none,
            color: appStore.isDarkMode ? bodyDark : null,
            size: size ?? 12,
          ),
        );
      }
    } else if (priceHtml != null ? parseHtmlString(priceHtml).contains('–') : false) {
      return Text(
        parseHtmlString(priceHtml),
        style: boldTextStyle(
          color: appStore.isDarkMode ? bodyDark : null,
          size: size ?? 14,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    } else if (price != "") {
      return Text(
        '${appStore.wooCurrency}${price.validate()}',
        style: boldTextStyle(
          decoration: TextDecoration.none,
          color: appStore.isDarkMode ? bodyDark : null,
          size: size ?? 14,
        ),
      );

    }
    else
      return Text("");
  }
}
