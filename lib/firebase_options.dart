import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  const DefaultFirebaseOptions._();

  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are configured only for Android in this project.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDigbpOUeFPnbS7034jgf5jDZBeCSSDM7w',
    appId: '1:605844347480:android:63a8c0badb4f97b926882d',
    messagingSenderId: '605844347480',
    projectId: 'aquacare-crm',
    storageBucket: 'aquacare-crm.firebasestorage.app',
  );

  static const String webClientId =
      '605844347480-cs6sinft9r1n97nbsj72f9ncjd5aetip.apps.googleusercontent.com';
}
