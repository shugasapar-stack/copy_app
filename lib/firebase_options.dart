import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBjvK1bjec5SnDOS0BLxSblVpkvfLUxXXM',
    appId: '1:905742773866:android:6ee015cecf67c94c1ea413',
    messagingSenderId: '905742773866',
    projectId: 'mainproj-efc74',
    authDomain: 'mainproj-efc74.firebaseapp.com',
    storageBucket: 'mainproj-efc74.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBjvK1bjec5SnDOS0BLxSblVpkvfLUxXXM',
    appId: '1:905742773866:android:6ee015cecf67c94c1ea413',
    messagingSenderId: '905742773866',
    projectId: 'mainproj-efc74',
    storageBucket: 'mainproj-efc74.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBjvK1bjec5SnDOS0BLxSblVpkvfLUxXXM',
    appId: '1:905742773866:android:6ee015cecf67c94c1ea413',
    messagingSenderId: '905742773866',
    projectId: 'mainproj-efc74',
    storageBucket: 'mainproj-efc74.firebasestorage.app',
    iosBundleId: 'com.sapargali.shugila.mindflow',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBjvK1bjec5SnDOS0BLxSblVpkvfLUxXXM',
    appId: '1:905742773866:android:6ee015cecf67c94c1ea413',
    messagingSenderId: '905742773866',
    projectId: 'mainproj-efc74',
    storageBucket: 'mainproj-efc74.firebasestorage.app',
    iosBundleId: 'com.sapargali.shugila.mindflow',
  );
}
