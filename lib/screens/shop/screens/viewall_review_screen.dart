import 'package:flutter/material.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/woo_commerce/product_review_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/shop/components/update_review_component.dart';
import 'package:socialv/utils/cached_network_image.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../utils/app_constants.dart';

class ViewAllReviewsScreen extends StatelessWidget {
  final int productId;

  ViewAllReviewsScreen({required this.productId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(language.reviews, color: appColorPrimary,textColor: appColorPrimaryDarkLight,center: true,elevation: 0),
      body: SnapHelperWidget<List<ProductReviewModel>>(
        future: getProductReviews(productId: productId),
        loadingWidget: ThreeBounceLoadingWidget(),
        errorWidget: Center(child: Text(language.somethingWentWrong)),
        onSuccess: (snap) {
          return ListView.builder(
            itemCount: snap.length,
            itemBuilder: (context, index) {
              ProductReviewModel review = snap[index];
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    cachedImage(review.reviewerAvatarUrls?.full ?? '',
                            height: 40, width: 40, fit: BoxFit.cover)
                        .cornerRadiusWithClipRRect(20),
                    16.width,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(review.reviewer.validate(),
                                  style: boldTextStyle(size: 14)),
                              Text(convertToAgo(review.dateCreated.validate()),
                                  style: secondaryTextStyle(size: 12)),
                            ],
                          ),
                          4.height,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              RatingBarWidget(
                                onRatingChanged: (_) {},
                                rating: review.rating.validate().toDouble(),
                                size: 14,
                                activeColor: Colors.amber,
                                inActiveColor: Colors.amber,
                                disable: true,
                                allowHalfRating: true,
                              ),
                              if (review.reviewer == userStore.loginFullName)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text('${language.edit}',
                                          style: secondaryTextStyle(
                                              color: context.primaryColor, size: 12))
                                      .onTap(() {
                                    showInDialog(
                                      context,
                                      contentPadding: EdgeInsets.zero,
                                      backgroundColor: context.scaffoldBackgroundColor,
                                      builder: (p0) {
                                        return UpdateReviewComponent(
                                          rating: review.rating.validate(),
                                          review: review.review,
                                          reviewId: review.id.validate(),
                                        );
                                      },
                                    );
                                  }),
                                ),
                            ],
                          ),
                          //6.height,
                          Text(parseHtmlString(review.review.validate()),
                              style: secondaryTextStyle()),
                          //6.height,
                          
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
