import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:photo_view/photo_view.dart';
import 'package:socialv/store/fragment_store/home_fragment_store.dart';

import '../../../utils/app_constants.dart';

class ImageScreen extends StatefulWidget {
  final String? imageURl;
  final bool isMultipleImages;
  final List<String>? multipleImageList;
  final int? selectedImageIndex;

  ImageScreen({
    this.imageURl,
    this.multipleImageList,
    this.selectedImageIndex,
    this.isMultipleImages = false,
  });

  @override
  State<ImageScreen> createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  late PageController pageController;
  HomeFragStore imageScreenVars = HomeFragStore();

  @override
  void initState() {
    init();
    super.initState();
  }

  init() {
    pageController = PageController(initialPage: widget.selectedImageIndex.validate());
    imageScreenVars.selectedIndex = widget.selectedImageIndex.validate();
  }

  @override
  void dispose() {
    pageController.dispose();
    setStatusBarColorBasedOnTheme();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cardDarkColor,
      appBar: AppBar(
        backgroundColor: cardDarkColor,
        leading: BackButton(color: Colors.white),
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: cardDarkColor,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: widget.isMultipleImages
          ? Stack(
              children: [
                PageView.builder(
                  controller: pageController,
                  itemCount: widget.multipleImageList.validate().length,
                  itemBuilder: (context, index) {
                    return PhotoView(
                      imageProvider: NetworkImage(widget.multipleImageList.validate()[index]),
                      minScale: PhotoViewComputedScale.contained,
                    );
                  },
                  onPageChanged: (i) {
                    imageScreenVars.selectedIndex = pageController.page!.round();
                  },
                ),
                Positioned(
                  bottom: 16,
                  right: 0,
                  left: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: widget.multipleImageList.validate().map((e) {
                      return Observer(builder: (context) {
                        return Icon(
                          Icons.circle,
                          size: imageScreenVars.selectedIndex == widget.multipleImageList!.indexOf(e) ? 12 : 8,
                          color: imageScreenVars.selectedIndex == widget.multipleImageList!.indexOf(e) ? context.primaryColor : Colors.grey.shade500,
                        ).paddingSymmetric(horizontal: 2);
                      });
                    }).toList(),
                  ),
                ),
              ],
            )
          : PhotoView(
              imageProvider: NetworkImage(widget.imageURl.validate()),
              minScale: PhotoViewComputedScale.contained,
            ),
    );
  }
}
