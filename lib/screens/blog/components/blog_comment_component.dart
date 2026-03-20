import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/models/posts/wp_comments_model.dart';
import 'package:socialv/screens/blog/components/edit_blog_comment_component.dart';
import 'package:socialv/utils/app_constants.dart';
import 'package:socialv/utils/cached_network_image.dart';

class BlogCommentComponent extends StatelessWidget {
  final WpCommentModel comment;
  final VoidCallback refreshCallback;

  BlogCommentComponent({required this.comment, required this.refreshCallback});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: context.scaffoldBackgroundColor),
      margin: EdgeInsets.only(
        top: 8,
      //  bottom: 8,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          8.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              cachedImage(
                comment.author_avatar_urls!.ninetySix.validate(),
                height: 35,
                width: 35,
                fit: BoxFit.cover,
              ).cornerRadiusWithClipRRect(25),
              16.width,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(comment.author_name.validate(), style: secondaryTextStyle()),
                  4.height,
                  Text(convertToAgo(comment.date.validate()), style: secondaryTextStyle(size: 12)),
                ],
              ).expand(),
              if (comment.canReply)
                InkWell(
                  onTap: () {
                    showInDialog(
                      context,
                      contentPadding: EdgeInsets.zero,
                      backgroundColor: context.scaffoldBackgroundColor,
                      builder: (p0) {
                        return ReplyBlogCommentComponent(
                          id: comment.id.validate(),
                          blogId: comment.post,
                          comment: parseHtmlString(comment.content!.rendered.validate()),
                          onUpdate: (value) {
                            refreshCallback.call();
                          },
                        );
                      },
                    );
                  },
                  child: cachedImage(ic_reply, color: context.primaryColor, height: 18, width: 18, fit: BoxFit.cover),
                ),
            ],
          ),
          4.height,
          Text(parseHtmlString(comment.content!.rendered.validate()), style: primaryTextStyle(size: 14)).paddingSymmetric(horizontal: 16)
        ],
      ),
    );
  }
}
