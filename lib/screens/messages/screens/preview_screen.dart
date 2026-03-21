import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/main.dart';
import 'package:socialv/store/message_store.dart';

import '../../../utils/app_constants.dart';

class PreviewScreen extends StatelessWidget {
  final File wallPaperFile;

  PreviewScreen({required this.wallPaperFile});

  final MessageStore previewScreenVars = MessageStore();

  @override
  Widget build(BuildContext context) {
    bool isChange = false;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          finish(context, isChange);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(language.preview, style: boldTextStyle(size: 20)),
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: context.iconColor),
            onPressed: () {
              finish(context, isChange);
            },
          ),
        ),
        body: Stack(
          alignment: Alignment.center,
          children: [
            Image.file(
              File(wallPaperFile.path.validate()),
              height: context.height(),
              width: context.width(),
              fit: BoxFit.cover,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                10.height,
                Row(
                  children: [
                    Divider(indent: 16, height: 32, color: context.dividerColor).expand(),
                    Text(language.today, style: secondaryTextStyle(size: 12)).paddingSymmetric(horizontal: 8),
                    Divider(endIndent: 16, height: 32, color: context.dividerColor).expand(),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(color: context.cardColor, borderRadius: radius(commonRadius)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(language.thisIsPreviewOf, style: primaryTextStyle()),
                      4.height,
                      Text(
                        DateFormat(TIME_FORMAT_1).format(DateTime.now()),
                        style: secondaryTextStyle(size: 12),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(color: context.primaryColor, borderRadius: radius(commonRadius)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(language.setACustomWallpaper, style: primaryTextStyle(color: Colors.white)),
                        4.height,
                        Text(
                          DateFormat(TIME_FORMAT_1).format(DateTime.now()),
                          style: secondaryTextStyle(size: 12, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 20,
              child: appButton(
                height: 50,
                context: context,
                text: language.setWallpaper,
                onTap: () async {
                  if (!messageStore.isGeneralSetting)
                    await showDialog(
                        builder: (context) {
                          return Observer(builder: (context) {
                            return AlertDialog(
                              title: Text("Set Wallpaper"),
                              contentPadding: EdgeInsets.zero,
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    title: Text("For this chat"),
                                    leading: Radio<int>(
                          value: 0,
                                      groupValue: previewScreenVars.selectedOption,
                                      onChanged: (int? value) {
                                        previewScreenVars.selectedOption = value!;
                                        messageStore.isGeneralSetting = false;
                                      },
                                      
                                    ),
                                  ),
                                  ListTile(
                                    title: Text("For all chat"),
                              leading:
                                    Radio<int>(
                value: 1,
                groupValue: previewScreenVars.selectedOption,
                onChanged: (int? value) {
                  previewScreenVars.selectedOption = value!;
                                        messageStore.isGeneralSetting = true;
                },
              ),
                                  ),
                                ],
                              ),
                              actions: [
                                // Cancel button
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(); // Close the dialog
                                  },
                                  child: Text('Cancel'),
                                ),
                                // OK button
                                TextButton(
                                  onPressed: () {
                                    isChange = true;
                                    finish(context, isChange);
                                  },
                                  child: Text('OK'),
                                ),
                              ],
                            );
                          });
                        },
                        context: context);
                  isChange = true;
                  finish(context, isChange);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
