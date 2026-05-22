// File generated based on Firebase project: makan-bareng
// Do not edit manually.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Web platform is not configured yet. Add a Web app in Firebase Console.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB3g4QIpaIJoY1MPDLd6lbJ6liAY3PMzO8',
    appId: '1:123659372988:android:81e11dd4be126e7ff8c3b9',
    messagingSenderId: '123659372988',
    projectId: 'makan-bareng',
    storageBucket: 'makan-bareng.firebasestorage.app',
  );
}
