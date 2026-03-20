import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/common_models/wp_embedded_model.dart';
import 'package:socialv/models/posts/wp_post_response.dart';
import 'package:socialv/screens/blog/screens/blog_detail_screen.dart';
import 'package:socialv/screens/membership/screens/membership_plans_screen.dart';
import 'package:socialv/utils/app_constants.dart';
import 'package:socialv/utils/cached_network_image.dart';

class BlogCardComponent extends StatefulWidget {
  final WpPostResponse data;

  BlogCardComponent({required this.data});

  @override
  State<BlogCardComponent> createState() => _BlogCardComponentState();
}

class _BlogCardComponentState extends State<BlogCardComponent> {
  List<String> tags = [];
  String category = '';

  @override
  void initState() {
    super.initState();
    getTags();
  }

  void getTags() {
    widget.data.embedded!.wpTerms!.forEach((element) {
      element.forEach((e) {
        WpTermsModel terms = WpTermsModel.fromJson(e);
        if (terms.taxonomy.validate() == 'category') {
          category = terms.name.validate();
        } else if (terms.taxonomy.validate() == 'post_tag') {
          tags.add(terms.name.validate());
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (widget.data.is_restricted.validate()) {
          MembershipPlansScreen().launch(context);
        } else {
          BlogDetailScreen(blogId: widget.data.id.validate(), data: widget.data).launch(context);
        }
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: radius(12),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, spreadRadius: 2)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Image ---

            cachedImage(
                    (widget.data.embedded != null && widget.data.embedded!.featuredMedia != null) ? widget.data.embedded!.featuredMedia!.first.source_url.validate() : AppImages.profileBackgroundImage,
                    height: 180,
                    width: context.width(),
                    fit: BoxFit.cover)
                .cornerRadiusWithClipRRectOnly(topLeft: 12, topRight: 12),

            // --- Content ---
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category + Date
                  Row(
                    children: [
                      if (category.isNotEmpty)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: context.primaryColor.withValues(alpha: 0.1),
                            borderRadius: radius(20),
                            border: Border.all(color: context.primaryColor, width: 1),
                          ),
                          child: Text(category, style: secondaryTextStyle(color: context.primaryColor)),
                        ),
                      8.width,
                      Text(
                          formatDate(
                            widget.data.date.validate(),
                          ),
                          style: secondaryTextStyle(size: 12)),
                    ],
                  ),

                  12.height,
                  // Title
                  Text(parseHtmlString(widget.data.title!.rendered.validate()), style: boldTextStyle(size: 18)),

                  8.height,
                  // Excerpt
                  if (widget.data.excerpt != null && widget.data.excerpt!.rendered.validate().isNotEmpty)
                    ReadMoreText(
                      parseHtmlString(
                        widget.data.excerpt!.rendered.validate(),
                      ),
                      trimExpandedText: "...Read Less",
                      trimCollapsedText: "...Read More",
                      colorClickableText: context.primaryColor,
                      trimLength: 130,
                      style: secondaryTextStyle(),
                      textAlign: TextAlign.left,
                    ).center(),

                  // Tags
                  if (tags.isNotEmpty) ...[
                    12.height,
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.local_offer_outlined, size: 18, color: Colors.grey.shade400),
                        8.width,
                        Text('${language.tag}:', style: secondaryTextStyle(size: 14)),
                        4.width,
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: tags.map((e) {
                            return GestureDetector(
                              onTap: () {
                                // optional: navigate to tag details
                              },
                              child: Text(
                                tags.join("  |  "),
                                style: secondaryTextStyle(
                                  size: 14,
                                  color: context.primaryColor,
                                ),
                              ),
                            );
                          }).toList(),
                        ).expand(),
                      ],
                    ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
