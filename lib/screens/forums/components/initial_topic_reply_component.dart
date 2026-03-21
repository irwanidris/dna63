import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/main.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/store/profile_menu_store.dart';
import 'package:socialv/utils/app_constants.dart';

class InitialTopicReplyComponent extends StatefulWidget {
  final String topicContent;
  final String topicTitle;
  final int topicId;
  final int? replyId;
  final VoidCallback? callback;

  InitialTopicReplyComponent({
    required this.topicContent,
    required this.topicTitle,
    required this.topicId,
    this.callback,
    this.replyId,
  });

  @override
  State<InitialTopicReplyComponent> createState() => _InitialTopicReplyComponentState();
}

class _InitialTopicReplyComponentState extends State<InitialTopicReplyComponent> {

  ProfileMenuStore InitialTopicReplyComponentVars =ProfileMenuStore();
  final topicReplyFormKey = GlobalKey<FormState>();

  TextEditingController content = TextEditingController();
  TextEditingController tags = TextEditingController();


  Future<void> reply() async {
    if (topicReplyFormKey.currentState!.validate()) {
      topicReplyFormKey.currentState!.save();
      hideKeyboard(context);

      ifNotTester(() async {
        Map request = {
          "is_reply_topic": widget.replyId != widget.topicId ? 1 : 0,
          "content": content.text,
          "tags": tags.text.split(','),
          "notify_me": InitialTopicReplyComponentVars.doNotify,
        };
        appStore.setLoading(true);

        await replyTopic(request: request,topicId: widget.topicId).then((value) async {
          toast(value.message);
          widget.callback?.call();
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
    return Form(
      key: topicReplyFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.topicContent, style: secondaryTextStyle()),
          16.height,
          Text('${language.replyTo}: ${widget.topicTitle}', style: boldTextStyle()),
          16.height,
          AppTextField(
            controller: content,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.done,
            textFieldType: TextFieldType.MULTILINE,
            textStyle: boldTextStyle(),
            decoration: inputDecorationFilled(context, fillColor: context.cardColor, label: language.writeAReply),
            minLines: 5,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return language.pleaseEnterDescription;
              }
              return null;
            },
          ),
          16.height,

          AppTextField(
            controller: tags,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.done,
            textFieldType: TextFieldType.MULTILINE,
            textStyle: boldTextStyle(),
            minLines: 1,
            maxLines: 5,
            decoration: inputDecorationFilled(context, fillColor: context.cardColor, label: language.topicTags),
          ),
          Text(language.notePleaseAddComma,style: secondaryTextStyle()),
          16.height,
          Row(
            children: [
              Observer(
                builder: (context) {
                  return Checkbox(
                    shape: RoundedRectangleBorder(borderRadius: radius(2)),
                    activeColor: context.primaryColor,
                    value:  InitialTopicReplyComponentVars.doNotify,
                    onChanged: (val) {
                      InitialTopicReplyComponentVars.doNotify = ! InitialTopicReplyComponentVars.doNotify;
                    },
                  );
                }
              ),
              Text(language.notifyMeText, style: secondaryTextStyle()).onTap(() {
                InitialTopicReplyComponentVars.doNotify = ! InitialTopicReplyComponentVars.doNotify;
              }, splashColor: Colors.transparent, highlightColor: Colors.transparent),
            ],
          ),
          16.height,
          appButton(
            context: context,
            text: language.submit.capitalizeFirstLetter(),
            onTap: () {
              ifNotTester(() {
                reply();
              });
            },
          ),
        ],
      ),
    );
  }
}
