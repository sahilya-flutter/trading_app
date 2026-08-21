import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Default [FirebaseOptions] for use with your Firebase apps.
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
      default:
        return android;
    }
  }

  static FirebaseOptions get web => FirebaseOptions(
        apiKey: dotenv.isInitialized
            ? (dotenv.env['FIREBASE_WEB_API_KEY'] ?? 'AIzaSyTradingAppWebKey')
            : 'AIzaSyTradingAppWebKey',
        appId: dotenv.isInitialized
            ? (dotenv.env['FIREBASE_WEB_APP_ID'] ??
                '1:1021021021:web:tradingapp18fa5')
            : '1:1021021021:web:tradingapp18fa5',
        messagingSenderId: '1021021021',
        projectId: 'tradingapp-18fa5',
        authDomain: 'tradingapp-18fa5.firebaseapp.com',
      );

  static FirebaseOptions get android => FirebaseOptions(
        apiKey: dotenv.isInitialized
            ? (dotenv.env['FIREBASE_ANDROID_API_KEY'] ??
                'AIzaSyTradingAppAndroidKey')
            : 'AIzaSyTradingAppAndroidKey',
        appId: dotenv.isInitialized
            ? (dotenv.env['FIREBASE_ANDROID_APP_ID'] ??
                '1:1021021021:android:tradingapp18fa5')
            : '1:1021021021:android:tradingapp18fa5',
        messagingSenderId: '1021021021',
        projectId: 'tradingapp-18fa5',
      );

  static FirebaseOptions get ios => FirebaseOptions(
        apiKey: dotenv.isInitialized
            ? (dotenv.env['FIREBASE_IOS_API_KEY'] ?? 'AIzaSyTradingAppIOSKey')
            : 'AIzaSyTradingAppIOSKey',
        appId: dotenv.isInitialized
            ? (dotenv.env['FIREBASE_IOS_APP_ID'] ??
                '1:1021021021:ios:tradingapp18fa5')
            : '1:1021021021:ios:tradingapp18fa5',
        messagingSenderId: '1021021021',
        projectId: 'tradingapp-18fa5',
        iosBundleId: 'com.tradingapp.tradingApp',
      );
}
