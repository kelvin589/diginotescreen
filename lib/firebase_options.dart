// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars
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
    // ignore: missing_enum_constant_in_switch
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
    }

    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDFFSSQqoEXfF-cupgEkdS7CR7w6Ysg4G8',
    appId: '1:1043611456112:web:9f59073765e3c46d595ab5',
    messagingSenderId: '1043611456112',
    projectId: 'diginote-76a6e',
    authDomain: 'diginote-76a6e.firebaseapp.com',
    storageBucket: 'diginote-76a6e.appspot.com',
    measurementId: 'G-KQLG0JE99C',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDbkC-Spz8TjPIalOxVZ3Rwi2jcHXAoaLU',
    appId: '1:1043611456112:android:abe5d04301f0d41c595ab5',
    messagingSenderId: '1043611456112',
    projectId: 'diginote-76a6e',
    storageBucket: 'diginote-76a6e.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyALqcxZ9F-m7-N3-9ajY3Bsuznym9IgwvA',
    appId: '1:1043611456112:ios:81298c3dcc69c23a595ab5',
    messagingSenderId: '1043611456112',
    projectId: 'diginote-76a6e',
    storageBucket: 'diginote-76a6e.appspot.com',
    iosClientId: '1043611456112-aekn6f87l47npp6ccl0je2ibl40p07c4.apps.googleusercontent.com',
    iosBundleId: 'com.example.diginotescreen',
  );
}
