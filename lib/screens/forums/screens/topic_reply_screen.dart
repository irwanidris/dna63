import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/forums/common_models.dart';
import 'package:socialv/screens/forums/components/topic_reply_component.dart';
import 'package:socialv/store/profile_menu_store.dart';

import '../../../utils/app_constants.dart';

class TopicReplyScreen extends StatefulWidget {
  final TopicReplyModel reply;
  final int? topicId;

  const TopicReplyScreen({required this.reply, this.topicId});

  @override
  State<TopicReplyScreen> createState() => _TopicReplyScreenState();
}

class _TopicReplyScreenState extends State<TopicReplyScreen> {
  TopicReplyModel? reply;
  ProfileMenuStore topicReplyScreenVars = ProfileMenuStore();

  bool isUpdate = false;

  @override
  void initState() {
    super.initState();
    reply = widget.reply;
  }

  @override
  void dispose() {
    if (appStore.isLoading) appStore.setLoading(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.reply.topicName.validate(), style: boldTextStyle(size: 20)),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.iconColor),
          onPressed: () {
            if (isUpdate) LiveStream().emit(GetTopicDetail);

            finish(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TopicReplyComponent(
              topicId: widget.topicId,
              reply: reply!,
              isParent: true,
              isFromReplyScreen: true,
              newReply: (x) {
                isUpdate = true;
                topicReplyScreenVars.tempReplies.add(x);
              },
            ),
            ListView.builder(
              itemBuilder: (_, i) {
                return TopicReplyComponent(
                  topicId: widget.topicId,
                  isParent: false,
                  reply: reply!.children.validate()[i],
                  isFromReplyScreen: true,
                  callback: () {},
                );
              },
              padding: EdgeInsets.only(left: 16),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: reply!.children.validate().length,
            ),
            ListView.builder(
              itemBuilder: (_, i) {
                return Container(
                  decoration: BoxDecoration(color: context.cardColor, borderRadius: radius(commonRadius)),
                  margin: EdgeInsets.symmetric(vertical: 8),
                  padding: EdgeInsets.all(8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userStore.loginFullName.validate(),
                        style: primaryTextStyle(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      10.height,
                      Observer(builder: (_) {
                        return Text(topicReplyScreenVars.tempReplies[i], style: secondaryTextStyle());
                      }),
                      10.height,
                    ],
                  ),
                );
              },
              padding: EdgeInsets.only(left: 16),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: topicReplyScreenVars.tempReplies.length,
            ),
          ],
        ),
      ),
    );
  }
}
