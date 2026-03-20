import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/forums/common_models.dart';
import 'package:socialv/screens/forums/components/write_topic_reply_component.dart';
import 'package:socialv/screens/shop/components/cached_image_widget.dart';
import 'package:socialv/utils/cached_network_image.dart';
import 'package:socialv/utils/extentions/str_extentions.dart';
import 'package:socialv/utils/html_widget.dart';

import '../../../utils/app_constants.dart';

class TopicReplyComponent extends StatefulWidget {
  final TopicReplyModel reply;
  final VoidCallback? callback;
  final bool showReply;
  final bool isParent;
  final bool isFromReplyScreen;
  final Function(String)? newReply;
  final String? replyImageUrl;
  final int? topicId;

  const TopicReplyComponent({required this.reply, this.callback, this.showReply = true, required this.isParent, this.isFromReplyScreen = false, this.newReply, this.topicId, this.replyImageUrl});

  @override
  State<TopicReplyComponent> createState() => _TopicReplyComponentState();
}

class _TopicReplyComponentState extends State<TopicReplyComponent> {
  String? imageUrl;

  String? extractImageUrl(String content) {
    RegExp imageRegex = RegExp(r'<img[^>]+src="([^"]+)"');
    Match? match = imageRegex.firstMatch(content);
    return match?.group(1);
  }

  @override
  void initState() {
    super.initState();
    imageUrl = extractImageUrl(widget.reply.content.validate().validateAndFilter());
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      return Container(
          decoration: BoxDecoration(color: context.cardColor, borderRadius: radius(commonRadius)),
          margin: EdgeInsets.symmetric(vertical: 8),
          padding: EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(widget.reply.createdAtDate.validate(), style: secondaryTextStyle()),
                  Text('#${widget.reply.id.validate().toString()}', style: secondaryTextStyle(color: context.primaryColor)),
                ],
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
              ).visible(widget.reply.createdAtDate!.isNotEmpty && widget.reply.id != null),
              10.height,
              Row(
                children: [
                  cachedImage(widget.reply.profileImage.validate(), height: 30, width: 30, fit: BoxFit.cover).cornerRadiusWithClipRRect(15),
                  10.width,
                  Flexible(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(text: widget.reply.createdByName.validate().capitalizeFirstLetter(), style: primaryTextStyle(fontFamily: fontFamily)),
                          if (widget.reply.isUserVerified.validate()) WidgetSpan(child: Image.asset(ic_tick_filled, height: 18, width: 18, color: blueTickColor, fit: BoxFit.cover)),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                    ),
                  ),
                  6.width,
                  Container(
                    decoration: BoxDecoration(color: context.primaryColor.withAlpha(40), borderRadius: radius()),
                    child: Text(widget.reply.key.validate(), style: secondaryTextStyle(color: context.primaryColor, size: 12)),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ],
              ).onTap(() {
                widget.callback?.call();
                //  if (widget.reply.key.validate() != 'Inactive') MemberProfileScreen(memberId: widget.reply.createdById.validate().toInt()).launch(context);
              }, highlightColor: Colors.transparent, splashColor: Colors.transparent),
              10.height.visible(widget.reply.content!.isNotEmpty),
              if (widget.reply.content.validate().validateAndFilter().contains('<img src') || widget.reply.content.validate().validateAndFilter().contains('<strong>'))
                HtmlWidget(
                  postContent: widget.reply.content.validate().validateAndFilter(),
                  fontSize: 14,
                  color: context.iconColor,
                )
              else
                ReadMoreText(
                  widget.reply.content.validate().validateAndFilter(),
                  style: secondaryTextStyle(),
                  trimLines: 2,
                  trimMode: TrimMode.Line,
                ),
              8.height.visible(widget.reply.image != null && widget.reply.image != "" && widget.reply.image!.isNotEmpty),
              if (widget.replyImageUrl != null && widget.replyImageUrl!.isNotEmpty)
                Align(
                    alignment: Alignment.center,
                    child: CachedImageWidget(
                      url: widget.reply.image.toString(),
                      height: 150,
                      width: context.width() - 100,
                      fit: BoxFit.cover,
                    ).visible(widget.reply.image != "" && widget.reply.image != null)),
              8.height.visible(widget.reply.tag!.isNotEmpty),
              Text(
                "${widget.reply.tag?.map((tag) => "#${tag.name}").join(", ") ?? ""}",
                style: boldTextStyle(color: appColorPrimary, size: 12),
              ).visible(widget.reply.tag!.isNotEmpty),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (widget.topicId != null)
                    Align(
                      child: TextIcon(
                        prefix: Image.asset(
                          ic_edit,
                          height: 16,
                          width: 16,
                          fit: BoxFit.cover,
                          color: context.primaryColor,
                        ),
                        onTap: () async {
                          String imgUrl = '';
                          if (widget.reply.content.validate().validateAndFilter().contains('<img src')) {
                            RegExp regExp = RegExp("<img src=['\"]([^'\"]+)['\"]");
                            Match? match = regExp.firstMatch(widget.reply.content.validate());
                            if (match != null) {
                              imgUrl = match.group(1) ?? '';
                            }
                          }

                          await showModalBottomSheet(
                            context: context,
                            elevation: 0,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) {
                              return FractionallySizedBox(
                                heightFactor: 0.6,
                                child: WriteTopicReplyComponent(
                                  reply: widget.reply,
                                  tags: widget.reply.tag?.toList(),
                                  topicName: widget.reply.topicName.validate(),
                                  topicId: widget.topicId.validate(),
                                  replyId: widget.reply.id.validate(),
                                  replyImageUrl: imgUrl,
                                  newReply: (x) {
                                    widget.newReply?.call(x);
                                  },
                                ),
                              );
                            },
                          ).then((value) {
                            if (value ?? false) {
                              widget.callback?.call();
                            }
                          });
                        },
                      ),
                      alignment: Alignment.bottomRight,
                    ).visible(widget.reply.createdById.toString() == userStore.loginUserId),
                  Align(
                    child: TextIcon(
                      prefix: Image.asset(
                        ic_reply,
                        height: 16,
                        width: 16,
                        fit: BoxFit.cover,
                        color: context.primaryColor,
                      ),
                      onTap: () async {
                        await showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          elevation: 0,
                          backgroundColor: Colors.transparent,
                          builder: (context) {
                            return FractionallySizedBox(
                              heightFactor: 0.6,
                              child: WriteTopicReplyComponent(
                                topicName: widget.reply.topicName.validate(),
                                topicId: widget.topicId.validate(),
                                replyId: widget.reply.id.validate(),
                                newReply: (x) {
                                  widget.newReply?.call(x);
                                },
                              ),
                            );
                          },
                        ).then((value) {
                          if (value ?? false) {
                            widget.callback?.call();
                          }
                        });
                      },
                    ),
                    alignment: Alignment.bottomRight,
                  ).visible(widget.showReply)
                ],
              ),
            ],
          ));
    });
  }
}
