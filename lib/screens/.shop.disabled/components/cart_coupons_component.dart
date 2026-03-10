import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/woo_commerce/cart_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/utils/app_constants.dart';

class CartCouponsComponent extends StatefulWidget {
  final List<CartCouponModel>? couponsList;
  final Function(CartModel)? onCouponRemoved;

  CartCouponsComponent({this.couponsList, this.onCouponRemoved});

  @override
  State<CartCouponsComponent> createState() => _CartCouponsComponentState();
}

class _CartCouponsComponentState extends State<CartCouponsComponent> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: radius(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          8.height,
          Text(language.appliedCoupons, style: boldTextStyle()),
          8.height,
          if (widget.couponsList != null && widget.couponsList!.isNotEmpty)
            ...List.generate(
              widget.couponsList!.length,
              (index) {
                CartCouponModel coupon = widget.couponsList![index];
                return Padding(
                  padding: EdgeInsets.only(bottom: 8), // spacing between coupons
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 30,
                        width: 140,
                        decoration: BoxDecoration(
                          color: context.cardColor,
                          borderRadius: radius(8),
                          border: Border.all(color: appColorPrimary),
                        ),
                        padding: EdgeInsets.all(4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text("${language.code}:", style: secondaryTextStyle()),
                            Text(" ${coupon.code}", style: primaryTextStyle(color: appColorPrimary)),
                          ],
                        ),
                      ),
                      Text(
                        "Saved ${coupon.totals!.currencySymbol.validate()}${getPrice(coupon.totals!.totalDiscount.validate())}",
                        style: boldTextStyle(color: Colors.green, size: 16),
                      ),
                      TextButton(
                        onPressed: () {
                          showConfirmDialogCustom(
                            context,
                            onAccept: (c) {
                              ifNotTester(() {
                                removeCoupon(code: coupon.code.validate()).then((value) {
                                  toast(language.couponHasBeenRemoved);
                                  widget.onCouponRemoved?.call(value);
                                  appStore.setLoading(false);
                                }).catchError((e) {
                                  log('error remove coupon: ${e.toString()}');
                                  appStore.setLoading(false);
                                });
                              });
                            },
                            dialogType: DialogType.DELETE,
                            title: language.removeCouponConfirmation,
                            positiveText: language.remove,
                          );
                        },
                        child: Text("Remove", style: primaryTextStyle(color: appColorPrimary)),
                      ),
                    ],
                  ),
                );
              },
            )
          else
            Text("No coupons applied", style: secondaryTextStyle()),
        ],
      ),
    );
  }
}
