import 'package:flutter/material.dart';
import 'package:socialv/components/base_scaffold_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/gamipress/common_gamipress_model.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/utils/app_constants.dart';
import 'package:socialv/utils/cached_network_image.dart';

class BadgeDetailScreen extends StatelessWidget {
  final CommonGamiPressModel data;

  const BadgeDetailScreen({required this.data});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: data.title!.rendered.validate(),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(8),
        child: Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  cachedImage(
                    data.image.validate(),
                    height: 80,
                    width: 80,
                    fit: BoxFit.cover,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Directionality(
                        textDirection: Localizations.localeOf(context).languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                        child: RichText(
                          text: TextSpan(
                            children: [
                              if (data.authorName.validate().isNotEmpty) ...[
                                TextSpan(text: '${data.authorName.validate()} ', style: primaryTextStyle()),
                                if (data.isUserVerified.validate())
                                  WidgetSpan(
                                    child: Image.asset(ic_tick_filled, height: 16, width: 16, color: blueTickColor, fit: BoxFit.cover),
                                  ),
                              ],
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.start,
                        ),
                      ).paddingBottom(4),
                      Directionality(
                        textDirection: Localizations.localeOf(context).languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                        child: Text(
                          getFormattedDate(data.date.validate()),
                          style: secondaryTextStyle(size: 12, fontFamily: fontFamily),
                        ),
                      ).paddingBottom(4),
                      if (data.hasEarned.validate())
                        Directionality(
                          textDirection: Localizations.localeOf(context).languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                          child: Text(
                            language.youHaveEarnedBadge,
                            style: primaryTextStyle(color: context.primaryColor),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        )
                    ],
                  ).paddingSymmetric(horizontal: 16).expand(),
                ],
              ),
              8.height,
              if (data.hasEarned.validate()) ...[
                Container(
                  margin: EdgeInsets.symmetric(vertical: 16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: appGreenColor.withAlpha(30),
                    border: Border(left: BorderSide(color: appGreenColor, width: 2)),
                  ),
                  child: Text(language.congratulatesYouAreAchieve, style: primaryTextStyle(color: appGreenColor)),
                ),
              ],
              Text(parseHtmlString(data.content!.rendered.validate()), style: secondaryTextStyle(size: 16)),
            ],
          ).paddingAll(16),
        ),
      ),
    );
  }
}
