import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/store/gallery_store.dart';
import 'package:socialv/utils/app_constants.dart';

import '../../../components/loading_widget.dart';
import '../../../components/no_data_lottie_widget.dart';
import '../../../main.dart';
import '../../../models/gallery/albums.dart';
import '../../../models/posts/media_model.dart';
import '../../../network/rest_apis.dart';
import '../components/gallery_create_album_button.dart';
import '../components/gallery_screen_album_component.dart';
import 'create_album_screen.dart';
import 'single_album_detail_screen.dart';

class GalleryScreen extends StatefulWidget {
  final int? groupId;
  final int? userId;
  final bool canEdit;

  GalleryScreen({Key? key, this.groupId, this.userId, this.canEdit = false}) : super(key: key);

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  GalleryStore galleryStore = GalleryStore();
  ScrollController scrollCont = ScrollController();
  int mPage = 1;
  bool mIsLastPage = false;

  @override
  void initState() {
    super.initState();
    galleryStore.mediaTypeList.addAll(appStore.allowedMedia.validate().firstWhere((element) => element.component == (widget.groupId != null ? Component.groups : Component.members)).allowedTypes.validate());
    galleryStore.mediaTypeList.insert(0, MediaModel(type: '', title: "All", isActive: true));
    init();
    setStatusBarColorBasedOnTheme();
    afterBuildCreated(
      () {
        scrollCont.addListener(
          () {
            if (scrollCont.position.pixels == scrollCont.position.maxScrollExtent) {
              if (!mIsLastPage) {
                mPage++;
                init(page: mPage);
              }
            }
          },
        );
      },
    );
  }

  Future<void> init({int page = 1, bool showLoader = true}) async {
    galleryStore.isLoading = showLoader;
    await getAlbums(
      type: galleryStore.mediaTypeList[galleryStore.selectedIndex].type,
      userId: widget.userId,
      page: page,
      groupId: widget.groupId == null ? "" : widget.groupId.toString(),
      albumList: galleryStore.albumList,
      lastPageCallback: (p0) {
        mIsLastPage = p0;
      },
    ).then(
      (value) {
        galleryStore.isLoading = false;
        galleryStore.isErrorInGallery = false;
      },
    ).catchError(
      (e) {
        toast(e.toString(), print: true);
        galleryStore.isErrorInGallery = true;
        galleryStore.errorText = e.toString();
        galleryStore.isLoading = false;
        throw e;
      },
    );
  }

  Future<void> deleteAlbum({required int id}) async {
    ifNotTester(
      () async {
        mPage = 1;
        galleryStore.isLoading = false;
        await deleteMedia(id: id, type: MediaTypes.gallery).then(
          (value) {
            toast(value.message);
            init();
          },
        ).catchError(
          (e) {
            toast(e.toString());
            galleryStore.isLoading = false;
          },
        );
      },
    );
  }

  @override
  void dispose() {
    if (galleryStore.isLoading) galleryStore.isLoading = false;
    setStatusBarColorBasedOnTheme();

    scrollCont.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.scaffoldBackgroundColor,
        title: Text(language.gallery, style: boldTextStyle(size: 20)),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.iconColor),
          onPressed: () {
            finish(context);
          },
        ),
      ),
      body: Stack(
        children: [
          Column(children: [
            /// error Widget
            Observer(builder: (context) {
              return SizedBox(
                height: context.height() * 0.8,
                child: NoDataWidget(
                  imageWidget: NoDataLottieWidget(),
                  title: galleryStore.errorText,
                  onRetry: () {
                    init();
                  },
                  retryText: '   ${language.clickToRefresh}   ',
                ).center(),
              ).visible(galleryStore.isErrorInGallery && !galleryStore.isLoading);
            }),

            /// horizontal list widget
            HorizontalList(
              itemCount: galleryStore.mediaTypeList.length,
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              itemBuilder: (context, index) {
                MediaModel item = galleryStore.mediaTypeList[index];
                return Observer(builder: (context) {
                  return Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: galleryStore.selectedIndex == index ? context.primaryColor : context.cardColor,
                      borderRadius: BorderRadius.all(radiusCircular()),
                    ),
                    child: Text(
                      item.title.validate(),
                      style: boldTextStyle(size: 14, color: galleryStore.selectedIndex == index ? context.cardColor : context.primaryColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ).onTap(
                    () {
                      if (galleryStore.selectedIndex != index && !galleryStore.isLoading) {
                        galleryStore.selectedIndex = index;
                        galleryStore.isLoading = true;
                        init(showLoader: true, page: 1).then((value) => galleryStore.isLoading = false);
                      }
                      appStore.setSelectedMedia(galleryStore.selectedIndex == 0 ? galleryStore.mediaTypeList[1] : galleryStore.mediaTypeList[galleryStore.selectedIndex]);
                    },
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                  );
                });
              },
            ),

            /// list widget

            Observer(builder: (context) {
              return galleryStore.mediaTypeList.isNotEmpty && !galleryStore.isErrorInGallery
                  ? SingleChildScrollView(
                      controller: scrollCont,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (galleryStore.albumList.isEmpty && !galleryStore.isLoading)
                            SizedBox(
                              height: context.height() * 0.74,
                              child: !widget.canEdit.validate()
                                  ? NoDataWidget(
                                      imageWidget: NoDataLottieWidget(),
                                      title: language.noDataFound,
                                      onRetry: () {
                                        init();
                                      },
                                      retryText: '   ${language.clickToRefresh}   ',
                                    ).center()
                                  : GalleryCreateAlbumButton(
                                      isEmptyList: true,
                                      mediaTypeList: galleryStore.mediaTypeList,
                                      callback: () {
                                        CreateAlbumScreen(
                                          groupID: widget.groupId,
                                          refreshAlbum: () {
                                            init();
                                          },
                                        ).launch(context);
                                      },
                                    ),
                            ),
                          if (galleryStore.albumList.isNotEmpty)
                            Column(
                              children: [
                                if (widget.canEdit.validate())
                                  GalleryCreateAlbumButton(
                                    mediaTypeList: galleryStore.mediaTypeList,
                                    isEmptyList: false,
                                    callback: () {
                                      CreateAlbumScreen(
                                        groupID: widget.groupId,
                                        refreshAlbum: () {
                                          init();
                                        },
                                      ).launch(context);
                                    },
                                  ),
                                8.height,
                                GridView.builder(
                                  itemCount: galleryStore.albumList.length,
                                  padding: EdgeInsets.only(bottom: mIsLastPage ? 16 : 60, left: 16, right: 16),
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 1,
                                    crossAxisSpacing: 8,
                                    mainAxisExtent: 160,
                                    mainAxisSpacing: 8,
                                  ),
                                  itemBuilder: (context, index) {
                                    Albums album = galleryStore.albumList[index];

                                    return GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () {
                                        SingleAlbumDetailScreen(
                                          album: album,
                                          canEdit: widget.canEdit,
                                        ).launch(context);
                                      },
                                      child: GalleryScreenAlbumComponent(
                                        album: album,
                                        canDelete: album.canDelete.validate(),
                                        callback: (albumId) {
                                          deleteAlbum(id: albumId);
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                        ],
                      ),
                    ).expand()
                  : Offstage();
            }),
          ]),
          Observer(builder: (context) {
            return Positioned(
              bottom: galleryStore.albumList.isNotEmpty && mPage != 1 ? 8 : null,
              width: galleryStore.albumList.isNotEmpty && mPage != 1 ? MediaQuery.of(context).size.width : null,
              child: ThreeBounceLoadingWidget().center().visible(galleryStore.isLoading && mPage > 1),
            );
          }),
          Observer(builder: (context) {
            return LoadingWidget(isBlurBackground: mPage == 1 ? true : false).center().visible(galleryStore.isLoading && mPage == 1);
          }),
        ],
      ),
    );
  }
}
