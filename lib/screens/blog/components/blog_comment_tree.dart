import 'package:flutter/material.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/posts/wp_comments_model.dart';
import 'package:socialv/screens/blog/components/blog_comment_component.dart';

class BlogCommentTree extends StatelessWidget {
  final WpCommentModel comment;
  final Map<int, List<WpCommentModel>> groupedComments;
  final VoidCallback refreshCallback;
  final int depth;

  const BlogCommentTree({
    super.key,
    required this.comment,
    required this.groupedComments,
    required this.refreshCallback,
    this.depth = 0,
  });

  @override
  Widget build(BuildContext context) {
    List<WpCommentModel> children = groupedComments[comment.id] ?? [];

    return Container(
      margin: EdgeInsets.only(left: depth * 10.0, top: 8, bottom: 8),
      decoration: BoxDecoration(
        border: depth > 0
            ? Border(
                left: BorderSide(color: appStore.isDarkMode?Colors.grey.shade700:Colors.grey.shade300, width: 1.5),
              )
            : null,
      ),
      padding: EdgeInsets.only(left: depth > 0 ? 12 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BlogCommentComponent(
            comment: comment,
            refreshCallback: refreshCallback,
          ),
          if (children.isNotEmpty)
            ...children.map(
              (child) => BlogCommentTree(
                comment: child,
                groupedComments: groupedComments,
                refreshCallback: refreshCallback,
                depth: depth + 1,
              ),
            ),
        ],
      ),
    );
  }

}
