import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/posts/wp_comments_model.dart';
import 'package:socialv/network/rest_apis.dart';

import '../../../utils/app_constants.dart';

// ignore: must_be_immutable
class ReplyBlogCommentComponent extends StatefulWidget {
  final int? id;
  final int? blogId;
  final String? comment;
  final Function(WpCommentModel) onUpdate;

  ReplyBlogCommentComponent({this.id, this.comment, required this.onUpdate, this.blogId});

  @override
  State<ReplyBlogCommentComponent> createState() => _ReplyBlogCommentComponentState();
}

class _ReplyBlogCommentComponentState extends State<ReplyBlogCommentComponent> {
  TextEditingController textController = TextEditingController();
  String message = '';

  @override
  void initState() {
    super.initState();
    if (widget.comment != null) {
      message= parseHtmlString(widget.comment.validate());
    }
  }

  void updateComment() {
    if (textController.text.isNotEmpty) {
      ifNotTester(() async {
        appStore.setLoading(true);
        finish(context);
        await replyCommentBlog(parentId: widget.id.validate(), content: textController.text,blogId:widget.blogId! ).then((value) async {
          widget.onUpdate.call(value);
          toast(language.commentUpdatedSuccessfully);
          appStore.setLoading(false);
        }).catchError((e) {
          appStore.setLoading(false);
          toast(e.toString(), print: true);
        });
      });
    } else {
      toast(language.writeComment);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width(),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: radius(20),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Title
            Row(
              children: [
                Icon(Icons.reply, color: context.primaryColor, size: 22),
                8.width,
                Expanded(
                  child: Text(
                    "Reply to ${message}",
                    style: boldTextStyle(color: context.primaryColor, size: 18),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            16.height,

            /// Text field inside a card-style container
            Container(
              decoration: BoxDecoration(
                color: appStore.isDarkMode
                    ? context.scaffoldBackgroundColor
                    : scaffoldLightColor,
                borderRadius: radius(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: AppTextField(
                controller: textController,
                textFieldType: TextFieldType.OTHER,
                minLines: 5,
                maxLines: 10,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: language.writeComment,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(14),
                ),
                onFieldSubmitted: (x) => updateComment(),
              ),
            ),
            24.height,

            /// Buttons
            Row(
              children: [
                AppButton(
                  text: language.cancel,
                  textColor: context.primaryColor,
                  color: context.cardColor,
                  elevation: 0,
                  shapeBorder: RoundedRectangleBorder(
                    borderRadius: radius(12),
                    side: BorderSide(color: context.primaryColor),
                  ),
                  onTap: () => finish(context),
                ).expand(),
                16.width,
                AppButton(
                  text: language.submit,
                  textColor: Colors.white,
                  color: context.primaryColor,
                  elevation: 0,
                  shapeBorder: RoundedRectangleBorder(
                    borderRadius: radius(12),
                  ),
                  onTap: () => updateComment(),
                ).expand(),
              ],
            ),
          ],
        ),
      ),
    );
  }

}
