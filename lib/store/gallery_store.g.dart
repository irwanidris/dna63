// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gallery_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$GalleryStore on GalleryBase, Store {
  late final _$albumListAtom =
      Atom(name: 'GalleryBase.albumList', context: context);

  @override
  ObservableList<Albums> get albumList {
    _$albumListAtom.reportRead();
    return super.albumList;
  }

  @override
  set albumList(ObservableList<Albums> value) {
    _$albumListAtom.reportWrite(value, super.albumList, () {
      super.albumList = value;
    });
  }

  late final _$mediaTypeListAtom =
      Atom(name: 'GalleryBase.mediaTypeList', context: context);

  @override
  ObservableList<MediaModel> get mediaTypeList {
    _$mediaTypeListAtom.reportRead();
    return super.mediaTypeList;
  }

  @override
  set mediaTypeList(ObservableList<MediaModel> value) {
    _$mediaTypeListAtom.reportWrite(value, super.mediaTypeList, () {
      super.mediaTypeList = value;
    });
  }

  late final _$albumMediaListAtom =
      Atom(name: 'GalleryBase.albumMediaList', context: context);

  @override
  ObservableList<AlbumMediaListModel> get albumMediaList {
    _$albumMediaListAtom.reportRead();
    return super.albumMediaList;
  }

  @override
  set albumMediaList(ObservableList<AlbumMediaListModel> value) {
    _$albumMediaListAtom.reportWrite(value, super.albumMediaList, () {
      super.albumMediaList = value;
    });
  }

  late final _$mediaListAtom =
      Atom(name: 'GalleryBase.mediaList', context: context);

  @override
  ObservableList<PostMedia> get mediaList {
    _$mediaListAtom.reportRead();
    return super.mediaList;
  }

  @override
  set mediaList(ObservableList<PostMedia> value) {
    _$mediaListAtom.reportWrite(value, super.mediaList, () {
      super.mediaList = value;
    });
  }

  late final _$selectedIndexAtom =
      Atom(name: 'GalleryBase.selectedIndex', context: context);

  @override
  int get selectedIndex {
    _$selectedIndexAtom.reportRead();
    return super.selectedIndex;
  }

  @override
  set selectedIndex(int value) {
    _$selectedIndexAtom.reportWrite(value, super.selectedIndex, () {
      super.selectedIndex = value;
    });
  }

  late final _$isErrorInGalleryAtom =
      Atom(name: 'GalleryBase.isErrorInGallery', context: context);

  @override
  bool get isErrorInGallery {
    _$isErrorInGalleryAtom.reportRead();
    return super.isErrorInGallery;
  }

  @override
  set isErrorInGallery(bool value) {
    _$isErrorInGalleryAtom.reportWrite(value, super.isErrorInGallery, () {
      super.isErrorInGallery = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: 'GalleryBase.isLoading', context: context);

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$errorTextAtom =
      Atom(name: 'GalleryBase.errorText', context: context);

  @override
  String get errorText {
    _$errorTextAtom.reportRead();
    return super.errorText;
  }

  @override
  set errorText(String value) {
    _$errorTextAtom.reportWrite(value, super.errorText, () {
      super.errorText = value;
    });
  }

  late final _$dropdownTypeValueAtom =
      Atom(name: 'GalleryBase.dropdownTypeValue', context: context);

  @override
  MediaModel? get dropdownTypeValue {
    _$dropdownTypeValueAtom.reportRead();
    return super.dropdownTypeValue;
  }

  @override
  set dropdownTypeValue(MediaModel? value) {
    _$dropdownTypeValueAtom.reportWrite(value, super.dropdownTypeValue, () {
      super.dropdownTypeValue = value;
    });
  }

  late final _$galleryMediaListAtom =
      Atom(name: 'GalleryBase.galleryMediaList', context: context);

  @override
  ObservableList<MediaModel> get galleryMediaList {
    _$galleryMediaListAtom.reportRead();
    return super.galleryMediaList;
  }

  @override
  set galleryMediaList(ObservableList<MediaModel> value) {
    _$galleryMediaListAtom.reportWrite(value, super.galleryMediaList, () {
      super.galleryMediaList = value;
    });
  }

  late final _$dropdownStatusValueAtom =
      Atom(name: 'GalleryBase.dropdownStatusValue', context: context);

  @override
  PrivacyStatus? get dropdownStatusValue {
    _$dropdownStatusValueAtom.reportRead();
    return super.dropdownStatusValue;
  }

  @override
  set dropdownStatusValue(PrivacyStatus? value) {
    _$dropdownStatusValueAtom.reportWrite(value, super.dropdownStatusValue, () {
      super.dropdownStatusValue = value;
    });
  }

  @override
  String toString() {
    return '''
albumList: ${albumList},
mediaTypeList: ${mediaTypeList},
albumMediaList: ${albumMediaList},
mediaList: ${mediaList},
selectedIndex: ${selectedIndex},
isErrorInGallery: ${isErrorInGallery},
isLoading: ${isLoading},
errorText: ${errorText},
dropdownTypeValue: ${dropdownTypeValue},
galleryMediaList: ${galleryMediaList},
dropdownStatusValue: ${dropdownStatusValue}
    ''';
  }
}
