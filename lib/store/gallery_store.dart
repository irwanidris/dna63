import 'package:mobx/mobx.dart';
import 'package:socialv/models/common_models.dart';
import 'package:socialv/models/gallery/album_media_list_model.dart';
import 'package:socialv/models/gallery/albums.dart';
import 'package:socialv/models/general_settings_model.dart';
import 'package:socialv/models/posts/media_model.dart';

part 'gallery_store.g.dart';

class GalleryStore = GalleryBase with _$GalleryStore;

abstract class GalleryBase with Store {
  @observable
  ObservableList<Albums> albumList = ObservableList();

  @observable
  ObservableList<MediaModel> mediaTypeList = ObservableList();

  @observable
  ObservableList<AlbumMediaListModel> albumMediaList = ObservableList();

  @observable
  ObservableList<PostMedia> mediaList = ObservableList();

  @observable
  int selectedIndex = 0;

  @observable
  bool isErrorInGallery = false;

  @observable
  bool isLoading = false;

  @observable
  String errorText = "";

  ///createAlbumComponentVars

  @observable
  MediaModel? dropdownTypeValue;

  @observable
  ObservableList<MediaModel> galleryMediaList = ObservableList();

  @observable
  PrivacyStatus? dropdownStatusValue;
}
