import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:rating_summary/rating_summary.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/lms/course_review_model.dart';
import 'package:socialv/network/lms_rest_apis.dart';
import 'package:socialv/screens/lms/components/write_course_review.dart';
import 'package:socialv/store/profile_menu_store.dart';

import '../../../utils/app_constants.dart';

class ReviewTabComponent extends StatefulWidget {
  final int courseId;

  const ReviewTabComponent({Key? key, required this.courseId}) : super(key: key);

  @override
  State<ReviewTabComponent> createState() => _ReviewTabComponentState();
}

class _ReviewTabComponentState extends State<ReviewTabComponent> {
  ProfileMenuStore reviewTabComponentVars = ProfileMenuStore();
  bool showAllReviews = false;
  @override
  void initState() {
    super.initState();
    getReview();
  }

  Future<void> getReview() async {
    reviewTabComponentVars.ratings.clear();
    reviewTabComponentVars.showLoading = true;
    getCourseReviews(courseId: widget.courseId).then((value) {
      reviewTabComponentVars.snap = value;
      reviewTabComponentVars.isFetched = true;

      if (value.data!.items != null) {
        value.data!.items!.keys.map((e) => value.data!.items![e]).toList().forEach((element) {
          reviewTabComponentVars.ratings.add(SingleRatingItem.fromJson(element));
        });
      }
      log('Ratings: ${reviewTabComponentVars.ratings.length}');
      reviewTabComponentVars.showLoading = false;
    }).catchError((e) {
      toast(e.toString(), print: true);
      reviewTabComponentVars.showLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Observer(builder: (context) {
          return reviewTabComponentVars.isFetched && !reviewTabComponentVars.showLoading
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Observer(builder: (context) {
                      return reviewTabComponentVars.snap.message.validate().isNotEmpty
                          ? Container(
                              decoration: BoxDecoration(
                                color: appGreenColor.withAlpha(20),
                                border: Border(left: BorderSide(color: appGreenColor, width: 2)),
                              ),
                              padding: EdgeInsets.all(12),
                              margin: EdgeInsets.all(16),
                              child: Text(reviewTabComponentVars.snap.message.validate(), style: primaryTextStyle(color: appGreenColor)),
                            )
                          : Offstage();
                    }),
                    Observer(builder: (context) {
                      return reviewTabComponentVars.snap.data != null
                          ? RatingSummary(
                              counter: reviewTabComponentVars.snap.data!.total.validate(),
                              average: reviewTabComponentVars.snap.data!.rated.validate().toDouble(),
                              showAverage: true,
                              counterFiveStars: reviewTabComponentVars.snap.data!.items!["5"]["total"],
                              counterFourStars: reviewTabComponentVars.snap.data!.items!["4"]["total"],
                              counterThreeStars: reviewTabComponentVars.snap.data!.items!["3"]["total"],
                              counterTwoStars: reviewTabComponentVars.snap.data!.items!["2"]["total"],
                              counterOneStars: reviewTabComponentVars.snap.data!.items!["1"]["total"],
                            ).paddingOnly(left: 16, right: 16, top: 16)
                          : Offstage();
                    }),
                    16.height,
                    if (reviewTabComponentVars.snap.data!.can_review.validate())
                      appButton(
                        width: context.width() / 2 - 20,
                        context: context,
                        text: language.writeReview,
                        onTap: () async {
                          await showModalBottomSheet(
                            context: context,
                            elevation: 0,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) {
                              return WriteCourseReview(
                                courseId: widget.courseId,
                                callback: () {
                                  appStore.setLoading(false);
                                  getReview();
                                },
                              );
                            },
                          );
                        },
                      ).paddingAll(16),
                    if (reviewTabComponentVars.snap.data!.reviews != null && reviewTabComponentVars.snap.data!.reviews!.reviews.validate().isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(language.reviews, style: boldTextStyle()).paddingSymmetric(horizontal: 16),
                          if (reviewTabComponentVars.snap.data!.reviews!.reviews!.length > 3)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  showAllReviews = !showAllReviews;
                                });
                              },
                              child: Text(
                                showAllReviews ?  language.viewLess: language.viewAll,
                                style: boldTextStyle(color: appColorPrimary),
                              ),
                            ).paddingSymmetric(horizontal: 16),
                        ],
                      ),
                    Observer(builder: (context) {
                      return reviewTabComponentVars.snap.data!.reviews != null && reviewTabComponentVars.snap.data!.reviews!.reviews.validate().isNotEmpty
                          ? ListView.builder(
                              padding: EdgeInsets.all(16),
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: showAllReviews?reviewTabComponentVars.snap.data!.reviews!.reviews.validate().length:reviewTabComponentVars.snap.data!.reviews!.reviews.validate().take(3)
                                  .length,
                              itemBuilder: (ctx, index) {
                                Review review = reviewTabComponentVars.snap.data!.reviews!.reviews.validate()[index];

                                return Container(
                                  decoration: BoxDecoration(color: context.cardColor, borderRadius: radius(commonRadius)),
                                  padding: EdgeInsets.all(16),
                                  margin: EdgeInsets.symmetric(vertical: 8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(review.display_name.validate(), style: boldTextStyle()),
                                          RatingBarWidget(
                                            onRatingChanged: (x) {
                                              //
                                            },
                                            activeColor: Colors.amber,
                                            inActiveColor: Colors.amber,
                                            rating: review.rate.validate().toDouble(),
                                            size: 14,
                                            allowHalfRating: true,
                                            disable: true,
                                          ),
                                        ],
                                      ),
                                      8.height,
                                      Text(review.title.validate(), style: secondaryTextStyle()),
                                      8.height,
                                      Text(parseHtmlString(review.content.validate()), style: primaryTextStyle()),
                                    ],
                                  ),
                                );
                              },
                            )
                          : Offstage();
                    }),
                  ],
                )
              : Offstage();
        }),
        Observer(builder: (context) {
          return ThreeBounceLoadingWidget().visible(reviewTabComponentVars.showLoading);
        })
      ],
    );
  }
}
