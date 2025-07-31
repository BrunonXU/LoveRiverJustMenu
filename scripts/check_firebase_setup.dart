/// 🔍 Firebase配置检查工具
/// 
/// 检查Firebase配置是否正确设置
/// 
/// 使用方法：
/// dart scripts/check_firebase_setup.dart
/// 
/// 作者: Claude Code
/// 创建时间: 2025-01-30

import 'dart:io';

void main() {
  print('🔍 Firebase配置检查工具');
  print('=====================================\n');
  
  bool allGood = true;
  
  // 检查firebase_options.dart
  allGood &= _checkFirebaseOptions();
  
  // 检查依赖配置
  allGood &= _checkPubspecDependencies();
  
  // 检查主要文件
  allGood &= _checkMainFiles();
  
  // 总结
  print('\n=====================================');
  if (allGood) {
    print('✅ 所有配置检查通过！Firebase已准备就绪');
    print('🚀 现在可以运行应用测试云端功能：');
    print('   flutter run -d chrome');
  } else {
    print('❌ 发现配置问题，请根据上述提示修复');
    print('📖 参考FIREBASE_SETUP_GUIDE.md获取详细配置说明');
  }
}

/// 检查firebase_options.dart配置
bool _checkFirebaseOptions() {
  print('📁 检查Firebase配置文件...');
  
  final file = File('lib/firebase_options.dart');
  if (!file.existsSync()) {
    print('❌ firebase_options.dart文件不存在');
    return false;
  }
  
  final content = file.readAsStringSync();
  
  // 检查是否还是占位符配置
  final placeholders = [
    'AIzaSyC8Q0Q9Z9Z9Z9Z9Z9Z9Z9Z9Z9Z9Z9Z9Z9Z',
    'love-recipe-app',
    '123456789',
    'your-web-client-id.googleusercontent.com'
  ];
  
  bool hasPlaceholders = false;
  for (final placeholder in placeholders) {
    if (content.contains(placeholder)) {
      hasPlaceholders = true;
      break;
    }
  }
  
  if (hasPlaceholders) {
    print('⚠️ 发现占位符配置，需要更新为真实的Firebase配置');
    print('   运行: dart scripts/update_firebase_config.dart');
    return false;
  }
  
  // 检查必要字段
  final requiredFields = ['apiKey', 'projectId', 'authDomain', 'storageBucket'];
  bool hasAllFields = true;
  
  for (final field in requiredFields) {
    if (!content.contains("$field: '") || content.contains("$field: ''")) {
      print('❌ 缺少或为空的字段: $field');
      hasAllFields = false;
    }
  }
  
  if (hasAllFields) {
    print('✅ Firebase配置文件正常');
    return true;
  } else {
    return false;
  }
}

/// 检查pubspec.yaml依赖
bool _checkPubspecDependencies() {
  print('\n📦 检查项目依赖...');
  
  final file = File('pubspec.yaml');
  if (!file.existsSync()) {
    print('❌ pubspec.yaml文件不存在');
    return false;
  }
  
  final content = file.readAsStringSync();
  
  final requiredDeps = [
    'firebase_core',
    'firebase_auth',
    'cloud_firestore',
    'firebase_storage',
    'google_sign_in',
  ];
  
  bool allDepsPresent = true;
  for (final dep in requiredDeps) {
    if (!content.contains('$dep:')) {
      print('❌ 缺少依赖: $dep');
      allDepsPresent = false;
    }
  }
  
  if (allDepsPresent) {
    print('✅ 所有Firebase依赖已配置');
    return true;
  } else {
    print('⚠️ 运行: flutter pub get');
    return false;
  }
}

/// 检查主要文件结构
bool _checkMainFiles() {
  print('\n📋 检查文件结构...');
  
  final requiredFiles = [
    'lib/main.dart',
    'lib/core/auth/services/auth_service.dart',
    'lib/core/firestore/repositories/user_repository.dart',
    'lib/core/firestore/repositories/recipe_repository.dart',
    'lib/core/firestore/providers/firestore_providers.dart',
  ];
  
  bool allFilesExist = true;
  for (final filePath in requiredFiles) {
    if (!File(filePath).existsSync()) {
      print('❌ 文件不存在: $filePath');
      allFilesExist = false;
    }
  }
  
  if (allFilesExist) {
    print('✅ 核心文件结构完整');
  }
  
  return allFilesExist;
}