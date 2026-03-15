import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:nb_utils/nb_utils.dart';

///firebase configs
/// Refer this Step Add Firebase Option Step from the link below

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return firebaseConfig;
      case TargetPlatform.iOS:
        return firebaseConfig;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static final FirebaseOptions firebaseConfig = FirebaseOptions(
    apiKey: 'AIzaSyDBvaM6tkzt64Llcgd4Bk10tO_XE7rT9Dg',
    appId: isIOS ? 'Please add iOS app ID here' : '1:207214705257:android:6bee33a03a2c9ddf9dc0f8',
    messagingSenderId: '207214705257',
    projectId: 'dna63-apps-ce32a',
    storageBucket: 'dna63-apps-ce32a.firebasestorage.app',
    iosBundleId: 'com.rhinoresources.dna63',
  );
}
