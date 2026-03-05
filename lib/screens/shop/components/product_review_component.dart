import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/woo_commerce/product_review_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/shop/components/update_review_component.dart';
import 'package:socialv/screens/shop/screens/viewall_review_screen.dart';
import 'package:socialv/store/shop_store.dart';
import 'package:socialv/utils/cached_network_image.dart';

import '../../../utils/app_constants.dart';

class ProductReviewComponent extends StatefulWidget {
  final int productId;

  const ProductReviewComponent({required this.productId});

  @override
  State<ProductReviewComponent> createState() => _ProductReviewComponentState();
}
  
class _ProductReviewComponentState extends State<ProductReviewComponent> {
  final reviewFormKey = GlobalKey<FormState>();
  ShopStore productReviewComponentVars = ShopStore();
  TextEditingController controller = TextEditingController();

  void addReview() {
    hideKeyboard(context);

    if (productReviewComponentVars.rating > 0) {
      ifNotTester(() async {
        appStore.setLoading(true);
        Map request = {
          "product_id": widget.productId.toString(),
          "review": controller.text.isEmpty ? " " : controller.text,
          "reviewer": userStore.loginFullName,
          "reviewer_email": userStore.loginEmail,
          "rating": productReviewComponentVars.rating.toInt(),
        };
        await addProductReview(request: request).then((value) async {
          toast('${language.reviewAddedSuccessfully}');
          controller.clear();
          productReviewComponentVars.rating = 0.0;
          appStore.setLoading(false);
        }).catchError((e) {
          appStore.setLoading(false);
          toast(e.toString(), print: true);
        });
      });
    } else {
      toast('${language.pleaseAddRating}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.cardColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SnapHelperWidget<List<ProductReviewModel>>(
            future: getProductReviews(productId: widget.productId),
            onSuccess: (snap) {
              if (snap.isNotEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${language.reviews}', style: boldTextStyle()),
                        if (snap.length > 3)
                          TextButton(
                            onPressed: () {
                              ViewAllReviewsScreen(productId: widget.productId).launch(context);
                            },
                            child: Text(language.viewAll),
                          ),
                      ],
                    ),
                    24.height,
                    ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: snap.length > 3 ? 3 : snap.length,
                      itemBuilder: (ctx, index) {
                        ProductReviewModel review = snap[index];
                        return Stack(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                cachedImage(review.reviewerAvatarUrls!.full,
                                        height: 40,
                                        width: 40,
                                        fit: BoxFit.cover)
                                    .cornerRadiusWithClipRRect(20),
                                16.width,
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(review.reviewer.validate(),
                                                style: boldTextStyle(size: 14),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis)
                                            .expand(),
                                        Text(
                                            convertToAgo(
                                                review.dateCreated.validate()),
                                            style:
                                                secondaryTextStyle(size: 12)),
                                      ],
                                    ),
                                    2.height,
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          RatingBarWidget(
                                            onRatingChanged: (val) {
                                              productReviewComponentVars.rating = val;
                                            },
                                            activeColor: Colors.amber,
                                            inActiveColor: Colors.amber,
                                            rating: review.rating
                                                .validate()
                                                .toDouble(),
                                            size: 14,
                                            allowHalfRating: true,
                                            disable: true,
                                          ),
                                          if (review.reviewer ==userStore.loginFullName)
                                            Text('${language.edit}',
                                                    style: secondaryTextStyle(
                                                        color:
                                                            context.primaryColor,
                                                        size: 12))
                                                .onTap(() {
                                              showInDialog(
                                                context,
                                                contentPadding: EdgeInsets.zero,
                                                backgroundColor: context.scaffoldBackgroundColor,
                                                builder: (p0) {
                                                  return UpdateReviewComponent(
                                                    rating:review.rating.validate(),
                                                    review: review.review,
                                                    reviewId:
                                                        review.id.validate(),
                                                  );
                                                },
                                              );
                                            }),
                                        ],
                                      ),
                                    6.height,
                                    Text(
                                        parseHtmlString(
                                            review.review.validate()),
                                        style: secondaryTextStyle()),
                                  ],
                                ).expand(),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                );
              }
              return Offstage();
            },
            errorWidget: Offstage(),
            loadingWidget: ThreeBounceLoadingWidget(),
          ),
          Text('${language.addAReview}', style: boldTextStyle()),
          16.height,
          RichText(
            text: TextSpan(
              style: secondaryTextStyle(fontFamily: fontFamily),
              children: [
                TextSpan(text: '${language.rating} '),
                TextSpan(
                    text: '*',
                    style: TextStyle(
                        color: Colors.red,
                        fontFeatures: [FontFeature.subscripts()],
                        fontFamily: fontFamily)),
              ],
            ),
          ),
          6.height,
          Observer(builder: (context) {
            return RatingBarWidget(
              onRatingChanged: (val) {
                productReviewComponentVars.rating = val;
              },
              activeColor: Colors.amber,
              inActiveColor: Colors.amber,
              rating: productReviewComponentVars.rating,
              size: 22,
              allowHalfRating: true,
            );
          }),
          16.height,
          RichText(
            text: TextSpan(
              style: secondaryTextStyle(),
              children: [
                TextSpan(text: '${language.writeReview} '),
              ],
            ),
          ),
          8.height,
          Form(
            key: reviewFormKey,
            child: AppTextField(
              enabled: !appStore.isLoading,
              controller: controller,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.done,
              textFieldType: TextFieldType.MULTILINE,
              textStyle: primaryTextStyle(size: 14),
              minLines: 3,
              maxLines: 6,
              decoration: inputDecorationFilled(context,
                  fillColor: context.scaffoldBackgroundColor),
              onFieldSubmitted: (text) {
                //addReview();
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: AppButton(
              shapeBorder: RoundedRectangleBorder(borderRadius: radius(4)),
              text: language.submit,
              textStyle: boldTextStyle(color: Colors.white, size: 12),
              padding: EdgeInsets.zero,
              elevation: 0,
              color: context.primaryColor,
              onTap: () async {
                addReview();
              },
            ),
          ),
        ],
      ).paddingSymmetric(horizontal: 16, vertical: 16),
    );
  }
}
