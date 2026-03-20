import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/forums/common_models.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/store/profile_menu_store.dart';
import 'package:socialv/utils/app_constants.dart';

class WriteTopicReplyComponent extends StatefulWidget {
  final int topicId;
  final int? replyId;
  final String topicName;
  final Function(String)? newReply;
  final TopicReplyModel? reply;
  final String? replyImageUrl;
  final List<dynamic>? tags;

  const WriteTopicReplyComponent({required this.topicName, required this.topicId, this.replyId, this.newReply, this.reply, this.tags, this.replyImageUrl});

  @override
  State<WriteTopicReplyComponent> createState() => _WriteTopicReplyComponentState();
}

class _WriteTopicReplyComponentState extends State<WriteTopicReplyComponent> {
  ProfileMenuStore writeTopicReplyComponentVars = ProfileMenuStore();
  final replyFormKey = GlobalKey<FormState>();

  TextEditingController content = TextEditingController();
  TextEditingController image = TextEditingController();
  TextEditingController tags = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.reply?.content?.validate().isNotEmpty == true) {
      content.text = parseHtmlString(widget.reply!.content.validate());
      if (widget.tags != null && widget.tags!.isNotEmpty) {
        tags.text = widget.tags!.first.toString();
        tags.text = widget.tags!.join(',');
      }
    }
    if (widget.replyImageUrl != null) {
      image.text = widget.replyImageUrl!;
    }
  }

  Future<void> editReply() async {
    if (replyFormKey.currentState!.validate()) {
      replyFormKey.currentState!.save();
      hideKeyboard(context);

      ifNotTester(() async {
        Map request = {
          "is_topic": widget.topicId == widget.reply!.id ? 1 : 0,
          "topic_title": widget.topicName,
          "content": content.text,
          "tags": tags.text.split(','),
          "notify_me": writeTopicReplyComponentVars.doNotify,
          "image": image.text,
        };
        appStore.setLoading(true);

        await editTopicReply(request: request, topicId: widget.reply!.id!).then((value) async {
          toast(value.message);
          appStore.setLoading(false);
          widget.newReply?.call(content.text);
          finish(context, true);
        }).catchError((e) {
          appStore.setLoading(false);
          toast(e.toString());
        });
      });
    } else {
      appStore.setLoading(false);
    }
  }

  Future<void> reply() async {
    if (replyFormKey.currentState!.validate()) {
      replyFormKey.currentState!.save();
      hideKeyboard(context);

      ifNotTester(() async {
        Map request = {
          "reply_id": null,
          "is_reply_topic": widget.replyId != widget.topicId ? 0 : 1,
          "content": content.text,
          "tag": tags.text.split(','),
          "notify_me": writeTopicReplyComponentVars.doNotify,
          "image": image.text,
        };
        appStore.setLoading(true);

        await replyTopic(request: request, topicId: widget.topicId).then((value) async {
          toast(value.message);
          appStore.setLoading(false);
          widget.newReply?.call(content.text);
          finish(context, true);
        }).catchError((e) {
          appStore.setLoading(false);
          toast(e.toString());
        });
      });
    } else {
      appStore.setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, right: 16, left: 16),
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: replyFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  30.height,
                  Text('${language.replyTo}: ${widget.topicName}', style: boldTextStyle()),
                  16.height,
                  Theme(
                    data: ThemeData(textSelectionTheme: TextSelectionThemeData(selectionHandleColor: Colors.transparent)),
                    child: AppTextField(
                      controller: content,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.done,
                      textFieldType: TextFieldType.MULTILINE,
                      textStyle: boldTextStyle(),
                      decoration: inputDecorationFilled(context, fillColor: context.scaffoldBackgroundColor, label: language.writeAReply),
                      minLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return language.pleaseEnterDescription;
                        }
                        return null;
                      },
                    ),
                  ),
                  16.height,
                  Theme(
                    data: ThemeData(textSelectionTheme: TextSelectionThemeData(selectionHandleColor: Colors.transparent)),
                    child: TextField(
                      controller: image,
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.done,
                      style: boldTextStyle(),
                      decoration: inputDecorationFilled(context, fillColor: context.scaffoldBackgroundColor, label: language.imageLink),
                    ),
                  ),
                  16.height,
                  Theme(
                    data: ThemeData(textSelectionTheme: TextSelectionThemeData(selectionHandleColor: Colors.transparent)),
                    child: AppTextField(
                      controller: tags,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.done,
                      textFieldType: TextFieldType.MULTILINE,
                      textStyle: boldTextStyle(),
                      minLines: 1,
                      maxLines: 5,
                      isValidationRequired: false,
                      decoration: inputDecorationFilled(context, fillColor: context.scaffoldBackgroundColor, label: language.topicTags),
                      onFieldSubmitted: (text) {
                        //addReview();
                      },
                    ),
                  ),
                  Text(language.notePleaseAddComma, style: secondaryTextStyle()),
                  16.height,
                  Row(
                    children: [
                      Observer(builder: (context) {
                        return Checkbox(
                          shape: RoundedRectangleBorder(borderRadius: radius(2)),
                          activeColor: context.primaryColor,
                          value: writeTopicReplyComponentVars.doNotify,
                          onChanged: (val) {
                            writeTopicReplyComponentVars.doNotify = !writeTopicReplyComponentVars.doNotify;
                          },
                        );
                      }),
                      InkWell(
                        onTap: () {
                          writeTopicReplyComponentVars.doNotify = !writeTopicReplyComponentVars.doNotify;
                        },
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        child: Text(
                          language.notifyMeText,
                          style: secondaryTextStyle(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ).expand(),
                    ],
                  ),
                  16.height,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      appButton(
                        color: context.cardColor,
                        shapeBorder: RoundedRectangleBorder(
                          borderRadius: radius(defaultAppButtonRadius),
                          side: BorderSide(color: context.dividerColor),
                        ),
                        width: context.width() / 2 - 20,
                        context: context,
                        text: language.cancel.capitalizeFirstLetter(),
                        textStyle: boldTextStyle(),
                        onTap: () {
                          finish(context);
                        },
                      ),
                      appButton(
                        width: context.width() / 2 - 20,
                        context: context,
                        text: language.submit.capitalizeFirstLetter(),
                        onTap: () {
                          ifNotTester(() {
                            if (!appStore.isLoading) {
                              if (widget.reply != null) {
                                editReply();
                              } else {
                                reply();
                              }
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  16.height,
                ],
              ),
            ),
          ),
        ),
        Observer(builder: (_) => LoadingWidget().center().visible(appStore.isLoading))
      ],
    );
  }
}
