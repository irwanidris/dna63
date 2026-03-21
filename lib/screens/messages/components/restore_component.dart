import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:linear_timer/linear_timer.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/main.dart';
import 'package:socialv/network/messages_repository.dart';
import 'package:socialv/store/message_store.dart';

import '../../../utils/app_constants.dart';

class RestoreComponent extends StatefulWidget {
  final int threadId;
  final String? message;
  final Function(bool) callback;

  const RestoreComponent({required this.threadId, required this.callback, this.message = ""});

  @override
  State<RestoreComponent> createState() => _RestoreComponentState();
}

class _RestoreComponentState extends State<RestoreComponent> with TickerProviderStateMixin {
  MessageStore restoreComponentVars = MessageStore();
  LinearTimerController? restoreChatController;

  @override
  void initState() {
    super.initState();

    restoreChatController = LinearTimerController(this);

    afterBuildCreated(() => restoreChatController!.start());
  }

  @override
  void dispose() {
    restoreChatController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return Container(
        width: context.width(),
        decoration: BoxDecoration(
          color: restoreComponentVars.isRestored
              ? appGreenColor
              : appStore.isDarkMode
                  ? context.cardColor
                  : bodyWhite,
        ),
        child: Observer(builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (restoreComponentVars.isRestored)
                Row(
                  children: [
                    SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(color: context.cardColor, strokeWidth: 3),
                    ),
                    16.width,
                    Text(language.restoring, style: boldTextStyle(color: Colors.white)),
                  ],
                ).paddingAll(16)
              else
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info, color: Colors.white),
                    8.width,
                    Text(widget.message.validate(), maxLines: 1, overflow: TextOverflow.ellipsis, style: boldTextStyle(color: Colors.white)),
                    8.width,
                    Text(
                      language.undo,
                      style: secondaryTextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white,
                      ),
                    ).onTap(() async {
                      restoreComponentVars.isRestored = true;
                      await restoreThread(threadId: widget.threadId.validate()).then((value) {
                        widget.callback.call(true);
                      }).catchError((e) {
                        toast(e.toString());
                      });
                    })
                  ],
                ).paddingAll(16),
              LinearTimer(
                forward: false,
                duration: Duration(seconds: 15),
                color: appStore.isDarkMode ? Colors.grey : bodyWhite,
                backgroundColor: Colors.black,
                controller: restoreChatController,
                onTimerEnd: () {
                  widget.callback.call(false);
                },
              ),
            ],
          );
        }),
      );
    });
  }
}
