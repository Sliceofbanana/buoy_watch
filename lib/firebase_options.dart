// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return windows;
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
    apiKey: 'AIzaSyDncrOjQ1-EQtVWZI-Ogh7ZRLZBQEaktDQ',
    appId: '1:792450465523:web:0a1b7e1e1059ed1df34186',
    messagingSenderId: '792450465523',
    projectId: 'weatherdatadb-ca0a3',
    authDomain: 'weatherdatadb-ca0a3.firebaseapp.com',
    databaseURL: 'https://weatherdatadb-ca0a3-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'weatherdatadb-ca0a3.appspot.com',
    measurementId: 'G-JPXP2P80D4',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBH2mk4JP3hWrphREY0WQ-VFJOFwVzMPTw',
    appId: '1:792450465523:android:e42eaa1b258c5deef34186',
    messagingSenderId: '792450465523',
    projectId: 'weatherdatadb-ca0a3',
    databaseURL: 'https://weatherdatadb-ca0a3-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'weatherdatadb-ca0a3.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA4xjYssXMF7WzszNeb1bQ-4yv2TIy8Kpc',
    appId: '1:792450465523:ios:9e04c68e50700ddff34186',
    messagingSenderId: '792450465523',
    projectId: 'weatherdatadb-ca0a3',
    databaseURL: 'https://weatherdatadb-ca0a3-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'weatherdatadb-ca0a3.appspot.com',
    iosBundleId: 'com.example.thesisidk',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA4xjYssXMF7WzszNeb1bQ-4yv2TIy8Kpc',
    appId: '1:792450465523:ios:9e04c68e50700ddff34186',
    messagingSenderId: '792450465523',
    projectId: 'weatherdatadb-ca0a3',
    databaseURL: 'https://weatherdatadb-ca0a3-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'weatherdatadb-ca0a3.appspot.com',
    iosBundleId: 'com.example.thesisidk',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDncrOjQ1-EQtVWZI-Ogh7ZRLZBQEaktDQ',
    appId: '1:792450465523:web:d36bef0b4238e37bf34186',
    messagingSenderId: '792450465523',
    projectId: 'weatherdatadb-ca0a3',
    authDomain: 'weatherdatadb-ca0a3.firebaseapp.com',
    databaseURL: 'https://weatherdatadb-ca0a3-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'weatherdatadb-ca0a3.appspot.com',
    measurementId: 'G-3H5XN1QBEF',
  );
}
