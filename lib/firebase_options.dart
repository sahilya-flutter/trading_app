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
            ? (dotenv.env['FIREBASE_WEB_API_KEY'] ?? 'AIzaSyCvgI52y4WosOtxTFjmW27YkIHS8btvx6g')
            : 'AIzaSyCvgI52y4WosOtxTFjmW27YkIHS8btvx6g',
        appId: dotenv.isInitialized
            ? (dotenv.env['FIREBASE_WEB_APP_ID'] ??
                '1:665362863693:web:tradingapp18fa5')
            : '1:665362863693:web:tradingapp18fa5',
        messagingSenderId: '665362863693',
        projectId: 'tradingapp-18fa5',
        authDomain: 'tradingapp-18fa5.firebaseapp.com',
        storageBucket: 'tradingapp-18fa5.firebasestorage.app',
      );

  static FirebaseOptions get android => FirebaseOptions(
        apiKey: dotenv.isInitialized
            ? (dotenv.env['FIREBASE_ANDROID_API_KEY'] ??
                'AIzaSyCvgI52y4WosOtxTFjmW27YkIHS8btvx6g')
            : 'AIzaSyCvgI52y4WosOtxTFjmW27YkIHS8btvx6g',
        appId: dotenv.isInitialized
            ? (dotenv.env['FIREBASE_ANDROID_APP_ID'] ??
                '1:665362863693:android:5bd5288f9467c8a1386e04')
            : '1:665362863693:android:5bd5288f9467c8a1386e04',
        messagingSenderId: '665362863693',
        projectId: 'tradingapp-18fa5',
        storageBucket: 'tradingapp-18fa5.firebasestorage.app',
      );

  static FirebaseOptions get ios => FirebaseOptions(
        apiKey: dotenv.isInitialized
            ? (dotenv.env['FIREBASE_IOS_API_KEY'] ?? 'AIzaSyCvgI52y4WosOtxTFjmW27YkIHS8btvx6g')
            : 'AIzaSyCvgI52y4WosOtxTFjmW27YkIHS8btvx6g',
        appId: dotenv.isInitialized
            ? (dotenv.env['FIREBASE_IOS_APP_ID'] ??
                '1:665362863693:ios:5bd5288f9467c8a1386e04')
            : '1:665362863693:ios:5bd5288f9467c8a1386e04',
        messagingSenderId: '665362863693',
        projectId: 'tradingapp-18fa5',
        storageBucket: 'tradingapp-18fa5.firebasestorage.app',
        iosBundleId: 'com.tradingapp.tradingApp',
      );
}
