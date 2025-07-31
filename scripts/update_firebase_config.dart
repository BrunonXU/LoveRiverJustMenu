/// 🔥 Firebase配置自动更新脚本
/// 
/// 使用方法：
/// dart scripts/update_firebase_config.dart
/// 
/// 作者: Claude Code
/// 创建时间: 2025-01-30

import 'dart:io';

void main(List<String> arguments) {
  print('🔥 Firebase配置更新工具');
  print('=====================================');
  
  // 获取用户输入的Firebase配置
  final config = _getFirebaseConfig();
  
  // 更新firebase_options.dart文件
  _updateFirebaseOptions(config);
  
  // 更新Google登录配置
  _updateGoogleSignInConfig(config['webClientId'] ?? '');
  
  print('\n✅ Firebase配置更新完成！');
  print('📝 接下来请按照FIREBASE_SETUP_GUIDE.md完成其他配置步骤');
}

/// 获取Firebase配置信息
Map<String, String> _getFirebaseConfig() {
  print('\n📋 请输入从Firebase控制台获取的配置信息：');
  print('（提示：在Firebase项目设置 → 常规 → 您的应用 → Firebase SDK snippet中找到）\n');
  
  final config = <String, String>{};
  
  config['apiKey'] = _promptInput('API Key', 'AIzaSyDxxxxxxxxxxxxxxxxxxxxxxxxxxxx');
  config['authDomain'] = _promptInput('Auth Domain', 'your-project.firebaseapp.com');
  config['projectId'] = _promptInput('Project ID', 'your-project-id');
  config['storageBucket'] = _promptInput('Storage Bucket', 'your-project.appspot.com');
  config['messagingSenderId'] = _promptInput('Messaging Sender ID', '123456789012');
  config['appId'] = _promptInput('App ID', '1:123456789012:web:abcdef123456789012345');
  config['measurementId'] = _promptInput('Measurement ID (可选)', 'G-XXXXXXXXXX', required: false);
  
  print('\n🌐 Google登录配置（可选）：');
  config['webClientId'] = _promptInput('Google Web Client ID (可选)', 'your-client-id.googleusercontent.com', required: false);
  
  return config;
}

/// 提示用户输入
String _promptInput(String label, String example, {bool required = true}) {
  while (true) {
    stdout.write('$label（例：$example）: ');
    final input = stdin.readLineSync()?.trim() ?? '';
    
    if (input.isNotEmpty) {
      return input;
    } else if (!required) {
      return '';
    } else {
      print('❌ 此字段为必填项，请重新输入');
    }
  }
}

/// 更新firebase_options.dart文件
void _updateFirebaseOptions(Map<String, String> config) {
  print('\n🔄 更新firebase_options.dart...');
  
  final file = File('lib/firebase_options.dart');
  if (!file.existsSync()) {
    print('❌ firebase_options.dart文件不存在');
    return;
  }
  
  final content = '''/// 🔥 Firebase 配置文件
/// 
/// 真实的Firebase项目配置
/// 由update_firebase_config.dart脚本自动生成
/// 
/// 作者: Claude Code
/// 更新时间: ${DateTime.now().toString().split('.')[0]}

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
    apiKey: '${config['apiKey']}',
    appId: '${config['appId']}',
    messagingSenderId: '${config['messagingSenderId']}',
    projectId: '${config['projectId']}',
    authDomain: '${config['authDomain']}',
    storageBucket: '${config['storageBucket']}',
    ${config['measurementId']?.isNotEmpty == true ? "measurementId: '${config['measurementId']}'," : ''}
  );

  /// 🤖 Android平台配置
  /// 注意：Android需要额外配置google-services.json文件
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: '${config['apiKey']}', // 注意：Android API Key可能不同
    appId: '${config['appId']}', // 注意：Android App ID可能不同
    messagingSenderId: '${config['messagingSenderId']}',
    projectId: '${config['projectId']}',
    storageBucket: '${config['storageBucket']}',
  );

  /// 🍎 iOS平台配置
  /// 注意：iOS需要额外配置GoogleService-Info.plist文件
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: '${config['apiKey']}', // 注意：iOS API Key可能不同
    appId: '${config['appId']}', // 注意：iOS App ID可能不同
    messagingSenderId: '${config['messagingSenderId']}',
    projectId: '${config['projectId']}',
    storageBucket: '${config['storageBucket']}',
    iosBundleId: 'com.loverecipe.app', // 请根据实际情况修改
  );

  /// 🖥️ macOS平台配置
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: '${config['apiKey']}',
    appId: '${config['appId']}',
    messagingSenderId: '${config['messagingSenderId']}',
    projectId: '${config['projectId']}',
    storageBucket: '${config['storageBucket']}',
    iosBundleId: 'com.loverecipe.app',
  );

  /// 🪟 Windows平台配置
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: '${config['apiKey']}',
    appId: '${config['appId']}',
    messagingSenderId: '${config['messagingSenderId']}',
    projectId: '${config['projectId']}',
    authDomain: '${config['authDomain']}',
    storageBucket: '${config['storageBucket']}',
    ${config['measurementId']?.isNotEmpty == true ? "measurementId: '${config['measurementId']}'," : ''}
  );
}

/// 📝 配置说明
/// 
/// 此文件包含真实的Firebase项目配置
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
/// 
/// 📲 移动端额外配置：
/// - Android: 需要下载google-services.json放到android/app/目录
/// - iOS: 需要下载GoogleService-Info.plist放到ios/Runner/目录
/// - 使用FlutterFire CLI可以自动配置：flutter pub global activate flutterfire_cli
''';
  
  file.writeAsStringSync(content);
  print('✅ firebase_options.dart已更新');
}

/// 更新Google登录配置
void _updateGoogleSignInConfig(String webClientId) {
  if (webClientId.isEmpty) {
    print('⚠️ 跳过Google登录配置（未提供Web Client ID）');
    return;
  }
  
  print('🔄 更新Google登录配置...');
  
  final file = File('lib/core/auth/services/auth_service.dart');
  if (!file.existsSync()) {
    print('❌ auth_service.dart文件不存在');
    return;
  }
  
  String content = file.readAsStringSync();
  
  // 替换Google登录配置
  const oldConfig = "clientId: kIsWeb ? 'your-web-client-id.googleusercontent.com' : null,";
  final newConfig = "clientId: kIsWeb ? '$webClientId' : null,";
  
  if (content.contains(oldConfig)) {
    content = content.replaceAll(oldConfig, newConfig);
    file.writeAsStringSync(content);
    print('✅ Google登录配置已更新');
  } else {
    print('⚠️ 未找到Google登录配置位置，请手动更新');
  }
}