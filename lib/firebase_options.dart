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
            ? (dotenv.env['FIREBASE_WEB_API_KEY'] ?? 'AIzaSyDemoKeyWeb')
            : 'AIzaSyDemoKeyWeb',
        appId: dotenv.isInitialized
            ? (dotenv.env['FIREBASE_WEB_APP_ID'] ?? '1:1021021021:web:demo')
            : '1:1021021021:web:demo',
        messagingSenderId: '1021021021',
        projectId: dotenv.isInitialized
            ? (dotenv.env['FIREBASE_PROJECT_ID'] ?? 'trading-app-021')
            : 'trading-app-021',
        authDomain: 'trading-app-021.firebaseapp.com',
      );

  static FirebaseOptions get android => FirebaseOptions(
        apiKey: dotenv.isInitialized
            ? (dotenv.env['FIREBASE_ANDROID_API_KEY'] ?? 'AIzaSyDemoKeyAndroid')
            : 'AIzaSyDemoKeyAndroid',
        appId: dotenv.isInitialized
            ? (dotenv.env['FIREBASE_ANDROID_APP_ID'] ??
                '1:1021021021:android:demo')
            : '1:1021021021:android:demo',
        messagingSenderId: '1021021021',
        projectId: dotenv.isInitialized
            ? (dotenv.env['FIREBASE_PROJECT_ID'] ?? 'trading-app-021')
            : 'trading-app-021',
      );

  static FirebaseOptions get ios => FirebaseOptions(
        apiKey: dotenv.isInitialized
            ? (dotenv.env['FIREBASE_IOS_API_KEY'] ?? 'AIzaSyDemoKeyIOS')
            : 'AIzaSyDemoKeyIOS',
        appId: dotenv.isInitialized
            ? (dotenv.env['FIREBASE_IOS_APP_ID'] ?? '1:1021021021:ios:demo')
            : '1:1021021021:ios:demo',
        messagingSenderId: '1021021021',
        projectId: dotenv.isInitialized
            ? (dotenv.env['FIREBASE_PROJECT_ID'] ?? 'trading-app-021')
            : 'trading-app-021',
        iosBundleId: 'com.tradingapp.tradingApp',
      );
}
