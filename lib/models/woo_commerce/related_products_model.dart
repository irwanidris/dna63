import 'dart:convert';
import 'package:socialv/models/woo_commerce/product_list_model.dart';
import '../../utils/constants.dart';
import 'common_models.dart';

class RelatedProductModel {
  bool? status;
  String? message;
  List<RelatedProductList>? data;

  RelatedProductModel({
    this.status,
    this.message,
    this.data,
  });

  factory RelatedProductModel.fromRawJson(String str) => RelatedProductModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RelatedProductModel.fromJson(Map<String, dynamic> json) => RelatedProductModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? [] : List<RelatedProductList>.from(json["data"]!.map((x) => RelatedProductList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class RelatedProductList {
  String? id;
  String? name;
  String? price;
  String? link;
  String? image;

  RelatedProductList({
    this.id,
    this.name,
    this.price,
    this.link,
    this.image,
  });

  factory RelatedProductList.fromRawJson(String str) => RelatedProductList.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RelatedProductList.fromJson(Map<String, dynamic> json) => RelatedProductList(
        id: json["id"],
        name: json["name"],
        price: json["price"],
        link: json["link"],
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "price": price,
        "link": link,
        "image": image,
      };
}

ProductListModel convertToProductListModel(RelatedProductList relatedProduct) {
  return ProductListModel(
    id: int.tryParse(relatedProduct.id ?? '0'),
    name: relatedProduct.name,
    price: relatedProduct.price,
    permalink: relatedProduct.link,
    images: relatedProduct.image != null ? [ImageModel(id: int.tryParse(relatedProduct.id ?? '0'), src: relatedProduct.image)] : [],
    stockStatus: StockStatus.inStock,
    status: StockStatus.publish,
    type: 'simple',
    onSale: false,
    purchasable: true,
    reviewsAllowed: true,
    regularPrice: relatedProduct.price,
  );
}