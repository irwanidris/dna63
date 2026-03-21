import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/main.dart';
import 'package:socialv/utils/app_constants.dart';

class FilePickerDialog extends StatefulWidget {
  final bool isSelected;
  final bool showCameraVideo;
  final File? image;
  final String avatarUrl;
  final bool showRemoveOption;
  final String? type;

  FilePickerDialog(
      {this.showRemoveOption = true,
      this.isSelected = false,
      this.showCameraVideo = false,
      this.image,
      this.avatarUrl = "https://team.innoquad.in/wordpress-team/apptest-socialv/wp-content/plugins/buddypress/bp-core/images/mystery-man.jpg",
      this.type});

  @override
  State<FilePickerDialog> createState() => _FilePickerDialogState();
}

class _FilePickerDialogState extends State<FilePickerDialog> {
  bool hasCustomAvatar = false;
  bool hasSelectedImage = false;
  bool showRemoveOption = false;

  @override
  void initState() {
    hasCustomAvatar = widget.avatarUrl.isNotEmpty && widget.showRemoveOption;
    hasSelectedImage = widget.image != null && widget.image!.path.isNotEmpty && !isDefaultAvatar(widget.image!.path);
    showRemoveOption = hasCustomAvatar && hasSelectedImage;
    super.initState();
  }

  bool isDefaultAvatar(String url) {
    return url.toLowerCase().contains('default-avatar.jpg') || url.toLowerCase().contains('mystery-man.jpg');
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.width(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasSelectedImage && widget.type != "cover")
            SettingItemWidget(
              title: language.removeImage,
              titleTextStyle: primaryTextStyle(),
              leading: Icon(
                Icons.close,
              ),
              onTap: () {
                finish(context, FileTypes.CANCEL);
              },
            ),
          if (hasCustomAvatar && widget.type == "cover")
            SettingItemWidget(
              title: language.removeImage,
              titleTextStyle: primaryTextStyle(),
              leading: Icon(
                Icons.close,
              ),
              onTap: () {
                finish(context, FileTypes.CANCEL);
              },
            ),
          SettingItemWidget(
            title: language.camera,
            titleTextStyle: primaryTextStyle(),
            leading: Icon(
              LineIcons.camera,
            ),
            onTap: () {
              finish(context, FileTypes.CAMERA);
            },
          ),
          SettingItemWidget(
            title: language.videoCamera,
            titleTextStyle: primaryTextStyle(),
            leading: Icon(
              LineIcons.video_1,
            ),
            onTap: () {
              finish(context, FileTypes.CAMERA_VIDEO);
            },
          ).visible(widget.showCameraVideo),
          SettingItemWidget(
            title: language.gallery,
            titleTextStyle: primaryTextStyle(),
            leading: Icon(
              LineIcons.image_1,
            ),
            onTap: () {
              finish(context, FileTypes.GALLERY);
            },
          ),
        ],
      ),
    );
  }
}
