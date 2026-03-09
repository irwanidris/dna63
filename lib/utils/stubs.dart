// STUBS for MVP build - disabled modules
import 'package:flutter/material.dart';

/// SHOP STUBS
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
  
  const CachedImageWidget({Key? key, required this.url, this.height, this.width, this.fit}) : super(key: key);
  
  @override
  Widget build(BuildContext context) => Container();
}

/// GROUP STUBS
class GroupDetailScreen extends StatelessWidget {
  final int groupId;
  const GroupDetailScreen({Key? key, required this.groupId}) : super(key: key);
  @override
  Widget build(BuildContext context) => Container();
}

class GroupScreen extends StatelessWidget {
  final dynamic type;
  final int? userId;
  const GroupScreen({Key? key, this.type, this.userId}) : super(key: key);
  @override
  Widget build(BuildContext context) => Container();
}

class GroupSuggestionsComponent extends StatelessWidget {
  const GroupSuggestionsComponent({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => Container();
}

class InitialNoGroupComponent extends StatelessWidget {
  final VoidCallback? callback;
  const InitialNoGroupComponent({Key? key, this.callback}) : super(key: key);
  @override
  Widget build(BuildContext context) => Container();
}

enum GroupType { PUBLIC, PRIVATE, HIDDEN }
enum GroupInvitations { members, mods, admins }


/// MESSAGES STUBS
class MessageScreen extends StatelessWidget {
  final bool? isFromNotification;
  final String? name;
  final int? threadId;
  final VoidCallback? onDeleteThread;
  const MessageScreen({Key? key, this.isFromNotification, this.name, this.threadId, this.onDeleteThread}) : super(key: key);
  @override
  Widget build(BuildContext context) => Container();
}

class MessagesTabComponent extends StatelessWidget {
  const MessagesTabComponent({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => Container();
}

class FriendsTabComponent extends StatelessWidget {
  const FriendsTabComponent({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => Container();
}

class GroupTabComponent extends StatelessWidget {
  const GroupTabComponent({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => Container();
}

/// SHOP COMPONENTS
class CartScreen extends StatelessWidget {
  final bool? isFromHome;
  const CartScreen({Key? key, this.isFromHome}) : super(key: key);
  @override
  Widget build(BuildContext context) => Container();
}

class ShopScreen extends StatelessWidget {
  const ShopScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => Container();
}

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => Container();
}

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => Container();
}

class CheckoutScreen extends StatelessWidget {
  final dynamic cartDetails;
  const CheckoutScreen({Key? key, required this.cartDetails}) : super(key: key);
  @override
  Widget build(BuildContext context) => Container();
}

class OrderDetailScreen extends StatelessWidget {
  final dynamic orderDetails;
  const OrderDetailScreen({Key? key, required this.orderDetails}) : super(key: key);
  @override
  Widget build(BuildContext context) => Container();
}
