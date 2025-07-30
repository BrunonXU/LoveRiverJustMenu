/// 🔥 Firebase 配置文件
/// 
/// 为不同平台提供Firebase初始化配置
/// 这个文件通常由 Firebase CLI 自动生成
/// 当前使用占位符配置，实际部署时需要替换为真实的Firebase项目配置
/// 
/// 作者: Claude Code
/// 创建时间: 2025-01-30

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase 配置选项
/// 
/// 根据平台返回相应的Firebase配置
/// 支持Web、Android、iOS等多平台部署
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

  /// 🌐 Web平台配置
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC8Q0Q9Z9Z9Z9Z9Z9Z9Z9Z9Z9Z9Z9Z9Z9Z',
    appId: '1:123456789:web:abcdef123456789',
    messagingSenderId: '123456789',
    projectId: 'love-recipe-app',
    authDomain: 'love-recipe-app.firebaseapp.com',
    storageBucket: 'love-recipe-app.appspot.com',
    measurementId: 'G-MEASUREMENT_ID',
  );

  /// 🤖 Android平台配置
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC8Q0Q9Z9Z9Z9Z9Z9Z9Z9Z9Z9Z9Z9Z9Z9Z',
    appId: '1:123456789:android:abcdef123456789',
    messagingSenderId: '123456789',
    projectId: 'love-recipe-app',
    storageBucket: 'love-recipe-app.appspot.com',
  );

  /// 🍎 iOS平台配置
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC8Q0Q9Z9Z9Z9Z9Z9Z9Z9Z9Z9Z9Z9Z9Z9Z',
    appId: '1:123456789:ios:abcdef123456789',
    messagingSenderId: '123456789',
    projectId: 'love-recipe-app',
    storageBucket: 'love-recipe-app.appspot.com',
    iosBundleId: 'com.example.loveRecipeApp',
  );

  /// 🖥️ macOS平台配置
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC8Q0Q9Z9Z9Z9Z9Z9Z9Z9Z9Z9Z9Z9Z9Z9Z',
    appId: '1:123456789:ios:abcdef123456789',
    messagingSenderId: '123456789',
    projectId: 'love-recipe-app',
    storageBucket: 'love-recipe-app.appspot.com',
    iosBundleId: 'com.example.loveRecipeApp',
  );

  /// 🪟 Windows平台配置
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC8Q0Q9Z9Z9Z9Z9Z9Z9Z9Z9Z9Z9Z9Z9Z9Z',
    appId: '1:123456789:web:abcdef123456789',
    messagingSenderId: '123456789',
    projectId: 'love-recipe-app',
    authDomain: 'love-recipe-app.firebaseapp.com',
    storageBucket: 'love-recipe-app.appspot.com',
    measurementId: 'G-MEASUREMENT_ID',
  );
}

/// 📝 配置说明
/// 
/// 当前配置为占位符配置，用于开发和演示目的
/// 在实际部署前，请按照以下步骤配置真实的Firebase项目：
/// 
/// 1. 访问 Firebase Console (https://console.firebase.google.com/)
/// 2. 创建新项目或选择现有项目
/// 3. 添加您的应用平台（Web/Android/iOS）
/// 4. 下载配置文件：
///    - Web: firebase-config 对象
///    - Android: google-services.json
///    - iOS: GoogleService-Info.plist
/// 5. 使用 Firebase CLI 重新生成此文件：
///    ```bash
///    firebase login
///    firebase init
///    flutterfire configure
///    ```
/// 
/// 🔐 安全注意事项：
/// - API Key 可以公开，但建议设置使用限制（Domain/IP 白名单）
/// - 启用 Firebase Security Rules 保护数据
/// - 在生产环境中启用 App Check 防止滥用
/// 
/// 📱 支持的服务：
/// - ✅ Firebase Authentication（邮箱+Google登录）
/// - ✅ Cloud Firestore（数据库）
/// - ✅ Firebase Storage（文件存储）
/// - ✅ Firebase Analytics（数据分析）
/// - ✅ Firebase Performance（性能监控）
/// - ⚠️ Cloud Functions（需要升级到 Blaze 计划）
/// - ⚠️ Firebase Hosting（需要升级到 Blaze 计划）