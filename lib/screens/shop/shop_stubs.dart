import 'package:flutter/material.dart';

// STUBS: Shop module disabled for MVP
class EditShopDetailsScreen extends StatelessWidget {
  const EditShopDetailsScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => Container();
}

class CouponListScreen extends StatelessWidget {
  const CouponListScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => Container();
}

class CachedImageWidget extends StatelessWidget {
  final String url;
  final double? height;
  final double? width;
  final BoxFit? fit;
  
  const CachedImageWidget({
    Key? key, 
    required this.url, 
    this.height, 
    this.width, 
    this.fit,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) => Container();
}
