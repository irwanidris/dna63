import 'dart:convert';
import 'package:socialv/models/woo_commerce/product_list_model.dart';
import '../../utils/constants.dart';
import 'common_models.dart';

class RecentlyViewedProductModel {
  bool? status;
  String? message;
  List<RecentlyViewedProductList>? data;

  RecentlyViewedProductModel({
    this.status,
    this.message,
    this.data,
  });

  factory RecentlyViewedProductModel.fromRawJson(String str) => RecentlyViewedProductModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RecentlyViewedProductModel.fromJson(Map<String, dynamic> json) => RecentlyViewedProductModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? [] : List<RecentlyViewedProductList>.from(json["data"]!.map((x) => RecentlyViewedProductList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class RecentlyViewedProductList {
  int? id;
  String? name;
  int? price;
  String? url;
  String? image;

  RecentlyViewedProductList({
    this.id,
    this.name,
    this.price,
    this.url,
    this.image,
  });

  factory RecentlyViewedProductList.fromRawJson(String str) => RecentlyViewedProductList.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RecentlyViewedProductList.fromJson(Map<String, dynamic> json) => RecentlyViewedProductList(
        id: json["id"],
        name: json["name"],
        price: json["price"],
        url: json["url"],
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "price": price,
        "url": url,
        "image": image,
      };
}

ProductListModel convertToRecentlyViewed(RecentlyViewedProductList recentlyViewedProduct) {
  return ProductListModel(
    id: recentlyViewedProduct.id,
    name: recentlyViewedProduct.name,
    price: recentlyViewedProduct.price.toString(),
    permalink: recentlyViewedProduct.url,
    images: recentlyViewedProduct.image != null ? [ImageModel(id: recentlyViewedProduct.id, src: recentlyViewedProduct.image)] : [],
    stockStatus: StockStatus.inStock,
    status: StockStatus.publish,
    type: 'simple',
    purchasable: true,
    reviewsAllowed: true,
    regularPrice: recentlyViewedProduct.price.toString(),
    salePrice: '',
  );
}