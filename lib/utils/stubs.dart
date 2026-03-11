// STUBS for MVP build - disabled modules
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

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

/// APPINIO VIDEO PLAYER STUBS (CI: Git dependency disabled)
class CachedVideoPlayerController {
  final dynamic _file;
  CachedVideoPlayerController.network(String url) : _file = null;
  CachedVideoPlayerController.file(dynamic file) : _file = file;
  
  ValueNotifier<bool> get videoPlayerController => ValueNotifier<bool>(false);
  
  Future<void> initialize() async {}
  void play() {}
  void pause() {}
  void dispose() {}
}

class CustomVideoPlayerSettings {
  final Widget? enterFullscreenButton;
  final Widget? exitFullscreenButton;
  final Widget? playButton;
  final Widget? pauseButton;
  final bool playbackSpeedButtonAvailable;
  final bool settingsButtonAvailable;
  final bool playOnlyOnce;
  final dynamic systemUIModeInsideFullscreen;
  
  CustomVideoPlayerSettings({
    this.enterFullscreenButton,
    this.exitFullscreenButton,
    this.playButton,
    this.pauseButton,
    this.playbackSpeedButtonAvailable = true,
    this.settingsButtonAvailable = true,
    this.playOnlyOnce = false,
    this.systemUIModeInsideFullscreen,
  });
}

class CustomVideoPlayerController {
  final CachedVideoPlayerController customVideoPlayerController;
  final CachedVideoPlayerController videoPlayerController;
  
  CustomVideoPlayerController({ 
    dynamic context,
    required CachedVideoPlayerController videoPlayerController,
    required CustomVideoPlayerSettings customVideoPlayerSettings,
  }) : this.videoPlayerController = videoPlayerController, 
       this.customVideoPlayerController = videoPlayerController;
  
  void dispose() {}
}

class CustomVideoPlayer extends StatelessWidget {
  final CustomVideoPlayerController customVideoPlayerController;
  
  const CustomVideoPlayer({Key? key, required this.customVideoPlayerController}) : super(key: key);
  
  @override
  Widget build(BuildContext context) => Container();
}



/// PAYPAL CHECKOUT STUB (CI: Git dependency disabled)
extension PaypalCheckoutExtension on PaypalCheckout {
  PaypalCheckout whenComplete(dynamic Function() callback) {
    callback();
    return this;
  }
  
  PaypalCheckout onError(dynamic Function(dynamic, StackTrace) handler) {
    return this;
  }
  
  PaypalCheckout catchError(dynamic Function(dynamic) handler) {
    return this;
  }
}

class PaypalCheckout {
  PaypalCheckout({
    dynamic context,
    bool? sandboxMode,
    required String clientId,
    required String secretKey,
    required String returnURL,
    required String cancelURL,
    required List<dynamic> transactions,
    String? note,
    required dynamic onSuccess,
    required dynamic onError,
    required dynamic onCancel,
  }) {
    // Stub payment simulation - always succeeds
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(Duration(milliseconds: 500));
      if (onSuccess != null) {
        onSuccess({'message': 'Payment successful', 'data': {'id': 'STUB_${DateTime.now().millisecondsSinceEpoch}'}});
      }
    });
  }
  
  PaypalCheckout launch(dynamic context) => this;
  
  static Future<void> execute({
    required dynamic context,
    bool? sandboxMode,
    required String clientId,
    required String secretKey,
    required String returnURL,
    required String cancelURL,
    required List<dynamic> transactions,
    required Function(dynamic) onSuccess,
    required Function(dynamic) onError,
    required Function(dynamic) onCancel,
  }) async {}
}
