import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/posts/post_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/profile/screens/member_profile_screen.dart';
import 'package:socialv/utils/app_constants.dart';
import 'package:socialv/utils/cached_network_image.dart';

class LatestActivityComponent extends StatelessWidget {
  const LatestActivityComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        16.height,
        Text(language.latestActivities, style: boldTextStyle(size: 18)),
        16.height,
        Expanded(
          child: SnapHelperWidget(
            future: getPost(
              userId: userStore.loginUserId.toInt(),
              type: PostRequestType.newsFeed,
              postList: homeFragStore.postList,
            ),
            onSuccess: (List<PostModel> snap) {
              if (snap.isNotEmpty) {
                return ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: snap.take(8).length,
                  itemBuilder: (ctx, index) {
                    PostModel activity = snap[index];
                    return InkWell(
                      onTap: () {
                        MemberProfileScreen(memberId: activity.userId.validate()).launch(context);
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 12),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            cachedImage(
                              activity.userImage!.isNotEmpty ? activity.userImage : AppImages.defaultAvatarUrl,
                              height: 50,
                              width: 50,
                              fit: BoxFit.cover,
                            ).cornerRadiusWithClipRRect(25),
                            12.width,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (activity.activityMessage.validate().isNotEmpty)
                                    Text(
                                      parseHtmlString(activity.activityMessage.validate()),
                                      style: primaryTextStyle(),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  6.height,
                                  Text(
                                    convertToAgo(activity.dateRecorded.validate()),
                                    style: secondaryTextStyle(size: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              } else {
                return NoDataWidget(
                  title: language.noDataFound,
                  imageWidget: NoDataLottieWidget(),
                );
              }
            },
            errorWidget: NoDataWidget(
              title: language.somethingWentWrong,
              imageWidget: NoDataLottieWidget(),
            ),
            loadingWidget: LoadingWidget(isBlurBackground: false).center(),
          ),
        ),
      ],
    ).paddingSymmetric(horizontal: 16);
  }

  /// Convert date to "time ago" string
  String convertToAgo(String date) {
    try {
      DateTime postDate = DateTime.parse(date);
      Duration diff = DateTime.now().difference(postDate);
      if (diff.inDays >= 1) return "${diff.inDays}d ago";
      if (diff.inHours >= 1) return "${diff.inHours}h ago";
      if (diff.inMinutes >= 1) return "${diff.inMinutes}m ago";
      return "Just now";
    } catch (e) {
      return "";
    }
  }
}
