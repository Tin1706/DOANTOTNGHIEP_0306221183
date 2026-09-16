import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBsNTWSDWNJdm6I2_YTCi2P67yAgp4qz5c',
    appId: '1:314397093717:web:fb832576d7610f4e0b09dc',
    messagingSenderId: '314397093717',
    projectId: 'doantotnghiep-64969',
    authDomain: 'doantotnghiep-64969.firebaseapp.com',
    storageBucket: 'doantotnghiep-64969.firebasestorage.app',
  );

    static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyADz9jFj3iv0h2-V_8rauavx6yExS0QygI', // API key chuẩn từ JSON
    appId: '1:314397093717:android:65659981f288409b0b09dc',
    messagingSenderId: '314397093717',
    projectId: 'doantotnghiep-64969',
    storageBucket: 'doantotnghiep-64969.firebasestorage.app',
  );
}
