import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase Configuration for SocialV
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return androidConfig;
      case TargetPlatform.iOS:
        return iosConfig;
      case TargetPlatform.macOS:
        throw UnsupportedError('macOS not supported');
      case TargetPlatform.windows:
        throw UnsupportedError('Windows not supported');
      case TargetPlatform.linux:
        throw UnsupportedError('Linux not supported');
      default:
        throw UnsupportedError('DefaultFirebaseOptions are not supported');
    }
  }

  static const FirebaseOptions androidConfig = FirebaseOptions(
    apiKey: 'AIzaSyDBvaM6tkzt64Llcgd4Bk10tO_XE7rT9Dg',
    appId: '1:207214705257:android:6bee33a03a2c9ddf9dc0f8',
    messagingSenderId: '207214705257',
    projectId: 'dna63-apps-ce32a',
    storageBucket: 'dna63-apps-ce32a.firebasestorage.app',
  );

  static const FirebaseOptions iosConfig = FirebaseOptions(
    apiKey: 'AIzaSyDBvaM6tkzt64Llcgd4Bk10tO_XE7rT9Dg',
    appId: '1:207214705257:ios:6bee33a03a2c9ddf9dc0f8',
    messagingSenderId: '207214705257',
    projectId: 'dna63-apps-ce32a',
    storageBucket: 'dna63-apps-ce32a.firebasestorage.app',
    iosBundleId: 'com.iconic.socialv',
  );
}