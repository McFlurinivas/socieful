// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC9JGTYCyOChRAL-254kbo5W4QbMUGW-NM',
    appId: '1:627270484828:web:fec771eba87a33b238b799',
    messagingSenderId: '627270484828',
    projectId: 'socieful',
    authDomain: 'socieful.firebaseapp.com',
    storageBucket: 'socieful.appspot.com',
    measurementId: 'G-NVWP6HWFQ3',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD9-tl7cNq0FAzSHjU7dLZHByp_S-kl9Nk',
    appId: '1:627270484828:android:2ff11e11dbdd63b538b799',
    messagingSenderId: '627270484828',
    projectId: 'socieful',
    storageBucket: 'socieful.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBu5bunBLznphXg5ClYTWgBBgEuLojk654',
    appId: '1:627270484828:ios:d7445793c1538a8338b799',
    messagingSenderId: '627270484828',
    projectId: 'socieful',
    storageBucket: 'socieful.appspot.com',
    iosBundleId: 'com.example.socieful',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBu5bunBLznphXg5ClYTWgBBgEuLojk654',
    appId: '1:627270484828:ios:d7445793c1538a8338b799',
    messagingSenderId: '627270484828',
    projectId: 'socieful',
    storageBucket: 'socieful.appspot.com',
    iosBundleId: 'com.example.socieful',
  );
}